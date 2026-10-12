# TAKEN — selectiecriteria EHDS (Verordening (EU) 2025/327), secundair gebruik

Status: **geblokkeerd bij stap 1**. De brontekst kon niet worden opgehaald (zie
hieronder). Zonder authentieke brontekst worden stap 2 t/m 6 niet uitgevoerd;
er staat bewust niets uit het geheugen in deze map.

## Checklist

- [x] **Stap 0** — remote bijgewerkt naar `NederlandseDigitaleDienst/regelrecht`
      (fetch; push gaat naar de fork `StephanMB/regelrecht`, de enige repo met
      schrijfrechten in deze sessie), branch gebaseerd op `origin/main` 8d48bfb4,
      repository verkend. Bevindingen hieronder.
- [ ] **Stap 1** — brontekst ophalen. **Blokkade:** het netwerkbeleid van de
      cloudomgeving weigert de CONNECT naar elk benodigd domein (HTTP 403 van de
      egress-proxy, `connect_rejected`), getest op 2026-10-12:
      `eur-lex.europa.eu`, `publications.europa.eu`, `op.europa.eu`,
      `data.europa.eu`, `cellar-api.op.europa.eu`. Nodig in de allowlist:
      `eur-lex.europa.eu` (HTML NL/EN en rectificaties) en
      `publications.europa.eu` (Formex-XML via Cellar). Ook rectificaties zijn
      daardoor niet te controleren.
- [ ] **Stap 2** — inventaris, dekkingsmatrix, validatiescript. Geblokkeerd door stap 1
      (de parser hangt af van het bronformaat: Formex of EUR-Lex-HTML).
- [ ] **Stap 3** — specificatie. Geblokkeerd door stap 1.
- [ ] **Stap 4** — concepttestgevallen. Geblokkeerd door stap 3.
- [ ] **Stap 5** — interpretatielogboek en NL/EN-vergelijking. Geblokkeerd door stap 1.
- [ ] **Stap 6** — verificatie. Geblokkeerd door stap 2–4.
- [ ] **Stap 7** — draft-PR. Uitgesteld tot er inhoud is; deze checklist staat
      wel op de branch `claude/blissful-lamport-vf4bbt`.

## Bevindingen stap 0

- **Bronverwijzing.** Op documentniveau ondersteunt het schema (v0.7.1) een
  EU-bron: `regulatory_layer: EU_VERORDENING` maakt `celex_nummer` verplicht,
  `eli` is optioneel. Op elementniveau niet: `legal_basis` kent alleen
  `bwb_id` (patroon `BWBR…`), `juriconnect` (alleen BWB) en `article` /
  `paragraph` / `sentence` — geen `celex`, geen `onderdeel`, en
  `additionalProperties: false`. `articles[].references` vereist `bwb_id`.
  Een verwijzing naar art. 51, lid 1, onder a, past dus niet volledig; het
  onderdeel en een inventaris-ID kunnen alleen in `explanation` (vrije tekst).
- **Invoer en open normen.** Menselijk oordeel per geval: `parameters`
  (met `required: false` geeft een ontbrekend antwoord een *unknown* dat de
  parameter noemt, RFC-036). `open_terms` is voor normen die een lagere
  regeling invult (hier: categorieën die een lidstaat toevoegt). `markings`
  markeert wat het formaat niet kan uitdrukken. Een vraagtekst per parameter
  heeft geen eigen veld; alleen `description`.
- **Draaien.** `just validate <bestand>` (schema + typecheck);
  `just bdd` (cucumber-rs); `BDD_BUCKET=corpus REGULATION_PATH=<map>` laat
  bucket A een andere corpusmap draaien, met scenario's in
  `<wet>/scenarios/*.feature`; `cargo run --bin evaluate` evalueert één wet via
  JSON op stdin. Lokaal waren `mold`, `just` en `pre-commit` niet geïnstalleerd;
  nu wel.
- **Plek.** Corpusconventie: `corpus/regulation/<land>/<laag>/<id>/<datum>.yaml`.
  Er is nog geen EU-tak, en een ongevalideerd concept hoort niet in de corpus.
  Werkmap: `verkenningen/ehds/`, met daarin later dezelfde
  `regulation/…/scenarios/`-indeling zodat `REGULATION_PATH` erop kan wijzen.
