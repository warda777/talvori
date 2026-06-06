# Phase 2G-M7-C: Capability Greybox Visual Review

Status: `visuelle Pruefung gestartet / technische Debug-Greybox brauchbar`

## 1. Zweck

Dieses Dokument bewertet die erzeugten Phase-2G-M7-B-Previews visuell. Es
klaert, ob die Capability-Greybox als technische Debug-Greybox bestaetigt
werden kann oder ob Nachbesserungen noetig sind.

Die Pruefung gibt keine Freigabe fuer:

- Spielassets,
- finales Inselbild,
- Flutter-/Dart-Code,
- App-Integration,
- `frame_started`,
- neue Bauzustaende.

## 2. Gepruefte Dateien

Geprueft wurden:

- `docs/world_design/previews/phase2g_m7_capability_greybox/01_capability_plot_overview.png`
- `docs/world_design/previews/phase2g_m7_capability_greybox/02_allowed_functions_overlay.png`
- `docs/world_design/previews/phase2g_m7_capability_greybox/03_anchor_socket_overlay.png`
- `docs/world_design/previews/phase2g_m7_capability_greybox/04_user_choice_flow_overlay.png`
- `docs/world_design/previews/phase2g_m7_capability_greybox/README.md`

Die Dateien sind Debug-/Dokumentationsmaterial. Sie sind keine Spielassets und
keine finale Kunst.

## 3. Visuelle Bewertung

| Prueffrage | Bewertung |
| --- | --- |
| Sind alte Rollenlabels vollstaendig entfernt? | Ja. Die Preview nutzt abstrakte Labels wie `core_plot_a`, `hub_capable_plot_a` und `edge_water_capable_plot_a`. |
| Sind abstrakte Plotnamen gut lesbar? | Ja. Die groessere Canvas-Version ist ruhig genug, um Plotnamen, Status und Groesse zu lesen. |
| Sind `plotSize`, `unlockState` und `isUserSelectable` verstaendlich? | Ja. Die Overview-Datei macht diese drei Metadaten klar sichtbar. |
| Sind `allowedFunctions` sichtbar, ohne feste Bauentscheidung zu suggerieren? | Ja. Die Funktionsansicht zeigt mehrere moegliche Funktionen pro Plot und nennt explizit, dass keine Funktion ausgewaehlt ist. |
| Sind Anchors, Sockets und Footprints technisch pruefbar? | Ja, als interne QA-Ansicht. Die Ansicht ist dicht, aber Sockets, Anchors und Footprints sind unterscheidbar. |
| Ist der Nutzerwahl-Flow verstaendlich? | Ja. Die Flow-Preview zeigt klar: Plot waehlen, Optionen anzeigen, Nutzer bestaetigt, erst danach entsteht ein Ergebnis. |
| Ist die technische Vollansicht zu dicht? | Fuer Nutzer ja. Fuer interne Planung/QA ist sie brauchbar. |
| Braucht es zusaetzlich eine vereinfachte Nutzer-/Produktansicht? | Ja, empfohlen. Die technische Vollansicht darf nicht direkt als Nutzer-UX dienen. |
| Entsteht wieder der Eindruck einer festen Haus-/Garten-/Markt-Reihenfolge? | Nein. Die Diagramme zeigen Capabilities statt fester Rollen oder Reihenfolge. |
| Sind die Dateien als Dokumentationsmaterial geeignet? | Ja. Sie sind als technische Debug-Greybox geeignet. |

## 4. Einzelbewertung Der Preview-Dateien

### `01_capability_plot_overview.png`

Die Overview-Datei ist die staerkste technische Zusammenfassung. Plotnamen,
`plotSize`, `unlockState` und `isUserSelectable` sind klar lesbar. Statusfarben
und gestrichelte Linien machen verfuegbar/gesperrt gut unterscheidbar.

Bewertung: `brauchbar als technische Debug-Uebersicht`.

### `02_allowed_functions_overlay.png`

Die Funktionsansicht zeigt mehrere kompatible Funktionen pro Plot. Wichtig ist,
dass die Darstellung keine davon als bereits gewaehlt markiert. Dadurch bleibt
die Nutzerentscheidung erhalten.

Bewertung: `brauchbar, aber fuer Nutzer zu technisch`.

### `03_anchor_socket_overlay.png`

Die Anchor-/Socket-/Footprint-Ansicht ist bewusst dicht. Sie ist fuer interne
Pruefung wertvoll, weil sie Pfad-Sockets, Objekt-Anker und Footprints in einer
gemeinsamen Ansicht sichtbar macht. Fuer Produktkommunikation ist sie zu
komplex.

Bewertung: `brauchbar als interne QA-Ansicht`.

### `04_user_choice_flow_overlay.png`

Der Nutzerwahl-Flow ist klar und wichtig fuer die Produktentscheidung:
Capabilities fuehren nur zu Vorschlaegen. Platzierung oder Bauinstanz entsteht
erst nach Nutzerbestaetigung.

Bewertung: `brauchbar als Prozess-Debugdiagramm`.

## 5. Entscheidungsmoeglichkeiten

### Option 1: M7-B Als Technische Debug-Greybox Bestaetigen

M7-B kann als technische Debug-Greybox bestaetigt werden. Diese Bestaetigung
gilt nur fuer Dokumentation und interne Planung.

Sie gilt nicht fuer:

- Nutzer-UI,
- Spielasset,
- finales Inselbild,
- Assetfreigabe,
- Codefreigabe.

### Option 2: M7-B Mit Kleinen Nachbesserungen Bestaetigen

Moeglich, falls spaeter einzelne Labels, Abstaende oder Legenden verbessert
werden sollen. Aktuell sind keine zwingenden kleinen Nachbesserungen sichtbar.

### Option 3: M7-B Erneut Nachbessern

Nur noetig, wenn die Nutzerpruefung der technischen Dokumente zeigt, dass
`allowedFunctions`, `isUserSelectable` oder die Anchor-/Socket-Sicht nicht
ausreichend verstanden werden.

### Option 4: Zusaetzlich M7-D Als Vereinfachte Nutzer-/Produktansicht Planen

Empfohlen. M7-B ist fuer interne Planung geeignet, aber zu technisch fuer
Nutzer. Eine M7-D-Ansicht sollte dieselbe Capability-Logik einfacher zeigen:

- weniger technische Labels,
- weniger Funktionen gleichzeitig,
- klare Fokusfrage: Was kann ich hier bauen?
- keine Debug-Sockets/Footprints in der Nutzeransicht,
- sichtbare Nutzerwahl statt Datenmodell-Vollansicht.

## 6. Empfehlung

Empfehlung:

- M7-B als technische Debug-Greybox bestaetigen.
- Zusaetzlich spaeter M7-D als vereinfachte Nutzer-/Produktansicht planen.

Begruendung:

M7-B loest das Hauptproblem der Variante-B-Greybox: Die Preview zeigt keine
festen Gebaeudepositionen mehr. Sie zeigt stattdessen flexible Plot-Slots,
Capabilities und Nutzerentscheidung. Damit ist sie als technisches
Planungsdiagramm brauchbar.

Sie ist aber keine gute Nutzeransicht. Eine echte Nutzer-/Produktansicht muss
die gleiche Logik deutlich reduzierter und spielnaher darstellen.

## 7. Weiterhin Blockiert

Weiterhin blockiert bleiben:

- `frame_started`,
- neue Spielassets,
- PNGs im Asset-Ordner,
- finales Inselbild,
- Flutter-/Dart-Code,
- App-Integration,
- neue Bauzustaende,
- Persistenz,
- Supabase,
- SRS-/`word_progress`,
- Reward Bridge,
- Ressourcenlogik,
- Sound-/FX-Schicht.

## 8. Stop-Regeln

Stoppen, wenn:

- die technische Capability-Greybox als Nutzeransicht verwendet werden soll,
- Nutzer-UX direkt aus der technischen Vollansicht abgeleitet wird, ohne eine
  vereinfachte Produktansicht zu planen,
- aus M7-B Asset- oder Codefreigabe abgeleitet wird,
- `frame_started` weiterbearbeitet werden soll, bevor Capability-Greybox und
  Nutzeransicht geklaert sind,
- alte feste Gebaeude-Rollenlabels wieder in die Greybox gelangen,
- eine Capability-Greybox wieder Haus/Garten/Markt als feste Reihenfolge
  suggeriert.

## 9. Naechster Erlaubter Schritt

Nach M7-C ist erlaubt:

- Nutzer prueft die technische Debug-Greybox,
- M7-B als technische Debug-Greybox bestaetigen oder gezielt nachbessern,
- M7-D als vereinfachte Nutzer-/Produktansicht planen.

Weiterhin nicht erlaubt:

- Code,
- Assets,
- App-Integration,
- `frame_started`,
- produktive Bau-/Lernlogik.

## 10. M8-Erkenntnis: ObjectAnchors Und Tiefe

Phase 2G-M8 ergaenzt eine wichtige Lesart fuer M7-B:

- `objectAnchors` sind technische moegliche Platzierungs- oder
  Einstiegspunkte.
- `objectAnchors` sind keine Pflichtobjekte.
- Mehrere `objectAnchors` bedeuten nicht, dass auf derselben Ebene sofort
  mehrere sichtbare Objekte erscheinen muessen.
- Ein `objectAnchor` kann auch ein `containerEntryAnchor` sein, also ein
  Einstieg in eine tiefere Objekt- oder Containeransicht.
- Container koennen danach eigene `innerObjectAnchors` besitzen.

Konsequenz:

M7-D darf nicht nur eine vereinfachte technische Plotansicht werden. Eine
spaetere Nutzer-/Produktansicht muss Depth-, Zoom- und Container-Logik
mitdenken:

- Island View zeigt wenige Hauptobjekte und klare Fortschrittszeichen.
- Plot/Building/Interior/Object/Container-Ebenen nehmen kleinere Woerter und
  Detailobjekte auf.
- Kleine Objekte wie `Loeffel`, `Bleistift` oder `Schluessel` gehoeren eher in
  Container- oder Detailansichten als direkt auf die Inseloberflaeche.
- Nutzer sollen Objekte antippen, oeffnen, sortieren, zuordnen oder
  vervollstaendigen koennen.
- Diese Nutzer-/Produktansicht soll spaeter visuell geprueft werden, z. B. als
  Flowchart, Storyboard-Greybox oder einfache Preview fuer Ketten wie Kueche ->
  Schublade -> Besteck.

Diese Ergaenzung gibt weiterhin keine Freigabe fuer Assets, Code,
`frame_started` oder produktive Bau-/Lernlogik.
