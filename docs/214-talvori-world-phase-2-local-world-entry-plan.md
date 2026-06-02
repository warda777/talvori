# Talvori Welt Phase 2: Lokaler Welt-Einstieg Plan

Stand: 2026-06-02

Dieses Dokument plant Phase 2 nach dem freigegebenen Abschluss der Phase-1-Home-Zentrale.

Es ist ein reines Planungsdokument. Es wurden keine Dart-/Flutter-Dateien, keine Supabase-Daten, keine SQLite-/Vokabeldaten, keine SRS-Daten, kein `word_progress`, keine Secrets und keine Release-Artefakte geaendert.

## 1. Ziel von Phase 2

Phase 2 soll den ersten lokalen Einstieg in die Talvori Welt liefern.

Nach Phase 2 soll minimal funktionieren:

- Der Globe-Tap fuehrt nicht mehr nur zu einem Platzhalter, sondern in eine lokale Startregion.
- Die Startregion zeigt einen eigenen Plot.
- Auf dem Plot sind exakt drei erste Gebaeude sichtbar:
  - Haus,
  - Markt,
  - Bibliothek.
- Eine kleine lokale/mock Ressourcenleiste macht sichtbar, dass Weltaufbau spaeter aus Lernaktionen entstehen kann.
- Der Screen funktioniert ohne Cloud, ohne Supabase Writes und ohne echte Ressourcen-Persistenz.
- Ruecknavigation zur Home-Zentrale funktioniert sauber.

Phase 2 ist noch nicht:

- keine Reward Bridge als Vollsystem,
- keine echte Lernbelohnung,
- keine Ressourcen-Oekonomie,
- keine Cloud-Welt,
- keine Social-Welt,
- keine Persistenz-Migration,
- kein fertiges Gebaeude-Ausbau-System.

Der Kernbeweis ist:

> Ich tippe auf den Globe und sehe meine erste lokale Talvori-Region mit eigenem Plot.

## 2. Startregion

### Name

Arbeitstitel: **Talvori Ursprungshain**

Der Name ist bewusst klein, warm und lokal. Er vermeidet ein grosses Reichs-/Metropolenversprechen, bevor das Welt-System wirklich existiert.

### Rolle im Talvori-Konzept

Der Ursprungshain ist der erste Ort, an dem aus gesammelten Woertern spaeter sichtbare Welt entsteht.

Produktrolle:

- Einstiegspunkt in die eigene Welt.
- Ruhiger Lern-/Bau-Ort statt komplexe Karte.
- Bruecke zwischen Home-Globe und spaeterem Stadt-/Region-Ausbau.
- Erster lokaler Wow-Moment nach Phase 1.

### Warum diese Region geeignet ist

- Sie passt zur Foundation-Build-Regel: lokal zuerst, Cloud spaeter.
- Sie erlaubt einen kleinen, glaubwuerdigen Slice ohne Social-Backend.
- Sie kann mit Flutter-Widgets/CustomPainter starten.
- Sie laesst spaeter Wege zu Nachbarplots, Freunden, Showcase oder Regionen offen.

### Datenstatus

Die Startregion ist in Phase 2 rein lokal/mock:

- keine Supabase-Abhaengigkeit,
- keine Cloud-Region,
- keine echte Besitzlogik,
- keine Datenbankmigration,
- keine reale Ressourcen-Persistenz.

## 3. Globe-Tap-Verhalten

### Aktuelles Verhalten

Nach Phase 1 ist der Globe das zentrale Home-Hero-Objekt und bleibt das Welt-Tap-Ziel.

### Phase-2-Verhalten

Beim Tippen auf den Globe:

1. Home prueft keine Cloud-Welt.
2. Home navigiert in den lokalen Welt-Screen.
3. Der Screen zeigt den Ursprungshain mit Plot, Gebaeuden und Mock-Ressourcen.
4. Ruecknavigation fuehrt zur Home-Zentrale zurueck.

### Spaetere Uebergangslogik

Langfristig soll der Uebergang hochwertig wirken:

- Globe bleibt sichtbarer Ausgangspunkt.
- Kamera/Ansicht zoomt vom Globe in die lokale Region.
- Der Effekt darf spaeter an Google-Earth-artige Zoom-Logik erinnern.
- Der Uebergang soll premium wirken, aber nicht vor Phase 2 erzwungen werden.

### Akzeptable erste Slice-Loesung

Fuer Phase 2 ist ausreichend:

- einfacher Fade- oder Scale-Uebergang,
- optional kurzer dunkler Zwischenzustand mit Regionstitel,
- kein echter 3D-Kamera-Zoom,
- keine Aenderung am Globe-Renderer,
- keine neue Globe-Shader-/Texturarbeit.

Wichtig:

Der Uebergang darf die stabile Home-Globe-Logik aus Phase 1 nicht gefaehrden.

## 4. Lokaler Welt-Screen

### Pflichtbestandteile

Der erste lokale Welt-Screen soll enthalten:

- Screen-Titel oder dezenter Regionstitel: `Talvori Ursprungshain`.
- Ruecknavigation zur Home-Zentrale.
- Eine zentrale Plot-Flaeche.
- Drei sichtbare Gebaeude:
  - Haus,
  - Markt,
  - Bibliothek.
- Eine kleine Ressourcenleiste mit Mock-Werten.
- Dezenter Talvori-Welt-Stil:
  - dunkler Neon-/Space-Bezug,
  - aber weniger Home-Galaxy-Dominanz,
  - klare Lesbarkeit.

### Platzhalterbestandteile

Folgende Elemente duerfen in Phase 2 Platzhalter sein:

- Ressourcenwerte,
- Gebaeude-Level,
- Baufortschritt,
- Nachbarplots,
- kleine Umgebungsdetails wie Wege, Baumgruppe oder Teich,
- Hinweise wie `kommt spaeter`.

### Grober Aufbau

Empfohlene Struktur:

1. Obere Leiste:
   - Zurueck,
   - Regionstitel,
   - kompakte Ressourcenanzeige.
2. Hauptbereich:
   - Plot-Flaeche mit drei Gebaeuden.
   - Haus eher links/vorne.
   - Markt eher mittig/rechts.
   - Bibliothek eher hinten/oben.
3. Unterer Bereich:
   - kurzer Statushinweis, z. B. `Dein erster Plot wartet auf Lernenergie.`
   - optional ein deaktivierter oder mock `Weiterbauen`-Button.

Nicht als Phase-2-Ziel:

- kein komplexes Stadtlayout,
- keine Karte mit vielen Regionen,
- keine echte Drag-/Build-Interaktion,
- keine Oekonomie-UI.

## 5. Eigener Plot

### Bedeutung in Phase 2

Der eigene Plot ist der erste sichtbare Besitz-/Bau-Ort des Nutzers.

In Phase 2 bedeutet das:

- ein lokales/mock Objekt,
- ein visuelles Feld im lokalen Welt-Screen,
- drei Startgebaeude,
- keine echte Besitzpruefung,
- keine Cloud-Speicherung.

### Mindestdaten

Ein spaeteres Mock-Modell koennte enthalten:

- `plotId`
- `regionId`
- `displayName`
- `buildings`
- `resources`
- `lastVisitedAt` als optionaler UI-Wert

Fuer Phase 2 duerfen diese Werte hart lokal oder ueber einen In-Memory-/Mock-State bereitgestellt werden.

### Spaetere Erweiterung

Offen fuer spaeter:

- echte lokale Persistenz,
- Cloud-Synchronisierung,
- mehrere Plots,
- Nachbarplots,
- Showcase/Friends,
- Bau-Level,
- Ressourcenverbrauch,
- Reward Bridge.

## 6. Initiale Gebaeude

Phase 2 plant exakt drei Gebaeude.

| Gebaeude | Zweck im Lern-/Spielkonzept | Phase-2-Funktion | Spaetere moegliche Funktion | Klickbar in Phase 2? |
| --- | --- | --- | --- | --- |
| Haus | Identitaet, eigener Ort, Startpunkt der Welt | Sichtbares Startgebaeude auf dem Plot; zeigt `Level 1` oder `Start`. | Profil-/Companion-Zuhause, Comeback-Ort, persoenliche Sammlung. | Optional klickbar; wenn klickbar, nur kleine Info-Card. |
| Markt | Woerter als Rohmaterial, Austausch, Sammeln | Sichtbares Gebaeude fuer Import-/Wortmaterial-Kontext. | Wortimport, DeepL-/Uebersetzungsauftraege, Rohstofftausch, Tagesangebote. | Optional klickbar; wenn klickbar, nur Info-Card. |
| Bibliothek | Lernen, Wissen, Saetze, Satzfunken | Sichtbares Gebaeude fuer Lernen/Satzfunken-Kontext. | Lernrunden, Satzfunken, Review, Wissenspunkte, kleine Quests. | Optional klickbar; wenn klickbar, nur Info-Card. |

Regel:

In Phase 2 darf kein Gebaeude echte Ressourcen verbrauchen oder SRS/`word_progress` veraendern.

## 7. Lokale/mock Ressourcen

Phase 2 darf erste Ressourcen zeigen, aber nur als Mock-/UI-Zustand.

Vorgeschlagene Ressourcen:

- `coins`
- `wood`
- `stone`
- `knowledgePoints`

Optional spaeter pruefbar:

- `light`
- `glass`
- `residents`

### Bedeutung im Phase-2-Slice

| Ressource | Phase-2-Bedeutung | Spaetere Bedeutung |
| --- | --- | --- |
| `coins` | allgemeiner Platzhalter fuer Weltwert | Belohnung, Marktaktionen, kleinere Freischaltungen |
| `wood` | Baumaterial fuer einfache Gebaeude | Typing-/Praxisbelohnungen |
| `stone` | stabiles Baumaterial | Bedeutungs-/Review-Belohnungen |
| `knowledgePoints` | Lernenergie/Wissen ohne Oekonomieversprechen | Satzfunken, Bibliothek, Review-Fortschritt |

Nicht erlaubt in Phase 2:

- keine echte Persistenz,
- keine SRS-Anbindung,
- keine Reward-Berechnung,
- keine Ressourcen-Ausgaben,
- keine Balancing-Regeln.

## 8. Architektur-Vorbereitung

Folgende Dateien/Ordner koennten spaeter vorbereitet werden. In diesem Planungsblock werden sie noch nicht angelegt.

Moegliche Struktur:

- `lib/features/world/local_world/`
- `lib/features/world/local_world/ui/screens/local_world_screen.dart`
- `lib/features/world/local_world/ui/widgets/local_world_plot_view.dart`
- `lib/features/world/local_world/ui/widgets/local_world_building_tile.dart`
- `lib/features/world/local_world/ui/widgets/local_world_resource_bar.dart`
- `lib/features/world/local_world/domain/local_world_region.dart`
- `lib/features/world/local_world/domain/local_world_plot.dart`
- `lib/features/world/local_world/domain/local_world_building.dart`
- `lib/features/world/local_world/domain/local_world_resource_wallet.dart`
- `lib/features/world/local_world/application/local_world_mock_controller.dart`

Alternative, falls das bestehende `features/world` bereits genug Struktur bietet:

- Screen direkt unter `lib/features/world/ui/screens/`
- Widgets unter `lib/features/world/ui/widgets/`
- Mock-State vorerst im Screen oder in kleinem Controller

Empfohlene Regel:

- UI liest Mock-World-State.
- Mock-World-State entscheidet keine Rewards.
- Keine direkte Kopplung an Lernengine, SRS oder `word_progress`.
- Keine Supabase-RPCs oder Edge Functions.
- Spaetere Reward Bridge bleibt ein eigenes Modul.

## 9. Akzeptanzkriterien fuer Phase 2

Phase 2 gilt als abgeschlossen, wenn:

- Globe-Tap fuehrt in einen lokalen Welt-Screen.
- Der lokale Welt-Screen zeigt die Startregion `Talvori Ursprungshain`.
- Ein eigener Plot ist klar sichtbar.
- Exakt drei Gebaeude sind sichtbar:
  - Haus,
  - Markt,
  - Bibliothek.
- Eine lokale/mock Ressourcenleiste ist sichtbar.
- Ruecknavigation zur Home-Zentrale funktioniert.
- Keine Supabase Writes passieren.
- Keine SQLite-/SRS-/`word_progress`-Daten werden veraendert.
- Keine Reward Bridge als Vollsystem eingebaut wurde.
- Keine echte Ressourcen-Persistenz eingefuehrt wurde.
- Der Screen fuehlt sich wie ein kleiner Talvori-Welt-Einstieg an, nicht wie ein normales Dashboard.
- Phase-1-Home-Stabilitaet bleibt erhalten:
  - Globe bleibt stabil,
  - Companion-Chat blockiert Home-Taps weiterhin korrekt,
  - Keyboard-/Input-Verhalten wird nicht verschlechtert.

## 10. Test- und Pruefplan fuer die spaetere Umsetzung

Nach einer spaeteren Implementierung sollten mindestens folgende Checks laufen:

- `flutter analyze` oder `dart analyze` fuer relevante Dateien.
- Widget-Test fuer Globe-Tap:
  - Home rendern,
  - Globe antippen,
  - lokaler Welt-Screen erscheint.
- Widget-Test fuer Ruecknavigation:
  - lokaler Welt-Screen zurueck zur Home-Zentrale.
- Widget-Test fuer lokale Welt:
  - Regionstitel sichtbar,
  - Plot sichtbar,
  - Haus, Markt, Bibliothek sichtbar,
  - Ressourcenleiste sichtbar.
- Regressionstest fuer Companion-Chat:
  - wenn Chat aktiv ist, schliesst ein Globe-Tap zuerst den Chat und navigiert nicht sofort.
- Geraetetest:
  - Globe-Tap,
  - Uebergang,
  - Ruecknavigation,
  - Home-Companion/Keyboard-Konflikte,
  - Lesbarkeit auf kleinerem Screen.
- Sicherheitspruefung:
  - keine Supabase Writes,
  - keine SQLite-Vokabeldaten geaendert,
  - keine SRS-/`word_progress`-Nebenwirkungen,
  - keine Secrets,
  - keine Release-Artefakte.

## 11. Explizit ausserhalb von Phase 2

Nicht Teil von Phase 2:

- keine Supabase Writes,
- keine Cloud-Welt,
- keine Social-Funktionen,
- keine Reward Bridge als Vollsystem,
- keine SRS-/`word_progress`-Migration,
- keine echte Ressourcen-Persistenz,
- kein Gebaeude-Ausbau-System,
- keine Oekonomie,
- keine Multiplayer-/Freunde-Funktionen,
- keine Paywall-/Entitlement-Logik,
- keine DeepL-/Import-/KI-Quest-Anbindung,
- keine echte Lernbelohnung,
- kein globaler Chat,
- kein Google-Earth-artiger 3D-Uebergang als Muss.

## 12. Empfohlener erster Implementierungsblock nach diesem Plan

Naechster sinnvoller Codeblock:

**Lokaler Welt-Screen als kleiner Mock-Slice**

Umfang:

- `LocalWorldScreen` planen/erstellen.
- Globe-Tap auf diesen Screen routen.
- `Talvori Ursprungshain` anzeigen.
- Plot mit Haus, Markt, Bibliothek anzeigen.
- Mock-Ressourcenleiste anzeigen.
- Ruecknavigation pruefen.

Nicht in diesem ersten Codeblock:

- keine Reward Bridge,
- keine Persistenz,
- keine Cloud,
- keine SRS-/`word_progress`-Aenderung,
- keine grosse Uebergangsanimation.
