// Turns the machine_readable part of a law YAML into Mermaid flowcharts that a
// lawyer can read: decisions become diamonds with a yes/no question, arithmetic
// becomes one formula per path, and every value says where it comes from.
//
// Deterministic by construction: the same parsed YAML always yields the same
// text (node ids are a counter, iteration follows YAML order, nothing reads
// the clock or a random source). Nothing is interpreted or summarised beyond
// what the YAML states; the only transformation is "hoisting": a condition
// that the expression tests in several places (heeft_toeslagpartner in the
// zorgtoeslag formula is tested five times) is asked once, up front, and the
// expression is simplified on each branch.

const MAX_HOIST_DEPTH = 4;

const COMPARISON_WORDS = {
  EQUALS: 'gelijk aan',
  NOT_EQUALS: 'ongelijk aan',
  GREATER_THAN: 'groter dan',
  GREATER_THAN_OR_EQUAL: 'groter dan of gelijk aan',
  LESS_THAN: 'kleiner dan',
  LESS_THAN_OR_EQUAL: 'kleiner dan of gelijk aan',
};
const COMPARISON_SYMBOLS = {
  EQUALS: '=', NOT_EQUALS: '≠', GREATER_THAN: '>', GREATER_THAN_OR_EQUAL: '≥',
  LESS_THAN: '<', LESS_THAN_OR_EQUAL: '≤',
};
const ARITHMETIC = {
  ADD: { symbol: '+', prec: 1 },
  SUBTRACT: { symbol: '−', prec: 1 },
  MULTIPLY: { symbol: '×', prec: 2 },
  DIVIDE: { symbol: '÷', prec: 2 },
};
const ROUNDING_WORDS = { ROUND: 'afgerond', CEIL: 'naar boven afgerond', FLOOR: 'naar beneden afgerond' };
const LEGAL_CHARACTER_WORDS = {
  BESCHIKKING: 'beschikking',
  TOETS: 'toets',
  WAARDEBEPALING: 'waardebepaling',
  BESLUIT_VAN_ALGEMENE_STREKKING: 'besluit van algemene strekking',
  INFORMATIEF: 'informatief',
};
const DELEGATION_WORDS = {
  MINISTERIELE_REGELING: 'ministeriële regeling',
  AMVB: 'algemene maatregel van bestuur',
  GEMEENTELIJKE_VERORDENING: 'gemeentelijke verordening',
};

/**
 * @param {object} law parsed law YAML
 * @returns {{ article: string, url?: string, text: string, mermaid: string }[]}
 *   one chart per article whose execution computes something; articles that
 *   only assign a fixed value or pass an open term through are left out.
 */
export function buildLawFlowcharts(law) {
  const outputIndex = indexOutputs(law);
  return (law.articles || [])
    .filter(hasComputation)
    .map((article) => ({
      article: String(article.number),
      url: article.url,
      text: article.text || '',
      mermaid: articleFlowchart(article, outputIndex),
    }));
}

function hasComputation(article) {
  const actions = article.machine_readable?.execution?.actions || [];
  return actions.some((a) => isOperation(actionExpression(a)));
}

// output name → { article, delegation } for every output any article declares,
// so an input sourced from this same law can say "art. 3" or "ministeriële
// regeling (art. 4)".
function indexOutputs(law) {
  const index = new Map();
  for (const article of law.articles || []) {
    const mr = article.machine_readable;
    if (!mr?.execution) continue;
    const openTerms = new Map((mr.open_terms || []).map((t) => [t.id, t]));
    for (const action of mr.execution.actions || []) {
      if (!action.output || index.has(action.output)) continue;
      const expr = actionExpression(action);
      const passthrough = typeof expr === 'string' && openTerms.get(expr.slice(1));
      index.set(action.output, {
        article: String(article.number),
        delegation: passthrough ? passthrough.delegation_type : null,
      });
    }
  }
  return index;
}

function actionExpression(action) {
  if (action.operation) {
    const { output: _output, ...expr } = action;
    return expr;
  }
  return action.value;
}

// --- Chart for one article -------------------------------------------------

function articleFlowchart(article, outputIndex) {
  const execution = article.machine_readable.execution;
  const symbols = buildSymbols(article);
  const graph = createGraph();
  const actions = (execution.actions || []).filter((a) => a.output);
  const actionsByOutput = new Map(actions.map((a) => [a.output, a]));

  // An output another action of this article refers to is drawn where it is
  // used; the rest are the chart's roots.
  const referenced = new Set();
  for (const action of actions) {
    for (const ref of collectRefs(actionExpression(action))) {
      if (actionsByOutput.has(ref) && ref !== action.output) referenced.add(ref);
    }
  }
  const roots = actions.filter((a) => !referenced.has(a.output) && isOperation(actionExpression(a)));

  const ctx = { graph, symbols, actionsByOutput, outputIndex, article, inlined: new Set(), depth: 0 };

  const start = graph.node('terminal', startLabel(article, execution));
  let exits = [{ from: start }];

  const inputs = inputLines(execution, outputIndex, article);
  if (inputs.length) {
    const data = graph.node('data', `<b>Gegevens</b><br/>${inputs.join('<br/>')}`);
    graph.connect(exits, data);
    exits = [{ from: data }];
  }

  for (const action of roots) {
    exits = emitAction(action, exits, ctx);
  }

  return graph.render();
}

function startLabel(article, execution) {
  const produces = execution.produces;
  const kind = produces?.legal_character ? LEGAL_CHARACTER_WORDS[produces.legal_character] : null;
  return `<b>Artikel ${article.number}</b>${kind ? `<br/>${kind}` : ''}`;
}

function inputLines(execution, outputIndex, article) {
  const lines = [];
  for (const p of execution.parameters || []) {
    lines.push(`• ${humanize(p.name)}: opgegeven bij de aanvraag`);
  }
  for (const input of execution.input || []) {
    lines.push(`• ${humanize(input.name)}: ${describeSource(input.source, outputIndex, article)}`);
  }
  return lines;
}

function describeSource(source, outputIndex, article) {
  if (!source) return 'gegeven';
  if (source.regulation) return lawTitle(source.regulation);
  const origin = outputIndex.get(source.output);
  if (!origin) return 'deze wet';
  if (origin.delegation) {
    return `${DELEGATION_WORDS[origin.delegation] || humanize(origin.delegation.toLowerCase())} (art. ${origin.article})`;
  }
  return origin.article === String(article.number) ? 'dit artikel' : `art. ${origin.article} van deze wet`;
}

function lawTitle(id) {
  const text = humanize(id);
  return text.charAt(0).toUpperCase() + text.slice(1);
}

function buildSymbols(article) {
  const mr = article.machine_readable;
  const symbols = new Map();
  for (const [name, def] of Object.entries(mr.definitions || {})) {
    const isObject = def !== null && typeof def === 'object';
    symbols.set(name, {
      kind: 'definition',
      value: isObject ? def.value : def,
      unit: isObject ? def.type_spec?.unit ?? null : null,
    });
  }
  const execution = mr.execution;
  for (const p of execution.parameters || []) symbols.set(p.name, { kind: 'parameter', type: p.type, unit: null });
  for (const i of execution.input || []) {
    symbols.set(i.name, { kind: 'input', type: i.type, unit: i.type_spec?.unit ?? null, source: i.source });
  }
  for (const o of execution.output || []) {
    symbols.set(o.name, { kind: 'output', type: o.type, unit: o.type_spec?.unit ?? null });
  }
  return symbols;
}

// --- Emitting flow ----------------------------------------------------------
// Every emitter takes the dangling exits it continues from and returns the
// exits it leaves behind, so paths compose without knowing each other.

function emitAction(action, entry, ctx) {
  ctx.inlined.add(action.output);
  const symbol = ctx.symbols.get(action.output);
  const expr = actionExpression(action);
  if (symbol?.type === 'boolean') {
    const { yes, no } = emitCondition(expr, entry, ctx);
    const name = capitalize(humanize(action.output));
    const yesNode = ctx.graph.node('yes', `${name}: <b>ja</b>`);
    const noNode = ctx.graph.node('no', `${name}: <b>nee</b>`);
    ctx.graph.connect(yes, yesNode);
    ctx.graph.connect(no, noNode);
    return [{ from: yesNode }];
  }
  return emitComputation(action.output, expr, entry, ctx);
}

function emitComputation(output, expr, entry, ctx) {
  ctx.graph.pushGroup(`Berekening ${humanize(output)}`);
  const exits = hoist(
    expr,
    entry,
    ctx,
    (leaf, leafEntry) => {
      const id = ctx.graph.node('formula', formulaLabel(output, leaf, ctx));
      ctx.graph.connect(leafEntry, id);
      return [{ from: id }];
    },
    (a, b) => [...a, ...b],
  );
  ctx.graph.popGroup();
  return exits;
}

function emitCondition(cond, entry, ctx) {
  if (typeof cond === 'string' && cond.startsWith('$')) {
    return emitQuestion(cond, entry, ctx);
  }
  if (!isOperation(cond)) {
    // A literal condition: always true or always false.
    return cond ? { yes: entry, no: [] } : { yes: [], no: entry };
  }
  const op = cond.operation;
  if (op === 'AND') {
    let current = entry;
    const no = [];
    for (const sub of cond.conditions || []) {
      const r = emitCondition(sub, current, ctx);
      current = r.yes;
      no.push(...r.no);
    }
    return { yes: current, no };
  }
  if (op === 'OR') {
    let current = entry;
    const yes = [];
    for (const sub of cond.conditions || []) {
      const r = emitCondition(sub, current, ctx);
      current = r.no;
      yes.push(...r.yes);
    }
    return { yes, no: current };
  }
  if (op === 'NOT') {
    const r = emitCondition(cond.value, entry, ctx);
    return { yes: r.no, no: r.yes };
  }
  // `$x = false` asks the same question as `$x`, with the answers swapped.
  if (op === 'EQUALS' && cond.value === false && isRef(cond.subject)) {
    const r = emitCondition(cond.subject, entry, ctx);
    return { yes: r.no, no: r.yes };
  }
  if (op === 'EQUALS' && cond.value === true && isRef(cond.subject)) {
    return emitCondition(cond.subject, entry, ctx);
  }
  return hoist(
    cond,
    entry,
    ctx,
    (leaf, leafEntry) => emitQuestion(leaf, leafEntry, ctx),
    (a, b) => ({ yes: [...a.yes, ...b.yes], no: [...a.no, ...b.no] }),
  );
}

function emitQuestion(cond, entry, ctx) {
  entry = inlineDependencies(cond, entry, ctx);
  const id = ctx.graph.node('decision', questionLabel(cond, ctx));
  ctx.graph.connect(entry, id);
  return { yes: [{ from: id, label: 'ja' }], no: [{ from: id, label: 'nee' }] };
}

// An output of this same article that a question refers to is computed right
// before the question, so the chart reads in the order a case is handled.
function inlineDependencies(expr, entry, ctx) {
  for (const ref of collectRefs(expr)) {
    const action = ctx.actionsByOutput.get(ref);
    if (action && !ctx.inlined.has(ref)) entry = emitAction(action, entry, ctx);
  }
  return entry;
}

// Ask the first condition that an IF in `expr` tests, once, then continue on
// each branch with the expression as it reads under that answer.
function hoist(expr, entry, ctx, leaf, combine) {
  const ifNode = ctx.depth < MAX_HOIST_DEPTH ? findHoistable(expr) : null;
  if (!ifNode) return leaf(expr, entry);
  const condition = ifNode.cases[0].when;
  const branch = emitCondition(condition, entry, ctx);
  ctx.depth++;
  const whenTrue = hoist(substitute(expr, condition, true), branch.yes, ctx, leaf, combine);
  const whenFalse = hoist(substitute(expr, condition, false), branch.no, ctx, leaf, combine);
  ctx.depth--;
  return combine(whenTrue, whenFalse);
}

function findHoistable(expr) {
  let found = null;
  walk(expr, (node) => {
    if (found || !isConditional(node) || !node.cases?.length) return;
    if (!containsConditional(node.cases[0].when)) found = node;
  });
  return found;
}

function substitute(expr, condition, truth) {
  const key = canonical(condition);
  const rec = (node) => {
    if (Array.isArray(node)) return node.map(rec);
    if (!node || typeof node !== 'object') return node;
    if (isConditional(node) && node.cases?.length && canonical(node.cases[0].when) === key) {
      if (truth) return rec(node.cases[0].then);
      if (node.cases.length > 1) return rec({ ...node, cases: node.cases.slice(1) });
      return rec(node.default);
    }
    const out = {};
    for (const [k, v] of Object.entries(node)) out[k] = rec(v);
    return simplify(out);
  };
  return rec(expr);
}

// A branch can leave `x + 0` behind (the zorgtoeslag formula adds 0 when the
// income stays under the threshold). Dropping it changes nothing about the
// value and saves the reader a term.
function simplify(node) {
  if (!isOperation(node) || !Array.isArray(node.values)) return node;
  const isZero = (v) => v === 0;
  if (node.operation === 'ADD' || (node.operation === 'SUBTRACT')) {
    const values = node.values.filter((v, i) => !(isZero(v) && (node.operation === 'ADD' || i > 0)));
    if (values.length === node.values.length) return node;
    if (values.length === 1) return values[0];
    if (values.length === 0) return 0;
    return { ...node, values };
  }
  return node;
}

// --- Labels -----------------------------------------------------------------

function questionLabel(cond, ctx) {
  if (isRef(cond)) {
    const name = cond.slice(1);
    const hint = sourceHint(name, ctx);
    return `${capitalize(humanize(name))}?${hint ? `<br/><i>${hint}</i>` : ''}`;
  }
  const op = cond.operation;
  if (COMPARISON_WORDS[op]) {
    const unit = unitOf(cond.subject, ctx) ?? unitOf(cond.value, ctx);
    return `Is ${render(cond.subject, ctx, unit)} ${COMPARISON_WORDS[op]} ${render(cond.value, ctx, unit)}?`;
  }
  if (op === 'IN' || op === 'NOT_IN') {
    const items = cond.values ?? cond.value;
    const list = Array.isArray(items) ? items.map((v) => render(v, ctx)).join(', ') : render(items, ctx);
    return `Is ${render(cond.subject, ctx)} ${op === 'IN' ? '' : 'niet '}een van: ${list}?`;
  }
  if (op === 'NOT_NULL') return `Is ${render(cond.subject, ctx)} bekend?`;
  return `${capitalize(render(cond, ctx))}?`;
}

function sourceHint(name, ctx) {
  const symbol = ctx.symbols.get(name);
  if (symbol?.kind !== 'input' || !symbol.source) return null;
  return describeSource(symbol.source, ctx.outputIndex, ctx.article);
}

function formulaLabel(output, expr, ctx) {
  // Rounding and a floor/ceiling around the whole formula are limits on the
  // outcome, not part of the sum; they read better as a note underneath.
  const notes = [];
  for (;;) {
    if (isOperation(expr) && ROUNDING_WORDS[expr.operation]) {
      const unit = unitOf(expr.value, ctx);
      const precision = expr.precision ?? 0;
      notes.push(
        unit === 'eurocent' && precision === 0
          ? `${ROUNDING_WORDS[expr.operation]} op hele centen`
          : `${ROUNDING_WORDS[expr.operation]} op ${precision} decimalen`,
      );
      expr = expr.value;
      continue;
    }
    if (isOperation(expr) && (expr.operation === 'MAX' || expr.operation === 'MIN') && expr.values?.length === 2) {
      const literal = expr.values.findIndex((v) => typeof v === 'number');
      if (literal !== -1) {
        const other = expr.values[1 - literal];
        const word = expr.operation === 'MAX' ? 'niet lager dan' : 'niet hoger dan';
        notes.push(`${word} ${render(expr.values[literal], ctx, unitOf(other, ctx))}`);
        expr = other;
        continue;
      }
    }
    break;
  }
  const formulaCtx = { ...ctx, inlineDefinitions: false };
  const lines = [`<b>${humanize(output)}</b> =`, ...splitTopLevel(expr, formulaCtx)];
  for (const note of notes) lines.push(`<i>${note}</i>`);
  const used = collectRefs(expr).filter((name) => isScalarDefinition(ctx.symbols.get(name)));
  if (used.length) {
    lines.push('<i>waarbij</i>');
    const unit = unitOf(expr, ctx);
    for (const name of used) {
      const symbol = ctx.symbols.get(name);
      lines.push(`<i>${humanize(name)} = ${formatValue(symbol.value, symbol.unit ?? unit)}</i>`);
    }
  }
  return lines.join('<br/>');
}

// The outermost sum is drawn one term per line, so `a − (b + c)` reads as a
// short list instead of one long sentence.
function splitTopLevel(expr, ctx) {
  if (!isOperation(expr) || (expr.operation !== 'ADD' && expr.operation !== 'SUBTRACT')) {
    return [render(expr, ctx)];
  }
  const unit = unitOf(expr, ctx);
  const symbol = ARITHMETIC[expr.operation].symbol;
  return expr.values.map((v, i) => {
    const r = renderPrec(v, ctx, unit);
    const text = expr.operation === 'SUBTRACT' && i > 0 && r.prec === 1 ? `(${r.text})` : r.text;
    return i === 0 ? text : `${symbol} ${text}`;
  });
}

function isScalarDefinition(symbol) {
  return symbol?.kind === 'definition' && symbol.value !== null && typeof symbol.value !== 'object';
}

// Infix rendering with just enough parentheses. `unit` is the unit a bare
// number takes from its context (0 next to an amount is € 0).
function render(expr, ctx, unit = null) {
  return renderPrec(expr, ctx, unit).text;
}

function renderPrec(expr, ctx, unit) {
  if (expr === null || expr === undefined) return atom('(leeg)');
  if (typeof expr === 'boolean') return atom(expr ? 'ja' : 'nee');
  if (typeof expr === 'number') return atom(formatValue(expr, unit));
  if (typeof expr === 'string') {
    if (!expr.startsWith('$')) return atom(`‘${expr}’`);
    return atom(renderRef(expr.slice(1), ctx, unit));
  }
  if (!isOperation(expr)) return atom(String(expr));

  const op = expr.operation;
  const values = expr.values || [];
  if (ARITHMETIC[op]) {
    const { symbol, prec } = ARITHMETIC[op];
    const childUnit = op === 'ADD' || op === 'SUBTRACT' ? unitOf(expr, ctx) : null;
    const parts = values.map((v, i) => {
      const r = renderPrec(v, ctx, childUnit);
      // a − (b + c), a ÷ (b × c): the right side of a non-commutative
      // operator needs brackets at equal precedence as well.
      const nonCommutative = (op === 'SUBTRACT' || op === 'DIVIDE') && i > 0;
      return r.prec < prec || (nonCommutative && r.prec === prec) ? `(${r.text})` : r.text;
    });
    return { text: parts.join(` ${symbol} `), prec };
  }
  if (op === 'MIN' || op === 'MAX') {
    const childUnit = unitOf(expr, ctx);
    const word = op === 'MIN' ? 'laagste van' : 'hoogste van';
    return atom(`${word} (${values.map((v) => render(v, ctx, childUnit)).join('; ')})`);
  }
  if (COMPARISON_SYMBOLS[op]) {
    const u = unitOf(expr.subject, ctx) ?? unitOf(expr.value, ctx);
    return { text: `${render(expr.subject, ctx, u)} ${COMPARISON_SYMBOLS[op]} ${render(expr.value, ctx, u)}`, prec: 0 };
  }
  if (op === 'AND' || op === 'OR') {
    const word = op === 'AND' ? ' en ' : ' of ';
    return { text: (expr.conditions || []).map((c) => render(c, ctx)).join(word), prec: 0 };
  }
  if (op === 'NOT') return atom(`niet (${render(expr.value, ctx)})`);
  if (isConditional(expr)) {
    const cases = (expr.cases || []).map((c) => `als ${render(c.when, ctx)}: ${render(c.then, ctx, unit)}`);
    if (expr.default !== undefined) cases.push(`anders ${render(expr.default, ctx, unit)}`);
    return atom(`(${cases.join('; ')})`);
  }
  if (ROUNDING_WORDS[op]) {
    return atom(`${render(expr.value, ctx, unit)} ${ROUNDING_WORDS[op]} op ${expr.precision ?? 0} decimalen`);
  }
  if (op === 'AGE') {
    return atom(`leeftijd in jaren op ${render(expr.reference_date, ctx)} (geboren op: ${render(expr.date_of_birth, ctx)})`);
  }
  if (op === 'DATE_ADD') {
    const parts = ['years', 'months', 'weeks', 'days']
      .filter((k) => expr[k] !== undefined)
      .map((k) => (typeof expr[k] === 'number' ? formatValue(expr[k], k) : `${render(expr[k], ctx)} ${formatValue(0, k).slice(2)}`));
    return atom(`${render(expr.date ?? expr.subject ?? expr.value, ctx)} plus ${parts.join(' en ')}`);
  }
  if (op === 'DATE_DIFF') {
    const words = { days: 'dagen', months: 'maanden', years: 'jaren' };
    return atom(`aantal ${words[expr.in] || expr.in} van ${render(expr.from, ctx)} tot ${render(expr.to, ctx)}`);
  }
  if (op === 'FOREACH') {
    const words = { ADD: 'som', OR: 'een of meer', AND: 'allemaal', MIN: 'laagste', MAX: 'hoogste' };
    const item = expr.as || 'item';
    const filter = expr.filter ? `, voor zover ${render(expr.filter, ctx)}` : '';
    const what = `${render(expr.body, ctx)} voor elke ${humanize(item)} in ${render(expr.collection, ctx)}${filter}`;
    return atom(expr.combine ? `${words[expr.combine] || expr.combine.toLowerCase()} van (${what})` : `(${what})`);
  }
  // Anything else is shown by name with its operands, rather than guessed at.
  const operands = Object.entries(expr)
    .filter(([k]) => k !== 'operation' && k !== 'title')
    .map(([k, v]) => `${k}: ${Array.isArray(v) ? v.map((x) => render(x, ctx)).join(', ') : render(v, ctx)}`);
  return atom(`${op.toLowerCase()} (${operands.join('; ')})`);
}

function atom(text) {
  return { text, prec: 3 };
}

function renderRef(name, ctx, contextUnit) {
  const symbol = ctx.symbols.get(name);
  if (isScalarDefinition(symbol) && ctx.inlineDefinitions !== false) {
    return `${humanize(name)} (${formatValue(symbol.value, symbol.unit ?? contextUnit)})`;
  }
  return humanize(name);
}

function unitOf(expr, ctx) {
  if (typeof expr === 'string' && expr.startsWith('$')) return ctx.symbols.get(expr.slice(1))?.unit ?? null;
  if (!isOperation(expr)) return null;
  const op = expr.operation;
  if (op === 'ADD' || op === 'SUBTRACT' || op === 'MIN' || op === 'MAX') {
    for (const v of expr.values || []) {
      const u = unitOf(v, ctx);
      if (u) return u;
    }
    return null;
  }
  if (op === 'MULTIPLY') {
    const units = (expr.values || []).map((v) => unitOf(v, ctx)).filter((u) => u && u !== 'ratio' && u !== 'percentage');
    return units[0] ?? null;
  }
  if (ROUNDING_WORDS[op]) return unitOf(expr.value, ctx);
  if (isConditional(expr)) {
    for (const c of expr.cases || []) {
      const u = unitOf(c.then, ctx);
      if (u) return u;
    }
    return unitOf(expr.default, ctx);
  }
  return null;
}

function formatValue(value, unit) {
  if (typeof value !== 'number') return typeof value === 'string' ? `‘${value}’` : String(value);
  if (unit === 'eurocent') {
    const euros = value / 100;
    return `€ ${formatNumber(euros, Number.isInteger(euros) ? 0 : 2)}`;
  }
  if (unit === 'euro') return `€ ${formatNumber(value, Number.isInteger(value) ? 0 : 2)}`;
  if (unit === 'ratio') return `${formatNumber(Number((value * 100).toFixed(6)))}%`;
  if (unit === 'percentage') return `${formatNumber(value)}%`;
  if (unit === 'years' || unit === 'months' || unit === 'weeks' || unit === 'days') {
    const words = { years: 'jaar', months: 'maanden', weeks: 'weken', days: 'dagen' };
    return `${formatNumber(value)} ${words[unit]}`;
  }
  return formatNumber(value);
}

// Dutch notation without depending on the runtime's locale data.
function formatNumber(value, fixed) {
  const text = fixed === undefined ? String(value) : value.toFixed(fixed);
  const [int, frac] = text.split('.');
  const sign = int.startsWith('-') ? '-' : '';
  const digits = sign ? int.slice(1) : int;
  const grouped = digits.replace(/\B(?=(\d{3})+(?!\d))/g, '.');
  return `${sign}${grouped}${frac ? `,${frac}` : ''}`;
}

// --- Helpers ----------------------------------------------------------------

function isOperation(v) {
  return v !== null && typeof v === 'object' && !Array.isArray(v) && typeof v.operation === 'string';
}

function isConditional(v) {
  return isOperation(v) && (v.operation === 'IF' || v.operation === 'SWITCH');
}

function isRef(v) {
  return typeof v === 'string' && v.startsWith('$');
}

function containsConditional(expr) {
  let found = false;
  walk(expr, (node) => {
    if (isConditional(node)) found = true;
  });
  return found;
}

function walk(node, visit) {
  if (Array.isArray(node)) {
    for (const v of node) walk(v, visit);
    return;
  }
  if (!node || typeof node !== 'object') return;
  visit(node);
  for (const v of Object.values(node)) walk(v, visit);
}

function collectRefs(expr) {
  const refs = [];
  const add = (s) => {
    if (isRef(s) && !refs.includes(s.slice(1))) refs.push(s.slice(1));
  };
  const rec = (node) => {
    if (Array.isArray(node)) return node.forEach(rec);
    if (typeof node === 'string') return add(node);
    if (!node || typeof node !== 'object') return;
    for (const v of Object.values(node)) rec(v);
  };
  rec(expr);
  return refs;
}

// Key order is fixed by sorting, so two conditions written with their keys in
// a different order still count as the same question.
function canonical(v) {
  if (Array.isArray(v)) return `[${v.map(canonical).join(',')}]`;
  if (v && typeof v === 'object') {
    return `{${Object.keys(v).sort().map((k) => `${JSON.stringify(k)}:${canonical(v[k])}`).join(',')}}`;
  }
  return JSON.stringify(v);
}

function humanize(name) {
  return String(name).replace(/^\$/, '').replace(/_/g, ' ');
}

function capitalize(text) {
  return text.charAt(0).toUpperCase() + text.slice(1);
}

// --- Mermaid output ---------------------------------------------------------

const SHAPES = {
  terminal: (id, l) => `${id}(["${l}"])`,
  data: (id, l) => `${id}[/"${l}"/]`,
  decision: (id, l) => `${id}{"${l}"}`,
  formula: (id, l) => `${id}["${l}"]`,
  yes: (id, l) => `${id}(["${l}"])`,
  no: (id, l) => `${id}(["${l}"])`,
};

function createGraph() {
  const nodes = [];
  const edges = [];
  const groups = [];
  const stack = [];
  let counter = 0;

  return {
    node(kind, label) {
      const id = `n${++counter}`;
      nodes.push({ id, kind, label, group: stack.at(-1) ?? null });
      return id;
    },
    connect(exits, to) {
      for (const exit of exits) {
        if (!edges.some((e) => e.from === exit.from && e.to === to && e.label === exit.label)) {
          edges.push({ from: exit.from, to, label: exit.label });
        }
      }
    },
    pushGroup(label) {
      const id = `g${groups.length + 1}`;
      groups.push({ id, label, parent: stack.at(-1) ?? null });
      stack.push(id);
    },
    popGroup() {
      stack.pop();
    },
    render() {
      const lines = ['flowchart TD'];
      const emitGroup = (groupId, indent) => {
        for (const n of nodes.filter((x) => x.group === groupId)) {
          lines.push(`${indent}${SHAPES[n.kind](n.id, escapeLabel(n.label))}:::${n.kind}`);
        }
        for (const g of groups.filter((x) => x.parent === groupId)) {
          lines.push(`${indent}subgraph ${g.id}["${escapeLabel(g.label)}"]`);
          emitGroup(g.id, `${indent}  `);
          lines.push(`${indent}end`);
        }
      };
      emitGroup(null, '  ');
      for (const e of edges) {
        lines.push(e.label ? `  ${e.from} -->|${e.label}| ${e.to}` : `  ${e.from} --> ${e.to}`);
      }
      lines.push(
        '  classDef terminal fill:#e8eef6,stroke:#154273,color:#154273',
        '  classDef data fill:#f5f5f5,stroke:#666,color:#222,text-align:left',
        '  classDef decision fill:#fff4d6,stroke:#b07d00,color:#222',
        '  classDef formula fill:#ffffff,stroke:#154273,color:#222',
        '  classDef yes fill:#e3f1e3,stroke:#2f7d32,color:#1b4d1d',
        '  classDef no fill:#fbe4e4,stroke:#b42318,color:#7a1610',
      );
      return `${lines.join('\n')}\n`;
    },
  };
}

function escapeLabel(text) {
  return String(text).replace(/"/g, '#quot;');
}
