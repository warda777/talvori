# M16-J: Village Plot Capacity Local Preview Scope

Stand: 2026-06-07

Status: `Scope-/Visual-Plan gestartet / keine Implementierung`

## 1. Ziel

M16-J konkretisiert aus M16-I den naechsten kleinen lokalen Preview-Kandidaten:
eine Dorf-/Zuhause-/Alltag-ThemeIsland als abstrakte Multi-Slot-Vorschau mit
mehreren unterschiedlich grossen Grundstuecks-Slots.

M16-J ist nur Planung und Dokumentationsvisualisierung. Daraus folgen keine
Flutter-/Dart-Dateien, keine App-Integration, keine Route, keine neue Seite,
keine Build-Wheel-Implementierung, keine Persistenz, keine Runtime-
Konfiguration, keine Assets, keine automatische Wortplatzierung, kein
Build-State, kein `frame_started` und keine Bauzustaende.

Fuehrende Grundlage:

- `docs/world_design/318-theme-island-plot-capacity-and-build-wheel-plan.md`

Leitregel:

```text
Theme -> benoetigte Grundstuecke -> Groessen -> Inselkapazitaet
-> austauschbare Slots -> lokale Slot-Auswahl
-> spaeteres In-Place Build-Wheel
```

## 2. Lokale Dorf-Slot-Struktur

| Slot | Rolle | Groesse | Warum diese Groesse | Austauschbar? | Zoom noetig? | Wheel spaeter sinnvoll? | Risiko | Gate |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Haus-Grundstueck | Wohn-/Alltagskern | gross | Haus braucht Vorbereich, spaeter Interior und mehr Luft als Utility | bedingt | ja | ja, aber nur Kandidat | Pflicht-Hausstart, Build-State-Misread | Home/Interior/Device Gate |
| Garage-/Carport-Grundstueck | Utility-/Fahrzeugnaehe | mittel | Fahrzeug-/Tool-Naehe braucht Platz, aber weniger als Haus | ja | optional | ja | Vehicle-System zu frueh | Utility/Vehicle Gate |
| Garten-Grundstueck | Natur-/Alltagsbereich | gross/flexibel | Pflanzen, Hof, Detailobjekte brauchen Luft und Clutter-Grenzen | ja | ja | ja | Timer-/Growth-Druck | Fairness/Clutter Gate |
| Beet-/Feld-Grundstueck | Pflanzen/Food klein | mittel/gross | Reihen/Flaechenlogik braucht mehr als Deko | ja | optional | ja | Produktionslogik, Timer | Growth/Food Gate |
| Vorhof-/Einfahrt-Grundstueck | Zugang/Uebergang | mittel | Verbindung zwischen Haus, Weg und Utility | bedingt | nein/optional | ja | wirkt wie Pflicht-Route | Path/Connector Gate |
| Baum-/Naturflaeche | Atmosphaere/Naturworte | klein/mittel | Naturpunkt soll lesbar bleiben, ohne Deko-Masse | ja | nein/optional | ja | Deko-Clutter | Nature/Clutter Gate |
| Weg-/Platzflaeche | Verbindung/Orientierung | verbindend | Layoutfluss statt normales Gebaeudegrundstueck | bedingt | nein | ja, aber Sonderrolle | als Bauplatz misslesen | Path-System Gate |
| Erweiterungsflaeche | Reserve/Future Slot | reserve | Platz fuer spaeteres Thema oder Backlog | ja | spaeter | ja | Unlock-/Retention-Druck | Expansion Gate |

## 3. Spaeterer Code-Kandidat

Empfohlener spaeterer Code-Kandidat:

`VillagePlotCapacityPreview`

Ein lokales Preview-Widget duerfte spaeter hoechstens zeigen:

- mehrere abstrakte Grundstuecksgroessen,
- austauschbare Slots,
- einen verbindenden Weg/Platz,
- lokale Slot-Auswahl als Highlight,
- keine feste Gebaeudebelegung,
- keine Assets,
- keine Gebaeude,
- keine Bauzustaende,
- keine Persistenz,
- keine echte Platzierung,
- keine Build-Wheel-Implementierung,
- keine App-Integration.

Das Widget waere ein lokaler Preview-/Harness-Slice, nicht die finale Insel und
nicht das Zielsystem. Es muesste vor Code separat freigegeben werden.

## 4. Erlaubter Spaeterer Minimal-Scope

Ein spaeterer `VillagePlotCapacityPreview`-Slice duerfte maximal:

- eine abstrakte Dorf-/Alltag-Flaeche mit mehreren Slots zeichnen,
- unterschiedliche Slotgroessen sichtbar machen,
- Slots als austauschbare Flaechen labeln,
- einen Weg-/Platz-Connector zeigen,
- einen Slot lokal hervorheben,
- Slot-Auswahl lokal zuruecksetzen,
- keine App-Struktur beruehren.

Nicht erlaubt:

- keine Gebaeude,
- keine Haus-/Garage-/Garten-Assets,
- keine Build-Wheel-Implementierung,
- keine Route,
- keine neue Seite,
- keine Persistenz,
- keine Runtime-Konfiguration,
- keine automatische Wortplatzierung,
- kein Build-State,
- kein `frame_started`.

## 5. Verhaeltnis Zu Bisherigen Prototypen

`compact_local_world_surface_preview.dart` testet nur einen einzelnen neutralen
Platz: Marker, lokales Highlight, Ghost Preview Surface, lokale Info und
lokale Preview-Aktionen.

M16-J plant dagegen mehrere thematisch abgeleitete Slots:

- Haus gross,
- Garage mittel,
- Garten gross/flexibel,
- Beet/Feld mittel/gross,
- Vorhof mittel,
- Baum/Natur klein/mittel,
- Weg/Platz verbindend,
- Erweiterung reserve.

M16-J ist naeher an einer Dorf-/Insel-Kapazitaetsansicht, aber immer noch ohne
finale Inselgrafik, ohne Assets, ohne Gebaeude, ohne Bauzustand und ohne
Build-Wheel. Das Build-Wheel bleibt nachgelagert.

## 6. Dokumentationsvisualisierungen

M16-J ergaenzt echte PNG-Dokumentationsvisualisierungen unter:

`docs/world_design/previews/m16_j_village_plot_capacity_local_preview/`

Erzeugte Visuals:

- `01_village_slot_size_map.png`
- `02_slot_exchangeability_flow.png`
- `03_allowed_vs_blocked_village_preview_scope.png`
- optional `00_contact_sheet.png`

Diese PNGs sind Dokumentationspreviews. Sie sind keine App-Screens, keine
Screenshots, keine finalen UI-PNGs, keine Spielassets und keine Dateien unter
`assets/`.

## 7. Entscheidung

M16-J empfiehlt als naechsten spaeteren Code-Kandidaten:

`VillagePlotCapacityPreview`

Dieser Kandidat ist sinnvoll, weil er:

- den Schritt von Einzelmarker zu Multi-Slot-Kapazitaet macht,
- M16-I praktisch testbarer macht,
- keine Gebaeude, Assets oder Bauzustaende braucht,
- lokale Interaktion klein halten kann,
- die Build-Wheel-Idee vorbereitet, ohne sie zu implementieren.

Vor Code braucht es weiterhin eine ausdrueckliche Nutzerfreigabe fuer einen
engen Implementierungsblock.

## 8. Stop-Regeln

Aus M16-J folgt ausdruecklich:

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
