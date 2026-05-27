# Companion Discovery & Smart Tips

## 1. Ausgangsproblem

Der Talvori Companion zeigte bisher im Home Screen vor allem den Browser-Share-Hinweis. Das war der erste sinnvolle kontextbezogene Hinweis, aber noch keine breitere Discovery-Logik.

Ziel ist, dass der Companion lokale Hinweise kennt und Funktionen sichtbar macht, die Nutzer noch nicht ausprobiert haben.

## 2. Ziel

Der Companion soll erkennen, welche Funktionen vermutlich noch nicht genutzt wurden, und dazu kurze Hinweise anzeigen.

Die Hinweise sollen:

- kurz bleiben
- nicht wie ein Tutorial wirken
- lokal entscheidbar sein
- später als Kontextgrundlage für KI-Antworten dienen

## 3. Umsetzung

Neu vorbereitet wurden:

- `CompanionDiscoveryTip`
- `CompanionDiscoveryTipType`
- `CompanionDiscoveryContext`
- `CompanionDiscoveryTipResolver`

Der `HomeScreen` erstellt einen lokalen `CompanionDiscoveryContext` und lässt den Resolver daraus einen passenden Tipp wählen. Der gefundene Tipp wird über den bestehenden `CompanionController` angezeigt.

Der Companion bleibt damit UI-seitig gleich angebunden: Die Bubble kommt weiterhin aus dem Companion-State, und der bestehende Idle-/Compact-Timer bleibt aktiv.

## 4. Aktuelle unterstützte Tipp-Typen

- `browserShare`
- `wordGames`
- `dailyImpulse`
- `wordWorlds`
- `learningLevels`
- `languageTools`
- `motivation`

Die Typen `myWords` und `favorites` sind im Enum bereits vorbereitet, werden in der ersten Resolver-Reihenfolge aber noch nicht aktiv priorisiert.

## 5. Anti-Nerv-Regeln

Aktuell gilt:

- maximal ein automatischer Discovery-Tipp pro `HomeScreen`-Instanz
- Guard: `_didShowInitialCompanionDiscoveryTip`
- die Bubble verschwindet über die bestehende Idle-/Compact-Logik
- Nutzer können den Companion weiterhin manuell antippen und zwischen aktivem und kompaktem Zustand wechseln

Es gibt noch keine Tagespersistenz für Hinweise.

## 6. Was bewusst noch nicht umgesetzt ist

- keine KI-API
- keine Chat-Persistenz
- keine Tagespersistenz für Hinweise
- keine Premium-/Paketlogik
- keine komplexe Nutzungstelemetrie
- keine dauerhafte Companion-Einstellung

## 7. Nächste Schritte

- echte Nutzungsflags speichern
- Favoriten-/Meine-Wörter-Discovery fachlich priorisieren
- Einstellungen für Companion-Hinweise ergänzen
- Anti-Nerv-Regeln pro Tag oder Session persistieren
- später KI-Kontext aus den Discovery-Daten speisen
