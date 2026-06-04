# Talvori Welt: Production Roadmap Und Checklists

Stand: 2026-06-04

Dieses Dokument ist die zentrale Produktionskontrolle fuer Talvori Welt. Es
ordnet Roadmap, ToDos, Gates und Checklisten, damit vor weiteren World-Schritten
klar ist, was erlaubt, blockiert oder noch nur Planung ist.

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
- `docs/world_design/234-asset-production-and-buildable-island-templates.md`
- `docs/220-talvori-world-professional-game-architecture-research.md`
- `docs/221-talvori-world-build-and-expansion-architecture.md`
- `docs/222-talvori-world-game-system-master-plan.md`

## 1. Zweck Des Dokuments

Dieses Dokument dient als zentrale Produktionskontrolle fuer Talvori Welt.

Es soll:

- Roadmap, ToDos, Gates und Checklisten buendeln,
- Abweichungen vom Plan frueh sichtbar machen,
- verhindern, dass Code auf unvollstaendige Planung oder nicht freigegebene
  Assets gebaut wird,
- vor jedem groesseren Codex-Prompt geprueft werden,
- klar markieren, was als naechstes erlaubt oder blockiert ist.

Merksatz:

> Kein neuer World-Code ohne fuehrendes Dokument, freigegebene Assets und
> kleinen Scope.

## 2. Statusmodell

Statuswerte:

| Status | Bedeutung | Code erlaubt? | Nur Planung? | Stop-Regel |
| --- | --- | --- | --- | --- |
| `offen` | Idee oder Aufgabe ist erkannt, aber noch nicht ausgearbeitet. | nein | ja | Code stoppen. |
| `in Arbeit` | Konzept, Asset oder Dokument wird gerade bearbeitet. | nein | ja | Code stoppen, bis Ergebnis vorliegt. |
| `geplant` | Konzept ist beschrieben, aber noch nicht produziert oder geprueft. | nur fuer Docs/kleine Vorbereitung | ja | Produktions- oder Code-Scope pruefen. |
| `generiert` | Asset oder Material wurde erzeugt, aber noch nicht geprueft. | nein | eingeschraenkt | Erst Qualitaetspruefung. |
| `geprueft` | Ergebnis wurde geprueft; Entscheidung oder Freigabe kann folgen. | nur nach ausdruecklicher Freigabe | ja | Offene Maengel klaeren. |
| `nachbessern` | Ergebnis passt noch nicht. | nein | ja | Code stoppen, Asset/Plan ueberarbeiten. |
| `freigegeben` | Ergebnis ist fuer den naechsten Schritt nutzbar. | ja, wenn Scope passt | ja | Weiter nur nach Checkliste. |
| `fertig` | Schritt ist abgeschlossen und dokumentiert. | ja, wenn abhaengige Gates erfuellt sind | ja | Keine offenen Blocker. |
| `verworfen` | Ergebnis wird nicht weiter genutzt. | nein | nur fuer Ableitung | Nicht als Grundlage verwenden. |

Regeln:

- Code ist nur auf Basis von `freigegeben` oder `fertig` erlaubt.
- `offen`, `in Arbeit`, `generiert`, `nachbessern` und `verworfen` blockieren
  Code.
- `geplant` erlaubt weitere Planung, aber keinen produktionsnahen Code.
- `geprueft` ist ein Zwischenstatus; die Entscheidung muss dokumentiert werden.

## 3. Aktueller Gesamtstand

Aktueller Stand der Talvori-Welt-Produktion:

- Phase 1 Home-Zentrale ist abgeschlossen.
- Phase 2 Local World Entry ist vorhanden.
- Starter- und Community-Inseln sind als Preview-/World-Assets vorhanden.
- Das Connector-Kit ist vorhanden, aber nicht aktiv genutzt.
- DockingPoints sind lokal/mock vorbereitet.
- Der erste Phase-2E-Code-Slice wurde visuell verworfen, weil die Asset-
  Grundlage nicht buildable war.
- Das buildable Waldlichtung-Template wurde fuer den kleinen Phase-2E-E-Slice
  freigegeben.
- Phase 2E-E wurde als lokaler Mock-Slice umgesetzt und mit Commit
  `c82880e4 feat: polish forest clearing foundation guidance` abgeschlossen.
- Phase 2F (`foundation_complete`) wurde als lokaler Mock-Slice umgesetzt,
  auf Geraet geprueft und mit Commit
  `b13d2162 fix: refine foundation complete guidance flow` abgeschlossen.
- Phase 2G (`frame_started` / Rohbau) wurde als reiner Planungsblock in
  `docs/world_design/243-frame-started-plan.md` gestartet.
- Der Asset-Prompt-/Freigabeblock fuer `frame_started` wurde in
  `docs/world_design/244-frame-started-asset-prompt.md` vorbereitet.
- Die lokale Sichtpruefung des aktuellen `frame_started.png`-Kandidaten hat
  gezeigt, dass ungefaehres Zentrum-Alignment fuer Rohbau nicht reicht.
- Der zusaetzliche Anchor-/Alignment-Definitionsblock fuer Phase 2G wurde in
  `docs/world_design/245-build-alignment-and-anchor-system.md` gestartet.
- Der naechste Blocker betrifft Anchor-/Footprint-Freigabe,
  `frame_started`-Nachbesserung, Phase-2G-Code und jede groessere Bau-,
  Lern-, Reward-, Persistenz-, Sound-/FX- oder Expansion-Architektur.

Interpretation:

Talvori hat eine starke Weltbasis als Preview- und Auswahlwelt. Phase 2E-E
beweist als lokaler Proof-of-Concept, dass freigegebene buildable Assets,
Layering, lokaler BuildState und einfache Nutzerfuehrung zusammen funktionieren.
Der naechste Schritt darf daraus aber noch keine vollstaendige Bau-, Lern-,
Reward- oder Persistenzarchitektur ableiten.

## 4. Aktueller Hauptblocker

Hauptblocker:

Phase 2F ist abgeschlossen. Phase 2G ist nur als Planung, Asset-Prompt-
Vorbereitung und Anchor-/Alignment-Definitionsblock gestartet. Der aktuelle
`frame_started.png`-Kandidat ist nicht freigegeben. `frame_started` / Rohbau
darf nicht automatisch als Asset oder Code weitergefuehrt werden. Vor jeder
weiteren Asset-Freigabe muessen Anchor-, Footprint-, Support- und
Debug-Overlay-Regeln angewendet werden. Asset-Erzeugung/Nachbesserung und Code
brauchen danach jeweils eigene Freigabe und eine erneute Pruefung der Gates.

Vor jedem Phase-2G-Code oder jedem Ausbau ausserhalb des abgeschlossenen
lokalen Phase-2F-Mock-Slices muss erneut geprueft werden:

- Professional Game Development Research Gate,
- Build-Feedback-Konzept,
- Asset-Produktionsregeln,
- State-/Modulsystem,
- Scale-/Dimension-Regeln,
- keine Erweiterung des Scopes ohne Dokumentation.

Die abgeschlossenen Freigaben aus Phase 2E-D/2E-E und Phase 2F gelten nur fuer
die kleinen lokalen Mock-Slices: Waldlichtung, `main_build_area`, lokaler
Zustand `empty -> foundation_started -> foundation_complete` und lokale Anzeige
von `base.png` + `foundation_started.png` oder `base.png` +
`foundation_complete.png`.

## 5. Roadmap Phasen

| Phase | Aufgabe | Status | Ziel / Gate |
| --- | --- | --- | --- |
| Phase 2E-A | Buildable Waldlichtung Asset-Konzept | `fertig` | Konzept in `docs/world_design/236-buildable-forest-clearing-template-concept.md` dokumentiert. |
| Phase 2E-A2 | Buildable Waldlichtung Greybox/Layout | `fertig` | Funktionales Layout in `docs/world_design/237-buildable-forest-clearing-greybox-layout.md` dokumentiert. |
| Phase 2E-A3 | Multi-Scale World/Interior System | `fertig` | Detailstufen in `docs/world_design/238-multi-scale-world-and-interior-system.md` dokumentiert. |
| Phase 2E-A4 | World Scale and Dimension Rules | `fertig` | Massstab, Footprints und Referenzobjekte in `docs/world_design/239-world-scale-and-dimension-rules.md` dokumentiert. |
| Phase 2E-A5 | Private Island State System | `fertig` | State-/Modulsystem in `docs/world_design/240-private-island-state-system.md` dokumentiert. |
| Phase 2E-A6 | Build Feedback Animation/Sound | `fertig` | Build-Feedback, minimale Animation, vorbereitete Effekt-ID und Sound-Grenzen in `docs/world_design/241-build-feedback-animation-and-sound.md` dokumentiert. |
| Phase 2E-B | Asset-Erzeugung Waldlichtung buildable base | `generiert / in Pruefung` | Base-Asset existiert und ist in `template.md` dokumentiert; Device-Check und finale Freigabe fehlen. |
| Phase 2E-C | Asset-Erzeugung `foundation_started` Overlay | `generiert / vorgeprueft` | Overlay existiert und wurde visuell auf `base.png` geprueft; Device-Check und Freigabe fehlen. |
| Phase 2E-D | Asset-/Metadatenpruefung auf Geraet | `freigegeben` | Isolierter Widget-Test-Harness und temporaere visuelle Preview sind brauchbar; Anker-/Bounds-Werte sind dokumentiert; Freigabe gilt nur fuer den kleinen Phase-2E-E-Mock-Slice. |
| Phase 2E-E | Kleiner Code-Slice mit freigegebenen Assets | `fertig / lokaler Mock-Slice bestanden` | Lokale Anzeige von `base.png` + `foundation_started.png` ist umgesetzt. `main_build_area` auf Waldlichtung ist umgesetzt. Lokaler Zustand `empty -> foundation_started` ist umgesetzt. Nutzerfuehrung mit Hinweistext und kontrastreichem Fokus ist umgesetzt. Minimaler Feedback-Moment mit vorbereiteter ID `build.foundation.started` ist umgesetzt. Visuell auf Geraet geprueft. Keine ausgeschlossenen Systeme wurden beruehrt: keine Persistenz, Supabase Writes, SRS-/`word_progress`-Aenderung, Reward Bridge, echte Ressourcenlogik, Expansion, PlacedItems, Interiors/ObjectDetail, produktive Bau-/Lernlogik, Sounddatei oder Audio-Implementierung. Commit: `c82880e4 feat: polish forest clearing foundation guidance`. |
| Phase 2F | `foundation_complete` | `fertig / lokaler Mock-Slice bestanden` | Lokale Mock-Erweiterung `foundation_started -> foundation_complete` ist umgesetzt. Anzeige `base.png` + `foundation_complete.png` ist umgesetzt; `foundation_complete` ersetzt `foundation_started` visuell ohne dauerhaftes Stapeln. Direkter Tap-Flow funktioniert. Grosse Snackbar wurde entfernt. Kleine In-World-Labels `Fundament begonnen` und `Fundament fertig` bleiben. Label-Abstand wurde verbessert und auf Geraet geprueft. Feedback-ID `build.foundation.complete` ist vorbereitet, ohne Sound-/FX-Implementierung. Keine ausgeschlossenen Systeme wurden beruehrt: keine Persistenz, Supabase Writes, SRS-/`word_progress`-Aenderung, Reward Bridge, Ressourcenlogik, Sound-/FX-Schicht, Audio/Sounddateien, Expansion, PlacedItems, Interiors/ObjectDetail oder produktive Bau-/Lernlogik. Commit: `b13d2162 fix: refine foundation complete guidance flow`. |
| Phase 2G | `frame_started` / Rohbau | `Anchor-/Alignment-Block erforderlich / Asset nicht freigegeben` | Reiner Planungsblock in `docs/world_design/243-frame-started-plan.md`; Asset-Prompt-/Freigabeblock in `docs/world_design/244-frame-started-asset-prompt.md`; Anchor-/Footprint-Regeln in `docs/world_design/245-build-alignment-and-anchor-system.md`. Der aktuelle `frame_started.png`-Kandidat ist vorhanden, aber nicht freigegeben. Naechster erlaubter Schritt ist Anchor-basierte Prompt-/Asset-Nachbesserung und erneute Alignment-Preview, nicht Code. |
| Phase 2H | `building_level_1` | `geplant` / spaeter | Erst nach Rohbau-Qualitaet und Balancing. |

Aktuell erlaubter naechster Schritt:

Phase 2E-E ist abgeschlossen und committed:
`c82880e4 feat: polish forest clearing foundation guidance`.

Phase 2F ist abgeschlossen und committed:
`b13d2162 fix: refine foundation complete guidance flow`.

Phase 2G ist als Planungsblock gestartet:
`docs/world_design/243-frame-started-plan.md`.

Der Asset-Prompt-/Freigabeblock fuer `frame_started` ist vorbereitet:
`docs/world_design/244-frame-started-asset-prompt.md`.

Der Anchor-/Alignment-Definitionsblock fuer `frame_started` ist gestartet:
`docs/world_design/245-build-alignment-and-anchor-system.md`.

Der naechste sinnvolle Schritt ist nicht Phase-2G-Code und nicht
Asset-Freigabe, sondern Anchor-basierte Nachbesserung: Prompt/Asset auf
konkrete Support-Punkte, Footprint-Polygone und Debug-Overlay-Gates
ausrichten. Der aktuelle `frame_started.png`-Kandidat bleibt blockiert.

Vor Phase 2G oder jedem weiteren Ausbau ausserhalb des abgeschlossenen lokalen
2F-Mock-Slices muss erneut geprueft werden:

- Professional Game Development Research Gate,
- Build-Feedback-Konzept,
- Asset-Produktionsregeln,
- State-/Modulsystem,
- Scale-/Dimension-Regeln,
- keine Erweiterung des Scopes ohne Dokumentation.

Entscheidung nach Phase 2E-E:

Phase 2E-E ist als lokaler Proof-of-Concept fuer die buildable Waldlichtung
bestanden.

Der Slice beweist nur:

- Asset-Layering mit `base.png` + `foundation_started.png`,
- lokale BuildState-Umschaltung `empty -> foundation_started`,
- basic Nutzerfuehrung mit Hinweistext und kontrastreichem Fokus,
- minimaler visueller Feedback-Moment mit vorbereiteter ID
  `build.foundation.started`.

Der Slice beweist noch nicht:

- vollstaendige Bauarchitektur,
- Balancing,
- Reward Bridge,
- Persistenz,
- Kategorie-System,
- Sound-/FX-System,
- Expansion oder PlacedItems.

Offene Punkte nach abgeschlossenem Phase-2F-Mock-Slice:

- `foundation_complete` ist nur als lokaler Mock-Slice abgeschlossen;
  produktive Bau-/Lernlogik bleibt blockiert.
- Phase 2G (`frame_started` / Rohbau) ist geplant und als Asset-Prompt
  vorbereitet; ein lokaler `frame_started.png`-Kandidat existiert, ist aber
  wegen unzureichend exakter Anchor-/Footprint-Passung nicht freigegeben.
- Anchor-/Support-Punkte fuer `foundation_complete` sind in
  `docs/world_design/245-build-alignment-and-anchor-system.md` definiert und
  muessen vor weiterer Asset-Freigabe angewendet werden.
- Es gibt kein echtes Bau-/Lern-/Reward-System.
- Es gibt keine Persistenz.
- Es gibt keine Ressourcenlogik.
- Es gibt keine Sound-/FX-Schicht.
- Es gibt kein Expansion-/PlacedItem-/Interior-System.
- Es gibt keine Cloud-/Supabase-Logik.

Aktuell nicht erlaubt / weiterhin blockiert:

- keine Persistenz,
- keine Supabase Writes,
- keine SRS-/`word_progress`-Aenderung,
- keine Reward Bridge,
- keine echte Ressourcenlogik,
- keine Expansion,
- keine PlacedItems,
- keine Interiors/ObjectDetail,
- keine produktive Bau-/Lernlogik,
- keine Sounddateien oder Audio-Implementierung,
- keine Phase-2G-Asset-Freigabe ohne Anchor-/Debug-Overlay-Check,
- keine Phase-2G-Asset-Erzeugung oder Nachbesserung ohne Bezug auf die
  Anchor-/Footprint-Regeln,
- kein Phase-2G-Code ohne Asset, Preview, Device-Check und Freigabe,
- kein weiterer Bau-Code ausserhalb der abgeschlossenen lokalen Mock-Slices.

## 6. Dokument-Abhaengigkeiten

Fuehrende Abhaengigkeiten:

- Economy/Balancing muss vor Reward/Baukosten beachtet werden.
- In-World-Learning UI muss vor Aufgaben-UI beachtet werden.
- Build Progression/Zones muss vor BuildZones/Items beachtet werden.
- Onboarding muss vor erstem Nutzerflow beachtet werden.
- Asset Production muss vor Bau-Code beachtet werden.
- Cloud, Monetization und Social sind noch nicht ausgearbeitet und duerfen
  nicht gebaut werden.

Konsequenzen:

- Kein Reward- oder Ressourcen-Code ohne `224`.
- Keine Aufgabenkarte ohne `225`.
- Keine BuildZone-/Item-Logik ohne `226`.
- Kein erster Nutzerfluss ohne `232`.
- Kein neuer Bau-Code ohne `234`.
- Keine Cloud Writes ohne spaeteres Cloud-/Persistenzdokument.
- Keine Monetarisierung ohne spaeteres Monetarisierungsdokument.
- Keine Social-Funktion ohne spaeteres Social-/Moderationsdokument.

## 7. Asset-Freigabe-Checkliste

Vor Asset-Nutzung pruefen:

- PNG transparent.
- Kein Space-Hintergrund.
- Keine UI, Schrift oder Buttons.
- Bauflaeche wirkt natuerlich.
- Base und Overlay passen perspektivisch.
- `logicalBounds` sind dokumentiert.
- BuildZone-Anker sind dokumentiert.
- Aufbau-Assets haben `referenceState`, `build_center`, Support-Anker,
  `safe_inner_build_polygon` und `max_frame_footprint_polygon`.
- Support-Fuesse/Kontaktpunkte sitzen sichtbar auf dem Referenzzustand und
  nicht ausserhalb des zulaessigen Fundaments.
- Debug-Overlay-Pruefung mit Referenzzustand wurde bestanden.
- `foundation_started` wirkt nicht wie Overlay.
- Device-Screenshot wurde geprueft.
- Status ist `freigegeben`.

Wenn ein Punkt fehlt, bleibt das Asset blockiert.

## 8. Code-Freigabe-Checkliste

Vor jedem World-Codeprompt pruefen:

- Passendes Planungsdokument existiert.
- Verwendete Assets sind freigegeben.
- Template-Metadaten sind vorhanden.
- Scope ist klein genug.
- Keine offenen visuellen Blocker.
- Keine Supabase Writes, ausser explizit geplant.
- Keine SRS-/`word_progress`-Aenderung, ausser explizit geplant.
- Keine Reward Bridge, ausser explizit geplant.
- Keine Persistenz, ausser explizit geplant.
- Tests oder Device-Check sind definiert.

Wenn der Prompt versucht, fehlende Assets durch Code zu kaschieren, wird der
Prompt gestoppt oder auf Asset-/Planungsarbeit zurueckgefuehrt.

## 9. Phase-2E ToDo-Liste

Konkrete ToDos:

- Buildable Waldlichtung-Konzept finalisieren.
- Asset-Prompt fuer base erstellen.
- Base-Asset erzeugen.
- Alpha/Transparenz pruefen.
- `foundation_started`-Prompt erstellen.
- Overlay-Asset erzeugen.
- Overlay auf base visuell pruefen.
- `template.md` erstellen.
- BuildZone-Anker definieren.
- Device-Screenshot pruefen.
- Entscheidung dokumentieren.
- Erst dann Codeprompt formulieren.

Aktueller Schwerpunkt:

Die ToDos bis einschliesslich Device-Screenshot waren Asset- und
Dokumentationsarbeit und sind fuer Phase 2E-D erledigt.
Die lokale Device-Mock-Preview, der isolierte Widget-Test-Harness und die
Anker-/Bounds-Dokumentation sind erledigt. Die Freigabeentscheidung fuer Phase
2E-D ist dokumentiert. Phase 2E-E ist als kleiner lokaler Mock-Code-Slice
umgesetzt, visuell geprueft, bestanden und mit Commit
`c82880e4 feat: polish forest clearing foundation guidance` abgeschlossen.
Die Planung von Phase 2F (`foundation_complete` Konzept, Asset, Scope,
Feedback und Tests) ist mit
`docs/world_design/242-foundation-complete-plan.md` gestartet und fuer den
engen lokalen Mock-Slice abgeschlossen.
`foundation_complete.png` wurde erzeugt, lokal vorgeprueft, formal
freigegeben, als lokaler Phase-2F-Mock-Slice umgesetzt, auf Geraet geprueft
und mit Commit `b13d2162 fix: refine foundation complete guidance flow`
abgeschlossen. Phase 2G-Planung (`frame_started` / Rohbau) wurde mit
`docs/world_design/243-frame-started-plan.md` gestartet. Der
Asset-Prompt-/Freigabeblock wurde in
`docs/world_design/244-frame-started-asset-prompt.md` vorbereitet. Die
nachfolgende lokale Sichtpruefung des `frame_started.png`-Kandidaten hat einen
zusaetzlichen Anchor-/Alignment-Block erzwungen:
`docs/world_design/245-build-alignment-and-anchor-system.md`. Der naechste
offene Schritt ist Anchor-basierte Prompt-/Asset-Nachbesserung und erneute
Alignment-Preview. Asset-Freigabe und Code bleiben blockiert, bis Support-
Anker, Footprint, Preview, Device-Check, Freigabe und Tests definiert sind.

## 10. Stop-Regeln

Ein Schritt wird gestoppt, wenn:

- Asset nicht buildable wirkt,
- Overlay wie UI oder Marker wirkt,
- Bauflaeche nicht klar ist,
- Perspektive nicht passt,
- ein aufbauendes BuildAreaState-Asset nicht auf definierten Support-Ankern
  oder innerhalb des zulaessigen Footprints steht,
- Pfosten/Fuesse sichtbar ausserhalb des Referenzfundaments landen,
- kein Debug-Overlay-Check fuer ein aufbauendes Asset dokumentiert ist,
- Status nicht `freigegeben` ist,
- Code versucht, fehlende Assets zu kaschieren,
- Scope groesser wird als geplant,
- neue Nutzerfuehrung nicht ausreichend kontrastreich ist,
- Baufeedback nur als harter Bildwechsel ohne klaren Moment wirkt,
- Supabase beruehrt wird,
- SRS oder `word_progress` beruehrt werden,
- Reward Bridge beruehrt wird,
- Persistenz beruehrt wird.

Stoppen bedeutet:

- keine weitere Implementierung in diesem Block,
- Blocker benennen,
- naechste sichere Planungs- oder Asset-Aufgabe ableiten.

## 11. Update-Regel

Nach jedem Block muss dokumentiert werden:

- was geaendert wurde,
- welche Dateien betroffen sind,
- welcher Status sich geaendert hat,
- welche ToDos erledigt sind,
- welche ToDos offen bleiben,
- ob der naechste Schritt erlaubt oder blockiert ist.

Wenn ein Status geaendert wird, muss die Begruendung sichtbar sein.
Die Roadmap-Tabelle in Abschnitt 5 muss nach jedem relevanten Block aktiv
aktualisiert werden. Statusaenderungen duerfen nicht nur im Chat stehen,
sondern muessen im Dokument nachvollziehbar sein.

Nach jedem abgeschlossenen Planungs-, Asset- oder Codeblock wird committed.
Wenn nicht committed wird, muss der Grund dokumentiert werden. Kein neuer Block
startet mit unklarem oder dirty Arbeitsstand.

Beispiel:

```text
Phase 2E-B: generiert -> nachbessern
Grund: Bauflaeche wirkt zu kuenstlich und `foundation_started` passt nicht zur
Perspektive.
Naechster Schritt: Prompt fuer Base-Asset ueberarbeiten.
```

## 12. Professional Game Development Research Gate

Vor groesseren Entscheidungen zu Game Design, Weltarchitektur,
Asset-Produktion, Buildable Islands, Economy/Balancing, Retention,
Monetarisierung, Cloud/Backend, Social, Animation, Roadmap oder Code-Slices
muss geprueft werden:

- Wie wuerden professionelle Game-Entwickler oder erfahrene Studios dieses
  Problem typischerweise angehen?
- Gibt es bewaehrte Begriffe oder Methoden wie Prototype, Greybox/Blockout,
  Vertical Slice, Pre-Production, Production Gate, LiveOps, Economy Balancing,
  Level Design, Asset Pipeline, LOD oder Content Pipeline?
- Gibt es aktuelle Quellen, Artikel, Dokumentationen oder Best Practices, die
  fuer die Entscheidung relevant sind?
- Was davon passt zu Talvori?
- Was passt nicht zu Talvori?
- Welche konkrete Ableitung ergibt sich daraus fuer Talvori?

Regel:

Codex soll bei solchen Entscheidungen nicht nur raten. Wenn die Frage
professionelles Game Design, Asset-Produktion, Economy, Retention,
Monetarisierung, Social, Cloud oder technische Architektur betrifft, soll Codex
nach Moeglichkeit aktuelle Quellen recherchieren oder klar dokumentieren, wenn
keine Recherche durchgefuehrt wurde.

Jede research-informed Entscheidung haelt kurz fest:

- recherchierte Orientierung / Quelle / Methode,
- Ableitung fuer Talvori,
- Entscheidung,
- Risiken,
- was dadurch erlaubt ist,
- was dadurch blockiert ist.

Beispiele:

- Vor finaler Asset-Produktion pruefen: Wie arbeiten Profis mit
  Greybox/Blockout, Asset Pipeline und Vertical Slice?
- Vor Balancing pruefen: Wie arbeiten Aufbau-/Mobile-Games mit Quellen,
  Senken, Progression und Anti-Farming?
- Vor Monetarisierung pruefen: Wie decken Lern-/Mobile-Produkte Kosten, ohne
  Pay-to-Win zu werden?
- Vor Cloud-Entscheidung pruefen: Was muss lokal bleiben, was muss
  server-authoritative sein?
- Vor Social pruefen: Wie werden sichere Kommunikation, Moderation und
  Missbrauchsschutz geplant?

Stop-Regel:

Wenn eine groessere Entscheidung getroffen werden soll, aber kein
Professional-Research-Gate durchgefuehrt wurde, wird der Schritt gestoppt oder
auf einen Recherche-/Planungsblock zurueckgefuehrt.

## 13. Prueffragen Vor Jedem Neuen Chat/Codex-Prompt

Vor jedem neuen Chat oder Codex-Prompt pruefen:

- Was ist das Ziel?
- Welches Dokument ist fuehrend?
- Sind Abhaengigkeiten erfuellt?
- Ist ein Asset freigegeben?
- Ist der Scope klein?
- Gibt es einen Testplan?
- Wird etwas an Datenlogik, SRS, Reward oder Cloud geaendert?
- Wurde geprueft, wie professionelle Game-Entwickler dieses Problem loesen
  wuerden?
- Ist eine aktuelle Recherche noetig?
- Wurde die Ableitung fuer Talvori dokumentiert?
- Ist ein Commit danach geplant?

Wenn die Antwort auf eine dieser Fragen unklar ist, muss der Prompt zuerst
praezisiert oder als Planungsblock formuliert werden.

## 14. Akzeptanzkriterien

Dieses Dokument ist gut, wenn:

- klar ist, was als naechstes erlaubt ist,
- klar ist, was blockiert ist,
- Phase 2E nicht wieder auf unvorbereiteten Assets startet,
- ToDos und Statuswerte vorhanden sind,
- Code-Gates und Asset-Gates klar sind,
- das Professional-Research-Gate vor groesseren Entscheidungen sichtbar ist,
- es als Checkliste vor neuen Prompts nutzbar ist.
