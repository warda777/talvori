# Chat-Naming und Snackbar-Status

## 1. Ausgangsproblem

Der Bereich hieß bisher „Impuls-Postfach“. Für den neuen Messenger- und KI-Chat-Bereich war dieser Name zu technisch und zu sperrig.

Der Companion-Chat hieß sichtbar „Talvori Companion“. Gleichzeitig waren Snackbars teilweise noch transparent oder im alten Stil dargestellt und dadurch schlecht lesbar. Der kompakte Home-Companion nutzte außerdem das `bored`-Maskottchen, was im Ruhemodus zu negativ wirkte.

## 2. Ziel

Der Bereich soll als moderner Chat-Hub wirken.

- Neuer Bereichstitel: **Talvori Chat**
- Neuer Untertitel: **Dein Ort für Tali, Wortwelten und fokussierte Lernchats.**
- Companion-Name nutzerseitig: **Tali**
- Interne Thread-ID bleibt stabil: `talvori-companion`
- Snackbars werden zentral im Talvori Dark-Neon-Stil dargestellt.
- Der inaktive Companion nutzt `idle` statt `bored`.

## 3. Umsetzung

Die sichtbaren Texte im bisherigen Impuls-Postfach/Chat-Bereich wurden auf **Talvori Chat** umgestellt. Der Companion-Chat wird nutzerseitig als **Tali** angezeigt.

Die technische Thread-ID bleibt unverändert `talvori-companion`, damit bestehende Verläufe kompatibel bleiben. Bestehende Companion-Threads werden beim Laden sichtbar auf den Titel **Tali** normalisiert, ohne die stabile ID zu ändern.

Der Tali-Chat nutzt ein Maskottchen-Asset als Avatar, damit er in Chatliste und Chat-Detail persönlicher wirkt.

Der kompakte Companion-Zustand nutzt jetzt `TalvoriMascotMood.idle` statt `TalvoriMascotMood.bored`.

Für Snackbars wurde eine zentrale UI-Datei eingeführt:

- `lib/core/ui/talvori_snackbar.dart`

Zusätzlich wurde das globale Snackbar-Theme angepasst:

- `lib/core/theme/app_theme.dart`

Direkte Snackbar-Aufrufe in den UI-Dateien wurden auf `TalvoriSnackBar` umgestellt.

## 4. Snackbar-Design

Snackbars nutzen jetzt einen einheitlichen Talvori Dark-Neon-Stil:

- dunkler Hintergrund
- weiße, gut lesbare Schrift
- neonfarbener Akzent für Rand und Icon
- `SnackBarBehavior.floating`
- abgerundete Ecken
- keine transparenten, schlecht lesbaren Standard-Snackbars
- zentrale Nutzung über `TalvoriSnackBar.show(...)`

Der Helper unterstützt aktuell Info-, Success-, Warning- und Error-Varianten sowie Custom-Content für komplexere Toasts.

## 5. Suchprüfung

Die Suche nach `SnackBar(` und `showSnackBar` zeigt direkte Erzeugung bzw. Anzeige nur noch im zentralen Helper `lib/core/ui/talvori_snackbar.dart`.

`course_screen.dart` enthält weiterhin `_showTagesimpulsSnackBar(...)`, diese Methode delegiert intern aber an `TalvoriSnackBar.show(...)`.

`incoming_shared_text_import_listener.dart` nutzt weiterhin `hideCurrentSnackBar()`. Das ist bewusst erlaubt, weil dort nur die aktuell sichtbare Snackbar geschlossen wird, bevor zur Wortliste navigiert wird.

## 6. Tests

Gelaufen sind:

- `flutter test`
- `git diff --check`
- `test/core/ui/talvori_snackbar_test.dart`
- relevante Companion-, Home- und Impuls-Postfach-Tests im Rahmen der vollständigen Testsuite

Hinweis: `dart analyze lib` scheitert weiterhin an bestehenden, nicht zu diesem Block gehörenden Altproblemen. Die gezielte Analyse der relevanten Snackbar-Dateien war erfolgreich.

## 7. Aktueller Stand

Der Chat-Bereich heißt jetzt **Talvori Chat**.

Der persönliche Companion heißt nutzerseitig **Tali**.

Der Companion-Thread bleibt technisch kompatibel über `talvori-companion`.

Snackbars sind zentralisiert und verwenden den Dark-Neon-Stil.

Der Home-Ruhemodus wirkt neutraler und positiver, weil er `idle` statt `bored` verwendet.

## 8. Offene Punkte

- Tali-spezifische Detaildarstellung im Chat weiter verbessern.
- Companion-Einstellungen später ergänzen.
- Snackbars auf echtem Gerät weiter visuell prüfen.
- Optional weitere Doku/Design-Guidelines für die Talvori Dark-Neon-UI ergänzen.
