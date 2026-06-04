# Talvori Welt: Asset-Produktion Und Buildable Island Templates

Stand: 2026-06-04

Dieses Dokument plant, wie Talvori kuenftig baubare Insel-Assets produzieren
muss, damit BuildZones, Fundamente, Gebaeude, Wege, Deko, Connectoren und
Ausbaustufen von Anfang an glaubwuerdig in die Welt integriert sind.

Es ist ein reines Planungsdokument. Es wurden keine Dart-/Flutter-Dateien,
keine Assets, keine Supabase-Daten, keine SQLite-/Vokabeldaten, keine SRS-Daten,
kein `word_progress`, keine Reward Bridge, keine Persistenz, keine Secrets und
keine Release-Artefakte geaendert.

Grundlagen:

- `docs/world_design/000-world-design-document-map.md`
- `docs/world_design/223-learning-to-building-loop.md`
- `docs/world_design/224-economy-balancing.md`
- `docs/world_design/225-in-world-learning-ui.md`
- `docs/world_design/226-build-progression-and-zones.md`
- `docs/world_design/232-onboarding-first-session.md`

## 1. Problem Aus Dem Phase-2E-Test

Der erste sehr kleine Phase-2E-Code-Slice wurde visuell geprueft und verworfen.
Das Problem lag nicht nur im Code, sondern in der Asset-Grundlage.

Beobachtung:

- Das bestehende Waldlichtung-Asset sieht als Natur-/Auswahlinsel schoen aus.
- Es ist aber nicht als baubare Insel vorbereitet.
- Nachtraeglich platzierte Fundament-Markierungen wirken wie UI- oder
  Flutter-Overlay.
- Der Baufortschritt verschmilzt nicht mit der Inseloberflaeche.
- Eine BuildZone auf einem fertigen Natur-PNG hat keine echte visuelle
  Verankerung.

Folge:

Wenn Talvori Baufortschritt einfach ueber fertige Inselbilder legt, wirkt der
Aufbau billig. Der Nutzer sieht dann nicht:

> Ich habe gelernt und meine Insel veraendert sich.

Sondern eher:

> Auf ein schoenes Bild wurde ein Marker gelegt.

Das widerspricht dem Kerngefuehl von Talvori Welt.

## 2. Grundentscheidung

Talvori braucht kuenftig nicht nur einzelne schoene Insel-PNGs, sondern
baubare Insel-Templates.

Ein baubares Insel-Template besteht aus:

- Basis-Insel-Asset,
- sichtbarer natuerlicher Leereflaeche,
- semantischen BuildZones,
- optionalen Bauzustands-Overlay-Assets,
- Path-/Docking-/Deko-Vorbereitung,
- `logicalBounds`,
- `hitTestShape`,
- `placementBounds`,
- Dokumentation der vorgesehenen Bauplaetze.

Grundregel:

Das sichtbare Asset und die semantischen Daten muessen gemeinsam geplant
werden. Ein BuildZone-Modell darf nicht erst nachtraeglich auf beliebige
Pixel gelegt werden.

## 2a. Production-Gate-Regel

Kein weiterer Bau-Code startet, bevor mindestens ein buildable
Waldlichtung-Template visuell geprueft ist.

Fuer Phase 2E muss mindestens vorhanden sein:

- buildable base asset,
- `foundation_started` overlay asset,
- Template-Metadaten,
- BuildZone-Anker,
- visueller Device-Check.

Wenn diese Dinge fehlen, wird nicht weiter implementiert. Ein schoenes
Natur-/Preview-Asset reicht nicht als Grundlage fuer neuen Bau-Code.

Dieses Gate schuetzt:

- visuelle Qualitaet,
- Implementierungsscope,
- BuildZone-Logik,
- spaetere Asset-Skalierung,
- Nutzerverstaendnis von Lernen -> Bauen.

## 2b. Professioneller Produktionsbezug

Talvori folgt in diesem Bereich einer Pre-Production-/Vertical-Slice-Denkweise.

Regel:

Erst Prozess und Zielqualitaet beweisen, dann Produktion skalieren.

Das bedeutet:

- zuerst ein vollstaendiges Beispiel sauber bauen,
- Qualitaet auf echten Geraetescreens pruefen,
- Metadaten und Asset-Schichten gemeinsam validieren,
- erst danach Varianten erzeugen,
- keine breite Asset-Produktion ohne bewiesenen Template-Prozess.

Waldlichtung ist deshalb nicht nur ein einzelnes Asset, sondern der
Qualitaetsbeweis fuer den Buildable-Island-Prozess.

## 2c. Asset-Produktionspipeline

Konkreter Ablauf fuer ein Buildable Template:

1. Template-Konzept schreiben.
2. Asset-Prompt erstellen.
3. Base-Asset erzeugen.
4. `foundation_started`-Overlay erzeugen.
5. Transparente PNGs validieren.
6. Perspektive und Licht pruefen.
7. BuildZone-/Overlay-Anker dokumentieren.
8. Device-Screenshot pruefen.
9. Erst dann Code-Slice vorbereiten.

Wichtig:

Der Code-Slice kommt am Ende der Pipeline, nicht am Anfang. Wenn ein Asset noch
visuell unklar ist, darf Flutter das Problem nicht mit Markern, Shapes oder
Schatten kaschieren.

## 2d. Definition Of Ready Fuer Buildable Assets

Ein buildable Asset darf erst in Code verwendet werden, wenn:

- PNG transparent ist,
- kein Space-Hintergrund enthalten ist,
- keine UI, Schrift oder Buttons enthalten sind,
- die Bauflaeche natuerlich wirkt,
- die Bauflaeche genug Platz fuer Fundament und spaeteres Haus hat,
- `foundation_started` perspektivisch passt,
- Docking-, Path- und Deko-Bereiche mitgedacht sind,
- Template-Metadaten existieren,
- Dateinamen klar sind.

Ein Asset ohne diese Readiness bleibt Konzept- oder Preview-Material.

## 2e. Definition Of Done Fuer Den Phase-2E-Asset-Test

Der Phase-2E-Asset-Test ist erst fertig, wenn:

- base und `foundation_started` optisch zusammenpassen,
- Overlay nicht wie UI wirkt,
- Bauflaeche auf Geraet lesbar ist,
- Waldlichtung weiterhin hochwertig aussieht,
- kein fertiges Haus sichtbar ist,
- BuildZone logisch zur sichtbaren Flaeche passt,
- Screenshot geprueft wurde,
- Entscheidung dokumentiert wurde: behalten / nachbessern / verwerfen.

Ohne diese Entscheidung bleibt das Template nicht freigegeben.

## 3. Anforderungen An Starter-Insel-Assets

Starter-Inseln muessen weiterhin natuerlich und attraktiv wirken, aber sie
brauchen klare bauliche Nutzbarkeit.

Anforderungen:

- genug freie zentrale Flaeche,
- sichtbare natuerliche Bauflaeche ohne fertige Gebaeude,
- keine Gebaeude, die spaeter erst gebaut werden sollen,
- klare 2.5D-/isometrische Perspektive,
- genug Platz fuer Fundament, kleines Haus, ersten Weg und kleine Deko,
- natuerliche Raender,
- vorbereitbare Docking-/Connector-Raender,
- keine starke Ueberladung mit Baeumen, Felsen oder Bueschen auf Bauplaetzen,
- gute Lesbarkeit in Weltuebersicht, Inselansicht und Bauplatzansicht,
- transparente Freistellung ohne Space-Hintergrund.

Wichtig:

Eine freie Bauflaeche darf nicht wie eine moderne Plattform, ein UI-Kreis oder
ein kuenstlich leerer Fleck aussehen. Sie muss wie eine natuerliche, spaeter
nutzbare Stelle der Insel wirken.

## 4. Bauzustaende Als Asset-Schichten

Talvori sollte Baufortschritt als getrennte visuelle Zustaende planen.

Langfristige Bauzustaende:

- `empty`
- `prepared` / gerodet / geebnet
- `foundation_started`
- `foundation_complete`
- `frame_started`
- `frame_complete`
- `building_level_1`
- `building_level_2`
- `living_building`
- `master_version`

Nicht alle Zustaende muessen sofort produziert werden.

Fuer den naechsten Phase-2E-Versuch reichen:

- `empty`
- `foundation_started`

Trotzdem muss die Asset-Produktion bereits wissen, wie spaetere Zustaende
anschliessen. `foundation_started` darf nicht so gezeichnet sein, dass spaeter
kein plausibles `foundation_complete` oder `building_level_1` mehr darauf
aufbauen kann.

Bauzustands-Roadmap:

| Phase | Benoetigte Asset-Schichten |
| --- | --- |
| Phase 2E | `base` + `foundation_started` |
| Phase 2F | `foundation_complete` |
| Phase 2G | `frame_started` |
| Phase 2H | `building_level_1` |
| Spaeter | `building_level_2`, `living_building`, `master_version` |

Die Roadmap ist kein Produktionsauftrag fuer alle Zustaende sofort. Sie ist ein
Kontrollrahmen, damit fruehe Overlays spaetere Ausbaustufen nicht blockieren.

## 5. Overlay-Asset-Strategie

Talvori muss entscheiden, wie Bauzustaende visuell entstehen.

Moeglichkeit A: generische Overlay-PNGs

- Ein Fundament-Overlay wird auf verschiedene Inseln gelegt.
- Vorteil: wartbar, wenig Asset-Aufwand.
- Risiko: wirkt schnell wie ein fremdes Objekt oder UI-Marker.

Moeglichkeit B: inselspezifische Overlay-PNGs

- Jede baubare Insel bekommt eigene Overlays fuer ihre Bauzustaende.
- Vorteil: beste 2.5D-Integration, Material und Perspektive passen zur Insel.
- Risiko: hoeherer Asset-Aufwand pro Insel.

Moeglichkeit C: kombinierter Ansatz

- Basis- und Fundamentzustaende sind inselspezifisch.
- Kleine Deko, Lichter oder spaetere Effekte koennen generischer sein.
- Vorteil: gute Qualitaet bei kontrolliertem Produktionsaufwand.

Leitentscheidung:

Fuer hochwertige 2.5D-Optik sind inselspezifisch abgestimmte Overlays
wahrscheinlich besser als generische Rechtecke. Der erste neue Phase-2E-Slice
sollte deshalb mindestens fuer Waldlichtung ein abgestimmtes
`foundation_started`-Asset nutzen.

## 6. BuildZone-Zu-Asset-Abgleich

Jedes baubare Asset braucht eine kurze technische Dokumentation.

Pro Insel muessen mindestens festgehalten werden:

- wo die `main_build_area` liegt,
- wo spaetere `secondary_build_area` liegen koennen,
- wo `decoration_area` moeglich ist,
- wo `path_area` moeglich ist,
- wo `blocked_area` liegt,
- wo `dockingPoints` liegen koennen,
- wo freie Flaechen liegen,
- welche Bereiche nur Deko oder Natur bleiben,
- welche Bereiche wegen Wasser, Felsen, Klippen oder Landmarken blockiert sind.

Wichtig:

Die visuelle Insel und die Zone-Daten muessen dieselbe Logik erzaehlen. Wenn
eine Stelle im Bild wie Fels oder Wasser aussieht, darf dort keine normale
BuildZone liegen.

## 7. Waldlichtung Als Neues Buildable Template

Die Waldlichtung soll fuer den neuen Phase-2E-Versuch nicht einfach als
aktuelles Naturbild weiterverwendet werden.

Geplant wird eine neue oder ueberarbeitete Variante:

`buildable starter island: forest_clearing`

Anforderungen:

- klarer Hauptbauplatz,
- Platz fuer `foundation_started`,
- Platz fuer spaeteres kleines Haus,
- Platz fuer ersten Weg oder Lichtpunkt,
- natuerliche Umrandung aus Gras, Baeumen, Bueschen und kleinen Steinen,
- wenige stoerende Felsen oder Baeume im Bauzentrum,
- Bauzentrum wirkt natuerlich vorbereitet, nicht kuenstlich leer,
- gut lesbare 2.5D-Perspektive,
- ausreichend ruhige Flaeche fuer Overlay-Zustaende.

Fuer Phase 2E benoetigte Asset-Schichten:

- `empty` / `base`: Waldlichtung mit natuerlichem freien Bauplatz.
- `foundation_started`: erste Steinplatten oder geglaettete Grundlage, exakt
  auf diese Bauflaeche abgestimmt.

Nicht erlaubt:

- fertiges Haus,
- komplette Waende,
- moderne Plattform,
- leuchtender UI-Kreis,
- generisches Rechteck,
- Fundament, das perspektivisch nicht zur Insel passt.

## 8. Ackerfeld Und Felseninsel Als Spaetere Vergleichs-Templates

Nach Waldlichtung sollten Ackerfeld und Felseninsel als Vergleichsinseln
geplant werden.

Ackerfeld:

- flacher,
- offener,
- groessere Bauflaeche,
- weniger BlockedAreas,
- klare, einfache fruehe Bauwirkung.

Felseninsel:

- kantiger,
- weniger Bauflaeche,
- mehr blockierte Bereiche,
- deutlichere Hoehen und Kanten,
- Fundament muss sich an felsige Oberflaeche anpassen.

Ziel:

Beide duerfen nicht einfach schoene Naturinseln ohne Bauplanung sein. Sie
sollen zeigen, dass BuildZones je nach Biom unterschiedlich funktionieren.

Skalierungsregel:

- Nicht sofort alle 20 Starter-Inseln buildable machen.
- Erst Waldlichtung beweisen.
- Dann Ackerfeld und Felseninsel als Vergleich.
- Erst wenn diese drei funktionieren, werden Template-Regeln auf weitere
  Inseln uebertragen.

Sonst entstehen zu viele Spezialassets ohne gesicherten Prozess.

## 9. Connector- Und Docking-Vorbereitung

Baubare Insel-Templates muessen spaetere Verbindungen mitdenken.

Regeln:

- Inselraender brauchen moegliche Andockstellen.
- Connectoren duerfen nicht frei schweben.
- Dockingbereiche muessen visuell am Inselrand plausibel sein.
- Spaetere Bruecken oder Felsstege brauchen Platz.
- Starter-Inseln brauchen mindestens zwei moegliche Dockingrichtungen.
- Community-Regionen brauchen groessere kuratierte Anschlussbereiche.

Dockingbereiche koennen visuell vorbereitet sein durch:

- kleine natuerliche Felskanten,
- flachere Randzonen,
- offene Ufer- oder Plateaustellen,
- dezente Felsnasen,
- spaeter nutzbare Brueckenanker ohne fertige Bruecke.

Nicht erlaubt:

- sichtbare technische Steckverbindungen,
- fertige Bruecken auf Starter-Inseln,
- Connector-Enden, die ohne Dockingpunkt im Space enden.

## 10. Zoom- Und Detailanforderungen

Ein Buildable Template muss in mehreren Betrachtungsebenen funktionieren.

Zoom-Ebenen:

- Weltuebersicht,
- Inselansicht,
- Bauplatzansicht,
- spaeter Gebaeudeansicht,
- spaeter Innenraum.

Anforderungen:

- In der Weltuebersicht muss die Insel als Silhouette lesbar bleiben.
- In der Inselansicht muss die Bauflaeche erkennbar sein.
- In der Bauplatzansicht darf die Flaeche nicht leer oder pixelig wirken.
- Bauzustaende muessen klein, aber klar unterscheidbar sein.
- Details duerfen den Bauplatz nicht ueberladen.
- Overlays muessen zur Perspektive, Beleuchtung und Materialitaet passen.

## 11. Produktionsregeln Fuer Imagegen/Codex

Kuenftige Prompts fuer baubare Starter-Inseln muessen explizit Buildability
enthalten.

Prompt-Regeln:

- immer freigestelltes PNG mit transparentem Hintergrund,
- keine UI,
- keine Schrift,
- keine Buttons,
- kein Space-Hintergrund,
- keine fertigen Gebaeude auf Starter-Inseln,
- klare 2.5D-/isometrische Perspektive,
- sichtbare natuerliche Bauflaechen einplanen,
- Bauflaechen nicht als moderne Plattform oder UI-Kreis zeichnen,
- natuerliche, aber funktionale Flaeche,
- genug Raum fuer Bauzustands-Overlays,
- separate Asset-Dateien fuer Basis und Bauzustaende,
- Material und Licht der Overlays muessen zur Basisinsel passen,
- Connector-/Docking-Raender subtil vorbereiten.

Beispiel-Prompt-Baustein:

> Erzeuge eine buildable Starter-Insel mit klarer natuerlicher
> `main_build_area`, die spaeter ein Fundament und ein kleines Haus aufnehmen
> kann. Die Flaeche soll organisch und naturbelassen wirken, aber ausreichend
> ruhig sein, damit ein `foundation_started`-Overlay perspektivisch exakt
> darauf passt.

## 12. Benennung Und Dateistruktur

Moegliche flache Dateistruktur:

```text
assets/images/world/starter_island_forest_clearing_buildable_empty.png
assets/images/world/starter_island_forest_clearing_foundation_started.png
assets/images/world/starter_island_forest_clearing_foundation_complete.png
assets/images/world/starter_island_field_buildable_empty.png
assets/images/world/starter_island_rock_buildable_empty.png
```

Alternative Ordnerstruktur:

```text
assets/images/world/buildable_islands/forest_clearing/base.png
assets/images/world/buildable_islands/forest_clearing/foundation_started.png
assets/images/world/buildable_islands/forest_clearing/foundation_complete.png
assets/images/world/buildable_islands/field/base.png
assets/images/world/buildable_islands/rock/base.png
```

Empfehlung:

Die Ordnerstruktur ist langfristig besser, weil sie Basis, Overlays,
Metadaten, spaetere Varianten und Debug-Dokumentation zusammenhaelt.

Moegliche Metadaten-Datei:

```text
assets/images/world/buildable_islands/forest_clearing/template.md
```

Diese Datei koennte spaeter beschreiben:

- BuildZones,
- Overlay-Anker,
- Dockingpunkte,
- logische Bounds,
- bekannte Asset-Grenzen,
- Produktionsnotizen.

Template-Metadaten sind Pflicht fuer jedes Buildable Template.

Eine `template.md` oder spaetere strukturierte Metadatei braucht mindestens:

- asset id,
- asset paths,
- intended build zones,
- overlay anchors,
- logical bounds,
- hit test shape,
- placement bounds,
- docking candidates,
- path candidates,
- blocked areas,
- notes for zoom/device checks,
- current status: `offen` / `in Arbeit` / `geprueft` / `fertig` /
  `verworfen`.

Statusmodell fuer Buildable Assets:

| Status | Bedeutung | Code-Nutzung |
| --- | --- | --- |
| `offen` | Idee ist notiert, aber noch nicht produziert | nicht erlaubt |
| `in Arbeit` | Prompt/Asset wird vorbereitet | nicht erlaubt |
| `generiert` | Asset liegt vor, ist aber nicht geprueft | nicht erlaubt |
| `geprueft` | visuell geprueft, Entscheidung offen oder positiv | nur nach expliziter Freigabe |
| `nachbessern` | Asset braucht Korrektur | nicht erlaubt |
| `fertig` | Asset ist geprueft und freigegeben | erlaubt |
| `verworfen` | Asset wird nicht verwendet | nicht erlaubt |

Regel:

Kein Asset mit Status `offen`, `in Arbeit`, `generiert` oder `nachbessern`
darf als Grundlage fuer neuen Code verwendet werden.

## 13. Verhaeltnis Zum Bestehenden Asset-Bestand

Bestehende Starter-Insel-Assets bleiben wertvoll.

Regeln:

- bestehende Starter-Insel-Assets nicht loeschen,
- bestehende Assets nicht automatisch ersetzen,
- bestehende Assets koennen als Natur-/Preview-/Auswahlassets nutzbar bleiben,
- Buildable Templates koennen neue Assets sein,
- erst visuell pruefen, ob neue Buildable Assets besser funktionieren,
- alte Auswahlassets duerfen weiterhin im World Canvas erscheinen, solange noch
  kein baubarer Modus aktiv ist.

Unterscheidung:

- Preview-Asset: zeigt die Insel als schoene Auswahloption.
- Buildable Base: zeigt dieselbe oder aehnliche Insel mit vorbereitetem
  Bauplatz.
- Build-State Overlay: zeigt einen konkreten Bauzustand auf einer BuildZone.

## 14. Phase-2E-Neuausrichtung

Vor einem neuen Phase-2E-Code-Slice muss zuerst mindestens ein buildable
Waldlichtung-Template geplant und erzeugt werden.

Verbindliche Phase-2E-Asset-Entscheidung:

Fuer den naechsten Versuch wird nicht das alte Naturasset bebaut.

Stattdessen wird ein neues Buildable-Waldlichtung-Template genutzt:

- `base`,
- `foundation_started`.

Optional spaeter:

- `foundation_complete`,
- `frame_started`,
- `building_level_1`.

Neuer Phase-2E-Ablauf:

1. Buildable Waldlichtung-Asset planen.
2. `empty`/`base` und `foundation_started`-Overlay definieren.
3. Im Code nur diese vorbereiteten Assets nutzen.
4. BuildZone referenziert echte Bauflaeche.
5. Mock-Aufgabe `3 einfache Woerter erkennen` erneut testen.
6. Sichtbarer Zustand `empty` -> `foundation_started` wirkt wie Teil der Insel.
7. Erst danach weitere Starter-Inseln oder Bauzustaende vorbereiten.

Scope bleibt:

- keine Persistenz,
- keine Supabase Writes,
- keine SQLite-/SRS-/`word_progress`-Aenderung,
- keine Reward Bridge,
- keine echte Wallet,
- keine Deko-Platzierung,
- keine Wege,
- keine Connectoren,
- keine Innenraeume,
- keine Gebaeudeauswahl.

Pflicht-Checkliste vor neuem Build-/World-Codeprompt:

- Gibt es ein passendes Planungsdokument?
- Gibt es ein freigegebenes buildable Template?
- Sind `base` und benoetigte Overlays vorhanden?
- Sind Metadaten vorhanden?
- Ist der Scope kleiner als ein Vertical Slice?
- Gibt es Device-Screenshots?
- Gibt es offene visuelle Blocker?
- Werden Supabase, SRS, Reward Bridge und Persistenz ausgeschlossen oder
  bewusst geplant?

Wenn eine dieser Fragen nicht beantwortet ist, wird der Codeprompt gestoppt
oder auf reine Planung/Asset-Produktion reduziert.

## 15. Risiken

Risiken:

- zu viel Aufwand pro Insel,
- zu viele Spezial-Overlays,
- generische Overlays wirken billig,
- Assets passen nicht zu BuildZones,
- spaetere 3D-/Renderer-Option wird verbaut,
- Buildable-Version sieht schlechter aus als Naturversion,
- zu fruehe Asset-Produktion ohne Template-Regeln,
- BuildZones werden weiter als UI-Flaechen statt als Weltstruktur behandelt,
- Asset-Dateien wachsen ohne klare Benennung oder Metadaten,
- Preview- und Buildable-Versionen wirken wie unterschiedliche Inseln.

Gegenmassnahmen:

- zuerst nur Waldlichtung als Template beweisen,
- `empty` und `foundation_started` reichen fuer den naechsten Test,
- Asset und BuildZone-Daten gemeinsam pruefen,
- Metadaten pro Buildable Template dokumentieren,
- Preview-Asset und Buildable Base visuell nah beieinander halten,
- keine generischen Rechteck-Overlays fuer den ersten hochwertigen Test.

## 16. Offene Fragen

Offene Fragen:

- Soll Waldlichtung ein neues Buildable Base-Asset bekommen oder reicht eine
  ueberarbeitete Variante des bestehenden Motivs?
- Werden Bauzustands-Overlays pro Insel erzeugt oder teilweise als generische
  Module wiederverwendet?
- Wie genau werden Overlay-Anker in Metadaten beschrieben?
- Soll die App beim Wechsel in den Bauplatzmodus vom Preview-Asset auf das
  Buildable Base-Asset umschalten?
- Wie stark duerfen Preview-Asset und Buildable Base visuell voneinander
  abweichen?
- Welche Dateistruktur wird vor der ersten neuen Asset-Erzeugung verbindlich?

## 17. Akzeptanzkriterien

Dieses Dokument ist gut, wenn:

- klar ist, warum der erste Phase-2E-Slice optisch nicht funktioniert hat,
- klar ist, warum baubare Insel-Templates noetig sind,
- klar ist, welche Asset-Schichten benoetigt werden,
- klar ist, wie Waldlichtung neu als Buildable Template gedacht wird,
- Connectoren, Dockingpunkte, BuildZones und Zoom beruecksichtigt sind,
- ein neuer Asset-Erzeugungs-Prompt ableitbar ist,
- vor neuem Code keine unvorbereiteten Naturassets mehr bebaut werden,
- Production-Gate definiert ist,
- Definition of Ready und Definition of Done vorhanden sind,
- Statusmodell vorhanden ist,
- Roadmap fuer Bauzustaende vorhanden ist,
- Template-Metadaten Pflicht sind,
- klar ist, dass ohne freigegebenes buildable Asset kein neuer Bau-Code
  startet.
