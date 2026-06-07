# M16-I: Theme Island Plot Capacity And In-Place Build Wheel Plan

Stand: 2026-06-07

Status: `Planungs- und Visualisierungsblock gestartet / keine Implementierung`

## 1. Ziel

M16-I schaerft die Welt-/Inselplanung: Eine ThemeIsland darf nicht als kleine
feste Insel mit wenigen Slots verstanden werden. Inselgroesse,
Grundstuecksanzahl und Grundstuecksgroessen muessen aus dem jeweiligen Thema
abgeleitet werden.

Kernregel:

```text
Erst Thema analysieren
-> benoetigte Grundstuecke ableiten
-> Grundstuecksgroessen bestimmen
-> Inselgroesse und Layout ableiten
-> austauschbare Slots platzieren
-> Nutzer waehlt Slot
-> Bauauswahl erscheint als Popup/Wheel in derselben Ansicht
```

M16-I ist nur Plan und Visualisierung. Daraus folgen keine Flutter-/Dart-
Dateien, keine App-Integration, keine Route, keine neue Seite, keine
Persistenz, keine Runtime-Konfiguration, keine Assets, keine automatische
Wortplatzierung, kein Build-State, kein `frame_started` und keine Bauzustaende.

## 2. Fuehrende Grundlage

M16-I baut auf diesen Dokumenten auf:

- `docs/world_design/252-flexible-plot-placement-and-learning-semantics.md`
- `docs/world_design/253-capability-greybox-plan.md`
- `docs/world_design/254-capability-greybox-visual-review.md`
- `docs/world_design/272-plot-capability-derivation.md`
- `docs/world_design/273-plot-capability-visual-review.md`
- `docs/world_design/317-first-world-element-slice-scope-and-visual-plan.md`

Wichtige Lesart:

- Plot-Capabilities sind Erlaubnisse, keine Pflichtbelegung.
- ThemeIslands brauchen theme-spezifische Kapazitaet.
- Nutzerwahl bleibt zentral.
- Das System darf vorschlagen, aber nicht automatisch platzieren.
- Bestehende lokale M16-Prototypen beweisen nur kleine Interaktionen, nicht das
  finale Inselmodell.

## 3. Thema-zu-Grundstueck-Pipeline

| Schritt | Zweck | Ergebnis | Stop-Regel |
| --- | --- | --- | --- |
| 1. ThemeIsland waehlen | Beispiel: Dorf / Zuhause / Alltag | Thema als Planungsrahmen | keine finale Insel |
| 2. Theme-Capabilities bestimmen | Welche Funktionen traegt das Thema? | home, garden, path, nature, learningHub, utility | keine Runtime-Konfiguration |
| 3. Grundstueckstypen ableiten | Was braucht das Thema sichtbar? | Haus, Garten, Weg, Natur, Vorhof, Utility | keine automatische Wortplatzierung |
| 4. Anzahl bestimmen | Thema nicht kuenstlich klein halten | mehrere Slots je Bedarf | kein fixer 3-Slot-Plan |
| 5. Groessen bestimmen | Unterschiedliche Elemente brauchen Platz | klein, mittel, gross, sehr gross | Haus nicht wie Beet behandeln |
| 6. Inselkapazitaet pruefen | Reicht die ThemeIsland fuer diese Mischung? | Kapazitaetsentscheidung | kein finales Inselbild |
| 7. Layout-Groesse ableiten | Insel waechst aus Bedarf | groessere oder modulare Insel | keine Assetproduktion |
| 8. Slots platzieren | Slots bleiben austauschbar | flexible Plot-Slots | keine feste Gebaeudeordnung |
| 9. Nutzer waehlt Slot | lokale Auswahl in derselben Ansicht | Plot Highlight | keine Persistenz |
| 10. Build Wheel oeffnet | Bau-/Elementkandidaten als Overlay | Popup/Wheel | keine neue Seite, keine Route |
| 11. Nutzer waehlt Kandidat | nur Preview-Auswahl | Candidate Preview | keine Bauausfuehrung |
| 12. Spaeteres Gate | echte Umsetzung erst spaeter | Confirm/Build/Persist-Gate | kein `frame_started` |

## 4. Beispiel: Dorf / Zuhause / Alltag

Das Beispiel zeigt, warum eine ThemeIsland nicht aus einer kleinen fixen Insel
mit wenigen Slots entstehen darf. Schon ein ruhiges Dorf-/Alltagsthema braucht
mehrere unterschiedliche Flaechenlogiken.

| Grundstueck | Zweck | Moegliche Woerter/Lernbereiche | Groesse | Austauschbar | Bau-Wheel-Kandidaten | Risiko | Gate |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Haus-Grundstueck | Wohn-/Alltagskern | room, kitchen, door, window, chair, family | gross | bedingt | Haus, kleines Zuhause, Lernraum | Pflicht-Hausstart, Build-State-Misread | Foundation-/Home-Gate, keine Persistenz |
| Garage-/Carport-Grundstueck | Utility/Fahrzeugnahe | car, bike, tool, garage, key | mittel | ja | Garage, Carport, Tool-Ecke | Vehicle-System zu frueh | Utility-/Vehicle-Gate |
| Garten-Grundstueck | Natur-/Alltagsbereich | flower, tree, watering can, garden | gross/flexibel | ja | Garten, Hofgarten, Pflanzbereich | Growth-/Timer-Druck | Fairness-/Timer-Gate |
| Feld-/Beet-Grundstueck | Pflanzen/Food klein | seed, plant, carrot, soil | mittel/gross | ja | Beet, Feld, Pflanzkiste | Produktionslogik, Timer | Growth/Food-Gate |
| Vorhof-/Einfahrt-Grundstueck | Zugang und Uebergang | path, door, welcome, shoes | mittel | bedingt | Vorhof, Einfahrt, kleiner Platz | wirkt wie Pflicht-Route | Path-/Connector-Gate |
| Baum-/Naturflaeche | Atmosphaere und Naturworte | tree, leaf, bird spaeter, shade | klein/mittel | ja | Baumgruppe, Wiese, Naturpunkt | Deko-Clutter | Clutter-/Nature-Gate |
| Weg-/Platzflaeche | Verbindung, Orientierung | road, path, square, left/right | verbindend | bedingt | Weg, Platz, Kreuzung | normales Baugrundstueck-Misread | Path-System-Gate |
| Erweiterungsflaeche | Zukunft/Reserve | backlog, future theme, expansion | mittel/gross | ja | leerer Slot, Reserve, spaeterer Bereich | Unlock-/Retention-Druck | Expansion-Gate |

Leitentscheidungen:

- Haus braucht mehr Platz als Garage oder Carport.
- Garten und Feld brauchen andere Flaechenlogik als Haus.
- Weg/Platz ist Verbindungsflaeche, kein normales Gebaeudegrundstueck.
- Baum/Natur darf nicht zu Deko-Clutter werden.
- Alle Grundstuecke muessen austauschbar oder mindestens konfigurierbar
  bleiben.

## 5. In-Place Build Wheel

UX-Regel:

- Nutzer bleibt auf derselben Insel-/Grundstuecksansicht.
- Kein neuer Screen.
- Kein Seitenwechsel.
- Kein hartes Routing.
- Grundstueck antippen -> Plot Highlight.
- Popup/Wheel oeffnet in-place.
- Wheel zeigt moegliche Bau-/Elementkandidaten als spaetere Bild-/Icon-Kacheln.
- Wheel darf spaeter radial, drehbar oder als kompakter Overlay-Ring erscheinen.
- Wheel muss abbrechbar sein.
- Grundstueck muss wieder abwaehlbar sein.
- Auswahl bleibt Preview, bis spaetere Gates Bau/Persistenz erlauben.

Wheel-Beispiel fuer Dorf:

| Kandidat | Passende Plottypen | Preview-Regel | Blocker |
| --- | --- | --- | --- |
| Haus | Haus-Grundstueck, grosser residential Plot | nur Kandidat, kein Pflichtstart | kein Build-State |
| Garage | Utility/vehicle Plot | nur wenn mittlerer Platz vorhanden | keine Vehicle-Logik |
| Carport | Utility/vehicle Plot | leichter als Garage, aber nicht Asset | keine Assetfreigabe |
| Garten | Garten/core-edge Plot | flexibel, naturbezogen | kein Timer-Druck |
| Beet/Feld | Garten/Farm/Food Plot | nur Preview | keine Produktionslogik |
| Baumgruppe | Natur/edge Plot | kleine Naturflaeche | kein Clutter |
| Vorhof | Connector/residential Plot | Uebergangsflaeche | keine Route |
| Weg/Platz | Connector/path Plot | Verbindungsoption | kein produktives Path-System |

## 6. Groessen- und Austauschbarkeitsmatrix

| Plot Type | Example Elements | Size Class | Why this size | Exchangeable? | Can host multiple elements? | Needs zoom? | Mobile risk | Gate before implementation |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Haus | Haus, Lernraum, Alltagshaus | gross | Gebaeude, Vorbereich, spaeter Interior | bedingt | ja, spaeter ueber Depth | ja | mittel | Home/Interior/Device Gate |
| Garage/Carport | Garage, Carport, Tool-Ecke | mittel | Fahrzeug-/Utility-Naehe braucht Zufahrt | ja | begrenzt | optional | mittel | Utility/Vehicle Gate |
| Garten | Garten, Hofgarten, Naturbereich | gross/flexibel | Pflanzen, Wege, Detailobjekte | ja | ja, aber begrenzt | ja | mittel/hoch | Growth/Fairness/Clutter Gate |
| Beet/Feld | Beet, Feld, Pflanzkiste | mittel/gross | Reihen/Flaeche brauchen Luft | ja | ja, vorsichtig | optional | hoch | Food/Growth Gate |
| Baum/Natur | Baumgruppe, Wiese, Naturpunkt | klein/mittel | Atmosphaere ohne Deko-Masse | ja | begrenzt | nein/optional | Clutter | Nature/Clutter Gate |
| Weg/Platz | Weg, Platz, Kreuzung | verbindend | Orientierung, Zugang, Layoutfluss | bedingt | nein als Bauplatz | nein | mittel | Path/Connector Gate |
| Erweiterung | Reserve, Future Slot | mittel/gross | haelt Insel wachstumsfaehig | ja | spaeter | ja | gering/mittel | Expansion Gate |

## 7. Verhaeltnis Zu Lokalen M16-Prototypen

`lib/features/world/local_world/ui/widgets/compact_local_world_surface_preview.dart`
ist nur ein lokaler Interaktionsprototyp. Er zeigt:

- neutralen Marker,
- lokales Highlight,
- Info-Panel,
- Ghost Preview Surface,
- lokale Preview-Aktionen.

Er ist nicht:

- finale Insel,
- ThemeIsland-Layout,
- Plot-Kapazitaetsmodell,
- Build-Wheel,
- App-Integration,
- Bauzustand.

Spaeter muss die abstrakte Flaeche durch eine echte ThemeIsland-/
Plot-Kapazitaetslogik ersetzt werden. Foundation Choice bleibt Fokus-/
Einstiegslogik und ist nicht das Bau-Menue. Das Build Wheel ist ein eigenes
spaeteres Overlay-Konzept.

## 8. Dokumentationsvisualisierungen

M16-I ergaenzt echte PNG-Dokumentationsvisualisierungen unter:

`docs/world_design/previews/m16_i_theme_island_plot_capacity_build_wheel/`

Erzeugte Visuals:

- `01_theme_to_plot_capacity_pipeline.png`
- `02_village_plot_capacity_map.png`
- `03_in_place_build_wheel_flow.png`
- `04_allowed_vs_blocked_plot_build_scope.png`
- optional `00_contact_sheet.png`

Diese PNGs sind Dokumentationspreviews. Sie sind keine App-Screens, keine
Screenshots, keine finalen UI-PNGs, keine Spielassets und keine Dateien unter
`assets/`.

## 9. Entscheidung

M16-I empfiehlt:

- ThemeIsland-Kapazitaet muss aus Thema und benoetigten Grundstuecken
  abgeleitet werden.
- Keine kleine fixe Insel mit wenigen Slots als Grundlage verwenden.
- Dorf/Zuhause/Alltag braucht mehrere Plottypen mit verschiedenen Groessen.
- Plot-Slots bleiben austauschbar oder konfigurierbar.
- Bauauswahl erfolgt spaeter in-place als Overlay/Wheel, nicht per neuer Seite.
- Wheel-Auswahl bleibt Preview, bis ein eigenes Gate echte Bau-/Persistenzlogik
  erlaubt.

## 10. Stop-Regeln

Aus M16-I folgt ausdruecklich:

- Keine Implementierung.
- Keine Flutter-/Dart-Dateien.
- Keine App-Integration.
- Keine Route.
- Keine neue Seite.
- Keine Build-Wheel-Implementierung.
- Keine Tests und keine Widget-Tests.
- Keine Screenshots.
- Keine Runtime-Konfiguration.
- Keine Persistenz.
- Keine Supabase Writes.
- Keine lokalen DB-Writes.
- Keine SRS-/`word_progress`-Aenderung.
- Keine Reward Bridge.
- Keine automatische Wortplatzierung.
- Keine Assets.
- Keine Asset-Dateien unter `assets/`.
- Kein Build-State.
- Kein `frame_started`.
- Keine Bauzustaende.
