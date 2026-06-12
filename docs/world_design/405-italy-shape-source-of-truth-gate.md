# Italien-Kontur Source-of-Truth Gate

Stand: 2026-06-12

Status: `docs_only_slice`, `source_of_truth_gate`, `no_code`, `no_assets`,
`not_runtime_data`, `no_geometry_values`

## 1. Zweck des Gates

Dieses Gate legt fest, welche Quelle fuer die echte Italien-Kontur spaeter als
Source of Truth verwendet werden darf und welche Vereinfachungsregeln fuer den
Italien-Prototyp gelten.

Fuehrende Entscheidung:

- Italien wird als echte Aussenkontur fuer den ersten neuen World-Prototyp
  verwendet.
- Dieses Gate entscheidet noch keine finale Grafik.
- Dieses Gate entscheidet noch keine Runtime-Geometrie.
- Dieses Gate erzeugt keine Konturdatei, keine SVG/PNG, keine Bilder, keine
  Assets, keine Koordinaten und keinen Code.
- Dieses Gate legt nur Quelle, Lizenz-/Attributionsgrenzen,
  Auswahlregeln, Vereinfachungsregeln und Stop-Regeln fest.

Der Folgepfad bleibt:

```text
Quelle festlegen -> Erkennungsmerkmale/Abstraktion -> Makro-Layout ->
Bauflaechen/Wege -> technische Layer/Masks -> Greybox -> Game-Look ->
Slot-Interaktion
```

## 2. Source-of-Truth-Kandidaten

### 2.1 Natural Earth

Bewertung:

- Geeigneter Kandidat fuer Laendergrenzen als offene Vektorquelle.
- Natural Earth bietet freie Vektor- und Rasterdaten in 1:10m, 1:50m und
  1:110m Massstaeben.
- Die offiziellen Terms of Use beschreiben Natural-Earth-Raster- und
  Vektordaten der Website als Public Domain.
- Natural Earth erlaubt Nutzung, Veraenderung und Design-Anpassung; Credit ist
  laut Terms nicht noetig, aber eine Quellenangabe wie "Made with Natural
  Earth" ist als freiwillige Dokumentationsangabe sinnvoll.
- Fuer den naechsten Slice ist besonders `Admin 0 - Countries` relevant,
  weil es eine Laendergrenzen-Datei mit Versionierung anbietet.

Risiko / Pruefung vor Verwendung:

- Vor einem Download oder Repo-Import muss der konkrete Datensatz, die Version
  und der Downloadpfad dokumentiert werden.
- Fuer Italien muss geprueft werden, ob Festland, Sizilien und Sardinien in
  der gewaehlten Geometrie fuer mobile Erkennbarkeit ausreichend enthalten
  sind.
- Politische/de-facto-Grenzlogik ist fuer Talvori nur Quelle der Aussenform,
  nicht Spielinhalt.

Entscheidung:

- Natural Earth ist die empfohlene Source-of-Truth fuer den naechsten Slice.

### 2.2 OpenStreetMap-basierte Grenzen

Bewertung:

- OpenStreetMap ist eine starke offene Geodatenquelle.
- OSM-Daten stehen unter der Open Data Commons Open Database License (ODbL).
- OSM verlangt Attribution und macht bei abgeleiteten Daten Share-Alike- und
  Lizenzpflichten relevant.

Risiko / Pruefung vor Verwendung:

- OSM ist nur Kandidat, wenn Lizenz-, Attribution- und Share-Alike-Folgen fuer
  Talvori vorher separat geprueft werden.
- OSM eignet sich eher, wenn spaeter detailliertere Geodaten gebraucht werden;
  fuer eine spielgerecht vereinfachte Italien-Aussenkontur ist das in diesem
  Stadium wahrscheinlich mehr Lizenz- und Datenkomplexitaet als Nutzen.
- Keine OSM-Kartenkacheln oder Screenshots duerfen kopiert oder
  nachgezeichnet werden.

Entscheidung:

- OSM bleibt ein Kandidat mit Lizenz-/Attributionspruefung, aber nicht die
  bevorzugte erste Source-of-Truth.

### 2.3 Andere offene Vektorquellen

Andere Quellen sind nur zulaessig, wenn vor Verwendung klar dokumentiert ist:

- exakte Quelle,
- Datensatzname,
- Version oder Abrufstand,
- Lizenz,
- Attributionspflicht,
- kommerzielle Nutzbarkeit,
- Bearbeitungsrecht,
- Weitergaberecht,
- Eignung fuer vereinfachte Spielkontur.

Nicht zulaessig:

- fremde Bilder,
- Screenshots,
- Kartenkacheln,
- Google Maps,
- Apple Maps,
- Pinterest,
- Luftbilder,
- Atlasbilder,
- nachgezeichnete Karten aus Suchergebnissen.

## 3. Empfohlene Source-of-Truth

Empfohlen fuer den naechsten Slice:

```text
Natural Earth Admin 0 - Countries
```

Begruendung:

- vektorbasiert,
- offen verfuegbar,
- fuer Laendergrenzen passend,
- Public-Domain-Status laut Natural-Earth-Terms,
- deutlich geringeres Lizenzrisiko als OSM fuer diesen fruehen Prototyp,
- geeignet als Ausgangspunkt fuer eine spielgerechte vereinfachte
  Italien-Aussenkontur.

Dokumentationsnotiz:

- Empfohlene Attribution in Talvori-Docs, falls Natural Earth spaeter wirklich
  genutzt wird: `Made with Natural Earth`.
- Auch wenn Natural Earth keinen Credit verlangt, soll die Quelle im Repo
  nachvollziehbar bleiben.

Vor Verwendung im naechsten Slice noch zu pruefen:

- konkrete Natural-Earth-Version,
- konkreter Downloadpfad,
- ob 10m, 50m oder 110m fuer mobile Spielkontur am besten geeignet ist,
- ob die Geometrie Festland, Sizilien und Sardinien ausreichend getrennt oder
  gruppierbar enthaelt,
- welche Vereinfachungsstufe noetig ist, damit die Stiefel-Form lesbar bleibt
  und nicht wie GIS-Detail wirkt.

In diesem Slice wird keine Datei heruntergeladen, keine Datei erzeugt und
keine externe Kopie ins Repo gelegt.

## 4. Italien-Bestandteile fuer den ersten Prototyp

Planungsregel:

| Bestandteil | Vorlaeufige Entscheidung | Grund |
| --- | --- | --- |
| Festland Italien | grundsaetzlich enthalten | Traegt die erkennbare Stiefel-Form und ist der Hauptkoerper des Prototyps. |
| Sizilien | pruefen und voraussichtlich enthalten | Stark wiedererkennbar und wichtig fuer die Lesbarkeit von Italien als Form. |
| Sardinien | pruefen und voraussichtlich enthalten | Markant, aber gameplaygerecht positionierbar/skalierbar, damit Mobile-Lesbarkeit nicht leidet. |
| Kleine Nebeninseln | nur bei Gameplay-Relevanz | Sonst weglassen oder stark abstrahieren, um Clutter und falsche Detailpflicht zu vermeiden. |

Noch nicht entschieden:

- finale Positionierung,
- finale Skalierung,
- finale Abstaende zwischen Festland, Sizilien und Sardinien,
- welche Nebeninseln eventuell spaeter spielrelevant werden,
- ob Inseln als eigene Spielraeume oder nur als Form-/Reserveelemente wirken.

Diese Entscheidungen gehoeren in spaetere Abstraktions-, Layout- und
Greybox-Gates.

## 5. Vereinfachungsregeln

Die echte Italien-Kontur darf spaeter nur so vereinfacht werden, dass
Spielbarkeit, mobile Lesbarkeit und Talvori-2.5D-Diorama-Gefuehl besser
werden.

Erlaubt:

- Stiefel-Form klar erhalten.
- Kuestenlinie fuer Mobile vereinfachen.
- Kleine Buchten, Mikrozacken und nicht spielrelevante Details reduzieren.
- Festland, Sizilien und Sardinien klar lesbar halten.
- Sizilien und Sardinien gameplaygerecht positionieren und skalieren, ohne
  Atlasgenauigkeit zu erzwingen.
- Aussenform in eine freundlichere, baufaehigere 2.5D-Form uebersetzen.
- Bau- und Wege-Lesbarkeit hoeher priorisieren als geografisches Detail.

Nicht erlaubt:

- politische Detailkarte,
- 1:1-Geografie als Spielziel,
- Pixeltracing aus Bildern,
- Atlas-, GIS- oder Unterrichtskarten-Look,
- Detailtreue, die Bauflaechen, Wege, Kamera oder Touch-Lesbarkeit blockiert,
- so starke Vereinfachung, dass Italien nicht mehr erkennbar ist.

Jede Vereinfachung muss spaeter begruenden:

- Was wurde vereinfacht?
- Warum hilft es Mobile-Lesbarkeit?
- Warum hilft es Spielbarkeit?
- Bleibt die Form als Italien erkennbar?
- Bleibt die Form fuer 2.5D-Diorama und Build/Map geeignet?

## 6. Grenze zwischen echter Form und Gameplay-Abstraktion

Fuehrende Trennung:

- Die Aussenform kommt aus echter Quelle.
- Die Innenstruktur bleibt gameplaygerecht.

Nicht aus echter Geografie kopieren:

- Wege,
- Bauflaechen,
- Waelder,
- Berge,
- Wasserfuehrung im Inneren,
- Landmarken,
- No-Walk,
- No-Build,
- Sort-Bands,
- Build-Station-Positionen.

Reale Merkmale duerfen inspirieren:

- Alpen-/Gebirgslesart im Norden,
- Apennin-/Hoehenlogik als grobe Strukturidee,
- Kueste und Meeresnaehe,
- Sizilien und Sardinien als markante Inselraeume,
- Nord-/Mitte-/Sued-Gefuehl.

Aber:

- Talvori ist kein Unterrichtsatlas.
- Keine politische oder schulische Karte.
- Keine Quiz-/Worksheet-Lesart.
- Keine Pflicht, reale Staedte, Regionen oder Infrastruktur nachzubauen.
- Gameplay, Weltgefuehl, Bauprogression und mobile Lesbarkeit fuehren.

## 7. Technische Folgeplanung

Der spaetere Folge-Slice darf vorbereiten:

- eine vereinfachte Dokumentationskontur,
- eine reine Review-/Greybox-Kontur,
- eine Shape-Entscheidung fuer Festland, Sizilien und Sardinien,
- eine Dokumentation der Vereinfachungsschritte,
- eine weitere Quellen-/Lizenznotiz, falls die konkrete Natural-Earth-Datei
  verwendet wird.

Weiterhin blockiert:

- Runtime-Daten,
- App-Integration,
- finale Koordinaten,
- produktive Polygone,
- YAML-/JSON-/YML-Dateien,
- Dateien unter `assets/`,
- finale Kunst,
- Engine-ready- oder Asset-Status.

Moegliche spaetere Layer-Namen, nur als Planung:

- `italy_country_shape_source`
- `italy_shape_simplified`
- `italy_mainland_shape`
- `italy_sicily_shape`
- `italy_sardinia_shape`
- `italy_coast_buffer_planning`

Diese Namen sind keine Dateien, keine Runtime-Struktur und keine
Implementierungsfreigabe.

## 8. Stop-Regeln

Ein Folge-Slice ist nicht commitfaehig, wenn:

- Quelle oder Lizenz unklar ist,
- fremde Kartenbilder kopiert oder nachgezeichnet werden,
- Google Maps, Apple Maps, Pinterest, Screenshots, Atlasbilder oder
  Kartenkacheln als Konturgrundlage verwendet werden,
- die Form nicht mehr als Italien erkennbar ist,
- die Karte wie Unterrichtsatlas oder technisches GIS-Tool wirkt,
- die Kontur als finale Kunst behandelt wird,
- Runtime-Koordinaten entstehen,
- Polygone als produktive Daten entstehen,
- YAML/JSON/YML-Dateien ohne eigenes Gate entstehen,
- App-Code oder Flutter-Dateien entstehen,
- Assets unter `assets/` entstehen,
- eine finale Kunstproduktion vor Source-of-Truth, Greybox/Blockout und
  Playability-Pruefung gestartet wird,
- Wege, Bauflaechen, No-Walk oder No-Build aus realer Geografie oder Pixeln
  abgeleitet werden.

## 9. Naechster empfohlener Slice

Naechster Slice:

```text
Italien-Erkennungsmerkmale und Gameplay-Abstraktion
```

Dieser Slice soll definieren, welche Merkmale Italien fuer Talvori erkennbar
machen muessen und welche geografischen Details zugunsten von Spielbarkeit,
Kamera, Bauflaechen, Wegen, 2.5D-Diorama und Touch-Lesbarkeit abstrahiert
werden duerfen.
