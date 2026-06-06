# Phase 2G-M10-C: Companion Reaction Flow

Stand: 2026-06-06

Status: `Planungs- und Visualisierungsblock gestartet`

Dieses Dokument plant, wie Tali/Vori den Depth-/Container-Lernflow emotional
begleitet, ohne die Challenge zu ueberlagern, Druck zu erzeugen oder eine
Implementierung freizugeben.

M10-C ist kein Flutter-/Dart-Code, keine App-Integration, kein Testblock, keine
Spielasset-Produktion, kein finales Inselbild, kein `frame_started` und keine
Bauzustandsarbeit.

## 1. Ziel

Der Beispiel-Flow bleibt:

```text
Haus/Kueche -> Schublade -> Besteck
```

M9/M10 haben gezeigt, dass der Nutzer eine Schublade entdeckt, oeffnet und dort
eine kleine Challenge loest. M10-B/M10-B2 empfehlen fuer den ersten Prototype
Tap-Auswahl, danach Audio + Tap. M10-C klaert nun den emotionalen Companion-
Anteil:

- Wann darf Tali/Vori reagieren?
- Wie bleibt die Reaktion hilfreich, aber nicht stoerend?
- Wie reagiert Tali/Vori bei Erfolg, Fehlern, Untaetigkeit und Wiederholung?
- Welche Grenzen verhindern Druck, Loesungs-Automatik und visuelle Ueberladung?

## 2. Companion-Rollen

| Rolle | Zweck | Beispiel Im Kuechenflow | Grenze |
| --- | --- | --- | --- |
| Curiosity Trigger | Tali/Vori bemerkt etwas Interessantes. | Blick zur Schublade, kleiner Hinweisreiz. | Nicht jede Sekunde blinken oder reden. |
| Gentle Nudge | Freundliche Ermutigung ohne Druck. | `Da koennte etwas drin sein.` | Kein Zwang, kein Zeitdruck. |
| Challenge Support | Hilfe bei Unsicherheit. | Kurzer Hinweis auf Form oder Kategorie. | Companion darf die Loesung nicht verraten. |
| Success Reaction | Sichtbare Freude nach richtigem Tap. | `Gut gefunden!` mit kurzer positiver Reaktion. | Nicht zu lang, nicht jedes Mal riesig. |
| Correction Support | Freundliche Reaktion bei Fehler. | `Fast. Schau noch einmal auf die Form.` | Kein harter Fehler, keine Schuld. |
| Next Goal Suggestion | Optionales naechstes Ziel. | `Moechtest du als Naechstes die Gabel lernen?` | Immer freiwillig, kein Druck. |
| Comeback Motivation | Sanfte spaetere Erinnerung. | `Die Schublade wartet noch auf dich.` | Keine harte Streak- oder Verlustlogik. |

## 3. Timing-Regeln

Tali/Vori darf nicht staendig sprechen. Reaktionen sollen kurz, ruhig und an
sinnvollen Momenten erscheinen.

Erlaubte Momente:

- vor dem Tap, wenn der Nutzer Orientierung braucht,
- nach dem Oeffnen, wenn der Inhalt kurz gerahmt wird,
- waehrend der Challenge nur bei Unsicherheit oder nach Fehler,
- nach Erfolg als kurzer Reward-Moment,
- beim freiwilligen naechsten Ziel,
- spaeter als Comeback-Hinweis, wenn ein Ziel offen bleibt.

Nicht erlaubt:

- lange Texte waehrend der Challenge,
- aggressive Unterbrechungen,
- automatische Loesung,
- Dauerkommentar,
- Druck, Schuldgefuehl oder harte Streak-Mechanik,
- Hinweise, die der Nutzer nicht ignorieren oder ueberspringen kann.

## 4. Reaktionspfade

### Positive Reaktion

Ausloeser:

```text
Nutzer tippt den Loeffel richtig.
```

Geplanter Ablauf:

1. Objekt bekommt kurzes positives Feedback.
2. Tali/Vori reagiert freundlich: `Gut gefunden!`
3. Fortschritt wird ruhig sichtbar, z. B. `Schublade 1/3`.
4. Optionales naechstes Ziel erscheint: `Moechtest du als Naechstes die Gabel
   lernen?`

Grenze:

Die Reaktion darf den Erfolg verstaerken, aber nicht laenger als die Aufgabe
selbst wirken.

### Fehlerreaktion

Ausloeser:

```text
Nutzer tippt Gabel oder Messer statt Loeffel.
```

Geplanter Ablauf:

1. Kein harter Fehler-Sound und keine Bestrafung.
2. Tali/Vori reagiert freundlich: `Fast. Schau noch einmal auf die Form.`
3. Der Nutzer bekommt einen zweiten Versuch.
4. Bei wiederholtem Fehler kann die Aufgabe leichter werden.

Grenze:

Tali/Vori darf nicht beschamen, nicht draengen und nicht sofort die Loesung
anzeigen.

### Untaetigkeit

Ausloeser:

```text
Nutzer wartet oder ist unsicher.
```

Geplanter Ablauf:

1. Erst kurze Ruhe lassen.
2. Dann sehr sanfter Hinweis: `In der Schublade ist etwas versteckt.`
3. Hinweis kann ignoriert werden.
4. Kein Countdown, keine Strafe.

Grenze:

Untaetigkeit darf nicht als Fehler behandelt werden.

### Wiederholung

Ausloeser:

```text
Nutzer hat das Wort wiederholt falsch oder bricht ab.
```

Geplanter Ablauf:

1. Tali/Vori bietet leichtere Wiederholung an.
2. Optionaler Satz: `Wir koennen das kurz zusammen ueben.`
3. Alternative: Wort in Backlog/Codex belassen und spaeter wieder anbieten.

Grenze:

Wiederholung ist Hilfe, kein Zwang.

## 5. Companion-Textregeln

Texte sollen:

- kurz sein,
- freundlich sein,
- keine Schuld ausloesen,
- das Ziel klaeren,
- nur bei passenden Momenten erscheinen,
- optional sein.

Beispiele:

| Situation | Geeigneter Text | Nicht geeignet |
| --- | --- | --- |
| Curiosity | `Da koennte etwas drin sein.` | `Du musst jetzt die Schublade oeffnen.` |
| Erfolg | `Gut gefunden!` | `Endlich richtig.` |
| Fehler | `Fast. Schau noch einmal auf die Form.` | `Falsch. Versuch es besser.` |
| Untaetigkeit | `In der Schublade ist etwas versteckt.` | `Du verlierst Zeit.` |
| Naechstes Ziel | `Moechtest du als Naechstes die Gabel lernen?` | `Mach sofort weiter, sonst verlierst du deinen Fortschritt.` |

## 6. Visualisierungen

M10-C erzeugt Dokumentations-/Preview-Dateien unter:

```text
docs/world_design/previews/phase2g_m10c_companion_reaction_flow/
```

Geplante Dateien:

| Datei | Zweck |
| --- | --- |
| `01_companion_reaction_timeline.png` | Timeline vom Curiosity Cue bis zum optionalen naechsten Ziel. |
| `02_success_error_idle_reactions.png` | Vergleich der Success-, Error- und Idle-/Hint-Pfade. |
| `03_companion_boundaries.png` | Grenzen: motivieren ja, loesen/nerven/Druck nein. |
| `README.md` | Zweck, Prueffazit, Grenzen und Blocker. |

Diese Dateien sind Dokumentationsmaterial und keine Spielassets.

## 7. Was M10-C Nicht Entscheidet

M10-C entscheidet nicht:

- finale Companion-UX,
- Companion-Implementierung,
- Voice-/Audio-Ausgabe,
- Animation oder Rive/FX,
- finale Companion-Texte,
- Tali/Vori-Asset-Produktion,
- allgemeines Container-System,
- App-Integration,
- Codefreigabe,
- Asset-Freigabe,
- `frame_started`.

## 8. Stop-Regeln

Stoppen, wenn:

- aus M10-C Companion-Implementierung abgeleitet wird,
- aus M10-C Voice-, Audio- oder Animationsfreigabe abgeleitet wird,
- Companion-UX final entschieden werden soll, bevor M10-C visuell geprueft
  wurde,
- Tali/Vori die Challenge automatisch loest,
- Tali/Vori Druck, Schuldgefuehl oder harte Streak-Mechanik erzeugt,
- aus M10-C App-, Code- oder Assetfreigabe abgeleitet wird.

## 9. Naechster Erlaubter Schritt

Nach M10-C ist erlaubt:

- M10-C visuell pruefen,
- Companion-Reaktionsflow dokumentarisch bestaetigen oder nachbessern,
- M11 Multi-Example Container Flow Previews planen,
- spaeter M10-C2 als Review-Dokument erstellen.

Weiterhin nicht erlaubt:

- Flutter-/Dart-Code,
- App-Integration,
- Tests,
- Spielassets,
- PNGs im Asset-Ordner,
- finales Inselbild,
- `frame_started`,
- Bauzustaende,
- produktive Companion-Implementierung.

## 10. Preview Quality Note

Die M10-C-Preview ist als Dokumentationsmaterial brauchbar.

In `01_companion_reaction_timeline.png` sind einzelne Labels optisch knapp am
Kartenrahmen bzw. wirken nicht ganz sauber eingerahmt, insbesondere lange Titel
wie `Success / Error` und `Next suggestion`. Das blockiert M10-C nicht, weil
keine finale UI und kein Spielasset erzeugt wurde.

Fuer zukuenftige Previews gilt:

- Alle Texte muessen sichtbar innerhalb ihrer Karten, Rahmen oder Panels
  bleiben.
- Kein Label darf aus einer Box herauslaufen.
- Karten brauchen ausreichend Padding.
- Lange Titel muessen umgebrochen, gekuerzt oder mit groesserer Box
  dargestellt werden.
- Vor Commit soll bei neuen Preview-PNGs eine kurze visuelle
  Text-Containment-Pruefung erfolgen.
