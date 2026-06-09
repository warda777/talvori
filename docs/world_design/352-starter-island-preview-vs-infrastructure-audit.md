# M16-BB: Starter Island Preview vs Infrastructure Strategy Audit

Stand: 2026-06-09

Status: `Audit-/Dokumentations-Slice / keine Implementierung`

## 1. Zweck

M16-BB prueft die aktuelle lokale Starter-Island-Preview gegen die
Infrastrukturstrategie aus M16-BA. Ziel ist eine fachliche Entscheidung, ob die
vorhandene Preview als Grundlage fuer weitere UI-, Wheel-, BuildChoice- oder
Spielmoment-Code-Slices taugt.

Dieser Slice ist ein Audit. Er aendert keinen Code und gibt keine produktive
Mechanik frei.

## 2. Non-Goals und Stop-Regeln

M16-BB erzeugt nicht:

- keine Implementierung,
- keine Flutter-/Dart-Codeaenderung,
- keine App-Integration,
- keine Route,
- keine Navigation,
- keine Tests,
- keine Widget-Tests,
- keine Screenshots als Repo-Artefakte,
- keine Persistenz,
- keine Supabase Writes,
- keine lokalen DB-Writes,
- keine SRS-/`word_progress`-Aenderung,
- keine automatische Wortplatzierung,
- keine Assets,
- keine Asset-Dateien unter `assets/`,
- kein BuildState,
- kein `frame_started`,
- keine Economy-Implementierung,
- keine Muenzen-Implementierung,
- keine BuildChoice-Code-Freigabe.

## 3. Gelesene Grundlagen

| Datei | Audit-Beitrag |
| --- | --- |
| `351-starter-island-infrastructure-strategy-gate.md` | Fuehrende Strategie fuer Grundform, Slot-Zahlen, Templates, Varianten und Unlock-Grenzen. |
| `328-talvori-learning-game-readiness-todo-checklist.md` | M16T-INFRA-IDs, Fortschritt und Stop-Regeln. |
| `336-documentation-map-and-slice-reading-rules.md` | Pflichtfragen zu Infrastruktur-Ebene, UI-Art und Scope. |
| `350-interaction-pattern-decision-matrix.md` | Bewertet direkte Weltaktion, In-place-Wheel, Bottom-HUD und Drag-Grenzen. |
| `lib/features/world/local_world/ui/widgets/starter_island_plot_board_preview.dart` | Aktuelle lokale Starter-Island-Preview. |
| `lib/features/world/local_world/ui/widgets/starter_island_plot_board_preview_main.dart` | Isolierter lokaler Launch-Entry, keine App-Integration. |

## 4. Executive Audit Summary

Audit-Ergebnis:

```text
Teilweise passend, aber nicht bereit fuer den naechsten fachlichen Code-Slice.
Vor weiterem Aufbau-Code ist eine kleine Alignment-Korrektur noetig.
```

Die Preview passt bereits gut zu M16-BA bei:

- zusammenhaengender Insel-Greybox,
- fixer Kueste,
- fixem Fluss/Wasserarm,
- zentraler Hub-Idee,
- Haupt-/Nebenweg-Andeutung,
- Hoehen-/Wald-/Wasserzonen,
- freien Anchors statt vorab gesetzten Kategorien,
- Kategorien als mehrfach nutzbare Templates,
- direkter Weltaktion plus kompakter Kategorieauswahl,
- lokaler Candidate-Preview ohne Persistenz.

Die groesste Abweichung:

- Die Preview zeigt 17 Anchor-Flaechen und macht sie faktisch alle sofort
  nutzbar. M16-BA empfiehlt dagegen 8-12 sichtbare freie Slots, davon 4-6
  sofort nutzbar und 4-6 spaeter als ruhige Erweiterung sichtbar.

Damit ist die Preview als technischer Proof brauchbar, aber als
Starter-Insel-Grundlage noch zu breit und zu "alles sofort verfuegbar".

## 5. Audit-Frage 1: Grundform nach M16-BA

| M16-BA-Kriterium | Preview-Befund | Bewertung |
| --- | --- | --- |
| Zusammenhaengende Insel | `CustomPainter` zeichnet eine zusammenhaengende Landform. | passt |
| Kueste | Aussenrand/shore wird sichtbar gezeichnet. | passt |
| Wasserarm / Fluss | Breiter Fluss/Wasserarm ist als starke Landmarke vorhanden. | passt |
| Hub | Zentraler Anchor `A-HUB-C` und Startslot `P-00` existieren. | passt |
| Hauptwege / Nebenwege | Mehrere Pfadlinien gehen vom Zentrum zu Zonen. Nicht als Haupt/Neben beschriftet, aber visuell angedeutet. | passt teilweise |
| Hoehenzonen | Ridge-/Hoehenlinien sind angedeutet. | passt |
| Waldzonen | Gruene Blobs und Natur-Anchors deuten Wald/Natur an. | passt |
| Wasserzonen | Wasseranker und Flussbereich sind vorhanden. | passt |

Entscheidung:

Die Grundform ist fachlich kompatibel mit M16-BA. Sie ist eine gute Greybox,
solange sie weiterhin als Preview und nicht als finale Insel gelesen wird.

## 6. Audit-Frage 2: Slot-Strategie

Aktueller Code-Befund:

- `_plotAnchors` enthaelt 17 Anchor-Flaechen.
- Alle 17 Anchors werden in der normalen Board-Ansicht als Tap-Ziele gerendert.
- Ein Tap auf einen Anchor oeffnet die Kategorieauswahl.
- Es gibt keine sichtbare Trennung zwischen Startslot und Erweiterungsslot.
- Es gibt keinen gesperrten, ruhigen oder spaeteren Slot-Zustand.

| Frage | Befund | Bewertung |
| --- | --- | --- |
| Wie viele Slots sind sichtbar? | 17 Anchors. | zu viele fuer M16-BA |
| Wie viele wirken sofort nutzbar? | 17, weil alle antippbar sind. | deutlich zu viele |
| Wie viele wirken als spaetere Erweiterung? | 0 explizit. | fehlt |
| Passt das zu 8-12 sichtbar? | Nein, 17 liegt darueber. | Abweichung |
| Passt das zu 4-6 sofort nutzbar? | Nein, alle 17 wirken sofort nutzbar. | Abweichung |
| Passt das zu 4-6 spaeter sichtbar? | Nein, Erweiterungsstatus fehlt. | Abweichung |

Audit-Bewertung:

Die Preview muss vor weiterem Infrastruktur- oder BuildChoice-Code reduziert
oder in sichtbare Slot-Zustaende getrennt werden.

Sichere Zielrichtung:

- 8-12 sichtbare freie Slots in der normalen Ansicht.
- Davon 4-6 sofort nutzbar.
- 4-6 als ruhige Erweiterung sichtbar, aber nicht aktiv waehlen.
- Weitere interne Anchors duerfen als spaetere Reserve im Code vorbereitet
  sein, sollen aber im normalen Nutzerflow nicht sichtbar dominieren.

## 7. Audit-Frage 3: Kategorie-Template-Logik

Aktueller Code-Befund:

- `_wheelCategories` enthaelt 9 Kategorien: Ufer, Zuhause, Markt, Wissen,
  Lager, Garten, Werkstatt, Codex, Safe.
- `_wheelCategoriesForAnchor(_)` gibt alle Kategorien zurueck.
- Kategorien sind dadurch grundsaetzlich ueberall waehlbar.
- `_anchorCategoryIds` speichert lokal pro Anchor eine Kategorie-ID.
- Es gibt keine Uniqueness-Regel, die eine Kategorie nur einmal erlauben
  wuerde.
- Slot + Kategorie + Anchor erzeugt im HUD eine Standortvariante, z. B.
  Kategorie plus `am Ufer`, `zentral`, `am Rand`.

| Kriterium | Befund | Bewertung |
| --- | --- | --- |
| Kategorien mehrfach nutzbar | Ja, keine Einmaligkeitsregel vorhanden. | passt |
| Kategorien nicht als feste Belegung | In der Standardansicht sind keine Kategorien vorab sichtbar. | passt |
| Slot + Kategorie nur lokale Variante | Ja, Auswahl setzt nur lokale Map und HUD/Shape-Preview. | passt |
| Kein Build | Guardrail-Chips und Copy sagen `kein Build`. | passt |
| Kein Placement | Copy sagt `Lokaler Candidate, kein Placement`. | passt |
| Keine Persistenz | Nur `setState` und lokale Map, keine Datenzugriffe. | passt |

Resthinweis:

Die Datenklasse `_PlotAnchor` enthaelt noch `zone` und `allowedFamilies`.
Diese Felder wirken historisch nach harter Filterlogik, werden im normalen
Flow aber nicht mehr fuer Kategorie-Blocking genutzt. Fuer spaetere
Wartbarkeit sollten sie in einem Folge-Code-Slice entweder in
Terrain-/Variant-Hinweise umbenannt oder konsequent nur als interne
Dokumentationshilfe behandelt werden.

## 8. Audit-Frage 4: UI-/Interaction-Pattern nach 350

| Kriterium aus 350 | Preview-Befund | Bewertung |
| --- | --- | --- |
| Direkte Weltaktion | Anchor-Tap auf der Insel oeffnet Auswahl. | passt |
| Wheel nur kurze In-place-Auswahl | Picker ist klein, zeigt Icon + Kurzname und bleibt nahe Anchor. | passt |
| Kein grosses Fenster | Kategorieauswahl ist kein Fullscreen, kein Dialog. | passt |
| Drag nicht Standardflow | Layout-/Drag-Hinweise sind nicht sichtbar; kein normaler Drag-Flow. | passt |
| Bottom-HUD klein | HUD ist reduziert, Details einklappbar. | passt mit Beobachtung |
| Alternative bewusst nicht gewaehlt | Code-Kommentar nennt: kein grosses Fenster, kein Drag als Standard, keine Showcase-Seite fuer kleine Auswahl. | passt |

Beobachtung:

Das Bottom-HUD ist fuer die aktuelle Audit-Preview akzeptabel. Es kann aber
bei Bank-Encounter oder Details schnell dichter wirken. Das ist kein
Blocker fuer die Infrastrukturfrage, sollte aber bei naechster UI-Korrektur
weiter unter Mobile-Dichte beobachtet werden.

Bewusst verworfene Alternativen fuer diesen Flow:

- Showcase-Seite: zu gross fuer einfache Kategorieauswahl.
- Drag/Drop: nicht Standard-Nutzerflow.
- Grosses Wheel/Dialogfenster: zu wenig Island-First.
- Permanente Regeltexte: zu viel Debug-Gefuehl.

## 9. Audit-Frage 5: Infrastruktur-Grenzen

| Grenze | Preview-Befund | Bewertung |
| --- | --- | --- |
| Terrain veraendert? | Nein. Terrain wird nur gezeichnet. | passt |
| Nur Slot genutzt? | Ja. Nutzer waehlt Anchor/Kategorie lokal. | passt |
| Fluss fix? | Ja. Fluss wird im Painter fix gezeichnet. | passt |
| Wege fix? | Ja. Wege werden im Painter fix gezeichnet. | passt |
| Kueste fix? | Ja. Inselrand/shore ist fix. | passt |
| Muenzen/Unlock/Economy? | Nicht vorhanden. | passt |
| BuildChoice-Code? | Kein produktiver BuildChoice-Code. Nur Kategorie-/Shape-Preview und Texte zu spaeteren BuildChoice-Ideen. | passt |
| Persistenz? | Keine DB, kein Provider, kein Supabase, keine Speicherung. | passt |
| App-Integration? | Main-Datei ist isolierter `flutter run -t` Entry. | passt |

Bewertung:

Die Preview wahrt die harten Infrastruktur-Grenzen. Das Problem liegt nicht in
verbotener Persistenz oder Build-Logik, sondern in Slot-Dichte und fehlender
Start-/Expansion-Unterscheidung.

## 10. Audit-Frage 6: Probleme / Abweichungen

| Problem | Risiko | Muss vor weiterem Code angepasst werden? |
| --- | --- | --- |
| 17 sichtbare Anchors | Ueber M16-BA-Budget, wirkt wie zu viele sofortige Moeglichkeiten. | ja |
| Alle Anchors sofort tappbar | Keine 4-6 Startslot-Begrenzung, keine ruhige Progression. | ja |
| Keine sichtbaren Erweiterungsslots | M16-BA-Neugier- und Unlock-Strategie fehlt. | ja |
| Interne `zone`/`allowedFamilies` | Kann spaeter wieder als harte Filterlogik missverstanden werden. | nein, aber im naechsten Code-Slice sauber benennen/pruefen |
| Bottom-HUD kann dicht werden | Mobile-Fokus kann leiden, besonders mit Bank-Bubble. | beobachten |
| Haupt-/Nebenwege nicht explizit geklaert | Grundform sichtbar, aber Strategiebezug nicht ganz lesbar. | optional |

Positive Befunde:

- Insel bleibt Hauptspielraum.
- Freie Slots wirken vor Kategorieauswahl frei.
- Kategorien sind nicht sichtbar vorab gesetzt.
- Kategorieauswahl ist kompakt.
- Kategorien sind ueberall waehlbar.
- Variantentext entsteht aus Standort, nicht als harte Erlaubnis.
- Keine Muenzen, keine Economy, kein BuildState, keine Persistenz.

## 11. Entscheidung

Die aktuelle Code-Preview ist **nicht bereit** fuer den naechsten fachlichen
Aufbau-Code-Slice, wenn dieser auf M16-BA aufbauen soll.

Sie ist bereit als technischer Referenzstand fuer:

- pannbare Insel-Greybox,
- freie Anchor-Taps,
- Kategorie-Templates,
- lokale Candidate-Preview,
- direktes Weltaktionsmuster.

Sie ist nicht bereit als M16-BA-konforme Starter-Insel-Basis, weil:

- zu viele Slots sichtbar sind,
- zu viele Slots sofort nutzbar wirken,
- Erweiterungsslots nicht unterscheidbar sind,
- Startslots und Spaeter-Slots keine klare visuelle Rolle haben.

Kurzentscheidung:

```text
Erst Anpassung noetig.
Kein weiterer BuildChoice-, Wheel- oder Spielmoment-Code auf dieser Slotbasis.
```

## 12. Empfohlener naechster Code-Slice

Empfohlener Folge-Slice:

```text
M16-BC Starter Island Slot Visibility and Expansion State Alignment
```

Ziel:

Die vorhandene Preview an M16-BA ausrichten, ohne neue Systeme zu bauen.

Erlaubte Datei:

- `lib/features/world/local_world/ui/widgets/starter_island_plot_board_preview.dart`

Optional nur falls noetig:

- `lib/features/world/local_world/ui/widgets/starter_island_plot_board_preview_main.dart`

Pflichtkorrekturen:

- Sichtbare normale Slots auf 8-12 reduzieren.
- 4-6 Slots als sofort nutzbar markieren.
- 4-6 Slots als ruhige Erweiterung sichtbar machen.
- Erweiterungsslots nicht normal waehlbar machen.
- Keine Kategorie-Vorgaben vor Auswahl anzeigen.
- Alle freigegebenen Kategorien auf sofort nutzbaren Slots weiterhin
  grundsaetzlich waehlbar halten.
- Terrain nur als Variantenhinweis behandeln.
- Interne `zone`/`allowedFamilies` pruefen: nicht als harte Kategoriefilter
  verwenden.
- Bottom-HUD knapp halten.
- Direktes Weltaktionsmuster + kompakte Kategorieauswahl beibehalten.

Stop-Regeln fuer den Folge-Slice:

- keine Route,
- keine App-Integration,
- keine Navigation,
- keine Home-/main-/Router-/Provider-/Datenlayer-Aenderung,
- keine Persistenz,
- keine Supabase/local DB Writes,
- keine SRS-/`word_progress`-Aenderung,
- keine automatische Wortplatzierung,
- keine Assets,
- kein BuildState,
- kein `frame_started`,
- keine Tests ohne explizite Testfreigabe,
- keine Screenshots als Repo-Artefakte,
- keine Economy- oder Muenzen-Implementierung,
- keine Produktivmechanik-Freigabe.

## 13. 328-Update-Entscheidung

M16-BB erzeugt keine neue M16-T-ID und aendert keine bestehenden ID-Status.

`docs/world_design/328-talvori-learning-game-readiness-todo-checklist.md`
bleibt in diesem Slice unveraendert.

Begruendung:

- M16-BB ist ein Audit gegen bereits erledigte `M16T-INFRA-*`-Regeln.
- Der Befund erzeugt eine Folge-Slice-Empfehlung, aber kein neues dauerhaftes
  Readiness-Item.
- Die noetige Anpassung kann als naechster Code-Slice gegen bestehende
  `M16T-INFRA-*`, `M16T-INTERACT-*`, `M16T-MOBILE-*` und `M16T-WORLD-*`
  Regeln laufen.

## 14. Schlussfolgerung

Die aktuelle Starter-Island-Preview ist konzeptionell in der richtigen Richtung:
eine feste Insel, freie Slots, lokale Kategorie-Templates und keine
Persistenz. Sie braucht jedoch vor weiterem Code eine Slot-Dichte- und
Progressionskorrektur.

Der naechste Schritt sollte nicht neues Gameplay sein, sondern das Board selbst
ruhiger und M16-BA-konform machen:

```text
weniger sichtbare Slots
-> klare Startslots
-> klare Erweiterungsslots
-> Kategorie-Templates bleiben frei
-> kein Build, kein Placement, keine Persistenz
```
