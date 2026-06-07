# M15-D: Foundation Choice Local Preview Harness Implementation Gate

Stand: 2026-06-07

Status: `Implementation Gate gestartet / keine Harness-Implementierung`

## 1. Ziel

Dieses Dokument prueft, ob ein spaeterer isolierter Local Preview Harness fuer
`FoundationChoicePreview` als sehr kleiner Implementierungs-Slice sauber
freigegeben werden koennte.

M15-D ist ein reiner Dokumentations- und Gate-Block. Es ist keine Harness-
Implementierung, keine Testfreigabe, keine Screenshot-Freigabe, keine
App-Integration, keine Home-/Onboarding-/World-Routing-Integration, keine
Runtime-Konfiguration, keine Persistenz, keine Assetfreigabe und keine
Implementierungsfreigabe.

## 2. Gepruefte Grundlage

Fuehrend fuer M15-D sind:

- `lib/features/world/local_world/ui/widgets/foundation_choice_preview.dart`,
- `docs/world_design/314-foundation-choice-local-preview-harness-gate.md`,
- `docs/world_design/313-foundation-choice-preview-code-review.md`,
- `docs/world_design/312-foundation-choice-final-pre-implementation-checklist.md`,
- `docs/world_design/311-foundation-choice-prompt-visual-review.md`,
- `docs/world_design/310-foundation-choice-minimal-slice-prompt-draft.md`,
- `docs/world_design/309-foundation-choice-implementation-gate.md`,
- `docs/world_design/previews/m15_c_foundation_choice_local_preview_harness_gate/00_contact_sheet.png`,
- `docs/world_design/previews/m15_c_foundation_choice_local_preview_harness_gate/01_harness_gate_map.png`,
- `docs/world_design/previews/m15_c_foundation_choice_local_preview_harness_gate/02_device_check_scope_map.png`.

M15-C bestaetigt: Ein spaeterer isolierter Local Preview Harness ist
theoretisch sinnvoll, aber noch nicht freigegeben.

## 3. Minimaler Spaeterer Harness-Scope

Gepruefter spaeterer Harness-Slice:

> `FoundationChoicePreview` isoliert in einer lokalen Preview-/Demo-Flaeche
> sichtbar machen, ohne App-Route, ohne Tests, ohne Screenshots und ohne
> produktive Integration.

Ein solcher Slice waere nur dann eng genug, wenn er ausschliesslich:

- `FoundationChoicePreview` isoliert rendert,
- keine App-Route erzeugt,
- keine Home-/Onboarding-/World-Integration erzeugt,
- keinen Screenshot erzeugt,
- keinen Test erzeugt,
- keine Persistenz erzeugt,
- keine Runtime-Konfiguration erzeugt,
- keine Assets erzeugt,
- keine automatische Wortplatzierung erzeugt,
- kein `frame_started` erzeugt.

### 3.1 Nutzen

Ein spaeterer isolierter Harness koennte den bereits vorhandenen Preview-Slice
sicherer pruefbar machen, ohne ihn in die App zu integrieren. Der Nutzen waere:

- Small-Phone-Portrait als kritischen Leitfall sichtbar machen,
- Text-Containment vor Integration pruefen,
- Tap-Zonen und Safe Exit lokal bewerten,
- Tali/Vori-Karte auf Ueberdeckung pruefen,
- lokale Auswahlzustaende manuell nachvollziehen,
- Copy-Risiken sichtbar machen, bevor ein echter Produktpfad entsteht.

### 3.2 Risiko

Hauptrisiken:

- Harness wird als App-Integration gelesen,
- Harness wird als Nutzerfeature gelesen,
- lokale Demo-Flaeche wird zu App-Route,
- Screenshot- oder Testfreigabe wird abgeleitet,
- Copy `Lernfokus lokal merken` wird als Persistenz gelesen,
- Device-Werte werden als finale Layout-Freigabe gelesen,
- `frame_started`, Bauzustand oder Startinsel wird faelschlich abgeleitet.

### 3.3 Hypothetisch Betroffene Bereiche

Diese Bereiche werden in M15-D nur hypothetisch genannt und nicht geaendert:

- moegliche lokale Demo-/Preview-Datei,
- moegliche Debug-/Dev-only-Flaeche,
- moegliche Testbereiche, falls spaeter ausdruecklich freigegeben,
- moegliche Dokumentations-Harness-Bereiche.

Keine konkrete Codeanweisung wird aus M15-D ausgefuehrt.

## 4. Erlaubter Spaeterer Harness-Scope

Falls ein spaeterer Implementierungsblock ausdruecklich freigegeben wird,
duerfte ein Harness hoechstens:

- eine isolierte lokale Preview-Wrapper-Datei oder Demo-Flaeche vorbereiten,
- `FoundationChoicePreview` ohne Navigation anzeigen,
- Small Phone Portrait als Design-Leitfall sichtbar machen,
- keine Tests erzeugen, ausser Tests werden separat und ausdruecklich
  freigegeben,
- keine Screenshots erzeugen, ausser Screenshots werden separat und
  ausdruecklich freigegeben,
- keine App-Navigation aendern,
- keine Produkt-Route erzeugen,
- keine Persistenz oder Config beruehren,
- keine Assets beruehren.

Dieser Scope ist nur spaeter denkbar. Er ist keine aktuelle Freigabe.

## 5. Hart Blockierter Scope

Aus M15-D bleibt hart blockiert:

- Home-Integration,
- Onboarding-Integration,
- World-Routing,
- App-Route,
- produktive Navigation,
- Tests,
- Widget-Tests,
- Screenshots,
- Golden Tests,
- Persistenz,
- Supabase,
- lokale DB,
- Runtime Config,
- Feature Flags,
- Assets,
- automatische Wortplatzierung,
- Reward Bridge,
- `frame_started`,
- Bauzustaende.

## 6. Gate-Matrix

| Area | Later Harness Value | Risk | Missing Decision | Allowed Later Scope | Blocked Now | Gate Decision |
| --- | --- | --- | --- | --- | --- | --- |
| Isolated Preview Wrapper | macht Widget lokal sichtbar | wird App-Screen | konkrete isolierte Flaeche | lokale Wrapper-/Demo-Flaeche | App-Route, Navigation | spaeter denkbar |
| Debug/Dev-only Surface | trennt Review von Nutzerfeature | Dev-Flaeche wird produktiv | genauer Einstiegspunkt | dev-only, lokal, nicht produktiv | Home-/Onboarding-Einstieg | spaeter denkbar |
| Small Phone Visual Check | kritischster Device-Fall | Layout wirkt final bestaetigt | Device-Werte und Pruefart | manuelle Sichtpruefung | Screenshot/Test aus M15-D | spaeter sinnvoll |
| Standard Phone Visual Check | Normalfall absichern | zu fruehe Freigabe | Pruefmatrix | lokaler Check | finale UI-Freigabe | spaeter sinnvoll |
| Large Phone Visual Check | Breite pruefen | Zusatzkomplexitaet | optionaler Umfang | optionaler Check | Tablet-Finalisierung | optional |
| Copy Review | Persistenz-Misread vermeiden | `merken` klingt gespeichert | Copy-Entscheidung vor Code | Copy nur im Harness beobachten | produktive Copy-Freigabe | noetig vor Integration |
| Accessibility/Semantics Review | Farbunabhaengigkeit und Fokus | Compliance wird abgeleitet | Checktyp | Semantics manuell planen | Compliance-Freigabe | spaeter sinnvoll |
| Screenshot Capture | belegbare Sichtpruefung | wird App-Screenshot gelesen | explizite Screenshot-Freigabe | keiner ohne Freigabe | Screenshots | blockiert |
| Widget Test | Regression pruefen | Testfreigabe wird abgeleitet | explizite Testfreigabe | keiner ohne Freigabe | Tests, Widget-Tests | blockiert |
| Golden Test | visuelle Regression | zu schwer und zu final | eigener Test-/Golden-Gate | keiner ohne Freigabe | Golden Tests | blockiert |
| Home Integration | produktiver Einstieg | Preview wird Feature | eigenes Integrations-Gate | keiner aus M15-D | Home-Integration | blockiert |
| Onboarding Integration | First-Run-Flow | echtes Onboarding entsteht | eigenes Onboarding-Gate | keiner aus M15-D | Onboarding-Integration | blockiert |
| World Routing | World-Pfad | Startinsel/ThemeIsland-Misread | eigenes Routing-Gate | keiner aus M15-D | World-Routing | blockiert |
| Persistence | Auswahl merken | DB/Supabase/State-Drift | kein Gate vorgesehen | keiner | Persistenz, lokale DB | blockiert |
| Runtime Config | Feature sichtbar machen | Config/Flag wird produktiv | kein Gate vorgesehen | keiner | Runtime Config, Feature Flags | blockiert |
| Assets | visuelle Ausstattung | Spielassets entstehen | Asset-Gate fehlt | keiner | Assets, `assets/` | blockiert |
| `frame_started` | keiner fuer Harness | Bauzustand wird abgeleitet | bleibt blockiert | keiner | `frame_started`, Bauzustand | blockiert |

## 7. Copy-Entscheidung Zu `Lernfokus lokal merken`

Gate-Frage:

> Soll der Buttontext `Lernfokus lokal merken` vor einem spaeteren Harness-
> Slice geaendert werden?

Entscheidung fuer M15-D:

- Fuer den isolierten bestehenden Preview-Slice reicht Dokumentation.
- Vor einem spaeteren Harness-Slice ist die Copy nicht blockierend, solange
  der Harness sichtbar lokal/isoliert bleibt und keine Persistenz erzeugt.
- Vor jeder Integration sollte der Text jedoch geaendert oder mindestens
  erneut entschieden werden.

Empfohlene spaetere Alternative, nur als Vorschlag:

`Lernfokus lokal anzeigen`

Diese Formulierung reduziert die Persistenz-Lesart von `merken`. M15-D setzt
diese Aenderung nicht um.

## 8. Dokumentationsvisualisierungen

M15-D ergaenzt echte PNG-Dokumentationsvisualisierungen unter:

`docs/world_design/previews/m15_d_foundation_choice_harness_implementation_gate/`

Erzeugte Visuals:

- `01_harness_implementation_gate_map.png`,
- `02_allowed_vs_blocked_harness_scope.png`,
- optional `00_contact_sheet.png`.

Diese PNGs sind Dokumentationspreviews. Sie sind keine App-Screens, keine
Screenshots, keine finalen UI-PNGs, keine Spielassets und keine Asset-Dateien
unter `assets/`.

## 9. Gate-Entscheidung

Optionen:

1. Kein Harness-Slice denkbar.
2. Nur weiterer Gate-/Review-Block noetig.
3. Spaeterer isolierter Harness-Slice theoretisch freigabefaehig, aber nur mit
   separatem Implementierungs-Prompt und ausdruecklicher Nutzerfreigabe.
4. Harness direkt freigeben.

Empfehlung: Option 3.

Ein spaeterer isolierter Harness-Slice ist theoretisch freigabefaehig, wenn er
lokal, dev-/preview-orientiert und ohne Navigation, Tests, Screenshots,
Persistenz, Runtime-Konfiguration, Assets, automatische Wortplatzierung und
`frame_started` bleibt.

M15-D gibt keinen Harness, keinen Test, keinen Screenshot und keine
Implementierung frei.

## 10. Stop-Regeln

Aus M15-D folgt ausdruecklich:

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

## 11. Ergebnis

M15-D kommt zu folgendem Ergebnis:

- Ein spaeterer isolierter Local Preview Harness fuer `FoundationChoicePreview`
  ist theoretisch freigabefaehig.
- Der spaetere Slice muesste extrem klein bleiben: isolierter Wrapper oder
  lokale Demo-Flaeche, keine Navigation, keine Tests, keine Screenshots.
- Die Copy `Lernfokus lokal merken` blockiert einen spaeteren Harness nicht,
  sollte aber vor jeder Integration in Richtung `Lernfokus lokal anzeigen`
  geprueft werden.
- Vor jeder Umsetzung braucht es einen separaten Implementierungs-Prompt mit
  ausdruecklicher Nutzerfreigabe.
