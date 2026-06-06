# Phase 2G-M11-B: Multi-Example Container Flow Visual Review

Stand: 2026-06-06

Status: `visuelle Pruefung gestartet / Multi-Flow-Richtung brauchbar`

Dieses Dokument bewertet die Phase-2G-M11-Previews visuell. Es klaert, ob die
Multi-Flow-Logik als Planungsrichtung grundsaetzlich brauchbar ist oder
nachgebessert werden muss.

Die Pruefung gibt keine Freigabe fuer:

- Flutter-/Dart-Code,
- App-Integration,
- Tests,
- Spielassets,
- PNGs im Asset-Ordner,
- finales Inselbild,
- finale UI,
- finale Container-Systemarchitektur,
- Flow-Implementierung,
- `frame_started`,
- neue Bauzustaende.

## 1. Zweck

M11-B prueft, ob die M11-Previews das wichtigste M9-B-Follow-up erfuellen:
Ein Container-/Depth-System darf nicht aus nur einem Kuechenbeispiel
abgeleitet werden.

Geprueft wird daher, ob drei unterschiedliche Flows visuell plausibel sind:

- Schule -> Federmappe -> Stifte,
- Hafen -> Bootskajute -> Kompass/Karte/Seil,
- Garten -> Beet -> Samen/Giesskanne/Pflanze.

## 2. Gepruefte Dateien

Geprueft wurden:

- `docs/world_design/previews/phase2g_m11_multi_example_container_flows/01_multi_flow_overview.png`
- `docs/world_design/previews/phase2g_m11_multi_example_container_flows/02_flow_comparison_matrix.png`
- `docs/world_design/previews/phase2g_m11_multi_example_container_flows/03_challenge_fit_by_flow.png`
- `docs/world_design/previews/phase2g_m11_multi_example_container_flows/04_companion_moments_by_flow.png`
- `docs/world_design/previews/phase2g_m11_multi_example_container_flows/README.md`

Die Dateien sind Dokumentations-/Previewmaterial. Sie sind keine Spielassets,
keine finale UI und keine Codefreigabe.

## 3. Visuelle Bewertung

| Prueffrage | Bewertung |
| --- | --- |
| Sind die drei Flows verstaendlich? | Ja. Jeder Flow zeigt Thema, Container/Fokus, Objekte, Challenge-Fit, Companion-Moment und Risiko. |
| Wird klar, dass M11 mehr als nur den Kuechenflow prueft? | Ja. Die Uebersicht stellt Schule, Hafen und Garten sichtbar nebeneinander. |
| Ist Schule/Federmappe/Stifte als kleiner Alltagscontainer tragfaehig? | Ja. Federmappe ist ein intuitiver Container fuer kleine Schulobjekte. |
| Ist Hafen/Bootskajute/Kompass-Karte-Seil thematisch stark, aber mobil riskanter? | Ja. Der Flow wirkt reizvoll, wird aber als komplexerer Mobile-Fall markiert. |
| Ist Garten/Beet/Samen-Giesskanne-Pflanze als fokussierte Zone tragfaehig? | Ja. Das Beet funktioniert als fokussierte Zone, auch wenn es kein klassischer Behaelter ist. |
| Wird Tap-Auswahl ueber alle drei Flows als MVP-Kandidat sichtbar? | Ja. Matrix und Challenge-Preview zeigen Tap-Auswahl ueberall als stark. |
| Bleibt Audio + Tap eine zweite Stufe mit Fallback? | Ja. Audio + Tap wird als fruehe zweite Stufe dargestellt, nicht als Pflicht fuer den Start. |
| Sind Matching/Sortieren spaeter sinnvoll? | Ja. Besonders Schule/Federmappe und Garten/Beet zeigen gute spaetere Passung. |
| Bleiben Mini-Sequenzen advanced? | Ja. Mini-Sequenzen wirken vor allem fuer Hafen und Garten reizvoll, bleiben aber advanced. |
| Sind Tali/Vori-Momente freundlich, kurz und nicht loesungsgebend? | Ja. Die Companion-Momente sind kurz, optional und helfen nicht automatisch beim Loesen. |
| Sind Risiken sichtbar genug? | Ja. Hafen/Kajute, Schul-Kleinteile und Garten-Wachstum/Timer sind klar markiert. |
| Sind die Previews lesbar? | Ja. Uebersicht, Matrix, Challenge-Fit und Companion-Momente sind fuer interne Planung gut lesbar. |
| Bleiben Texte innerhalb der Karten/Rahmen/Panels? | Ja. Keine relevanten Labels laufen sichtbar aus Karten, Rahmen oder Panels. |
| Wirken die Previews zu technisch? | Nein fuer interne Planung. Sie bleiben diagrammatisch, aber nicht chaotisch. |
| Wird finale UI, Spielasset oder Codefreigabe suggeriert? | Nein. Titel, README und Labels markieren die Dateien als Dokumentationspreview. |

## 4. Einzelbewertung Der Preview-Dateien

### `01_multi_flow_overview.png`

Die Uebersicht ist die wichtigste Produkt-/Planungsansicht. Sie zeigt alle
drei Flows in gleicher Struktur und macht sofort sichtbar, dass M11 nicht nur
den Kuechenflow fortsetzt.

Bewertung: `brauchbar`.

Staerken:

- klare Trennung der drei Themen,
- gute Risikozeile je Flow,
- Beat-Sequenz macht Nutzerhandlung sichtbar.

Risiko:

- Hafen/Kajute ist inhaltlich reizvoll, kann aber spaeter visuell komplexer
  werden als Schule oder Garten.

### `02_flow_comparison_matrix.png`

Die Matrix ist fuer interne Planung brauchbar. Sie macht sichtbar, dass
Schule/Federmappe und Garten/Beet besonders klare fruehe Kandidaten sind,
waehrend Hafen/Bootskajute als wertvoller, aber riskanterer Flow behandelt
werden muss.

Bewertung: `brauchbar`.

Risiko:

- Fuer Nutzer waere die Matrix zu technisch. Sie darf nicht als Produktansicht
  verstanden werden.

### `03_challenge_fit_by_flow.png`

Die Challenge-Fit-Preview bestaetigt die bisherige M10-B2-Richtung:
Tap-Auswahl ist der staerkste gemeinsame MVP-Kandidat. Audio + Tap bleibt die
zweite Stufe mit Silent-/Accessibility-Fallback. Matching, Sortieren und
Mini-Sequenzen bleiben spaetere Varianten.

Bewertung: `brauchbar`.

Risiko:

- Mini-Sequenzen wirken stark bei Hafen und Garten, duerfen aber nicht vor
  einer separaten Aktions-/Reihenfolgepruefung implementiert werden.

### `04_companion_moments_by_flow.png`

Die Companion-Preview zeigt, dass Tali/Vori pro Flow anders reagieren kann,
ohne die Challenge zu loesen oder Druck zu erzeugen.

Bewertung: `brauchbar`.

Risiko:

- Companion-Texte bleiben bewusst schematisch. Voice, Animation, Timing,
  Personality-Varianten und Comeback-Erinnerungen brauchen spaeter eigene
  Detailpruefung.

### `README.md`

Das README dokumentiert Zweck, Dateien, Prueffazit, Risiken und Grenzen klar.

Bewertung: `brauchbar`.

## 5. Entscheidungsempfehlung

Empfehlung:

```text
M11 als Multi-Flow-Pruefung grundsaetzlich bestaetigen.
```

Begruendung:

- Schule/Federmappe ist als kleiner Alltagscontainer sehr tragfaehig.
- Garten/Beet ist als fokussierte Zone tragfaehig und stark fuer spaetere
  Wachstums-/Progressionslogik.
- Hafen/Bootskajute ist thematisch stark und motivierend, bleibt aber als
  Mobile-/Komplexitaetsrisiko dokumentiert.
- Tap-Auswahl funktioniert ueber alle drei Flows als erster MVP-Kandidat.
- Tali/Vori-Momente bleiben kurz, freundlich und nicht loesungsgebend.
- Die Previews sind lesbar und halten Texte sichtbar innerhalb der Panels.

Einschraenkung:

M11-B bestaetigt nur die Multi-Flow-Richtung als Planungsgrundlage. Es gibt
weiterhin keine finale Container-Systemarchitektur, keine Flow-Implementierung,
keine App-Integration und keine Assetfreigabe.

## 6. Entscheidungmoeglichkeiten

| Option | Bewertung |
| --- | --- |
| M11 als Multi-Flow-Pruefung grundsaetzlich bestaetigen | Empfohlen. |
| M11 mit kleinen Nachbesserungen bestaetigen | Aktuell nicht noetig. |
| M11 erneut nachbessern | Aktuell nicht noetig. |
| M11 nur als Zwischenstand behalten und weitere Flows/Mobile-Preview planen | Nicht als Voraussetzung fuer die Grundsatzbestaetigung noetig, aber Mobile-Follow-up bleibt sinnvoll. |

## 7. Empfohlene Follow-ups

M11-B schliesst den M9-B-Pflichtpunkt `Weitere Beispiel-Flows` als
grundsaetzlich brauchbar ab. Trotzdem bleiben weitere Folgeschritte sinnvoll:

- Mobile-spezifische Pruefung fuer Hafen/Bootskajute,
- Clutter-/Kleinteile-Pruefung fuer Schule/Federmappe,
- Fairness-/Timer-Pruefung fuer Gartenwachstum,
- spaetere UX-Pruefung fuer Mini-Sequenzen,
- spaetere Produktansicht fuer einen echten Nutzerflow statt interner
  Vergleichsmatrix.

## 8. Weiterhin Blockiert

Weiterhin blockiert bleiben:

- Flutter-/Dart-Code,
- App-Integration,
- Tests,
- Spielassets,
- PNGs im Asset-Ordner,
- finales Inselbild,
- finale UI,
- finale Container-Systemarchitektur,
- Flow-Implementierung,
- Challenge-Implementierung,
- Companion-Implementierung,
- Voice-/Audio-/Animation-/Rive-Freigabe,
- `frame_started`,
- neue Bauzustaende,
- Persistenz,
- Supabase,
- SRS-/`word_progress`,
- Reward Bridge.

## 9. Stop-Regeln

Stoppen, wenn:

- aus M11-B eine finale Container-Systemarchitektur abgeleitet werden soll,
- ein Flow ohne spaetere UX-/Mobile-Pruefung implementiert werden soll,
- Hafen-/Kajuten-UX ohne separate Mobile-Komplexitaetspruefung bestaetigt
  werden soll,
- Garten-Wachstumsmechanik ohne Fairness-/Timer-Pruefung geplant oder
  implementiert werden soll,
- Schulobjekt-Ansicht ohne Clutter-/Kleinteile-Pruefung als Produktentscheidung
  behandelt werden soll,
- aus M11 oder M11-B App-, Code- oder Assetfreigabe abgeleitet wird.

## 10. Naechster Erlaubter Schritt

Nach M11-B ist erlaubt:

- M11 als Multi-Flow-Pruefung dokumentarisch bestaetigen,
- Mobile-spezifische Preview oder Review fuer Hafen/Bootskajute planen,
- Clutter-/Kleinteile-Pruefung fuer Schule/Federmappe planen,
- Fairness-/Timer-Pruefung fuer Gartenwachstum planen,
- oder den naechsten reinen Planungsblock fuer Container-Systemarchitektur
  vorbereiten.

Weiterhin nicht erlaubt:

- Code,
- Assets,
- App-Integration,
- `frame_started`,
- finale Container-Systemarchitektur,
- produktive Bau-/Lernlogik.

## 11. Nachtrag: World Content Taxonomy

Nach M11-B wurde ein umfangreicher Nutzerkatalog mit moeglichen Orten,
Gebaeuden, Aussenbereichen, Infrastruktur, Naturflaechen, Wasser-/Kuesten-
Bereichen, Landwirtschaft und Details eingebracht.

Dieser Katalog wird nicht als Assetfreigabe gelesen. Er wird in
`docs/world_design/266-world-content-taxonomy-and-location-catalog.md` als
Planungs-/Taxonomy-Backlog aufgenommen.

M11-B bleibt weiterhin nur ein Multi-Flow-Review. Der Taxonomy-Nachtrag
erzeugt keine finale Container-Systemarchitektur, keine App-Integration, keine
Assets, keine Bauzustaende und kein `frame_started`.
