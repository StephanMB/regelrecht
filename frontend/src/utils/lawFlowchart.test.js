import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { describe, expect, it } from 'vitest';
import * as yaml from 'js-yaml';
import { buildLawFlowcharts } from './lawFlowchart.js';

// vitest runs from frontend/; the test environment rewrites import.meta.url.
const zorgtoeslagPath = resolve(
  process.cwd(),
  '../corpus/regulation/nl/wet/wet_op_de_zorgtoeslag/2025-01-01.yaml',
);
const zorgtoeslag = () => yaml.load(readFileSync(zorgtoeslagPath, 'utf8'));
const chart = (charts, article) => charts.find((c) => c.article === article).mermaid;

describe('buildLawFlowcharts', () => {
  it('produces identical text for the same law, every time', () => {
    expect(buildLawFlowcharts(zorgtoeslag())).toEqual(buildLawFlowcharts(zorgtoeslag()));
  });

  it('draws only articles that compute something', () => {
    // art. 4 passes an open term through, art. 5 and 8 assign a fixed value
    expect(buildLawFlowcharts(zorgtoeslag()).map((c) => c.article)).toEqual(['2', '3']);
  });

  it('asks the toeslagpartner question once instead of in every IF', () => {
    const art2 = chart(buildLawFlowcharts(zorgtoeslag()), '2');
    expect(art2.match(/Heeft toeslagpartner\?/g)).toHaveLength(1);
    // two incomes × two partner situations = four formulas, none with an IF left
    expect(art2.match(/<b>hoogte zorgtoeslag<\/b> =/g)).toHaveLength(4);
    expect(art2).not.toMatch(/\bals\b|\bif\b/i);
  });

  it('computes the amount before the question that depends on it', () => {
    const art2 = chart(buildLawFlowcharts(zorgtoeslag()), '2');
    expect(art2.indexOf('subgraph g1["Berekening hoogte zorgtoeslag"]')).toBeGreaterThan(-1);
    expect(art2).toMatch(/Is hoogte zorgtoeslag groter dan € 0\?/);
  });

  it('writes amounts and percentages the way the law text does', () => {
    const charts = buildLawFlowcharts(zorgtoeslag());
    expect(chart(charts, '2')).toContain('drempelinkomen alleenstaande = € 39.719');
    expect(chart(charts, '2')).toContain('percentage drempelinkomen alleenstaande = 1,896%');
    // art. 3 gives its limits no unit; the comparison with an amount supplies it
    expect(chart(charts, '3')).toContain('vermogensgrens alleenstaand (€ 141.896)');
  });

  it('names where each input comes from', () => {
    const art2 = chart(buildLawFlowcharts(zorgtoeslag()), '2');
    expect(art2).toContain('standaardpremie: ministeriële regeling (art. 4)');
    expect(art2).toContain('vermogen onder grens: art. 3 van deze wet');
    expect(art2).toContain('is verzekerde: Zorgverzekeringswet');
  });

  it('drops a term that a branch reduces to zero', () => {
    const art2 = chart(buildLawFlowcharts(zorgtoeslag()), '2');
    expect(art2).not.toContain('+ € 0');
  });
});
