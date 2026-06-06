# Phase 2G-M13-B: Early Island Onboarding Choice Review

Stand: 2026-06-06

Status: `Planung gestartet / Previews erzeugen`

## 1. Zweck

Dieses Dokument klaert, wie Nutzer am Anfang zwischen den Foundation-
Kandidaten waehlen koennen, ohne dass Talvori eine feste Startinsel, einen
Pflicht-Hausstart oder eine irreversible Roadmap-Entscheidung erzwingt.

M13-B ist eine Planungsgrundlage und ein Onboarding-Choice-Review. Es ist keine
finale Onboarding-UI, keine finale Startinsel, keine finale Roadmap, keine
App-Integration, keine Runtime-Konfiguration, keine Assetfreigabe und keine
ThemeIsland-Umsetzung.

## 2. Ausgangslage Aus M13-A2

M13-A2 bestaetigt M13 als ersten brauchbaren ThemeIsland Roadmap Draft. Die
Foundation-Welle enthaelt drei fruehe Kandidaten:

- Zuhause / Alltag
- Schule / Lernen
- Garten / Natur nah

Diese drei Kandidaten sind bewusst als fruehe Auswahlmoeglichkeiten zu lesen,
nicht als finale Startinsel. M13-B prueft deshalb die Frage, wie Nutzer im
Onboarding eine persoenliche Richtung waehlen koennen, ohne dass Talvori ihnen
einen einzigen Startpfad aufzwingt.

## 3. Foundation-Kandidaten

### 3.1 Zuhause / Alltag

| Aspekt | Bewertung |
| --- | --- |
| Vorteil | Sehr vertraut, alltagsnah, viele sofort verstaendliche Woerter. |
| Erste Container | Schublade, Regal, Kiste, ggf. Eingangsablage. |
| Beispielwoerter | `spoon`, `key`, `window`, `chair`, `table`. |
| Risiko | Darf nicht als Pflicht-Hausstart wirken. |
| Risiko | Kann zu stark wie ein klassisches Hausbau-Spiel wirken. |
| Gate | Nutzer muss freiwillig waehlen; Zuhause ist nur eine Option. |

Zuhause / Alltag ist stark, weil der Nutzer schnell versteht, warum kleine
Alltagswoerter in Container und Raeume passen. Gleichzeitig darf diese Option
Talvori nicht auf ein Hausbau-Spiel reduzieren.

### 3.2 Schule / Lernen

| Aspekt | Bewertung |
| --- | --- |
| Vorteil | Passt stark zum Lernkontext und hat klare Lernobjekte. |
| Erste Container | Federmappe, Buecherregal, Schulranzen, Tischfach. |
| Beispielwoerter | `pencil`, `ruler`, `book`, `eraser`, `notebook`. |
| Risiko | Kann trocken, schulisch oder verpflichtend wirken. |
| Risiko | Viele Kleinteile brauchen Mobile-/Clutter-Regeln. |
| Gate | Emotionale Darstellung noetig; nicht wie Arbeitsblatt. |

Schule / Lernen kann einen sehr klaren Lernfokus geben, muss aber spielnah und
freundlich wirken. Die Option darf nicht das Gefuehl erzeugen, dass Talvori nur
eine digitale Schulaufgabe ist.

### 3.3 Garten / Natur Nah

| Aspekt | Bewertung |
| --- | --- |
| Vorteil | Freundlich, wachstumsnah, starke Symbolik fuer Lernfortschritt. |
| Erste Container/Fokusobjekte | Beet, Pflanzkiste, Samenbeutel, Geraeteecke. |
| Beispielwoerter | `seed`, `watering can`, `flower`, `soil`, `leaf`. |
| Risiko | Wachstum, Timer und Fairness muessen separat geregelt werden. |
| Risiko | Darf keine manipulative Warte- oder Retention-Mechanik erzeugen. |
| Gate | Fairness-/Timer-Regeln vor Umsetzung. |

Garten / Natur nah ist emotional stark und eignet sich fuer Fortschrittsbilder.
Die Option muss aber vermeiden, Lernfortschritt an Druck, harte Timer oder
kuenstliche Wartebarrieren zu knuepfen.

## 4. Onboarding-Choice-Prinzipien

- Kein Nutzer muss mit Haus/Zuhause starten.
- Die erste Wahl soll als persoenlicher Lernfokus wirken, nicht als
  irreversible Entscheidung.
- Tali/Vori darf kurz erklaeren, aber nicht draengen.
- Die Auswahl soll wenige Optionen zeigen, nicht alle Roadmap-Wellen.
- Die Auswahl soll neugierig machen, aber keine falschen Versprechen geben.
- Foundation-Kandidaten bleiben planbare Startoptionen, keine finale
  Startinsel.
- Nutzer kann spaeter weitere Inseln oder Themen freischalten.
- Woerter ohne passende Startinsel landen sicher in Codex, Backlog oder
  Blueprint.
- Die Auswahl darf keine ThemeIsland-Implementierung ausloesen.
- Kein Paywall- oder Premium-Druck im Onboarding.

## 5. Onboarding-Varianten

| Variante | Beschreibung | Vorteil | Risiko | Bewertung |
| --- | --- | --- | --- | --- |
| `Single recommended start` | System schlaegt eine Startinsel vor. | Sehr einfach und schnell. | Kann wie Pflichtpfad wirken. | Nur mit starker Opt-out-Logik geeignet. |
| `Three-card choice` | Nutzer waehlt zwischen Zuhause, Schule und Garten. | Klare Agency und transparente Optionen. | Entscheidung kann ueberfordern. | Gut, wenn Karten sehr einfach bleiben. |
| `Question-based routing` | Tali/Vori fragt nach Lerninteresse und routet Vorschlag. | Persoenlich und companion-nah. | Mehr UX-Komplexitaet. | Stark fuer Produktgefuehl, aber nicht allein ausreichend. |
| `Starter test flow` | Nutzer loest erst Mini-Challenge, danach folgt Vorschlag. | Aktiv und spielerisch. | Mehr Aufwand vor Auswahl. | Spaeter wertvoll, fuer ersten Onboarding-Entwurf zu schwer. |
| `Hybrid` | Kurze Frage, drei Karten, bestaetigen, spaeter aenderbar. | Gute Balance aus Agency, Klarheit und persoenlicher Empfehlung. | Braucht gute Textlaenge und klare Reversibilitaet. | Beste erste Planungsrichtung. |

## 6. Vorlaeufige Empfehlung

M13-B sollte fuer die erste Planungsrichtung `Hybrid` bevorzugen:

1. Tali/Vori stellt eine kurze Frage nach dem ersten Lernfokus.
2. Das System zeigt drei Foundation-Karten: Zuhause / Alltag, Schule / Lernen
   und Garten / Natur nah.
3. Die Karten zeigen nur wenige Beispielwoerter und keine volle Roadmap.
4. Der Nutzer waehlt und bestaetigt.
5. Die Wahl bleibt spaeter aenderbar.
6. Nicht passende Woerter gehen sicher in Codex, Backlog oder Blueprint.

Diese Empfehlung ist keine finale Onboarding-UI. Sie legt keine Startinsel
final fest und gibt keine Onboarding-Implementierung frei.

## 7. Beispiel-Flow

1. Welcome: Talvori begruesst den Nutzer kurz.
2. Tali/Vori sagt sinngemaess: "Womit moechtest du zuerst lernen?"
3. Nutzer sieht drei ruhige Foundation-Karten.
4. Nutzer waehlt eine Richtung, z. B. Garten / Natur nah.
5. System zeigt eine kurze Bestaetigung: "Du kannst spaeter wechseln."
6. Der Startbereich wird nur als sicherer Lernfokus geplant.
7. Unpassende Woerter bleiben in Codex, Backlog oder Blueprint.

## 8. Safe Backlog-Regel

Die erste Wahl darf keine Woerter verlieren. Wenn ein Wort nicht zur gewaehlten
Foundation-Richtung passt, darf es nicht falsch platziert werden. Stattdessen
wird es sicher behandelt:

- `CodexEntry`: Wort wird erklaert und gelernt, ohne sichtbare Platzierung.
- `BlueprintEntry`: Wort kann spaeter an passender Stelle gebaut werden.
- `WordObjectBacklog`: Wort wartet auf passende ThemeIsland, Depth-Ebene oder
  Nutzerentscheidung.
- `FutureIslandSuggestion`: Tali/Vori kann spaeter eine passende Insel
  vorschlagen.

## 9. Visualisierungsplan

M13-B erzeugt Dokumentationspreviews unter:

`docs/world_design/previews/phase2g_m13b_early_island_onboarding_choice/`

Geplante Dateien:

| Datei | Zweck |
| --- | --- |
| `01_onboarding_choice_flow.png` | Zeigt Welcome, kurze Tali/Vori-Erklaerung, Wahl, Bestaetigung, aenderbare Auswahl und sicheren Backlog. |
| `02_foundation_choice_cards.png` | Zeigt Zuhause, Schule und Garten mit Vorteil, Risiko, Gate und Beispielwoertern. |
| `03_onboarding_variant_comparison.png` | Vergleicht Single recommendation, Three-card choice, Question routing, Starter test flow und Hybrid. |
| `04_no_forced_start_guardrails.png` | Zeigt Stop-Regeln gegen Pflichtstart, Lock-in, Premium-Druck, automatische Platzierung und Umsetzung. |
| `README.md` | Zweck, Grenzen, Prueffazit und Nicht-Freigaben. |

Die Previews sind keine finale UI, keine Spielassets und keine App- oder
Assetfreigabe.

## 10. Prueffazit

Die Foundation-Wahl ist als Onboarding-Planung sinnvoll, wenn sie als
persoenlicher Lernfokus gestaltet wird. Der `Hybrid`-Ansatz wirkt fuer den
aktuellen Planungsstand am staerksten, weil er Nutzerentscheidung,
Tali/Vori-Kontext und spaetere Aenderbarkeit kombiniert.

Kritisch bleibt:

- Zuhause darf nicht als Pflicht-Hausstart gelesen werden.
- Schule darf nicht trocken oder kleinteilig ueberladen wirken.
- Garten darf keine manipulative Timer-/Growth-Retention erzeugen.
- Die erste Wahl darf nicht irreversibel sein.
- Unpassende Woerter muessen in Codex, Blueprint oder Backlog sicher bleiben.

## 11. Stop-Regeln

Aus M13-B darf nicht abgeleitet werden:

- keine finale Startinsel aus M13-B,
- kein Pflicht-Hausstart aus M13-B,
- keine finale Onboarding-UI aus M13-B,
- keine Onboarding-Implementierung aus M13-B,
- keine automatische Wortplatzierung aus M13-B,
- keine ThemeIsland-Umsetzung aus M13-B,
- keine Assets aus M13-B,
- keine irreversible Erstwahl,
- keine Premium-/Paywall-Logik im Start-Onboarding,
- keine Foundation-Insel ohne spaetere Device-/Accessibility-/Tap-Target-
  Pruefung,
- kein Garten-/Growth-Start ohne Fairness-/Timer-Regeln,
- keine App- oder Assetfreigabe aus M13-B,
- kein `frame_started` oder Bauzustand aus M13-B.

## 12. Naechster Erlaubter Schritt

Erlaubt ist nur:

- M13-B visuell pruefen,
- M13-B dokumentarisch nachbessern,
- M13-C ThemeIsland Capability Sheets als reinen Planungsblock starten,
- M13-D Word-to-Island UX Flow als reinen Planungsblock starten,
- Device-/Accessibility-/Tap-Target-Pruefung planen.

Weiterhin nicht erlaubt:

- Flutter-/Dart-Code,
- App-Integration,
- Tests,
- Spielassets,
- PNGs im Asset-Ordner,
- finale Onboarding-UI,
- finale Startinsel,
- ThemeIsland-Umsetzung,
- Runtime-Konfiguration,
- `frame_started`,
- Bauzustaende.
