# status: concept — te valideren door jurist
#
# Deze scenario's zijn geschreven door dezelfde partij als het regelwerk en zijn dus niet
# onafhankelijk. Ze laten zien hoe het regelwerk antwoorden combineert; of de verwachte uitkomst
# juridisch klopt, moet een jurist vaststellen. Elk scenario noemt met @bepaling:<id> de bepalingen
# die de uitkomst dragen (ID's uit inventaris.json). Een vraag die niet in de tabel staat, is
# onbeantwoord.
Feature: Beschikbaarstelling voor secundair gebruik (Verordening (EU) 2025/327) — concept

  # status: concept — te valideren door jurist
  # Randgeval: een bron in meerdere categorieën, waarvan één met de latere toepassingsdatum. De vroegste datum telt.
  @concept @bepaling:art2-lid2-onderdeel-t @bepaling:art2-lid2-onderdeel-t-i @bepaling:art51-lid1-onderdeel-a @bepaling:art51-lid1-onderdeel-f @bepaling:art105-alinea5
  Scenario: Ziekenhuis met EPD-gegevens en genetische laboratoriumuitslagen valt in meerdere categorieën
    Given the calculation date is "2030-01-01"
    Given law "verordening_europese_ruimte_voor_gezondheidsgegevens" is loaded
    Given the following parameters:
      | verwerking_buiten_werkingssfeer_unierecht                          | false |
      | verwerking_door_bevoegde_autoriteit_strafrecht                     | false |
      | in_gezondheidszorg_of_zorgsector                                   | true  |
      | is_vergoedingsdienst_waar_noodzakelijk                             | false |
      | ontwikkelt_producten_of_diensten_voor_gezondheidssector            | false |
      | ontwikkelt_of_vervaardigt_wellnessapps                             | false |
      | verricht_onderzoek_gezondheidszorg_of_zorgsector                   | false |
      | treedt_op_als_sterfteregister                                      | false |
      | is_instelling_orgaan_of_instantie_van_de_unie                      | false |
      | heeft_recht_of_plicht_tot_verwerking                               | true  |
      | verwerkt_als_verwerkingsverantwoordelijke                          | true  |
      | verwerkt_voor_doel_uit_punt_t_i                                    | true  |
      | kan_niet_persoonsgebonden_gegevens_beschikbaar_stellen_via_ontwerp | false |
      | lezing_punt_t_voorwaarden_gelden_voor_alle_partijen                | true  |
      | houder_is_natuurlijke_persoon                                      | false |
      | houder_is_micro_onderneming                                        | false |
      | nationaal_recht_past_plichten_toe_op_vrijgestelde_houder           | false |
      | nationaal_recht_wijst_bemiddelingsentiteit_aan                     | false |
      | bevat_gegevens_over_gezondheid_of_genetische_gegevens              | true  |
      | gegevens_in_elektronische_vorm_verwerkt                            | true  |
      | bevat_niet_persoonsgebonden_elektronische_gezondheidsgegevens      | false |
      | databron_is_gestructureerde_verzameling                            | true  |
      | valt_in_categorie_a                                                | true  |
      | valt_in_categorie_b                                                | false |
      | valt_in_categorie_c                                                | false |
      | valt_in_categorie_d                                                | false |
      | valt_in_categorie_e                                                | false |
      | valt_in_categorie_f                                                | true  |
      | valt_in_categorie_g                                                | false |
      | valt_in_categorie_h                                                | false |
      | valt_in_categorie_i                                                | false |
      | valt_in_categorie_j                                                | false |
      | valt_in_categorie_k                                                | false |
      | valt_in_categorie_l                                                | false |
      | valt_in_categorie_m                                                | false |
      | valt_in_categorie_n                                                | false |
      | valt_in_categorie_o                                                | false |
      | valt_in_categorie_p                                                | false |
      | valt_in_categorie_q                                                | false |
      | valt_in_aanvullende_nationale_categorie                            | false |
    When I evaluate "is_houder_van_gezondheidsgegevens" of "verordening_europese_ruimte_voor_gezondheidsgegevens"
    Then the execution succeeds
    Then output "is_houder_van_gezondheidsgegevens" is true
    When I evaluate "categorie_a" of "verordening_europese_ruimte_voor_gezondheidsgegevens"
    Then the execution succeeds
    Then output "categorie_a" is true
    When I evaluate "categorie_f" of "verordening_europese_ruimte_voor_gezondheidsgegevens"
    Then the execution succeeds
    Then output "categorie_f" is true
    When I evaluate "plicht_in_categorie_zonder_uitstel" of "verordening_europese_ruimte_voor_gezondheidsgegevens"
    Then the execution succeeds
    Then output "plicht_in_categorie_zonder_uitstel" is true
    When I evaluate "plicht_in_categorie_met_uitstel" of "verordening_europese_ruimte_voor_gezondheidsgegevens"
    Then the execution succeeds
    Then output "plicht_in_categorie_met_uitstel" is true
    When I evaluate "eerste_toepassingsdatum_beschikbaarstellingsplicht" of "verordening_europese_ruimte_voor_gezondheidsgegevens"
    Then the execution succeeds
    Then output "eerste_toepassingsdatum_beschikbaarstellingsplicht" equals "2029-03-26"
    When I evaluate "beschikbaarstellingsplicht_geldt_op_peildatum" of "verordening_europese_ruimte_voor_gezondheidsgegevens"
    Then the execution succeeds
    Then output "beschikbaarstellingsplicht_geldt_op_peildatum" is true

  # status: concept — te valideren door jurist
  # Randgeval: categorie f) valt onder de uitgestelde toepassing van art. 105, vijfde alinea.
  @concept @bepaling:art51-lid1-onderdeel-f @bepaling:art105-alinea5
  Scenario: Onderzoeksinstelling met alleen genomische gegevens: categorie met latere toepassingsdatum, vóór die datum
    Given the calculation date is "2030-06-01"
    Given law "verordening_europese_ruimte_voor_gezondheidsgegevens" is loaded
    Given the following parameters:
      | verwerking_buiten_werkingssfeer_unierecht                          | false |
      | verwerking_door_bevoegde_autoriteit_strafrecht                     | false |
      | in_gezondheidszorg_of_zorgsector                                   | false |
      | is_vergoedingsdienst_waar_noodzakelijk                             | false |
      | ontwikkelt_producten_of_diensten_voor_gezondheidssector            | false |
      | ontwikkelt_of_vervaardigt_wellnessapps                             | false |
      | verricht_onderzoek_gezondheidszorg_of_zorgsector                   | true  |
      | treedt_op_als_sterfteregister                                      | false |
      | is_instelling_orgaan_of_instantie_van_de_unie                      | false |
      | heeft_recht_of_plicht_tot_verwerking                               | true  |
      | verwerkt_als_verwerkingsverantwoordelijke                          | true  |
      | verwerkt_voor_doel_uit_punt_t_i                                    | true  |
      | kan_niet_persoonsgebonden_gegevens_beschikbaar_stellen_via_ontwerp | false |
      | lezing_punt_t_voorwaarden_gelden_voor_alle_partijen                | true  |
      | houder_is_natuurlijke_persoon                                      | false |
      | houder_is_micro_onderneming                                        | false |
      | nationaal_recht_past_plichten_toe_op_vrijgestelde_houder           | false |
      | nationaal_recht_wijst_bemiddelingsentiteit_aan                     | false |
      | bevat_gegevens_over_gezondheid_of_genetische_gegevens              | true  |
      | gegevens_in_elektronische_vorm_verwerkt                            | true  |
      | bevat_niet_persoonsgebonden_elektronische_gezondheidsgegevens      | false |
      | databron_is_gestructureerde_verzameling                            | true  |
      | valt_in_categorie_a                                                | false |
      | valt_in_categorie_b                                                | false |
      | valt_in_categorie_c                                                | false |
      | valt_in_categorie_d                                                | false |
      | valt_in_categorie_e                                                | false |
      | valt_in_categorie_f                                                | true  |
      | valt_in_categorie_g                                                | false |
      | valt_in_categorie_h                                                | false |
      | valt_in_categorie_i                                                | false |
      | valt_in_categorie_j                                                | false |
      | valt_in_categorie_k                                                | false |
      | valt_in_categorie_l                                                | false |
      | valt_in_categorie_m                                                | false |
      | valt_in_categorie_n                                                | false |
      | valt_in_categorie_o                                                | false |
      | valt_in_categorie_p                                                | false |
      | valt_in_categorie_q                                                | false |
      | valt_in_aanvullende_nationale_categorie                            | false |
    When I evaluate "categorie_f" of "verordening_europese_ruimte_voor_gezondheidsgegevens"
    Then the execution succeeds
    Then output "categorie_f" is true
    When I evaluate "valt_onder_beschikbaarstellingsplicht" of "verordening_europese_ruimte_voor_gezondheidsgegevens"
    Then the execution succeeds
    Then output "valt_onder_beschikbaarstellingsplicht" is true
    When I evaluate "plicht_in_categorie_zonder_uitstel" of "verordening_europese_ruimte_voor_gezondheidsgegevens"
    Then the execution succeeds
    Then output "plicht_in_categorie_zonder_uitstel" is false
    When I evaluate "plicht_in_categorie_met_uitstel" of "verordening_europese_ruimte_voor_gezondheidsgegevens"
    Then the execution succeeds
    Then output "plicht_in_categorie_met_uitstel" is true
    When I evaluate "eerste_toepassingsdatum_beschikbaarstellingsplicht" of "verordening_europese_ruimte_voor_gezondheidsgegevens"
    Then the execution succeeds
    Then output "eerste_toepassingsdatum_beschikbaarstellingsplicht" equals "2031-03-26"
    When I evaluate "beschikbaarstellingsplicht_geldt_op_peildatum" of "verordening_europese_ruimte_voor_gezondheidsgegevens"
    Then the execution succeeds
    Then output "beschikbaarstellingsplicht_geldt_op_peildatum" is false
    When I evaluate "beschrijvingsplicht_geldt_op_peildatum" of "verordening_europese_ruimte_voor_gezondheidsgegevens"
    Then the execution succeeds
    Then output "beschrijvingsplicht_geldt_op_peildatum" is true

  # status: concept — te valideren door jurist
  # Zelfde feiten; op 26 maart 2031 geldt de plicht wel.
  @concept @bepaling:art51-lid1-onderdeel-f @bepaling:art105-alinea5
  Scenario: Onderzoeksinstelling met alleen genomische gegevens: categorie met latere toepassingsdatum, op die datum
    Given the calculation date is "2031-03-26"
    Given law "verordening_europese_ruimte_voor_gezondheidsgegevens" is loaded
    Given the following parameters:
      | verwerking_buiten_werkingssfeer_unierecht                          | false |
      | verwerking_door_bevoegde_autoriteit_strafrecht                     | false |
      | in_gezondheidszorg_of_zorgsector                                   | false |
      | is_vergoedingsdienst_waar_noodzakelijk                             | false |
      | ontwikkelt_producten_of_diensten_voor_gezondheidssector            | false |
      | ontwikkelt_of_vervaardigt_wellnessapps                             | false |
      | verricht_onderzoek_gezondheidszorg_of_zorgsector                   | true  |
      | treedt_op_als_sterfteregister                                      | false |
      | is_instelling_orgaan_of_instantie_van_de_unie                      | false |
      | heeft_recht_of_plicht_tot_verwerking                               | true  |
      | verwerkt_als_verwerkingsverantwoordelijke                          | true  |
      | verwerkt_voor_doel_uit_punt_t_i                                    | true  |
      | kan_niet_persoonsgebonden_gegevens_beschikbaar_stellen_via_ontwerp | false |
      | lezing_punt_t_voorwaarden_gelden_voor_alle_partijen                | true  |
      | houder_is_natuurlijke_persoon                                      | false |
      | houder_is_micro_onderneming                                        | false |
      | nationaal_recht_past_plichten_toe_op_vrijgestelde_houder           | false |
      | nationaal_recht_wijst_bemiddelingsentiteit_aan                     | false |
      | bevat_gegevens_over_gezondheid_of_genetische_gegevens              | true  |
      | gegevens_in_elektronische_vorm_verwerkt                            | true  |
      | bevat_niet_persoonsgebonden_elektronische_gezondheidsgegevens      | false |
      | databron_is_gestructureerde_verzameling                            | true  |
      | valt_in_categorie_a                                                | false |
      | valt_in_categorie_b                                                | false |
      | valt_in_categorie_c                                                | false |
      | valt_in_categorie_d                                                | false |
      | valt_in_categorie_e                                                | false |
      | valt_in_categorie_f                                                | true  |
      | valt_in_categorie_g                                                | false |
      | valt_in_categorie_h                                                | false |
      | valt_in_categorie_i                                                | false |
      | valt_in_categorie_j                                                | false |
      | valt_in_categorie_k                                                | false |
      | valt_in_categorie_l                                                | false |
      | valt_in_categorie_m                                                | false |
      | valt_in_categorie_n                                                | false |
      | valt_in_categorie_o                                                | false |
      | valt_in_categorie_p                                                | false |
      | valt_in_categorie_q                                                | false |
      | valt_in_aanvullende_nationale_categorie                            | false |
    When I evaluate "eerste_toepassingsdatum_beschikbaarstellingsplicht" of "verordening_europese_ruimte_voor_gezondheidsgegevens"
    Then the execution succeeds
    Then output "eerste_toepassingsdatum_beschikbaarstellingsplicht" equals "2031-03-26"
    When I evaluate "beschikbaarstellingsplicht_geldt_op_peildatum" of "verordening_europese_ruimte_voor_gezondheidsgegevens"
    Then the execution succeeds
    Then output "beschikbaarstellingsplicht_geldt_op_peildatum" is true

  # status: concept — te valideren door jurist
  # Randgeval: een verwerker. Onder deze lezing is de partij geen houder, omdat zij niet als verwerkingsverantwoordelijke verwerkt.
  @concept @bepaling:art2-lid2-onderdeel-t @bepaling:art2-lid2-onderdeel-t-i @bepaling:art74-lid1-alinea1
  Scenario: Partij die EPD-gegevens alleen in opdracht van een ziekenhuis verwerkt, lezing: voorwaarden i) en ii) gelden voor alle partijen
    Given the calculation date is "2030-01-01"
    Given law "verordening_europese_ruimte_voor_gezondheidsgegevens" is loaded
    Given the following parameters:
      | verwerking_buiten_werkingssfeer_unierecht                          | false |
      | verwerking_door_bevoegde_autoriteit_strafrecht                     | false |
      | in_gezondheidszorg_of_zorgsector                                   | false |
      | is_vergoedingsdienst_waar_noodzakelijk                             | false |
      | ontwikkelt_producten_of_diensten_voor_gezondheidssector            | true  |
      | ontwikkelt_of_vervaardigt_wellnessapps                             | false |
      | verricht_onderzoek_gezondheidszorg_of_zorgsector                   | false |
      | treedt_op_als_sterfteregister                                      | false |
      | is_instelling_orgaan_of_instantie_van_de_unie                      | false |
      | heeft_recht_of_plicht_tot_verwerking                               | false |
      | verwerkt_als_verwerkingsverantwoordelijke                          | false |
      | verwerkt_voor_doel_uit_punt_t_i                                    | true  |
      | kan_niet_persoonsgebonden_gegevens_beschikbaar_stellen_via_ontwerp | false |
      | lezing_punt_t_voorwaarden_gelden_voor_alle_partijen                | true  |
      | houder_is_natuurlijke_persoon                                      | false |
      | houder_is_micro_onderneming                                        | false |
      | nationaal_recht_past_plichten_toe_op_vrijgestelde_houder           | false |
      | nationaal_recht_wijst_bemiddelingsentiteit_aan                     | false |
      | bevat_gegevens_over_gezondheid_of_genetische_gegevens              | true  |
      | gegevens_in_elektronische_vorm_verwerkt                            | true  |
      | bevat_niet_persoonsgebonden_elektronische_gezondheidsgegevens      | false |
      | databron_is_gestructureerde_verzameling                            | true  |
      | valt_in_categorie_a                                                | true  |
      | valt_in_categorie_b                                                | false |
      | valt_in_categorie_c                                                | false |
      | valt_in_categorie_d                                                | false |
      | valt_in_categorie_e                                                | false |
      | valt_in_categorie_f                                                | false |
      | valt_in_categorie_g                                                | false |
      | valt_in_categorie_h                                                | false |
      | valt_in_categorie_i                                                | false |
      | valt_in_categorie_j                                                | false |
      | valt_in_categorie_k                                                | false |
      | valt_in_categorie_l                                                | false |
      | valt_in_categorie_m                                                | false |
      | valt_in_categorie_n                                                | false |
      | valt_in_categorie_o                                                | false |
      | valt_in_categorie_p                                                | false |
      | valt_in_categorie_q                                                | false |
      | valt_in_aanvullende_nationale_categorie                            | false |
    When I evaluate "is_houder_van_gezondheidsgegevens" of "verordening_europese_ruimte_voor_gezondheidsgegevens"
    Then the execution succeeds
    Then output "is_houder_van_gezondheidsgegevens" is false
    When I evaluate "categorie_a" of "verordening_europese_ruimte_voor_gezondheidsgegevens"
    Then the execution succeeds
    Then output "categorie_a" is false
    When I evaluate "valt_onder_beschikbaarstellingsplicht" of "verordening_europese_ruimte_voor_gezondheidsgegevens"
    Then the execution succeeds
    Then output "valt_onder_beschikbaarstellingsplicht" is false
    When I evaluate "eerste_toepassingsdatum_beschikbaarstellingsplicht" of "verordening_europese_ruimte_voor_gezondheidsgegevens"
    Then the execution succeeds
    Then output "eerste_toepassingsdatum_beschikbaarstellingsplicht" is absent

  # status: concept — te valideren door jurist
  # Zelfde feiten, andere lezing van art. 2, lid 2, punt t): de partij is dan houder omdat zij producten of diensten voor de gezondheidszorgsector ontwikkelt.
  @concept @bepaling:art2-lid2-onderdeel-t @bepaling:art51-lid1-onderdeel-a
  Scenario: Partij die EPD-gegevens alleen in opdracht van een ziekenhuis verwerkt, lezing: voorwaarden gelden alleen voor Unie-instellingen
    Given the calculation date is "2030-01-01"
    Given law "verordening_europese_ruimte_voor_gezondheidsgegevens" is loaded
    Given the following parameters:
      | verwerking_buiten_werkingssfeer_unierecht                          | false |
      | verwerking_door_bevoegde_autoriteit_strafrecht                     | false |
      | in_gezondheidszorg_of_zorgsector                                   | false |
      | is_vergoedingsdienst_waar_noodzakelijk                             | false |
      | ontwikkelt_producten_of_diensten_voor_gezondheidssector            | true  |
      | ontwikkelt_of_vervaardigt_wellnessapps                             | false |
      | verricht_onderzoek_gezondheidszorg_of_zorgsector                   | false |
      | treedt_op_als_sterfteregister                                      | false |
      | is_instelling_orgaan_of_instantie_van_de_unie                      | false |
      | heeft_recht_of_plicht_tot_verwerking                               | false |
      | verwerkt_als_verwerkingsverantwoordelijke                          | false |
      | verwerkt_voor_doel_uit_punt_t_i                                    | true  |
      | kan_niet_persoonsgebonden_gegevens_beschikbaar_stellen_via_ontwerp | false |
      | lezing_punt_t_voorwaarden_gelden_voor_alle_partijen                | false |
      | houder_is_natuurlijke_persoon                                      | false |
      | houder_is_micro_onderneming                                        | false |
      | nationaal_recht_past_plichten_toe_op_vrijgestelde_houder           | false |
      | nationaal_recht_wijst_bemiddelingsentiteit_aan                     | false |
      | bevat_gegevens_over_gezondheid_of_genetische_gegevens              | true  |
      | gegevens_in_elektronische_vorm_verwerkt                            | true  |
      | bevat_niet_persoonsgebonden_elektronische_gezondheidsgegevens      | false |
      | databron_is_gestructureerde_verzameling                            | true  |
      | valt_in_categorie_a                                                | true  |
      | valt_in_categorie_b                                                | false |
      | valt_in_categorie_c                                                | false |
      | valt_in_categorie_d                                                | false |
      | valt_in_categorie_e                                                | false |
      | valt_in_categorie_f                                                | false |
      | valt_in_categorie_g                                                | false |
      | valt_in_categorie_h                                                | false |
      | valt_in_categorie_i                                                | false |
      | valt_in_categorie_j                                                | false |
      | valt_in_categorie_k                                                | false |
      | valt_in_categorie_l                                                | false |
      | valt_in_categorie_m                                                | false |
      | valt_in_categorie_n                                                | false |
      | valt_in_categorie_o                                                | false |
      | valt_in_categorie_p                                                | false |
      | valt_in_categorie_q                                                | false |
      | valt_in_aanvullende_nationale_categorie                            | false |
    When I evaluate "is_houder_van_gezondheidsgegevens" of "verordening_europese_ruimte_voor_gezondheidsgegevens"
    Then the execution succeeds
    Then output "is_houder_van_gezondheidsgegevens" is true
    When I evaluate "categorie_a" of "verordening_europese_ruimte_voor_gezondheidsgegevens"
    Then the execution succeeds
    Then output "categorie_a" is true
    When I evaluate "valt_onder_beschikbaarstellingsplicht" of "verordening_europese_ruimte_voor_gezondheidsgegevens"
    Then the execution succeeds
    Then output "valt_onder_beschikbaarstellingsplicht" is true
    When I evaluate "eerste_toepassingsdatum_beschikbaarstellingsplicht" of "verordening_europese_ruimte_voor_gezondheidsgegevens"
    Then the execution succeeds
    Then output "eerste_toepassingsdatum_beschikbaarstellingsplicht" equals "2029-03-26"

  # status: concept — te valideren door jurist
  # Zonder antwoord op de leesvraag is de uitkomst onbekend; de engine kiest geen lezing.
  @concept @bepaling:art2-lid2-onderdeel-t
  Scenario: Partij die EPD-gegevens alleen in opdracht van een ziekenhuis verwerkt, leesvraag onbeantwoord
    Given the calculation date is "2030-01-01"
    Given law "verordening_europese_ruimte_voor_gezondheidsgegevens" is loaded
    Given the following parameters:
      | verwerking_buiten_werkingssfeer_unierecht                          | false |
      | verwerking_door_bevoegde_autoriteit_strafrecht                     | false |
      | in_gezondheidszorg_of_zorgsector                                   | false |
      | is_vergoedingsdienst_waar_noodzakelijk                             | false |
      | ontwikkelt_producten_of_diensten_voor_gezondheidssector            | true  |
      | ontwikkelt_of_vervaardigt_wellnessapps                             | false |
      | verricht_onderzoek_gezondheidszorg_of_zorgsector                   | false |
      | treedt_op_als_sterfteregister                                      | false |
      | is_instelling_orgaan_of_instantie_van_de_unie                      | false |
      | heeft_recht_of_plicht_tot_verwerking                               | false |
      | verwerkt_als_verwerkingsverantwoordelijke                          | false |
      | verwerkt_voor_doel_uit_punt_t_i                                    | true  |
      | kan_niet_persoonsgebonden_gegevens_beschikbaar_stellen_via_ontwerp | false |
      | houder_is_natuurlijke_persoon                                      | false |
      | houder_is_micro_onderneming                                        | false |
      | nationaal_recht_past_plichten_toe_op_vrijgestelde_houder           | false |
      | nationaal_recht_wijst_bemiddelingsentiteit_aan                     | false |
      | bevat_gegevens_over_gezondheid_of_genetische_gegevens              | true  |
      | gegevens_in_elektronische_vorm_verwerkt                            | true  |
      | bevat_niet_persoonsgebonden_elektronische_gezondheidsgegevens      | false |
      | databron_is_gestructureerde_verzameling                            | true  |
      | valt_in_categorie_a                                                | true  |
      | valt_in_categorie_b                                                | false |
      | valt_in_categorie_c                                                | false |
      | valt_in_categorie_d                                                | false |
      | valt_in_categorie_e                                                | false |
      | valt_in_categorie_f                                                | false |
      | valt_in_categorie_g                                                | false |
      | valt_in_categorie_h                                                | false |
      | valt_in_categorie_i                                                | false |
      | valt_in_categorie_j                                                | false |
      | valt_in_categorie_k                                                | false |
      | valt_in_categorie_l                                                | false |
      | valt_in_categorie_m                                                | false |
      | valt_in_categorie_n                                                | false |
      | valt_in_categorie_o                                                | false |
      | valt_in_categorie_p                                                | false |
      | valt_in_categorie_q                                                | false |
      | valt_in_aanvullende_nationale_categorie                            | false |
    When I evaluate "is_houder_van_gezondheidsgegevens" of "verordening_europese_ruimte_voor_gezondheidsgegevens"
    Then the execution succeeds
    Then output "is_houder_van_gezondheidsgegevens" is unknown for lack of "lezing_punt_t_voorwaarden_gelden_voor_alle_partijen"
    When I evaluate "valt_onder_beschikbaarstellingsplicht" of "verordening_europese_ruimte_voor_gezondheidsgegevens"
    Then the execution succeeds
    Then output "valt_onder_beschikbaarstellingsplicht" is unknown for lack of "lezing_punt_t_voorwaarden_gelden_voor_alle_partijen"

  # status: concept — te valideren door jurist
  # Randgeval: de houder heeft plichten, maar de bron bevat geen elektronische gezondheidsgegevens. De categorievragen zijn niet beantwoord en hoeven dat ook niet.
  @concept @bepaling:art2-lid2-onderdeel-c @bepaling:art51-lid1
  Scenario: Ziekenhuisbron zonder gezondheidsgegevens
    Given the calculation date is "2030-01-01"
    Given law "verordening_europese_ruimte_voor_gezondheidsgegevens" is loaded
    Given the following parameters:
      | verwerking_buiten_werkingssfeer_unierecht                          | false |
      | verwerking_door_bevoegde_autoriteit_strafrecht                     | false |
      | in_gezondheidszorg_of_zorgsector                                   | true  |
      | is_vergoedingsdienst_waar_noodzakelijk                             | false |
      | ontwikkelt_producten_of_diensten_voor_gezondheidssector            | false |
      | ontwikkelt_of_vervaardigt_wellnessapps                             | false |
      | verricht_onderzoek_gezondheidszorg_of_zorgsector                   | false |
      | treedt_op_als_sterfteregister                                      | false |
      | is_instelling_orgaan_of_instantie_van_de_unie                      | false |
      | heeft_recht_of_plicht_tot_verwerking                               | true  |
      | verwerkt_als_verwerkingsverantwoordelijke                          | true  |
      | verwerkt_voor_doel_uit_punt_t_i                                    | true  |
      | kan_niet_persoonsgebonden_gegevens_beschikbaar_stellen_via_ontwerp | false |
      | lezing_punt_t_voorwaarden_gelden_voor_alle_partijen                | true  |
      | houder_is_natuurlijke_persoon                                      | false |
      | houder_is_micro_onderneming                                        | false |
      | nationaal_recht_past_plichten_toe_op_vrijgestelde_houder           | false |
      | nationaal_recht_wijst_bemiddelingsentiteit_aan                     | false |
      | bevat_gegevens_over_gezondheid_of_genetische_gegevens              | false |
      | gegevens_in_elektronische_vorm_verwerkt                            | true  |
      | bevat_niet_persoonsgebonden_elektronische_gezondheidsgegevens      | false |
      | databron_is_gestructureerde_verzameling                            | true  |
    When I evaluate "is_houder_van_gezondheidsgegevens" of "verordening_europese_ruimte_voor_gezondheidsgegevens"
    Then the execution succeeds
    Then output "is_houder_van_gezondheidsgegevens" is true
    When I evaluate "bevat_elektronische_gezondheidsgegevens" of "verordening_europese_ruimte_voor_gezondheidsgegevens"
    Then the execution succeeds
    Then output "bevat_elektronische_gezondheidsgegevens" is false
    When I evaluate "valt_onder_beschikbaarstellingsplicht" of "verordening_europese_ruimte_voor_gezondheidsgegevens"
    Then the execution succeeds
    Then output "valt_onder_beschikbaarstellingsplicht" is false
    When I evaluate "beschrijvingsplicht_dataset" of "verordening_europese_ruimte_voor_gezondheidsgegevens"
    Then the execution succeeds
    Then output "beschrijvingsplicht_dataset" is false
    When I evaluate "eerste_toepassingsdatum_beschikbaarstellingsplicht" of "verordening_europese_ruimte_voor_gezondheidsgegevens"
    Then the execution succeeds
    Then output "eerste_toepassingsdatum_beschikbaarstellingsplicht" is absent

  # status: concept — te valideren door jurist
  # Randgeval: de partij kan alleen als vergoedingsdienst houder zijn, en of dat “noodzakelijk” is, is niet beantwoord.
  @concept @bepaling:art2-lid2-onderdeel-t @bepaling:art51-lid1-onderdeel-e
  Scenario: Open norm onbeantwoord: vergoedingsdienst “indien noodzakelijk”
    Given the calculation date is "2030-01-01"
    Given law "verordening_europese_ruimte_voor_gezondheidsgegevens" is loaded
    Given the following parameters:
      | verwerking_buiten_werkingssfeer_unierecht                          | false |
      | verwerking_door_bevoegde_autoriteit_strafrecht                     | false |
      | in_gezondheidszorg_of_zorgsector                                   | false |
      | ontwikkelt_producten_of_diensten_voor_gezondheidssector            | false |
      | ontwikkelt_of_vervaardigt_wellnessapps                             | false |
      | verricht_onderzoek_gezondheidszorg_of_zorgsector                   | false |
      | treedt_op_als_sterfteregister                                      | false |
      | is_instelling_orgaan_of_instantie_van_de_unie                      | false |
      | heeft_recht_of_plicht_tot_verwerking                               | true  |
      | verwerkt_als_verwerkingsverantwoordelijke                          | true  |
      | verwerkt_voor_doel_uit_punt_t_i                                    | true  |
      | kan_niet_persoonsgebonden_gegevens_beschikbaar_stellen_via_ontwerp | false |
      | lezing_punt_t_voorwaarden_gelden_voor_alle_partijen                | true  |
      | houder_is_natuurlijke_persoon                                      | false |
      | houder_is_micro_onderneming                                        | false |
      | nationaal_recht_past_plichten_toe_op_vrijgestelde_houder           | false |
      | nationaal_recht_wijst_bemiddelingsentiteit_aan                     | false |
      | bevat_gegevens_over_gezondheid_of_genetische_gegevens              | true  |
      | gegevens_in_elektronische_vorm_verwerkt                            | true  |
      | bevat_niet_persoonsgebonden_elektronische_gezondheidsgegevens      | false |
      | databron_is_gestructureerde_verzameling                            | true  |
      | valt_in_categorie_a                                                | false |
      | valt_in_categorie_b                                                | false |
      | valt_in_categorie_c                                                | false |
      | valt_in_categorie_d                                                | false |
      | valt_in_categorie_e                                                | true  |
      | valt_in_categorie_f                                                | false |
      | valt_in_categorie_g                                                | false |
      | valt_in_categorie_h                                                | false |
      | valt_in_categorie_i                                                | false |
      | valt_in_categorie_j                                                | false |
      | valt_in_categorie_k                                                | false |
      | valt_in_categorie_l                                                | false |
      | valt_in_categorie_m                                                | false |
      | valt_in_categorie_n                                                | false |
      | valt_in_categorie_o                                                | false |
      | valt_in_categorie_p                                                | false |
      | valt_in_categorie_q                                                | false |
      | valt_in_aanvullende_nationale_categorie                            | false |
    When I evaluate "is_houder_van_gezondheidsgegevens" of "verordening_europese_ruimte_voor_gezondheidsgegevens"
    Then the execution succeeds
    Then output "is_houder_van_gezondheidsgegevens" is unknown for lack of "is_vergoedingsdienst_waar_noodzakelijk"
    When I evaluate "categorie_e" of "verordening_europese_ruimte_voor_gezondheidsgegevens"
    Then the execution succeeds
    Then output "categorie_e" is unknown for lack of "is_vergoedingsdienst_waar_noodzakelijk"
    When I evaluate "valt_onder_beschikbaarstellingsplicht" of "verordening_europese_ruimte_voor_gezondheidsgegevens"
    Then the execution succeeds
    Then output "valt_onder_beschikbaarstellingsplicht" is unknown for lack of "is_vergoedingsdienst_waar_noodzakelijk"

  # status: concept — te valideren door jurist
  # Art. 50, lid 1, punt b): vrijgesteld, en het nationale recht heeft de plichten niet van toepassing verklaard.
  @concept @bepaling:art50-lid1-onderdeel-b @bepaling:art50-lid2 @bepaling:art51-lid1-onderdeel-i
  Scenario: Micro-onderneming die een wellnessapp ontwikkelt is vrijgesteld
    Given the calculation date is "2030-01-01"
    Given law "verordening_europese_ruimte_voor_gezondheidsgegevens" is loaded
    Given the following parameters:
      | verwerking_buiten_werkingssfeer_unierecht                          | false |
      | verwerking_door_bevoegde_autoriteit_strafrecht                     | false |
      | in_gezondheidszorg_of_zorgsector                                   | false |
      | is_vergoedingsdienst_waar_noodzakelijk                             | false |
      | ontwikkelt_producten_of_diensten_voor_gezondheidssector            | false |
      | ontwikkelt_of_vervaardigt_wellnessapps                             | true  |
      | verricht_onderzoek_gezondheidszorg_of_zorgsector                   | false |
      | treedt_op_als_sterfteregister                                      | false |
      | is_instelling_orgaan_of_instantie_van_de_unie                      | false |
      | heeft_recht_of_plicht_tot_verwerking                               | false |
      | verwerkt_als_verwerkingsverantwoordelijke                          | false |
      | verwerkt_voor_doel_uit_punt_t_i                                    | false |
      | kan_niet_persoonsgebonden_gegevens_beschikbaar_stellen_via_ontwerp | true  |
      | lezing_punt_t_voorwaarden_gelden_voor_alle_partijen                | true  |
      | houder_is_natuurlijke_persoon                                      | false |
      | houder_is_micro_onderneming                                        | true  |
      | nationaal_recht_past_plichten_toe_op_vrijgestelde_houder           | false |
      | nationaal_recht_wijst_bemiddelingsentiteit_aan                     | false |
      | bevat_gegevens_over_gezondheid_of_genetische_gegevens              | true  |
      | gegevens_in_elektronische_vorm_verwerkt                            | true  |
      | bevat_niet_persoonsgebonden_elektronische_gezondheidsgegevens      | false |
      | databron_is_gestructureerde_verzameling                            | true  |
      | valt_in_categorie_a                                                | false |
      | valt_in_categorie_b                                                | false |
      | valt_in_categorie_c                                                | false |
      | valt_in_categorie_d                                                | false |
      | valt_in_categorie_e                                                | false |
      | valt_in_categorie_f                                                | false |
      | valt_in_categorie_g                                                | false |
      | valt_in_categorie_h                                                | false |
      | valt_in_categorie_i                                                | true  |
      | valt_in_categorie_j                                                | false |
      | valt_in_categorie_k                                                | false |
      | valt_in_categorie_l                                                | false |
      | valt_in_categorie_m                                                | false |
      | valt_in_categorie_n                                                | false |
      | valt_in_categorie_o                                                | false |
      | valt_in_categorie_p                                                | false |
      | valt_in_categorie_q                                                | false |
      | valt_in_aanvullende_nationale_categorie                            | false |
    When I evaluate "is_houder_van_gezondheidsgegevens" of "verordening_europese_ruimte_voor_gezondheidsgegevens"
    Then the execution succeeds
    Then output "is_houder_van_gezondheidsgegevens" is true
    When I evaluate "vrijstelling_geldt" of "verordening_europese_ruimte_voor_gezondheidsgegevens"
    Then the execution succeeds
    Then output "vrijstelling_geldt" is true
    When I evaluate "heeft_plichten_als_houder" of "verordening_europese_ruimte_voor_gezondheidsgegevens"
    Then the execution succeeds
    Then output "heeft_plichten_als_houder" is false
    When I evaluate "categorie_i" of "verordening_europese_ruimte_voor_gezondheidsgegevens"
    Then the execution succeeds
    Then output "categorie_i" is false
    When I evaluate "valt_onder_beschikbaarstellingsplicht" of "verordening_europese_ruimte_voor_gezondheidsgegevens"
    Then the execution succeeds
    Then output "valt_onder_beschikbaarstellingsplicht" is false

  # status: concept — te valideren door jurist
  # Art. 50, lid 2: de lidstaat heeft de plichten op deze categorie van toepassing verklaard.
  @concept @bepaling:art50-lid2 @bepaling:art51-lid1-onderdeel-i @bepaling:art105-alinea5
  Scenario: Micro-onderneming die een wellnessapp ontwikkelt, nationaal recht past de plichten toch toe
    Given the calculation date is "2030-01-01"
    Given law "verordening_europese_ruimte_voor_gezondheidsgegevens" is loaded
    Given the following parameters:
      | verwerking_buiten_werkingssfeer_unierecht                          | false |
      | verwerking_door_bevoegde_autoriteit_strafrecht                     | false |
      | in_gezondheidszorg_of_zorgsector                                   | false |
      | is_vergoedingsdienst_waar_noodzakelijk                             | false |
      | ontwikkelt_producten_of_diensten_voor_gezondheidssector            | false |
      | ontwikkelt_of_vervaardigt_wellnessapps                             | true  |
      | verricht_onderzoek_gezondheidszorg_of_zorgsector                   | false |
      | treedt_op_als_sterfteregister                                      | false |
      | is_instelling_orgaan_of_instantie_van_de_unie                      | false |
      | heeft_recht_of_plicht_tot_verwerking                               | false |
      | verwerkt_als_verwerkingsverantwoordelijke                          | false |
      | verwerkt_voor_doel_uit_punt_t_i                                    | false |
      | kan_niet_persoonsgebonden_gegevens_beschikbaar_stellen_via_ontwerp | true  |
      | lezing_punt_t_voorwaarden_gelden_voor_alle_partijen                | true  |
      | houder_is_natuurlijke_persoon                                      | false |
      | houder_is_micro_onderneming                                        | true  |
      | nationaal_recht_past_plichten_toe_op_vrijgestelde_houder           | true  |
      | nationaal_recht_wijst_bemiddelingsentiteit_aan                     | false |
      | bevat_gegevens_over_gezondheid_of_genetische_gegevens              | true  |
      | gegevens_in_elektronische_vorm_verwerkt                            | true  |
      | bevat_niet_persoonsgebonden_elektronische_gezondheidsgegevens      | false |
      | databron_is_gestructureerde_verzameling                            | true  |
      | valt_in_categorie_a                                                | false |
      | valt_in_categorie_b                                                | false |
      | valt_in_categorie_c                                                | false |
      | valt_in_categorie_d                                                | false |
      | valt_in_categorie_e                                                | false |
      | valt_in_categorie_f                                                | false |
      | valt_in_categorie_g                                                | false |
      | valt_in_categorie_h                                                | false |
      | valt_in_categorie_i                                                | true  |
      | valt_in_categorie_j                                                | false |
      | valt_in_categorie_k                                                | false |
      | valt_in_categorie_l                                                | false |
      | valt_in_categorie_m                                                | false |
      | valt_in_categorie_n                                                | false |
      | valt_in_categorie_o                                                | false |
      | valt_in_categorie_p                                                | false |
      | valt_in_categorie_q                                                | false |
      | valt_in_aanvullende_nationale_categorie                            | false |
    When I evaluate "vrijstelling_geldt" of "verordening_europese_ruimte_voor_gezondheidsgegevens"
    Then the execution succeeds
    Then output "vrijstelling_geldt" is false
    When I evaluate "heeft_plichten_als_houder" of "verordening_europese_ruimte_voor_gezondheidsgegevens"
    Then the execution succeeds
    Then output "heeft_plichten_als_houder" is true
    When I evaluate "categorie_i" of "verordening_europese_ruimte_voor_gezondheidsgegevens"
    Then the execution succeeds
    Then output "categorie_i" is true
    When I evaluate "eerste_toepassingsdatum_beschikbaarstellingsplicht" of "verordening_europese_ruimte_voor_gezondheidsgegevens"
    Then the execution succeeds
    Then output "eerste_toepassingsdatum_beschikbaarstellingsplicht" equals "2029-03-26"

  # status: concept — te valideren door jurist
  # Art. 1, lid 9, punt b): de verordening is niet van toepassing op deze verwerking van persoonsgegevens.
  @concept @bepaling:art1-lid9-onderdeel-b
  Scenario: Verwerking door een bevoegde autoriteit voor strafrechtelijke doeleinden
    Given the calculation date is "2030-01-01"
    Given law "verordening_europese_ruimte_voor_gezondheidsgegevens" is loaded
    Given the following parameters:
      | verwerking_buiten_werkingssfeer_unierecht                          | false |
      | verwerking_door_bevoegde_autoriteit_strafrecht                     | true  |
      | in_gezondheidszorg_of_zorgsector                                   | true  |
      | is_vergoedingsdienst_waar_noodzakelijk                             | false |
      | ontwikkelt_producten_of_diensten_voor_gezondheidssector            | false |
      | ontwikkelt_of_vervaardigt_wellnessapps                             | false |
      | verricht_onderzoek_gezondheidszorg_of_zorgsector                   | false |
      | treedt_op_als_sterfteregister                                      | false |
      | is_instelling_orgaan_of_instantie_van_de_unie                      | false |
      | heeft_recht_of_plicht_tot_verwerking                               | true  |
      | verwerkt_als_verwerkingsverantwoordelijke                          | true  |
      | verwerkt_voor_doel_uit_punt_t_i                                    | true  |
      | kan_niet_persoonsgebonden_gegevens_beschikbaar_stellen_via_ontwerp | false |
      | lezing_punt_t_voorwaarden_gelden_voor_alle_partijen                | true  |
      | houder_is_natuurlijke_persoon                                      | false |
      | houder_is_micro_onderneming                                        | false |
      | nationaal_recht_past_plichten_toe_op_vrijgestelde_houder           | false |
      | nationaal_recht_wijst_bemiddelingsentiteit_aan                     | false |
      | bevat_gegevens_over_gezondheid_of_genetische_gegevens              | true  |
      | gegevens_in_elektronische_vorm_verwerkt                            | true  |
      | bevat_niet_persoonsgebonden_elektronische_gezondheidsgegevens      | false |
      | databron_is_gestructureerde_verzameling                            | true  |
      | valt_in_categorie_a                                                | false |
      | valt_in_categorie_b                                                | false |
      | valt_in_categorie_c                                                | false |
      | valt_in_categorie_d                                                | false |
      | valt_in_categorie_e                                                | false |
      | valt_in_categorie_f                                                | false |
      | valt_in_categorie_g                                                | false |
      | valt_in_categorie_h                                                | false |
      | valt_in_categorie_i                                                | false |
      | valt_in_categorie_j                                                | false |
      | valt_in_categorie_k                                                | false |
      | valt_in_categorie_l                                                | true  |
      | valt_in_categorie_m                                                | false |
      | valt_in_categorie_n                                                | false |
      | valt_in_categorie_o                                                | false |
      | valt_in_categorie_p                                                | false |
      | valt_in_categorie_q                                                | false |
      | valt_in_aanvullende_nationale_categorie                            | false |
    When I evaluate "verordening_niet_van_toepassing_art1_lid9" of "verordening_europese_ruimte_voor_gezondheidsgegevens"
    Then the execution succeeds
    Then output "verordening_niet_van_toepassing_art1_lid9" is true
    When I evaluate "heeft_plichten_als_houder" of "verordening_europese_ruimte_voor_gezondheidsgegevens"
    Then the execution succeeds
    Then output "heeft_plichten_als_houder" is false
    When I evaluate "categorie_l" of "verordening_europese_ruimte_voor_gezondheidsgegevens"
    Then the execution succeeds
    Then output "categorie_l" is false
    When I evaluate "valt_onder_beschikbaarstellingsplicht" of "verordening_europese_ruimte_voor_gezondheidsgegevens"
    Then the execution succeeds
    Then output "valt_onder_beschikbaarstellingsplicht" is false

  # status: concept — te valideren door jurist
  # Toetst de modelkeuze dat art. 60, lid 3, niet beperkt is tot de categorieën van art. 51 (zie interpretatielogboek).
  @concept @bepaling:art60-lid3 @bepaling:art2-lid2-onderdeel-w
  Scenario: Dataset met gezondheidsgegevens buiten de categorieën van art. 51: wel beschrijvingsplicht
    Given the calculation date is "2030-01-01"
    Given law "verordening_europese_ruimte_voor_gezondheidsgegevens" is loaded
    Given the following parameters:
      | verwerking_buiten_werkingssfeer_unierecht                          | false |
      | verwerking_door_bevoegde_autoriteit_strafrecht                     | false |
      | in_gezondheidszorg_of_zorgsector                                   | true  |
      | is_vergoedingsdienst_waar_noodzakelijk                             | false |
      | ontwikkelt_producten_of_diensten_voor_gezondheidssector            | false |
      | ontwikkelt_of_vervaardigt_wellnessapps                             | false |
      | verricht_onderzoek_gezondheidszorg_of_zorgsector                   | false |
      | treedt_op_als_sterfteregister                                      | false |
      | is_instelling_orgaan_of_instantie_van_de_unie                      | false |
      | heeft_recht_of_plicht_tot_verwerking                               | true  |
      | verwerkt_als_verwerkingsverantwoordelijke                          | true  |
      | verwerkt_voor_doel_uit_punt_t_i                                    | true  |
      | kan_niet_persoonsgebonden_gegevens_beschikbaar_stellen_via_ontwerp | false |
      | lezing_punt_t_voorwaarden_gelden_voor_alle_partijen                | true  |
      | houder_is_natuurlijke_persoon                                      | false |
      | houder_is_micro_onderneming                                        | false |
      | nationaal_recht_past_plichten_toe_op_vrijgestelde_houder           | false |
      | nationaal_recht_wijst_bemiddelingsentiteit_aan                     | false |
      | bevat_gegevens_over_gezondheid_of_genetische_gegevens              | true  |
      | gegevens_in_elektronische_vorm_verwerkt                            | true  |
      | bevat_niet_persoonsgebonden_elektronische_gezondheidsgegevens      | false |
      | databron_is_gestructureerde_verzameling                            | true  |
      | valt_in_categorie_a                                                | false |
      | valt_in_categorie_b                                                | false |
      | valt_in_categorie_c                                                | false |
      | valt_in_categorie_d                                                | false |
      | valt_in_categorie_e                                                | false |
      | valt_in_categorie_f                                                | false |
      | valt_in_categorie_g                                                | false |
      | valt_in_categorie_h                                                | false |
      | valt_in_categorie_i                                                | false |
      | valt_in_categorie_j                                                | false |
      | valt_in_categorie_k                                                | false |
      | valt_in_categorie_l                                                | false |
      | valt_in_categorie_m                                                | false |
      | valt_in_categorie_n                                                | false |
      | valt_in_categorie_o                                                | false |
      | valt_in_categorie_p                                                | false |
      | valt_in_categorie_q                                                | false |
      | valt_in_aanvullende_nationale_categorie                            | false |
    When I evaluate "valt_onder_beschikbaarstellingsplicht" of "verordening_europese_ruimte_voor_gezondheidsgegevens"
    Then the execution succeeds
    Then output "valt_onder_beschikbaarstellingsplicht" is false
    When I evaluate "beschrijvingsplicht_dataset" of "verordening_europese_ruimte_voor_gezondheidsgegevens"
    Then the execution succeeds
    Then output "beschrijvingsplicht_dataset" is true
    When I evaluate "beschrijvingsplicht_geldt_op_peildatum" of "verordening_europese_ruimte_voor_gezondheidsgegevens"
    Then the execution succeeds
    Then output "beschrijvingsplicht_geldt_op_peildatum" is true

  # status: concept — te valideren door jurist
  # Categorie c), en art. 60, lid 5, voor de houder van niet-persoonsgebonden gegevens.
  @concept @bepaling:art2-lid2-onderdeel-b @bepaling:art51-lid1-onderdeel-c @bepaling:art60-lid5
  Scenario: Geaggregeerde, niet-persoonsgebonden gegevens over zorgverbruik
    Given the calculation date is "2029-03-26"
    Given law "verordening_europese_ruimte_voor_gezondheidsgegevens" is loaded
    Given the following parameters:
      | verwerking_buiten_werkingssfeer_unierecht                          | false |
      | verwerking_door_bevoegde_autoriteit_strafrecht                     | false |
      | in_gezondheidszorg_of_zorgsector                                   | true  |
      | is_vergoedingsdienst_waar_noodzakelijk                             | false |
      | ontwikkelt_producten_of_diensten_voor_gezondheidssector            | false |
      | ontwikkelt_of_vervaardigt_wellnessapps                             | false |
      | verricht_onderzoek_gezondheidszorg_of_zorgsector                   | false |
      | treedt_op_als_sterfteregister                                      | false |
      | is_instelling_orgaan_of_instantie_van_de_unie                      | false |
      | heeft_recht_of_plicht_tot_verwerking                               | true  |
      | verwerkt_als_verwerkingsverantwoordelijke                          | true  |
      | verwerkt_voor_doel_uit_punt_t_i                                    | true  |
      | kan_niet_persoonsgebonden_gegevens_beschikbaar_stellen_via_ontwerp | false |
      | lezing_punt_t_voorwaarden_gelden_voor_alle_partijen                | true  |
      | houder_is_natuurlijke_persoon                                      | false |
      | houder_is_micro_onderneming                                        | false |
      | nationaal_recht_past_plichten_toe_op_vrijgestelde_houder           | false |
      | nationaal_recht_wijst_bemiddelingsentiteit_aan                     | false |
      | bevat_gegevens_over_gezondheid_of_genetische_gegevens              | false |
      | gegevens_in_elektronische_vorm_verwerkt                            | true  |
      | bevat_niet_persoonsgebonden_elektronische_gezondheidsgegevens      | true  |
      | databron_is_gestructureerde_verzameling                            | true  |
      | valt_in_categorie_a                                                | false |
      | valt_in_categorie_b                                                | false |
      | valt_in_categorie_c                                                | true  |
      | valt_in_categorie_d                                                | false |
      | valt_in_categorie_e                                                | false |
      | valt_in_categorie_f                                                | false |
      | valt_in_categorie_g                                                | false |
      | valt_in_categorie_h                                                | false |
      | valt_in_categorie_i                                                | false |
      | valt_in_categorie_j                                                | false |
      | valt_in_categorie_k                                                | false |
      | valt_in_categorie_l                                                | false |
      | valt_in_categorie_m                                                | false |
      | valt_in_categorie_n                                                | false |
      | valt_in_categorie_o                                                | false |
      | valt_in_categorie_p                                                | false |
      | valt_in_categorie_q                                                | false |
      | valt_in_aanvullende_nationale_categorie                            | false |
    When I evaluate "categorie_c" of "verordening_europese_ruimte_voor_gezondheidsgegevens"
    Then the execution succeeds
    Then output "categorie_c" is true
    When I evaluate "toegang_via_betrouwbare_open_databanken" of "verordening_europese_ruimte_voor_gezondheidsgegevens"
    Then the execution succeeds
    Then output "toegang_via_betrouwbare_open_databanken" is true
    When I evaluate "open_databank_plicht_geldt_op_peildatum" of "verordening_europese_ruimte_voor_gezondheidsgegevens"
    Then the execution succeeds
    Then output "open_databank_plicht_geldt_op_peildatum" is true
    When I evaluate "beschikbaarstellingsplicht_geldt_op_peildatum" of "verordening_europese_ruimte_voor_gezondheidsgegevens"
    Then the execution succeeds
    Then output "beschikbaarstellingsplicht_geldt_op_peildatum" is true
