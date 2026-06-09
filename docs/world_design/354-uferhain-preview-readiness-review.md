# M16-BG: Uferhain Preview Readiness Review

Stand: 2026-06-09

Status: `Audit-/Dokumentations-Slice / keine Implementierung`

## 1. Zweck

M16-BG prueft, ob die aktuelle lokale Starter-Island-Preview nach M16-BA bis
M16-BF gut genug als MVP-Greybox-Basis fuer weitere Uferhain-Slices ist.

Der Review entscheidet, ob Talvori als Naechstes mit Spielmomenten,
BuildChoice-/Showcase-Planung oder visueller Uferhain-Greybox-Verfeinerung
weitergehen darf, oder ob vorher Landschaft, Slot-Position, Lesbarkeit,
UI-Dichte oder Interaktionslogik korrigiert werden muessen.

M16-BG ist ein Audit. Es aendert keinen Code und gibt keine produktive
Mechanik frei.

## 2. Non-Goals und Stop-Regeln

M16-BG erzeugt nicht:

- keine Flutter-/Dart-Codeaenderung,
- keine App-Integration,
- keine Route,
- keine Navigation,
- keine neue Seite,
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
- keine Bauzustaende,
- keine Economy-Implementierung,
- keine Muenzen-Implementierung,
- keine BuildChoice-Implementierung,
- keine Produktivmechanik-Freigabe.

Der Review basiert auf Code- und Dokumentenpruefung. Er ersetzt keine
spaetere Device-/Visual-QA mit Screenshot oder Playtest.

## 3. Gelesene Grundlagen

| Datei | Beitrag fuer M16-BG |
| --- | --- |
| `353-starter-island-identity-biome-and-category-scope-gate.md` | Uferhain-Identitaet, Kategorie-Scope, User-facing Naming und BuildChoice-Hierarchie. |
| `351-starter-island-infrastructure-strategy-gate.md` | Starter-Insel-Grundform, Slot-Strategie, fixe Infrastruktur, Templates, Varianten und Unlock-Grenzen. |
| `352-starter-island-preview-vs-infrastructure-audit.md` | Vorheriger Audit-Befund: zu viele sofort nutzbare Anchors, noetige Start-/Expansion-Trennung. |
| `350-interaction-pattern-decision-matrix.md` | UI-Entscheidung: direkte Weltaktion, kompaktes In-place-Wheel, Bottom-HUD, kein Drag als Standardflow. |
| `328-talvori-learning-game-readiness-todo-checklist.md` | M16-T-Status, bestehende INFRA-/INTERACT-Regeln und Stop-Regeln. |
| `336-documentation-map-and-slice-reading-rules.md` | Pflichtfragen fuer kuenftige World-/UI-/BuildChoice-/Implementierungs-Slices. |
| `starter_island_plot_board_preview.dart` | Aktuelle lokale Uferhain-Greybox-Preview. |
| `starter_island_plot_board_preview_main.dart` | Isolierter lokaler Preview-Entry ohne App-Integration. |

## 4. Executive Audit Summary

Audit-Ergebnis:

```text
Bereit als MVP-Greybox-Basis fuer den naechsten kleinen Uferhain-Slice.
Noch nicht bereit als produktionsnahe Insel, finaler BuildChoice-Flow oder
visuelle Demo ohne weitere QA.
```

Die Preview hat die wichtigsten M16-BA/M16-BB-Abweichungen inzwischen
korrigiert:

- 10 sichtbare Slots statt 17 sichtbarer Anchors,
- 5 sofort nutzbare Startslots,
- 5 ruhig sichtbare Erweiterungsslots,
- 7 reservierte Anchors bleiben im normalen Flow unsichtbar,
- Uferhain-Sprache ist sichtbar,
- Codex/Safe sind im normalen sichtbaren Kategorienamen durch Archiv/Spaeter
  ersetzt,
- Kategorien bleiben Haupttemplates,
- Unterideen wie Garage, Terrasse, Pool, Teich oder Outdoor-Sauna bleiben
  BuildChoice-/Showcase-Kandidaten und stehen nicht im ersten Wheel,
- keine harte Terrain-Blockade,
- keine Persistenz, kein BuildState, keine Assets und keine Economy.

Damit ist die Preview fuer einen naechsten kleinen Spielmoment- oder
Planungs-Slice tragfaehig. Sie sollte aber noch nicht als finales UX- oder
Visual-Design gelesen werden.

## 5. Audit-Frage 1: Uferhain-Identitaet

| Kriterium | Befund | Bewertung |
| --- | --- | --- |
| Wirkt die Preview wie Uferhain? | Titel/HUD nennen `Uferhain`; Terrainlabels nennen Uferplatz, zentrale Lichtung, Waldlichtung, Huegelplatz und ruhigen Rand. | passt |
| Kueste erkennbar? | `CustomPainter` zeichnet Ozean, Inselrand und Shore-Lesart. | passt fuer Greybox |
| Flussarm erkennbar? | Breiter Wasserarm wird als zentrale Landmarke gezeichnet. | passt |
| Hain / Waldzone erkennbar? | Gruene Zonen und Waldlichtungs-Slots deuten Hain/Natur an. | passt fuer Greybox |
| Hub / Lichtung erkennbar? | Zentraler Startslot und Top-HUD stützen die Lichtungslesart. | passt |
| Leichte Hoehen erkennbar? | Ridge-/Hoehenlinien und Huegelplatz sind vorhanden. | passt teilweise |
| Ruhige Randbereiche erkennbar? | Erweiterungs-/Spaeter-Orte liegen am Rand und wirken ruhiger. | passt |

Bewertung:

Die Preview wirkt nicht mehr wie eine generische Slot-Liste. Sie liest sich als
pannbare Uferhain-Greybox mit Wasser, Hain, Lichtung, Hoehen und Rand. Die
Atmosphaere bleibt bewusst einfach; fuer eine spielerischere Demo fehlen noch
staerkere Landmarks, Materialitaet und kleine Weltobjekt-Andeutungen. Das ist
aber kein Blocker fuer die naechste fachliche Greybox-Stufe.

## 6. Audit-Frage 2: Slot-Strategie

Aktueller Code-Befund:

- `_plotAnchors` enthaelt 17 lokale Anchors.
- Sichtbar sind nur Anchors mit `state != reserved`.
- Sichtbare Slots: 10.
- Startslots: 5.
- Erweiterungsslots: 5.
- Reserved Slots: 7, im normalen Flow nicht sichtbar.

| Frage | Befund | Bewertung |
| --- | --- | --- |
| 8-12 sichtbare Slots? | 10 sichtbare Slots. | passt |
| 4-6 Startslots? | 5 Startslots. | passt |
| 4-6 Erweiterungsslots? | 5 Erweiterungsslots. | passt |
| Start/Expansion unterscheidbar? | Startslots zeigen `frei`; Expansion zeigt `spaeter` und Lock-Icon. | passt |
| Reserved Slots unsichtbar? | `reserved` wird ueber `isVisible` aus der normalen Darstellung genommen. | passt |
| Slot-Positionen sinnvoll fuer Uferhain? | Startslots liegen bei Hub/Lichtung, Ufer, Hain und Huegel; Expansion liegt bei Markt-/Werkstatt-/Lager-/Archiv-/Spaeter-Zukunftsraeumen. | passt |

Bewertung:

Die Slot-Strategie ist jetzt M16-BA-konform genug. Weitere Anpassungen duerfen
sich auf Lesbarkeit, Atmosphaere oder konkrete Spielmomente konzentrieren,
nicht mehr auf die Grundzahl der Slots.

## 7. Audit-Frage 3: Kategorie-/Template-Logik

| Kriterium | Befund | Bewertung |
| --- | --- | --- |
| Kategorien sind Haupttemplates | Wheel enthaelt Ufer, Zuhause, Markt, Wissen, Lager, Garten, Werkstatt, Archiv und Spaeter. | passt |
| Keine Detailbauten im ersten Wheel | Garage, Terrasse, Pool, Teich, Sauna usw. stehen nicht im Wheel. | passt |
| Archiv statt Codex sichtbar | Wheel, Safe Exit und HUD nutzen Archiv/Wortarchiv. | passt |
| Spaeter statt Safe sichtbar | Wheel, Safe Exit und HUD nutzen Spaeter/Ablage. | passt |
| Unterideen als BuildChoice/Showcase eingeordnet | Details und 353 dokumentieren die Unterauswahl als spaeteren Schritt. | passt |
| Kategorien frei waehlbar | `_wheelCategoriesForAnchor(_)` gibt alle Kategorien zurueck. | passt |
| Keine harte Terrain-Blockade | Terrain erzeugt Variantenlabel, keine Erlaubnis-/Verbotslogik. | passt |

Bewertung:

Die Kategorie-/Template-Logik ist bereit fuer weitere Uferhain-Slices. Wichtig
bleibt: Das erste Wheel darf nicht weiter wachsen. Wenn spaeter mehr
Unterideen oder konkrete Objekte verglichen werden, muss ein
Showcase-/BuildChoice-Gate greifen.

## 8. Audit-Frage 4: Terrain-Varianten

Aktuelle Variantenlogik:

```text
Kategorie + Anchor/Terrain
-> lokaler Variantenname
-> Candidate / Preview
!= Build / Placement / Persistenz
```

| Beispiel | Aktueller Befund | Bewertung |
| --- | --- | --- |
| Zuhause am Ufer | moeglich, wenn Zuhause auf Ufer-/Wassernahe-Slot gewaehlt wird. | passt |
| Markt an der Lichtung | moeglich, wenn Markt auf Lichtungs-/Hub-Slot gewaehlt wird. | passt |
| Garten im Hain | moeglich, wenn Garten auf Hain-/Waldlichtungs-Slot gewaehlt wird. | passt |
| Werkstatt am Rand | moeglich ueber Rand-/Craft-Erweiterung, sobald spaeter nutzbar. | passt |
| Wissen am Huegel | moeglich auf Huegel-/Learn-Slot. | passt |
| Archiv im Uferhain | im Labelmodell vorhanden; im normalen Startflow eher `Archiv am Huegel`, `Archiv am Ufer` oder `Archiv an der Lichtung`. | kleinere Luecke |

Bewertung:

Terrain beschreibt stimmig lokale Varianten und blockiert Kategorien nicht.
Die einzige kleine Luecke ist sprachlich: `Archiv im Uferhain` ist als
Fallback/ruhige Ortslesart vorgesehen, aber nicht der prominenteste direkt
waehlbare Startslot-Output. Das ist kein Blocker, solange naechste Slices nicht
genau diese Variante als Pflichtdemo verlangen.

## 9. Audit-Frage 5: UI-/Interaction-Pattern nach 350

| Kriterium | Befund | Bewertung |
| --- | --- | --- |
| Direkte Weltaktion | Slot-Tap auf der Insel oeffnet Auswahl oder Expansion-Hinweis. | passt |
| Kompaktes Wheel | Kategorieauswahl ist nahe am Anchor, Icon + Kurzname, keine Langtexte. | passt mit Dichte-Hinweis |
| Kein Drag als Standardflow | Kein sichtbarer Layout-/Drag-Modus, keine Drag-Handles. | passt |
| Kein grosses Fenster | Kein Fullscreen, kein Dialog, keine Showcase-Seite. | passt |
| Kein Debug-HUD | Technische Guardrail-Chips sind aus normaler Ansicht entfernt. | passt |
| Tap outside / Abwahl | Map-Tap ruft `_clearBoardSelection()` auf und schliesst Auswahl/HUD. | passt |
| Bottom-HUD ruhig genug | Default-HUD ist kurz, Details einklappbar. | passt |
| Wheel-Woerter nicht abgeschnitten | Labels sind kurz und verwenden FittedBox/kurze Namen. | passt im Code-Audit |

Dichte-Hinweis:

Das Wheel zeigt 9 Hauptkategorien. Das ist fuer diese Greybox noch
akzeptabel, aber die Grenze ist erreicht. Wenn eine zehnte oder elfte
Hauptkategorie hinzukommt, sollte das Muster erneut nach `350` geprueft
werden: kompaktes Bottom-Sheet, Showcase oder Kategoriegruppen statt groesseres
Wheel.

## 10. Audit-Frage 6: Mobile / Clutter

| Frage | Befund | Bewertung |
| --- | --- | --- |
| Genug Insel sichtbar? | Top-HUD ist kompakt; Bottom-HUD erscheint nur bei Auswahl; Karte bleibt pannbar. | passt fuer Greybox |
| Header verdeckt zu viel? | Header ist klein und auf Titel + Aktion reduziert. | passt |
| Bottom-HUD verdeckt zu viel? | HUD ist kompakt, kann bei Details oder Bank-Bubble dichter werden. | beobachten |
| Slots antippbar? | Tap targets sind groesser als reine Anchorpunkte und unterscheiden frei/spaeter. | passt |
| Labels lesbar? | Anchor zeigt A-ID, Marker zeigt frei/spaeter; Terrainname wandert ins HUD. | passt |
| Ueberlappungen? | Weniger Label-Dichte als vorher; Code setzt keine grossen Dauerlabels auf alle Slots. | passt im Code-Audit |
| Spielbrett statt Editor? | Kein Drag, keine Snap-Hinweise, keine Debug-Chips; Insel bleibt Hauptflaeche. | passt |

Bewertung:

Mobile-/Clutter-Lage ist gut genug fuer die naechste kleine Iteration. Vor
einem echten Playtest braucht es trotzdem eine visuelle Device-QA, weil dieser
BG-Slice keine Screenshots erzeugt und keine Pixel-/Overlap-Pruefung im
Simulator dokumentiert.

## 11. Audit-Frage 7: Infrastruktur-Grenzen

| Grenze | Befund | Bewertung |
| --- | --- | --- |
| Keine Terrain-Bearbeitung | Terrain wird nur gezeichnet. | passt |
| Kein freier Fluss-/Wegbau | Fluss und Wege sind fixe Painter-Elemente. | passt |
| Kein BuildState | Auswahl bleibt lokale Candidate-/Shape-Preview. | passt |
| Keine Persistenz | Nur `setState` und lokale Maps, keine DB/Provider/Supabase. | passt |
| Keine Assets | Nur Flutter/Material/CustomPainter/einfache Formen. | passt |
| Keine Economy/Muenzen | Expansion zeigt Zukunft, kein Kauf-/Muenzen-Dialog. | passt |
| Erweiterung ohne Druck | Expansion-Slots oeffnen kein Wheel und keinen Kaufdruck. | passt |
| Keine App-Integration | Main-Datei ist isolierter `flutter run -t` Entry. | passt |

Bewertung:

Die Infrastruktur-Grenzen werden eingehalten. BG gibt weiterhin keine
produktive Mechanik, keine Persistenz und keine App-Integration frei.

## 12. Audit-Frage 8: Spielgefuehl

Staerken:

- Die Preview macht Lust, freie Slots auszuprobieren, weil Slots als Orte auf
  einer Insel statt als Liste erscheinen.
- Die Fantasie ist freier als in frueheren Versionen: Terrain erzeugt
  Varianten, aber keine Kategoriepflicht.
- Start- und Erweiterungsslots geben eine erste Progressionslesart, ohne
  Druck oder Economy.
- Archiv/Spaeter/Ablage sind verstaendlicher als Codex/Safe fuer normale
  Nutzer.
- Bank bleibt ein Ufer-Beispiel und dominiert nicht die gesamte Insel.

Schwaechen:

- Die Insel ist noch sehr greyboxig: wenige Landmarken, keine echten
  Weltobjekt-Andeutungen, wenig emotionaler Hook.
- Das 9er-Wheel ist akzeptabel, aber knapp an der Grenze fuer eine
  spielartige In-place-Auswahl.
- Bottom-HUD und Bank-Bubble koennen bei Details zusammen dichter wirken.
- Einige interne Namen wie `A-CODEX-NE` oder `zone: safe` bleiben im Code
  historisch, sind aber nicht sichtbar. Sie sollten nicht wieder als
  User-facing Sprache auftauchen.
- `Confirm`, `Change` und `Cancel` sind noch englische Greybox-Aktionen. Fuer
  eine echte deutschsprachige Nutzerpreview sollten sie spaeter lokalisiert
  oder spielnäher benannt werden.

Bewertung:

Die Preview wirkt mittlerweile mehr wie eine Weltgrundlage als wie ein
technischer Editor. Fuer echtes Spielgefuehl braucht sie als naechstes einen
konkreten, kleinen Weltmoment, der die Insel nicht nur planbar, sondern
bespielbar macht.

## 13. Entscheidung

Entscheidung:

```text
Bereit fuer den naechsten kleinen Uferhain-Slice.
```

Freigegeben als naechste Grundlage fuer:

- kleinen Spielmoment am Uferplatz,
- Bank-Meaning-Puzzle-Polish im Inselkontext,
- BuildChoice-/Showcase-Planung als Dokumentations-/Gate-Slice,
- spaetere visuelle Greybox-Verfeinerung.

Nicht freigegeben:

- produktive App-Integration,
- Route oder Navigation,
- Persistenz,
- BuildState,
- echte BuildChoice-Auswahl,
- Asset-Erzeugung,
- Economy/Muenzen,
- breiter Spielsystemausbau.

## 14. Empfohlener naechster Slice

Empfehlung:

```text
M16-BH Uferplatz Bank Spielmoment Readiness/Polish
```

Warum dieser naechste Schritt:

- Er prueft die wichtigste Annahme: Talvori-Lernen soll sich als
  Spielmoment auf der Insel anfuehlen, nicht als Lernfenster.
- Der Uferplatz ist durch Uferhain, Bank-Meaning-Puzzle und Wasser-Kontext
  fachlich am besten vorbereitet.
- Ein kleiner Bank-Spielmoment ist risikoaermer als sofort eine
  BuildChoice-/Showcase-Planung mit vielen Unterideen.
- Der Slice kann zeigen, ob World-Bubble, Bottom-HUD, Safe Exits und
  ContextCard/Archiv-Fund zusammen spielbar wirken.

Empfohlener Scope fuer M16-BH:

- erlaubte Datei falls Code: `lib/features/world/local_world/ui/widgets/starter_island_plot_board_preview.dart`,
- alternativ zuerst Docs-/UX-Gate ohne Code,
- Bank-Spielmoment nur auf Ufer-/Wasser-Startslot,
- kein neues Wheel-System,
- keine BuildChoice-Implementierung,
- keine Route,
- keine Persistenz,
- keine Assets,
- keine Tests ohne explizite Testfreigabe.

Alternative nach M16-BH:

- BuildChoice-/Showcase-Planung fuer Hauptkategorie -> Unterauswahl,
- visuelle Uferhain-Greybox-Verfeinerung mit staerkeren Landmarken,
- Device-/Visual-QA-Slice fuer Mobile-Dichte und Overlap.

## 15. 328-Update-Entscheidung

M16-BG erzeugt keine neue M16-T-ID und aendert keinen bestehenden Status.

`docs/world_design/328-talvori-learning-game-readiness-todo-checklist.md`
bleibt in diesem Slice unveraendert.

Begruendung:

- BG ist ein Readiness-Audit gegen bereits definierte INFRA-, INTERACT-,
  PLAY-, MOBILE- und WORLD-Regeln.
- Der Audit bestaetigt die aktuelle Preview als naechste Greybox-Basis,
  erzeugt aber kein neues dauerhaftes Readiness-Item.
- Offene Risiken koennen in Folge-Slices ueber bestehende M16-T-Gruppen
  bearbeitet werden.

## 16. Schlussfolgerung

Die Uferhain-Preview ist jetzt gut genug, um nicht weiter im
Grundstruktur-Modus steckenzubleiben. Sie zeigt:

- Uferhain als klare Starter-Insel-Lesart,
- 5 Startslots und 5 Erweiterungsslots,
- freie Hauptkategorie-Wahl,
- Terrain-zu-Variante ohne harte Blockade,
- Archiv/Spaeter als nutzerfreundliche Begriffe,
- keine produktive Persistenz oder Build-Logik.

Der naechste Fortschritt sollte Spielgefuehl erzeugen, nicht noch mehr
Infrastrukturtext. Der kleinste sinnvolle Schritt ist ein Uferplatz-/Bank-
Spielmoment-Polish im bestehenden Board, weiterhin isoliert und ohne
Produktivfreigabe.
