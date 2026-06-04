# Talvori Welt: World Scale And Dimension Rules

Stand: 2026-06-04

Dieses Dokument definiert Phase 2E-A4: Massstab, Footprints und
Groessenlogik fuer Talvori Welt. Es legt fest, wie Insel, Haus, Hof, Wege,
Deko, Fahrzeuge, Innenraeume und spaetere Objekt-Detailansichten proportional
zusammenpassen sollen.

Es ist ein reines Planungsdokument. Es wurden keine Dart-/Flutter-Dateien,
keine Assets, keine Supabase-Daten, keine SQLite-/Vokabeldaten, keine SRS-Daten,
kein `word_progress`, keine Reward Bridge, keine Persistenz, keine Secrets und
keine Release-Artefakte geaendert.

Grundlagen:

- `docs/world_design/000-world-design-document-map.md`
- `docs/world_design/234-asset-production-and-buildable-island-templates.md`
- `docs/world_design/235-world-production-roadmap-and-checklists.md`
- `docs/world_design/236-buildable-forest-clearing-template-concept.md`
- `docs/world_design/237-buildable-forest-clearing-greybox-layout.md`
- `docs/world_design/238-multi-scale-world-and-interior-system.md`
- `docs/221-talvori-world-build-and-expansion-architecture.md`
- `docs/222-talvori-world-game-system-master-plan.md`

## 1. Zweck Des Dokuments

Dieses Dokument definiert Massstab und Groessenlogik fuer Talvori Welt.

Es verhindert, dass Assets zwar visuell schoen, aber dimensional unbrauchbar
sind.

Es wird Pflichtreferenz vor neuen:

- Insel-Assets,
- Gebaeude-Assets,
- Fahrzeug-Assets,
- Interior-Assets,
- Object-Detail-Assets,
- Buildable-Island-Templates.

Regel:

Ohne Scale-Pruefung darf kein neues buildable Asset freigegeben werden.

## 2. Research-Ergebnis: Wie Profis Vorgehen

Das Professional Game Development Research Gate wurde fuer diesen Schritt
angewendet.

| Quelle / Orientierung | Ableitung fuer Talvori | Konkrete Entscheidung |
| --- | --- | --- |
| Unreal Engine: Units of Measurement. Unreal dokumentiert klare Projekt-Einheiten, z. B. Zentimeter fuer Laenge. Quelle: `https://dev.epicgames.com/documentation/en-us/unreal-engine/units-of-measurement-in-unreal-engine` | Professionelle Produktionen definieren frueh, in welchen Einheiten und Relationen Objekte gedacht werden. | Talvori braucht eine eigene stilisierte Scale-Bible, auch wenn es kein realmetrisches 3D-Spiel ist. |
| Unity Manual: Grid component. Unity nutzt Cell Size, Cell Gap und Layouts wie Rectangle, Hexagon und Isometric. Quelle: `https://docs.unity.cn/Manual/class-Grid.html` | Footprints und Slots brauchen eine gemeinsame Referenz, damit Objekte nicht beliebig auf Flaechen landen. | Talvori plant BuildZones, ItemSlots und Footprint-Klassen statt freier Pixelplatzierung. |
| Unity Manual: LOD Group. LOD reduziert Detail abhaengig von Kamera-/Screen-Groesse. Quelle: `https://docs.unity.cn/Manual/class-LODGroup.html` | Ein Objekt muss je Detailstufe anders lesbar sein; kleine Details gehoeren nicht in die World View. | Talvori trennt World-, Island-, Interior- und Object-Detail-Scale. |
| Unity Manual: Asset Workflow. Assets koennen visuelle oder abstrakte Daten sein und brauchen Pipeline/Metadaten. Quelle: `https://docs.unity.cn/Manual/AssetWorkflow.html` | Massstab muss Teil der Asset-Metadaten und Freigabe sein, nicht nur Prompt-Gefuehl. | Buildable Templates brauchen Scale-Notizen, Footprints und Referenzobjekte. |
| Android Screen Compatibility Overview. Mobile Apps muessen verschiedene Screen-Groessen, Dichten und Orientierungen beruecksichtigen. Quelle: `https://developer.android.google.cn/guide/practices/screens_support?hl=en` | Mobile Lesbarkeit ist wichtiger als realistische Detailfuelle. Zu kleine Wege, Tueren oder Objekte werden unspielbar. | Talvori nutzt glaubwuerdige, stilisierte Proportionen mit klaren Tap-/Lesbarkeitszonen. |
| Polycount Art Bible. Art Bible/Style Guide dient als verbindliche Stilreferenz fuer Assets. Quelle: `https://wiki.polycount.com/wiki/Art_Bible` | Konsistente Proportionen gehoeren zur Art Direction wie Farbe, Licht und Material. | Talvori fuehrt eine Scale-/Dimension-Regel als Teil der Asset-Produktionslogik ein. |
| SpecBase Art Bible. Eine Art Bible kann Proportionen, Silhouetten, Asset-Naming und Produktionslimits festhalten. Quelle: `https://www.specbase.net/docs/library/art_bible/` | Ohne dokumentierte Scale-Regeln driftet die Welt ueber viele Assets auseinander. | Neue Assets muessen gegen Referenzobjekte und Footprint-Klassen geprueft werden. |

Kurzfassung:

Professionelle Teams definieren frueh Metriken, Referenzobjekte, Footprints,
Grid-/Slot-Regeln und Art-Bible-Constraints. Selbst wenn ein Spiel stilisiert
ist, braucht es konsistente Relationen: Tuer zu Haus, Weg zu Bewohner, Auto zu
Hof, Baum zu Insel, Interior zu Exterior.

Ableitung fuer Talvori:

Talvori nutzt keinen mathematisch realistischen 1:1-Massstab, aber eine
verbindliche stilisierte Scale-Logik. Mobile Lesbarkeit und Spielbarkeit haben
Vorrang vor Realweltmassen, doch Proportionen muessen glaubwuerdig bleiben.

## 3. Grundentscheidung Fuer Talvori

Talvori nutzt einen stilisierten 2.5D-Massstab.

Regeln:

- Proportionen muessen glaubwuerdig sein, nicht realistisch mathematisch exakt.
- Mobile Lesbarkeit gewinnt gegen exakte Realweltgroessen.
- Das Haus aus dem bisherigen Showcase dient als grobe
  Qualitaets-/Proportionsreferenz.
- Jede buildable Insel braucht genug Raum fuer:
  - Startgebaeude,
  - Hof/Vorplatz,
  - ersten Weg,
  - kleine Deko,
  - spaetere Erweiterungsflaechen,
  - mindestens zwei Docking-/Connector-Raender.

Nicht erlaubt:

- Ein Haus, das die Starter-Insel dominiert.
- Eine Insel, die nur eine Bauflaeche hat, aber keinen Hof/Weg/Randkontext.
- Ein Auto, das wie Spielzeug wirkt, wenn es als lernbares Objekt gemeint ist.
- Wege, Tueren oder Deko, die auf Mobile nicht mehr lesbar sind.

## 4. Massstabsebenen

Talvori unterscheidet mehrere Scale-Ebenen:

### World View Scale

- Viele Inseln gleichzeitig sichtbar.
- Assets sind klein.
- Nur Silhouette, Biom, Rolle und Besitzstatus muessen lesbar sein.
- Keine kleinen Bau- oder Interior-Details.

### Island View Scale

- Eine Insel als spielbarer Besitzraum.
- BuildZones, Gebaeude-Aussenformen, Wege, Docking und Erweiterungen muessen
  lesbar sein.
- Kleine Deko darf sichtbar sein, aber nicht im Mittelpunkt stehen.

### Build Area View Scale

- Bauplatz im Fokus.
- Fundament, Wegstart, Lichtpunkt oder kleiner Bauimpuls muessen klar lesbar
  sein.
- Nicht einfach extremer Zoom auf World View.

### Building Exterior Scale

- Gebaeude als eigenstaendiges Aussenobjekt.
- Tuer, Fenster, Dach, Schild und Eingang koennen Slots haben.
- Aussenmassstab muss zur Insel und zum Hof passen.

### Building Interior Scale

- Innenraum ist eigene Detailansicht.
- Moebel, Fenster, Tuer, Lampe, Regal und Teppich koennen Slots haben.
- Innenraum darf stilisiert groesser wirken, wenn der Uebergang plausibel
  bleibt.

### Object Detail Scale

- Grosse oder lernstarke Objekte koennen eigene Detailansicht haben.
- Beispiel Auto: Aussenobjekt in Island/Exterior View, Innenraum als eigene
  Object Detail View.

Grundregel:

Nicht jede Ebene nutzt denselben Pixelmassstab. Detailansichten duerfen eigene
Assets und eigene Skalierung haben. Trotzdem muessen sie logisch
zusammenpassen.

## 5. Referenzobjekte

Diese Referenzobjekte muessen fuer kuenftige Scale-Pruefungen genutzt werden.

| Referenzobjekt | Rolle Im Massstab | Prueft Im Vergleich Zu | Phase |
| --- | --- | --- | --- |
| Mensch/Bewohner | optionale spaetere Human-Scale-Referenz | Tuer, Weg, Haus, Auto, Innenraum | spaeter |
| Kleines Haus/Huette | wichtigste Starter-Gebaeude-Referenz | Inselgroesse, `main_build_area`, Hof, Dachlesbarkeit | ab Phase 2E/2H relevant |
| Tuer | Eintritts- und Human-Scale-Anker | Haus, Bewohner, Weg, Interior-Einstieg | spaeter |
| Fenster | Aussen-/Innen-Detailanker | Hauswand, Satz-/Wissensfortschritt | spaeter |
| Wegbreite | Navigations- und Lesbarkeitsanker | Tuer, Hof, Bewohner, Connector | ab Island View relevant |
| Baum | Biom- und Hoehenanker | Inselrand, Haus, Lichtung, blocked area | Phase 2E relevant |
| Auto | groesseres Aussenobjekt und Object-Detail-Kandidat | Haus, Hof, Weg, Inselgroesse | spaeter |
| Tisch | Interior-Footprint | Raumgroesse, Stuhl, Tasse | spaeter |
| Stuhl | Human-/Interior-Scale | Tisch, Bewohner, Raum | spaeter |
| Tasse | Micro-Objekt und Wortdetail | Tisch, Object Detail View | spaeter |
| Bett/Regal | groessere Interior-Objekte | Raumtiefe, Wand, Kategorie | optional spaeter |

Phase-2E-Regel:

Fuer die Waldlichtung reicht noch kein Auto- oder Interior-Asset. Das
Base-Asset muss aber dimensional nicht verhindern, dass spaeter Haus, Hof, Weg,
Deko, Garten oder groessere Aussenobjekte plausibel gedacht werden koennen.

## 6. Insel-Groessenlogik

Eine Starter-Insel muss Platz bieten fuer:

- `main_build_area`,
- Startgebaeude,
- kleiner Hof/Vorplatz,
- ein erster Weg oder Lichtpunkt,
- ein bis zwei kleine Deko-/Naturbereiche,
- mindestens eine `future_expansion_area`,
- mindestens zwei Docking-Kandidaten,
- blocked/nature areas.

Regel:

Wenn eine Insel nur eine freie Flaeche hat, aber keinen Platz fuer
glaubwuerdige Umgebung, ist sie nicht buildable-ready.

Erforderliche Inselstruktur:

- Zentrum: Startgebaeude/Fundament.
- Vorne/unten oder seitlich: Hof/Vorplatz.
- Randnah: Weg-/Lichtpunkt-Anschluss.
- Seitlich/hinten: Future Expansion Area.
- Zwei offene Raender: Docking-/Connector-Kandidaten.
- Blocked Areas: Felsen, Baumgruppen, Klippen, Unterbau.

## 7. Footprint-Klassen

Talvori nutzt Footprint-Klassen als Denkmodell fuer Slots und Zonen.

| Klasse | Typische Verwendung | Benoetigte Zone/Slot-Art | Relevante View |
| --- | --- | --- | --- |
| `micro` | kleine Deko, Stein, Blume, Tasse | `decoration_slot`, `interior_slot`, `object_slot` | Interior / Object Detail |
| `small` | Laterne, Bank, kleiner Busch | `decoration_area`, `path_side_slot` | Island / Build Area |
| `medium` | Tisch, kleiner Baum, kleiner Brunnen | `decoration_area`, `interior_slot`, `nature_area` | Island / Interior |
| `building_small` | Huette, kleines Haus | `main_build_area`, `building_slot` | Island / Building Exterior |
| `building_medium` | Bibliothek, Werkstatt, Markt | `secondary_build_area`, `future_expansion_area` | Island / Building Exterior |
| `vehicle_small` | Fahrrad, Motorrad optional spaeter | `yard_slot`, `path_area`, `decoration_area` | Island / Object Detail |
| `vehicle_medium` | Auto | `yard_slot`, `exterior_object_slot` | Island / Object Detail |
| `expansion_piece` | Landmodul, Plateau-Erweiterung | `future_expansion_area`, `edge_slot` | Island |
| `connector_anchor` | Bruecken-/Dockingansatz | `dockingPoint`, `edge_slot` | Island / World |

Regel:

Footprint-Klasse entscheidet nicht nur Groesse, sondern auch, ob ein Objekt in
Island View, Interior View oder Object Detail View gehoert.

## 8. Groessenrelationen Als Richtwerte

Diese Richtwerte sind keine finalen Pixelwerte. Sie dienen als
Freigabepruefung fuer Assets.

- Startgebaeude darf die Insel nicht dominieren.
- `main_build_area` muss groesser sein als das spaetere Fundament.
- Fundament braucht Randluft fuer Hof, Weg und spaetere Deko.
- Hof/Vorplatz muss vor einem Haus logisch Platz haben.
- Wegbreite muss zu Tuer/Haus passen.
- Baeume duerfen am Rand groesser wirken, aber die Bauflaeche nicht
  verschlucken.
- Auto braucht eigenen Aussenstellplatz oder Hofbereich.
- Auto-Innenraum wird nicht aus Island View gezoomt, sondern als eigene
  Object Detail View umgesetzt.
- Innenraumobjekte wie Tisch, Stuhl und Tasse gehoeren nicht in Island View.

Mobile-Lesbarkeit:

- Eine relevante Flaeche darf in der normalen Zielansicht nicht nur als Pixel-
  Fleck erscheinen.
- Tap-Ziele brauchen visuelle Randluft.
- Kleine Objekte duerfen dekorativ sein, aber nicht als Pflichtinteraktion in
  der World View dienen.

## 9. Aussen- Und Innenmassstab

Aussenansicht:

- Gebaeude erscheint als Objekt in der Inselwelt.
- Aussen zeigt Besitz, Fortschritt und Silhouette.
- Tuer, Fenster und Dach duerfen andeuten, was innen moeglich wird.

Innenraumansicht:

- Innenraum ist eigene View mit eigener Detailtiefe.
- Innenraum hat eigene Slots und Scale-Regeln.
- Innenobjekte muessen zueinander passen: Tisch zu Stuhl, Tasse zu Tisch,
  Regal zu Wand.

Regel:

Aussen und Innen muessen logisch verbunden sein, aber nicht 1:1 pixelgleich.
Ein kleines Haus kann innen stilisiert groesser wirken, solange Uebergang,
Fantasie und UI das plausibel machen.

## 10. Fahrzeug-/Objektmassstab

Auto als Beispiel:

- Ein Auto auf dem Hof braucht glaubwuerdige Groesse im Verhaeltnis zu Haus,
  Weg und Insel.
- In Island View ist das Auto nur Aussenobjekt.
- Auto-Innenraum ist eigene Object Detail View.
- Frontscheibe, Lenkrad, Sitz, Tuer und Spiegel werden dort als Slots geplant.

Regeln:

- Nicht jedes Objekt bekommt eine Detailansicht.
- Object Detail View ist fuer lernstarke Objekte.
- Auto darf nicht als winziges Deko-Spielzeug erscheinen, wenn es spaeter
  Vokabellernen tragen soll.
- Wenn die Insel keinen plausiblen Stellplatz bieten kann, gehoert Auto nicht
  in diese Island-View-Phase.

## 11. Kategorie-Erweiterbarkeit

Scale-Regeln duerfen nicht nur fuer eine Kategorie funktionieren.

Beispiele:

- Reisen: Auto, Bahnhof, Hotel, Koffer.
- Gesundheit: Praxis, Koerper, Medizinobjekte.
- Essen: Kueche, Tisch, Tasse, Teller.
- Business: Buero, Laptop, Schreibtisch.
- Schule: Klassenzimmer, Tafel, Stuehle.

Regeln:

- Kategorien bleiben Templates.
- Gebaeude-, Raum- und Objekt-Templates muessen zu Footprint-Klassen passen.
- Kategoriekompatibilitaet wird in Metadaten geplant.
- Keine Kategorie wird in Insel-, Slot- oder Widget-Code hart codiert.

## 12. Auswirkungen Auf Waldlichtung

Das naechste Waldlichtung-Base-Asset muss dimensional pruefen:

- Passt spaeter ein kleines Haus glaubwuerdig auf die `main_build_area`?
- Bleibt Platz fuer Hof/Vorplatz?
- Bleibt Platz fuer ersten Weg/Lichtpunkt?
- Gibt es Raum fuer Deko/Natur?
- Gibt es plausible Docking-/Expansion-Raender?
- Wirkt die Insel nicht zu klein fuer spaetere Aussenobjekte wie Auto oder
  Garten?
- Ist das Asset als Island View gedacht, nicht als Interior oder Object Detail
  View?

Fuer Phase 2E bedeutet das:

- Waldlichtung braucht keine fertige Huette.
- Waldlichtung braucht kein Auto.
- Waldlichtung braucht keine Interior-Details.
- Waldlichtung braucht aber genug dimensionale Luft, damit diese Dinge spaeter
  nicht unglaubwuerdig werden.

## 13. Asset-Freigabe-Regel

Ein neues buildable Asset darf nicht freigegeben werden, wenn:

- Hausmassstab unglaubwuerdig wirkt,
- Hof/Terrasse/Garten keinen Platz haben,
- Auto oder groessere Aussenobjekte spaeter nicht plausibel platziert werden
  koennen,
- Wege zu schmal oder unlesbar waeren,
- Baeume/Felsen die Hauptbauflaeche blockieren,
- Erweiterungsstuecke nicht plausibel andocken koennen,
- Insel nur schoen, aber nicht massstaeblich nutzbar ist.

Diese Regel ergaenzt die bestehende Asset-Freigabe-Checkliste aus `235`.

## 14. Prompt-Regeln Fuer Imagegen/Codex

Zukuenftige Asset-Prompts muessen enthalten:

- scale-consistent island layout,
- believable space for a small house, yard, path, garden,
- expansion-ready edges,
- enough room for future exterior objects,
- do not make house/build area oversized,
- do not make island too small for later objects,
- stylized but coherent proportions,
- mobile readable 2.5D/isometric scale.

Ausserdem muss der Prompt klar sagen:

- kein fertiges Haus im Base-Asset,
- keine Interior-Objekte im Island-View-Asset,
- keine Vehicle-Detailansicht im Inselbild,
- keine zu engen oder komplett blockierten Raender.

## 15. Beziehung Zu `238`

`238` definiert Detailstufen.

`239` definiert Groessenlogik zwischen diesen Detailstufen.

Konsequenzen:

- Island View muss gross genug fuer Aussenobjekte sein.
- Interior View loest Innenraumdetails.
- Object Detail View loest Objekt-Innenansichten.
- Detailtiefe entsteht durch Spaces/Views, nicht durch endlosen Zoom.
- Scale-Relationen muessen ueber die Detailstufen hinweg plausibel bleiben.

## 16. Update Von `235`

`docs/world_design/235-world-production-roadmap-and-checklists.md` wird minimal
aktualisiert:

- Phase 2E-A4 wird in der Roadmap sichtbar.
- Status nach Erstellung dieses Dokuments: `fertig`.
- Naechster erlaubter Schritt bleibt: Base-Prompt ueberarbeiten / Phase 2E-B
  erneut.
- Code bleibt blockiert.

## 17. Stop-Regeln

Stoppen, wenn:

- keine professionelle Recherche durchgefuehrt wurde,
- Massstab nicht konkret genug ist,
- Insel nicht genug Platz fuer Haus/Hof/Weg/Expansion hat,
- Aussen- und Innenmassstab verwechselt werden,
- Auto-/Objekt-Detaillogik in Island View gepresst wird,
- Kategorien hart codiert werden,
- Asset erzeugt wird,
- Code geschrieben wird.

Stoppen bedeutet:

- Dimensionen klaeren,
- Referenzobjekte pruefen,
- Footprint-Klasse festlegen,
- dann erst Asset-Prompt oder Code-Scope fortsetzen.

## 18. Akzeptanzkriterien

Dieses Dokument ist gut, wenn:

- Scale-Regeln klar sind,
- Referenzobjekte definiert sind,
- Footprint-Klassen vorhanden sind,
- Island View, Interior View und Object Detail View massstaeblich getrennt
  sind,
- Waldlichtung-Base-Prompt daraus besser ableitbar ist,
- Kategorie-Erweiterbarkeit beruecksichtigt ist,
- Asset-Freigaberegeln erweitert sind,
- Code weiterhin blockiert bleibt.

## Offene Fragen

- Welche konkrete Pixel-/Prozentgroesse soll ein `building_small` im ersten
  Waldlichtung-Base-Asset maximal einnehmen?
- Wann wird ein Mensch/Bewohner als feste Scale-Referenz produziert?
- Soll Auto in der ersten Starter-Insel-Generation nur vorbereitet oder erst in
  spaeteren thematischen Inseln relevant werden?
- Welche Footprint-Klassen werden zuerst in `template.md` verpflichtend?
- Wie werden Scale-Regeln spaeter automatisiert oder halbautomatisch im
  Device-Check geprueft?
