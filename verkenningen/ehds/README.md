# Verkenning EHDS: selectiecriteria secundair gebruik

**Concept, te valideren door een jurist.** Deze map stelt geen juridische uitleg vast.

Vraag: valt een databron onder de plicht om elektronische gezondheidsgegevens beschikbaar te stellen
voor secundair gebruik (Verordening (EU) 2025/327), onder welke categorie(ën) van art. 51, en vanaf
welke datum?

| Pad | Wat |
|-----|-----|
| `bron/` | Formex-XML (NL, EN) als ruwe bytes, rectificatie- en wijzigingscontrole; herkomst en sha256 in `bronnen.yaml` |
| `inventaris.json` | Alle 369 bepalingen met ID, vindplaats en sha256; gemaakt door `scripts/inventaris.py` |
| `dekking.yaml` | Per bepaling één status: `gemodelleerd`, `buiten_scope` of `open` |
| `regulation/nl/eu_verordening/…/2025-03-25.yaml` | Het regelwerk: de beslisstructuur |
| `…/scenarios/secundair_gebruik.feature` | Concepttestgevallen (niet onafhankelijk; `@concept`) |
| `interpretatielogboek.md` | Modelleerkeuzes (K1–K19) en NL/EN-verschillen (N1–N5) |

Elk menselijk oordeel is een parameter met `required: false`. Onbeantwoord geeft “onbekend”, behalve
waar een ander antwoord de uitkomst al beslist (een `nee` in een EN-voorwaarde, een `ja` in een OF).

## Draaien

```bash
python3 -I verkenningen/ehds/scripts/inventaris.py   # inventaris opnieuw maken
python3 -I verkenningen/ehds/scripts/valideer.py     # faalt bij gat, onbekende ID of gewijzigde bron
just validate verkenningen/ehds/regulation/nl/eu_verordening/*/2025-03-25.yaml
cd packages/engine && BDD_BUCKET=corpus REGULATION_PATH="$(pwd)/../../verkenningen/ehds/regulation" \
  cargo test --test bdd
```

## Gaten in het regelrecht-formaat (schema v0.7.1)

1. `legal_basis` kent alleen Nederlandse bronnen: `bwb_id` en `juriconnect` zijn BWB-only, en er is
   geen veld voor CELEX/ELI, onderdeel of alinea (`additionalProperties: false`). Inventaris-ID en
   onderdeel staan nu in de vrije tekst van `explanation`. Nodig: `celex`/`eli`, `onderdeel`, `alinea`,
   of een generiek `provision_id`.
2. `articles[].references` vereist een `bwb_id`; een verwijzing naar een EU-bepaling past niet.
3. De BDD-loader leest alleen `<REGULATION_PATH>/nl/`; er is geen plek voor EU-recht. Daarom staat
   dit regelwerk onder `nl/eu_verordening/`. Nodig: een `eu/`-tak die loader en corpus kennen.
4. Een parameter heeft geen veld voor de vraagtekst en geen manier om een leesvraag (uitleg van de
   tekst) te onderscheiden van een feit over het geval; beide staan nu in `description`.
5. Er is geen artikel-URL voor een EU-handeling die hier te verifiëren was; alle `url`'s wijzen naar
   de ELI van de hele verordening.
