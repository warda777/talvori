# Phase 2G-M12-A2: ThemeIsland Prioritization Visual Review

Stand: 2026-06-06

Status: `visuelle Pruefung gestartet / erste Priorisierung brauchbar`

Dieses Dokument prueft die M12-Previews zur ThemeIsland-Priorisierung.

Die Pruefung gibt keine Freigabe fuer:

- Flutter-/Dart-Code,
- App-Integration,
- Tests,
- Spielassets,
- PNG-Aenderungen,
- finales Inselbild,
- finale ThemeIsland-Roadmap,
- ThemeIsland-Umsetzung,
- Assetproduktion,
- `frame_started`,
- Bauzustaende.

## 1. Zweck

M12 priorisiert ThemeIsland-Kandidaten als erste Planungsrichtung. M12-A2
prueft, ob die Previews diese Richtung visuell verstaendlich machen und ob
Early-, Mid-, Late- und Sensitive/Blocked-Kandidaten nachvollziehbar getrennt
sind.

M12-A2 entscheidet nicht ueber Produktion. Es bewertet nur, ob M12 als
Planungsrichtung brauchbar ist oder nachgebessert werden muss.

## 2. Gepruefte Dateien

Geprueft wurden:

- `docs/world_design/previews/phase2g_m12_theme_island_prioritization/01_theme_island_priority_map.png`
- `docs/world_design/previews/phase2g_m12_theme_island_prioritization/02_theme_island_decision_matrix.png`
- `docs/world_design/previews/phase2g_m12_theme_island_prioritization/03_early_candidate_flow_examples.png`
- `docs/world_design/previews/phase2g_m12_theme_island_prioritization/04_scope_risk_wave_plan.png`
- `docs/world_design/previews/phase2g_m12_theme_island_prioritization/README.md`

## 3. Visuelle Bewertung

| Prueffrage | Bewertung |
| --- | --- |
| Ist die Early/Mid/Late/Special-Struktur verstaendlich? | Ja. Die farbigen Spalten und Wellen machen die erste Gruppierung klar. |
| Wird klar, dass M12 keine finale Roadmap ist? | Ja. Titel, Footer und README markieren M12 als Planung, nicht Produktion. |
| Sind Zuhause/Alltag, Schule/Lernen und Garten/Natur nah als Early-Kandidaten nachvollziehbar? | Ja. Die Flow-Beispiele zeigen einfache Container-/Depth-Flows und passende Tap-Auswahl-Challenges. |
| Wird klar, warum Kueste/Meer/Hafen, Essen/Restaurant/Cafe, Einkauf/Versorgung und Land/Farm Mid bleiben? | Ja. Sie wirken attraktiv, sind aber mit Mobile-, Clutter-, Timer-, Wasser- oder Scope-Risiken markiert. |
| Wird klar, warum Stadt, Verkehr, Arbeit, Freizeit, Outdoor und Technik spaeter kommen? | Ja. Matrix und Scope-Plan zeigen mehr Systembedarf. |
| Wird klar, warum sensible Themen blockiert bleiben? | Ja. Gesundheit, Kultur/Gesellschaft/Verwaltung und Religion/Politik/Gericht/Polizei sind als blocked/special sichtbar. |
| Ist die Decision Matrix lesbar? | Ja fuer interne Planung. Sie ist dicht, aber die Bewertungscodes sind konsistent und lesbar. |
| Ist die Matrix zu dicht? | Fuer Nutzer waere sie zu technisch; fuer interne Planung ist sie brauchbar. |
| Sind die Early Candidate Flow Examples verstaendlich? | Ja. Die drei Flow-Spalten zeigen klar Bereich -> Container -> Objekt -> Tap-Challenge. |
| Bleiben alle Texte in Karten/Rahmen/Panels? | Ja. Keine sichtbaren abgeschnittenen oder herauslaufenden Texte. |
| Wird keine ThemeIsland-Umsetzung, Assetproduktion oder finale Roadmap suggeriert? | Ja. Die Previews sind als Debug-/Dokumentationsmaterial erkennbar. |
| Sind Risiken ausreichend sichtbar? | Ja fuer M12. Fuer spaetere Planung brauchen die Risiken aber eigene Follow-up-Bloecke. |

## 4. Sichtbare Staerken

- Die Wellenlogik ist schnell erfassbar.
- Early-Kandidaten werden nicht nur benannt, sondern mit Beispiel-Flows
  begruendet.
- Mid- und Late-Kandidaten werden nicht abgewertet, sondern bewusst wegen
  Scope und Systembedarf verschoben.
- Sensitive/Blocked-Themen sind klar getrennt und werden nicht in die erste
  Produktionswelle gezogen.
- Die Previews vermeiden Spielasset-Optik und bleiben Dokumentationsmaterial.

## 5. Sichtbare Risiken

- Die Decision Matrix ist fuer interne Planung brauchbar, aber nicht als
  Nutzer-/Produktansicht geeignet.
- `Zuhause / Alltag` darf nicht wieder als Pflicht-Hausstart gelesen werden.
- `Schule / Lernen` braucht vor Umsetzung Mobile-/Clutter-Regeln fuer
  Kleinteile.
- `Garten / Natur nah` braucht Fairness-/Timer-Regeln, bevor Wachstum oder
  Daily-Routinen geplant werden.
- `Kueste / Meer / Hafen` bleibt visuell stark, aber mobile und systemisch
  riskanter.
- Sensitive Inseln duerfen ohne M12-D nicht weiter produktiv geplant werden.

## 6. Entscheidungsempfehlung

Empfehlung:

```text
M12 als erste ThemeIsland-Priorisierung grundsaetzlich bestaetigen.
```

Begruendung:

- Die Early/Mid/Late/Sensitive-Trennung ist visuell nachvollziehbar.
- Die Early-Kandidaten sind durch konkrete Container-/Depth-Flows begruendet.
- Die Risiken sind sichtbar genug, um Folgeblocks sauber abzuleiten.
- M12 bleibt klar Planungsgrundlage und keine finale Roadmap.

Keine Freigabe:

- keine finale ThemeIsland-Roadmap,
- keine ThemeIsland-Umsetzung,
- keine Assetproduktion,
- keine App-Integration,
- kein Code,
- kein `frame_started`.

## 7. Bestaetigte Kandidaten Fuer Den Planungsstand

### Early

- `Zuhause / Alltag`
- `Schule / Lernen`
- `Garten / Natur nah`

### Mid

- `Kueste / Meer / Hafen`
- `Essen / Restaurant / Cafe`
- `Einkauf / Versorgung`
- `Land / Farm`

### Late

- `Stadt / Dorfzentrum`
- `Reisen / Verkehr`
- `Arbeit / Berufe / Werkstatt`
- `Freizeit / Sport`
- `Natur / Berge / Outdoor`
- `Technik / Digital`

### Sensitive / Blocked

- `Gesundheit`
- `Kultur / Gesellschaft / Verwaltung`
- Religion,
- Politik,
- Gericht,
- Polizei,
- Krankenhaus.

## 8. Offene Folgeblocks

Weiterhin offen:

- `Phase 2G-M12-B Word-to-Island Routing Matrix`
- `Phase 2G-M12-C Plot-Capability Derivation`
- `Phase 2G-M12-D Sensitive Content Representation Rules`
- `Phase 2G-M12-E Mobile And Clutter Rules For Small Objects`

M12-A2 ersetzt diese Folgeblocks nicht.

## 9. Stop-Regeln

Stoppen, wenn:

- aus M12-A2 eine finale ThemeIsland-Roadmap abgeleitet wird,
- aus M12-A2 eine ThemeIsland-Umsetzung abgeleitet wird,
- aus M12-A2 Assetproduktion abgeleitet wird,
- eine Early-Insel ohne M12-B Word-to-Island Routing geplant wird,
- eine Early-Insel ohne M12-C Plot-Capability-Ableitung geplant wird,
- Schule/Federmappe ohne Mobile-/Clutter-Regeln umgesetzt werden soll,
- Gartenwachstum ohne Fairness-/Timer-Regeln geplant wird,
- Zuhause/Alltag als Pflicht-Hausstart erzwungen wird,
- sensible Inseln ohne M12-D Sensitive-Content-Regeln geplant werden.

## 10. Naechster Erlaubter Schritt

Erlaubt:

- M12-A2 dokumentarisch bestaetigen,
- M12 nachbessern, falls Nutzer das wuenscht,
- M12-B Word-to-Island Routing Matrix planen,
- M12-C Plot-Capability Derivation planen,
- M12-D Sensitive Content Representation Rules planen,
- M12-E Mobile And Clutter Rules planen.

Weiterhin nicht erlaubt:

- Code,
- App-Integration,
- Spielassets,
- PNG-Aenderungen,
- finale Roadmap,
- ThemeIsland-Umsetzung,
- `frame_started`.
