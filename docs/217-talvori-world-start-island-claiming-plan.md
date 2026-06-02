# Talvori Welt Phase 2C: Startinsel-Claiming-Plan

Stand: 2026-06-02

Dieses Dokument plant den naechsten lokalen Welt-Slice nach dem asset-basierten Ursprungshain-Umbau. Es beschreibt, wie die aktuelle hochwertige Insel als Showcase erhalten bleibt und wie Nutzer spaeter eine eigene Startinsel lokal auswaehlen koennen.

Es ist ein reines Planungsdokument. Es wurden keine Dart-/Flutter-Dateien, keine Supabase-Daten, keine SQLite-/Vokabeldaten, keine SRS-Daten, kein `word_progress`, keine Reward Bridge, keine Persistenz, keine Secrets und keine Release-Artefakte geaendert.

Hinweis zur Altgrundlage:

Die PDF `Talvori_Welt_Konzeptdokument_v3.pdf` wurde als strategische Altgrundlage beruecksichtigt, soweit ihre Leitplanken im aktuellen Arbeitskontext vorliegen. Eine gleichnamige PDF-Datei wurde im Repository bei Erstellung dieses Dokuments nicht gefunden.

## 1. Ausgangspunkt

Der aktuelle Welt-Screen zeigt eine hochwertige Beispielinsel:

- separater fullscreen Space-Hintergrund,
- freigestellte Ursprungshain-Insel,
- World Canvas mit Zoom/Pan,
- Hotspots,
- Overlay-Controls,
- Ruecknavigation zur Home-Zentrale.

Diese Struktur erzeugt den gewuenschten ersten Wow-Effekt und ist eine gute technische Basis. Sie soll nicht verworfen werden.

Die aktuelle Ursprungshain-Insel ist aber als persoenliche Startinsel zu fertig:

- Sie hat bereits Haus, Markt und Bibliothek.
- Sie zeigt freie Bauplaetze, Wege, Kristalle, Laternen und starke Ausbaudichte.
- Sie wirkt eher wie ein Zielbild als wie ein erster eigener Anfang.

Neue Grundentscheidung:

Der Nutzer soll beim ersten Weltstart nicht automatisch eine fertige Insel besitzen. Stattdessen soll er eine eigene, einfachere Startinsel auswaehlen und lokal beanspruchen koennen.

## 2. Rolle der Showcase-Insel

Die aktuelle schoene Ursprungshain-Insel ist eine offizielle Showcase-/Beispielinsel.

Sie soll:

- zeigen, was durch Lernen, Aufbau und Ausbau entstehen kann,
- Motivation und Qualitaetsgefuehl erzeugen,
- den Wow-Effekt beim ersten Weltkontakt tragen,
- klar als Beispiel/Talvori-Bau erkennbar sein,
- nicht automatisch Besitz des Nutzers sein,
- im Startbereich sichtbar bleiben,
- spaeter als Gastmodus- oder Onboarding-Insel dienen koennen.

Produktrolle:

Die Showcase-Insel ist das Versprechen. Die eigene Startinsel ist der Anfang.

## 3. Erster Weltstart

Idealer Ablauf:

1. Nutzer tippt auf den Globe.
2. Die Weltansicht oeffnet sich.
3. Nutzer sieht die Showcase-Insel und mehrere freie Startinseln.
4. Nutzer kann zoomen und in alle Richtungen pannen.
5. Nutzer waehlt eine freie Startinsel.
6. Eine kleine Info-Card oder ein Bottom Sheet erklaert Stimmung und Starttyp.
7. Nutzer tippt `Diese Insel waehlen`.
8. Die ausgewaehlte Insel wird lokal zu `Mein Plot`.
9. `Mein Plot` bringt den Nutzer spaeter immer zur eigenen Insel zurueck.

Phase 2C bleibt lokal/mock:

- keine Persistenz,
- keine Supabase Writes,
- keine Cloud-Logik,
- keine echte Besitzpruefung,
- kein Reward-System.

## 4. Starter-Inseltypen

Die Architektur soll mehrere Startinseltypen ermoeglichen. In Phase 2C muessen noch nicht alle Assets existieren.

Moegliche Startinseln:

| Startinsel | Stimmung | Rolle |
| --- | --- | --- |
| Waldlichtung | warm, gruen, ruhig | klassischer Cozy-Einstieg |
| Ackerfeld | offen, produktiv, hell | Ressourcen-/Wachstumsgefuehl |
| Wieseninsel | freundlich, leicht, blumig | sanfter Start fuer neue Nutzer |
| Felseninsel | robust, klar, strukturiert | Fundament-/Bau-Fokus |
| Wasserfall-Insel | lebendig, magisch, blau | Energie, Fluss, Bewegung |
| Kristallinsel | mystisch, lila/cyan | Wissen, Magie, Licht |
| Nebelwald | geheimnisvoll, ruhig | Entdecken, langsames Freilegen |
| Wuesteninsel | warm, reduziert, sonnig | spaeterer Kontrast-Biome |
| Schneehain | klar, ruhig, hell | spaeterer Winter-/Fokus-Biome |
| Ruineninsel | alt, verwunschen, reparierbar | Comeback-/Reparaturmotiv |

Phase 2C braucht nur 3 bis 5 lokale Mock-Optionen. Die Liste definiert die Richtung.

## 5. Insel-Auswahl

Freie Inseln schweben im Space um die Showcase-Insel herum.

Auswahlverhalten:

- Jede freie Insel hat einen einfachen Namen.
- Jede freie Insel hat eine kurze Stimmung.
- Nutzer kann eine Insel antippen.
- Eine kleine Info-Card oder ein Bottom Sheet erscheint.
- Aktion: `Diese Insel waehlen`.
- Nach Auswahl wird die Insel lokal als eigene Insel markiert.
- `Mein Plot` springt zur gewaehlten Insel.

Nicht in Phase 2C:

- keine echte Persistenz,
- keine Cloud-Besitzlogik,
- keine Supabase Writes,
- keine Oekonomie,
- keine echte Freunde-/Social-Logik.

## 6. Gefuehrte Freiheit statt Minecraft

Leitplanke aus der alten Konzeptgrundlage:

Talvori soll weder komplett vorgegeben noch komplett random sein.

Talvori ist in Version 1 kein freier Minecraft-/Sandbox-Klon.

Empfohlen ist gefuehrte Freiheit:

- Nutzer waehlt Inseltyp, Gebaeude, Stil, Platzierung und Deko.
- Das System haelt Qualitaet, Lesbarkeit und aesthetische Ordnung hoch.
- Bauplaetze, Raster/Slots, sinnvolle Varianten und Begrenzungen verhindern Chaos.
- Die Welt bleibt schoen, auch wenn der Nutzer freie Entscheidungen trifft.

Nicht Phase 2C:

- kein Detailbau von Waenden,
- kein Boden-/Blocksystem,
- keine freie Bauphysik,
- kein freier 3D-Sandbox-Modus.

## 7. Aufbau-Stufen und Zoom-Level

### Zoom-Level 1: Weltansicht

Zeigt:

- Showcase-Insel,
- freie Startinseln,
- spaetere Freunde,
- Nachbarplots,
- Community-Inseln.

Zweck:

Orientierung, Auswahl, Reise und spaetere soziale Umgebung.

### Zoom-Level 2: Inselansicht

Zeigt:

- eigene Insel,
- Bauplaetze,
- Wege,
- erste Ressourcen,
- sichtbare Module.

Zweck:

Eigener Ort, Ausbau und lokale Entscheidungen.

### Zoom-Level 3: Bauplatzansicht

Zeigt:

- freien Bauplatz,
- moegliche Gebaeude,
- Landschaftselemente,
- einfache Auswahl.

Zweck:

Gefuehrte Bauentscheidung ohne komplexe Sandbox.

### Zoom-Level 4: Detailausbau spaeter

Moeglich spaeter:

- Varianten,
- Dach,
- Wandmaterial,
- Farbe,
- Dekoration,
- Boden,
- kleine Bewohner,
- Gartenobjekte.

Nicht Phase 2C:

Phase 2C baut noch keine Waende, Boeden oder Gebaeudedetails.

## 8. Modulares Baukasten-System

Aus der Konzeptleitlinie abgeleitete Grundstruktur:

### Gebaeudetypen

- Haus
- Markt
- Bibliothek
- Werkstatt
- Gartenhaus
- Brunnen
- Turm
- Akademie
- Hafen/Bruecke

### Level-Stufen

- Fundament
- kleines Gebaeude
- ausgebautes Gebaeude
- lebendiges Gebaeude
- Meister-Version

### Varianten

- Dach
- Wandmaterial
- Farbe
- Schild
- Licht
- kleine Animation
- Dekoration

### Dekorationen

- Baeume
- Blumen
- Laternen
- Zaeune
- Wege
- Schilder
- Tiere
- Kisten
- Baenke

### Leben-Ebene

- NPCs
- Tiere
- Rauch
- Licht
- Bewegungen
- Partikel

### Lern-Ebene

- private Nebel
- Questmarker
- Reparaturstatus
- Lernwert

Phase 2C bereitet diese Struktur nur vor. Sie setzt sie nicht als Vollsystem um.

## 9. Was kann spaeter gebaut werden?

Grobe Kategorien:

| Kategorie | Beispiele |
| --- | --- |
| Gebaeude | Haus, Markt, Bibliothek, Werkstatt, Gartenhaus, Brunnen, Turm |
| Natur | Baeume, Blumen, Wasserfall, Teich, Felsen, Waldstuecke |
| Wege und Bruecken | Steinwege, Holzbruecken, magische Verbindungen |
| Dekoration | Laternen, Kristalle, Zaeune, Baenke, Schilder |
| Lebendige Elemente | kleine Bewohner, Tiere, Rauch, Lichteffekte, Partikel |
| Lernorte | Satzfunken-Platz, Review-Schrein, Wortgarten, Phrase-Schmiede |
| Regionale/Community-Elemente spaeter | Bahnhof, Hafen, Leuchtturm, Stadion, Fernsehturm |

## 10. Ressourcenbezug

Aktueller Mock:

- `coins`
- `wood`
- `stone`
- `knowledgePoints`

Langfristige Ressourcenleitlinie:

| Ressource | Lernbezug | Weltbezug |
| --- | --- | --- |
| Stein | Wort erkannt | Fundament |
| Holz | Wort aktiv erinnert | Waende und Konstruktion |
| Glas | Wort im Satz verstanden | Fenster, Schilder, Strassen |
| Metall | Phrase gemeistert | stabile Struktur, Maschinen, Spezialteile |
| Bewohner | Dialog geschafft | Gebaeude wird lebendig |
| Licht/Energie | Aussprache oder Aktivierung | Leuchten und Effekte |
| Reparaturpunkte | Wiederholung erledigt | private Nebel entfernen |

Phase 2C bleibt Mock:

- keine echte Reward Bridge,
- keine SRS-Anbindung,
- keine Oekonomie,
- keine Ressourcen-Persistenz.

Mittelfristig sollte die UI-Ressourcenlogik an die praezisere Lernressourcenlogik angepasst werden.

## 11. Datenmodell- und Architektur-Vorbereitung

Die Welt soll spaeter nicht als fertiges Gesamtbild gespeichert werden.

Stattdessen sollen Zustands-, Baustein- und Platzierungsdaten beschrieben werden.

Moegliche spaetere Modelle:

- `WorldRegion`
- `WorldPlot`
- `IslandObject`
- `StarterIslandOption`
- `ShowcaseIsland`
- `OwnIsland`
- `FriendIsland`
- `ForeignIsland`
- `PlacedWorldItem`
- `WorldResourceWallet`
- `PublicDisplayState`
- `PrivateLearningOverlay`

Jede Insel braucht spaeter mindestens:

- `id`
- `type`
- `biome`
- `displayName`
- `worldPosition`
- `scale`
- `assetPath`
- `ownershipState`
- `publicDisplayState`
- optional `connectedIslandIds`
- optional `placedItems`

Jedes platzierte Weltobjekt braucht spaeter mindestens:

- `id`
- `plotId` oder `islandId`
- `itemType`
- `category`
- `position`
- `level`
- `variant`
- `visualState`
- optional `learningBinding`

## 12. Skalierung und Weltkacheln

Aus der Konzeptleitlinie:

- Nicht alle Grundstuecke live gleichzeitig laden.
- Nur sichtbaren Kartenausschnitt, direkte Nachbarschaft oder besuchte Grundstuecke laden.
- Auf Weltkarte nur Vorschau zeigen:
  - Besitzer,
  - Level,
  - Hauptgebaeude,
  - Lernwert,
  - Aktivitaetsstatus.
- Details erst beim Besuch laden.
- Assets lokal oder ueber CDN ausliefern.
- Nicht pro Nutzer als fertige Bilder speichern.
- Updates nach abgeschlossenen Aktionen, nicht jede Sekunde live.
- Realtime nur spaeter fuer Chat, Online-Status und leichte Live-Signale.

Fuer Phase 2C bedeutet das:

- mehrere Inseln auf einem lokalen Mock-WorldCanvas,
- keine echte 10.000-Nutzer-Welt,
- Architektur aber so denken, dass spaetere Regionen/Kacheln moeglich bleiben.

## 13. Rendering-Strategie und 3D-Offenheit

Aktuell ausreichend:

- Flutter,
- Image-Assets,
- `Stack`,
- `InteractiveViewer`,
- Hotspots.

Regeln:

- Weltlogik darf nicht direkt im Renderer stecken.
- Insel-/Plot-/Objekt-Daten sollen rendererunabhaengig gedacht werden.
- Renderer kann spaeter ausgetauscht werden.
- Flame, Tiled-/JSON-System oder langfristig 3D-/2.5D-Engine koennen spaeter geprueft werden.
- Kein echter 3D-Umbau in Phase 2C.
- Keine neuen Packages ohne Freigabe.

## 14. Schnellnavigation und Orientierung

Pflicht, sobald die Welt groesser wird:

- `Mein Plot`
- schneller Sprung zu Freunden
- Freund antippen und direkt dessen Grundstueck oeffnen
- optional Weltkarte/Regionsuebersicht

Phase 2C:

- lokale Vorbereitung reicht,
- keine echte Freundesnavigation,
- kein Social-Backend,
- keine Cloud-Abfrage.

Schnellnavigation gehoert in den Overlay-Control-Layer, nicht in einzelne Insel-Widgets.

## 15. Phase-2C-Ziel

Phase 2C soll einen kleinen lokalen Slice liefern:

- Showcase-Insel bleibt sichtbar.
- 3 bis 5 freie Starter-Inseln sind als einfache Mock-Objekte sichtbar.
- Inseln sind auf dem World Canvas verteilt.
- Nutzer kann eine freie Insel antippen.
- Info-Card oder Bottom Sheet erscheint.
- `Insel waehlen` setzt lokalen Mock-State.
- `Mein Plot` springt zur gewaehlten Insel.
- keine Persistenz.
- keine Backend-Logik.
- keine Reward Bridge.

## 16. Scope-Grenzen

Weiterhin ausgeschlossen:

- keine Supabase Writes,
- keine SQLite-/SRS-/`word_progress`-Aenderungen,
- keine Reward Bridge,
- keine echte Ressourcen-Persistenz,
- keine Cloud-Welt,
- kein Social-Backend,
- keine echte Freundesnavigation,
- keine Multiplayer-Funktion,
- keine echte Oekonomie,
- kein Detailbau von Waenden/Boeden,
- keine freie Bauphysik,
- keine komplexe 3D-Engine,
- keine neuen Packages ohne Freigabe.

## 17. Akzeptanzkriterien fuer die spaetere Phase 2C

Phase 2C gilt als gelungen, wenn:

- Nutzer sieht eine hochwertige Showcase-Insel.
- Nutzer versteht, dass die Showcase-Insel nur ein Beispiel ist.
- Nutzer sieht mehrere freie Startinseln.
- Nutzer kann zoomen und pannen.
- Nutzer kann eine Startinsel antippen.
- Nutzer kann eine eigene Insel lokal auswaehlen.
- `Mein Plot` springt zur eigenen Insel oder ist dafuer sauber vorbereitet.
- Die Architektur bleibt modular und rendererunabhaengig.
- Die Welt ist nicht als ein fertiges Gesamtbild gedacht.
- Keine Backend-/SRS-/Reward-Seiteneffekte entstehen.

## 18. Umgang mit aktuellem Stand

Der aktuelle Fullscreen-Screen ist eine gute visuelle und technische Basis.

Er soll nicht verworfen werden.

Entscheidungen:

- Die schoene Insel bleibt als Showcase-/Motivationsinsel.
- Der naechste Ausbau soll mehrere Inselobjekte auf dem World Canvas vorbereiten.
- Eigene Startinseln werden zunaechst lokal/mock und einfacher als die Showcase-Insel.
- Gebaeudebau, Ressourcenlogik, Reward Bridge und Persistenz kommen spaeter.
- Vor weiterem Code sollte dieser Startinsel-Claiming-Plan committed werden.

