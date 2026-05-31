# Store-Screenshot-Shotlist MVP

Stand: 2026-05-31

Diese Shotlist plant die Store-Screenshots fuer den Talvori-MVP. Es wurden keine Screenshots erstellt, keine UI geaendert, keine App-Daten geaendert und keine Produktivfreigaben gesetzt.

## 1. Grundregel

Fuer Screenshots duerfen nur Woerter aus dieser Datei verwendet werden:

- `docs/word-review/mvp_screenshot_content_selection.csv`

Oder spaeter gleichwertig manuell gepruefte Woerter.

Nicht verwenden:

- `fix_translation_later`
- `needs_context`
- `reject_for_mvp`
- `move_out_of_mvp`
- ungepruefte Woerter
- Spanisch-/Franzoesisch-Inhalte als fertige Release-Inhalte
- Wort-Duell als fertigen Multiplayer
- Premium/Abo
- Cloud-Backup oder Account-Sync
- TOEFL/IELTS/Cambridge
- Debug-/Developer-Screens

## 2. Geplante Shotlist

### Screenshot 1: Willkommen In Talvori

Zielaussage:

- Talvori ist eine freundliche Sprachlern-App fuer einen klaren, kleinen Start.

Screen/Pfad:

- Onboarding / Startscreen

Erlaubte sichtbare Woerter:

- `luggage` -> `Gepaeck`
- `one-way ticket` -> `einfache Fahrkarte`
- `airport` -> `Flughafen`
- `napkin` -> `Serviette`
- `pasta` -> `Nudeln`
- `drawer` -> `Schublade`

Empfohlener Store-Overlay-Text:

- `Lerne Englisch in kleinen Schritten`

No-Gos:

- keine Aussage zu vollstaendig geprueften 13k Woertern
- keine vollstaendige Mehrsprachigkeit bewerben
- keine Premium-, Account- oder Cloud-Hinweise

Plattform:

- Android und iOS

### Screenshot 2: Dein Home Zum Lernen

Zielaussage:

- Home fuehrt schnell zu Wortwelten, Lernmodus, Wortspielen und Einstellungen.

Screen/Pfad:

- Home

Erlaubte sichtbare Woerter:

- keine einzelnen Woerter notwendig
- falls Wortkarten sichtbar sind: nur Auswahl aus `mvp_screenshot_content_selection.csv`

Empfohlene Woerter, falls sichtbar:

- `bag` -> `Tasche`
- `apple` -> `Apfel`
- `living room` -> `Wohnzimmer`

Empfohlener Store-Overlay-Text:

- `Alles Wichtige an einem Ort`

No-Gos:

- keine Debug-/Developer-Zugaenge
- keine unfertigen Preview-Karten als Hauptmotiv
- keine ungeprueften Woerter im Hintergrund

Plattform:

- Android und iOS

### Screenshot 3: Wortwelten Entdecken

Zielaussage:

- Nutzer lernen thematisch statt in einer unuebersichtlichen Gesamtwortliste.

Screen/Pfad:

- WordHub / Wortwelten

Erlaubte sichtbare Wortwelten:

- Travel
- Food & Cooking
- Home & Living

Empfohlene Woerter:

- Travel: `airport`, `passport`, `plane`
- Food & Cooking: `apple`, `bread`, `cheese`
- Home & Living: `bathroom`, `bed`, `bedroom`

Empfohlener Store-Overlay-Text:

- `Lerne Vokabeln in Wortwelten`

No-Gos:

- A1-C2 nicht als normale Wortwelt inszenieren
- Top 500 nicht als normale Wortwelt zeigen
- keine Health-/Work-Wortwelt gross zeigen, solange diese nicht als Screenshot-Kern geprueft ist

Plattform:

- Android und iOS

### Screenshot 4: Schritt Fuer Schritt Wiederholen

Zielaussage:

- Der Lernmodus hilft beim Wiederholen einfacher, gepruefter Woerter.

Screen/Pfad:

- Lernmodus / Wiederholen

Empfohlene Woerter:

- `to sit` -> `sitzen`
- `to sleep` -> `schlafen`
- `to open the window` -> `das Fenster oeffnen`
- `to wash the dishes` -> `abwaschen`
- `to water plants` -> `Pflanzen giessen`

Empfohlener Store-Overlay-Text:

- `Wiederhole Woerter Schritt fuer Schritt`

No-Gos:

- keine unklaren Bedeutungen
- keine zu langen Satzfragen
- keine `fix_translation_later`-Woerter
- keine SRS-/Fortschrittsversprechen, die im Screenshot nicht belegbar sind

Plattform:

- Android und iOS

### Screenshot 5: Kurze Wortspiel-Runden

Zielaussage:

- Wortspiele sind eine leichte Lernabwechslung, nicht das Hauptversprechen der App.

Screen/Pfad:

- Wortspiele-Hub oder stabiler spielbarer Wortspielmodus

Empfohlene Woerter:

- `bread` -> `Brot`
- `carrot` -> `Karotte`
- `cheese` -> `Kaese`
- `coffee` -> `Kaffee`
- `cup` -> `Tasse`
- `bed` -> `Bett`
- `chair` -> `Stuhl`

Empfohlener Store-Overlay-Text:

- `Spiele kurze Vokabelrunden`

No-Gos:

- Wort-Duell nicht als fertigen Multiplayer zeigen
- keine Preview-Karte als Haupt-Screenshot
- keine KI-Spiele zeigen, wenn der konkrete Screen irrefuehrend wirkt
- keine sehr kleinen oder leeren Spielzustaende

Plattform:

- Android und iOS

### Screenshot 6: Datenschutz Und Support

Zielaussage:

- Talvori zeigt Datenschutz, Support und rechtliche Links transparent in der App.

Screen/Pfad:

- Settings / Rechtliches / Support

Erlaubte sichtbare Inhalte:

- Datenschutz: `https://talvori.eu/privacy/`
- Nutzungsbedingungen: `https://talvori.eu/terms/`
- Impressum: `https://talvori.eu/imprint/`
- Support: `https://talvori.eu/support/`
- Feedback-Mail: `support@talvori.eu`

Empfohlener Store-Overlay-Text:

- `Datenschutz und Support direkt erreichbar`

No-Gos:

- keine finalen juristischen Aussagen im Overlay
- keine Developer-/Debug-Sektion
- keine Platzhalter wie `kommt bald`

Plattform:

- Android und iOS

## 3. Optionaler Screenshot

### Optional: Companion / Impuls

Nur verwenden, wenn der konkrete Release-Build stabil, eindeutig und nicht irrefuehrend wirkt.

Zielaussage:

- Talvori begleitet den Lernalltag mit kleinen Impulsen.

No-Gos:

- keine Chat-Sync-, Account- oder KI-Perfektionsversprechen
- keine unfertigen Companion-Identitaeten als fertiges Langzeitfeature verkaufen

Empfehlung:

- Fuer den ersten Store-Durchlauf eher weglassen, wenn sechs starke Screenshots ausreichen.

## 4. Wortliste Je Screen

Zusatzdatei:

- `docs/word-review/mvp_screenshot_words_by_screen.csv`

Diese Datei ordnet konkrete gepruefte Woerter den geplanten Screenshots zu. Sie ist nur Planungsdokumentation und keine Produktivdatenfreigabe.

## 5. Finale Pruefung Vor Erstellung

Vor echten Screenshots:

- finalen Release-Build verwenden
- Debug-/Developer-Zugaenge pruefen
- sichtbare Woerter gegen `mvp_screenshot_content_selection.csv` abgleichen
- Store-Overlay-Texte auf Zeichenlaenge und Plattformvorgaben pruefen
- keine nicht fertigen Features im Bild zeigen
- Screenshots je Plattform/Geraet separat pruefen
