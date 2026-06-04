# Talvori Welt: Phase 2F Foundation Complete Plan

Stand: 2026-06-04

Dieses Dokument plant Phase 2F fuer Talvori Welt. Es beschreibt den naechsten
Bauzustand `foundation_complete` nach dem lokalen Phase-2E-E-Proof-of-Concept.
Es ist ein reines Planungsdokument. Es wurden keine Dart-/Flutter-Dateien,
keine Assets, keine App-Integration, keine Supabase-Daten, keine SQLite-/
SRS-/`word_progress`-Daten, keine Reward Bridge, keine Persistenz, keine
Secrets und keine Release-Artefakte geaendert.

Fuehrende Grundlagen:

- `docs/world_design/235-world-production-roadmap-and-checklists.md`
- `docs/world_design/236-buildable-forest-clearing-template-concept.md`
- `docs/world_design/237-buildable-forest-clearing-greybox-layout.md`
- `docs/world_design/238-multi-scale-world-and-interior-system.md`
- `docs/world_design/239-world-scale-and-dimension-rules.md`
- `docs/world_design/240-private-island-state-system.md`
- `docs/world_design/241-build-feedback-animation-and-sound.md`
- `assets/images/world/buildable_islands/forest_clearing/template.md`

## 1. Zweck Von Phase 2F

Phase 2F plant den Zustand `foundation_complete`.

Ziele:

- Noch kein Code.
- Noch kein Asset.
- Noch keine App-Integration.
- Klar definieren, wie sich `foundation_complete` von
  `foundation_started` unterscheidet.
- Einen ableitbaren Asset-Prompt fuer ein spaeteres transparentes Overlay
  vorbereiten.

Nicht-Ziele:

- Kein Haus.
- Kein Rohbau.
- Keine Waende.
- Kein Dach.
- Kein `frame_started`.
- Kein Gebaeude-Level.
- Keine Persistenz.
- Keine Reward Bridge.
- Keine echte Lern- oder Ressourcenlogik.

Phase 2F darf nicht automatisch Haus, Rohbau oder ein vollstaendiges Gebaeude
starten. Es geht nur um den Abschluss des Fundaments.

## 2. Research-Ergebnis

### Quelle / Orientierung

- [Game Developer: City builder games - make Build-Up animations cheaply](https://www.gamedeveloper.com/design/city-builder-games-make-build-up-animations-cheaply)
  beschreibt fuer City-Builder, dass Baufortschritt oft ueber klar getrennte
  Konstruktionsgrafiken oder mehrere Fertigstellungsframes sichtbar wird.
  Wichtig fuer Talvori ist vor allem: gleiche Kamera/Perspektive, gleiche
  Lichtlogik und deutlich erkennbare Zwischenstufen.
- [Unity Manual: Prefabs](https://docs.unity.cn/Manual/Prefabs.html)
  bestaetigt die professionelle Grundidee wiederverwendbarer Templates/
  Varianten statt fest eingebrannter Einzelbilder. Fuer Talvori bedeutet das:
  `foundation_complete` bleibt ein separater visueller Zustand innerhalb des
  Template-Systems.
- [Designing Game Feel. A Survey](https://arxiv.org/abs/2011.09201) ordnet
  Game Feel als bewusst gestaltete Rueckmeldung ein. Besonders relevant ist
  die Ableitung, dass klare visuelle Verstaerkung die Bedeutung eines
  Spielereignisses kommuniziert.
- [Critical Design Elements for Mobile City Builders](https://www.designthegame.com/learning/tutorial/critical-design-elements-mobile-city-builders)
  betont kurze Mobile-Sessions, klare Ziele, sichtbare Meilensteine und
  reduzierte UI-Komplexitaet.
- [Anno Union: Residential Tiers](https://www.anno-union.com/devblog-residential-tiers/)
  zeigt als professionelle Orientierung, dass sichtbare Progressionsstufen,
  Meilensteine und visuelle Charakterisierung zusammenarbeiten, ohne dass
  Talvori diese Struktur kopiert.

### Ableitung Fuer Talvori

Talvori soll Baufortschritt nicht als harten Bildtausch zeigen, sondern als
kurze, lesbare und hochwertige Zustandsveraenderung. Jeder Bauzustand braucht
eine eigene visuelle Bedeutung. `foundation_started` zeigt den ersten Impuls;
`foundation_complete` zeigt einen klar abgeschlossenen Sockel, der spaeter
einen Rohbau tragen kann.

### Konkrete Entscheidung

`foundation_complete` wird als eigenes transparentes Overlay geplant. Es
ersetzt visuell `foundation_started`, statt es als weiteren Layer darueber zu
stapeln. Der Zustand bleibt klein, category-neutral und an dieselbe
`main_build_area` gebunden.

## 3. Abgrenzung Zu `foundation_started`

`foundation_started` bedeutet:

- erster Fundamentansatz,
- unvollstaendig,
- rohe Erde und erste Steine,
- kleiner Bauimpuls,
- sichtbar: "Hier hat etwas begonnen."

`foundation_complete` bedeutet:

- sauberes vollstaendiges Fundament,
- stabiler, klarer Gebaeudesockel,
- vorbereitet fuer `frame_started`,
- sichtbar: "Dieses Fundament kann jetzt etwas tragen."

`foundation_complete` bedeutet nicht:

- kein Haus,
- keine Waende,
- kein Dach,
- kein fertiges Gebaeude,
- keine grosse Baustelle,
- kein Kategoriegebaeude.

Die beiden Zustaende duerfen nicht zu aehnlich aussehen. Wenn der Nutzer den
Wechsel nicht sofort erkennt, ist Phase 2F visuell nicht erfolgreich.

## 4. Visuelles Ziel Fuer `foundation_complete`

`foundation_complete` soll:

- dieselbe 2.5D/isometrische Perspektive wie `base.png` nutzen,
- dieselbe Canvas-Groesse wie Base und Started nutzen: `1536 x 1024`,
- ein transparentes Overlay sein,
- exakt auf der `main_build_area` sitzen,
- wie ein vollstaendiger Sockel oder ein klares Fundament wirken,
- hochwertiger, stabiler und abgeschlossener wirken als `foundation_started`,
- natuerliche Materialien nutzen: Stein, geglaettete Erde, leichte Kanten,
- genuegend zurueckhaltend bleiben, damit `frame_started` spaeter darauf
  aufbauen kann,
- in Island View und Build Area View lesbar bleiben.

Nicht erlaubt:

- moderner Betonblock,
- UI-Plattform,
- Rechteck-Marker,
- technischer Baukreis,
- fertiges Haus,
- Waende,
- Dach,
- grosse Magie- oder Explosionseffekte,
- Kategorie-Symbole.

## 5. State-Reihenfolge

Die geplante Reihenfolge bleibt:

1. `empty`
2. `foundation_started`
3. `foundation_complete`
4. spaeter `frame_started`
5. spaeter `frame_complete`
6. spaeter `building_level_1`

Phase 2F fuehrt nur `foundation_complete` ein.

Nicht Teil von Phase 2F:

- Rohbau,
- Waende,
- Haus,
- Gebaeudeauswahl,
- Innenraum,
- Expansion,
- PlacedItems,
- echte Ressourcen- oder Lernlogik.

## 6. Asset-Strategie

Entscheidung:

- `foundation_complete` wird als eigenes transparentes Overlay geplant.
- Es nutzt denselben Canvas wie `base.png` und `foundation_started.png`.
- Es ersetzt visuell `foundation_started`, statt beide Fundamente dauerhaft
  uebereinander zu rendern.
- Es bleibt ein `BuildAreaState`-Overlay.
- Es ist kein Full-State-Replacement.
- Es ist kein `PlacedWorldItemState`.
- Es ist kein `IslandExpansionState`.

Begruendung:

Die Overlay-Strategie ist fuer diesen kleinen Schritt am klarsten und am
wenigsten riskant. Sie erhaelt das Base-Asset als `IslandBaseState`, bewahrt
die spaetere Modulstrategie und verhindert, dass ein einzelnes Komplettbild zu
viel Spielwahrheit enthaelt.

Datei, die spaeter entstehen darf:

```text
assets/images/world/buildable_islands/forest_clearing/foundation_complete.png
```

Diese Datei darf erst nach einem eigenen Asset-Block erzeugt werden.

## Asset-Prompt Fuer `foundation_complete`

Status:

- Prompt vorbereitet.
- Asset noch nicht erzeugt.
- Kein Code.
- Kein `template.md`-Update.
- Keine App-Integration.

Spaetere Zieldatei:

```text
assets/images/world/buildable_islands/forest_clearing/foundation_complete.png
```

Grundlage fuer den Asset-Block:

- `assets/images/world/buildable_islands/forest_clearing/base.png`
- `assets/images/world/buildable_islands/forest_clearing/foundation_started.png`

### Vollstaendiger Prompt Auf Englisch

```text
Create a transparent PNG overlay only for the Talvori buildable forest clearing
island. The overlay represents the "foundation_complete" construction state.

Use the existing base island image and the existing "foundation_started" overlay
as visual references. The new overlay must use the exact same canvas size as the
base and foundation_started images: 1536 x 1024 px. It must be RGBA with a fully
transparent background and transparent corners.

The overlay must align to the existing main_build_area in the center / slightly
front part of the forest clearing. It must use the same 2.5D / isometric mobile
game perspective, lighting direction, material language and scale as the current
base island and foundation_started overlay.

Create a complete but simple natural stone foundation. It should look more
finished, stable and intentional than foundation_started, clearly different from
the earlier rough first foundation marks. It should look complete enough to be
called a finished foundation and prepared to support a small cozy hut or house
later.

Use natural stones, compacted earth, subtle edge definition and materials that
fit the forest clearing: soft earth, moss-adjacent stones, natural stone edges,
slightly leveled ground. Keep it calm, high quality and integrated into the
island. The foundation should feel like part of the world, not an interface
element.

The foundation must leave enough space for a future yard / front area / first
path. It must not cover the future expansion area, must not block docking
candidates, and must not dominate the island. It should remain category-neutral
and not imply a specific future theme such as travel, health, business, school,
food or technology.

This is not a building state. Do not create frame_started. Do not add walls,
roof, scaffolding, house parts, hut parts or finished building elements. The
result should be only the completed foundation layer, ready for a later
construction stage.
```

### Negative Prompt / Ausschlussliste

```text
No full island image. No background. No sky. No space background. No shadow
rectangle. No matte. No hard rectangular canvas artifact. No green-screen or
chroma-key residue.

No house. No hut. No walls. No roof. No finished building. No building frame.
No scaffolding. No doors. No windows. No furniture. No interior view.

No modern concrete slab. No modern platform. No rectangular UI platform. No
glowing magical platform. No UI marker. No selection ring. No button. No text.
No labels. No icons. No category symbols.

No heavy particles baked into the asset. No large dust cloud baked into the
static overlay. No aggressive glow. No explosion. No magical effect.

Do not make the foundation oversized. Do not cover the yard/front area. Do not
cover the path candidate. Do not cover future expansion areas. Do not block
docking candidates. Do not make it look like frame_started or a building.
```

### Technische Anforderungen

- Output-Datei fuer den spaeteren Asset-Block:
  `assets/images/world/buildable_islands/forest_clearing/foundation_complete.png`
- PNG RGBA.
- Transparente Ecken.
- Transparenter Hintergrund.
- Gleiche Canvas-Groesse wie Base und Started: `1536 x 1024`.
- Sichtbarer Inhalt sitzt in derselben `main_build_area` wie
  `foundation_started`.
- Keine separate Inselgrafik.
- Keine rechteckige Matte.
- Keine harten Schatten, die wie ein eingebrannter Hintergrund wirken.
- In diesem Prompt-Block wird kein Asset erzeugt.

### Pruefkriterien Nach Erzeugung

Nach einem spaeteren Asset-Block muss geprueft werden:

- Overlay passt perspektivisch und raeumlich auf `base.png`.
- Overlay ersetzt `foundation_started` visuell, statt dauerhaft darueber
  gestapelt zu werden.
- Es wirkt vollstaendig, stabil und natuerlich.
- Es unterscheidet sich klar von `foundation_started`.
- Es sieht nicht wie `frame_started` aus.
- Es enthaelt keine Gebaeudeteile, keine Waende, kein Dach und kein Haus.
- Es wirkt nicht wie UI, Marker, Plattform oder moderner Betonblock.
- Es blockiert spaeteres Haus/Huette, Hof/Vorplatz, Weg, Expansion und
  DockingCandidates nicht.
- Es funktioniert in Island View und bleibt bei erwarteter Skalierung lesbar.
- Es bleibt category-neutral.

## 7. Feedback-Sequenz

Geplanter Build-Feedback-Moment:

1. Kurzer Fokus auf bestehendes `foundation_started`.
2. Kurzer Bauabschluss-Impuls.
3. Das Fundament wird sauberer, stabiler und vollstaendiger.
4. Kurzer Success-Glow.
5. Hinweistext erscheint: `Das Fundament ist fertig.`
6. Spaeter optional Sound oder Haptik.

Vorbereitete Feedback-ID:

```text
build.foundation.complete
```

Grenzen:

- Keine Sounddatei in Phase 2F-Planung.
- Kein Audio-Package.
- Keine produktive Audio-Schicht.
- Kein Partikelsystem.
- Keine Reward-/Ressourcenanimation.
- Kein harter Bildwechsel ohne Feedback-Moment.

Wenn Phase 2F spaeter implementiert wird, darf sie hoechstens eine kleine,
ruhige Animation nutzen: Fokus, Fade/Scale oder kurzer Glow. Der vollstaendige
Drop/Dust/Debris-Zielmoment aus `241` bleibt weiterhin ein spaeteres Zielbild,
nicht Pflicht fuer den ersten `foundation_complete`-Slice.

## 8. Nutzerfuehrung

Wenn `foundation_started` aktiv ist, soll der Nutzer erkennen:

- Das Fundament hat begonnen.
- Es gibt einen naechsten klaren Schritt.
- Der naechste Schritt ist noch nicht Hausbau, sondern Fundamentabschluss.

Moeglicher kurzer Hinweistext:

```text
Stelle das Fundament fertig, damit spaeter ein Haus entstehen kann.
```

Moeglicher Kontextkarten-Titel:

```text
Fundament fertigstellen
```

Regeln:

- Hinweis kurz halten.
- Keine technischen Begriffe.
- Kein langer Tutorial-Text.
- Visueller Fokus nach den Kontrastregeln aus `241`: violett, magenta oder
  cyan, nicht gruen/mint auf gruener Flaeche.
- Nach `foundation_complete` verschwinden Fertigstell-Hinweis und Fokus.
- Kein Onboarding-Framework.
- Keine Persistenz, die merkt, ob der Nutzer den Hinweis gesehen hat.

## 9. Scale-/Dimension-Regeln

`foundation_complete` muss die Regeln aus `239` einhalten:

- Es darf nicht zu gross wirken.
- Es muss spaeter ein kleines Haus oder eine Huette tragen koennen.
- Es braucht Randluft fuer Hof, Vorplatz und ersten Weg.
- Es darf die `future_expansion_area` nicht blockieren.
- Es darf Docking- oder Connector-Kandidaten nicht verdecken.
- Es muss als Island-View-/Build-Area-Zustand funktionieren, nicht als
  Interior- oder Object-Detail-Asset.
- Es darf die Insel nicht wie ein abgeschlossenes fertiges Plateau wirken
  lassen.

Prueffragen fuer spaetere Asset-Freigabe:

- Ist der Sockel gross genug fuer ein kleines Haus?
- Bleibt vor dem Fundament Platz fuer Hof/Vorplatz?
- Bleibt ein Weganschluss plausibel?
- Bleiben Randbereiche fuer Deko, Docking und Expansion lesbar?
- Wirkt das Fundament stabil, aber nicht wie ein fertiges Gebaeude?

## 10. Kategorie-Erweiterbarkeit

`foundation_complete` ist category-neutral.

Es enthaelt keine harten Hinweise auf:

- Reisen,
- Gesundheit,
- Alltag,
- Business,
- Schule,
- Essen,
- Technik,
- Kultur.

Spaetere Gebaeudevarianten koennen ueber Templates und Kategorien darauf
aufbauen. Das Fundament bleibt eine generische Grundlage fuer ein erstes
Startgebaeude, z. B. Haus, Huette oder Basis-Lernhaus.

## 11. Template-Aenderungen Spaeter

Noch nicht ausfuehren.

Wenn `foundation_complete.png` spaeter erzeugt und vorgeprueft wurde, muss
`assets/images/world/buildable_islands/forest_clearing/template.md` ergaenzt
werden:

- `assetPaths.foundation_complete`
- optional `foundationCompleteOverlayAnchor`
- optional `foundationCompleteOverlayScale`
- Status / Preview / Freigabe fuer Phase 2F
- Entscheidung, ob `codeAllowed` fuer einen engen Phase-2F-Mock-Slice gilt

Werte duerfen nicht geraten werden. Wenn Device-/Preview-Check fehlt, bleiben
Koordinaten oder Skalenwerte `TBD`.

## 12. Roadmap-Update

`docs/world_design/235-world-production-roadmap-and-checklists.md` wird minimal
aktualisiert:

- Phase 2F Status: `Planung gestartet`
- Naechster erlaubter Schritt nach diesem Dokument: Asset-Prompt fuer
  `foundation_complete` ableiten
- Phase 2F-Code bleibt blockiert, bis Asset, Preview, Template-Update und
  Freigabe erfolgt sind.

## 13. Stop-Regeln

Stoppen, wenn:

- `foundation_complete` wie ein fertiges Haus wirkt,
- Waende, Dach oder Gebaeude enthalten sind,
- es nur wie ein harter Bildtausch geplant wird,
- es das Base-Asset komplett ersetzen soll,
- Kategorie hart eingebaut wird,
- Scale-/Dimension-Regeln nicht beachtet werden,
- `foundation_started` und `foundation_complete` zu aehnlich aussehen,
- `foundation_complete` Docking, Expansion oder Vorplatz blockiert,
- Sounddateien oder Audio-Packages geplant werden,
- Code geschrieben wird,
- Assets erzeugt werden,
- Persistenz, Supabase, SRS, `word_progress` oder Reward Bridge beruehrt
  werden.

## 14. Akzeptanzkriterien

Das Dokument ist gut, wenn:

- klar ist, was `foundation_complete` visuell bedeutet,
- klare Abgrenzung zu `foundation_started` besteht,
- Overlay-Strategie festgelegt ist,
- `foundation_complete` noch kein Haus/Rohbau ist,
- Feedback-ID `build.foundation.complete` vorbereitet ist,
- Nutzerfuehrung fuer den naechsten Schritt geplant ist,
- Scale, Dimension, Kategorie-Neutralitaet und Template-Grenzen beachtet sind,
- der Scope klein bleibt,
- keine Produktlogik gebaut wird,
- ein naechster Asset-Prompt ableitbar ist.

## 15. Offene Fragen

- Reicht die im Asset-Prompt definierte Unterscheidung
  "stabiler/fertiger als `foundation_started`, aber kein Rohbau/Gebaeude" nach
  dem ersten Device-Check aus?
- Soll der spaetere Phase-2F-Slice wieder nur einen Button nutzen oder bereits
  eine lokale Mock-Aufgabe vorbereiten?
- Reicht ein einziges Overlay langfristig fuer den Fundamentabschluss oder
  braucht `foundation_complete` spaeter Varianten je erstem Gebaeudetyp?
- Soll der `foundation_complete`-Effekt in Phase 2F nur Fade/Scale nutzen oder
  bereits einen kleinen Abschluss-Glow?

## 16. Quellen Und Orientierung

- Game Developer: City builder build-up animation approach:
  https://www.gamedeveloper.com/design/city-builder-games-make-build-up-animations-cheaply
- Unity Manual: Prefabs and reusable templates:
  https://docs.unity.cn/Manual/Prefabs.html
- Pichlmair/Johansen: Designing Game Feel. A Survey:
  https://arxiv.org/abs/2011.09201
- Design the Game: Critical Design Elements for Mobile City Builders:
  https://www.designthegame.com/learning/tutorial/critical-design-elements-mobile-city-builders
- Anno Union: Residential Tiers as progression/milestone orientation:
  https://www.anno-union.com/devblog-residential-tiers/
