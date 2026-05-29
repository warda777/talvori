# Home-Portal, Wheel-Counter und Tali-Emotionen

## 1. Ausgangspunkt

Nach dem Category Design Editor wurde der HomeScreen weiter verfeinert. Der bisherige Bilderrahmen wurde stärker als ruhiges Talvori-Portal gedacht, der Word-Wheel-Counter wurde aus dem Bilderrahmen herausgelöst und Tali wurde von einem einfachen Mascot hin zu einem vorbereiteten Emotion-/Style-System erweitert.

## 2. Home-Portal

Der Bilderrahmen soll nicht mehr als vergrößerbare zweite Hauptaktion wirken. Er dient stattdessen als ruhiger Portal-Bereich, der Atmosphäre, kurze Orientierung und die Home-Identität trägt.

Counter und Wortstatus sollen nicht mehr im Bildrahmen dominieren. Der Play-Button bleibt die klare Hauptaktion zum Lernen.

## 3. Wheel-Counter

Der Counter wie `1/4` zeigt die aktuelle Position in der Word-Wheel und die Gesamtzahl der Wörter in „Meine Wörter“.

Er wurde aus dem Bilderrahmen entfernt und erscheint nun als kleine Neon-Dark-Kapsel im Home-Bereich. Die Kapsel bleibt antippbar und öffnet weiterhin „Meine Wörter“.

Der Counter ist nicht dauerhaft sichtbar. Er wird temporär eingeblendet, wenn die Wheel bewegt wird, bleibt kurz sichtbar und blendet danach wieder aus. Dadurch bleibt der HomeScreen ruhiger und aufgeräumter.

## 4. Tali-Mascot-System

Tali wurde vom einfachen Mascot zu einem vorbereiteten Emotion-System erweitert. Die Grundlage unterstützt Emotionen wie:

- `neutral`
- `happy`
- `thinking`
- `bored`
- `surprised`
- `cool`
- `hurra`
- `embarrassed`
- `sleepy`
- `loveEyes`
- `wink`
- `party`
- `starEyes`

Die Assets liegen unter `assets/images/mascot/`. Die Asset-Auflösung läuft zentral über `TalvoriMascotAssets`, sodass Home und Companion nicht direkt einzelne Bildpfade zusammenbauen müssen.

## 5. Varianten Männlich/Weiblich

Es gibt eine männliche und eine weibliche Mascot-Variante. Nutzer können den Talvori-Stil in den Einstellungen wählen.

Die Auswahl wird lokal über `ProfilePreferences` gespeichert. Home und Companion nutzen anschließend die gewählte Variante. Ziel ist eine spätere Personalisierung, ohne den HomeScreen oder die Companion-UI erneut umbauen zu müssen.

## 6. Emotion-Logik

Emotionen sollen nicht zufällig wechseln. Sie sollen auf konkrete App-Ereignisse reagieren.

Beispiele für die Ziel-Logik:

- `neutral` = Standard
- `bored` = inaktiver Zustand
- `thinking` = KI denkt
- `happy` = erfolgreiche Antwort oder Aktion
- `surprised` = Fehler oder unerwarteter Zustand
- `starEyes` = Belohnung oder Punkte
- `party` / `hurra` = Ziel erreicht

Aktuell ist die technische Grundlage geschaffen. Weitere Event-Hooks können später gezielt ergänzt werden.

## 7. Settings-Integration

In den Einstellungen gibt es eine Auswahl für den Talvori-Stil:

- Weiblich
- Männlich

Diese Auswahl beeinflusst das angezeigte Tali-Asset im Home-/Companion-Bereich.

## 8. Tests

Relevante Checks:

- `flutter test`
- HomeScreen-Tests
- CompanionController-Tests
- SettingsScreen-Tests

Hinweis: Die Tests waren vor Commit grün.

## 9. Aktueller Stand

Home-Portal und Wheel-Counter sind umgesetzt. Tali-Emotionen und männliche/weibliche Varianten sind technisch vorbereitet. Die Assets sind eingebunden und die App kann künftig stärker personalisiert auf Ereignisse reagieren.

## 10. Offene Punkte

- Emotionen weiter gezielt an echte Ereignisse anbinden.
- Mehr Head-/Mikroanimationen für Ja/Nein/Blickrichtungen ergänzen.
- Mascot-Auswahl optisch in den Einstellungen weiter verbessern.
- Home-Portal später weiter mit Mini-Impulsen ausbauen.
- Tali-Assets stilistisch weiter vereinheitlichen, falls einzelne Varianten abweichen.
