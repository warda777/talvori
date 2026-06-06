# Phase 2G-M11-C2: World Content Taxonomy Review

Stand: 2026-06-06

Status: `Taxonomy Review gestartet / erste Grundlage brauchbar`

Dieses Dokument prueft den World Content Taxonomy And Location Catalog aus
`docs/world_design/266-world-content-taxonomy-and-location-catalog.md`.

Die Pruefung klaert, ob der Katalog als erste Grundlage fuer spaetere
ThemeIsland-Roadmap, Plot-Capabilities, Word-to-Island-Routing und
Depth-/Container-Planung brauchbar ist.

Die Pruefung gibt keine Freigabe fuer:

- Flutter-/Dart-Code,
- App-Integration,
- Tests,
- Spielassets,
- PNGs,
- finales Inselbild,
- finale ThemeIsland-Roadmap,
- Assetproduktion,
- `frame_started`,
- Bauzustaende.

## 1. Zweck

M11-C hat die umfangreiche Nutzerliste moeglicher Orte, Gebaeude,
Aussenbereiche, Infrastruktur, Naturflaechen, Wasser-/Kuestenbereiche,
Landwirtschaft und Details als strukturierten Taxonomy-Katalog aufgenommen.

M11-C2 prueft:

- ob die 14 Hauptkategorien sinnvoll sind,
- ob die Ebenenlogik verstaendlich ist,
- ob Scope- und Stop-Regeln klar genug sind,
- ob wichtige Querschnittsbereiche fehlen,
- welche Folgeblocks aus dem Katalog abgeleitet werden duerfen.

## 2. Gepruefte Datei

Geprueft wurde:

- `docs/world_design/266-world-content-taxonomy-and-location-catalog.md`

Der Katalog ist weiterhin:

- keine Assetliste,
- keine Bau-Freigabe,
- keine finale ThemeIsland-Roadmap,
- keine Codefreigabe.

## 3. Review Der Hauptstruktur

| Prueffrage | Bewertung |
| --- | --- |
| Sind die 14 Hauptkategorien sinnvoll? | Ja. Sie decken Wohn-, Aussen-, Verkehr-, Stadt-, Versorgung-, Freizeit-, Public-Service-, Arbeit-, Natur-, Wasser-, Landwirtschafts- und Detailbereiche breit ab. |
| Fehlen wichtige Oberkategorien? | Keine grobe Weltkategorie fehlt kritisch, aber mehrere Querschnittsbereiche sollten als Follow-up ergaenzt werden. |
| Sind Kategorien doppelt oder stark ueberlappend? | Teilweise ja, aber akzeptabel. `Gastronomie/Freizeit`, `Freizeit draussen`, `Einkauf/Versorgung` und `Stadt/Dorfzentrum` ueberlappen bewusst und brauchen spaeter Routing-Regeln. |
| Ist die Ebene `ThemeIsland -> Zone -> Plot/Gebaeude -> Aussenbereich -> Innenraum -> Container/Fokusobjekt -> Detail/Deko` verstaendlich? | Ja. Die Ebene ist stark genug, um grosse Begriffe von kleinen Detailwoertern zu trennen. |
| Wird klar, dass grosse Themen nicht auf die Waldlichtung gepresst werden duerfen? | Ja. Der Katalog und das Template markieren die Waldlichtung als Starter-/Testform. |
| Wird klar, dass kleine Woerter eher in Interior-/Container-/Detail-Views gehoeren? | Ja. Die Routing-Regeln und Beispiele stuetzen das. |
| Wird klar, dass Deko nicht automatisch Lernobjekt oder Asset bedeutet? | Ja. Deko wird als `DecorationPool`, `AmbientObject` oder DetailAnchor beschrieben, mit Clutter-Warnung. |
| Werden sensible Bereiche markiert? | Ja fuer Krankenhaus, Polizei, Politik und Religion. Gericht, Kultur/Feste und persoenliche/sensible Alltagsthemen sollten spaeter expliziter werden. |
| Wird klar, dass Verkehr/Fahrzeuge eigene Logik brauchen? | Ja. Fahrzeuge, Strassen und Wege sind als `requires_own_system` oder Connector-/Path-System markiert. |
| Wird klar, dass der Katalog keine finale Roadmap ist? | Ja. Mehrfach als Taxonomy-Backlog und nicht finale ThemeIsland-Roadmap markiert. |
| Wird klar, dass keine Assetproduktion daraus folgt? | Ja. Scope- und Stop-Regeln sagen das explizit. |

## 4. Bewertung Der 14 Hauptkategorien

| Kategorie | Review |
| --- | --- |
| Wohnbereiche | Sinnvoll als Building-Archetype-Backlog. Early nur einfaches Zuhause; andere Wohnformen spaeter. |
| Grundstueck/Aussenbereich | Sehr wichtig fuer Starter-, Garten- und Haus-Depth-Flows. Gute fruehe Kandidaten, aber Clutter beachten. |
| Fahrzeuge/Parken | Inhaltlich wichtig, aber systemisch komplex. Richtig als `requires_own_system` markiert. |
| Strassen/Wege | Zentrale Connector-/Path-Kategorie. Darf nicht als reine Deko behandelt werden. |
| Stadt-/Dorfzentrum | Sinnvoll fuer Hub-, Social- und Civic-Zonen; eher eigene Stadt-/Dorfinsel. |
| Einkauf/Versorgung | Stark fuer Vocabulary-Sets, aber hohe Scope-Gefahr durch Innenraeume und Warenlisten. |
| Gastronomie/Freizeit | Wichtig fuer Essen, Aktivitaeten und Tourismus; braucht spaeter eigene Interior-/Activity-Flows. |
| Oeffentliche Gebaeude | Sinnvoll, aber sensibel. Bildung kann frueher kommen; Gesundheit/Polizei/Politik spaeter mit Safety. |
| Arbeit/Gewerbe/Industrie | Stark fuer Berufs- und Prozessvokabeln; braucht spaeter Produktions- und Werkzeuglogik. |
| Natur/Gruenflaechen | Wichtig fuer Biome, Kulisse und Naturwoerter; gut fuer Themeninseln und ruhige Lernorte. |
| Freizeit draussen | Gut fuer Aktionswoerter und Mini-Sequenzen; nicht ohne Aktionslogik implementieren. |
| Wasser/Hafen/Kueste | Sehr wichtige eigene ThemeIsland-Gruppe; nicht auf Waldlichtung pressen. |
| Landwirtschaft/laendlich | Stark fuer Wachstum, Tiere und Produktionsloops; Timer/Fairness beachten. |
| Dekoration/Details | Notwendig fuer Lebendigkeit, aber klare Clutter- und Lernobjekt-Trennung noetig. |

## 5. Luecken Und Follow-up-Bereiche

Diese Bereiche fehlen nicht als Sofortanforderung, sollten aber fuer spaetere
Planungsbloecke sichtbar vorgemerkt werden:

| Bereich | Warum wichtig | Status |
| --- | --- | --- |
| Innenraeume als Querschnittsebene | `InteriorOrRoom` ist vorhanden, braucht spaeter eigene Interior-Taxonomy. | follow-up |
| Moebel und Haushaltsgegenstaende | Zentral fuer Zuhause, Restaurant, Schule und Health-Interiors. | follow-up |
| Werkzeuge und Maschinen | Wichtig fuer Werkstatt, Farm, Industrie, Fahrzeuge und Bau. | follow-up |
| Tiere | Wichtig fuer Farm, Natur, Haustiere, Wasser/Kueste und Wortsets. | follow-up |
| Kleidung und persoenliche Gegenstaende | Wichtig fuer Alltag, Reisen, Schule, Sport und Container wie Koffer/Rucksack. | follow-up |
| Wetter, Jahreszeiten, Tageszeiten | Wichtig fuer Kueste, Natur, Landwirtschaft und Events. | follow-up |
| Emotionen, soziale Situationen, abstrakte Begriffe | Brauchen Codex/Dialog/Szene statt Objektzwang. | follow-up |
| Digitale/technische Raeume | Computer, Smartphone, App, Serverraum und Labor brauchen Technik-Theme. | follow-up |
| Lern-/Schulmaterialien | Federmappe ist erfasst, aber Schule braucht Material-Taxonomy. | follow-up |
| Gesundheitsobjekte, Medikamente, Pflegehilfen | Sensibel und wichtig fuer Health-Theme. | follow-up / safety |
| Sicherheits-/Notfallobjekte | Feuerwehr, Polizei, Erste Hilfe, Rettung brauchen sensible Darstellung. | follow-up / safety |
| Kultur/Feste/Religion | Als sensible Spezialkategorie spaeter gesondert planen. | follow-up / safety |
| Verwaltung/Politik/Gesellschaft | Als sensible Spezialkategorie spaeter gesondert planen. | follow-up / safety |

## 6. Entscheidungsempfehlung

Empfehlung:

```text
Taxonomy-Katalog als erste Content-/Location-Grundlage grundsaetzlich bestaetigen.
```

Begruendung:

- Die 14 Hauptkategorien sind breit genug fuer langfristige Weltplanung.
- Die Ebenenlogik trennt grosse Orte von kleinen Woertern und Deko.
- Die Waldlichtung wird klar vor Ueberladung geschuetzt.
- Sensible und systemisch komplexe Bereiche werden als spaetere Pruefungen
  markiert.
- Der Katalog ist deutlich als Backlog, nicht als Assetliste, geschrieben.

Einschraenkung:

Der Katalog darf nicht als finale ThemeIsland-Roadmap oder Assetauftrag
verwendet werden. Er ist eine Strukturgrundlage fuer spaetere Priorisierung,
Routing und Capability-Ableitung.

## 7. Empfohlene Folgeblocks

Sinnvolle naechste reine Planungsbloecke:

- `Phase 2G-M12 ThemeIsland Prioritization`
  - Welche Themeninseln kommen frueh, welche spaeter?
- `Phase 2G-M12-B Word-to-Island Routing Matrix`
  - Welche Wortkategorien landen auf welcher Insel oder im Backlog?
- `Phase 2G-M12-C Plot-Capability Derivation`
  - Welche Plot-Faehigkeiten ergeben sich aus den Hauptkategorien?
- `Phase 2G-M12-D Sensitive Content Representation Rules`
  - Krankenhaus, Religion, Politik, Polizei, Gericht, Gesundheit, Kultur und
    Gesellschaft sicher behandeln.
- `Phase 2G-M12-E Mobile And Clutter Rules For Small Objects`
  - Deko, Kleinteile, Moebel und Containerdetails mobile-tauglich begrenzen.

## 8. Weiterhin Blockiert

Weiterhin blockiert bleiben:

- Flutter-/Dart-Code,
- App-Integration,
- Tests,
- Spielassets,
- PNG-Aenderungen,
- finales Inselbild,
- finale ThemeIsland-Roadmap,
- finale Container-Systemarchitektur,
- Assetproduktion,
- ThemeIsland-Umsetzung,
- Word-to-Island-Routing-Matrix ohne Taxonomy-Review,
- Plot-Capability-Ableitung ohne Kategoriepruefung,
- `frame_started`,
- Bauzustaende.

## 9. Stop-Regeln

Stoppen, wenn:

- eine ThemeIsland-Roadmap ohne Taxonomy-Review erstellt werden soll,
- eine Word-to-Island-Routing-Matrix ohne Taxonomy-Review erstellt werden soll,
- Plot-Capabilities ohne Kategoriepruefung abgeleitet werden sollen,
- eine sensible Kategorie ohne eigene Darstellungs- und Safety-Regeln geplant
  wird,
- Deko- oder Kleinteile-Produktion ohne Mobile-/Clutter-Regeln geplant wird,
- technische, Verkehrs- oder Fahrzeuglogik ohne eigenes Systemkonzept geplant
  wird,
- Taxonomy-Begriffe als automatische Asset-Auftraege gelesen werden,
- grosse Kategorien auf die Waldlichtung gepresst werden sollen.

## 10. Naechster Erlaubter Schritt

Erlaubt:

- Taxonomy-Katalog dokumentarisch bestaetigen,
- ThemeIsland-Priorisierung planen,
- Word-to-Island-Routing-Matrix planen,
- Plot-Capability-Ableitung planen,
- Sensitive-Content-Regeln planen,
- Mobile-/Clutter-Regeln fuer Kleinteile und Deko planen.

Weiterhin nicht erlaubt:

- Code,
- Assets,
- App-Integration,
- finale Roadmap,
- finale ThemeIsland-Umsetzung,
- `frame_started`.

