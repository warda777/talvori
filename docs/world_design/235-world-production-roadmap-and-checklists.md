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
- Das buildable Waldlichtung-Template ist jetzt der naechste Blocker.

Interpretation:

Talvori hat eine starke Weltbasis als Preview- und Auswahlwelt. Der naechste
Schritt darf aber nicht wieder versuchen, BuildZones oder Fundamentfortschritt
auf unvorbereitete Naturassets zu legen.

## 4. Aktueller Hauptblocker

Hauptblocker:

Kein weiterer Bau-Code, bis das buildable Waldlichtung-Template freigegeben ist.

Benoetigt:

- buildable base asset,
- `foundation_started` overlay,
- `template.md` oder strukturierte Metadaten,
- Device-Screenshot,
- visuelle Entscheidung: behalten / nachbessern / verwerfen.

Freigabe bedeutet:

- Asset und Overlay passen perspektivisch zusammen.
- Die Bauflaeche wirkt natuerlich.
- `foundation_started` wirkt nicht wie UI oder Marker.
- BuildZone-Anker und Overlay-Anker sind dokumentiert.
- Der Test auf einem Zielgeraet wurde visuell geprueft.

## 5. Roadmap Phasen

| Phase | Aufgabe | Status | Ziel / Gate |
| --- | --- | --- | --- |
| Phase 2E-A | Buildable Waldlichtung Asset-Konzept | `fertig` | Konzept in `docs/world_design/236-buildable-forest-clearing-template-concept.md` dokumentiert. |
| Phase 2E-A2 | Buildable Waldlichtung Greybox/Layout | `fertig` | Funktionales Layout in `docs/world_design/237-buildable-forest-clearing-greybox-layout.md` dokumentiert. |
| Phase 2E-A3 | Multi-Scale World/Interior System | `fertig` | Detailstufen in `docs/world_design/238-multi-scale-world-and-interior-system.md` dokumentiert. |
| Phase 2E-A4 | World Scale and Dimension Rules | `fertig` | Massstab, Footprints und Referenzobjekte in `docs/world_design/239-world-scale-and-dimension-rules.md` dokumentiert. |
| Phase 2E-A5 | Private Island State System | `fertig` | State-/Modulsystem in `docs/world_design/240-private-island-state-system.md` dokumentiert. |
| Phase 2E-B | Asset-Erzeugung Waldlichtung buildable base | `generiert / in Pruefung` | Base-Asset existiert und ist in `template.md` dokumentiert; Device-Check und finale Freigabe fehlen. |
| Phase 2E-C | Asset-Erzeugung `foundation_started` Overlay | `generiert / vorgeprueft` | Overlay existiert und wurde visuell auf `base.png` geprueft; Device-Check und Freigabe fehlen. |
| Phase 2E-D | Asset-/Metadatenpruefung auf Geraet | `offen` | Device-Screenshot, Anker-/Bounds-Felder, Template-Status, Entscheidung. |
| Phase 2E-E | Kleiner Code-Slice mit freigegebenen Assets | blockiert | Erst erlaubt, wenn 2E-D freigegeben ist. |
| Phase 2F | `foundation_complete` | `geplant` / spaeter | Nach bewiesenem 2E-Slice. |
| Phase 2G | `frame_started` / Rohbau | `geplant` / spaeter | Erst nach belastbarer Fundamentlogik. |
| Phase 2H | `building_level_1` | `geplant` / spaeter | Erst nach Rohbau-Qualitaet und Balancing. |

Aktuell erlaubter naechster Schritt:

Phase 2E-D: Asset-/Metadatenpruefung auf Geraet vorbereiten. Dabei muessen
`base.png`, `foundation_started.png` und `template.md` in einer echten App- oder
Mock-Ansicht geprueft werden. Zu klaeren sind Device-Screenshot,
Anker-/Bounds-Felder, Template-Status und Freigabeentscheidung.

Grund:

`foundation_started` existiert und wurde visuell auf `base.png` vorgeprueft. Es
ist noch nicht freigegeben, weil Device-Check und Ankerdefinition fehlen.

Aktuell nicht erlaubt:

Phase 2E-E oder spaetere Bau-Code-Slices. Code bleibt blockiert, bis ein
buildable Waldlichtung-Template freigegeben ist.

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

Die ToDos bis einschliesslich Device-Screenshot sind Asset- und
Dokumentationsarbeit, kein Flutter-Code.

## 10. Stop-Regeln

Ein Schritt wird gestoppt, wenn:

- Asset nicht buildable wirkt,
- Overlay wie UI oder Marker wirkt,
- Bauflaeche nicht klar ist,
- Perspektive nicht passt,
- Status nicht `freigegeben` ist,
- Code versucht, fehlende Assets zu kaschieren,
- Scope groesser wird als geplant,
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
