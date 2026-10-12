# TAKEN — selectiecriteria EHDS (Verordening (EU) 2025/327), secundair gebruik

## Checklist

- [x] **Stap 0** — remote: fetch van `NederlandseDigitaleDienst/regelrecht`, push naar de fork
      `StephanMB/regelrecht` (de enige repo met schrijfrechten in deze sessie); branch op
      `origin/main` 8d48bfb4. Repository verkend; bevindingen hieronder.
- [x] **Stap 1** — brontekst NL en EN als Formex-4-ZIP via Cellar (`publications.europa.eu`), ruwe
      bytes, URL/datum/sha256 in `bron/bronnen.yaml`. EUR-Lex gaf curl alleen een WAF-uitdaging.
      Rectificaties: drie (FRA/HRV/LAV, HUN, HUN), geen NL of EN; wijzigingshandelingen: geen.
- [x] **Stap 2** — `scripts/inventaris.py` → `inventaris.json` (369 bepalingen);
      `dekking.yaml`; `scripts/valideer.py`, getest op de vereiste en extra faalgevallen (ontbrekende status,
      onbekende ID, gewijzigde bron, niet-letterlijk citaat).
- [x] **Stap 3** — regelwerk `regulation/nl/eu_verordening/…/2025-03-25.yaml` (art. 1, 2, 50, 51, 60, 105);
      `just validate` OK. Gaten in het formaat: README.md.
- [x] **Stap 4** — 13 conceptscenario's met @concept en @bepaling-tags, alle vijf randgevallen; 13/13
      groen door de engine (`BDD_BUCKET=corpus REGULATION_PATH=…`).
- [x] **Stap 5** — `interpretatielogboek.md`: K1–K19, NL/EN-verschillen N1–N5.
- [x] **Stap 6** — inventaris twee keer gedraaid: byte-identiek (sha256 39350cb0…); valideer.py OK;
      BDD 13/13; pre-commit hooks groen; elk element herlezen naast de brontekst (één correctie:
      “leden” i.p.v. “punten” in de vraag over gezondheidsgegevens).
- [x] **Stap 7** — gecommit en gepusht naar `claude/blissful-lamport-vf4bbt`; draft-PR
      https://github.com/StephanMB/regelrecht/pull/1 (tegen de fork; een PR tegen
      `NederlandseDigitaleDienst/regelrecht` kon vanuit deze sessie niet worden geopend).

## Bevindingen stap 0

- **Bronverwijzing.** Op documentniveau ondersteunt het schema (v0.7.1) een EU-bron
  (`EU_VERORDENING` + `celex_nummer`, `eli`). Op elementniveau niet: `legal_basis` kent alleen BWB
  (`bwb_id`, `juriconnect`) en `article`/`paragraph`/`sentence`, met `additionalProperties: false`.
- **Invoer en open normen.** Oordeel per geval: `parameters` met `required: false` (onbeantwoord =
  onbekend, RFC-036, Kleene-logica in EN/OF). `open_terms` is voor normen die een lagere regeling
  invult; `markings` voor wat het formaat niet kan uitdrukken.
- **Draaien.** `just validate <bestand>`; `just bdd`; met `BDD_BUCKET=corpus REGULATION_PATH=<map>`
  draait bucket A een andere corpusmap, maar de loader leest alleen `<map>/nl/`.
- **Plek.** Corpusconventie `corpus/regulation/<land>/<laag>/<id>/<datum>.yaml`; een
  ongevalideerd EU-concept hoort daar niet. Werkmap: `verkenningen/ehds/`. Buiten de werkmap alleen
  een regel in `REUSE.toml` voor de bronbestanden (.zip/.rq/.csv), die `reuse lint` vereist.
- **Code review.** AGENTS.md vraagt een review door een subagent; de opdracht staat hooguit één
  subagent toe en alleen als dat sneller is. Niet gedaan; in plaats daarvan elk element zelf
  herlezen naast de bron en de validator met negatieve gevallen getest.
