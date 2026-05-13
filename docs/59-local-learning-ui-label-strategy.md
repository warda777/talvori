# 59 Local Learning UI Label Strategy

Stand: 2026-05-13

## Zweck

Dieses Dokument plant eine konkrete UI-Text- und Labelstrategie fuer eine spaetere lokale Lernoberflaeche.

Es ist nur Planung:

- kein Code
- keine UI-Aenderung
- keine Supabase-Aenderung
- keine App-Flow-Aenderung
- keine Aenderung an `main.dart`
- keine Aenderung an `word_providers.dart`
- keine Aenderung an `learn_mode_controller.dart`
- keine Aenderung an `learn_mode_screen.dart`

## Grundprinzip

Die lokale Lernoberflaeche soll normale Nutzer fuehren, nicht SRS-Fachbegriffe erklaeren.

Deshalb gilt:

- technische Begriffe bleiben intern
- sichtbare Labels beschreiben die Nutzerabsicht
- keine versteckten Gesten fuer Moduswechsel
- keine Hauptbegriffe wie `T-SRS`, `A-SRS`, `Hybrid`
- keine alleinige Nutzerfuehrung ueber `S0`, `S1`, `S2` usw.

## 1. Lernmodi

### time

Empfohlener Nutzername:

- **Nach Zeitplan**

Begruendung:

- beschreibt den Kern: Karten werden nach faelligen Zeitabstaenden wiederholt
- kurz und verstaendlich
- vermeidet `T-SRS`

Optionaler kurzer Hilfstext fuer spaeter:

- "Wiederhole, was heute faellig ist."

### adaptive

Empfohlener Nutzername:

- **Intensiv lernen**

Begruendung:

- passt zur V1-Regel: kein hartes Tageslimit, keine Zeitblockade, bewusstes Durcharbeiten vieler Karten
- gut fuer Pruefungs- und Fokusphasen
- vermeidet `A-SRS`

Optionaler kurzer Hilfstext fuer spaeter:

- "Lerne viele Karten aktiv in deinem Tempo."

### hybrid

Empfohlener Nutzername:

- **Ausgewogen lernen**

Begruendung:

- beschreibt die Mischung aus freier frueher Lernphase und kuerzeren zeitbasierten Wiederholungen in hoeheren Stufen
- klingt natuerlich und nicht technisch
- vermeidet `Hybrid` als sichtbaren Hauptbegriff

Optionaler kurzer Hilfstext fuer spaeter:

- "Kombiniert aktives Lernen mit geplanten Wiederholungen."

## 2. Trainingsbereiche

### all

Empfohlener Nutzername:

- **Alles lernen**

Begruendung:

- umfasst neue Karten und Wiederholungen
- kurz und klar
- vermeidet technische S0-S5-Fuehrung

Optionaler kurzer Hilfstext fuer spaeter:

- "Neue und bekannte Karten gemischt."

### reviewOnly

Empfohlener Nutzername:

- **Nur wiederholen**

Begruendung:

- macht klar, dass keine neuen Karten eingefuehrt werden
- ist verstaendlicher als `S1-S5`

Optionaler kurzer Hilfstext fuer spaeter:

- "Keine neuen Karten in dieser Session."

### focused

Empfohlener Nutzername:

- **Gezielt üben**

Begruendung:

- beschreibt den Fokus-Charakter
- passt zur V1-Regel: keine normale SRS-Progression
- vermeidet `Single`

Optionaler kurzer Hilfstext fuer spaeter:

- "Fokus-Training ohne normalen Fortschrittswechsel."

## 3. Stufen S0 Bis S5

Interne Werte bleiben:

- `S0`
- `S1`
- `S2`
- `S3`
- `S4`
- `S5`

Empfohlene Nutzerlabels:

- S0: **Neu**
- S1: **Begonnen**
- S2: **Im Aufbau**
- S3: **Gefestigt**
- S4: **Sicher**
- S5: **Langzeit**

Begruendung:

- Die Labels beschreiben den Lernzustand statt die Technik.
- S5 klingt nicht wie "fertig", sondern wie ein wiederholbarer Langzeitstatus.
- Das passt zur V1-Regel: S5 bleibt aktiv und wiederholbar.

Empfehlung fuer Anzeige:

- In normalen Nutzeroberflaechen zuerst das Label zeigen, z. B. **Gefestigt**.
- Technische Kuerzel wie `S3` hoechstens klein, optional oder in Debug-/Detailansichten zeigen.

[PRÜFEN] Ob der erste lokale Testscreen die Kuerzel `S0-S5` klein anzeigen darf, um Entwicklung und QA zu erleichtern.

## 4. Buttontexte

### Start / Fortsetzen

Empfohlene Texte:

- Wenn keine aktive Session existiert: **Session starten**
- Wenn aktive Session existiert: **Session fortsetzen**

Alternative fuer sehr einfache Testoberflaeche:

- **Starten**
- **Fortsetzen**

Empfehlung:

- Fuer den lokalen Testscreen sind **Starten** und **Fortsetzen** ausreichend.
- Fuer spaetere Produkt-UI ist **Session starten** / **Session fortsetzen** klarer.

### Richtig

Empfohlener Text:

- **Richtig**

Begruendung:

- kurz
- eindeutig
- passt zur Engine-Antwort `ReviewAnswer.correct`

### Falsch

Empfohlener Text:

- **Falsch**

Begruendung:

- kurz
- eindeutig
- passt zur Engine-Antwort `ReviewAnswer.wrong`

Hinweis:

- Spaeter koennte "Nochmal üben" freundlicher wirken, aber fuer V1 ist **Falsch** klarer und testbarer.

### Session Abschliessen

Empfohlener Text:

- **Session abschließen**

Begruendung:

- beschreibt die Aktion genau
- passt zu `completeIfFinished(...)`

### Weitere Session Starten

Empfohlener Text:

- **Weitere Session starten**

Begruendung:

- passt besonders zu `Intensiv lernen`, wo Nutzer bewusst weiterlernen duerfen
- vermeidet automatischen Endlos-Refill
- macht klar, dass eine neue Session eine Nutzerentscheidung ist

## 5. Zustandstexte

### initial

Moeglicher Text:

- **Bereit zum Lernen**

Moegliche Beschreibung:

- "Starte eine lokale Session, wenn du loslegen moechtest."

Fuer Testscreen erlaubt:

- **Noch keine Session**

### loading

Moeglicher Text:

- **Wird geladen...**

Fuer Testscreen erlaubt:

- **Lädt...**

Hinweis:

- Kein spezifischer Text wie "Supabase wird geladen", weil die lokale Oberflaeche offline-first ist.

### error

Moeglicher Text:

- **Etwas ist schiefgelaufen**

Moegliche Beschreibung:

- "Bitte versuche es erneut."

Wichtig:

- Der technische `errorMessage`-Wert sollte fuer Debug/Test sichtbar sein duerfen.
- Produkt-UI sollte spaeter freundlichere Fehlertexte zentralisieren.

### active card

Moeglicher Zustandstitel:

- **Aktuelle Karte**

Inhalt:

- `term`
- `translation`
- `exampleSentence`
- `notes`
- `currentStage`
- Fortschritt

Fuer Testscreen erlaubt:

- direkte Anzeige der vorhandenen Felder ohne aufwendige Produktkopie

### no current card

Moeglicher Text:

- **Keine aktuelle Karte**

Moegliche Beschreibung:

- "Pruefe, ob die Session abgeschlossen werden kann."

Wichtig:

- Keine automatische neue Session starten.
- Keine automatische neue Karte nachladen.

### completed

Moeglicher Text:

- **Session abgeschlossen**

Moegliche Beschreibung:

- "Du kannst spaeter weitermachen oder bewusst eine weitere Session starten."

Fuer `Intensiv lernen` besonders passend:

- **Weitere Session starten**

## 6. Was Im Testscreen Erlaubt Ist

Ein isolierter lokaler Testscreen darf einfache, neutrale Texte verwenden.

Erlaubt:

- **Starten**
- **Fortsetzen**
- **Richtig**
- **Falsch**
- **Session abschließen**
- **Weitere Session starten**
- **Lädt...**
- **Keine aktuelle Karte**
- **Session abgeschlossen**
- sichtbare technische IDs oder Stufen klein fuer QA, falls klar als Debug/Test markiert

Noch nicht als finale Produktkopie verstehen:

- Debug-Labels
- technische IDs
- einfache Empty-State-Texte
- rohe Fehlerdetails

Wichtig:

- Der Testscreen darf nicht so wirken, als waere damit die finale UX fuer Launch entschieden.

## 7. Was Vermieden Werden Muss

Nicht als sichtbare Hauptbegriffe verwenden:

- `T-SRS`
- `A-SRS`
- `Hybrid`
- `AUTO`
- `SINGLE`
- `S0-S5` als alleinige Nutzerfuehrung
- `T1`, `A1`, `H1` usw.

Nicht mehr verwenden:

- Longpress-Hinweise fuer Hybrid
- versteckte Moduswahl per Longpress
- Switch zwischen A-SRS und T-SRS
- technische Stage-Prefixe als primäre Navigation

Nicht in lokale UI-Texte mischen:

- Supabase-Begriffe
- Datenbank-/SQLite-Begriffe
- Engine-Begriffe wie `pass_count`, `next_due_at`, `retryPending`

Ausnahme:

- Debug-/QA-Ausgaben in einem isolierten Testscreen duerfen technische Details zeigen, wenn sie klar nicht Produkt-UI sind.

## 8. Spaeter Zu Zentralisierende Texte

Spaeter sollten zentralisiert werden:

- Lernmodusnamen
- Trainingsbereichsnamen
- Stufenlabels
- Buttontexte
- Zustandstitel
- Empty-State-Texte
- Error-Texte
- Completion-Texte
- kurze Hilfstexte/Tooltips

Moeglicher spaeterer Ort:

- ein lokaler Label-/Text-Mapper im UI-neutralen Bereich
- spaeter eventuell App-Lokalisierung, falls Talvori mehrsprachig wird

Wichtig:

- Der `LocalLearningScreenContract` bleibt textfrei.
- Der `localLearningScreenContractProvider` bleibt textfrei.
- Texte sollten nicht in Engine, Repository oder SQLite-Schicht wandern.

## 9. Kleinster Naechster Schritt

Der kleinste naechste Schritt ist weiterhin planend:

1. Einen isolierten lokalen Testscreen planen.
2. Darin nur die lokale Provider-Kette verwenden:
   - `localLearningViewModelProvider`
   - `localLearningScreenContractProvider`
   - `localLearningControllerProvider.notifier` fuer erlaubte Aktionen
3. Keine bestehende Navigation veraendern.
4. Keine bestehende UI-Datei anfassen.
5. Keine finalen Produkttexte erzwingen.

Alternative, falls noch kein Screen geplant werden soll:

1. Einen UI-neutralen Label-Mapper planen.
2. Dieser wuerde Enums/Stages in die empfohlenen Labels mappen.
3. Erst danach einen Testscreen planen.

## Klare Empfehlung

Fuer Version 1 der lokalen Lernoberflaeche:

- `time` -> **Nach Zeitplan**
- `adaptive` -> **Intensiv lernen**
- `hybrid` -> **Ausgewogen lernen**
- `all` -> **Alles lernen**
- `reviewOnly` -> **Nur wiederholen**
- `focused` -> **Gezielt üben**
- S0-S5 -> **Neu**, **Begonnen**, **Im Aufbau**, **Gefestigt**, **Sicher**, **Langzeit**

Der naechste sichere Schritt ist nicht der Umbau des bestehenden Lernscreens, sondern die Planung eines isolierten lokalen Testscreens oder eines UI-neutralen Label-Mappers.
