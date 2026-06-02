# Talvori Home Phase 1 Device Test

## 1. Zweck

Dieses Dokument bereitet den finalen Geraetetest der Phase-1-Home-Zentrale vor.

Ziel ist nicht, neue Features zu planen oder direkt zu bauen. Ziel ist, auf einem echten Geraet systematisch zu pruefen, ob die Talvori-Welt-Home-Zentrale als Phase 1 freigegeben werden kann oder ob vor Phase 2 noch konkrete Restpunkte offen sind.

Phase 2 startet erst, wenn dieser Test bestanden oder mit klar begrenzten Restpunkten dokumentiert ist.

## 2. Testumgebung

| Feld | Wert |
| --- | --- |
| Geraet | offen |
| iOS-/Android-Version | offen |
| Flutter Build | offen |
| Branch | offen |
| Commit | offen |
| Datum | offen |
| Tester | offen |

## 3. Pruefliste Home-Zentrale

Legende fuer Ergebnis:

- `bestanden`
- `auffaellig`
- `blockierend`
- `Notiz`

### A. Home normal

| Pruefpunkt | Ergebnis | Notiz |
| --- | --- | --- |
| App startet ohne Crash. | offen |  |
| Home wirkt nicht ueberladen. | offen |  |
| Globe ist klarer Hero. | offen |  |
| Dynamischer Home-Status wirkt passend. | offen |  |
| Progress-Pill wirkt nicht stoerend. | offen |  |

### B. Globe

| Pruefpunkt | Ergebnis | Notiz |
| --- | --- | --- |
| Globe bleibt gross und zentral. | offen |  |
| Rotation laeuft sauber. | offen |  |
| Network-Lines wirken hochwertig. | offen |  |
| Star-Nodes wirken sauber. | offen |  |
| Globe bleibt bei Chat/Tastatur stabil. | offen |  |
| Globe-Tap oeffnet Welt/Startregion. | offen |  |

### C. Background

| Pruefpunkt | Ergebnis | Notiz |
| --- | --- | --- |
| Cyan/lila Background bleibt stimmig. | offen |  |
| Sterne sind sichtbar, aber nicht ueberladen. | offen |  |
| Shooting Stars wirken natuerlich. | offen |  |
| Shooting Stars kommen nicht immer gleich. | offen |  |
| Keine stoerenden Nebel-/Bogenreste sichtbar. | offen |  |

### D. Plus-/Wheel-Hub

| Pruefpunkt | Ergebnis | Notiz |
| --- | --- | --- |
| Plus ist geschlossen sichtbar. | offen |  |
| Plus oeffnet das Wheel. | offen |  |
| Plus wird zu X. | offen |  |
| X-Zustand ist farblich klar anders. | offen |  |
| 405-Grad-Animation wirkt sauber. | offen |  |
| Wheel ist rund/intuitiv drehbar. | offen |  |
| Icons sind erreichbar. | offen |  |
| Navigation funktioniert. | offen |  |
| Geschlossener Zustand wirkt ruhig. | offen |  |

### E. Companion / Tali

| Pruefpunkt | Ergebnis | Notiz |
| --- | --- | --- |
| Tali idle sichtbar und passend positioniert. | offen |  |
| Tap oeffnet Focus/Bubble. | offen |  |
| Bubble ist lesbar. | offen |  |
| Chat-Icon funktioniert. | offen |  |
| Chat oeffnet ohne Globe-Veraenderung. | offen |  |
| Tali/Bubble bleiben ueber der Tastatur sichtbar. | offen |  |

### F. Companion-Bubble

| Pruefpunkt | Ergebnis | Notiz |
| --- | --- | --- |
| Text wird nicht abgeschnitten. | offen |  |
| Langer Text ist scrollbar. | offen |  |
| Quick Actions erscheinen nur bei echten Suggestions. | offen |  |
| Standardzustand ist nicht ueberladen. | offen |  |

### G. Keyboard / Input

| Pruefpunkt | Ergebnis | Notiz |
| --- | --- | --- |
| Input-Bar sitzt korrekt. | offen |  |
| Tastatur oeffnet ohne Globe-Zoom. | offen |  |
| Tastatur laesst sich per Swipe/Drag schliessen. | offen |  |
| Keine ruckelnden Layoutspruenge sichtbar. | offen |  |

### H. Debug / Logs

| Pruefpunkt | Ergebnis | Notiz |
| --- | --- | --- |
| Keine stoerenden `TALVORI_HOME_DEBUG` Logs aktiv. | offen |  |
| Keine sonstigen stoerenden Home-Debug-Ausgaben sichtbar. | offen |  |
| Falls Debug-Logs vorhanden: Restpunkt dokumentieren. | offen |  |

## 4. Ergebnisfelder

Diese Felder nach dem Test ausfuellen:

| Bereich | bestanden | auffaellig | blockierend | Notiz |
| --- | --- | --- | --- | --- |
| Home normal | offen | offen | offen |  |
| Globe | offen | offen | offen |  |
| Background | offen | offen | offen |  |
| Plus-/Wheel-Hub | offen | offen | offen |  |
| Companion/Tali | offen | offen | offen |  |
| Companion-Bubble | offen | offen | offen |  |
| Keyboard/Input | offen | offen | offen |  |
| Debug/Logs | offen | offen | offen |  |

## 5. Abschlussentscheidung

Phase 1 freigeben?

- [ ] Ja
- [ ] Nein
- [ ] Ja mit Restpunkten

Begruendung:

```text
offen
```

## 6. Wenn Phase 1 nicht fertig ist

### Muss vor Phase 2

- offen

### Kann spaeter

- offen

### Optional

- offen

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

