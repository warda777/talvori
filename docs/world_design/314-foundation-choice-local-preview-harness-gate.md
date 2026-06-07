# M15-C: Foundation Choice Local Preview Harness Gate

Stand: 2026-06-07

Status: `Harness Gate gestartet / keine Harness-Implementierung`

## 1. Ziel

Dieses Dokument prueft, ob ein spaeterer isolierter lokaler Preview-Harness fuer
`FoundationChoicePreview` sinnvoll, sicher und eng genug waere.

M15-C ist ein reiner Dokumentations- und Gate-Planungsblock. Es ist keine
Harness-Implementierung, keine Testfreigabe, keine App-Integration, keine
Home-/Onboarding-/World-Routing-Integration, keine Runtime-Konfiguration, keine
Persistenz, keine Assetfreigabe und keine Implementierungsfreigabe.

## 2. Gepruefte Grundlage

Fuehrend fuer M15-C sind:

- `lib/features/world/local_world/ui/widgets/foundation_choice_preview.dart`,
- `docs/world_design/313-foundation-choice-preview-code-review.md`,
- `docs/world_design/312-foundation-choice-final-pre-implementation-checklist.md`,
- `docs/world_design/311-foundation-choice-prompt-visual-review.md`,
- `docs/world_design/310-foundation-choice-minimal-slice-prompt-draft.md`,
- `docs/world_design/309-foundation-choice-implementation-gate.md`,
- `docs/world_design/previews/m15_b_foundation_choice_code_review/01_code_scope_review_map.png`,
- `docs/world_design/235-world-production-roadmap-and-checklists.md`,
- `assets/images/world/buildable_islands/forest_clearing/template.md`.

M15-B bestaetigt den isolierten Widget-Slice als scope-konform, markiert aber
spaetere Device-, Visual- und Harness-Gates als Voraussetzung vor jeder
Integration.

## 3. Harness-Ziel

Ein spaeterer Harness waere nur eine lokale isolierte Sichtpruefung. Er waere:

- kein Nutzerfeature,
- kein echtes Onboarding,
- keine App-Integration,
- keine Home-/Onboarding-/World-Routing-Integration,
- keine App-Route,
- keine Persistenz,
- keine Runtime-Konfiguration,
- keine Navigation,
- keine Assetproduktion,
- keine automatische Wortplatzierung,
- kein Build-State,
- kein `frame_started`.

Ein spaeterer Harness duerfte keine Screenshots oder Tests erzeugen, ausser ein
spaeterer Prompt gibt Screenshots oder Tests ausdruecklich frei.

## 4. Erlaubter Spaeterer Harness-Scope

Falls ein spaeterer Block ausdruecklich freigegeben wird, duerfte ein Harness
hoechstens:

- `FoundationChoicePreview` isoliert rendern,
- Small Phone Portrait simulieren oder manuell pruefen,
- Standard Phone Portrait pruefen,
- Large Phone Portrait optional pruefen,
- Text-Containment pruefen,
- Tap-Zonen pruefen,
- Safe Exit pruefen,
- `spaeter aenderbar` pruefen,
- Tali/Vori-Karte auf Ueberdeckung pruefen,
- Auswahlzustand lokal pruefen.

Nicht erlaubt:

- Home-Integration,
- Onboarding-Integration,
- World-Routing,
- App-Route,
- Persistenz,
- Runtime-Konfiguration,
- Assets,
- Screenshots ohne spaetere Freigabe,
- Tests ohne spaetere Freigabe,
- automatische Wortplatzierung,
- `frame_started`.

## 5. Harness-Gate-Matrix

| Harness Area | Purpose | Allowed Later Check | Risk | Required Gate | Blocked Now |
| --- | --- | --- | --- | --- | --- |
| Small Phone Portrait | kritischster mobiler Leitfall | isolierte Sichtpruefung von Stack, Scroll und Buttons | Karten oder Hilfstext werden zu eng | eigener Harness-/Manual-Preview-Prompt | Screenshot, Test, App-Route |
| Standard Phone Portrait | Normalfall pruefen | Layout, Textgewicht, Tap-Abstand | Preview wirkt zu final | lokaler Harness-Gate | Integration |
| Large Phone Portrait | groessere Phones absichern | maxWidth, Lesbarkeit, keine Zusatzkomplexitaet | breiter Screen wirkt wie finale UI | optionaler Device-Check | finale UI |
| Text Containment | Karten/Rahmen/Panels pruefen | Banner, Tali/Vori, Cards, Actions, Resultpanel | Text laeuft aus oder ueberlappt | Visual-Harness-Freigabe | Codeaenderung aus M15-C |
| Tap Targets | Interaktion plausibel pruefen | Karten, Confirm, Safe Exit | Buttons zu klein oder zu dicht | spaeterer Manual-/Harness-Check | Widget-Test aus M15-C |
| Tali/Vori Collision | Companion darf nichts verdecken | Karte bleibt oberhalb, kein Overlay | Companion verdeckt Karten oder Buttons | Device-/Accessibility-Gate | Overlay-Implementierung |
| Safe Exit | ruhiger Ausstieg sichtbar | `Spaeter entscheiden` bleibt erreichbar | Safe Exit wirkt versteckt | Device-Check | echtes Onboarding |
| Later Changeable Note | Reversibilitaet sichtbar | `Spaeter aenderbar` bleibt lesbar | Auswahl wirkt irreversibel | Copy-/Device-Check | Persistenz |
| Local Selection State | nur Preview-State pruefen | Auswahl lokal setzen und zuruecksetzen | State wird Persistenz gelesen | Code-Review vor Harness | DB/Supabase/Runtime-State |
| Semantics / Accessibility | nicht nur Farbe | Semantics, Check-Icon, Fokusfolge spaeter pruefen | Auswahl nur farbcodiert | Accessibility-Gate | Compliance-Freigabe |
| Screenshot Option | spaeter belegbare Sichtpruefung | nur wenn explizit freigegeben | Screenshot wird als App-Screen gelesen | separater Screenshot-Prompt | Screenshots aus M15-C |
| Widget Test Option | spaeter automatisierte Regression | nur wenn explizit freigegeben | Testfreigabe wird abgeleitet | separater Testprompt | Tests aus M15-C |
| Manual Preview Option | risikoarmster erster Check | lokales, isoliertes Anschauen | kann als App-Integration misslesen werden | klarer Demo-/Harness-Scope | App-Route |
| App Integration | Produktpfad | keiner aus M15-C | Harness wird Feature | eigenes Integrations-Gate | komplett blockiert |

## 6. Copy-Risiko-Pruefung

Bewertungsskala:

- `okay for isolated preview`
- `needs copy tweak before harness`
- `needs copy tweak before integration`
- `blocked`

| Copy | Bewertung | Risiko | Entscheidung |
| --- | --- | --- | --- |
| `Lernfokus lokal merken` | `needs copy tweak before integration` | `merken` kann nach Persistenz klingen | Fuer isolierte Preview akzeptabel; vor Harness beobachtbar, vor Integration Copy pruefen |
| `Lokale Preview / kein echtes Onboarding / nichts wird gespeichert` | `okay for isolated preview` | sehr trocken, aber klar | Fuer Harness beibehalten, weil Misread-Schutz hoch ist |
| `Lokaler Preview-Status gesetzt. Kein Onboarding, keine Datenbank.` | `needs copy tweak before integration` | `Status gesetzt` klingt technisch und leicht runtime-nah | Fuer isolierte Preview akzeptabel; vor Integration in Richtung `nur lokal angezeigt` pruefen |
| `Spaeter aenderbar. Keine Startinsel. Keine Speicherung.` | `okay for isolated preview` | kurze Dichte kann streng wirken | Wichtig fuer Reversibilitaet; im Harness sichtbar halten |

Kein Copy-Punkt ist fuer den isolierten Preview-Slice blockierend. Vor jeder
Integration sollte aber mindestens der Buttontext `Lernfokus lokal merken`
erneut geprueft werden.

## 7. Dokumentationsvisualisierungen

M15-C ergaenzt echte PNG-Dokumentationsvisualisierungen unter:

`docs/world_design/previews/m15_c_foundation_choice_local_preview_harness_gate/`

Erzeugte Visuals:

- `01_harness_gate_map.png`,
- `02_device_check_scope_map.png`,
- optional `00_contact_sheet.png`.

Diese PNGs sind Dokumentationspreviews. Sie sind keine App-Screens, keine
Screenshots, keine finalen UI-PNGs, keine Spielassets und keine Asset-Dateien
unter `assets/`.

## 8. Gate-Entscheidung

Optionen:

1. Kein Harness denkbar.
2. Nur weiterer Review noetig.
3. Spaeterer isolierter Local Preview Harness denkbar, aber nur nach eigenem
   Prompt und ausdruecklicher Freigabe.
4. Harness direkt implementieren.

Empfehlung: Option 3.

Ein spaeterer isolierter Preview-Harness ist theoretisch sinnvoll, weil der
Widget-Slice zwar scope-konform ist, aber vor jeder Integration Device-,
Text-Containment-, Tap-Target-, Safe-Exit-, Tali/Vori- und Accessibility-
Risiken lokal sichtbar geprueft werden sollten.

M15-C gibt keinen Harness, keine Tests, keine Screenshots und keine Integration
frei.

## 9. Stop-Regeln

Aus M15-C folgt ausdruecklich:

- Keine Harness-Implementierung.
- Keine Flutter-/Dart-Dateien.
- Keine App-Integration.
- Keine Home-/Onboarding-/World-Routing-Integration.
- Keine Tests.
- Keine Widget-Tests.
- Keine Screenshots.
- Keine Persistenz.
- Keine Runtime-Konfiguration.
- Keine Supabase Writes.
- Keine lokalen DB-Writes.
- Keine SRS-/`word_progress`-Aenderung.
- Keine Reward Bridge.
- Keine automatische Wortplatzierung.
- Keine Assetfreigabe.
- Keine Assets und keine Asset-Dateien unter `assets/`.
- Kein Build-State.
- Kein `frame_started`.
- Kein Bauzustand.

## 10. Ergebnis

M15-C bewertet einen spaeteren isolierten lokalen Preview-Harness als
theoretisch denkbar und sinnvoll. Der spaetere Harness muss aber strikt lokal,
isoliert und review-orientiert bleiben. Er darf kein Nutzerfeature, keine
Route, keine App-Integration, keine Persistenz, keine Runtime-Konfiguration,
keine Screenshots und keine Tests erzeugen, solange diese Schritte nicht in
einem spaeteren Prompt ausdruecklich freigegeben werden.
