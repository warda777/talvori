# Talvori Welt: Visual Direction Review fuer Phase 2A

Stand: 2026-06-02

Dieses Dokument bewertet den aktuellen lokalen Welt-Slice aus visueller Sicht und legt die naechste Zielrichtung fuer den Phase-2A-Umbau fest.

Es ist ein reines Planungs- und Richtungsdokument. Es wurden keine Dart-/Flutter-Dateien, keine Supabase-Daten, keine SQLite-/Vokabeldaten, keine SRS-Daten, kein `word_progress`, keine Reward Bridge, keine Secrets und keine Release-Artefakte geaendert.

## 1. Aktueller Stand

Der technische Einstieg in Phase 2 funktioniert:

- Der Globe-Tap fuehrt in einen lokalen Welt-Screen.
- Der Screen zeigt die Startregion `Talvori Ursprungshain`.
- Ruecknavigation zur Home-Zentrale ist vorgesehen.
- Ein eigener Plot ist sichtbar.
- Die drei Startgebaeude Haus, Markt und Bibliothek sind vorhanden.
- Die Mock-Ressourcen `coins`, `wood`, `stone` und `knowledgePoints` sind sichtbar.

Damit erfuellt der aktuelle Screen den funktionalen Mock-Slice.

Visuell ist der Stand aber noch nicht stark genug:

- Die Struktur wirkt zu listenartig.
- Gebaeude erscheinen eher wie UI-Karten als wie Weltobjekte.
- Der Screen fuehlt sich noch nicht wie eine betretbare Welt an.
- Die Flaeche hat zu wenig Landschaft, Tiefe, Wege und Aufenthaltsqualitaet.
- Der erste Welt-Eindruck ist noch nicht auf dem Premium-Niveau der Home-Zentrale.

Bewertung:

Der aktuelle Slice ist als technische Grundlage gut, aber nicht als finale visuelle Richtung fuer Talvori Welt.

## 2. Neue Zielrichtung

Bevorzugte Richtung:

> Cozy Learning World als schwebendes Diorama

Die lokale Welt soll nicht als Dashboard und nicht als Gebaeudeliste erscheinen. Sie soll wie ein kleiner, betretbarer Ort wirken.

Zielbild:

- eine schwebende Insel, Lichtung oder kompakte Landschaft,
- Haus, Markt und Bibliothek als echte Weltobjekte,
- freie Bauplaetze sichtbar in der Landschaft,
- Wege zwischen Gebaeuden und Bauplaetzen,
- Naturdetails wie Baeume, Felsen, Gras, Wasser, Laternen oder kleine magische Kristalle,
- warme Lichtpunkte und dezente Talvori-Neon-Akzente,
- dunkler, hochwertiger Space-/Himmelsraum im Hintergrund,
- klare Premium-Anmutung statt Standard-App-Karten.

Wichtig:

Die Welt darf stilisiert und mit Flutter-Widgets/CustomPainter gebaut sein. Sie muss nicht fotorealistisch sein. Entscheidend ist, dass sie als Ort gelesen wird.

## 3. Referenzbild-Regel

Das bereitgestellte Referenzbild dient als Qualitaets- und Stilrichtung.

Regeln:

- Das Bild darf nicht exakt kopiert werden.
- Es darf nicht als Asset uebernommen werden.
- Keine externen Bilddateien als Hintergrund verwenden.
- Die Zielqualitaet und Grundwirkung sollen aber in dieselbe hochwertige Richtung gehen.
- Das Ergebnis soll moderner, immersiver und weltartiger wirken als der aktuelle Listen-Slice.
- Die Talvori-Farbwelt bleibt eigenstaendig: dunkel, cyan/lila, magisch, ruhig, premium.

Leitfrage fuer Phase 2A:

> Fuehlt sich der Screen nach Globe-Tap wie ein kleiner Talvori-Ort an, oder nur wie eine Liste mit Gebaeuden?

Wenn er wie eine Liste wirkt, ist Phase 2A visuell noch nicht fertig.

## 4. Interaktionsanforderungen

Die Welt muss von Anfang an so gedacht werden, dass sie spaeter wachsen kann.

Fuer Phase 2A soll die Architektur vorbereiten:

- Zoom der Weltansicht,
- Pan/Drag in alle Richtungen,
- Erweiterung um weitere Landschaftsbereiche,
- Verbindung von Grundstuecken ueber Bruecken, Wege oder magische Uebergaenge,
- spaetere Regionserweiterung ohne kompletten UI-Neubau.

Phase 2A muss diese Interaktionen nicht vollstaendig als fertiges System liefern, aber der Aufbau darf sie nicht verhindern.

Konsequenz fuer das Layout:

- Die Hauptwelt sollte als skalierbare Flaeche gedacht werden.
- Weltobjekte sollten positionsbasiert platziert werden koennen.
- Gebaeude und freie Plots sollten eigene Objekte/Widgets sein.
- Eine reine vertikale Column-Struktur ist fuer die Weltflaeche nicht ausreichend.

## 5. Orientation-Strategie: Portrait und Landscape

### Grundentscheidung

Talvori bleibt grundsaetzlich eine mobile App. Deshalb muss Portrait weiterhin gut funktionieren.

Die Weltansicht darf aber nicht nur fuer Hochformat gedacht werden. Sie soll zusaetzlich Landscape unterstuetzen oder mindestens architektonisch darauf vorbereitet sein.

Landscape eignet sich besonders fuer den Explore-/Weltmodus, weil mehr horizontale Flaeche sichtbar ist und sich eine groessere Welt natuerlicher erkunden laesst.

### Warum Landscape wichtig ist

- Die Welt darf nicht in ein schmales Hochformat gequetscht werden.
- Nutzer sollen Landschaft, freie Grundstuecke, Bruecken und Nachbarbereiche grosszuegig sehen koennen.
- Pan/Drag in alle Richtungen fuehlt sich im Querformat natuerlicher an.
- Spaetere Freundes- und Fremd-Plots lassen sich im Landscape-Modus besser erkunden.
- Eine groessere Talvori-Welt braucht Raum, damit sie nicht wie eine kleine App-Kachel wirkt.

### Layout-Regel

Die Weltflaeche muss responsiv sein.

Regeln:

- Portrait darf keine verkleinerte, unlesbare Version der ganzen Welt sein.
- Portrait soll einen fokussierten Ausschnitt zeigen.
- Landscape darf eine breitere Explore-Ansicht zeigen.
- UI-Overlays wie Ressourcen, Zurueck, `Zu meinem Plot` und Freunde duerfen die Welt nicht verdecken.
- Die Insel/Landschaft soll in keiner Ausrichtung billig verkleinert oder gequetscht wirken.

Konsequenz:

Die Weltansicht sollte als groessere, positionsbasierte Flaeche gedacht werden, nicht als fixe iPhone-Portrait-Komposition.

### Spaetere Schnellnavigation

Wenn die Welt gross wird, braucht der Nutzer jederzeit eine Aktion:

- `Zu meinem Grundstueck`,
- schneller Sprung zu Freunden,
- Freund antippen und direkt dessen Grundstueck oeffnen,
- optional spaeter Weltuebersicht oder Regionsuebersicht.

Diese Navigation sollte als Overlay-Control-Layer ueber der Welt liegen, nicht tief in einzelnen Plot-Widgets.

### Phase-2A-Konsequenz

Der naechste Umbau muss die Weltflaeche so bauen, dass sie spaeter sowohl Portrait als auch Landscape tragen kann.

Nicht gewuenscht:

- kein fixes Layout, das nur auf eine iPhone-Portrait-Hoehe optimiert ist,
- keine kleine gequetschte Insel,
- keine UI-Overlays, die im Landscape-Modus die Weltmitte verdecken,
- keine Struktur, die Zoom/Pan spaeter blockiert.

Gewuenscht:

- Portrait zeigt einen starken, fokussierten Ausschnitt.
- Landscape ist als grosszuegiger Explore-Modus vorbereitet.
- Die Insel/Landschaft wirkt gross und wertig.

## 6. Plot- und Weltlogik

Folgende Plot-Typen muessen in der visuellen und architektonischen Planung mitgedacht werden:

| Plot-Typ | Bedeutung | Phase-2A-Rolle | Spaetere Rolle |
| --- | --- | --- | --- |
| Eigener Plot | Das persoenliche Grundstueck des Nutzers | Zentral sichtbar; enthaelt Haus, Markt, Bibliothek | Ausbau, Ressourcen, Lernfortschritt, persoenliche Identitaet |
| Freier Plot | Noch nicht belegter Bauplatz | Sichtbar als leere Flaeche mit Plus/Marker | Spaeter kaufen, freischalten, bauen oder verbinden |
| Fremd-Plot | Plot eines anderen Nutzers ohne Freundesbezug | Nur logisch vorbereiten, nicht zwingend anzeigen | Showcase, Region, Besucheransicht |
| Freundes-Plot | Plot eines Freundes | Optional als Platzhalter/angedockter Nachbar vorbereiten | Direktbesuch, Reaktionen, Freundes-Social-Minimum |

Phase 2A sollte mindestens eigene und freie Plots sichtbar machen.

Fremd- und Freundes-Plots duerfen zunaechst nur architektonisch vorbereitet oder als spaetere Andockpunkte markiert werden.

## 7. Schnellnavigation

Wenn die Welt spaeter groesser wird, braucht sie klare Schnellaktionen.

Geplante Schnellnavigation:

- direkt zurueck zu meinem Grundstueck,
- direkt zu Freunden springen,
- Freund antippen und direkt sein Grundstueck oeffnen,
- optional spaeter Weltuebersicht oder Regionsuebersicht.

Fuer Phase 2A reicht:

- ein sichtbarer oder spaeter leicht ergaenzbarer Platz fuer Welt-/Freunde-/Settings-Aktionen,
- Ruecknavigation zur Home-Zentrale,
- keine echte Freundesnavigation und kein Social-Backend.

Architekturhinweis:

Die Schnellnavigation sollte nicht tief in die Plot-Widgets eingebettet werden. Sie gehoert als eigener Overlay-/Control-Layer ueber die Weltansicht.

## 8. Phase-2A-Ziel

Der naechste visuelle Umbau soll:

- die vertikale Listenstruktur entfernen,
- einen zentralen Landschafts-/Insel-Screen schaffen,
- Haus, Markt und Bibliothek als Weltobjekte zeigen,
- zusaetzliche freie Grundstuecke sichtbar machen,
- Ressourcen nur dezent anzeigen,
- den Ursprungshain als Ort und nicht als Dashboard inszenieren,
- optional kleine Taps oder Info-Cards fuer Gebaeude und Grundstuecke erlauben.

Empfohlene visuelle Struktur:

1. Oberer Layer:
   - Ruecknavigation,
   - Regionstitel,
   - dezente Ressourcenchips.

2. Welt-Layer:
   - schwebende Insel/Lichtung als Hauptobjekt,
   - Haus, Markt, Bibliothek als platzierte Objekte,
   - freie Bauplaetze mit Plus-/Glanzmarkern,
   - Wege, Naturdetails, Lichtpunkte.

3. Overlay-Layer:
   - kurzer Statushinweis,
   - spaetere Schnellnavigation zu Welt/Freunden/Settings,
   - optionale Info-Cards nach Tap.

## 9. Scope-Grenzen

Weiterhin ausgeschlossen:

- keine echte 3D-Engine,
- kein Muss fuer echten Google-Earth-Zoom,
- keine Reward Bridge,
- keine echte Ressourcen-Persistenz,
- keine Cloud-Welt,
- keine Social-Backend-Logik,
- keine Supabase Writes,
- keine SQLite-/SRS-/`word_progress`-Aenderungen,
- keine Oekonomie,
- kein Gebaeude-Ausbau-System als Vollsystem,
- keine Multiplayer-/Freunde-Funktionen,
- keine externen Bildassets aus dem Referenzbild.

Phase 2A bleibt ein lokaler visueller Slice.

## 10. Akzeptanzkriterien

Phase 2A gilt visuell als gelungen, wenn:

- Beim Globe-Tap wirkt der Screen wie eine echte kleine Welt.
- Die Ansicht ist fuer Zoom und Pan logisch vorbereitet.
- Freie Grundstuecke sind sichtbar.
- Haus, Markt und Bibliothek sind als Weltobjekte erkennbar.
- Mein Plot, freie Plots und spaetere Freundes-/Fremd-Plots sind logisch vorbereitet.
- Eine spaetere Schnellnavigation zu mir und zu Freunden ist architektonisch mitgedacht.
- Ressourcen bleiben dezent und dominieren die Welt nicht.
- Der Screen hat keine Listen-/Dashboard-Anmutung.
- Der Stil bleibt Talvori: dunkel, magisch, cyan/lila, hochwertig, ruhig.
- Portrait zeigt einen fokussierten, gut lesbaren Welt-Ausschnitt.
- Landscape ist als grosszuegiger Explore-Modus vorgesehen.
- Die Welt wirkt in keiner Ausrichtung gequetscht oder billig verkleinert.
- Zoom/Pan und spaetere Schnellnavigation zu eigenem Plot/Freunden bleiben architektonisch moeglich.

## 11. Naechster sinnvoller Block

Der naechste Implementierungsblock sollte lauten:

> Phase 2A: LocalWorldScreen von Listen-Slice zu schwebendem Diorama umbauen.

Fokus:

- bestehende Funktionalitaet behalten,
- vertikale Kartenstruktur entfernen,
- Weltflaeche als schwebende Insel/Lichtung aufbauen,
- Haus, Markt, Bibliothek positionsbasiert platzieren,
- freie Bauplaetze ergaenzen,
- Ressourcen und Navigation als dezente Overlays fuehren,
- keine Reward-/Cloud-/Persistenzlogik bauen.
