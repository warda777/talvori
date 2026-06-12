# 408: Italy City Anchor Plan

Stand: 2026-06-12

Status: `docs_only / city_anchor_plan / not_asset / not_runtime_data / not_engine_ready / no_coordinates`

## 1. Zweck

Der sichtbare Makro-Blockout aus `407` ist als erster Spielraum-Blockout
nuetzlich, aber noch zu abstrakt. Vor einer Ueberarbeitung braucht der
Italien-Prototyp echte italienische Stadtanker, damit Wege, Wasser, Regionen,
Bauflaechen und spaetere Landmarken nicht frei im Raum erfunden wirken.

Dieses Dokument legt die erste Stadtanker-Liste und ihre Spielrollen fest.
Es erzeugt keine Stadtpunkt-Datei, keine Koordinaten, keine Runtime-Daten,
keine Assets und keinen Code.

## 2. Reuse-before-build Check

| Quelle / Grundlage | Eignung | Lizenz-/Risikohinweis | Entscheidung |
| --- | --- | --- | --- |
| Natural Earth Populated Places | geeignet als spaeterer offener Stadtpunkt-Kandidat | Natural Earth ist Public Domain; Populated Places bietet Stadt-/Ortspunkte mit Namen, Version 5.1.2. | Bevorzugter spaeterer Datencheck, aber in diesem Slice kein Download und keine Koordinaten. |
| OpenStreetMap | fachlich reich, aber fuer diesen Schritt zu lizenzsensibel | OSM-Daten stehen unter ODbL, brauchen Attribution und koennen Share-Alike-Folgen haben. | Nur Kandidat mit eigenem Lizenz-/Attributionsgate, nicht jetzt verwenden. |
| ISTAT | moeglicher amtlicher Kandidat fuer italienische Orts-/Statistikdaten | Lizenz, Attribution, kommerzielle Nutzbarkeit und Datensatz-Fit muessen vor Nutzung separat geprueft werden. | Nur Kandidat, nicht jetzt verwenden. |
| 407-Makro-Blockout | sichtbar vorhanden, aber zu abstrakt | Dokumentationsvisual, keine Runtime-Geometrie. | Als zu ueberarbeitender Ausgangspunkt markieren, nicht final behandeln. |

Quellenhinweise:

- Natural Earth Populated Places: `https://www.naturalearthdata.com/downloads/10m-cultural-vectors/10m-populated-places/`
- Natural Earth Terms of Use: `https://www.naturalearthdata.com/about/terms-of-use/`
- OpenStreetMap Copyright and License: `https://www.openstreetmap.org/copyright`

## 3. Warum echte Stadtanker noetig sind

Stadtanker schuetzen den Italien-Prototyp vor drei Risiken:

1. Der Blockout wirkt sonst wie eine generische Landmasse mit zufaelligen
   Bauflaechen.
2. Wege und Uebergaenge koennen nicht glaubwuerdig begruendet werden.
3. Spaetere Spielerkennung von Italien bleibt zu sehr an der Aussenkontur
   haengen, statt ueber vertraute Orte, Rollen und regionale Vielfalt zu
   wirken.

Stadtanker sind keine finalen Runtime-Koordinaten. Sie sind
Design-Bezugspunkte fuer den naechsten visuellen Blockout-Pass.

## 4. Erste Stadtanker-Liste

| Stadtanker | Status | Moegliche Spielrolle | Warum aufnehmen |
| --- | --- | --- | --- |
| Rom | sofort wichtig | zentraler Hub, Start-/Hauptanker, Kultur- und Fortschrittsknoten | Italienische Hauptidentitaet und beste zentrale Orientierung. |
| Florenz | sofort wichtig | Kunst-/Handwerk-/Lernkultur-Anker | Starker Mittelitalien-Anker zwischen Norden und Rom. |
| Venedig | sofort wichtig | Wasser-/Bruecken-/Entdeckungsanker | Begruendet Wasserwege, Brueckenlogik und besondere Visit-Momente. |
| Mailand | sofort wichtig | Nord-/Werkstatt-/Handelsanker | Starker Nordanker und Gegenpol zu Rom/Neapel. |
| Neapel | sofort wichtig | Sued-/Kueste-/Energie-Anker | Verbindet Suedraum, Kueste und Weg nach Sizilien. |
| Bologna | sofort wichtig | Lern-/Wegekreuz-/Netzwerkanker | Geeignet als Knoten zwischen Mailand, Florenz, Venedig und Rom. |
| Pisa | Reserve | Landmark-/Schieferturm-/Mini-Fokusanker | Stark erkennbar, aber nicht zwingend fuer ersten Pfadkern. |
| Verona | Reserve | Nordost-/Besuchs-/Kulturanker | Ergaenzt Venedig/Bologna ohne den Startblockout zu ueberladen. |
| Genua | Reserve | Hafen-/Kueste-/Westanker | Begruendet westliche Kueste und See-/Handelsbezug. |
| Bari | Reserve | Adria-/Suedost-/Hafenanker | Staerkt den Stiefelabsatz und spaetere Uebergangslogik. |
| Palermo | Reserve | Sizilien-Hauptanker | Macht Sizilien als eigenen Spielraum glaubwuerdig. |
| Catania | Reserve | Sizilien-Ost-/Vulkan-/Hoehenanker | Ergaenzt Palermo und kann spaeter Natur-/Hoehenlogik tragen. |
| Cagliari | Reserve | Sardinien-Hauptanker | Macht Sardinien als eigener Spielraum glaubwuerdig. |

## 5. Sofort wichtig vs. Reserve

Sofort wichtige Stadtanker fuer den naechsten Blockout-Pass:

- Rom
- Florenz
- Venedig
- Mailand
- Neapel
- Bologna

Reserveanker fuer Erweiterung, regionale Tiefe und spaetere Visit-/Object-
Focus-Logik:

- Pisa
- Verona
- Genua
- Bari
- Palermo
- Catania
- Cagliari

Diese Einteilung ist eine Spielplanungsentscheidung. Sie behauptet keine
Bevoelkerungsrangliste, keine Atlasgenauigkeit und keine finalen
Koordinaten.

## 6. Madrid-Regel

Madrid wird nicht aufgenommen.

Grund:

- Madrid liegt nicht in Italien.
- Der Italien-Prototyp braucht klare geografische und spielerische Identitaet.
- Fremde Stadtanker wuerden die Source-of-Truth- und Wiedererkennbarkeitslogik
  fuer den ersten Prototyp verwirren.

Spaetere andere Laender- oder Europa-Prototypen brauchen eigene Source-of-
Truth-, Stadtanker- und Blockout-Gates.

## 7. Regeln fuer den naechsten Blockout-Pass

Der naechste Slice soll `407` ueberarbeiten, nicht finalisieren.

Pflicht:

- Stadtanker sichtbar als spielnahe Orientierung beruecksichtigen.
- 11-14 organische Bauflaechen weiter schuetzen.
- Ca. 6 sofort plausible Flaechen an den sofort wichtigen Stadtankern
  ausrichten.
- Reserveflaechen an Reserveankern oder sinnvollen Zwischenraeumen andocken.
- Wege sollen die Stadtanker-Logik tragen, nicht nur Flaechen verbinden.
- Wasser/Kueste/Uebergaenge sollen Venedig, Neapel, Bari, Palermo, Catania
  und Cagliari raeumlich plausibel machen.
- No-Walk/No-Build bleibt grob und blockoutartig, nicht Runtime.

Nicht erlaubt:

- keine finalen Koordinaten,
- keine Runtime-Stadtpunkte,
- keine JSON/YAML/YML,
- keine App-Code-Dateien,
- keine Assets,
- keine App-Integration,
- kein Commit.

## 8. Entscheidung

| Frage | Entscheidung |
| --- | --- |
| Sind echte Stadtanker fuer den naechsten Blockout noetig? | JA |
| Wird Natural Earth Populated Places als spaeterer Stadtpunkt-Kandidat bevorzugt? | JA |
| Werden OSM/ISTAT jetzt verwendet? | NEIN |
| Entstehen finale Koordinaten oder Runtime-Daten? | NEIN |
| Bleibt 407 ein zu ueberarbeitender Zwischenstand? | JA |

## 9. Naechster Slice

Naechster empfohlener Slice:

```text
Italien-Makro-Blockout an Stadtankern ueberarbeiten
```
