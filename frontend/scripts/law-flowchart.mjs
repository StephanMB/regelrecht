#!/usr/bin/env node
// Renders a law YAML as flowcharts for lawyers: one Mermaid chart per article
// that computes something, plus an HTML page that shows each chart next to the
// article text it was drawn from.
//
//   node frontend/scripts/law-flowchart.mjs <law.yaml> [out-dir]
//
// Writes <out-dir>/<law-id>.html and <out-dir>/<law-id>-art-<n>.mmd. The .mmd
// files are the deterministic product; the HTML only loads Mermaid to draw
// them.
import { mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { join, resolve } from 'node:path';
import { load as loadYaml } from 'js-yaml';
import { buildLawFlowcharts } from '../src/utils/lawFlowchart.js';

const [input, outDir = '.'] = process.argv.slice(2);
if (!input) {
  console.error('gebruik: law-flowchart.mjs <law.yaml> [out-dir]');
  process.exit(2);
}

const law = loadYaml(readFileSync(input, 'utf8'));
const charts = buildLawFlowcharts(law);
const id = law.$id || 'law';
mkdirSync(outDir, { recursive: true });

for (const chart of charts) {
  writeFileSync(join(outDir, `${id}-art-${chart.article}.mmd`), chart.mermaid);
}
writeFileSync(join(outDir, `${id}.html`), page(law, charts));
console.log(`${charts.length} stroomschema('s) geschreven naar ${resolve(outDir)}`);

function page(law, charts) {
  const title = law.name && !String(law.name).startsWith('#') ? law.name : humanizeId(law.$id);
  const sections = charts
    .map(
      (c) => `
  <section>
    <h2>Artikel ${esc(c.article)}</h2>
    <div class="row">
      <pre class="mermaid">${esc(c.mermaid)}</pre>
      <aside>
        <h3>Wettekst</h3>
        ${c.text.split(/\n\s*\n/).map((p) => `<p>${esc(p.trim())}</p>`).join('\n        ')}
        ${c.url ? `<p><a href="${esc(c.url)}">wetten.overheid.nl</a></p>` : ''}
      </aside>
    </div>
  </section>`,
    )
    .join('\n');
  return `<!doctype html>
<html lang="nl">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>${esc(title)} — stroomschema</title>
<style>
  :root { color-scheme: light; --ink: #1a1a1a; --muted: #5a5a5a; --line: #d8dde3; --bg: #fff; }
  body { margin: 0; padding: 24px 16px; font: 15px/1.5 system-ui, sans-serif; color: var(--ink); background: var(--bg); }
  main { max-width: 1400px; margin: 0 auto; }
  h1 { font-size: 1.6rem; margin: 0 0 4px; }
  .lead { color: var(--muted); margin: 0 0 24px; }
  section { border-top: 1px solid var(--line); padding: 16px 0 24px; }
  .row { display: grid; grid-template-columns: minmax(0, 3fr) minmax(280px, 1fr); gap: 24px; align-items: start; }
  .mermaid { margin: 0; overflow-x: auto; background: none; }
  aside { font-size: 0.9rem; color: var(--muted); }
  aside h3 { font-size: 0.95rem; color: var(--ink); margin: 0 0 8px; }
  @media (max-width: 900px) { .row { grid-template-columns: 1fr; } }
</style>
</head>
<body>
<main>
  <h1>${esc(title)}</h1>
  <p class="lead">Stroomschema per artikel, automatisch afgeleid uit ${esc(law.$id)} (geldig vanaf ${esc(law.valid_from)}). Ruit = vraag, rechthoek = berekening.</p>
${sections}
</main>
<script type="module">
  import mermaid from 'https://cdn.jsdelivr.net/npm/mermaid@11.4.1/dist/mermaid.esm.min.mjs';
  mermaid.initialize({ startOnLoad: true, theme: 'base', flowchart: { htmlLabels: true, useMaxWidth: false, wrappingWidth: 260, curve: 'basis' } });
</script>
</body>
</html>
`;
}

function humanizeId(id) {
  const t = String(id).replace(/_/g, ' ');
  return t.charAt(0).toUpperCase() + t.slice(1);
}

function esc(s) {
  return String(s ?? '').replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
}
