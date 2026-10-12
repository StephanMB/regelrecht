# Interpretatielogboek

Elke plek waar de tekst ruimte laat en het concept een modelleerkeuze maakt. Per keuze: bepaling,
keuze, redelijk alternatief, reden. ID's verwijzen naar `inventaris.json`. Niets hier is een
vastgestelde uitleg; het is een lijst voor de jurist.

## Keuzes

**K1. Reikwijdte van “die: i) … ofwel ii)”** — `art2-lid2-onderdeel-t`
- Keuze: geen. De leesvraag is een parameter (`lezing_punt_t_voorwaarden_gelden_voor_alle_partijen`);
  zonder antwoord is de uitkomst onbekend als de lezingen verschillen (zie N1).
- Alternatief: één lezing vastleggen.
- Reden: NL en EN lezen verschillend; de keuze bepaalt of een partij uit de opsomming zonder i) of ii)
  houder is (o.a. de verwerker, K5).

**K2. “indien noodzakelijk” bij vergoedingsdiensten** — `art2-lid2-onderdeel-t`
- Keuze: open norm, in de vraag zelf (`is_vergoedingsdienst_waar_noodzakelijk`).
- Alternatief: elke vergoedingsdienst is houder.
- Reden: de tekst zegt niet wanneer het noodzakelijk is, of voor wie.

**K3. Opsomming van partijen apart bevraagd** — `art2-lid2-onderdeel-t`
- Keuze: zes vragen voor de partijen buiten de Unie, één voor Unie-instellingen.
- Alternatief: één vraag “valt de partij onder de opsomming”.
- Reden: elk lemma blijft herleidbaar; “in de gezondheidszorg- of de zorgsector” blijft een oordeel.

**K4. Onderdeel i) gaat over de partij, niet over de databron** — `art2-lid2-onderdeel-t-i`
- Keuze: drie vragen (recht of plicht, hoedanigheid van verwerkingsverantwoordelijke, doel) over de
  verwerking van persoonlijke elektronische gezondheidsgegevens door de partij in het algemeen.
- Alternatief: de voorwaarden toetsen voor de verwerking in deze databron.
- Reden: onderdeel t) definieert een partij; de databron komt pas in art. 51 terug.

**K5. Verwerker in opdracht van een ander** — `art2-lid2-onderdeel-t-i`, `art74-lid1-alinea1`
- Keuze: een verwerker antwoordt nee op de vraag naar de hoedanigheid van verwerkingsverantwoordelijke.
  Onder de lezing “voorwaarden gelden voor alle partijen” is hij dan geen houder (tenzij ii); onder de
  andere lezing wel, als hij in de opsomming valt.
- Alternatief: art. 74, lid 1, eerste alinea, lezen als “wie beschikbaar stelt, is
  verwerkingsverantwoordelijke” en de verwerker daarom als houder aanmerken.
- Reden: art. 74 regelt de rol bij de beschikbaarstelling, niet wie houder is; staat als `open` in de matrix.

**K6. Circulaire definitie van niet-persoonsgebonden gegevens** — `art2-lid2-onderdeel-b`, `art2-lid2-onderdeel-c`
- Keuze: één vraag of de bron niet-persoonsgebonden elektronische gezondheidsgegevens bevat.
- Alternatief: afleiden uit een eigen criterium voor “gezondheidsgegevens” zonder betrokkene.
- Reden: b) definieert met de term die c) met b) definieert; welke niet-persoonsgebonden gegevens
  “gezondheidsgegevens” zijn, zegt de tekst niet. Dat oordeel ligt bij wie de vraag beantwoordt.

**K7. Een categorie vereist elektronische gezondheidsgegevens** — `art51-lid1`
- Keuze: categorie X geldt alleen als de bron elektronische gezondheidsgegevens bevat én in X valt.
- Alternatief: indeling in een categorie volstaat (b, c en j kunnen gegevens bevatten die niet “over
  gezondheid” gaan, zoals beroepsstatus van gezondheidswerkers).
- Reden: de aanhef spreekt van “categorieën elektronische gezondheidsgegevens”.

**K8. Databron en categorieën** — `art51-lid1`
- Keuze: een databron is wat één houder houdt; elke categorievraag luidt “valt (een deel van) de
  databron onder …”. Overlap (a en h, h en n, k en l) is toegestaan; er is geen voorrang.
- Alternatief: per deel van de bron één categorie, of categorieën als elkaar uitsluitend.
- Reden: “databron” is geen term van de verordening, en de tekst kent geen voorrang tussen categorieën.

**K9. Tijdsvoorwaarde in punt p)** — `art51-lid1-onderdeel-p`
- Keuze: “zodra de daarmee verband houdende resultaten gepubliceerd zijn” zit in de categorievraag.
- Alternatief: een aparte datumparameter en een vergelijking met de peildatum.
- Reden: de publicatiedatum is per cohort een feit; zie ook N3.

**K10. Art. 1, lid 9, sluit de hele bron uit** — `art1-lid9`
- Keuze: als lid 9 van toepassing is, heeft de houder voor deze bron geen plichten.
- Alternatief: alleen het persoonsgebonden deel valt erbuiten; niet-persoonsgebonden gegevens niet.
- Reden: eenvoud; lid 9 spreekt alleen over “verwerking van persoonsgegevens”. Te bevestigen.

**K11. “Doet geen afbreuk” beperkt hoofdstuk IV niet** — `art1-lid3` t/m `art1-lid8`
- Keuze: buiten scope; geen uitzondering in de toets.
- Alternatief: lid 7 of lid 8 lezen als uitzondering voor gegevens die al via een ander regime
  toegankelijk zijn.
- Reden: de formule laat ander recht intact; ze stelt niemand vrij.

**K12. Bemiddelingsentiteit verandert wie, niet of** — `art50-lid3`
- Keuze: aparte uitkomst `plichten_vervuld_door_bemiddelingsentiteit`; de plicht van de houder blijft.
- Alternatief: de houder heeft dan geen eigen plicht meer.
- Reden: “worden de gegevens niettemin beschouwd als beschikbaar gesteld door meerdere houders”.

**K13. Beschrijvingsplicht los van de categorieën** — `art60-lid3`, `art2-lid2-onderdeel-w`
- Keuze: geldt voor elke dataset met elektronische gezondheidsgegevens van een houder met plichten.
- Alternatief: alleen voor datasets met gegevens uit de categorieën van art. 51.
- Reden: lid 3 verwijst, anders dan lid 1, niet naar art. 51.

**K14. Open databanken voor niet-persoonsgebonden gegevens** — `art60-lid5`
- Keuze: aparte plicht voor elke houder met plichten die niet-persoonsgebonden gegevens houdt.
- Alternatief: alleen voor gegevens in een categorie van art. 51, of een vorm van de plicht uit lid 1.
- Reden: lid 5 noemt art. 51 niet.

**K15. Toepassingsdata** — `art105-alinea5`, `art105-alinea2`
- Keuze: hoofdstuk IV vanaf 26 maart 2029; art. 51, lid 1, punten b), f), g), m) en p) vanaf
  26 maart 2031. De algemene datum (26 maart 2027) speelt geen rol.
- Alternatief: de algemene datum voor de beschrijvingsplicht laten gelden.
- Reden: alinea 5 bepaalt de datum voor het hele hoofdstuk; art. 60 staat daarin.

**K16. Datum voor een nationale categorie** — `art51-lid2`, `art105-alinea5`
- Keuze: invoer (`toepassingsdatum_aanvullende_nationale_categorie`); onbeantwoord blijft de datum onbekend.
- Alternatief: 26 maart 2029 aannemen.
- Reden: art. 105 noemt geen datum voor lid 2; het nationale recht kan er een kiezen.

**K17. Inwerkingtreding als `valid_from`** — `art105-alinea1`
- Keuze: 25 maart 2025, berekend: bekendmaking in PB L op 5 maart 2025 (Formex `PUBLICATION.REF`),
  twintigste dag daarna, de dag na bekendmaking als dag één.
- Alternatief: geen; wel een rekenkeuze die de jurist kan nalopen.
- Reden: het formaat vraagt een datum; de toets gebruikt alleen de toepassingsdata.

**K18. Bescherming door IE-rechten en bedrijfsgeheimen** — `art52-lid1`
- Keuze: buiten scope; zulke gegevens worden volgens lid 1 gewoon beschikbaar gesteld.
- Alternatief: een vraag opnemen, als signaal voor de procedure van lid 2.
- Reden: het verandert de uitkomst van de toets niet.

**K19. Opt-out van natuurlijke personen** — `art71`
- Keuze: buiten scope.
- Alternatief: als beperking van de reikwijdte opnemen.
- Reden: het bepaalt welke gegevens van een persoon niet beschikbaar komen, niet of de bron onder de plicht valt.

## NL/EN-vergelijking

Kernbegrippen vergeleken: art. 1, lid 9; art. 2, lid 2, punten a)–c), e), j), t), w), ab); art. 50;
art. 51; art. 60, leden 1, 3 en 5; art. 105. Beide taalversies zijn authentiek. Elk betekenisverschil
is een open punt.

**N1** — `art2-lid2-onderdeel-t`. NL: “… alsook instellingen, organen of instanties van de Unie
die: i) … ofwel ii) …”. EN: “… as well as any Union institution, body, office or agency, that has
either: (i) … or (ii) …”. In NL hangt “die” direct aan de Unie-instellingen; de komma in EN laat
lezen dat i) en ii) voor alle genoemde partijen gelden. Zie K1.

**N2** — `art51-lid1-onderdeel-e`. NL “verstrekkingen”, EN “dispensations” (afleveren van
geneesmiddelen). “Verstrekking” is in het Nederlandse zorgrecht ruimer. Valt alleen aflevering eronder?

**N3** — `art51-lid1-onderdeel-p`. NL “zodra de daarmee verband houdende resultaten gepubliceerd
zijn”, EN “after the first publication of the related results”. Volstaat de eerste publicatie, of
moeten (alle) resultaten gepubliceerd zijn?

**N4** — `art2-lid2-onderdeel-t-ii`. NL “registreren, verstrekken, beperken of uitwisselen van die
gegevens”, EN “registering, providing, restricting access to or exchanging such data”. NL “beperken
van gegevens” is ruimer dan het beperken van de toegang.

**N5** — `art50-lid3`. EN wisselt van “obligations” (lid 1, 2) naar “duties” (lid 3); NL houdt
“verplichtingen”. Waarschijnlijk geen betekenisverschil; genoteerd voor volledigheid.

Geen verschil gevonden in de overige vergeleken bepalingen.
