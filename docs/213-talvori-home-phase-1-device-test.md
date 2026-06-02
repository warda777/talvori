# Talvori Home Phase 1 Device Test

## 1. Zweck

Dieses Dokument bereitet den finalen Geraetetest der Phase-1-Home-Zentrale vor.

Ziel ist nicht, neue Features zu planen oder direkt zu bauen. Ziel ist, auf einem echten Geraet systematisch zu pruefen, ob die Talvori-Welt-Home-Zentrale als Phase 1 freigegeben werden kann oder ob vor Phase 2 noch konkrete Restpunkte offen sind.

Phase 2 startet erst, wenn dieser Test bestanden oder mit klar begrenzten Restpunkten dokumentiert ist.

## 2. Testumgebung

| Feld | Wert |
| --- | --- |
| Geraet | echtes Testgeraet |
| iOS-/Android-Version | offen |
| Flutter Build | offen |
| Branch | main |
| Commit | 72e495a2 |
| Datum | 2. Juni 2026 |
| Tester | Andreas |

## 3. Pruefliste Home-Zentrale

Legende fuer Ergebnis:

- `bestanden`
- `auffaellig`
- `blockierend`
- `Notiz`

### A. Home normal

| Pruefpunkt | Ergebnis | Notiz |
| --- | --- | --- |
| App startet ohne Crash. | bestanden | Geraetetest bestanden. |
| Home wirkt nicht ueberladen. | bestanden | Home-Zentrale wirkt ruhig genug fuer Phase 1. |
| Globe ist klarer Hero. | bestanden | Globe bleibt Hauptobjekt. |
| Dynamischer Home-Status wirkt passend. | bestanden | Kein Blocker fuer Phase 2. |
| Progress-Pill wirkt nicht stoerend. | bestanden | Progress/Home-Taps werden bei aktivem Chat zuerst abgefangen. |

### B. Globe

| Pruefpunkt | Ergebnis | Notiz |
| --- | --- | --- |
| Globe bleibt gross und zentral. | bestanden | Keine neue Globe-Aenderung im Abschlusscheck. |
| Rotation laeuft sauber. | bestanden | Kein Blocker gemeldet. |
| Network-Lines wirken hochwertig. | bestanden | Kein Blocker gemeldet. |
| Star-Nodes wirken sauber. | bestanden | Kein Blocker gemeldet. |
| Globe bleibt bei Chat/Tastatur stabil. | bestanden | Auf Geraet geprueft: kein Tastatur-/Chat-Zoom. |
| Globe-Tap oeffnet Welt/Startregion. | bestanden | Bei aktivem Chat schliesst erster Tap nur den Chat; zweiter Tap navigiert. |

### C. Background

| Pruefpunkt | Ergebnis | Notiz |
| --- | --- | --- |
| Cyan/lila Background bleibt stimmig. | bestanden | Keine Background-Regression im Abschlusscheck. |
| Sterne sind sichtbar, aber nicht ueberladen. | bestanden | Geraetetest ohne neuen Blocker. |
| Shooting Stars wirken natuerlich. | bestanden | Aktueller Stand fuer Phase 1 akzeptiert. |
| Shooting Stars kommen nicht immer gleich. | bestanden | Aktueller Stand fuer Phase 1 akzeptiert. |
| Keine stoerenden Nebel-/Bogenreste sichtbar. | bestanden | Keine stoerenden Reste gemeldet. |

### D. Plus-/Wheel-Hub

| Pruefpunkt | Ergebnis | Notiz |
| --- | --- | --- |
| Plus ist geschlossen sichtbar. | bestanden | Kein Blocker gemeldet. |
| Plus oeffnet das Wheel. | bestanden | Funktioniert im Home-Test und Geraetetest. |
| Plus wird zu X. | bestanden | Aktueller Zustand fuer Phase 1 akzeptiert. |
| X-Zustand ist farblich klar anders. | bestanden | Aktueller Zustand fuer Phase 1 akzeptiert. |
| 405-Grad-Animation wirkt sauber. | bestanden | Aktueller Zustand fuer Phase 1 akzeptiert. |
| Wheel ist rund/intuitiv drehbar. | bestanden | Kein Blocker gemeldet. |
| Icons sind erreichbar. | bestanden | Kein Blocker gemeldet. |
| Navigation funktioniert. | bestanden | Bei aktivem Chat schliesst erster Tap nur den Chat; danach navigiert der Hub. |
| Geschlossener Zustand wirkt ruhig. | bestanden | Kein Blocker gemeldet. |

### E. Companion / Tali

| Pruefpunkt | Ergebnis | Notiz |
| --- | --- | --- |
| Tali idle sichtbar und passend positioniert. | bestanden | Kein Blocker gemeldet. |
| Tap oeffnet Focus/Bubble. | bestanden | Geraetetest bestanden. |
| Bubble ist lesbar. | bestanden | Scrollbarer Textbereich funktioniert. |
| Chat-Icon funktioniert. | bestanden | Chat/Input oeffnet sauber. |
| Chat oeffnet ohne Globe-Veraenderung. | bestanden | Globe bleibt stabil. |
| Tali/Bubble bleiben ueber der Tastatur sichtbar. | bestanden | Auch bei wachsender Eingabeleiste geprueft. |

### F. Companion-Bubble

| Pruefpunkt | Ergebnis | Notiz |
| --- | --- | --- |
| Text wird nicht abgeschnitten. | bestanden | Bubble ist scrollbar. |
| Langer Text ist scrollbar. | bestanden | Geraetetest bestanden. |
| Quick Actions erscheinen nur bei echten Suggestions. | bestanden | Kein Dauer-Button-Blocker im Standardzustand. |
| Standardzustand ist nicht ueberladen. | bestanden | Fuer Phase 1 akzeptiert. |

### G. Keyboard / Input

| Pruefpunkt | Ergebnis | Notiz |
| --- | --- | --- |
| Input-Bar sitzt korrekt. | bestanden | Tali bleibt ueber der Eingabeleiste, auch wenn sie waechst. |
| Tastatur oeffnet ohne Globe-Zoom. | bestanden | Globe bleibt stabil. |
| Tastatur laesst sich per Swipe/Drag schliessen. | bestanden | Keyboard-Swipe funktioniert. |
| Keine ruckelnden Layoutspruenge sichtbar. | bestanden | Kein Blocker gemeldet. |

### H. Debug / Logs

| Pruefpunkt | Ergebnis | Notiz |
| --- | --- | --- |
| Keine stoerenden `TALVORI_HOME_DEBUG` Logs aktiv. | bestanden | `rg "TALVORI_" lib test` fand nur `TALVORI_TRANSLATION_MODE` als normalen Config-Define. |
| Keine sonstigen stoerenden Home-Debug-Ausgaben sichtbar. | bestanden | Keine temporaeren Companion/Input/Home Layout-Debug-Funktionen gefunden. |
| Falls Debug-Logs vorhanden: Restpunkt dokumentieren. | bestanden | Keine temporaeren Debug-Logs aktiv; nichts zu entfernen. |

## 4. Ergebnisfelder

Diese Felder nach dem Test ausfuellen:

| Bereich | bestanden | auffaellig | blockierend | Notiz |
| --- | --- | --- | --- | --- |
| Home normal | ja | nein | nein | Geraetetest bestanden. |
| Globe | ja | nein | nein | Stabil bei Chat/Tastatur. |
| Background | ja | nein | nein | Fuer Phase 1 akzeptiert. |
| Plus-/Wheel-Hub | ja | nein | nein | Home-Tap-Blocker bei aktivem Chat bestanden. |
| Companion/Tali | ja | nein | nein | Tali bleibt ueber der Eingabeleiste. |
| Companion-Bubble | ja | nein | nein | Bubble ist scrollbar. |
| Keyboard/Input | ja | nein | nein | Swipe, Input-Scrollbar-Fade und Layout bestanden. |
| Debug/Logs | ja | nein | nein | Keine temporaeren Debug-Logs aktiv. |

## 5. Abschlussentscheidung

Phase 1 freigeben?

- [x] Ja
- [ ] Nein
- [ ] Ja mit Restpunkten

Begruendung:

```text
Home-Zentrale wurde auf dem Geraet geprueft. Globe, Background, Plus/Wheel,
Tali, Bubble, Companion-Chat, Keyboard/Input, Draft-Erhalt, Home-Tap-Blocker,
Input-Scrollbar-Fade und Debug/Logs sind bestanden.

Es gibt keine offenen Muss-Punkte vor Phase 2. Phase 2 kann als naechster
Planungsblock starten.
```

## 6. Wenn Phase 1 nicht fertig ist

### Muss vor Phase 2

- keine offenen Muss-Punkte

### Kann spaeter

- Google-Earth-artiger Uebergang zum Welt-Einstieg
- Hintergrund-Modi: Subtil / Atmosphaerisch / Galaxie
- Home-Statuslogik spaeter mit echten Satzfunken-/Review-Daten erweitern

### Optional

- weitere Feinanpassungen nach Phase-2-Kontext

## 7. Naechster Schritt bei bestandenem Test

Wenn dieser Test bestanden ist:

1. Phase 2 planen: lokaler Welt-Einstieg.
2. Globe-Tap fuehrt in die Startregion.
3. Startregion definieren.
4. Eigenen Plot anlegen.
5. Drei Gebaeude einplanen:
   - Haus,
   - Markt,
   - Bibliothek.
6. Erste lokale/mock Ressourcen definieren.

Nicht direkt starten mit:

- Supabase Writes,
- Cloud-Welt,
- Reward Bridge als Vollsystem,
- SRS-/`word_progress`-Migration,
- Social Backend.
