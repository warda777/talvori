# Talvori Welt: Buildable Forest Clearing Greybox Layout

Stand: 2026-06-04

Dieses Dokument definiert Phase 2E-A2: den Greybox-/Layout-Schritt fuer das
erste buildable Waldlichtung-Template. Es liegt vor finaler Asset-Erzeugung und
vor jedem neuen Bau-Code.

Es ist ein reines Planungsdokument. Es wurden keine Dart-/Flutter-Dateien,
keine Assets, keine Supabase-Daten, keine SQLite-/Vokabeldaten, keine SRS-Daten,
kein `word_progress`, keine Reward Bridge, keine Persistenz, keine Secrets und
keine Release-Artefakte geaendert.

Grundlagen:

- `docs/world_design/000-world-design-document-map.md`
- `docs/world_design/223-learning-to-building-loop.md`
- `docs/world_design/224-economy-balancing.md`
- `docs/world_design/225-in-world-learning-ui.md`
- `docs/world_design/226-build-progression-and-zones.md`
- `docs/world_design/232-onboarding-first-session.md`
- `docs/world_design/234-asset-production-and-buildable-island-templates.md`
- `docs/world_design/235-world-production-roadmap-and-checklists.md`
- `docs/world_design/236-buildable-forest-clearing-template-concept.md`

## 1. Zweck Des Dokuments

Dieses Dokument ist Phase 2E-A2.

Es ist der Greybox-/Layout-Schritt vor finaler Asset-Erzeugung.

Ziel:

- funktionales Layout der buildable Waldlichtung klaeren,
- `main_build_area` raeumlich festlegen,
- Platz fuer `foundation_started` und spaetere Bauphasen vorbereiten,
- blocked, decoration, path und docking areas mitdenken,
- category-neutral bleiben,
- verhindern, dass wieder ein schoenes, aber nicht bebaubares Inselbild
  entsteht.

Code und finale Assets bleiben blockiert, bis das Layout als sinnvoll bewertet
wurde.

## 2. Research-Ergebnis: Wie Profis Vorgehen

Das Professional Game Development Research Gate wurde fuer diesen Schritt
angewendet.

| Quelle / Orientierung | Ableitung fuer Talvori | Entscheidung fuer diesen Schritt |
| --- | --- | --- |
| Unity Learn: ProBuilder/Greyboxing beschreibt Greyboxing als Technik, bei der Levels mit einfachen Formen blockiert werden, um Gameplay vor finalen Art Assets zu pruefen. Quelle: `https://learn.unity.com/course/game-design-curricular-framework-resources/tutorial/editing-with-probuilder` | Talvori darf das Base-Asset nicht zuerst als finales Bild denken. Erst muss die Funktion der Flaechen stimmen. | Waldlichtung bekommt zuerst ein Greybox-/Layout-Dokument. |
| Epic/Unreal: Level Blockout nutzt einfache Formen fuer Waende, Wege und funktionale Hindernisse. Quelle: `https://dev.epicgames.com/documentation/en-us/unreal-engine/designer-01-project-setup-and-level-blockout-in-unreal-engine` | Auch eine 2.5D-PNG-Insel braucht vor finaler Grafik funktionale Raeume: Bauplatz, Raender, Wege, Docking und Blocker. | Layout beschreibt Zonen und Anker vor Asset-Prompt. |
| Unreal Geometry Brush Docs: Brushes werden konzeptionell genutzt, um Volumen im Level zu fuellen oder auszuschneiden, bis Layout und Spielgefuehl passen. Quelle: `https://dev.epicgames.com/documentation/en-us/unreal-engine/geometry-brush-actors-in-unreal-engine` | Talvori braucht kein 3D-BSP, aber dieselbe Denkweise: erst Volumen/Funktion, dann Detail. | Insel wird als funktionaler Raum mit Bauflaeche, Rand, Blockern und Blickachsen geplant. |
| Unity Manual: Asset Workflow betont Import, Projektstruktur, Metadaten und Content Pipeline. Quelle: `https://docs.unity.cn/Manual/AssetWorkflow.html` | Buildable Islands brauchen nicht nur PNGs, sondern Dateistruktur, Template-Metadaten und klare Pipeline. | `base`, `foundation_started` und `template.md` bleiben zusammen in `buildable_islands/forest_clearing/`. |
| Unity LOD Manual und Android Screen Guidelines beschreiben Distanz-/Detail- und Screen-Anpassung als technische Notwendigkeit. Quellen: `https://docs.unity.cn/2020.3/Documentation/Manual/LevelOfDetail.html`, `https://developer.android.com/guide/practices/screens_support.html` | Mobile World-Assets muessen in Weltuebersicht, Inselansicht und Bauplatzansicht lesbar bleiben. | Greybox prueft Groesse, Blickbarkeit und Tap-Ziel vor finalem Asset. |

Kurzfassung:

Professionelle Game-Entwicklung trennt fruehe Layout-Validierung von finaler
Asset-Produktion. Greybox/Blockout reduziert visuelle Details, damit Funktion,
Lesbarkeit, Wege, Hindernisse und Kamera zuerst stimmen.

Ableitung fuer Talvori:

Talvori erzeugt nicht sofort ein huebsches finales Base-Asset. Zuerst wird die
funktionale Inselstruktur geplant. Erst wenn Bauflaeche, Overlay-Platz,
Docking, Zonen und Kamera funktionieren, wird das finale Base-Asset erzeugt.

## 3. Greybox-Grundentscheidung

Waldlichtung wird zuerst als funktionales Layout gedacht.

Das Layout ist keine finale Grafik.

Es beschreibt:

- Flaechen,
- Anker,
- Zonen,
- Blickachsen,
- spaetere Bauzustaende,
- Randbereiche,
- Kamera- und Zoom-Anforderungen.

Ziel ist eine natuerlich wirkende Insel, die aber strukturell baubar ist.

## 4. Grobes Insel-Layout

Raeumliche Grundidee:

- `main_build_area` liegt zentral oder leicht nach vorne/unten versetzt.
- Wald-/Moos-/Grasumrandung rahmt die Lichtung.
- Baeume und Buesche liegen eher am Rand.
- Der Bauplatz bleibt ruhig, offen und gut lesbar.
- Felskoerper/Unterbau laeuft nach unten organisch aus.
- Zwei moegliche Docking-Raender bleiben frei.
- Ein erster kleiner Weg oder Lichtpunkt kann spaeter vom Bauplatz zu einem
  Randbereich fuehren.
- Kleine DecorationZones liegen ausserhalb der Hauptbauflaeche.
- BlockedAreas liegen an Klippen, Felsen, dichter Baumgruppe und Unterbau.

Die Insel soll nicht wie ein Level-Editor wirken. Die Struktur muss im finalen
Bild als natuerliche Lichtung lesbar sein.

## 5. Main Build Area Layout

Position:

- zentral oder leicht nach vorne/unten versetzt,
- nicht direkt am Inselrand,
- nicht hinter Baumgruppen,
- nicht auf Klippe, Wasser oder Fels.

Form:

- organisch oval / weich abgerundet,
- leicht unregelmaessig,
- keine perfekte Kreisform,
- kein UI-Kreis,
- kein Rechteck.

Groesse:

- ausreichend fuer `foundation_started`,
- spaeter ausreichend fuer kleines Haus / Huette,
- gross genug als Tap-Ziel in Portrait,
- nicht so gross, dass die Insel leer wirkt.

Umgebung:

- Baeume, Buesche und Steine rahmen die Flaeche,
- keine stoerenden Objekte direkt darauf,
- kleine Gras-/Erdvariationen bleiben sichtbar,
- Bauplatz wirkt nutzbar, aber naturbelassen.

Lesbarkeit:

- in Portrait und Landscape antippbar,
- bei Zoom als Bauplatz verstaendlich,
- im normalen Modus nicht wie Debug-Flaeche,
- bei Tap/Fokus dezent hervorhebbar.

## 6. Foundation Started Platzierung

`foundation_started` sitzt exakt auf der `main_build_area`.

Fuer Phase 2E wird `foundation_started` als eigenstaendiges transparentes
Overlay geplant. Komplette alternative Inselzustaende sind erst spaeter zu
pruefen, falls Overlays trotz guter Planung nicht hochwertig genug wirken.

Gestaltung:

- kleine Steinplatten,
- geglaettete Erde,
- erster Fundamentansatz,
- gleiche 2.5D-Richtung wie das Base-Asset,
- Material passt zu Erde, Gras und Fels der Waldlichtung.

Nicht erlaubt:

- generisches Rechteck,
- UI-Marker,
- Plattform,
- fertiges Haus,
- Waende,
- Dach,
- zu grosser Glow.

Wichtig:

`foundation_started` muss `foundation_complete` und spaeter `frame_started`
ermoeglichen. Es darf die spaetere Hausflaeche nicht zu klein, schief oder
visuell blockiert machen.

## 7. Spaetere Bauphasen Im Layout Mitdenken

Diese Phasen werden jetzt nicht produziert, muessen aber raeumlich moeglich
bleiben:

- `foundation_complete` nutzt dieselbe Flaeche wie `foundation_started`.
- `frame_started` braucht Platz nach oben/hinten in der 2.5D-Perspektive.
- `building_level_1` braucht genug Hausflaeche und Dachlesbarkeit.
- Erster Weg oder Lichtpunkt braucht Anschluss vom Bauplatz zu einem Rand.
- Bibliotheks-/Wissenspunkt braucht spaeter eine zweite Zone oder Erweiterung.
- Deko darf die `main_build_area` nicht blockieren.

Layout-Regel:

Der erste Bauplatz ist die Mitte des Lern->Bau-Gefuehls, aber er darf spaetere
Zonen nicht verschliessen.

## Expansion- Und Docking-Layout Als Pflicht

Bewertung des generierten Base-Assets
`assets/images/world/buildable_islands/forest_clearing/base.png`:

- Das Asset besitzt eine freie zentrale Bauflaeche.
- Es ist technisch als freigestelltes PNG nutzbar.
- Es wirkt visuell schoen und hochwertig.
- Es funktioniert aber noch nicht ausreichend als langfristig ausbaubares
  Insel-/Grundstueck-Template.

Grund fuer den Status `nachbessern`:

- Die Insel wirkt zu abgeschlossen.
- Erweiterungsflaechen sind nicht klar genug vorbereitet.
- Docking-/Connector-Stellen sind nicht eindeutig genug.
- Landwachstum von innen nach aussen ist nicht ausreichend sichtbar mitgedacht.
- Das Asset ist schoen, aber noch nicht klar genug als ausbaubares
  Spielsystem-Template.

Buildable Starter-Inseln duerfen nicht nur eine zentrale Bauflaeche haben. Sie
muessen von Anfang an Erweiterung und Docking mitdenken. Die Insel soll von
innen nach aussen wachsen koennen:

- Zentrum: erstes Fundament / Startgebaeude.
- Innerer Ring: erster Weg, Lichtpunkt, kleine Deko.
- Mittlerer Ring: Bibliothek, zweite BuildZone, Kategoriegebaeude.
- Randbereiche: `dockingCandidates`, Connector-Anker, spaetere
  Land-Erweiterung.
- Aussenbereiche: moegliche Expansion-Module oder zusaetzliche Inselstuecke.

Konkrete Layout-Regeln:

- Mindestens zwei klare Docking-/Connector-Kandidaten am Rand.
- Mindestens eine `future_expansion_area`.
- Randflaechen duerfen nicht komplett durch Baeume oder Felsen blockiert sein.
- Erweiterungsstellen sollen natuerlich wirken, zum Beispiel als flache
  Felsnasen, offene Grasraender oder kleine Plateau-Kanten.
- Keine fertigen Bruecken.
- Keine technischen Steckpunkte.
- Keine UI-Markierungen.
- Trotzdem muss visuell erkennbar sein, wo spaeter etwas anschliessen koennte.

## 8. Zonenplan

### `main_build_area`

Zweck:

- erster Bauplatz,
- `foundation_started`,
- spaeter Fundament, Haus/Huette oder neutrales Basis-Lernhaus.

Position:

- zentral oder leicht vorne/unten versetzt.

Phase 2E sichtbar/interaktiv:

- ja.

### `blocked_area`

Zweck:

- Schutz von Randfelsen, Klippen, dichtem Wald, Baumgruppen und Unterbau.

Position:

- Inselraender,
- Felskoerper,
- dichte Baum-/Buschgruppen.

Phase 2E sichtbar/interaktiv:

- nein.

### `decoration_area`

Zweck:

- spaetere kleine Deko,
- Blumen, Laternen, kleine Steine, Buesche.

Position:

- kleine Randflaechen ausserhalb der `main_build_area`.

Phase 2E sichtbar/interaktiv:

- nein.

### `path_area` / `pathNodes`

Zweck:

- spaeterer Weg vom Bauplatz zu Rand / Lichtpunkt.

Position:

- vom Bauplatz nach vorne/unten oder leicht zur Seite.

Phase 2E sichtbar/interaktiv:

- nein.

### `dockingCandidates`

Zweck:

- spaetere Connector-Anschluesse.

Position:

- mindestens zwei Raender, z. B. Nordwest und Suedost oder West und Ost.

Phase 2E sichtbar/interaktiv:

- nein.

### `future_expansion_area`

Zweck:

- optionaler Platz fuer spaetere zweite Zone oder Wissenspunkt.

Position:

- nur falls Layout genug Platz bietet, eher seitlich/hinten.

Phase 2E sichtbar/interaktiv:

- nein.

## 9. Category-Neutralitaet Und Spaetere Lernkategorien

Waldlichtung darf nicht nach einer festen Kategorie aussehen.

Nicht enthalten:

- Reisekoffer,
- medizinische Symbole,
- Business-Symbole,
- Schulmoebel,
- Essen-/Restaurantzeichen,
- Technik-Objekte,
- Kultur-Labels.

Regeln:

- Die Insel traegt ein neutrales Startgebaeude.
- Spaetere Kategoriegebaeude entstehen ueber Templates/Varianten.
- `main_build_area` bleibt flexibel fuer unterschiedliche erste
  Gebaeudevarianten.
- BuildZones und Metadaten duerfen keine Kategorie hart codieren.

Waldlichtung ist ein category-neutral Starter Template.

## 10. Kamera-/Zoom-Greybox

Weltuebersicht:

- Insel muss als Waldlichtung erkennbar bleiben.
- Silhouette und gruenes Biom muessen lesbar sein.

Inselansicht:

- `main_build_area` muss erkennbar sein.
- Bauflaeche darf nicht unter UI-Overlays liegen.

Bauplatzansicht:

- `foundation_started` muss klar sichtbar sein.
- Kein extremer Zoom erforderlich.
- Kamera-Fokus auf `main_build_area` moeglich.

Portrait:

- Insel darf nicht gequetscht wirken.
- Bauplatz bleibt tappbar.

Landscape:

- spaeter als Explore-Modus moeglich,
- Layout darf breiter gelesen werden, aber nicht auf Landscape angewiesen sein.

## 11. Asset-Komposition Fuer Imagegen

Aus dem Greybox-Layout folgt fuer den Base-Prompt:

- zentrale oder leicht vorne/unten versetzte natuerliche Bauflaeche,
- center-to-edge growth layout,
- first build area in center, future growth around it,
- Rand-Baeume und Buesche,
- ruhige Mitte,
- keine fertigen Gebaeude,
- keine UI-Formen,
- klare 2.5D-Perspektive,
- transparente PNG-Ausgabe,
- subtile Docking-faehige Raender,
- island must include readable expansion-ready edges,
- at least two natural docking candidate ledges,
- at least one future expansion area,
- do not make the island feel like a closed finished plateau,
- sichtbarer schwebender Inselkoerper.

Bereiche, die frei bleiben muessen:

- `main_build_area`,
- spaeterer Weg-/Lichtpunkt-Anschluss,
- mindestens zwei Docking-Raender,
- optionale zweite Zone.

Bereiche, die detailliert sein duerfen:

- Randwald,
- Moos,
- Buesche,
- kleine Steine,
- Felsunterbau,
- Inselkante.

Bereiche, die ruhig sein muessen:

- Bauplatz,
- Overlay-Flaeche,
- spaeterer Weganschluss.

Fehler, die im Prompt ausgeschlossen werden:

- fertige Huette,
- Haus,
- Bruecke,
- moderne Plattform,
- Kreis-/Rechteck-Markierung,
- Text,
- UI,
- Space-Hintergrund,
- ueberladener Bauplatz.

## 12. ASCII-/Text-Skizze

```text
                 [Baumgruppe / blocked]
          [Deko]                         [Docking NW]
             \                             /
              \       [future option]     /
               \          [path node]    /
                \             |          /
              [Randgras] [main_build_area] [Randsteine]
                         [foundation zone]
                              |
                         [path / Lichtpunkt]
                              |
                    [Docking SE / offener Rand]
                         [Klippe / blocked]
```

Lesart:

- `main_build_area` ist Zentrum des ersten Baufortschritts.
- Docking NW und SE bleiben nur visuelle Vorbereitung.
- Deko bleibt randnah.
- BlockedAreas schuetzen Baumgruppen, Felsen, Klippen und Unterbau.
- Path/Lichtpunkt ist spaeterer Anschluss, nicht Phase 2E.

## 13. Entscheidung: Bild Zuerst Oder Funktion Zuerst?

Entscheidung:

- Nicht finales Bild zuerst.
- Nicht Code zuerst.
- Erst funktionales Greybox/Layout.
- Danach Asset-Prompt.
- Danach Base-Asset.
- Danach `foundation_started`.
- Danach Device-Check.
- Danach erst Code.

Begruendung:

Talvori baut eine Welt, keine Marker auf Bildern. Funktion, Lesbarkeit und
semantische Zonen muessen vor finaler Grafik stimmen.

## 14. Phase-2E-A2 Ergebnis

Wenn dieses Dokument fertig ist:

- darf als naechstes der Base-Asset-Prompt erstellt werden,
- entsteht noch kein freigegebenes Asset,
- beginnt Phase 2E-B erst mit Asset-Erzeugung,
- bleibt Phase 2E-E Code weiterhin blockiert.

Erlaubt:

- Base-Prompt ableiten,
- `foundation_started`-Prompt ableiten,
- `template.md`-Struktur vorbereiten.

Nicht erlaubt:

- Asset sofort ohne Prompt-Review erzeugen,
- Code schreiben,
- altes Naturasset weiter bebauen.

## 15. Update Von `235`

`docs/world_design/235-world-production-roadmap-and-checklists.md` wird minimal
aktualisiert:

- Phase 2E-A2 wird in der Roadmap sichtbar,
- Status wird nach Erstellung dieses Dokuments nachvollziehbar,
- Code bleibt blockiert.

## 16. Stop-Regeln

Stoppen, wenn:

- keine professionelle Recherche durchgefuehrt wurde,
- Greybox/Layout nicht konkret genug ist,
- `main_build_area` nicht eindeutig ist,
- `foundation_started` nicht platzierbar wirkt,
- Kategorie-Erweiterbarkeit vergessen wird,
- Docking-/Path-/Blocked-/Decoration-Bereiche fehlen,
- Codex versucht, Asset zu erzeugen,
- Codex versucht, Code zu schreiben.

## 17. Offene Fragen

Offene Fragen:

- Sind Nordwest/Suedost die besten Dockingrichtungen oder passt West/Ost
  besser zur finalen Insel-Silhouette?
- Soll `future_expansion_area` bereits im ersten Base-Asset sichtbar angelegt
  sein oder nur als Metadatenoption?
- Wie gross muss die `main_build_area` im finalen PNG sein, damit sie auf
  typischen Smartphone-Screens tappbar und lesbar bleibt?
- Wie wird nach dem ersten Device-Check entschieden, ob die Overlay-Strategie
  langfristig reicht oder spaetere komplette Inselzustaende geprueft werden
  muessen?

## 18. Akzeptanzkriterien

Dieses Dokument ist gut, wenn:

- professionelle Arbeitsweise recherchiert und auf Talvori uebertragen wurde,
- klar ist, warum Greybox/Layout vor finalem Asset kommt,
- `main_build_area` funktional beschrieben ist,
- `foundation_started` raeumlich vorbereitet ist,
- spaetere Bauphasen nicht blockiert werden,
- Kategorie-Erweiterbarkeit beruecksichtigt ist,
- eine Asset-Prompt-Grundlage ableitbar ist,
- Code weiterhin blockiert bleibt.
