# Talvori Welt Plan-Abgleich: Home-Redesign und aktuelle Leitdokumente

## 1. Zweck

Dieses Dokument gleicht den aktuellen Home-Redesign-Stand der Talvori-Welt-Zentrale mit den vorhandenen Talvori-Welt-Planungsdokumenten im Repository ab.

Es verwendet keine PDF als neue Arbeitsgrundlage. Die PDF "Talvori Welt Konzeptdokument Version 3" ist im Repository nicht vorhanden und wird in diesem Abgleich nicht vorausgesetzt. Grundlage sind die aktuellen Markdown-Dokumente und der dokumentierte Home-Arbeitsstand.

Ziel ist, klar festzuhalten:

- welche Entscheidungen weiterhin gelten,
- wo sich der aktuelle Home-Stand gegenueber aelteren Plaenen weiterentwickelt hat,
- welche offenen Home-Aufgaben als naechstes sinnvoll sind,
- welche Dokumente fuer kuenftige Codex-Bloecke massgeblich sein sollen.

## 2. Aktuelle massgebliche Quellen

### `AGENTS.md`

`AGENTS.md` ist die aktuelle strategische Arbeitsregel fuer Codex-Bloecke im Repository. Es setzt Talvori Welt als Produktziel, beschreibt die Home-Zentrale, den zentralen Plus-Hub, die Trennung von Companion-Chat und menschlichem Chat sowie die Schutzregeln fuer Daten, SRS, `word_progress`, Supabase und Secrets.

### `docs/talvori_world_transition_plan.md`

Dieses Dokument ist der Umstellungsplan vom klassischen Vocabulary-MVP zur Talvori-Welt-Richtung. Es haelt fest, dass der alte oeffentliche Vocabulary-MVP-Launch pausiert ist und die bestehende App als Foundation Build fuer Talvori Welt weiterverwendet wird.

### `docs/talvori_world_vertical_slice_plan.md`

Dieses Dokument beschreibt den urspruenglichen Engineering-Slice fuer Talvori Welt. Es definiert Home als Welt-Zentrale, Companion, lokalen Welt-Einstieg, Plot, Gebaeude, Ressourcen und Reward Bridge als naechste Produktlogik.

Einige Home-UI-Details aus diesem Plan sind inzwischen ueberholt, besonders die reduzierte Bottom-Bar. Die strategischen Ziele bleiben aber relevant.

### `docs/talvori_world_architecture_notes.md`

Dieses Dokument beschreibt die technische Zielrichtung: Lernlogik, Weltlogik, Companion-Logik, Social-Logik und Rendering bleiben getrennt. Reward Bridge soll aus LearningResults Weltfortschritt ableiten, ohne SRS oder `word_progress` zu beschaedigen.

### `docs/210-talvori-world-home-redesign-state.md`

Dieses Dokument ist der aktuellste dokumentierte Arbeitsstand des Home-Redesigns. Es beschreibt den realen Stand nach den vielen Globe-, Background-, Companion-, Bubble-, Keyboard- und Plus-/Wheel-Hub-Bloecken.

Fuer die naechsten Home-Bloecke ist `docs/210...` die wichtigste konkrete Arbeitsstand-Dokumentation.

### `docs/talvori_project_current_state_summary.md`

Dieses Dokument beschreibt vor allem den Foundation-Build-Stand vor der Talvori-Welt-Umstellung. Es ist weiterhin nuetzlich fuer bestehende App-Architektur, Release- und Datenkontext, aber nicht mehr das strategische Leitdokument fuer die Home-Zentrale.

## 3. Weiterhin gueltige Entscheidungen

Folgende Entscheidungen sind zwischen den Planungsdokumenten und dem aktuellen Home-Stand weiterhin konsistent:

- Talvori Welt bleibt das Produktziel.
- Der alte Vocabulary-MVP-Launch bleibt pausiert.
- Die bestehende App bleibt wertvolle Foundation Build, nicht Wegwerf-Arbeit.
- Home ist die Talvori-Welt-Zentrale.
- Der Globe ist die Hauptaktion und bleibt der Welt-Einstieg.
- Tali oder Vori ist der aktive Companion; nicht beide parallel als permanente Systeme.
- Companion-Chat bleibt getrennt von menschlichem Chat/Friends.
- Lernen soll spaeter sichtbaren Weltfortschritt erzeugen.
- Reward Bridge kommt spaeter und darf bestehende SRS-/`word_progress`-Semantik nicht beschaedigen.
- Weltlogik, Lernlogik, Companion-Logik, Social-Logik und Rendering bleiben getrennt.
- Keine Supabase Writes ohne explizite Freigabe.
- Keine SQLite-Vokabeldaten, SRS-Daten, `word_progress`, Secrets, Keystores oder Release-Artefakte in UI-/Planungsbloecken anfassen.

## 4. Bewusste Abweichungen und Weiterentwicklungen

| Konzept/Plan | Aktueller Stand | Bewertung | Entscheidung |
| --- | --- | --- | --- |
| Bottom-Dock | Frueher war eine reduzierte Bottom-Bar bzw. ein Dock mit Chat, Woerter/Import, Wortspiele und Profil vorgesehen. | Der klassische Dock-Ansatz wirkt zu sehr nach normaler App-Navigation und weniger nach Welt-Zentrale. | Der zentrale Plus-/Wheel-Hub ist der aktuelle Home-Standard. |
| V-Button/Stats oben | Frueher waren ein V-Button links und Stats/Fortschritt rechts oben sichtbar. | Der Top-Bereich wurde fuer den Globe-Hero reduziert. Die Progress-Pill bleibt kompakt; V/Stats wandern eher ins Wheel. | Cleaner Home-Fokus: oben nur das Noetigste. |
| Globe | Frueher war ein stilisierter/drehender Globe als Richtung offen. | Aktuell existiert ein realistischer Premium-Earth-Globe mit Shader, Night-Lights, Coastline-Highlights, Network-Lines und Lens-Flare-Nodes. | Der aktuelle Globe-Stil bleibt fuer den Home-Hero massgeblich. |
| Home-Status | Frueher war der statische Claim `Deine Welt wartet` naheliegend. | Aktuell ist ein dynamischer Tages-/Weltstatus geplant und teilweise umgesetzt. | Home-Text wird situativ statt dauerhaft statisch. |
| Background | Frueher: dark space/neon als allgemeine Richtung. | Aktuell: cyan/lila Ambient-Background plus animierte Galaxy-, Stern-, Twinkle- und Sternschnuppen-Ebene. | Konform mit dem Ziel; Shooting Stars sollen noch natuerlicher werden. |
| Companion-Bubble | Frueher: Bubble mit Hinweis und Quick Actions. | Aktuell: Bubble ist vorhanden, aber Textlayout und Quick Actions sind noch nicht final. | Quick Actions nur bei echten Suggestions; Text darf nicht hart begrenzt werden. |
| Companion/Keyboard | Frueher war das Keyboard-/Hero-Verhalten nicht ausformuliert. | Debug zeigte: `MediaQuery.padding.bottom` kann bei Keyboard auf `0` fallen und den Globe-Hero vergroessern. | Home/Hero/Globe muessen keyboard-stabile Safe-Area-Werte nutzen; Input nutzt `viewInsets.bottom`. |
| Plus/X | Frueher war nur Plus-Hub als Idee festgelegt. | Aktuell: offener Hub soll Plus zu X drehen, final mit 360 Grad plus 45 Grad. | Endzustand offen: eindeutig X, kein 360-Grad-Plus. |

## 5. Aktuelle offene Home-To-dos

- Companion-Bubble: Text darf nicht abgeschnitten werden.
- Quick Actions nur bei echten Suggestions anzeigen.
- Keyboard im Companion-Chat per Swipe nach unten schliessen.
- Shooting Stars: random aus unterschiedlichen Richtungen.
- Shooting-Star-Kopf runder und gluehender.
- Plus/X: 405-Grad-Rotation und eigener X-Zustand auf dem Geraet final pruefen.
- `home_smart_hub_menu.dart` unstaged Aenderung pruefen und entscheiden.
- Debug-Logs entfernen, falls noch Reste vorhanden sind.
- Galaxy-Staerke spaeter ggf. ueber Modi steuerbar machen:
  - Subtil,
  - Atmosphaerisch,
  - Galaxie.

## 6. Naechster Plan nach Home-Polish

### A. Home-Zentrale final stabilisieren

Die Home-Zentrale soll visuell und interaktiv stabil sein:

- Globe bleibt Hero und Welt-Einstieg.
- Plus-/Wheel-Hub funktioniert eindeutig.
- Companion/Bubble/Chat stoeren den Globe nicht.
- Background wirkt hochwertig, aber nicht ablenkend.

### B. Lokaler Welt-Einstieg

Nach dem Home-Polish sollte der Globe-Tap in einen lokalen Welt-Einstieg fuehren, nicht nur in einen Platzhalter.

### C. Startregion, Plot und drei Gebaeude

Naechster Produktbeweis:

- lokale Startregion,
- eigener Plot,
- drei einfache Gebaeude,
- sichtbarer Ausbau.

### D. Reward Bridge vorbereiten

Reward Bridge soll aus Lernaktionen Weltressourcen erzeugen, ohne SRS oder `word_progress` zu veraendern.

### E. Satzfunken, Import und DeepL anbinden

Importierte Woerter, DeepL-Uebersetzungen und Satzfunken sollen spaeter als Welt-/Companion-Material funktionieren.

### F. Social-Minimum spaeter

Freunde, Showcase und Reaktionen kommen spaeter. Globaler Chat ist kein kurzfristiges Ziel.

## 7. Empfehlung

Die PDF "Talvori Welt Konzeptdokument Version 3" muss aktuell nicht ins Repository uebernommen werden, um die Home-Zentrale weiterzubauen. Die vorhandenen Markdown-Dokumente sind fuer den aktuellen Home-Stand konkreter und aktueller.

Fuer die naechsten Codex-Bloecke sollten massgeblich sein:

1. `AGENTS.md` fuer strategische Regeln und Schutzregeln.
2. `docs/210-talvori-world-home-redesign-state.md` fuer den aktuellen Home-Arbeitsstand.
3. `docs/211-talvori-world-plan-alignment-review.md` fuer den Abgleich zwischen Plan und aktuellem Stand.
4. `docs/talvori_world_transition_plan.md`, `docs/talvori_world_vertical_slice_plan.md` und `docs/talvori_world_architecture_notes.md` fuer laengerfristige Produkt- und Architekturziele.

Wenn spaeter eine neue Konzeptversion entstehen soll, sollte sie aus diesen aktuellen Markdown-Dokumenten erzeugt werden, nicht umgekehrt. Eine aeltere oder externe PDF sollte nicht als alleinige Quelle zurueck in den Workflow gezogen werden, solange sie den aktuellen Home-Stand nicht ausdruecklich aufnimmt.

