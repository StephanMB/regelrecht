#!/usr/bin/env python3
"""Deterministische inventaris van Verordening (EU) 2025/327, Nederlandse tekst.

Leest de Formex-4-ZIP in `bron/` en schrijft `inventaris.json`: elke bepaling
met een stabiele ID, de vindplaats en een sha256 van de tekst. Hetzelfde script
op dezelfde bron geeft byte-identieke uitvoer: geen tijdstempels, vaste
volgorde (die van het document), vaste JSON-opmaak.

Granulariteit: de artikelen in FIJNMAZIG (binnen de scope van de verkenning)
worden uitgesplitst tot lid, alinea, onderdeel en subonderdeel; alle andere
artikelen, de overwegingen, de opschriften en de bijlagen staan er als één
item in.

Tekstnormalisatie, voor tekst en hash gelijk:
- voetnoten (NOTE) en bibliografische metadata (BIB.INSTANCE) vallen weg;
- aanhalingstekens (QUOT.START/QUOT.END) worden het teken uit hun CODE;
- elk blokelement wordt door een spatie gescheiden, inline-elementen niet;
- alle witruimte (ook harde spaties) wordt één spatie, begin en eind getrimd.
`tekst` is de eigen tekst van een item zonder de onderdelen eronder; `sha256`
is de hash van de volledige tekst van het item inclusief alles eronder, zodat
een wijziging in een onderdeel ook bij het lid en het artikel opvalt.

Gebruik:  python3 -I scripts/inventaris.py [--stdout]
"""

import hashlib
import json
import re
import sys
import xml.etree.ElementTree as ET
import zipfile
from pathlib import Path

WERKMAP = Path(__file__).resolve().parent.parent
BRON = WERKMAP / "bron" / "L_202500327NL.fmx4.zip"
UITVOER = WERKMAP / "inventaris.json"

# Artikelen die tot op lid en onderdeel worden uitgesplitst. Keuze per artikel
# staat in interpretatielogboek.md (scope); de rest staat op artikelniveau.
FIJNMAZIG = ("1", "2", "50", "51", "52", "60", "74", "77", "105")

INLINE = {"QUOT.START", "QUOT.END", "DATE", "REF.DOC.OJ", "REF.DOC", "HT", "FT"}
WEGLATEN = {"NOTE", "BIB.INSTANCE"}


def _stukken(e, uit, weglaten):
    if e.tag in weglaten:
        return
    if e.tag in ("QUOT.START", "QUOT.END"):
        uit.append(chr(int(e.get("CODE"), 16)))
        return
    blok = e.tag not in INLINE
    if blok:
        uit.append(" ")
    if e.text:
        uit.append(e.text)
    for kind in e:
        _stukken(kind, uit, weglaten)
        if kind.tail:
            uit.append(kind.tail)
    if blok:
        uit.append(" ")


def norm(s):
    return " ".join(s.split())


def tekst(e):
    """Volledige tekst van e, inclusief lijsten."""
    uit = []
    _stukken(e, uit, WEGLATEN)
    return norm("".join(uit))


def eigen_tekst(e):
    """Tekst van e zonder de lijsten (onderdelen) eronder."""
    uit = []
    _stukken(e, uit, WEGLATEN | {"LIST"})
    return norm("".join(uit))


def sha(s):
    return hashlib.sha256(s.encode("utf-8")).hexdigest()


def lijsten(e):
    """LIST-elementen direct onder e, zonder af te dalen in een ITEM of LIST."""
    for kind in e:
        if kind.tag == "LIST":
            yield kind
        elif kind.tag not in ("ITEM",) and kind.tag not in WEGLATEN:
            yield from lijsten(kind)


def nummer_onderdeel(item, volgnr):
    no = item.find("NP/NO.P")
    if no is None:
        return f"punt{volgnr}"
    m = re.fullmatch(r"\(?([a-z]+|[0-9]+)\)", norm("".join(no.itertext())))
    if not m:
        raise ValueError(f"onverwacht onderdeelnummer: {''.join(no.itertext())!r}")
    return m.group(1)


class Inventaris:
    def __init__(self):
        self.items = []
        self.ids = set()
        self.vindplaats_opschrift = {}

    def voeg_toe(self, **item):
        if item["id"] in self.ids:
            raise ValueError(f"dubbele ID {item['id']}")
        self.ids.add(item["id"])
        self.items.append({k: v for k, v in item.items() if v is not None})

    def onderdelen(self, container, ouder_id, ouder_vindplaats, in_onderdeel):
        for lijst in lijsten(container):
            for volgnr, item in enumerate(lijst.findall("ITEM"), 1):
                nr = nummer_onderdeel(item, volgnr)
                iid = f"{ouder_id}-{nr}" if in_onderdeel else f"{ouder_id}-onderdeel-{nr}"
                no = item.find("NP/NO.P")
                label = norm("".join(no.itertext())) if no is not None else f"punt {volgnr}"
                vp = f"{ouder_vindplaats}, {'subonderdeel' if in_onderdeel else 'punt'} {label}"
                self.voeg_toe(id=iid, soort="subonderdeel" if in_onderdeel else "onderdeel",
                              vindplaats=vp, ouder=ouder_id, tekst=eigen_tekst(item),
                              sha256=sha(tekst(item)))
                self.onderdelen(item, iid, vp, True)

    def artikel(self, art, plaats):
        ti = norm("".join(art.find("TI.ART").itertext()))
        m = re.fullmatch(r"Artikel (\d+)", ti)
        if not m or int(art.get("IDENTIFIER")) != int(m.group(1)):
            raise ValueError(f"artikelnummer klopt niet: {ti!r} / {art.get('IDENTIFIER')}")
        nr = m.group(1)
        aid = f"art{nr}"
        fijn = nr in FIJNMAZIG
        self.voeg_toe(id=aid, soort="artikel", vindplaats=f"Artikel {nr}", plaats=plaats,
                      opschrift=tekst(art.find("STI.ART")), fijnmazig=fijn, sha256=sha(tekst(art)))
        if not fijn:
            return
        leden = art.findall("PARAG")
        if leden:
            for lid in leden:
                no = norm("".join(lid.find("NO.PARAG").itertext()))
                k = re.fullmatch(r"(\d+)\.", no).group(1)
                lid_id, lid_vp = f"{aid}-lid{k}", f"Artikel {nr}, lid {k}"
                alineas = lid.findall("ALINEA")
                if len(alineas) == 1:
                    self.voeg_toe(id=lid_id, soort="lid", vindplaats=lid_vp, ouder=aid,
                                  tekst=eigen_tekst(lid), sha256=sha(tekst(lid)))
                    self.onderdelen(lid, lid_id, lid_vp, False)
                else:
                    self.voeg_toe(id=lid_id, soort="lid", vindplaats=lid_vp, ouder=aid,
                                  tekst=no, sha256=sha(tekst(lid)))
                    for j, al in enumerate(alineas, 1):
                        al_id, al_vp = f"{lid_id}-alinea{j}", f"{lid_vp}, alinea {j}"
                        self.voeg_toe(id=al_id, soort="alinea", vindplaats=al_vp, ouder=lid_id,
                                      tekst=eigen_tekst(al), sha256=sha(tekst(al)))
                        self.onderdelen(al, al_id, al_vp, False)
        else:
            for j, al in enumerate(art.findall("ALINEA"), 1):
                al_id, al_vp = f"{aid}-alinea{j}", f"Artikel {nr}, alinea {j}"
                self.voeg_toe(id=al_id, soort="alinea", vindplaats=al_vp, ouder=aid,
                              tekst=eigen_tekst(al), sha256=sha(tekst(al)))
                self.onderdelen(al, al_id, al_vp, False)

    def indeling(self, e, plaats):
        for kind in e:
            if kind.tag == "DIVISION":
                ti = norm("".join(kind.find("TITLE/TI").itertext()))
                m = re.fullmatch(r"(HOOFDSTUK|AFDELING) ([IVX]+|\d+)", ti)
                if not m:
                    raise ValueError(f"onverwacht opschrift: {ti!r}")
                deel = f"{m.group(1).lower()}-{m.group(2).lower()}"
                did = f"{plaats}-{deel}" if plaats else deel
                vp = f"{m.group(1).capitalize()} {m.group(2)}"
                vp = f"{self.vindplaats_opschrift[plaats]}, {vp.lower()}" if plaats else vp
                self.vindplaats_opschrift[did] = vp
                self.voeg_toe(id=did, soort="opschrift", vindplaats=f"{vp} (opschrift)",
                              tekst=tekst(kind.find("TITLE")), sha256=sha(tekst(kind.find("TITLE"))))
                self.indeling(kind, did)
            elif kind.tag == "ARTICLE":
                self.artikel(kind, plaats)


def bouw(bron=BRON):
    with zipfile.ZipFile(bron) as z:
        namen = sorted(z.namelist())
        hoofd = next(n for n in namen if n.endswith(".000101.fmx.xml"))
        act = ET.fromstring(z.read(hoofd))
        bijlagen = [(n, ET.fromstring(z.read(n))) for n in namen
                    if re.search(r"\.0(09[0-9]|1[0-9]{2})01\.fmx\.xml$", n)]
        leden_sha = {n: hashlib.sha256(z.read(n)).hexdigest() for n in namen}
    inv = Inventaris()
    inv.voeg_toe(id="titel", soort="titel", vindplaats="Titel",
                 tekst=tekst(act.find("TITLE")), sha256=sha(tekst(act.find("TITLE"))))
    pre = act.find("PREAMBLE")
    aanhef = [pre.find("PREAMBLE.INIT"), pre.find("GR.VISA"), pre.find("GR.CONSID/GR.CONSID.INIT")]
    aanhef_tekst = norm(" ".join(tekst(e) for e in aanhef))
    inv.voeg_toe(id="aanhef", soort="aanhef", vindplaats="Aanhef en visa",
                 tekst=aanhef_tekst, sha256=sha(aanhef_tekst))
    for c in pre.findall("GR.CONSID/CONSID"):
        n = re.fullmatch(r"\((\d+)\)", norm("".join(c.find("NP/NO.P").itertext()))).group(1)
        inv.voeg_toe(id=f"overweging-{n}", soort="overweging", vindplaats=f"Overweging ({n})",
                     sha256=sha(tekst(c)))
    slot_pre = tekst(pre.find("PREAMBLE.FINAL"))
    inv.voeg_toe(id="vaststellingsformule", soort="slotformule", vindplaats="Vaststellingsformule",
                 tekst=slot_pre, sha256=sha(slot_pre))
    inv.indeling(act.find("ENACTING.TERMS"), "")
    inv.voeg_toe(id="slot", soort="slot", vindplaats="Slotformule en ondertekening",
                 sha256=sha(tekst(act.find("FINAL"))))
    for naam, annex in bijlagen:
        ti = norm("".join(annex.find("TITLE/TI").itertext()))
        m = re.fullmatch(r"BIJLAGE ([IVX]+)", ti)
        inv.voeg_toe(id=f"bijlage-{m.group(1).lower()}", soort="bijlage", vindplaats=f"Bijlage {m.group(1)}",
                     opschrift=tekst(annex.find("TITLE")), sha256=sha(tekst(annex)))
    return {
        "bron": {
            "bestand": f"bron/{BRON.name}",
            "sha256": hashlib.sha256(Path(bron).read_bytes()).hexdigest(),
            "zip_leden": leden_sha,
            "celex": "32025R0327",
            "taal": "NL",
        },
        "fijnmazig": list(FIJNMAZIG),
        "bepalingen": inv.items,
    }


def serialiseer(inventaris):
    return json.dumps(inventaris, ensure_ascii=False, indent=1) + "\n"


def main(argv):
    uit = serialiseer(bouw())
    if "--stdout" in argv:
        sys.stdout.write(uit)
    else:
        UITVOER.write_text(uit, encoding="utf-8")
        print(f"{UITVOER.relative_to(WERKMAP)}: {len(json.loads(uit)['bepalingen'])} bepalingen")


if __name__ == "__main__":
    main(sys.argv[1:])
