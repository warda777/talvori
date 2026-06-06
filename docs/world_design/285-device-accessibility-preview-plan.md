# Phase 2G-M13-E: Device And Accessibility Preview Plan

Stand: 2026-06-06

Status: `Planung gestartet / Preview-Pruefplan definiert`

## 1. Zweck

Dieses Dokument plant, wie zukuenftige Talvori-Welt-Previews,
Onboarding-Flows, ThemeIsland-Choices, Word-to-Island-Flows,
Container-/Depth-Ansichten und kleine Objektansichten vor einer Umsetzung auf
Mobile-Lesbarkeit, Accessibility, Tap-Ziele, Text-Containment und visuelle
Ueberladung geprueft werden.

M13-E ist nur ein Pruefplan. Es werden keine neuen Preview-PNGs erzeugt, keine
Tests geschrieben, keine App-UI umgesetzt und keine Spielassets erzeugt.

M13-E ist keine finale UI, keine finale Datenstruktur, keine Runtime-
Konfiguration, keine App-Integration, keine App-/Assetfreigabe und kein
Implementierungsauftrag.

## 2. Ausgangslage

M12-E/M12-E2 haben Mobile-/Clutter-Regeln als erste Planungsrichtung
bestaetigt. M13-B/M13-B2 haben Onboarding-Choice als Hybrid-Planungsrichtung
bestaetigt. M13-D hat den Word-to-Island UX Flow geplant. M13-E verbindet
diese Linien zu einem allgemeinen Vorschau- und Freigabepruefplan.

Kernprinzip:

Eine Entscheidung ist erst dann produktnah brauchbar, wenn ihre Darstellung
auf kleinen mobilen Ansichten lesbar, bedienbar, verstaendlich und nicht
ueberladen wirkt. Text allein reicht bei visuellen oder entscheidungsrelevanten
Systemen nicht.

## 3. Pruefkategorien

### 3.1 Device-Groessen

Zukuenftige Previews sollen mindestens gedanklich oder visuell gegen diese
Groessen geprueft werden:

- kleines iPhone oder schmales Android,
- Standard Phone,
- grosses Phone,
- Tablet optional spaeter.

Planungsregel:

Wenn ein Flow auf kleinem Phone nicht plausibel lesbar oder bedienbar wirkt,
darf er nicht als produktnaher Nutzerflow bestaetigt werden.

### 3.2 Orientierung

- Primaer wird Portrait geprueft.
- Landscape ist ein spaeterer Sonderfall.
- Eine Preview darf nicht davon ausgehen, dass Nutzer das Geraet drehen
  muessen.

### 3.3 Tap-Target-Pruefung

Zu pruefen:

- Mindestgroesse fuer direkte Touch-Ziele,
- Abstand zwischen interaktiven Elementen,
- keine zu kleinen Kleinteile als direkte Touch-Ziele,
- keine ueberlappenden Tap-Zonen,
- Fokusobjekte muessen klarer sein als Deko.

Planungsregel:

TinyObjects wie Loeffel, Bleistift, Samen, Schluessel oder Schraube duerfen
nicht als winzige direkte Touch-Ziele in IslandView geplant werden. Sie
brauchen Zoom, Container, DetailInteractionView oder Codex/Backlog.

### 3.4 Text-Containment

Zu pruefen:

- Texte bleiben in Karten, Rahmen oder Panels.
- Lange Labels brauchen Umbruch, Kuerzung oder groessere Boxen.
- Wichtige Texte duerfen nicht abgeschnitten wirken.
- Buttons, Karten und Panels brauchen genug Padding.
- Technische Labels duerfen Nutzeransichten nicht ueberfrachten.

Planungsregel:

Eine Preview darf fuer interne Planung kleine visuelle Maengel dokumentieren,
aber finale oder freigaberelevante Previews duerfen keine wichtigen Texte
aus Rahmen herauslaufen lassen.

### 3.5 Accessibility

Zu pruefen:

- Lesbarkeit,
- Kontrast,
- reduzierte Bewegung,
- Silent-/Audio-Fallback,
- keine rein farbcodierte Bedeutung,
- kurze verstaendliche Texte,
- optionale Companion-Hinweise,
- keine beschamende Fehlerreaktion.

Planungsregel:

Audio, Farbe, Bewegung oder Companion-Text duerfen nicht die einzige
Verstaendnisquelle sein.

### 3.6 Mobile-Clutter

Zu pruefen:

- keine TinyObjects dauerhaft in IslandView,
- Container nicht als Objektliste ueberladen,
- Labels nur kontextuell,
- Deko darf Lernobjekte nicht verdecken,
- nicht alle Fortschritte gleichzeitig sichtbar machen,
- Depth/Container/Zoom als Entlastung nutzen.

Planungsregel:

Wenn eine Ansicht zu viele Kleinteile braucht, muss sie in Container,
Pagination, DetailInteractionView, Codex, Blueprint oder Backlog aufgeteilt
werden.

### 3.7 UX-Komplexitaet

Zu pruefen:

- nicht zu viele Entscheidungen pro Wort,
- nicht zu viele Karten im Onboarding,
- Tali/Vori-Hinweise kurz halten,
- "spaeter entscheiden" sichtbar halten,
- keine technische Matrix im Nutzerflow,
- keine irreversible Erstwahl,
- keine Premium- oder Paywall-Logik im Start-Onboarding.

Planungsregel:

Talvori darf dem Nutzer Vorschlaege machen, aber die Entscheidung muss leicht,
reversibel und nicht bedrohlich wirken.

## 4. Preview-Typen Und Pruefbedarf

| Preview-Typ | Visuelle Pruefung | Device-Frame | Tap-Target-Overlay | Text-Containment | Accessibility | Blockiert Freigabe, wenn... |
| --- | --- | --- | --- | --- | --- | --- |
| Onboarding Choice Cards | Pflicht | Ja, vor Produktentscheidung | Ja | Ja | Ja | Karten zu viele Entscheidungen erzeugen, Pflicht-Hausstart andeuten oder Texte brechen. |
| ThemeIsland Roadmap / Capability Sheets | Ja, intern | Optional | Nein | Ja | Basis | Wellen/Gates unklar sind oder Roadmap final wirkt. |
| Word-to-Island UX Flow | Ja, wenn nutzerseitig | Ja, vor UX-Freigabe | Optional | Ja | Ja | automatische Platzierung, technische Ueberladung oder fehlende Sense-Auswahl suggeriert wird. |
| Depth-/Container-Flow | Pflicht | Ja | Ja | Ja | Ja | Container wie Objektlisten wirken oder TinyObjects ohne Zoom beruehrt werden muessen. |
| Challenge Interaction Preview | Pflicht | Ja | Ja | Ja | Ja | Tap-Ziele zu klein sind, Audio-only geplant ist oder Feedback fehlt. |
| Companion Reaction Preview | Ja | Optional | Nein | Ja | Ja | Tali/Vori Druck, Schuldgefuehl oder Loesung statt Hilfe erzeugt. |
| Capability Greybox | Ja, intern | Nein | Optional | Ja | Basis | Debug-Labels als Nutzeransicht missverstanden werden. |
| Product UI Preview | Pflicht | Ja | Ja | Ja | Ja | finale UI suggeriert wird oder mobile Bedienbarkeit unklar bleibt. |
| IslandView / PlotView Preview | Pflicht | Ja | Ja | Ja | Ja | zu viele Objekte, Labels oder Deko-Layer Lernobjekte verdecken. |
| ContainerOpenView / DetailInteractionView | Pflicht | Ja | Ja | Ja | Ja | mehr als wenige Challenge-Objekte gezeigt werden oder Navigation unklar ist. |

Hinweis:

`Device-Frame` bedeutet hier Planungs- oder Preview-Pruefung gegen mobile
Rahmen. Es ist keine App-Implementierung und keine finale UI-Spezifikation.

## 5. Checklisten

### 5.1 Vor Preview-Erzeugung

- Ist der Zweck klar?
- Ist es Diagramm, Product Preview, QA-Overlay oder Asset?
- Sind Stop-Regeln bekannt?
- Sind Texte kurz genug?
- Sind Karten und Boxen gross genug?
- Ist klar, welche Device-Groesse betrachtet wird?
- Sind Tap-Ziele als Fokusobjekte geplant statt als Kleinteile?
- Gibt es eine Accessibility-Alternative fuer Audio, Farbe oder Bewegung?
- Wird keine finale UI suggeriert, wenn nur Planung gemeint ist?
- Wird keine Asset- oder Codefreigabe suggeriert?

### 5.2 Nach Preview-Erzeugung

- Sind alle Texte innerhalb der Rahmen?
- Sind Tap-Ziele gross genug gedacht?
- Sind wichtige Elemente nicht verdeckt?
- Ist der Flow verstaendlich?
- Ist die Preview auf kleinem Phone plausibel?
- Sind Labels kurz, kontextuell und nicht dauerhaft ueberall sichtbar?
- Wirkt Tali/Vori freundlich und optional?
- Gibt es keinen Druck, kein Schuldgefuehl und keinen Streak-Zwang?
- Werden keine Assets oder finalen UI-Entscheidungen suggeriert?
- Sind Grenzen und Nicht-Freigaben im README oder Review dokumentiert?

### 5.3 Vor Commit

- Keine PNGs, wenn nur Dokumentationsplan erwartet war.
- Keine Dart-/Flutter-Dateien.
- Keine Tests, ausser explizit erlaubt.
- Keine Spielassets.
- Keine App-Integration.
- Keine Runtime-Konfiguration.
- `git diff --check`.
- `git status --short`.
- Nur erwartete Dateien.

## 6. Harte Blocker

Eine Preview oder Freigabeentscheidung wird blockiert, wenn:

- Texte aus Karten, Rahmen oder Panels herauslaufen,
- wichtige Labels abgeschnitten sind,
- Tap-Ziele zu klein oder zu dicht sind,
- TinyObjects als direkte IslandView-Touch-Ziele geplant werden,
- zu viele technische Labels in einer Nutzeransicht stehen,
- Bedeutung nur ueber Farbe codiert wird,
- eine Audio-only-Challenge ohne Silent-/Accessibility-Fallback geplant wird,
- Companion-Hinweise Druck, Schuldgefuehl oder Streak-Zwang erzeugen,
- eine Preview finale UI oder Assetfreigabe suggeriert,
- sensible Inhalte dramatisiert oder automatisch visualisiert werden,
- Onboarding Pflicht-Hausstart, Lock-in oder Premium-Druck erzeugt,
- Container als ungefilterte Objektlisten wirken,
- Deko Lernobjekte verdeckt,
- Word-to-Island-Flows automatische Platzierung suggerieren.

## 7. Freigabegrade

| Grad | Bedeutung | Was erlaubt ist | Was nicht erlaubt ist |
| --- | --- | --- | --- |
| `planning-only` | Nur textliche oder konzeptionelle Planung. | Dokumentieren, strukturieren, Risiken sammeln. | UI, Code, Assets, finale Datenstruktur. |
| `debug-preview-ok` | Technische Preview ist intern brauchbar. | QA, interne Diskussion, Fehler finden. | Als Nutzeransicht verwenden. |
| `product-preview-ok` | Produktnahes Verstaendnis ist brauchbar. | UX-Richtung diskutieren, Review starten. | Finale UI oder Implementierung ableiten. |
| `device-preview-required` | Mobile-Rahmenpruefung fehlt. | Nachbessern oder Device-Preview planen. | Produktentscheidung treffen. |
| `accessibility-review-required` | Accessibility-Fragen sind offen. | Accessibility-Review planen. | Challenge/UI finalisieren. |
| `blocked` | Harte Blocker vorhanden. | Dokumentieren, nachbessern. | Freigabe oder Umsetzung. |
| `implementation-candidate` | Richtung kann spaeter fuer Implementierung vorbereitet werden. | Eigenen Implementierungs-Prompt und Gates planen. | Direkte Codefreigabe aus diesem Grad. |

Wichtig:

Auch `implementation-candidate` ist keine Codefreigabe. Es braucht einen
eigenen Implementierungsblock mit Ziel, Non-Goals, betroffenen Dateien,
Tests/Checks und ausdruecklicher Freigabe.

## 8. Anwendung Auf Naechste Planungsbloecke

M13-E gilt besonders fuer:

- M13-B/M13-B2 Onboarding Choice,
- M13-D Word-to-Island UX Flow,
- spaetere ThemeIsland Capability Reviews,
- Container-/Depth-Flow-Previews,
- Challenge-Interaction-Previews,
- Companion-Reaction-Previews,
- IslandView-/PlotView-Previews,
- ContainerOpenView-/DetailInteractionView-Previews.

Naechste sinnvolle Folgepruefungen koennen sein:

- echte Device-Frame-Preview fuer Hybrid-Onboarding,
- Tap-Target-Overlay fuer ContainerOpenView,
- Text-Containment-Review fuer Product Previews,
- Accessibility-Fallback-Plan fuer Audio + Tap,
- Clutter-Review fuer Schule/Federmappe und Garten/Beet.

## 9. Stop-Regeln

Aus M13-E darf nicht abgeleitet werden:

- keine UI-Implementierung aus M13-E,
- keine finalen Device-Regeln als Runtime-Konfiguration aus M13-E,
- keine finalen Accessibility-Regeln als Runtime-Konfiguration aus M13-E,
- keine Preview-PNG-Erzeugung aus M13-E,
- keine Tests aus M13-E,
- keine App-/Assetfreigabe aus M13-E,
- kein Code aus M13-E,
- kein `frame_started` oder Bauzustand aus M13-E,
- keine finale Onboarding-UI aus M13-E,
- keine finale ThemeIsland-UI aus M13-E,
- keine finale Word-to-Island-UI aus M13-E,
- keine finale Container-/Depth-UI aus M13-E.

## 10. Naechster Erlaubter Schritt

Erlaubt ist nur:

- M13-E reviewen,
- M13-E dokumentarisch nachbessern,
- einen Device-Frame-Preview-Plan als reinen Dokumentationsblock starten,
- einen Accessibility-Fallback-Plan als reinen Dokumentationsblock starten,
- einen Tap-Target-/Pagination-Plan als reinen Dokumentationsblock starten.

Weiterhin nicht erlaubt:

- Flutter-/Dart-Code,
- App-Integration,
- Tests,
- Spielassets,
- PNG-Erzeugung oder PNG-Aenderung,
- finale UI,
- finale Datenstruktur,
- Runtime-Konfiguration,
- automatische Wortplatzierung,
- ThemeIsland-Umsetzung,
- `frame_started`,
- Bauzustaende.
