#!/usr/bin/env python3
"""Controleert inventaris, dekkingsmatrix, regelwerk en scenario's tegen elkaar.

Faalt (exitcode 1) als:
- de sha256 van een bronbestand niet meer klopt met bron/bronnen.yaml;
- de inventaris, opnieuw gebouwd uit de bron, afwijkt van inventaris.json;
- een bepaling uit de inventaris geen (of geen geldige) status heeft in dekking.yaml,
  of de matrix een ID noemt die niet in de inventaris staat;
- een element van het regelwerk (parameter of actie) geen inventaris-ID noemt, een ID
  noemt die niet in de inventaris staat of niet `gemodelleerd` is, of een citaat «…»
  bevat dat niet letterlijk in de geciteerde bepaling staat;
- de `elementen` bij een `gemodelleerd` item niet gelijk zijn aan de elementen die
  dat item (of een bepaling eronder) in het regelwerk citeren;
- de artikeltekst in het regelwerk afwijkt van de brontekst;
- een scenario geen @concept-tag of geen @bepaling:<id>-tag heeft, of een onbekende ID noemt;
- het interpretatielogboek een ID tussen backticks noemt die niet in de inventaris staat.

Gebruik:  python3 -I scripts/valideer.py
"""

import hashlib
import importlib.util
import re
import sys
from pathlib import Path

import yaml

WERKMAP = Path(__file__).resolve().parent.parent
REGELWERK = sorted((WERKMAP / "regulation").rglob("*.yaml"))
SCENARIOS = sorted((WERKMAP / "regulation").rglob("scenarios/*.feature"))
STATUSSEN = {"gemodelleerd": "elementen", "buiten_scope": "reden", "open": "vraag"}
ANKER = re.compile(r"^\[([a-z0-9-]+(?:, [a-z0-9-]+)*)\]")
CITAAT = re.compile(r"«([^»]+)»")

fouten = []


def fout(msg):
    fouten.append(msg)


def norm(s):
    return " ".join(s.split())


def laad_inventarismodule():
    spec = importlib.util.spec_from_file_location("inventaris", WERKMAP / "scripts" / "inventaris.py")
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def controleer_bron():
    bronnen = yaml.safe_load((WERKMAP / "bron" / "bronnen.yaml").read_text(encoding="utf-8"))
    for b in bronnen["bestanden"]:
        p = WERKMAP / "bron" / b["pad"]
        if not p.exists():
            fout(f"bron: {b['pad']} ontbreekt")
        elif hashlib.sha256(p.read_bytes()).hexdigest() != b["sha256"]:
            fout(f"bron: sha256 van {b['pad']} klopt niet meer met bron/bronnen.yaml")


def controleer_inventaris(mod):
    vers = mod.serialiseer(mod.bouw())
    vastgelegd = (WERKMAP / "inventaris.json").read_text(encoding="utf-8")
    if vers != vastgelegd:
        import json
        oud = {b["id"]: b for b in json.loads(vastgelegd)["bepalingen"]}
        nieuw = {b["id"]: b for b in json.loads(vers)["bepalingen"]}
        verschil = sorted(i for i in oud.keys() | nieuw.keys() if oud.get(i) != nieuw.get(i))
        fout("inventaris: opnieuw gebouwd uit de bron wijkt af van inventaris.json; "
             f"betrokken ID's: {', '.join(verschil[:20]) or '(alleen kop)'}")
    import json
    return json.loads(vastgelegd)


def voorouders_per_id(ids):
    """ID -> set van zichzelf en alle voorouders (voor 'citeert dit item of iets eronder')."""
    ouder = {b["id"]: b.get("ouder") for b in ids}
    voorouders = {}
    for i in ouder:
        keten, j = set(), i
        while j:
            keten.add(j)
            j = ouder.get(j)
        voorouders[i] = keten
    return voorouders


def controleer_matrix(inventaris):
    ids = [b["id"] for b in inventaris["bepalingen"]]
    matrix = yaml.safe_load((WERKMAP / "dekking.yaml").read_text(encoding="utf-8")) or {}
    for i in ids:
        if i not in matrix:
            fout(f"dekking: {i} heeft geen status")
    for i, v in matrix.items():
        if i not in set(ids):
            fout(f"dekking: {i} staat niet in de inventaris")
            continue
        if not isinstance(v, dict) or v.get("status") not in STATUSSEN:
            fout(f"dekking: {i} heeft geen geldige status ({', '.join(STATUSSEN)})")
            continue
        veld = STATUSSEN[v["status"]]
        if not v.get(veld):
            fout(f"dekking: {i} is {v['status']} maar mist '{veld}'")
        overbodig = set(v) - {"status", veld, "opmerking"}
        if overbodig:
            fout(f"dekking: {i} heeft velden die niet bij '{v['status']}' horen: {', '.join(sorted(overbodig))}")
    return matrix


def elementen_van(regelwerk_pad):
    doc = yaml.safe_load(regelwerk_pad.read_text(encoding="utf-8"))
    for art in doc.get("articles", []):
        ex = (art.get("machine_readable") or {}).get("execution") or {}
        for soort, lijst, sleutel in (("parameter", ex.get("parameters") or [], "name"),
                                      ("actie", ex.get("actions") or [], "output")):
            for el in lijst:
                yield doc, art, soort, f"art{art['number']}/{el[sleutel]}", el.get("legal_basis")


def controleer_regelwerk(inventaris, matrix):
    tekst = {b["id"]: b.get("tekst", "") for b in inventaris["bepalingen"]}
    voorouders = voorouders_per_id(inventaris["bepalingen"])
    citerend = {}
    kopvelden = {}
    for pad in REGELWERK:
        doc = yaml.safe_load(pad.read_text(encoding="utf-8"))
        kopvelden[pad] = set(doc)
        gezien = set()
        for _, art, soort, naam, lb in elementen_van(pad):
            if naam in gezien:
                fout(f"{pad.name}: element {naam} komt twee keer voor")
            gezien.add(naam)
            uitleg = norm((lb or {}).get("explanation", ""))
            m = ANKER.match(uitleg)
            if not m:
                fout(f"{pad.name}: {soort} {naam} noemt geen inventaris-ID in legal_basis.explanation")
                continue
            genoemd = m.group(1).split(", ")
            for i in genoemd:
                if i not in tekst:
                    fout(f"{pad.name}: {naam} verwijst naar {i}, dat niet in de inventaris staat")
                elif matrix.get(i, {}).get("status") != "gemodelleerd":
                    fout(f"{pad.name}: {naam} verwijst naar {i}, dat in dekking.yaml niet 'gemodelleerd' is")
                else:
                    for a in voorouders[i]:
                        citerend.setdefault(a, set()).add(naam)
            citaten = CITAAT.findall(uitleg)
            if not citaten:
                fout(f"{pad.name}: {naam} citeert de brontekst niet («…»)")
            for c in citaten:
                if not any(norm(c) in tekst.get(i, "") for i in genoemd):
                    fout(f"{pad.name}: {naam}: citaat staat niet letterlijk in {', '.join(genoemd)}: «{c[:60]}…»")
        for art in doc.get("articles", []):
            aid = f"art{art['number']}"
            delen = [b["tekst"] for b in inventaris["bepalingen"]
                     if aid in voorouders[b["id"]] and b["id"] != aid]
            if norm(art.get("text", "")) != norm(" ".join(delen)):
                fout(f"{pad.name}: tekst van artikel {art['number']} wijkt af van de brontekst")
    for i, v in matrix.items():
        if not isinstance(v, dict) or v.get("status") != "gemodelleerd":
            continue
        opgegeven = set(v.get("elementen") or [])
        kop = {e for e in opgegeven if e.startswith("kop/")}
        for e in kop:
            if not any(e[4:] in velden for velden in kopvelden.values()):
                fout(f"dekking: {i} noemt {e}, maar het regelwerk heeft dat kopveld niet")
        if opgegeven - kop != citerend.get(i, set()):
            mist = sorted(citerend.get(i, set()) - opgegeven)
            teveel = sorted(opgegeven - kop - citerend.get(i, set()))
            fout(f"dekking: elementen van {i} kloppen niet met het regelwerk"
                 + (f"; ontbreekt: {', '.join(mist)}" if mist else "")
                 + (f"; citeert dit item niet: {', '.join(teveel)}" if teveel else ""))


def controleer_scenarios(inventaris):
    ids = {b["id"] for b in inventaris["bepalingen"]}
    for pad in SCENARIOS:
        tags = []
        for regel in pad.read_text(encoding="utf-8").splitlines():
            s = regel.strip()
            if s.startswith("@"):
                tags += s.split()
            elif s.startswith(("Scenario:", "Scenario Outline:")):
                naam = s.split(":", 1)[1].strip()
                if "@concept" not in tags:
                    fout(f"{pad.name}: scenario '{naam}' mist @concept")
                bepalingen = [t.split(":", 1)[1] for t in tags if t.startswith("@bepaling:")]
                if not bepalingen:
                    fout(f"{pad.name}: scenario '{naam}' noemt geen @bepaling:<id>")
                for i in bepalingen:
                    if i not in ids:
                        fout(f"{pad.name}: scenario '{naam}' noemt onbekende bepaling {i}")
                tags = []
            elif s and not s.startswith("#"):
                tags = []


def controleer_logboek(inventaris):
    ids = {b["id"] for b in inventaris["bepalingen"]}
    pad = WERKMAP / "interpretatielogboek.md"
    for i in re.findall(r"`((?:art\d+|overweging|hoofdstuk|bijlage)[a-z0-9-]*)`", pad.read_text(encoding="utf-8")):
        if i not in ids:
            fout(f"interpretatielogboek.md: {i} staat niet in de inventaris")


def main():
    mod = laad_inventarismodule()
    controleer_bron()
    inventaris = controleer_inventaris(mod)
    matrix = controleer_matrix(inventaris)
    controleer_regelwerk(inventaris, matrix)
    controleer_scenarios(inventaris)
    controleer_logboek(inventaris)
    if fouten:
        for f in fouten:
            print(f"FOUT  {f}")
        print(f"{len(fouten)} fout(en)")
        return 1
    telling = {}
    for v in matrix.values():
        telling[v["status"]] = telling.get(v["status"], 0) + 1
    print(f"OK: {len(inventaris['bepalingen'])} bepalingen; "
          + ", ".join(f"{k} {telling.get(k, 0)}" for k in STATUSSEN))
    return 0


if __name__ == "__main__":
    sys.exit(main())
