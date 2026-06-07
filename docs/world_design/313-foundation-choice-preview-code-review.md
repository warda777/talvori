# M15-B: Foundation Choice Preview Code Review And Visual Harness Plan

Stand: 2026-06-07

Status: `Code Review gestartet / Visual-Harness-Planung / keine Integration`

## 1. Ziel

Dieses Dokument prueft den umgesetzten minimalen Foundation-Choice-Preview-Code
gegen den freigegebenen Scope aus M15-A bis M15-A4.

M15-B ist ein enger Code-Review- und Visual-Harness-Planungsblock. Es ist kein
Feature-Code-Block, keine App-Integration, keine Home-/Onboarding-/
World-Routing-Integration, keine Persistenz, keine Runtime-Konfiguration, keine
Testfreigabe, keine Assetfreigabe und keine Implementierungsfreigabe.

## 2. Gepruefte Grundlage

Geprueft wurden:

- `lib/features/world/local_world/ui/widgets/foundation_choice_preview.dart`,
- `docs/world_design/312-foundation-choice-final-pre-implementation-checklist.md`,
- `docs/world_design/311-foundation-choice-prompt-visual-review.md`,
- `docs/world_design/310-foundation-choice-minimal-slice-prompt-draft.md`,
- `docs/world_design/309-foundation-choice-implementation-gate.md`,
- `docs/world_design/235-world-production-roadmap-and-checklists.md`,
- `assets/images/world/buildable_islands/forest_clearing/template.md`.

Zusaetzlich wurde per Textsuche geprueft, ob
`FoundationChoicePreview` ausserhalb der neuen Preview-Datei referenziert wird.
Ergebnis: keine Referenz ausserhalb der Datei.

## 3. Code-Review Ergebnis

| Check | Ergebnis | Evidence | Entscheidung |
| --- | --- | --- | --- |
| Datei existiert | pass | `foundation_choice_preview.dart` vorhanden | Scope erfuellt |
| Nur eine Flutter-Datei | pass | genau eine neue Dart-Datei aus dem Slice | Scope erfuellt |
| Nicht integriert | pass | keine Referenzen ausserhalb der Datei | Keine App-Integration |
| Nicht geroutet | pass | keine Route, kein Navigator, kein Entry Point | Keine Routing-Integration |
| Nicht exportiert | pass | keine Barrel-/Export-Referenz sichtbar | Isoliert |
| Keine Persistenz | pass | nur `setState`, keine Save-/Repository-/DB-Aufrufe | Keine Datenwirkung |
| Keine Runtime-Konfiguration | pass | keine Config-/Flag-Dateien, keine Runtime-Werte | Blockiert |
| Keine App-weite Navigation | pass | keine Navigation und kein App-Entry | Blockiert |
| Keine Assets | pass | nur Material Icons, keine Asset-Dateien | Keine Assetwirkung |
| Keine automatische Wortplatzierung | pass | keine Wort-/Routing-/Placement-Logik | Blockiert |
| Kein Build-State | pass | keine Bauzustandslogik | Blockiert |
| Kein `frame_started` | pass | String/Status entsteht nicht | Blockiert |
| Kein echtes Onboarding | pass | Banner markiert lokale Preview | Kein First-Run-Scope |
| Lokale In-Memory-Auswahl | pass | `_selectedChoice` und `_result` nur im State | Erlaubter Minimal-Scope |
| Safe Exit sichtbar | pass | Button `Spaeter entscheiden` vorhanden | Erfuellt |
| `spaeter aenderbar` sichtbar | pass | Hilfstext unter Aktionen vorhanden | Erfuellt |
| Tali/Vori blockiert Interaktion | pass mit Sichtnotiz | Tali/Vori ist als obere Karte vor den Optionen, nicht als Overlay | Spaetere Device-Pruefung noetig |
| Small Phone plausibel | pass mit Sichtnotiz | ScrollView, SafeArea, maxWidth, gestapelte Karten | Spaetere Harness-Pruefung noetig |
| Text wirkt nicht wie finale UI-Freigabe | minor note | Banner und Resulttext markieren Preview; Buttontext koennte spaeter praeziser werden | Keine Blockade |

Review-Entscheidung: Der Code bleibt innerhalb des freigegebenen Minimal-Scope.
Es wurden keine Blocker gefunden. Die wichtigsten offenen Punkte sind
textuelle Minor Notes und spaetere visuelle Device-/Harness-Pruefung.

## 4. Text- und Scope-Risiken

| Element | Bewertung | Risiko | Spaeterer Pruefhinweis |
| --- | --- | --- | --- |
| `Lernfokus lokal merken` | minor note | `merken` kann bei schneller Lesart nach Speicherung klingen | Spaeter `Lernfokus lokal anzeigen` oder `Preview-Auswahl zeigen` pruefen |
| `Lokale Preview / kein echtes Onboarding / nichts wird gespeichert` | pass | Direkt, trocken, aber sehr klaerend | Beibehalten, solange der Slice unintegriert ist |
| `Lokaler Preview-Status gesetzt. Kein Onboarding, keine Datenbank.` | pass mit minor note | `gesetzt` ist technisch, aber sagt keine Persistenz zu | Spaeter eventuell `Nur lokal angezeigt` pruefen |
| Zuhause / Alltag | pass | Kann als Pflicht-Hausstart fehlgelesen werden | Guardrail `Kein Pflicht-Hausstart.` sichtbar halten |
| Schule / Lernen | pass | Koennte schulisch wirken | `Kein Testmodus.` sichtbar halten |
| Garten / Natur nah | pass | Koennte Growth-/Timer-Druck nahelegen | `Kein Timer-Druck.` sichtbar halten |

Empfehlung fuer eine spaetere Copy-Iteration: Der Buttontext sollte vor einer
Integration noch einmal geprueft werden. `Lernfokus lokal merken` ist fuer die
isolierte Preview akzeptabel, aber `merken` sollte nicht in eine persistente
oder produktive Lesart kippen.

## 5. Visual-Harness-Plan

M15-B plant nur, wie das isolierte Widget spaeter lokal/visuell geprueft
werden koennte. Es entstehen keine Tests, keine Widget-Tests, keine
Screenshots und keine Harness-Implementierung.

Spaetere Harness-Ziele:

- Sichtbarkeit der Preview-Kennzeichnung,
- Text-Containment in Banner, Tali/Vori-Karte, Foundation-Karten, Buttons und
  Resultpanel,
- Tappbarkeit der drei Karten,
- Tappbarkeit von `Lernfokus lokal merken` und `Spaeter entscheiden`,
- Small-Phone-Portrait als kritischster Leitfall,
- keine Ueberdeckung durch Tali/Vori,
- Auswahl nicht nur ueber Farbe, sondern auch durch Check-Icon und Semantics,
- keine Ableitung von Onboarding, Startinsel, Persistenz oder Bauzustand.

Wichtige Device-Groessen fuer eine spaetere Pruefung:

| Device | Zweck | Risiko | Spaeterer Gate |
| --- | --- | --- | --- |
| Small Phone Portrait | Kritischster Leitfall | Karten/Buttons koennen vertikal eng werden | Manual Preview oder spaeterer Harness |
| Standard Phone Portrait | Normalfall | Textgewicht und Buttonabstand | Manual Preview |
| Large Phone Portrait | Luftiger Fall | Preview darf nicht komplexer werden | Manual Preview |
| Small Phone Landscape | Spaeterer Risikofall | Sehr wenig Hoehe | Separater Risk Check |
| Tablet | Optional spaeter | Karten koennen zu breit wirken | Optionaler Layout-Check |

Moegliche spaetere Gates, nur nach eigener Freigabe:

- Manual-Preview-Gate: Widget isoliert in einer lokalen Demo-Umgebung oeffnen.
- Screenshot-Gate: nur falls ein spaeterer Prompt Screenshots ausdruecklich
  erlaubt.
- Golden-/Widget-Test-Gate: nur falls ein spaeterer Testprompt Tests
  ausdruecklich erlaubt.
- Accessibility-Gate: Semantics, Focus-Reihenfolge, Farbunabhaengigkeit,
  Tap-Ziel-Abstaende und reduzierte Bewegung pruefen.

Schutz gegen Misread:

- Ein Harness darf nicht als Nutzerfeature erscheinen.
- Ein Harness darf keine App-Route, Home-Integration oder echtes Onboarding
  erzeugen.
- Ein Harness darf keine Persistenz, Runtime-Konfiguration, Assets,
  automatische Wortplatzierung oder `frame_started` ableiten.

## 6. Dokumentationsvisualisierung

M15-B ergaenzt eine kleine PNG-Dokumentationsvisualisierung unter:

`docs/world_design/previews/m15_b_foundation_choice_code_review/01_code_scope_review_map.png`

Diese PNG ist Dokumentationspreview. Sie ist kein Screenshot, kein App-Screen,
keine finale UI, kein Spielasset und keine Implementierungsfreigabe.

## 7. Stop-Regeln

Aus M15-B folgt ausdruecklich:

- Keine App-Integration.
- Keine Home-/Onboarding-/World-Routing-Integration.
- Keine Persistenz.
- Keine Runtime-Konfiguration.
- Keine Supabase Writes.
- Keine lokalen DB-Writes.
- Keine SRS-/`word_progress`-Aenderung.
- Keine Reward Bridge.
- Keine automatische Wortplatzierung.
- Keine Assetfreigabe.
- Keine Assets und keine Asset-Dateien unter `assets/`.
- Keine Tests.
- Keine Widget-Tests.
- Keine Screenshots.
- Keine Test-Harness-Implementierung.
- Kein Build-State.
- Kein `frame_started`.
- Kein Bauzustand.

## 8. Ergebnis

Der Foundation-Choice-Preview-Code ist als isolierter Minimal-Slice
scope-konform. Er ist nicht integriert, nicht geroutet, nicht exportiert und
verwendet nur lokale In-Memory-Auswahl.

Minor Notes:

- `Lernfokus lokal merken` ist fuer die isolierte Preview akzeptabel, sollte
  vor jeder Integration aber wegen moeglicher Persistenz-Lesart erneut
  geprueft werden.
- Der Preview-Status ist bewusst klar und nicht final formuliert; das ist fuer
  diesen engen Scope richtig.
- Small Phone und Text-Containment sind plausibel, aber vor Integration braucht
  es einen eigenen Visual-/Harness-/Device-Gate.

M15-B gibt keine Integration, keine Tests und keine weitere Implementierung
frei.
