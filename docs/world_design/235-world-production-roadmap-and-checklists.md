# Talvori Welt: Production Roadmap Und Checklists

Stand: 2026-06-06

Dieses Dokument ist die zentrale Produktionskontrolle fuer Talvori Welt. Es
ordnet Roadmap, ToDos, Gates und Checklisten, damit vor weiteren World-Schritten
klar ist, was erlaubt, blockiert oder noch nur Planung ist.

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
- `docs/world_design/252-flexible-plot-placement-and-learning-semantics.md`
- `docs/world_design/253-capability-greybox-plan.md`
- `docs/world_design/254-capability-greybox-visual-review.md`
- `docs/world_design/255-world-depth-gameplay-retention-research.md`
- `docs/world_design/256-depth-container-user-flow-preview-plan.md`
- `docs/world_design/257-depth-container-user-flow-visual-review.md`
- `docs/world_design/258-emotional-product-flow-preview-plan.md`
- `docs/world_design/259-emotional-product-flow-visual-review.md`
- `docs/world_design/260-challenge-interaction-comparison.md`
- `docs/world_design/261-challenge-interaction-visual-review.md`
- `docs/world_design/262-companion-reaction-flow.md`
- `docs/world_design/263-companion-reaction-visual-review.md`
- `docs/world_design/264-multi-example-container-flow-previews.md`
- `docs/world_design/265-multi-example-container-flow-visual-review.md`
- `docs/world_design/266-world-content-taxonomy-and-location-catalog.md`
- `docs/world_design/267-world-content-taxonomy-review.md`
- `docs/world_design/268-theme-island-prioritization.md`
- `docs/world_design/269-theme-island-prioritization-visual-review.md`
- `docs/220-talvori-world-professional-game-architecture-research.md`
- `docs/221-talvori-world-build-and-expansion-architecture.md`
- `docs/222-talvori-world-game-system-master-plan.md`

## 1. Zweck Des Dokuments

Dieses Dokument dient als zentrale Produktionskontrolle fuer Talvori Welt.

Es soll:

- Roadmap, ToDos, Gates und Checklisten buendeln,
- Abweichungen vom Plan frueh sichtbar machen,
- verhindern, dass Code auf unvollstaendige Planung oder nicht freigegebene
  Assets gebaut wird,
- vor jedem groesseren Codex-Prompt geprueft werden,
- klar markieren, was als naechstes erlaubt oder blockiert ist.

Merksatz:

> Kein neuer World-Code ohne fuehrendes Dokument, freigegebene Assets und
> kleinen Scope.

## 2. Statusmodell

Statuswerte:

| Status | Bedeutung | Code erlaubt? | Nur Planung? | Stop-Regel |
| --- | --- | --- | --- | --- |
| `offen` | Idee oder Aufgabe ist erkannt, aber noch nicht ausgearbeitet. | nein | ja | Code stoppen. |
| `in Arbeit` | Konzept, Asset oder Dokument wird gerade bearbeitet. | nein | ja | Code stoppen, bis Ergebnis vorliegt. |
| `geplant` | Konzept ist beschrieben, aber noch nicht produziert oder geprueft. | nur fuer Docs/kleine Vorbereitung | ja | Produktions- oder Code-Scope pruefen. |
| `generiert` | Asset oder Material wurde erzeugt, aber noch nicht geprueft. | nein | eingeschraenkt | Erst Qualitaetspruefung. |
| `geprueft` | Ergebnis wurde geprueft; Entscheidung oder Freigabe kann folgen. | nur nach ausdruecklicher Freigabe | ja | Offene Maengel klaeren. |
| `nachbessern` | Ergebnis passt noch nicht. | nein | ja | Code stoppen, Asset/Plan ueberarbeiten. |
| `freigegeben` | Ergebnis ist fuer den naechsten Schritt nutzbar. | ja, wenn Scope passt | ja | Weiter nur nach Checkliste. |
| `fertig` | Schritt ist abgeschlossen und dokumentiert. | ja, wenn abhaengige Gates erfuellt sind | ja | Keine offenen Blocker. |
| `verworfen` | Ergebnis wird nicht weiter genutzt. | nein | nur fuer Ableitung | Nicht als Grundlage verwenden. |

Regeln:

- Code ist nur auf Basis von `freigegeben` oder `fertig` erlaubt.
- `offen`, `in Arbeit`, `generiert`, `nachbessern` und `verworfen` blockieren
  Code.
- `geplant` erlaubt weitere Planung, aber keinen produktionsnahen Code.
- `geprueft` ist ein Zwischenstatus; die Entscheidung muss dokumentiert werden.

## 3. Aktueller Gesamtstand

Aktueller Stand der Talvori-Welt-Produktion:

- Phase 1 Home-Zentrale ist abgeschlossen.
- Phase 2 Local World Entry ist vorhanden.
- Starter- und Community-Inseln sind als Preview-/World-Assets vorhanden.
- Das Connector-Kit ist vorhanden, aber nicht aktiv genutzt.
- DockingPoints sind lokal/mock vorbereitet.
- Der erste Phase-2E-Code-Slice wurde visuell verworfen, weil die Asset-
  Grundlage nicht buildable war.
- Das buildable Waldlichtung-Template wurde fuer den kleinen Phase-2E-E-Slice
  freigegeben.
- Phase 2E-E wurde als lokaler Mock-Slice umgesetzt und mit Commit
  `c82880e4 feat: polish forest clearing foundation guidance` abgeschlossen.
- Phase 2F (`foundation_complete`) wurde als lokaler Mock-Slice umgesetzt,
  auf Geraet geprueft und mit Commit
  `b13d2162 fix: refine foundation complete guidance flow` abgeschlossen.
- Phase 2G (`frame_started` / Rohbau) wurde als reiner Planungsblock in
  `docs/world_design/243-frame-started-plan.md` gestartet.
- Der Asset-Prompt-/Freigabeblock fuer `frame_started` wurde in
  `docs/world_design/244-frame-started-asset-prompt.md` vorbereitet.
- Die lokale Sichtpruefung des aktuellen `frame_started.png`-Kandidaten hat
  gezeigt, dass ungefaehres Zentrum-Alignment fuer Rohbau nicht reicht.
- Der zusaetzliche Anchor-/Alignment-Definitionsblock fuer Phase 2G wurde in
  `docs/world_design/245-build-alignment-and-anchor-system.md` gestartet.
- Phase 2G `frame_started` wurde danach vollstaendig gestoppt, weil vor
  weiteren Bauassets ein Insel-Masterlayout mit modularen Plot-Flaechen,
  Sockets, Anchors und Footprints fehlt.
- Das Waldlichtung-Masterlayout-/Plot-System wurde in
  `docs/world_design/246-island-master-layout-and-modular-plot-system.md`
  gestartet.
- Phase 2G-M1 wurde als Greybox-/Scale-/Plot-Messblock in
  `docs/world_design/247-island-greybox-scale-and-plot-metrics.md` gestartet.
- Phase 2G-M2 wurde als konkreter Plot-Metrik- und Koordinaten-Greybox-
  Planungsblock in
  `docs/world_design/248-island-plot-metrics-and-greybox-layout.md`
  gestartet.
- Phase 2G-M3 wurde als sichtbarer Greybox-Preview-/Layout-Pruefblock in
  `docs/world_design/249-island-greybox-preview-plan.md` gestartet.
- Phase 2G-M4 wurde als reine Debug-Greybox-Preview-Erzeugung gestartet.
  Die Preview-Dateien liegen als Dokumentationsmaterial unter
  `docs/world_design/previews/phase2g_m3_island_greybox/`.
- Phase 2G-M5 wurde als visueller Greybox-Layout-Review in
  `docs/world_design/250-island-greybox-layout-review.md` gestartet.
- Die M4-Greybox ist technisch pruefbar, aber visuell noch nicht bestaetigt:
  Sie wirkt zu linear/rasterhaft, `market_square` haengt zu stark als
  vertikaler Schwanz unter `hub_seed_south`, und `water_edge_east` ist zu lang
  diagonal angebunden.
- Phase 2G-M5 wurde mit einer Variante-B-Debug-Greybox fortgesetzt. Die neuen
  Preview-Dateien liegen als Dokumentationsmaterial unter
  `docs/world_design/previews/phase2g_m5_island_greybox_variant_b/`.
- Variante B ist noch nicht visuell bestaetigt, wirkt aber weniger linear:
  `market_square` haengt nicht mehr als langer vertikaler Schwanz,
  `water_edge_east` liegt klarer an einer rechten/oberen Randlogik, und
  `garden_west`/`nature_north` rahmen den Starterbereich organischer.
- Die manuelle visuelle Pruefung fuer Variante B wurde in
  `docs/world_design/251-island-greybox-variant-b-manual-review.md`
  vorbereitet. Nutzerentscheidung bleibt offen.
- Die Nutzerpruefung hat einen grundlegenden Designpunkt offengelegt:
  Variante B darf nicht als starre Gebaeudeanordnung bestaetigt werden.
  Debug-Labels wie `starter_home`, `garden_west` oder `market_square` muessen
  als flexible Plot-Slots mit Faehigkeiten interpretiert werden.
- Phase 2G-M6 wurde als reiner Planungsblock in
  `docs/world_design/252-flexible-plot-placement-and-learning-semantics.md`
  gestartet. Er klaert flexible Nutzerplatzierung und die Semantik zwischen
  Lernwoertern, Blueprints, sichtbaren Weltobjekten, Szenen und Codex.
- Phase 2G-M6 wurde vertieft: Placement Decision Pipeline, Plot Capability
  Matrix, Word Placement Requirements, Visual Representation Tiers, User
  Choice Regeln, Ambiguity Handling, Visual Clutter Regeln und
  Rebuild/Move/Personalization-Entscheidungen sind dokumentiert.
- Phase 2G-M6-C wurde ergaenzt: abstrakte Datenmodell-Skizzen,
  Trennung von Lernfortschritt und Baufortschritt, Browser-/Real-World-
  Import-Workflow, Repraesentationsprioritaet, sensible/abstrakte Begriffe und
  Learning-Mode-Integration sind dokumentiert.
- Phase 2G-M6-D wurde ergaenzt: Progression ohne feste Baureihenfolge,
  freie Erstwahl, Import-Governance/Privacy/Safety, Nutzerziel-/Kategorie-
  Priorisierung und Anforderungen an die naechste Greybox mit abstrakten
  Capability-Labels sind dokumentiert.
- Phase 2G-M6-E wurde ergaenzt: Themeninseln / Personal Learning Archipelago
  sind als uebergeordnete Strategie dokumentiert. Eine Insel muss nicht alle
  Lernwelten abdecken; Waldlichtung/Variante B bleibt Starter-/Testform.
- Phase 2G-M6-F wurde ergaenzt: Archipel-Navigation, gemeinsamer Codex/
  Blueprint/Backlog, Cross-Island Word Routing, Island Slot Lifecycle,
  Island Ownership/Identity und Archipelago UX Complexity Control sind
  dokumentiert.
- Phase 2G-M7 wurde als reiner Planungsblock in
  `docs/world_design/253-capability-greybox-plan.md` gestartet. Er bereitet
  eine abstrakte Capability-Greybox vor, die feste Variante-B-Rollenlabels
  durch neutrale Plot-Slots mit `allowedFunctions`, `isUserSelectable`,
  `unlockState`, Anchors, Sockets und Footprints ersetzt.
- Phase 2G-M7-B wurde als reine Debug-/Dokumentations-Preview-Erzeugung
  gestartet. Preview-Dateien liegen unter
  `docs/world_design/previews/phase2g_m7_capability_greybox/` und sind keine
  Spielassets, keine finale Kunst und keine Codefreigabe.
- Phase 2G-M7-C wurde als reine visuelle Pruefung in
  `docs/world_design/254-capability-greybox-visual-review.md` gestartet.
  M7-B ist als technische Debug-Greybox grundsaetzlich brauchbar. Eine
  vereinfachte Nutzer-/Produktansicht bleibt als moeglicher M7-D-Schritt
  offen.
- Phase 2G-M8 wurde als Research-/Planungsblock in
  `docs/world_design/255-world-depth-gameplay-retention-research.md`
  gestartet. M8 klaert World Depth, Zoom-/Container-System,
  Gameplay-Motivation, Retention und faire Monetarisierungsgrundlagen.
  `objectAnchors` sind technische Moeglichkeiten, keine Pflichtobjekte.
- Phase 2G-M9 wurde als vereinfachte Nutzer-/Produktansicht fuer den Depth-/
  Container-Flow gestartet. Das Planungsdokument liegt in
  `docs/world_design/256-depth-container-user-flow-preview-plan.md`; die
  Preview-Dateien liegen unter
  `docs/world_design/previews/phase2g_m9_depth_container_user_flow/`.
  Sie zeigen den Beispiel-Flow Haus/Kueche -> Schublade -> Besteck und sind
  Dokumentationsmaterial, keine Spielassets und keine Codefreigabe.
- Phase 2G-M9-B wurde als visuelle Pruefung in
  `docs/world_design/257-depth-container-user-flow-visual-review.md`
  gestartet. Ergebnis: M9 ist als erster vereinfachter Nutzer-/Produktflow
  grundsaetzlich brauchbar, darf aber nicht allein als allgemeines
  Container-System bestaetigt werden. Weitere Beispiel-Flows bleiben
  empfohlen.
- M9-B hat verbindliche Follow-up-Punkte festgelegt. Diese duerfen nicht
  stillschweigend uebersprungen werden: emotionalere/spielnaehere
  Produktflow-Preview, Challenge-Interaktionsvergleich, Tali/Vori-
  Reaktionsflow und mehrere Beispiel-Flows fuer Schule, Hafen und Garten.
- Phase 2G-M10 wurde als emotionalere, spielnaehere Produktflow-Preview in
  `docs/world_design/258-emotional-product-flow-preview-plan.md` gestartet.
  Preview-Dateien liegen unter
  `docs/world_design/previews/phase2g_m10_emotional_product_flow/`.
  M10 ist Dokumentations-/Previewmaterial, keine finale UI, kein Spielasset,
  keine Codefreigabe und kein `frame_started`.
- Phase 2G-M10-D wurde als visuelle Pruefung in
  `docs/world_design/259-emotional-product-flow-visual-review.md` gestartet.
  Ergebnis: M10 ist als emotionalere Produktflow-Preview grundsaetzlich
  brauchbar. M10-B war danach als Pflicht-Follow-up offen und wurde im
  Challenge-Comparison-Block gestartet; M10-C wurde spaeter als Companion
  Reaction Flow gestartet; M11 wurde spaeter als Multi-Example Container Flow
  Preview gestartet.
- Phase 2G-M10-B wurde als Challenge Interaction Comparison in
  `docs/world_design/260-challenge-interaction-comparison.md` gestartet.
  Preview-Dateien liegen unter
  `docs/world_design/previews/phase2g_m10b_challenge_interaction_comparison/`.
  Empfehlung fuer den Review-Stand: zuerst Tap-Auswahl, als zweite Stufe
  Audio + Tap, Matching/Sortieren spaeter und Mini-Sequenzen spaeter fuer
  Aktionswoerter. Daraus folgen keine finale Challenge-Art, keine
  Challenge-Implementierung, kein Code, kein Asset und kein `frame_started`.
- Phase 2G-M10-B2 wurde als visuelle Pruefung in
  `docs/world_design/261-challenge-interaction-visual-review.md` gestartet.
  Ergebnis: Die M10-B-Empfehlung ist als erste Prototype-Richtung
  grundsaetzlich brauchbar: Tap-Auswahl zuerst, Audio + Tap danach,
  Matching/Sortieren spaeter, Mini-Sequenzen advanced. Daraus folgen keine
  Challenge-Implementierung, keine finale Challenge-Systementscheidung, kein
  Code, kein Asset und kein `frame_started`.
- Phase 2G-M10-C wurde als Tali/Vori Companion Reaction Flow in
  `docs/world_design/262-companion-reaction-flow.md` gestartet. Preview-
  Dateien liegen unter
  `docs/world_design/previews/phase2g_m10c_companion_reaction_flow/`.
  M10-C plant Curiosity Cue, Gentle Nudge, Challenge Support, Success Reaction,
  Correction Support, Idle Hint und optionale Next Goal Suggestion. Daraus
  folgen keine finale Companion-UX, keine Companion-Implementierung, keine
  Voice-/Audio-/Animation-Freigabe, kein Code, kein Asset und kein
  `frame_started`.
- Phase 2G-M10-C2 wurde als visuelle Pruefung in
  `docs/world_design/263-companion-reaction-visual-review.md` gestartet.
  Ergebnis: M10-C ist als erste Companion-Reaktionsrichtung grundsaetzlich
  brauchbar. Daraus folgen keine finale Companion-UX, keine Companion-
  Implementierung, keine Voice-/Audio-/Animation-/Rive-Freigabe, kein Code,
  kein Asset und kein `frame_started`.
- Phase 2G-M11 wurde als Multi-Example Container Flow Preview in
  `docs/world_design/264-multi-example-container-flow-previews.md` gestartet.
  Preview-Dateien liegen unter
  `docs/world_design/previews/phase2g_m11_multi_example_container_flows/`.
  M11 prueft Schule/Federmappe/Stifte, Hafen/Bootskajute/Kompass-Karte-Seil
  und Garten/Beet/Samen-Giesskanne-Pflanze. Daraus folgen keine finale
  Container-Systemarchitektur, keine Flow-Implementierung, keine App-
  Integration, kein Code, kein Asset und kein `frame_started`.
- Phase 2G-M11-B wurde als visuelle Pruefung in
  `docs/world_design/265-multi-example-container-flow-visual-review.md`
  gestartet. Ergebnis: M11 ist als Multi-Flow-Richtung grundsaetzlich
  brauchbar. Schule/Federmappe und Garten/Beet sind besonders tragfaehig;
  Hafen/Bootskajute bleibt wertvoll, aber mobil/visuell riskanter. Daraus
  folgen keine finale Container-Systemarchitektur, keine Flow-Implementierung,
  keine App-Integration, kein Code, kein Asset und kein `frame_started`.
- Phase 2G-M11-C / World Content Taxonomy wurde als reiner
  Dokumentationsnachtrag in
  `docs/world_design/266-world-content-taxonomy-and-location-catalog.md`
  gestartet. Der Katalog sammelt Wohnbereiche, Aussenbereiche, Verkehr,
  Stadt/Dorf, Einkauf, Freizeit, oeffentliche Gebaeude, Arbeit/Industrie,
  Natur, Wasser/Kueste, Landwirtschaft und Dekoration als langfristiges
  Taxonomy-Backlog. Er ist keine Assetfreigabe, keine finale ThemeIsland-
  Roadmap und keine Bau-Freigabe. Er dient spaeter als Grundlage fuer
  ThemeIsland-Routing, Plot-Capabilities, Container-/Depth-Planung und
  Asset-Priorisierung.
- Phase 2G-M11-C2 wurde als Taxonomy Review in
  `docs/world_design/267-world-content-taxonomy-review.md` gestartet.
  Ergebnis: Der Taxonomy-Katalog ist als erste Content-/Location-Grundlage
  grundsaetzlich brauchbar. Die 14 Hauptkategorien sind sinnvoll, aber
  Querschnittsbereiche wie Innenraeume, Moebel, Werkzeuge, Tiere, Kleidung,
  Wetter/Jahreszeiten, digitale Raeume, Lernmaterialien,
  Gesundheits-/Notfallobjekte und sensible Kultur-/Politik-/
  Gesellschaftsbereiche bleiben Follow-ups. Keine finale ThemeIsland-Roadmap,
  keine Assetliste, kein Code, kein Asset und kein `frame_started`.
- Phase 2G-M12 wurde als ThemeIsland Prioritization in
  `docs/world_design/268-theme-island-prioritization.md` gestartet.
  Preview-Dateien liegen unter
  `docs/world_design/previews/phase2g_m12_theme_island_prioritization/`.
  Ergebnis fuer den Planungsstand: Zuhause/Alltag, Schule/Lernen und
  Garten/Natur nah sind die staerksten Early-Kandidaten. Kueste/Meer/Hafen,
  Essen/Restaurant/Cafe, Einkauf/Versorgung und Land/Farm sind gute
  Mid-Kandidaten. Stadt, Verkehr, Arbeit, Freizeit, Outdoor und Technik
  bleiben spaeter; Gesundheit, Kultur/Gesellschaft/Verwaltung sowie
  Religion/Politik/Gericht/Polizei bleiben bis zu Sensitive-Content-Regeln
  blockiert. Keine finale ThemeIsland-Roadmap, keine ThemeIsland-Umsetzung,
  keine Assetliste, kein Code, kein Asset und kein `frame_started`.
- Phase 2G-M12-A2 wurde als visuelle Pruefung in
  `docs/world_design/269-theme-island-prioritization-visual-review.md`
  gestartet. Ergebnis fuer den Review-Stand: M12 ist als erste
  ThemeIsland-Priorisierung grundsaetzlich brauchbar. Die Decision Matrix ist
  dicht, aber fuer interne Planung lesbar; die Early Candidate Flow Examples
  sind verstaendlich; Texte bleiben in Karten/Rahmen/Panels. Keine finale
  ThemeIsland-Roadmap, keine ThemeIsland-Umsetzung, keine Assetproduktion,
  kein Code, kein Asset und kein `frame_started`.
- Phase 2G-M12-B wurde als Word-to-Island Routing Matrix in
  `docs/world_design/270-word-to-island-routing-matrix.md` gestartet.
  Preview-Dateien liegen unter
  `docs/world_design/previews/phase2g_m12b_word_to_island_routing/`.
  M12-B definiert erste Routing-Ebenen, Worttypen, Beispiel-Routings,
  Entscheidungsregeln, Multi-home-/Backlog-Logik und Fallbacks. Daraus folgen
  keine finale Routing-Implementierung, keine finale Datenstruktur, keine
  automatische Wortplatzierung, keine ThemeIsland-Umsetzung, keine
  Assetproduktion, kein Code, kein Asset und kein `frame_started`.
- Phase 2G-M12-B2 wurde als visuelle Pruefung in
  `docs/world_design/271-word-to-island-routing-visual-review.md` gestartet.
  Ergebnis fuer den Review-Stand: M12-B ist als erste Routing-
  Planungsrichtung grundsaetzlich brauchbar. Pipeline, Worttyp-Matrix,
  Beispielkarten und Multi-home-/Backlog-Flow sind fuer interne Planung
  verstaendlich. Daraus folgen keine finale Routing-Implementierung, keine
  finale Datenstruktur, keine automatische Wortplatzierung, keine
  ThemeIsland-Umsetzung, keine Assetfreigabe, kein Code, kein Asset und kein
  `frame_started`.
- Phase 2G-M12-C wurde als Plot-Capability Derivation in
  `docs/world_design/272-plot-capability-derivation.md` gestartet.
  Preview-Dateien liegen unter
  `docs/world_design/previews/phase2g_m12c_plot_capability_derivation/`.
  M12-C leitet erste Plot-Capabilities aus Taxonomy, ThemeIsland-
  Priorisierung und Word-to-Island Routing ab. Daraus folgen keine finale
  Plot-Datenstruktur, keine Runtime-Konfiguration, keine Plot-Implementierung,
  keine ThemeIsland-Umsetzung, keine Assetfreigabe, kein Code, kein Asset und
  kein `frame_started`.
- Phase 2G-M12-C2 wurde als visuelle Pruefung in
  `docs/world_design/273-plot-capability-visual-review.md` gestartet.
  Ergebnis fuer den Review-Stand: M12-C ist als erste Plot-Capability-
  Planungsrichtung grundsaetzlich brauchbar. Pipeline, Plot-Type-Capability-
  Matrix, Early Theme Capability Cards und Mid/Late/Special Plot Limits sind
  fuer interne Planung verstaendlich. Daraus folgen keine finale Plot-
  Datenstruktur, keine Runtime-Konfiguration, keine Plot-Implementierung,
  keine ThemeIsland-Umsetzung, keine Assetfreigabe, kein Code, kein Asset und
  kein `frame_started`.
- Phase 2G-M12-D wurde als Sensitive Content Representation Rules in
  `docs/world_design/274-sensitive-content-representation-rules.md`
  gestartet. Preview-Dateien liegen unter
  `docs/world_design/previews/phase2g_m12d_sensitive_content_rules/`.
  M12-D definiert erste Regeln fuer sensible, abstrakte und gesellschaftlich
  heikle Lerninhalte. Standardwege sind Codex, ContextCard, sanfter
  CompanionDialog, Backlog, RequiresUserChoice und BlockedUntilRules statt
  automatischer Gebaeude-, Symbol-, Objekt-, Reward- oder Retention-
  Darstellung. Daraus folgen keine finale Safety-Implementierung, keine
  Moderations-Implementierung, keine finale Datenstruktur, keine
  ThemeIsland-Umsetzung, keine Assetfreigabe, kein Code, kein Asset und kein
  `frame_started`.
- Phase 2G-M12-D2 wurde als visuelle Pruefung in
  `docs/world_design/275-sensitive-content-visual-review.md` gestartet.
  Ergebnis fuer den Review-Stand: M12-D ist als erste Sensitive-Content-
  Planungsrichtung grundsaetzlich brauchbar. Pipeline, Matrix, Beispielkarten
  und Blocked-Until-Rules Map zeigen, dass sensible Begriffe zuerst neutral
  geroutet werden und keine automatische Visualisierung, Gebaeude-/Symbol-/
  Assetproduktion, Reward-/Retention-Druck oder Beratungslogik ausloesen.
  Daraus folgen keine finale Safety-Implementierung, keine Moderations-
  Implementierung, keine finale Datenstruktur, keine sensible ThemeIsland-
  Umsetzung, keine Assetfreigabe, kein Code, kein Asset und kein
  `frame_started`.
- Phase 2G-M12-E wurde als Mobile And Clutter Rules For Small Objects in
  `docs/world_design/276-mobile-clutter-rules-small-objects.md` gestartet.
  Preview-Dateien liegen unter
  `docs/world_design/previews/phase2g_m12e_mobile_clutter_rules/`.
  M12-E definiert erste Planungsregeln fuer kleine Objekte, Deko,
  Container-Inhalte, Detailobjekte, Labels, Tap-Ziele und mobile Clutter-
  Grenzen. Daraus folgen keine finale Mobile-UI, keine finale Datenstruktur,
  keine Runtime-Konfiguration, keine Container-Implementierung, keine
  ThemeIsland-Umsetzung, keine Assetfreigabe, kein Code, kein Asset und kein
  `frame_started`.
- Phase 2G-M12-E2 wurde als visuelle Pruefung in
  `docs/world_design/277-mobile-clutter-visual-review.md` gestartet. Ergebnis
  fuer den Review-Stand: M12-E ist als erste Mobile-/Clutter-
  Planungsrichtung grundsaetzlich brauchbar. Ladder, Matrix, Container-
  Beispiele und Stop-Gates zeigen, dass TinyObjects nicht dauerhaft in
  IslandView gehoeren, Container keine Objektlisten sein duerfen, Labels nur
  kontextuell sichtbar sein sollen und Clutter-Risiko zu Zoom, Container,
  DetailInteractionView, Codex, Blueprint oder Backlog fuehrt. Daraus folgen
  keine finale Mobile-UI, keine finale Datenstruktur, keine Runtime-
  Konfiguration, keine Container-Implementierung, keine ThemeIsland-
  Umsetzung, keine App-/Assetfreigabe, kein Code und kein `frame_started`.
- Phase 2G-M12-F wurde als Consolidated Readiness Review in
  `docs/world_design/278-m12-consolidated-readiness-review.md` gestartet.
  M12-F prueft die komplette M12-Kette von ThemeIsland-Priorisierung,
  Word-to-Island Routing, Plot-Capabilities, Sensitive Content und
  Mobile/Clutter zusammen. Ergebnis fuer den Review-Stand: M12 bis M12-E2
  sind als konsolidierte Planungsgrundlage brauchbar. Daraus folgen keine
  finale ThemeIsland-Roadmap, keine finale Implementierungsfreigabe, keine
  finale Datenstruktur, keine Runtime-Konfiguration, keine App-/Assetfreigabe,
  kein Code und kein `frame_started`.
- Phase 2G-M13 wurde als ThemeIsland Roadmap Draft in
  `docs/world_design/279-theme-island-roadmap-draft.md` gestartet.
  Preview-Dateien liegen unter
  `docs/world_design/previews/phase2g_m13_theme_island_roadmap_draft/`.
  M13 ordnet ThemeIsland-Kandidaten in Foundation, Expansion Wave 1,
  Expansion Wave 2, System-Heavy Wave und Sensitive/Special Wave. Daraus
  folgen keine finale ThemeIsland-Roadmap, keine ThemeIsland-Umsetzung, keine
  Implementierungsfreigabe, keine finale Datenstruktur, keine Runtime-
  Konfiguration, keine App-/Assetfreigabe, kein Code und kein `frame_started`.
- Phase 2G-M13-A2 wurde als visuelle Pruefung des ThemeIsland Roadmap Drafts
  in `docs/world_design/280-theme-island-roadmap-visual-review.md` gestartet.
  Ergebnis fuer den Review-Stand: M13 ist als erster Roadmap-Draft brauchbar.
  Foundation, Expansion Wave 1, Expansion Wave 2, System-Heavy Wave und
  Sensitive/Special Wave sind verstaendlich. Daraus folgen keine finale
  ThemeIsland-Roadmap, keine finale Startinsel, keine ThemeIsland-Umsetzung,
  keine Implementierungsfreigabe, keine finale Datenstruktur, keine Runtime-
  Konfiguration, keine App-/Assetfreigabe, kein Code und kein `frame_started`.
- Phase 2G-M13-B wurde als Early Island Onboarding Choice Review in
  `docs/world_design/281-early-island-onboarding-choice-review.md` gestartet.
  Preview-Dateien liegen unter
  `docs/world_design/previews/phase2g_m13b_early_island_onboarding_choice/`.
  M13-B prueft, wie Nutzer zwischen Zuhause/Alltag, Schule/Lernen und
  Garten/Natur nah als Foundation-Fokus waehlen koennen, ohne Pflicht-
  Hausstart, finale Startinsel oder irreversible Erstwahl. Daraus folgen keine
  finale Onboarding-UI, keine finale Startinsel, keine ThemeIsland-Umsetzung,
  keine finale Datenstruktur, keine Runtime-Konfiguration, keine App-/
  Assetfreigabe, kein Code und kein `frame_started`.
- Phase 2G-M13-B2 wurde als visuelle Pruefung des Early Island Onboarding
  Choice Review in
  `docs/world_design/282-early-island-onboarding-choice-visual-review.md`
  gestartet. Ergebnis fuer den Review-Stand: M13-B ist als erste
  Onboarding-Choice-Planungsrichtung brauchbar; Hybrid wird als
  Planungsrichtung bestaetigt. Daraus folgen keine finale Onboarding-UI,
  keine finale Startinsel, keine Onboarding-Implementierung, keine
  ThemeIsland-Umsetzung, keine finale Datenstruktur, keine Runtime-
  Konfiguration, keine App-/Assetfreigabe, kein Code und kein `frame_started`.
- Phase 2G-M13-C wurde als ThemeIsland Capability Sheets in
  `docs/world_design/283-theme-island-capability-sheets.md` gestartet.
  M13-C konkretisiert ThemeIsland-Kandidaten nur als Planungsstruktur:
  Foundation-Sheets fuer Zuhause/Alltag, Schule/Lernen und Garten/Natur nah
  sowie kompaktere Sheets fuer Expansion Wave 1, Expansion Wave 2,
  System-Heavy und Sensitive/Special. Daraus folgen keine finale
  ThemeIsland-Roadmap, keine finale Startinsel, keine finale Onboarding-UI,
  keine ThemeIsland-Umsetzung, keine finale Datenstruktur, keine Runtime-
  Konfiguration, keine App-/Assetfreigabe, kein Code und kein `frame_started`.
- Phase 2G-M13-D wurde als Word-to-Island UX Flow in
  `docs/world_design/284-word-to-island-ux-flow.md` gestartet. M13-D plant
  nur den Nutzerfluss zwischen Wortaufnahme, Kontext/Sense, Safety, Worttyp,
  ThemeIsland-Kandidat, Depth-Kandidat, Nutzerentscheidung und Placement/
  Blueprint/Codex/Backlog. Daraus folgen keine finale Word-to-Island-
  Implementierung, keine finale Routing-Datenstruktur, keine Runtime-
  Konfiguration, keine automatische Wortplatzierung, keine ThemeIsland-
  Umsetzung, keine App-/Assetfreigabe, kein Code und kein `frame_started`.
- Phase 2G-M13-E wurde als Device And Accessibility Preview Plan in
  `docs/world_design/285-device-accessibility-preview-plan.md` gestartet.
  M13-E plant nur Pruefkategorien, Preview-Typen, Checklisten, harte Blocker
  und Freigabegrade fuer Device-, Accessibility-, Tap-Target-, Text-
  Containment- und Clutter-Pruefungen. Daraus folgen keine neuen PNGs, keine
  Tests, keine App-Integration, keine finale UI, keine finale Datenstruktur,
  keine Runtime-Konfiguration, keine App-/Assetfreigabe, kein Code und kein
  `frame_started`.
- Phase 2G-M13-F wurde als Container Pagination And Tap Target Rules in
  `docs/world_design/286-container-pagination-and-tap-target-rules.md`
  gestartet. M13-F plant nur Container-, Pagination-, Tap-Target-, Label-,
  Clutter- und QA-Overlay-Regeln fuer ContainerOpenView,
  DetailInteractionView und kleine Objektgruppen. Die Visualisierung bleibt
  textuell mit ASCII-Wireframes, Mermaid und Tabellen. Daraus folgen keine
  PNGs, keine Tests, keine App-Integration, keine finale UI, keine finale
  Datenstruktur, keine Runtime-Konfiguration, keine App-/Assetfreigabe, kein
  Code und kein `frame_started`.
- Phase 2G-M13-G wurde als Sensitive Content Policy Deepening in
  `docs/world_design/287-sensitive-content-policy-deepening.md` gestartet.
  M13-G vertieft nur Policy-, Routing-, Darstellungs-, Tali/Vori-, Privacy-
  und Gate-Regeln fuer sensible, abstrakte, medizinische, juristische,
  politische, religioese, gesellschaftliche und belastende Begriffe.
  Visualisierung bleibt textuell mit Mermaid, ASCII-Flows und Markdown-
  Matrizen. Daraus folgen keine PNGs, keine Tests, keine App-Integration,
  keine finale Safety-Implementierung, keine Moderations-Implementierung,
  keine finale Datenstruktur, keine Runtime-Konfiguration, keine App-/
  Assetfreigabe, kein Code und kein `frame_started`.
- Phase 2G-M13-H wurde als Growth And Timer Fairness Rules in
  `docs/world_design/288-growth-timer-fairness-rules.md` gestartet. M13-H
  vertieft nur Fairness-, Timer-, Growth-, Retention-, Tali/Vori- und
  Gate-Regeln fuer Wachstum, Garten-/Farm-Progression, Daily-Momente,
  Comebacks und Wartezeiten. Visualisierung bleibt textuell mit Mermaid,
  ASCII-Flows, Markdown-Tabellen, Fairness-/Timer-Matrizen und Decision-Flows.
  Daraus folgen keine PNGs, keine Tests, keine App-Integration, keine finale
  Growth-Implementierung, keine Timer-Implementierung, keine Retention-
  Implementierung, keine Monetarisierungsregel, keine finale Datenstruktur,
  keine Runtime-Konfiguration, keine App-/Assetfreigabe, kein Code und kein
  `frame_started`.
- Phase 2G-M13-I wurde als Asset Prioritization Scope Gate in
  `docs/world_design/289-asset-prioritization-scope-gate.md` gestartet. M13-I
  vertieft nur Asset-Priorisierung, Scope-Gates, Asset-Kategorien,
  Prioritaetslogik und Blocker. Visualisierung bleibt textuell mit Mermaid,
  ASCII-Flows, Markdown-Tabellen, Scope-/Asset-Matrizen und Gate-/Decision-
  Flows. Daraus folgen keine PNGs, keine Tests, keine App-Integration, keine
  Assetproduktion, keine finale Assetliste, keine finale Produktionsfreigabe,
  keine finale Datenstruktur, keine Runtime-Konfiguration, keine App-/
  Assetfreigabe, kein Code und kein `frame_started`.
- Phase 2G-M13-J wurde als Consolidated M13 Readiness Review in
  `docs/world_design/290-m13-consolidated-readiness-review.md` gestartet.
  M13-J prueft nur M13-B bis M13-I als zusammenhaengende Planungsgrundlage.
  Visualisierung bleibt textuell mit Mermaid, ASCII-Flows, Markdown-Tabellen,
  Readiness-Matrix und Gate-/Decision-Flows. Daraus folgen keine PNGs, keine
  Tests, keine App-Integration, keine Assetproduktion, keine finale Assetliste,
  keine finale Produktionsfreigabe, keine finale ThemeIsland-Roadmap, keine
  finale Startinsel, keine finale Onboarding-UI, keine finale Datenstruktur,
  keine Runtime-Konfiguration, keine App-/Assetfreigabe, kein Code und kein
  `frame_started`.
- Phase 2G-M13-K wurde als Early Onboarding Product Wireframe Plan in
  `docs/world_design/291-early-onboarding-product-wireframe-plan.md`
  gestartet. M13-K plant nur produktnahe mobile Wireframes und UX-Zustaende fuer
  den Foundation-Lernfokus. Visualisierung bleibt textuell mit
  ASCII-Wireframes, Mermaid-Flows, Markdown-Tabellen,
  Product-Wireframe-Beschreibungen und QA-/Device-Checklisten. Daraus folgen
  keine PNGs, keine Tests, keine App-Integration, keine finale Onboarding-UI,
  keine finale Startinsel, keine finale ThemeIsland-Roadmap, keine finale
  Datenstruktur, keine Runtime-Konfiguration, keine App-/Assetfreigabe, kein
  Code und kein `frame_started`.
- Phase 2G-M13-L wurde als Word-to-Island Product UX Preview Plan in
  `docs/world_design/292-word-to-island-product-ux-preview-plan.md` gestartet.
  M13-L plant nur produktnahe mobile UX-Wireframes und Zustaende fuer
  Word-to-Island. Visualisierung bleibt textuell mit ASCII-Wireframes,
  Mermaid-Flows, Markdown-Tabellen, Product-UX-Beschreibungen und QA-/Device-
  Checklisten. Daraus folgen keine PNGs, keine Tests, keine App-Integration,
  keine finale Word-to-Island-UI, keine finale Word-to-Island-Implementierung,
  keine finale Routing-Datenstruktur, keine Runtime-Konfiguration, keine
  automatische Wortplatzierung, keine App-/Assetfreigabe, kein Code und kein
  `frame_started`.
- Phase 2G-M13-M wurde als Container QA Overlay Preview Plan in
  `docs/world_design/293-container-qa-overlay-preview-plan.md` gestartet.
  M13-M plant nur QA-Overlay-, Container-, Tap-Zone-, Label-, Safe-Area-,
  Pagination- und Device-Pruefung fuer ContainerOpenView,
  DetailInteractionView und kleine Objektgruppen. Visualisierung bleibt
  textuell mit ASCII-Wireframes, ASCII-QA-Overlays, Mermaid-Flows,
  Markdown-Tabellen und QA-/Device-Checklisten. Daraus folgen keine PNGs,
  keine Tests, keine App-Integration, keine finale ContainerOpenView-UI,
  keine finale DetailInteractionView-UI, keine Container-Implementierung,
  keine finale Datenstruktur, keine Runtime-Konfiguration, keine
  App-/Assetfreigabe, kein Code und kein `frame_started`.
- Phase 2G-M13-N wurde als Foundation Choice Device Preview Plan in
  `docs/world_design/294-foundation-choice-device-preview-plan.md` gestartet.
  M13-N plant nur Device-, Safe-Area-, Tap-Zone-, Text-Containment-,
  Accessibility- und Layout-Pruefung fuer die Foundation Choice im Early
  Onboarding. Visualisierung bleibt textuell mit ASCII-Device-Wireframes,
  ASCII-Safe-Area-/Tap-Zone-Overlays, Mermaid-Flows, Markdown-Tabellen und
  Device-/Accessibility-/Text-Containment-Checklisten. Daraus folgen keine
  PNGs, keine Tests, keine App-Integration, keine finale Onboarding-UI, keine
  finale Foundation-Choice-UI, keine finale Startinsel, keine finale
  Datenstruktur, keine Runtime-Konfiguration, keine App-/Assetfreigabe, kein
  Code und kein `frame_started`.
- Phase 2G-M13-O wurde als ThemeIsland Roadmap Scope Freeze Review in
  `docs/world_design/295-theme-island-roadmap-scope-freeze-review.md`
  gestartet. M13-O prueft nur, ob die Roadmap als nicht-finale
  Planungsgrundlage eingefroren werden kann. Visualisierung bleibt textuell
  mit Mermaid-Flows, ASCII-Gate-Flows, Markdown-Tabellen,
  Scope-Freeze-Matrizen und Decision-/Readiness-Maps. Daraus folgen keine
  PNGs, keine Tests, keine App-Integration, keine finale ThemeIsland-Roadmap,
  keine finale Startinsel, keine finale Onboarding-UI, keine finale
  Foundation-Choice-UI, keine finale Datenstruktur, keine
  Runtime-Konfiguration, keine App-/Assetfreigabe, kein Code und kein
  `frame_started`.
- Phase 2G-M13-P wurde als Implementation Candidate Gate in
  `docs/world_design/296-implementation-candidate-gate.md` gestartet. M13-P
  prueft nur, ob spaetere Product-/Review-Harness-/Implementation-Kandidaten
  denkbar sind. Visualisierung bleibt textuell mit Mermaid-Flows,
  ASCII-Gate-Flows, Markdown-Tabellen, Implementation-Readiness-Matrizen und
  Decision-/Blocker-Maps. Daraus folgen keine PNGs, keine Tests, keine
  App-Integration, keine finale Implementierungsfreigabe, keine finale
  ThemeIsland-Roadmap, keine finale Startinsel, keine finale Onboarding-UI,
  keine finale Foundation-Choice-UI, keine finale Word-to-Island-UI, keine
  finale Container-UI, keine finale Datenstruktur, keine Runtime-Konfiguration,
  keine App-/Assetfreigabe, kein Code und kein `frame_started`.
- M14-A wurde als Foundation Choice Product Preview Plan in
  `docs/world_design/297-foundation-choice-product-preview-plan.md` gestartet.
  M14-A plant nur produktnahe Preview-Zustaende, Copy-Regeln, Product-Flow und
  ASCII-Product-Previews fuer die Foundation Choice. Visualisierung bleibt
  textuell mit ASCII-Product-Wireframes, ASCII-Mobile-Frames,
  ASCII-State-Previews, Mermaid-Flows, Markdown-Tabellen und Product-/Device-/
  Accessibility-Checklisten. Daraus folgen keine PNGs, keine Tests, keine
  App-Integration, keine finale Foundation-Choice-UI, keine finale
  Onboarding-UI, keine finale Startinsel, keine finale ThemeIsland-Roadmap,
  keine finale Datenstruktur, keine Runtime-Konfiguration, keine
  App-/Assetfreigabe, keine Implementierungsfreigabe, kein Code und kein
  `frame_started`.
- M14-A2 wurde als Foundation Choice Product Preview Visual Review in
  `docs/world_design/298-foundation-choice-product-preview-visual-review.md`
  gestartet. M14-A2 prueft nur M14-A visuell/textuell gegen Product-Flow,
  Copy, Product-States, Device-/Accessibility-Regeln und Guardrails.
  Visualisierung bleibt textuell mit ASCII-Review-Overlays,
  ASCII-Mobile-Frames, ASCII-State-Review-Skizzen, Mermaid-Flows,
  Markdown-Tabellen und Product-/Device-/Accessibility-Review-Checklisten.
  Daraus folgen keine PNGs, keine Tests, keine App-Integration, keine finale
  Foundation-Choice-UI, keine finale Onboarding-UI, keine finale Startinsel,
  keine finale Datenstruktur, keine Runtime-Konfiguration, keine
  App-/Assetfreigabe, keine Implementierungsfreigabe, kein Code und kein
  `frame_started`.
- M14-B wurde als Word-to-Island Product Preview Plan in
  `docs/world_design/299-word-to-island-product-preview-plan.md` gestartet.
  M14-B plant nur produktnahe Preview-Zustaende, Copy-Regeln, Product-Flow und
  ASCII-Product-Previews fuer Word-to-Island. Visualisierung bleibt textuell
  mit ASCII-Product-Wireframes, ASCII-Mobile-Frames, ASCII-State-Previews,
  Mermaid-Flows, Markdown-Tabellen und Product-/Device-/Accessibility-
  Checklisten. Daraus folgen keine PNGs, keine Tests, keine App-Integration,
  keine finale Word-to-Island-UI, keine finale Word-to-Island-Implementierung,
  keine finale Routing-Datenstruktur, keine Runtime-Konfiguration, keine
  automatische Wortplatzierung, keine App-/Assetfreigabe, keine
  Implementierungsfreigabe, kein Code und kein `frame_started`.
- M14-B2 wurde als Word-to-Island Product Preview Visual Review in
  `docs/world_design/300-word-to-island-product-preview-visual-review.md`
  gestartet. M14-B2 prueft nur M14-B visuell/textuell gegen Product-Flow,
  Sense-/Route-Logik, Safety-/Clutter-Regeln, Copy, Product-States,
  Device-/Accessibility-Regeln und Guardrails. Visualisierung bleibt textuell
  mit ASCII-Review-Overlays, ASCII-Mobile-Frames,
  ASCII-State-Review-Skizzen, Mermaid-Flows, Markdown-Tabellen und Product-/
  Device-/Accessibility-Review-Checklisten. Daraus folgen keine PNGs, keine
  Tests, keine App-Integration, keine finale Word-to-Island-UI, keine
  Word-to-Island-Implementierung, keine finale Routing-Datenstruktur, keine
  Runtime-Konfiguration, keine automatische Wortplatzierung, keine
  App-/Assetfreigabe, keine Implementierungsfreigabe, kein Code und kein
  `frame_started`.
- M14-C wurde als Container QA Product Preview Plan in
  `docs/world_design/301-container-qa-product-preview-plan.md` gestartet.
  M14-C plant nur produktnahe Preview-Zustaende, Copy-Regeln, Product-Flow,
  ASCII-Product-Previews und QA-Zonen fuer `ContainerOpenView`,
  `DetailInteractionView` und kleine Objektgruppen. Visualisierung bleibt
  textuell mit ASCII-Product-Wireframes, ASCII-QA-Overlays,
  ASCII-Mobile-Frames, Mermaid-Flows, Markdown-Tabellen und Product-/Device-/
  Accessibility-/QA-Checklisten. Daraus folgen keine PNGs, keine Tests, keine
  App-Integration, keine finale ContainerOpenView-UI, keine finale
  DetailInteractionView-UI, keine Container-Implementierung, keine finale
  Datenstruktur, keine Runtime-Konfiguration, keine App-/Assetfreigabe, keine
  Implementierungsfreigabe, kein Code und kein `frame_started`.
- M14-C2 wurde als Container QA Product Preview Visual Review in
  `docs/world_design/302-container-qa-product-preview-visual-review.md`
  gestartet. M14-C2 prueft nur M14-C visuell/textuell gegen Product-Wirkung,
  Beispielpfade, QA-Zonen, Copy-Regeln, Product-States,
  Device-/Accessibility-Regeln und Guardrails. Visualisierung bleibt textuell
  mit ASCII-Review-Overlays, ASCII-Mobile-Frames,
  ASCII-State-Review-Skizzen, Mermaid-Flows, Markdown-Tabellen und Product-/
  Device-/Accessibility-/QA-Review-Checklisten. Daraus folgen keine PNGs,
  keine Tests, keine App-Integration, keine finale ContainerOpenView-UI, keine
  finale DetailInteractionView-UI, keine Container-Implementierung, keine
  finale Datenstruktur, keine Runtime-Konfiguration, keine App-/Assetfreigabe,
  keine Implementierungsfreigabe, kein Code und kein `frame_started`.
- M14-D wurde als Device/Accessibility Review Harness Plan in
  `docs/world_design/303-device-accessibility-review-harness-plan.md`
  gestartet. M14-D plant nur spaetere Review-Harness-Pruefungen fuer Device,
  Accessibility, Text-Containment, Tap-Ziele, Safe Areas, Companion Collision,
  Pagination und Guardrail Copy. Visualisierung bleibt textuell mit
  ASCII-Harness-Flows, ASCII-Device-Frames, ASCII-QA-Check-Overlays,
  Mermaid-Flows, Markdown-Tabellen und Device-/Accessibility-/Tap-Target-/
  Text-Containment-Checklisten. Daraus folgen keine PNGs, keine Screenshots,
  keine Tests, keine Widget-Tests, keine Test-Harness-Implementierung, keine
  Flutter-/Dart-Dateien, keine App-Integration, keine finale UI, keine finale
  Datenstruktur, keine Runtime-Konfiguration, keine App-/Assetfreigabe, keine
  Implementierungsfreigabe, kein Code und kein `frame_started`.
- M14-D2 wurde als Device/Accessibility Review Harness Visual Review in
  `docs/world_design/304-device-accessibility-review-harness-visual-review.md`
  gestartet. M14-D2 prueft nur M14-D visuell/textuell gegen Coverage,
  Device-/Accessibility-Kategorien, ASCII-Harness-Frames, Harness-States,
  Runtime-Misread-Prevention und Guardrails. Visualisierung bleibt textuell
  mit ASCII-Review-Overlays, ASCII-Device-Frames,
  ASCII-Harness-Review-Skizzen, Mermaid-Flows, Markdown-Tabellen und Device-/
  Accessibility-/Tap-Target-/Text-Containment-Review-Checklisten. Daraus
  folgen keine PNGs, keine Screenshots, keine Tests, keine Widget-Tests, keine
  Test-Harness-Implementierung, keine Flutter-/Dart-Dateien, keine
  App-Integration, keine finale UI, keine finale Datenstruktur, keine
  Runtime-Konfiguration, keine App-/Assetfreigabe, keine
  Implementierungsfreigabe, kein Code und kein `frame_started`.
- M14-E wurde als Small Implementation Slice Candidate Review in
  `docs/world_design/305-small-implementation-slice-candidate-review.md`
  gestartet. M14-E prueft nur, ob spaetere kleine Slices denkbar waeren.
  Visualisierung bleibt textuell mit ASCII-Gate-Flows,
  ASCII-Decision-Maps, Mermaid-Flows, Markdown-Tabellen und Readiness-/
  Blocker-/Scope-Matrizen. Daraus folgen keine PNGs, keine Screenshots, keine
  Tests, keine Widget-Tests, keine Test-Harness-Implementierung, keine
  Flutter-/Dart-Dateien, keine App-Integration, keine finale UI, keine finale
  Datenstruktur, keine Runtime-Konfiguration, keine App-/Assetfreigabe, keine
  Implementierungsfreigabe, kein Code, keine automatische Wortplatzierung und
  kein `frame_started`.
- M14-E2 wurde als Small Implementation Slice Candidate Visual Review in
  `docs/world_design/306-small-implementation-slice-candidate-visual-review.md`
  gestartet. M14-E2 prueft nur M14-E visuell/textuell gegen Readiness-Level,
  Minimal-Slice-Kriterien, Kandidatenmatrix, Gate-Visualisierungen,
  `frame_started`-Blockade, Harness-Gates und Misread-Risiken. Visualisierung
  bleibt textuell mit ASCII-Review-Flows, ASCII-Decision-Maps, Mermaid-Flows,
  Markdown-Tabellen und Readiness-/Blocker-/Scope-Matrizen. Daraus folgen
  keine PNGs, keine Screenshots, keine Tests, keine Widget-Tests, keine
  Test-Harness-Implementierung, keine Flutter-/Dart-Dateien, keine
  App-Integration, keine finale UI, keine finale Datenstruktur, keine
  Runtime-Konfiguration, keine App-/Assetfreigabe, keine
  Implementierungsfreigabe, kein Code, keine automatische Wortplatzierung und
  kein `frame_started`.
- M14-V1 wurde als Visual Backfill For Docs 283-306 in
  `docs/world_design/307-visual-backfill-283-306.md` gestartet. Echte PNG-
  Dokumentationsvisualisierungen fuer `283` bis `306` wurden unter
  `docs/world_design/previews/m14_visual_backfill_283_306/` ergaenzt. Diese
  PNGs sind Dokumentationspreviews, keine finale UI, keine App-Screens und
  keine Spielassets. Daraus folgen keine App-Integration, keine
  Flutter-/Dart-Dateien, keine Tests, keine Widget-Tests, keine Screenshots,
  keine Asset-Dateien unter `assets/`, keine Runtime-Konfiguration, keine
  App-/Assetfreigabe, keine Implementierungsfreigabe und kein `frame_started`.
- M14-V1-B wurde als Visual Backfill Quality Review in
  `docs/world_design/308-visual-backfill-quality-review.md` gestartet. M14-V1-B
  prueft nur die bestehenden PNG-Dokumentationspreviews aus M14-V1 auf
  Lesbarkeit, Text-Containment, Footer-/Titel-Sichtbarkeit, Ueberladung,
  Preview-Status und Misread-Risiken. Daraus folgen keine neuen PNGs, keine
  PNG-Aenderungen, keine Screenshots, keine Tests, keine Widget-Tests, keine
  Flutter-/Dart-Dateien, keine App-Integration, keine Spielassets, keine
  Asset-Dateien unter `assets/`, keine finale UI, keine Runtime-Konfiguration,
  keine Implementierungsfreigabe, kein Code und kein `frame_started`.
- M15-A wurde als Foundation Choice Implementation Gate in
  `docs/world_design/309-foundation-choice-implementation-gate.md` gestartet.
  M15-A prueft nur, ob ein spaeterer minimaler Foundation-Choice-Slice als
  lokale, nicht persistente, nicht finale Product Preview denkbar waere. Daraus
  folgen keine neuen PNGs, keine PNG-Aenderungen, keine Screenshots, keine
  Tests, keine Widget-Tests, keine Flutter-/Dart-Dateien, keine
  App-Integration, keine finale UI, keine Runtime-Konfiguration, keine
  Persistenz, keine Supabase Writes, keine SRS-/`word_progress`-Aenderung,
  keine Reward Bridge, keine App-/Assetfreigabe, keine Implementierungsfreigabe,
  kein Code, keine automatische Wortplatzierung und kein `frame_started`.
- M15-A2 wurde als Foundation Choice Minimal Slice Implementation Prompt Draft
  in `docs/world_design/310-foundation-choice-minimal-slice-prompt-draft.md`
  gestartet. M15-A2 erstellt nur einen spaeteren Implementierungs-Prompt als
  Dokument und fuehrt ihn nicht aus. Daraus folgen keine Implementierung, keine
  Flutter-/Dart-Dateien, keine Tests, keine Widget-Tests, keine App-Integration,
  keine finale UI, keine Runtime-Konfiguration, keine Persistenz, keine
  Supabase Writes, keine SRS-/`word_progress`-Aenderung, keine Reward Bridge,
  keine PNGs, keine PNG-Aenderungen, keine Screenshots, keine Assets, keine
  App-/Assetfreigabe, keine Implementierungsfreigabe, kein Code, keine
  automatische Wortplatzierung und kein `frame_started`.
- M15-A3 wurde als Foundation Choice Prompt Visual Review in
  `docs/world_design/311-foundation-choice-prompt-visual-review.md` gestartet.
  M15-A3 prueft nur den Prompt-Draft aus M15-A2 und erzeugt PNG-
  Dokumentationspreviews unter
  `docs/world_design/previews/m15_a3_foundation_choice_prompt_visual_review/`.
  Daraus folgen keine Implementierung, keine Flutter-/Dart-Dateien, keine
  Tests, keine Widget-Tests, keine App-Integration, keine finale UI, keine
  Runtime-Konfiguration, keine Persistenz, keine Supabase Writes, keine SRS-/
  `word_progress`-Aenderung, keine Reward Bridge, keine Screenshots, keine
  Spielassets, keine Asset-Dateien unter `assets/`, keine App-/Assetfreigabe,
  keine Implementierungsfreigabe, kein Code, keine automatische Wortplatzierung
  und kein `frame_started`.
- M15-A4 wurde als Foundation Choice Final Pre-Implementation Checklist in
  `docs/world_design/312-foundation-choice-final-pre-implementation-checklist.md`
  gestartet. M15-A4 prueft nur, ob ein spaeterer Minimal-Slice bereit fuer
  ausdrueckliche Nutzerfreigabe waere. Daraus folgen keine Implementierung,
  keine Flutter-/Dart-Dateien, keine Tests, keine Widget-Tests, keine
  App-Integration, keine finale UI, keine Runtime-Konfiguration, keine
  Persistenz, keine Supabase Writes, keine SRS-/`word_progress`-Aenderung,
  keine Reward Bridge, keine PNGs, keine PNG-Aenderungen, keine Screenshots,
  keine Assets, keine App-/Assetfreigabe, keine Implementierungsfreigabe, kein
  Code, keine automatische Wortplatzierung und kein `frame_started`.
- M15-B wurde als Foundation Choice Preview Code Review und Visual Harness Plan
  in `docs/world_design/313-foundation-choice-preview-code-review.md`
  gestartet. M15-B prueft nur den isolierten Preview-Code in
  `lib/features/world/local_world/ui/widgets/foundation_choice_preview.dart`
  gegen den freigegebenen Minimal-Scope und plant einen spaeteren Visual
  Harness ohne Umsetzung. Eine PNG-Dokumentationspreview liegt unter
  `docs/world_design/previews/m15_b_foundation_choice_code_review/`. Daraus
  folgen keine App-Integration, keine Home-/Onboarding-/World-Routing-
  Integration, keine Persistenz, keine Runtime-Konfiguration, keine Tests,
  keine Widget-Tests, keine Screenshots, keine Assets, keine App-/
  Assetfreigabe, keine automatische Wortplatzierung und kein `frame_started`.
- M15-C wurde als Foundation Choice Local Preview Harness Gate in
  `docs/world_design/314-foundation-choice-local-preview-harness-gate.md`
  gestartet. M15-C prueft nur, ob ein spaeterer isolierter lokaler Preview-
  Harness fuer `FoundationChoicePreview` denkbar waere. PNG-
  Dokumentationspreviews liegen unter
  `docs/world_design/previews/m15_c_foundation_choice_local_preview_harness_gate/`.
  Daraus folgen keine Flutter-/Dart-Dateien, keine App-Integration, keine
  Home-/Onboarding-/World-Routing-Integration, keine Tests, keine Widget-
  Tests, keine Screenshots, keine Runtime-Konfiguration, keine Persistenz,
  keine Assets, keine automatische Wortplatzierung und kein `frame_started`.
- M15-D wurde als Foundation Choice Local Preview Harness Implementation Gate
  in
  `docs/world_design/315-foundation-choice-local-preview-harness-implementation-gate.md`
  gestartet. M15-D prueft nur, ob ein spaeterer isolierter Harness-Slice
  freigabefaehig waere. PNG-Dokumentationspreviews liegen unter
  `docs/world_design/previews/m15_d_foundation_choice_harness_implementation_gate/`.
  Daraus folgen keine Flutter-/Dart-Dateien, keine App-Integration, keine
  Home-/Onboarding-/World-Routing-Integration, keine Tests, keine Widget-
  Tests, keine Screenshots, keine Runtime-Konfiguration, keine Persistenz,
  keine Assets, keine automatische Wortplatzierung und kein `frame_started`.
- M15-D2 wurde als Foundation Choice Harness Implementation Prompt Draft in
  `docs/world_design/316-foundation-choice-harness-implementation-prompt-draft.md`
  gestartet. M15-D2 erstellt nur einen spaeteren Implementierungs-Prompt als
  Dokument und ergaenzt PNG-Dokumentationspreviews unter
  `docs/world_design/previews/m15_d2_foundation_choice_harness_prompt_draft/`.
  Daraus folgen keine Harness-Implementierung, keine Flutter-/Dart-Dateien,
  keine App-Integration, keine Home-/Onboarding-/World-Routing-Integration,
  keine Tests, keine Widget-Tests, keine Screenshots, keine Runtime-
  Konfiguration, keine Persistenz, keine Assets, keine automatische
  Wortplatzierung und kein `frame_started`.
- M16-A wurde als First World Element Slice Scope And Visual Plan in
  `docs/world_design/317-first-world-element-slice-scope-and-visual-plan.md`
  gestartet. Ziel ist ein schnellerer, aber sicherer Schritt Richtung
  sichtbares Welt-Element. Empfehlung: naechster moeglicher Code-Kandidat ist
  ein neutraler lokaler Plot-Marker, nicht Foundation Choice als Bau-Menue.
  PNG-Dokumentationspreviews liegen unter
  `docs/world_design/previews/m16_a_first_world_element_slice/`. Daraus
  folgen keine Flutter-/Dart-Dateien, keine App-Integration, keine Tests, keine
  Screenshots, keine Runtime-Konfiguration, keine Persistenz, keine Assets,
  keine automatische Wortplatzierung und kein `frame_started`.
- M16-I wurde als Theme Island Plot Capacity And In-Place Build Wheel Plan in
  `docs/world_design/318-theme-island-plot-capacity-and-build-wheel-plan.md`
  gestartet. Ziel ist, Inselgroesse, Grundstuecksanzahl und
  Grundstuecksgroessen aus dem Theme-Bedarf abzuleiten. Der In-Place
  Build-Wheel bleibt nur Overlay-/Popup-Planung. PNG-
  Dokumentationspreviews liegen unter
  `docs/world_design/previews/m16_i_theme_island_plot_capacity_build_wheel/`.
  Daraus folgen keine Flutter-/Dart-Dateien, keine App-Integration, keine
  Route, keine neue Seite, keine Tests, keine Screenshots, keine Runtime-
  Konfiguration, keine Persistenz, keine Assets, keine automatische
  Wortplatzierung, kein Build-State und kein `frame_started`.
- M16-J wurde als Village Plot Capacity Local Preview Scope in
  `docs/world_design/319-village-plot-capacity-local-preview-scope.md`
  gestartet. Ziel ist, aus M16-I einen spaeteren lokalen Multi-Slot-Preview-
  Slice fuer Dorf/Zuhause/Alltag abzuleiten. PNG-Dokumentationspreviews liegen
  unter
  `docs/world_design/previews/m16_j_village_plot_capacity_local_preview/`.
  Daraus folgen keine Flutter-/Dart-Dateien, keine App-Integration, keine
  Route, keine neue Seite, keine Build-Wheel-Implementierung, keine Tests,
  keine Screenshots, keine Runtime-Konfiguration, keine Persistenz, keine
  Assets, keine automatische Wortplatzierung, kein Build-State und kein
  `frame_started`.
- M16-K wurde als Global ThemeIsland Category Plot Capacity Matrix in
  `docs/world_design/320-global-theme-island-plot-capacity-matrix.md`
  gestartet. Ziel ist, alle bereits dokumentierten Kategorien aus Taxonomy,
  Priorisierung, Routing, Plot-Capability und Roadmap einzusammeln und in
  globale Plot-Capacity-Profile zu ueberfuehren. M16-J bleibt nur ein enges
  Dorf-/Zuhause-/Alltag-Beispiel, nicht die globale Grundlage. PNG-
  Dokumentationspreviews liegen unter
  `docs/world_design/previews/m16_k_global_theme_island_plot_capacity_matrix/`.
  Daraus folgen keine Flutter-/Dart-Dateien, keine App-Integration, keine
  Route, keine neue Seite, keine Build-Wheel-Implementierung, keine Tests,
  keine Screenshots, keine Runtime-Konfiguration, keine Persistenz, keine
  Assets, keine automatische Wortplatzierung, kein Build-State und kein
  `frame_started`.
- M16-L wurde als Global World Semantics Consistency Audit in
  `docs/world_design/321-global-world-semantics-consistency-audit.md`
  gestartet. Ziel ist, bestehende Regeln aus Taxonomy, Word-to-Island-
  Routing, Plot-Capabilities, Sensitive Policy, Mobile-/Clutter-Regeln,
  Depth-/Container-Regeln, Asset-Scope sowie M16-I/J/K zu konsolidieren.
  Kuenftige Prompts muessen M16-L als Pflicht-Check beruecksichtigen, damit
  Multi-Home-Woerter, Word-Type-Routing, Codex/Blueprint/Backlog-Fallbacks,
  Sensitive-/Abstract-/Emotion-/Action-Regeln und Stop-Regeln nicht
  vergessen werden. PNG-Dokumentationspreviews liegen unter
  `docs/world_design/previews/m16_l_global_world_semantics_consistency_audit/`.
  Daraus folgen keine Flutter-/Dart-Dateien, keine App-Integration, keine
  Route, keine Tests, keine Screenshots, keine Runtime-Konfiguration, keine
  Persistenz, keine Assets, keine automatische Wortplatzierung, kein
  Build-State und kein `frame_started`.
- M16-M wurde als Next Safe Preview Slice Decision Gate in
  `docs/world_design/322-next-safe-preview-slice-decision-gate.md`
  gestartet. Ziel ist, nach M16-I/J/K/L den naechsten kleinen lokalen Preview-
  Slice zu entscheiden, ohne wieder zu frueh auf Dorf/Zuhause, Water/Dock,
  Onboarding oder Build-Wheel zu verengen. Entscheidung: Als naechster
  Preview-Kandidat wird `WordSemanticsDecisionPreview` empfohlen, weil er
  M16-L sichtbar macht und automatische Wortplatzierung, falsche Build-State-
  Ableitung und zu fruehe Kategorie-/Plot-Konkretisierung am besten
  verhindert. PNG-Dokumentationspreviews liegen unter
  `docs/world_design/previews/m16_m_next_safe_preview_slice_decision_gate/`.
  Daraus folgen keine Flutter-/Dart-Dateien, keine App-Integration, keine
  Route, keine Tests, keine Screenshots, keine Runtime-Konfiguration, keine
  Persistenz, keine Assets, keine automatische Wortplatzierung, kein
  Build-State und kein `frame_started`.
- Der naechste Blocker betrifft die Pruefung dieser flexiblen
  Plot-/Learning-Semantics-Planung und ihrer M6-B-/M6-C-/M6-D-/M6-E-/M6-F-
  Entscheidungslogik sowie der M7-C-, M8-, M9-, M9-B-, M10-, M10-D-, M10-B-
  M10-B2-, M10-C-, M10-C2-, M11-, M11-B-, M11-C-, M11-C2-, M12-, M12-A2- und
  M12-B-/M12-B2-/M12-C-/M12-C2-/M12-D-/M12-D2-/M12-E-/M12-E2-/M12-F-,
  M13-, M13-A2-, M13-B-, M13-B2-, M13-C-, M13-D-, M13-E- und
  M13-F-/M13-G-/M13-H-/M13-I-/M13-J-/M13-K-/M13-L-/M13-M-/M13-N-/
  M13-O-/M13-P-/M14-A-/M14-A2-/M14-B-/M14-B2-/M14-C-/M14-C2-/M14-D-/
  M14-D2-/M14-E-/M14-E2-/M14-V1-Bewertung.
  Danach duerfen nur M7-B als technische Debug-Greybox bestaetigt, gezielt
  nachgebessert, M9 als erster Beispiel-Flow dokumentarisch bestaetigt, M10
  als emotionalere Produktflow-Preview dokumentarisch bestaetigt, M10-B als
  erste Challenge-Empfehlung dokumentarisch bestaetigt, M10-C als erste
  Companion-Reaktionsrichtung dokumentarisch bestaetigt, M11 als Multi-Flow-
  Richtung dokumentarisch bestaetigt, der World-Content-Katalog als erste
  Content-/Location-Grundlage bestaetigt, M12/M12-A2 als erste ThemeIsland-
  Priorisierung dokumentarisch bestaetigt, M12-B als erste Routing-Matrix
  dokumentarisch geprueft, M12-B2 als erste Routing-Planungsrichtung
  dokumentarisch bestaetigt, M12-C als erste Plot-Capability-Ableitung
  dokumentarisch geprueft, M12-C2 als erste Plot-Capability-Planungsrichtung
  dokumentarisch bestaetigt, M12-D als Sensitive-Content-Regelgrundlage
  dokumentarisch geprueft, M12-D2 als erste Sensitive-Content-
  Planungsrichtung dokumentarisch bestaetigt, M12-E als Mobile-/Clutter-
  Regelgrundlage dokumentarisch geprueft, M12-E2 als erste Mobile-/Clutter-
  Planungsrichtung dokumentarisch bestaetigt, M12-F als konsolidierte
  M12-Planungsgrundlage dokumentarisch bestaetigt, M13 als nicht-finaler
  ThemeIsland-Roadmap-Draft dokumentarisch geprueft, M13-A2 als erster
  Roadmap-Draft dokumentarisch bestaetigt, M13-B als Early-Island-
  Onboarding-Choice-Planung dokumentarisch geprueft, M13-B2 als erste
  Onboarding-Choice-Planungsrichtung dokumentarisch bestaetigt, M13-C als
  ThemeIsland-Capability-Sheet-Planung dokumentarisch geprueft, M13-D als
  Word-to-Island-UX-Flow dokumentarisch geprueft, M13-E als Device-/
  Accessibility-Preview-Pruefplan dokumentarisch geprueft, M13-F als
  Container-Pagination-/Tap-Target-Regelplan dokumentarisch geprueft,
  M13-G als Sensitive-Content-Policy-Vertiefung dokumentarisch geprueft,
  M13-H als Growth-/Timer-Fairness-Regelplan dokumentarisch geprueft, M13-I
  als Asset-Prioritization-/Scope-Gate-Planung dokumentarisch geprueft, M13-J
  als konsolidierte M13-Readiness-Grundlage dokumentarisch bestaetigt, M13-K
  als Early-Onboarding-Wireframe-Plan dokumentarisch geprueft, M13-L als
  Word-to-Island-Product-UX-Preview-Plan dokumentarisch geprueft, M13-M als
  Container-QA-Overlay-Preview-Plan dokumentarisch geprueft, M13-N als
  Foundation-Choice-Device-Preview-Plan dokumentarisch geprueft, M13-O als
  nicht-finaler ThemeIsland-Roadmap-Scope-Freeze dokumentarisch geprueft,
  M13-P als Implementation-Candidate-Gate dokumentarisch geprueft oder konkrete
  M14-A-Foundation-Choice-Product-Preview-Planung dokumentarisch geprueft,
  M14-A2-Foundation-Choice-Product-Preview-Review dokumentarisch bestaetigt,
  M14-B-Word-to-Island-Product-Preview-Planung dokumentarisch geprueft,
  M14-B2-Word-to-Island-Product-Preview-Review dokumentarisch bestaetigt,
  M14-C-Container-QA-Product-Preview-Planung dokumentarisch geprueft,
  M14-C2-Container-QA-Product-Preview-Review dokumentarisch bestaetigt,
  M14-D-Device-/Accessibility-Review-Harness-Planung dokumentarisch geprueft,
  M14-D2-Device-/Accessibility-Review-Harness-Review dokumentarisch
  bestaetigt,
  M14-E-Small-Implementation-Slice-Candidate-Review dokumentarisch geprueft,
  M14-E2-Small-Implementation-Slice-Candidate-Visual-Review dokumentarisch
  bestaetigt,
  M14-V1-Visual-Backfill fuer Dokumente 283-306 dokumentarisch geprueft,
  nachgebessert oder konkrete Taxonomy-/Routing-/Safety-/Mobile-/Accessibility-/ThemeIsland-/
  Asset-Scope-/Readiness-/Onboarding-/Word-to-Island-/Container-QA-Follow-ups
  geplant werden.
  Offen bleiben ThemeIsland-Roadmap, Mobile-Lesbarkeit, Inselkapazitaet,
  Depth-UX,
  Phase-2G-Code und jede groessere Bau-, Lern-, Reward-,
  Persistenz-, Sound-/FX- oder Expansion-Architektur.

Interpretation:

Talvori hat eine starke Weltbasis als Preview- und Auswahlwelt. Phase 2E-E
beweist als lokaler Proof-of-Concept, dass freigegebene buildable Assets,
Layering, lokaler BuildState und einfache Nutzerfuehrung zusammen funktionieren.
Der naechste Schritt darf daraus aber noch keine vollstaendige Bau-, Lern-,
Reward- oder Persistenzarchitektur ableiten.

## 4. Aktueller Hauptblocker

Hauptblocker:

Phase 2F ist abgeschlossen. Phase 2G `frame_started` ist vollstaendig
gestoppt. Der geloeschte `frame_started.png`-Kandidat war nicht freigegeben.
Einzelne Bauzustaende duerfen nicht weitergebaut werden, solange die
Waldlichtung nicht als `IslandMasterLayout` mit modularen Plot-Flaechen,
ConnectionSockets, BuildAnchors, PathAnchors, DecorationAnchors,
ExpansionSockets und FootprintPolygons geplant ist. Vor jeder weiteren
Asset-Erzeugung muessen Plot-Typ, Anchor, Footprint und Anschlusskonzept
feststehen. Code braucht danach eine eigene Freigabe und erneute Gates.

Vor jedem Phase-2G-Code oder jedem Ausbau ausserhalb des abgeschlossenen
lokalen Phase-2F-Mock-Slices muss erneut geprueft werden:

- Professional Game Development Research Gate,
- Build-Feedback-Konzept,
- Asset-Produktionsregeln,
- State-/Modulsystem,
- Scale-/Dimension-Regeln,
- keine Erweiterung des Scopes ohne Dokumentation.

Die abgeschlossenen Freigaben aus Phase 2E-D/2E-E und Phase 2F gelten nur fuer
die kleinen lokalen Mock-Slices: Waldlichtung, `main_build_area`, lokaler
Zustand `empty -> foundation_started -> foundation_complete` und lokale Anzeige
von `base.png` + `foundation_started.png` oder `base.png` +
`foundation_complete.png`.

## 5. Roadmap Phasen

| Phase | Aufgabe | Status | Ziel / Gate |
| --- | --- | --- | --- |
| Phase 2E-A | Buildable Waldlichtung Asset-Konzept | `fertig` | Konzept in `docs/world_design/236-buildable-forest-clearing-template-concept.md` dokumentiert. |
| Phase 2E-A2 | Buildable Waldlichtung Greybox/Layout | `fertig` | Funktionales Layout in `docs/world_design/237-buildable-forest-clearing-greybox-layout.md` dokumentiert. |
| Phase 2E-A3 | Multi-Scale World/Interior System | `fertig` | Detailstufen in `docs/world_design/238-multi-scale-world-and-interior-system.md` dokumentiert. |
| Phase 2E-A4 | World Scale and Dimension Rules | `fertig` | Massstab, Footprints und Referenzobjekte in `docs/world_design/239-world-scale-and-dimension-rules.md` dokumentiert. |
| Phase 2E-A5 | Private Island State System | `fertig` | State-/Modulsystem in `docs/world_design/240-private-island-state-system.md` dokumentiert. |
| Phase 2E-A6 | Build Feedback Animation/Sound | `fertig` | Build-Feedback, minimale Animation, vorbereitete Effekt-ID und Sound-Grenzen in `docs/world_design/241-build-feedback-animation-and-sound.md` dokumentiert. |
| Phase 2E-B | Asset-Erzeugung Waldlichtung buildable base | `generiert / in Pruefung` | Base-Asset existiert und ist in `template.md` dokumentiert; Device-Check und finale Freigabe fehlen. |
| Phase 2E-C | Asset-Erzeugung `foundation_started` Overlay | `generiert / vorgeprueft` | Overlay existiert und wurde visuell auf `base.png` geprueft; Device-Check und Freigabe fehlen. |
| Phase 2E-D | Asset-/Metadatenpruefung auf Geraet | `freigegeben` | Isolierter Widget-Test-Harness und temporaere visuelle Preview sind brauchbar; Anker-/Bounds-Werte sind dokumentiert; Freigabe gilt nur fuer den kleinen Phase-2E-E-Mock-Slice. |
| Phase 2E-E | Kleiner Code-Slice mit freigegebenen Assets | `fertig / lokaler Mock-Slice bestanden` | Lokale Anzeige von `base.png` + `foundation_started.png` ist umgesetzt. `main_build_area` auf Waldlichtung ist umgesetzt. Lokaler Zustand `empty -> foundation_started` ist umgesetzt. Nutzerfuehrung mit Hinweistext und kontrastreichem Fokus ist umgesetzt. Minimaler Feedback-Moment mit vorbereiteter ID `build.foundation.started` ist umgesetzt. Visuell auf Geraet geprueft. Keine ausgeschlossenen Systeme wurden beruehrt: keine Persistenz, Supabase Writes, SRS-/`word_progress`-Aenderung, Reward Bridge, echte Ressourcenlogik, Expansion, PlacedItems, Interiors/ObjectDetail, produktive Bau-/Lernlogik, Sounddatei oder Audio-Implementierung. Commit: `c82880e4 feat: polish forest clearing foundation guidance`. |
| Phase 2F | `foundation_complete` | `fertig / lokaler Mock-Slice bestanden` | Lokale Mock-Erweiterung `foundation_started -> foundation_complete` ist umgesetzt. Anzeige `base.png` + `foundation_complete.png` ist umgesetzt; `foundation_complete` ersetzt `foundation_started` visuell ohne dauerhaftes Stapeln. Direkter Tap-Flow funktioniert. Grosse Snackbar wurde entfernt. Kleine In-World-Labels `Fundament begonnen` und `Fundament fertig` bleiben. Label-Abstand wurde verbessert und auf Geraet geprueft. Feedback-ID `build.foundation.complete` ist vorbereitet, ohne Sound-/FX-Implementierung. Keine ausgeschlossenen Systeme wurden beruehrt: keine Persistenz, Supabase Writes, SRS-/`word_progress`-Aenderung, Reward Bridge, Ressourcenlogik, Sound-/FX-Schicht, Audio/Sounddateien, Expansion, PlacedItems, Interiors/ObjectDetail oder produktive Bau-/Lernlogik. Commit: `b13d2162 fix: refine foundation complete guidance flow`. |
| Phase 2G | `frame_started` / Rohbau | `gestoppt / Masterlayout erforderlich` | Planung in `docs/world_design/243-frame-started-plan.md`, Prompt-Vorbereitung in `docs/world_design/244-frame-started-asset-prompt.md` und Anchor-Regeln in `docs/world_design/245-build-alignment-and-anchor-system.md` bleiben erhalten, aber `frame_started` wird nicht weitergebaut. Grund: Vor weiteren Bauassets fehlt das Insel-Masterlayout mit modularen Plot-Flaechen, Sockets, Anchors und Footprints. Der nicht freigegebene Kandidat wurde geloescht. |
| Phase 2G-M | Waldlichtung Masterlayout / Modular Plot System | `Planung gestartet` | Reiner Planungsblock in `docs/world_design/246-island-master-layout-and-modular-plot-system.md`. Die aktuelle Waldlichtung gilt als `StarterCorePlot`, nicht als vollstaendige Insel. Naechster erlaubter Schritt ist Greybox-/Masterlayout- oder Scale-/Plot-Messblock, nicht Asset oder Code. |
| Phase 2G-M1 | Greybox / Scale / Plot Metrics | `Planung gestartet` | Reiner Mess-/Greybox-Planungsblock in `docs/world_design/247-island-greybox-scale-and-plot-metrics.md`. Definiert relative Plotgroessen, Mindestkapazitaet, StarterCorePlot-Rolle, Socket-Kompatibilitaet und erste Text-Greybox. Naechster erlaubter Schritt: konkrete Plot-Metriken festlegen oder Greybox-Skizze/Layout-Preview planen. Kein Asset und kein Code. |
| Phase 2G-M2 | Konkrete Plot-Metriken / Koordinaten-Greybox | `Planung gestartet` | Reiner Planungsblock in `docs/world_design/248-island-plot-metrics-and-greybox-layout.md`. Konkretisiert `P` als `100 x 72gu`, definiert vorlaeufige Plot-, Weg-, Socket- und Sicherheitsmetriken, `starter_home_plot = 1.5P`, Starter-/Expansion-Plots und eine erste Koordinaten-Greybox. Naechster erlaubter Schritt: Greybox-Skizze/Layout-Preview planen oder Mobile-Lesbarkeit/Inselkapazitaet pruefen. Kein Asset und kein Code. |
| Phase 2G-M3 | Sichtbare Greybox-Preview / Layout-Pruefung | `Planung gestartet` | Reiner Planungsblock in `docs/world_design/249-island-greybox-preview-plan.md`. Definiert sichtbare Debug-Greybox-Elemente, Plot-Status, Socket-, Weg-, Footprint- und Sicherheitszonen-Overlays, Status-Legende, Pruefkriterien und Mobile-Lesbarkeitsfragen. In diesem Block wurden keine Preview-PNGs erzeugt. Naechster erlaubter Schritt: tatsaechliche Debug-Greybox-Preview erzeugen/pruefen oder Metriken/Layout nachbessern. Kein finales Inselbild, kein Asset, kein Code. |
| Phase 2G-M4 | Debug-Greybox-Preview-Erzeugung | `Preview erzeugt / Nutzerpruefung offen` | Reiner Dokumentations-/Debugblock. Erzeugt `01_island_plot_greybox.png`, `02_socket_debug_overlay.png`, `03_footprint_debug_overlay.png`, `04_status_legend.png` und `README.md` unter `docs/world_design/previews/phase2g_m3_island_greybox/`. Die Preview-Dateien sind keine Spielassets und geben keine Asset- oder Codefreigabe. Naechster erlaubter Schritt: visuelle Pruefung durch Nutzer, danach Metriken/Layout bestaetigen oder nachbessern. |
| Phase 2G-M5 | Visuelle Greybox-Bewertung / Layout-Nachbesserung | `Review gestartet / Nachbesserung empfohlen` | Reiner Bewertungsblock in `docs/world_design/250-island-greybox-layout-review.md`. M4 ist als technisches Debugdiagramm brauchbar, aber nicht als visuell plausibles Insel-Masterlayout bestaetigt. Hauptprobleme: zu lineare Achse `path_south -> hub_seed_south -> market_square`, langer Markt-Schwanz, zu diagonale Wasseranbindung und zu rasterhafte Aussenform. Empfehlung: M4 nachbessern und eine neue M5-Greybox-Variante, bevorzugt Variante B, erzeugen. Kein finales Inselbild, kein Asset, kein Code. |
| Phase 2G-M5-B | Variante-B Debug-Greybox-Nachbesserung | `Preview erzeugt / Nutzerpruefung offen` | Reiner Dokumentations-/Debugblock. Erzeugt `01_island_plot_greybox_variant_b.png`, `02_socket_debug_overlay_variant_b.png`, `03_footprint_debug_overlay_variant_b.png`, `04_status_legend_variant_b.png` und `README.md` unter `docs/world_design/previews/phase2g_m5_island_greybox_variant_b/`. Variante B reduziert die lineare M4-Achse, verschiebt `market_square` naeher an `hub_seed_south`, liest `water_edge_east` staerker als Randzone und rahmt `starter_home` organischer. Die Preview-Dateien sind keine Spielassets und geben keine Asset- oder Codefreigabe. Nach der Sichtpruefung darf Variante B nicht als finale feste Gebaeudeanordnung bestaetigt werden; fuehrend ist Phase 2G-M6. |
| Phase 2G-M5-C | Variante-B manuelle Sichtpruefung | `ausgewertet / keine finale Layoutbestaetigung` | Reiner Dokumentationsblock in `docs/world_design/251-island-greybox-variant-b-manual-review.md`. Die Sichtpruefung hat gezeigt, dass Variante B zu stark wie eine feste Gebaeudeanordnung wirkt. Variante B darf nur noch als raeumliche Testform gelesen werden. Keine finale Entscheidung, kein finales Inselbild, kein Asset, kein Code. |
| Phase 2G-M6 | Flexible Plot Placement / Learning Semantics | `Planung gestartet / Variante-B nicht final bestaetigen` | Reiner Planungsblock in `docs/world_design/252-flexible-plot-placement-and-learning-semantics.md`. Stoppt jede Bestaetigung der Variante-B-Greybox als feste Gebaeudeanordnung. Plots werden als flexible Slots mit `plotSize`, `allowedFunctions`, Anchors, Sockets, Footprints und Nutzerwahl verstanden. Lernwoerter werden ueber Semantik in Weltobjekte, Bauteile, Szenen, Blueprints, Backlogs, Companion-Vorschlaege oder Codex-Eintraege uebersetzt. Kein finales Inselbild, kein Asset, kein Code. |
| Phase 2G-M6-B | Placement Decision / Semantics Logic | `Planung vertieft / Pruefung offen` | Vertieft `docs/world_design/252-flexible-plot-placement-and-learning-semantics.md` um Placement Decision Pipeline, Plot Capability Matrix, Word Placement Requirements, Visual Representation Tiers, User Choice Regeln, Ambiguity Handling, Visual Clutter Regeln und offene Rebuild/Move/Personalization-Entscheidungen. Kein Wort-zu-Welt-System ohne Pipeline, keine Plot-Freigabe ohne Capability Matrix, kein Objekt ohne Placement Requirements. Kein finales Inselbild, kein Asset, kein Code. |
| Phase 2G-M6-C | Data Model / Import / Safety / Learning Modes | `Planung vertieft / Pruefung offen` | Vertieft `docs/world_design/252-flexible-plot-placement-and-learning-semantics.md` um abstrakte Datenmodell-Skizzen (`PlotSlot`, `WordSemanticProfile`, `PlacementCandidate`, `BlueprintEntry` usw.), Trennung von Learning Progress und Build Progress, Browser-/Real-World-Import-Workflow, Repraesentationsprioritaet, sensible/abstrakte Begriffe und Learning-Mode-Integration. Kein Word-to-World-System ohne Modellskizze, kein Import ohne Kontext-/Sense-/Safety-Pruefung, kein sensibles Wort automatisch als Weltobjekt. Kein finales Inselbild, kein Asset, kein Code. |
| Phase 2G-M6-D | Progression / Onboarding / Governance / Capability Greybox | `Planung vertieft / Pruefung offen` | Vertieft `docs/world_design/252-flexible-plot-placement-and-learning-semantics.md` um Progression ohne feste Baureihenfolge, freie Erstwahl, Import-Governance/Privacy/Safety, Nutzerziel-/Kategorie-Priorisierung und Anforderungen an die naechste Greybox mit abstrakten Capability-Labels. Keine freie Plot-Platzierung ohne Onboarding-Erklaerung, kein Import ohne Governance-/Privacy-/Safety-Regeln, keine naechste Greybox mit festen Gebaeude-Rollenlabels. Kein finales Inselbild, kein Asset, kein Code. |
| Phase 2G-M6-E | Theme Islands / Personal Learning Archipelago | `Planung vertieft / Pruefung offen` | Vertieft `docs/world_design/252-flexible-plot-placement-and-learning-semantics.md` um Thematic Island And Archipelago Strategy, Candidate Theme Islands, First Island Choice, Island Roadmap, Word To Island Routing, Free/Paid-Prinzipien und Production Scope Control. Keine einzelne Insel darf alle Lernwelten erzwingen. Keine Themeninsel ohne Plot-Capabilities und Word-to-Island-Routing. Keine Monetarisierung ohne eigenes Dokument. Kein finales Inselbild, kein Asset, kein Code. |
| Phase 2G-M6-F | Archipelago Navigation / Shared Backlog / Island Slots | `Planung vertieft / Pruefung offen` | Vertieft `docs/world_design/252-flexible-plot-placement-and-learning-semantics.md` um Archipelago Navigation, Shared Codex/Blueprint/Backlog, Cross-Island Word Routing, Multi-Home Words, Island Slot Lifecycle, Island Ownership/Identity und UX-Komplexitaetsschutz. Kein Multi-Island-System ohne Archipel-Navigation, kein Themeninsel-System ohne gemeinsamen Codex-/Blueprint-/Backlog-Plan, keine Social-/Showcase-Funktion ohne eigenes Privacy-/Social-Konzept. Kein finales Inselbild, kein Asset, kein Code. |
| Phase 2G-M7 | Abstrakte Capability-Greybox | `Planung gestartet / keine Preview-PNGs` | Reiner Planungsblock in `docs/world_design/253-capability-greybox-plan.md`. Uebersetzt feste Variante-B-Labels in abstrakte Plot-Slots wie `core_plot_a`, `hub_capable_plot_a` und `edge_water_capable_plot_a`; definiert pro Plot `plotSize`, `allowedFunctions`, `isUserSelectable`, `unlockState`, `pathSockets`, `objectAnchors`, `buildingFootprint`, `requiredAdjacency` und Hinweise. Geplante Preview-Dateien werden nur dokumentiert, nicht erzeugt. Keine neue Greybox mit festen Gebaeude-Rollenlabels, keine Asset-Produktion, keine Codefreigabe. |
| Phase 2G-M7-B | Debug-Capability-Greybox-Erzeugung | `Preview erzeugt / visuelle Pruefung offen` | Reiner Dokumentations-/Debugblock. Erzeugt `01_capability_plot_overview.png`, `02_allowed_functions_overlay.png`, `03_anchor_socket_overlay.png`, `04_user_choice_flow_overlay.png` und `README.md` unter `docs/world_design/previews/phase2g_m7_capability_greybox/`. Die Preview-Dateien zeigen abstrakte Plot-Slots, `allowedFunctions`, Nutzerwaehlbarkeit, Anchors, Sockets, Footprints und Nutzerwahl-Flow. Sie sind keine Spielassets, keine finale Kunst und geben keine Code- oder Assetfreigabe. Naechster erlaubter Schritt: visuelle Pruefung der Capability-Greybox, danach bestaetigen oder nachbessern. |
| Phase 2G-M7-C | Capability-Greybox Visual Review | `Review gestartet / M7-B technisch brauchbar` | Reiner Dokumentationsblock in `docs/world_design/254-capability-greybox-visual-review.md`. Bewertet die M7-B-Previews visuell. Ergebnis: alte Rollenlabels sind entfernt, abstrakte Plotnamen und Metadaten sind lesbar, `allowedFunctions` suggerieren keine feste Bauentscheidung, Anchors/Sockets/Footprints sind intern pruefbar und der Nutzerwahl-Flow ist verstaendlich. M7-B ist als technische Debug-Greybox brauchbar, aber nicht als Nutzeransicht. M7-D als vereinfachte Nutzer-/Produktansicht bleibt empfohlen. Keine Asset- oder Codefreigabe. |
| Phase 2G-M8 | World Depth / Gameplay / Retention Research | `Research-/Planungsblock gestartet` | Reiner Research- und Planungsblock in `docs/world_design/255-world-depth-gameplay-retention-research.md`. Klaert Island-/Plot-/Building-/Interior-/Object-/Container-/Detail-Depth, Container-Objekte, Word-Type-to-Depth-Mapping, Anchor-Semantik, Interaction/Challenge Loop, Core/Meta Loop, Lessons aus erfolgreichen Spielen, faire Reward-Momente, Retention ohne Ausbeutung und Monetarisierungsgrundlagen. `objectAnchors` sind optionale technische Moeglichkeiten, keine Pflichtobjekte. Kein Asset, kein Code, keine App-Integration. |
| Phase 2G-M9 | Depth-/Container User Flow Preview | `Preview erzeugt / visuelle Pruefung offen` | Reiner Planungs- und Visualisierungsblock in `docs/world_design/256-depth-container-user-flow-preview-plan.md`. Erzeugt `01_depth_flow_storyboard.png`, `02_depth_level_stack.png`, `03_interaction_reward_loop.png` und `README.md` unter `docs/world_design/previews/phase2g_m9_depth_container_user_flow/`. Die Preview zeigt den Beispiel-Flow Haus/Kueche -> Schublade -> Besteck als vereinfachte Nutzer-/Produktansicht. Keine Spielassets, keine finale UI, keine Codefreigabe, kein `frame_started`. |
| Phase 2G-M9-B | Depth-/Container User Flow Visual Review | `Review gestartet / erster Flow brauchbar` | Reiner Dokumentationsblock in `docs/world_design/257-depth-container-user-flow-visual-review.md`. Bewertet die M9-Previews visuell. Ergebnis: Der Flow Haus/Kueche -> Schublade -> Besteck ist als erste vereinfachte Nutzer-/Produktansicht grundsaetzlich brauchbar, zeigt aktive Nutzerhandlung, Mini-Challenge, Feedback, Reward Moment und optionales naechstes Ziel. Er reicht aber nicht aus, um ein allgemeines Container-System fuer alle Themen abzuleiten. Weitere Beispiel-Flows wie Schule/Federmappe, Hafen/Bootskajute und Garten/Beet bleiben empfohlen. Keine Asset- oder Codefreigabe. |
| Phase 2G-M10 | Emotional Product Flow Preview | `Preview erzeugt / Review gestartet` | Reiner Planungs- und Visualisierungsblock in `docs/world_design/258-emotional-product-flow-preview-plan.md`. Erzeugt `01_emotional_storyboard.png`, `02_emotion_motivation_beats.png`, `03_tali_vori_light_reaction_concept.png` und `README.md` unter `docs/world_design/previews/phase2g_m10_emotional_product_flow/`. Ziel: mehr Atmosphaere, Neugier, Spielreiz und Produktgefuehl, ohne finale UI oder Spielasset zu erzeugen. M10-C wurde spaeter als eigener Companion-Reaktionsflow gestartet. Kein Code, kein Asset, kein `frame_started`. |
| Phase 2G-M10-D | Emotional Product Flow Visual Review | `Review gestartet / grundsaetzlich brauchbar` | Reiner Dokumentationsblock in `docs/world_design/259-emotional-product-flow-visual-review.md`. Bewertet die M10-Previews visuell. Ergebnis: M10 wirkt emotionaler und spielnaeher als M9, zeigt Curiosity Cue, aktive Nutzerhandlung, Reveal, Mini-Challenge, Feedback, Reward, freiwilliges naechstes Ziel und leichte Tali/Vori-Praesenz. M10 bestaetigt keine Challenge-Art, keine Companion-UX und kein allgemeines Container-System. Keine App-, Code- oder Assetfreigabe. |
| Phase 2G-M10-B | Challenge Interaction Comparison | `gestartet / Preview erzeugt / durch M10-B2 geprueft` | Reiner Research-, Planungs- und Visualisierungsblock in `docs/world_design/260-challenge-interaction-comparison.md`. Erzeugt `01_challenge_type_matrix.png`, `02_kitchen_challenge_variants.png`, `03_recommended_challenge_progression.png` und `README.md` unter `docs/world_design/previews/phase2g_m10b_challenge_interaction_comparison/`. Empfehlung fuer den Review-Stand: Tap-Auswahl zuerst, Audio + Tap als zweite Stufe, Matching/Sortieren spaeter, Mini-Sequenzen spaeter fuer Aktionen. Keine Challenge-Implementierung, keine finale Challenge-Art, kein Code, kein Asset. |
| Phase 2G-M10-B2 | Challenge Interaction Visual Review | `Review gestartet / erste Empfehlung brauchbar` | Reiner Dokumentationsblock in `docs/world_design/261-challenge-interaction-visual-review.md`. Bewertet die M10-B-Previews visuell. Ergebnis: Die Matrix ist fuer interne Planung dicht, aber brauchbar; Tap-Auswahl ist als erster Prototype-Flow nachvollziehbar, Audio + Tap als zweite Stufe, Matching/Sortieren spaeter und Mini-Sequenzen fuer Aktionen. Keine finale Challenge-Systementscheidung ohne M11, keine Challenge-Implementierung, kein Code, kein Asset. |
| Phase 2G-M10-C | Companion Reaction Flow | `gestartet / Preview erzeugt / durch M10-C2 geprueft` | Reiner Planungs- und Visualisierungsblock in `docs/world_design/262-companion-reaction-flow.md`. Erzeugt `01_companion_reaction_timeline.png`, `02_success_error_idle_reactions.png`, `03_companion_boundaries.png` und `README.md` unter `docs/world_design/previews/phase2g_m10c_companion_reaction_flow/`. Ziel: Tali/Vori als emotionalen Motivationsanker pruefen, ohne Challenge zu loesen, Druck zu erzeugen oder finale Companion-UX freizugeben. Keine Companion-Implementierung, keine Voice-/Audio-/Animation-Freigabe, kein Code, kein Asset. |
| Phase 2G-M10-C2 | Companion Reaction Visual Review | `Review gestartet / erste Richtung brauchbar` | Reiner Dokumentationsblock in `docs/world_design/263-companion-reaction-visual-review.md`. Bewertet die M10-C-Previews visuell. Ergebnis: Tali/Vori ist als sanfter Motivationsanker sichtbar, loest die Challenge nicht, erzeugt keinen Druck und bleibt begleitend. Die Text-Containment-Auffaelligkeit in `01_companion_reaction_timeline.png` ist nicht-blockierend und als Quality Note dokumentiert. Keine finale Companion-UX, keine Voice-/Audio-/Animation-/Rive-Freigabe, kein Code, kein Asset. |
| Phase 2G-M11 | Multi-Example Container Flow Previews | `gestartet / Preview erzeugt / durch M11-B geprueft` | Reiner Planungs- und Visualisierungsblock in `docs/world_design/264-multi-example-container-flow-previews.md`. Erzeugt `01_multi_flow_overview.png`, `02_flow_comparison_matrix.png`, `03_challenge_fit_by_flow.png`, `04_companion_moments_by_flow.png` und `README.md` unter `docs/world_design/previews/phase2g_m11_multi_example_container_flows/`. Ziel: Schule/Federmappe/Stifte, Hafen/Bootskajute/Kompass-Karte-Seil und Garten/Beet/Samen-Giesskanne-Pflanze pruefen, damit kein allgemeines Container-System aus nur einem Kuechenbeispiel abgeleitet wird. M11-B bewertet die Multi-Flow-Richtung als brauchbar. Keine Spielassets, keine finale UI, kein Code, keine finale Container-Systemarchitektur. |
| Phase 2G-M11-B | Multi-Example Container Flow Visual Review | `Review gestartet / Multi-Flow-Richtung brauchbar` | Reiner Dokumentationsblock in `docs/world_design/265-multi-example-container-flow-visual-review.md`. Bewertet die M11-Previews visuell. Ergebnis: Die drei Flows sind verstaendlich, Tap-Auswahl bleibt uebergreifend der staerkste MVP-Kandidat, Audio + Tap bleibt zweite Stufe, Matching/Sortieren bleiben spaeter sinnvoll und Mini-Sequenzen bleiben advanced. Schule/Federmappe und Garten/Beet sind besonders tragfaehig; Hafen/Bootskajute bleibt wertvoll, aber mobil/visuell riskanter. Keine finale Container-Systemarchitektur, keine Flow-Implementierung, kein Code, kein Asset. |
| Phase 2G-M11-C | World Content Taxonomy / Location Catalog | `Taxonomy-Backlog gestartet` | Reiner Dokumentationsnachtrag in `docs/world_design/266-world-content-taxonomy-and-location-catalog.md`. Strukturiert Wohnbereiche, Grundstueck/Aussenbereiche, Fahrzeuge/Parken, Strassen/Wege, Stadt/Dorfzentrum, Einkauf/Versorgung, Gastronomie/Freizeit, oeffentliche Gebaeude, Arbeit/Gewerbe/Industrie, Natur/Gruenflaechen, Freizeitflaechen draussen, Wasser/Hafen/Kueste, Landwirtschaft und Dekoration/Details. Der Katalog ist keine Assetfreigabe, keine Bau-Freigabe und keine finale ThemeIsland-Roadmap; er dient spaeter ThemeIsland-Routing, Plot-Capabilities, Depth-/Container-Planung und Asset-Priorisierung. |
| Phase 2G-M11-C2 | World Content Taxonomy Review | `Review gestartet / erste Grundlage brauchbar` | Reiner Dokumentationsblock in `docs/world_design/267-world-content-taxonomy-review.md`. Bewertet den Katalog aus `266` als erste Content-/Location-Grundlage. Ergebnis: Die 14 Hauptkategorien sind sinnvoll und die Ebene ThemeIsland -> Zone -> Plot/Gebaeude -> Aussenbereich -> Innenraum -> Container/Fokusobjekt -> Detail/Deko ist brauchbar. Offen bleiben ThemeIsland-Priorisierung, Word-to-Island-Routing-Matrix, Plot-Capability-Ableitung, Sensitive-Content-Regeln und Mobile-/Clutter-Regeln fuer Kleinteile und Deko. Keine finale Roadmap, keine Assetliste, kein Code, kein Asset, kein `frame_started`. |
| Phase 2G-M12 | ThemeIsland Prioritization | `Planung gestartet / Previews erzeugt` | Reiner Planungs- und Visualisierungsblock in `docs/world_design/268-theme-island-prioritization.md`. Preview-Dateien liegen unter `docs/world_design/previews/phase2g_m12_theme_island_prioritization/`: `01_theme_island_priority_map.png`, `02_theme_island_decision_matrix.png`, `03_early_candidate_flow_examples.png`, `04_scope_risk_wave_plan.png` und `README.md`. Ergebnis fuer den Planungsstand: Zuhause/Alltag, Schule/Lernen und Garten/Natur nah als Early-Kandidaten; Kueste/Meer/Hafen, Essen/Restaurant/Cafe, Einkauf/Versorgung und Land/Farm als Mid-Kandidaten; Stadt, Verkehr, Arbeit, Freizeit, Outdoor und Technik spaeter; Gesundheit und Kultur/Gesellschaft/Verwaltung blockiert bis zu Sensitive-Content-Regeln. Keine finale ThemeIsland-Roadmap, keine ThemeIsland-Umsetzung, kein Code, kein Asset, kein `frame_started`. |
| Phase 2G-M12-A2 | ThemeIsland Prioritization Visual Review | `Review gestartet / erste Priorisierung brauchbar` | Reiner Dokumentationsblock in `docs/world_design/269-theme-island-prioritization-visual-review.md`. Bewertet die M12-Previews visuell. Ergebnis: Early/Mid/Late/Sensitive-Struktur ist verstaendlich, Early-Kandidaten sind nachvollziehbar, Mid/Late/Sensitive-Risiken sind sichtbar, die Matrix ist dicht, aber fuer interne Planung brauchbar, und Texte bleiben innerhalb der Panels. Keine finale ThemeIsland-Roadmap, keine ThemeIsland-Umsetzung, keine Assetproduktion, kein Code, kein Asset, kein `frame_started`. |
| Phase 2G-M12-B | Word-to-Island Routing Matrix | `Planung gestartet / Previews erzeugt` | Reiner Planungs- und Visualisierungsblock in `docs/world_design/270-word-to-island-routing-matrix.md`. Preview-Dateien liegen unter `docs/world_design/previews/phase2g_m12b_word_to_island_routing/`: `01_word_routing_pipeline.png`, `02_word_type_routing_matrix.png`, `03_example_word_routing_cards.png`, `04_multi_home_and_backlog_flow.png` und `README.md`. Klaert erste Routing-Ebenen, Worttypen, Beispielrouting, Multi-home-Woerter, Backlog/Fallback und Nutzerentscheidung. Keine finale Routing-Implementierung, keine finale Datenstruktur, keine automatische Wortplatzierung, keine ThemeIsland-Umsetzung, kein Code, kein Asset, kein `frame_started`. |
| Phase 2G-M12-B2 | Word-to-Island Routing Visual Review | `Review gestartet / erste Routing-Richtung brauchbar` | Reiner Dokumentationsblock in `docs/world_design/271-word-to-island-routing-visual-review.md`. Bewertet die M12-B-Previews visuell. Ergebnis: Pipeline, Matrix, Beispielkarten und Multi-home-/Backlog-Flow sind als erste Routing-Planungsrichtung brauchbar. Bestaetigt nur Planungsregeln gegen automatische Platzierung, falsche Depth-Ebene, Multi-home ohne Nutzer-/Kontextentscheidung und sensitive Begriffe ohne M12-D. Keine finale Routing-Implementierung, keine finale Datenstruktur, keine automatische Wortplatzierung, keine ThemeIsland-Umsetzung, kein Code, kein Asset, kein `frame_started`. |
| Phase 2G-M12-C | Plot-Capability Derivation | `Planung gestartet / Previews erzeugt` | Reiner Planungs- und Visualisierungsblock in `docs/world_design/272-plot-capability-derivation.md`. Preview-Dateien liegen unter `docs/world_design/previews/phase2g_m12c_plot_capability_derivation/`: `01_plot_capability_pipeline.png`, `02_plot_type_capability_matrix.png`, `03_early_theme_capability_cards.png`, `04_mid_late_special_plot_limits.png` und `README.md`. Leitet erste Plot-Capabilities fuer abstrakte Plottypen und Early ThemeIslands ab. Keine finale Plot-Datenstruktur, keine Runtime-Konfiguration, keine Plot-Implementierung, keine ThemeIsland-Umsetzung, kein Code, kein Asset, kein `frame_started`. |
| Phase 2G-M12-C2 | Plot-Capability Visual Review | `Review gestartet / erste Capability-Richtung brauchbar` | Reiner Dokumentationsblock in `docs/world_design/273-plot-capability-visual-review.md`. Bewertet die M12-C-Previews visuell. Ergebnis: Pipeline, Matrix, Early Theme Cards und Mid/Late/Special Limits sind als erste Plot-Capability-Planungsrichtung brauchbar. Bestaetigt nur Planungsregeln: `allowedFunctions` sind Erlaubnisse, `core_plot` ist nicht automatisch `home`, `hub_capable_plot` ist nicht automatisch Markt, und Water/Farm/Travel/Vehicle/Digital/Sensitive bleiben gated. Keine finale Plot-Datenstruktur, keine Runtime-Konfiguration, keine Plot-Implementierung, keine ThemeIsland-Umsetzung, kein Code, kein Asset, kein `frame_started`. |
| Phase 2G-M12-D | Sensitive Content Representation Rules | `Planung gestartet / Previews erzeugt` | Reiner Planungs- und Visualisierungsblock in `docs/world_design/274-sensitive-content-representation-rules.md`. Preview-Dateien liegen unter `docs/world_design/previews/phase2g_m12d_sensitive_content_rules/`: `01_sensitive_content_decision_pipeline.png`, `02_sensitive_category_matrix.png`, `03_safe_representation_examples.png`, `04_blocked_until_rules_map.png` und `README.md`. Definiert erste neutrale Darstellungswege fuer sensible, abstrakte und gesellschaftlich heikle Begriffe: Codex, ContextCard, CompanionDialog, QuestWithoutSymbol, NeutralBlueprint, BacklogOnly, RequiresUserChoice und BlockedUntilRules. Keine finale Safety-Implementierung, keine Moderations-Implementierung, keine automatische Visualisierung, keine ThemeIsland-Umsetzung, kein Code, kein Asset, kein `frame_started`. |
| Phase 2G-M12-D2 | Sensitive Content Visual Review | `Review gestartet / erste Sensitive-Richtung brauchbar` | Reiner Dokumentationsblock in `docs/world_design/275-sensitive-content-visual-review.md`. Bewertet die M12-D-Previews visuell und inhaltlich. Ergebnis: Pipeline, Matrix, Beispielkarten und Blocked-Until-Rules Map sind als erste Sensitive-Content-Planungsrichtung brauchbar. Bestaetigt nur Planungsregeln gegen automatische Visualisierung, Gebaeude-/Symbol-/Assetproduktion, Reward-/Retention-Druck, Beratungslogik, sensible ThemeIsland-Umsetzung und Companion-Dramatisierung. Keine finale Safety-Implementierung, keine Moderations-Implementierung, keine finale Datenstruktur, kein Code, kein Asset, kein `frame_started`. |
| Phase 2G-M12-E | Mobile And Clutter Rules For Small Objects | `Planung gestartet / Previews erzeugt` | Reiner Planungs- und Visualisierungsblock in `docs/world_design/276-mobile-clutter-rules-small-objects.md`. Preview-Dateien liegen unter `docs/world_design/previews/phase2g_m12e_mobile_clutter_rules/`: `01_mobile_clutter_depth_ladder.png`, `02_small_object_routing_matrix.png`, `03_container_clutter_examples.png`, `04_mobile_stop_gates.png` und `README.md`. Definiert erste Planungswerte und Stop-Gates fuer TinyObjects, SmallTools, ContainerItems, AmbientDecoration, InteractiveFocusObjects, BuildingParts, SequenceObjects und SensitiveSmallObjects. Keine finale Mobile-UI, keine finale Datenstruktur, keine Runtime-Konfiguration, keine Container-Implementierung, kein Code, kein Asset, kein `frame_started`. |
| Phase 2G-M12-E2 | Mobile Clutter Visual Review | `Review gestartet / erste Mobile-Clutter-Richtung brauchbar` | Reiner Dokumentationsblock in `docs/world_design/277-mobile-clutter-visual-review.md`. Bewertet die M12-E-Previews visuell und inhaltlich. Ergebnis: Ladder, Matrix, Container-Beispiele und Stop-Gates sind als erste Mobile-/Clutter-Planungsrichtung brauchbar. Bestaetigt nur Planungsregeln gegen TinyObjects in IslandView, ueberfuellte Container, dauerhafte Labelwolken, verdeckende Deko und sensitiveSmallObjects ohne M12-D. Keine finale Mobile-UI, keine finale Datenstruktur, keine Runtime-Konfiguration, keine Container-Implementierung, kein Code, kein Asset, kein `frame_started`. |
| Phase 2G-M12-F | M12 Consolidated Readiness Review | `Review gestartet / M12-Kette als Planungsgrundlage brauchbar` | Reiner Dokumentationsblock in `docs/world_design/278-m12-consolidated-readiness-review.md`. Konsolidiert M12 bis M12-E2: ThemeIsland-Priorisierung, Word-to-Island Routing, Plot-Capabilities, Sensitive Content und Mobile/Clutter. Ergebnis: Die M12-Kette ist als Grundlage fuer weitere reine Planung brauchbar, aber keine finale ThemeIsland-Roadmap, keine Implementierungsfreigabe, keine finale Datenstruktur, keine Runtime-Konfiguration, keine App-/Assetfreigabe, kein Code, kein Asset, kein `frame_started`. |
| Phase 2G-M13 | ThemeIsland Roadmap Draft | `Planung gestartet / Previews erzeugt` | Reiner Planungs- und Visualisierungsblock in `docs/world_design/279-theme-island-roadmap-draft.md`. Preview-Dateien liegen unter `docs/world_design/previews/phase2g_m13_theme_island_roadmap_draft/`: `01_theme_island_roadmap_waves.png`, `02_early_island_candidate_cards.png`, `03_roadmap_gate_flow.png`, `04_risk_and_scope_map.png` und `README.md`. Ordnet Kandidaten in Foundation, Expansion Wave 1, Expansion Wave 2, System-Heavy Wave und Sensitive/Special Wave. Keine finale ThemeIsland-Roadmap, keine ThemeIsland-Umsetzung, keine finale Datenstruktur, keine Runtime-Konfiguration, kein Code, kein Asset, kein `frame_started`. |
| Phase 2G-M13-A2 | ThemeIsland Roadmap Visual Review | `Review gestartet / erster Roadmap-Draft brauchbar` | Reiner Dokumentationsblock in `docs/world_design/280-theme-island-roadmap-visual-review.md`. Bewertet die M13-Previews visuell und inhaltlich. Ergebnis: Die Roadmap-Wellen, Early Candidate Cards, Gate Flow und Risk/Scope Map sind als erster Roadmap-Draft brauchbar. Keine finale ThemeIsland-Roadmap, keine finale Startinsel, keine ThemeIsland-Umsetzung, keine finale Datenstruktur, keine Runtime-Konfiguration, kein Code, kein Asset, kein `frame_started`. |
| Phase 2G-M13-B | Early Island Onboarding Choice Review | `Planung gestartet / Previews erzeugt` | Reiner Planungs- und Visualisierungsblock in `docs/world_design/281-early-island-onboarding-choice-review.md`. Preview-Dateien liegen unter `docs/world_design/previews/phase2g_m13b_early_island_onboarding_choice/`: `01_onboarding_choice_flow.png`, `02_foundation_choice_cards.png`, `03_onboarding_variant_comparison.png`, `04_no_forced_start_guardrails.png` und `README.md`. Prueft eine reversible Foundation-Wahl zwischen Zuhause/Alltag, Schule/Lernen und Garten/Natur nah. Vorlaeufige Empfehlung: Hybrid aus kurzer Tali/Vori-Frage, drei Karten, Bestaetigung und spaeterer Aenderbarkeit. Keine finale Onboarding-UI, keine finale Startinsel, keine ThemeIsland-Umsetzung, keine finale Datenstruktur, keine Runtime-Konfiguration, kein Code, kein Asset, kein `frame_started`. |
| Phase 2G-M13-B2 | Early Island Onboarding Choice Visual Review | `Review gestartet / Hybrid-Richtung brauchbar` | Reiner Dokumentationsblock in `docs/world_design/282-early-island-onboarding-choice-visual-review.md`. Bewertet die M13-B-Previews visuell und inhaltlich. Ergebnis: Onboarding Choice Flow, Foundation Choice Cards, Variantenvergleich und No-Forced-Start-Guardrails sind als erste Onboarding-Choice-Planungsrichtung brauchbar. Hybrid wird nur als Planungsrichtung bestaetigt. Keine finale Onboarding-UI, keine finale Startinsel, keine Onboarding-Implementierung, keine ThemeIsland-Umsetzung, keine finale Datenstruktur, keine Runtime-Konfiguration, kein Code, kein Asset, kein `frame_started`. |
| Phase 2G-M13-C | ThemeIsland Capability Sheets | `Planung gestartet / Sheets erstellt` | Reiner Dokumentationsblock in `docs/world_design/283-theme-island-capability-sheets.md`. Konkretisiert ThemeIsland-Kandidaten als Planungsstruktur: Foundation-Sheets fuer Zuhause/Alltag, Schule/Lernen und Garten/Natur nah sowie kompakte Sheets fuer Expansion Wave 1, Expansion Wave 2, System-Heavy und Sensitive/Special. Enthaelt Capability-Matrix, Gates und Stop-Regeln. Keine finale ThemeIsland-Roadmap, keine finale Startinsel, keine finale Datenstruktur, keine Runtime-Konfiguration, keine ThemeIsland-Umsetzung, kein Code, kein Asset, kein `frame_started`. |
| Phase 2G-M13-D | Word-to-Island UX Flow | `Planung gestartet / UX-Flow definiert` | Reiner Dokumentationsblock in `docs/world_design/284-word-to-island-ux-flow.md`. Plant den Nutzerfluss von Wortaufnahme ueber Kontext/Sense, Worttyp, Safety, ThemeIsland-Kandidat, Depth-Kandidat und Nutzerentscheidung zu PlacementCandidate, Blueprint, Codex oder Backlog. Keine finale Word-to-Island-Implementierung, keine finale Routing-Datenstruktur, keine Runtime-Konfiguration, keine automatische Wortplatzierung, keine ThemeIsland-Umsetzung, kein Code, kein Asset, kein `frame_started`. |
| Phase 2G-M13-E | Device And Accessibility Preview Plan | `Planung gestartet / Pruefplan definiert` | Reiner Dokumentationsblock in `docs/world_design/285-device-accessibility-preview-plan.md`. Plant Pruefkategorien, Preview-Typen, Checklisten, harte Blocker und Freigabegrade fuer Device-Groessen, Portrait-Fokus, Tap-Ziele, Text-Containment, Accessibility, Mobile-Clutter und UX-Komplexitaet. Keine neuen PNGs, keine Tests, keine finale UI, keine finale Datenstruktur, keine Runtime-Konfiguration, keine App-/Assetfreigabe, kein Code, kein Asset, kein `frame_started`. |
| Phase 2G-M13-F | Container Pagination And Tap Target Rules | `Planung gestartet / Regeln textuell visualisiert` | Reiner Dokumentations- und Visualisierungsplanungsblock in `docs/world_design/286-container-pagination-and-tap-target-rules.md`. Plant Container-, Pagination-, Tap-Target-, Label-, Clutter- und QA-Overlay-Regeln fuer kleine Objektgruppen. Visualisierung nur als ASCII-Wireframes, Mermaid-Diagramm und Markdown-Tabellen. Keine PNGs, keine Tests, keine finale UI, keine finale Datenstruktur, keine Runtime-Konfiguration, keine Container-Implementierung, kein Code, kein Asset, kein `frame_started`. |
| Phase 2G-M13-G | Sensitive Content Policy Deepening | `Planung gestartet / Policy textuell vertieft` | Reiner Dokumentations- und Visualisierungsplanungsblock in `docs/world_design/287-sensitive-content-policy-deepening.md`. Vertieft Sensitive-Kategorien, Safe Representation Tiers, automatische Visualisierungsstopps, Tali/Vori-Verhalten, Privacy, User-Control, Policy-Matrizen und Gates. Visualisierung nur als Mermaid-Flow, ASCII-Flow und Markdown-Tabellen. Keine PNGs, keine Tests, keine finale Safety-Implementierung, keine Moderations-Implementierung, keine finale Datenstruktur, keine Runtime-Konfiguration, keine automatische Klassifikation, kein Code, kein Asset, kein `frame_started`. |
| Phase 2G-M13-H | Growth And Timer Fairness Rules | `Planung gestartet / Fairness textuell vertieft` | Reiner Dokumentations- und Visualisierungsplanungsblock in `docs/world_design/288-growth-timer-fairness-rules.md`. Vertieft Growth-Arten, Timer-Regeln, Streak-/Retention-Regeln, Tali/Vori-Erinnerungen, Fairness-Gates, harte Blocker und No-Decay-/No-Pay-to-Win-Leitplanken. Visualisierung nur als Mermaid-Flows, ASCII-Flow, Markdown-Tabellen und Fairness-/Timer-Matrizen. Keine PNGs, keine Tests, keine finale Growth-Implementierung, keine Timer-Implementierung, keine Retention-Implementierung, keine Monetarisierungsregel, keine finale Datenstruktur, keine Runtime-Konfiguration, kein Code, kein Asset, kein `frame_started`. |
| Phase 2G-M13-I | Asset Prioritization Scope Gate | `Planung gestartet / Scope-Gate definiert` | Reiner Dokumentations- und Visualisierungsplanungsblock in `docs/world_design/289-asset-prioritization-scope-gate.md`. Vertieft Asset-Kategorien, Prioritaetslogik, Asset-Gates, harte Blocker und Entscheidungsflows, damit aus Taxonomy, Roadmap, Routing, Capability Sheets, Onboarding, Growth oder Sensitive Planning keine automatische Assetproduktion entsteht. Visualisierung nur als Mermaid-Flow, ASCII-Flow, Markdown-Tabellen und Scope-/Asset-Matrizen. Keine PNGs, keine Tests, keine Assetproduktion, keine finale Assetliste, keine finale Produktionsfreigabe, keine finale Datenstruktur, keine Runtime-Konfiguration, kein Code, kein Asset, kein `frame_started`. |
| Phase 2G-M13-J | Consolidated M13 Readiness Review | `Review gestartet / M13-Kette als Planungsgrundlage brauchbar` | Reiner Dokumentations- und Visualisierungsplanungsblock in `docs/world_design/290-m13-consolidated-readiness-review.md`. Konsolidiert M13-B bis M13-I: Hybrid-Onboarding, Capability Sheets, Word-to-Island UX, Device/Accessibility, Container/Tap Targets, Sensitive Policy, Growth/Timer Fairness und Asset Scope Gate. Ergebnis: Die Kette ist als Planungsgrundlage brauchbar, aber Code, Assets, App-Integration, finale Roadmap, finale Startinsel, finale Onboarding-UI, finale Datenstruktur, Runtime-Konfiguration, Assetfreigabe und `frame_started` bleiben blockiert. Visualisierung nur als Mermaid-Flow, ASCII-Flow, Markdown-Tabellen und Readiness-Matrix. Keine PNGs, keine Tests, kein Code, kein Asset, kein `frame_started`. |
| Phase 2G-M13-K | Early Onboarding Product Wireframe Plan | `Planung gestartet / Wireframes textuell definiert` | Reiner Dokumentations- und Visualisierungsplanungsblock in `docs/world_design/291-early-onboarding-product-wireframe-plan.md`. Plant mobile-first Wireframes fuer Begruessung, drei Foundation-Lernfokus-Karten, Auswahl/Bestaetigung und Safe Exit mit Codex-/Blueprint-/Backlog-Fallback. Visualisierung nur als ASCII-Wireframes, Mermaid-Flow, Markdown-Tabellen, Wireframe-Beschreibungen und QA-/Device-Checklisten. Keine PNGs, keine Tests, keine App-Integration, keine finale Onboarding-UI, keine finale Startinsel, keine finale ThemeIsland-Roadmap, keine finale Datenstruktur, keine Runtime-Konfiguration, kein Code, kein Asset, kein `frame_started`. |
| Phase 2G-M13-L | Word-to-Island Product UX Preview Plan | `Planung gestartet / UX-Wireframes textuell definiert` | Reiner Dokumentations- und Visualisierungsplanungsblock in `docs/world_design/292-word-to-island-product-ux-preview-plan.md`. Plant mobile-first UX-Wireframes fuer Wort-Eingang, Vorschlagskarte, Sense-Auswahl, Container-Hinweis und Codex-/ContextCard-Route fuer sensible oder abstrakte Begriffe. Visualisierung nur als ASCII-Wireframes, Mermaid-Flow, Markdown-Tabellen, Product-UX-Beschreibungen und QA-/Device-Checklisten. Keine PNGs, keine Tests, keine App-Integration, keine finale Word-to-Island-UI, keine finale Word-to-Island-Implementierung, keine finale Routing-Datenstruktur, keine Runtime-Konfiguration, keine automatische Wortplatzierung, kein Code, kein Asset, kein `frame_started`. |
| Phase 2G-M13-M | Container QA Overlay Preview Plan | `Planung gestartet / QA-Overlays textuell definiert` | Reiner Dokumentations- und Visualisierungsplanungsblock in `docs/world_design/293-container-qa-overlay-preview-plan.md`. Plant QA-Overlay-Ebenen, ASCII-QA-Wireframes, Device-/Accessibility-Checks und Entscheidungszustaende fuer ContainerOpenView, DetailInteractionView und kleine Objektgruppen. Visualisierung nur als ASCII-Wireframes, ASCII-QA-Overlays, Mermaid-Flow, Markdown-Tabellen und QA-/Device-Checklisten. Keine PNGs, keine Tests, keine App-Integration, keine finale ContainerOpenView-UI, keine finale DetailInteractionView-UI, keine Container-Implementierung, keine finale Datenstruktur, keine Runtime-Konfiguration, kein Code, kein Asset, kein `frame_started`. |
| Phase 2G-M13-N | Foundation Choice Device Preview Plan | `Planung gestartet / Device-Wireframes textuell definiert` | Reiner Dokumentations- und Visualisierungsplanungsblock in `docs/world_design/294-foundation-choice-device-preview-plan.md`. Plant Device-Klassen, ASCII-Device-Wireframes, Safe-Area-/Tap-Zone-Overlays, Accessibility-Regeln und Text-Containment fuer die Foundation Choice zwischen Zuhause/Alltag, Schule/Lernen und Garten/Natur nah. Visualisierung nur als ASCII-Device-Wireframes, ASCII-Safe-Area-/Tap-Zone-Overlays, Mermaid-Flow, Markdown-Tabellen und Device-/Accessibility-/Text-Containment-Checklisten. Keine PNGs, keine Tests, keine App-Integration, keine finale Onboarding-UI, keine finale Foundation-Choice-UI, keine finale Startinsel, keine finale Datenstruktur, keine Runtime-Konfiguration, kein Code, kein Asset, kein `frame_started`. |
| Phase 2G-M13-O | ThemeIsland Roadmap Scope Freeze Review | `Review gestartet / Scope-Freeze textuell geprueft` | Reiner Dokumentations- und Visualisierungsplanungsblock in `docs/world_design/295-theme-island-roadmap-scope-freeze-review.md`. Prueft, ob die ThemeIsland-Roadmap als nicht-finale Planungsgrundlage eingefroren werden kann, und ordnet Wellen nach `frozen-for-planning`, `stable-but-needs-preview`, `candidate-only`, `requires-system-concept`, `requires-policy-gate` und `blocked-for-implementation`. Visualisierung nur als Mermaid-Flows, ASCII-Gate-Flows, Markdown-Tabellen, Scope-Freeze-Matrizen und Decision-/Readiness-Maps. Keine PNGs, keine Tests, keine App-Integration, keine finale ThemeIsland-Roadmap, keine finale Startinsel, keine finale Onboarding-UI, keine finale Foundation-Choice-UI, keine finale Datenstruktur, keine Runtime-Konfiguration, kein Code, kein Asset, kein `frame_started`. |
| Phase 2G-M13-P | Implementation Candidate Gate | `Gate gestartet / keine Implementierungsfreigabe` | Reiner Dokumentations- und Visualisierungsplanungsblock in `docs/world_design/296-implementation-candidate-gate.md`. Prueft, ob spaetere Product-/Review-Harness-/Implementation-Kandidaten denkbar sind, und ordnet sie nach `not-a-candidate`, `planning-only`, `preview-candidate-later`, `review-harness-candidate-later`, `implementation-candidate-later` und `blocked`. Visualisierung nur als Mermaid-Flows, ASCII-Gate-Flows, Markdown-Tabellen, Implementation-Readiness-Matrizen und Decision-/Blocker-Maps. Keine PNGs, keine Tests, keine App-Integration, keine finale Implementierungsfreigabe, keine finale ThemeIsland-Roadmap, keine finale Startinsel, keine finale Onboarding-UI, keine finale Foundation-Choice-UI, keine finale Word-to-Island-UI, keine finale Container-UI, keine finale Datenstruktur, keine Runtime-Konfiguration, kein Code, kein Asset, kein `frame_started`. |
| M14-A | Foundation Choice Product Preview Plan | `Planung gestartet / Product-Preview textuell definiert` | Reiner Dokumentations- und Visualisierungsplanungsblock in `docs/world_design/297-foundation-choice-product-preview-plan.md`. Plant produktnahe Preview-Zustaende, Copy-Regeln, Product-Flow, Foundation-Karten und ASCII-Product-Previews fuer die Foundation Choice zwischen Zuhause/Alltag, Schule/Lernen und Garten/Natur nah. Visualisierung nur als ASCII-Product-Wireframes, ASCII-Mobile-Frames, ASCII-State-Previews, Mermaid-Flows, Markdown-Tabellen und Product-/Device-/Accessibility-Checklisten. Keine PNGs, keine Tests, keine App-Integration, keine finale Foundation-Choice-UI, keine finale Onboarding-UI, keine finale Startinsel, keine finale ThemeIsland-Roadmap, keine finale Datenstruktur, keine Runtime-Konfiguration, keine App-/Assetfreigabe, keine Implementierungsfreigabe, kein Code, kein Asset, kein `frame_started`. |
| M14-A2 | Foundation Choice Product Preview Visual Review | `Review gestartet / M14-A als Product-Preview-Plan bestaetigt` | Reiner Dokumentations- und Visualisierungs-Reviewblock in `docs/world_design/298-foundation-choice-product-preview-visual-review.md`. Prueft den M14-A-Plan visuell/textuell gegen Product-Flow, Foundation-Karten, Copy-Regeln, Product-States, Device-/Accessibility-Regeln und Guardrails. Ergebnis: M14-A ist als Product-Preview-Plan grundsaetzlich brauchbar; kleine Copy-/Layout-Hinweise bleiben fuer spaetere Preview-Bloecke. Visualisierung nur als ASCII-Review-Overlays, ASCII-Mobile-Frames, ASCII-State-Review-Skizzen, Mermaid-Flows, Markdown-Tabellen und Product-/Device-/Accessibility-Review-Checklisten. Keine PNGs, keine Tests, keine App-Integration, keine finale Foundation-Choice-UI, keine finale Onboarding-UI, keine finale Startinsel, keine finale Datenstruktur, keine Runtime-Konfiguration, keine App-/Assetfreigabe, keine Implementierungsfreigabe, kein Code, kein Asset, kein `frame_started`. |
| M14-B | Word-to-Island Product Preview Plan | `Planung gestartet / Product-Preview textuell definiert` | Reiner Dokumentations- und Visualisierungsplanungsblock in `docs/world_design/299-word-to-island-product-preview-plan.md`. Plant produktnahe Preview-Zustaende, Copy-Regeln, Product-Flow, Beispielpfade und ASCII-Product-Previews fuer Word-to-Island. Visualisierung nur als ASCII-Product-Wireframes, ASCII-Mobile-Frames, ASCII-State-Previews, Mermaid-Flows, Markdown-Tabellen und Product-/Device-/Accessibility-Checklisten. Keine PNGs, keine Tests, keine App-Integration, keine finale Word-to-Island-UI, keine finale Word-to-Island-Implementierung, keine finale Routing-Datenstruktur, keine Runtime-Konfiguration, keine automatische Wortplatzierung, keine App-/Assetfreigabe, keine Implementierungsfreigabe, kein Code, kein Asset, kein `frame_started`. |
| M14-B2 | Word-to-Island Product Preview Visual Review | `Review gestartet / M14-B als Product-Preview-Plan bestaetigt` | Reiner Dokumentations- und Visualisierungs-Reviewblock in `docs/world_design/300-word-to-island-product-preview-visual-review.md`. Prueft den M14-B-Plan visuell/textuell gegen Product-Flow, Sense-/Route-Logik, Safety-/Clutter-Regeln, Copy-Regeln, Product-States, Device-/Accessibility-Regeln und Guardrails. Ergebnis: M14-B ist als Product-Preview-Plan grundsaetzlich brauchbar; kleine Copy-/Layout-Hinweise bleiben fuer spaetere Preview-Bloecke. Visualisierung nur als ASCII-Review-Overlays, ASCII-Mobile-Frames, ASCII-State-Review-Skizzen, Mermaid-Flows, Markdown-Tabellen und Product-/Device-/Accessibility-Review-Checklisten. Keine PNGs, keine Tests, keine App-Integration, keine finale Word-to-Island-UI, keine Word-to-Island-Implementierung, keine finale Routing-Datenstruktur, keine Runtime-Konfiguration, keine automatische Wortplatzierung, keine App-/Assetfreigabe, keine Implementierungsfreigabe, kein Code, kein Asset, kein `frame_started`. |
| M14-C | Container QA Product Preview Plan | `Planung gestartet / Product-Preview textuell definiert` | Reiner Dokumentations- und Visualisierungsplanungsblock in `docs/world_design/301-container-qa-product-preview-plan.md`. Plant produktnahe Preview-Zustaende, Copy-Regeln, Product-Flow, QA-Zonen, Beispielpfade und ASCII-Product-Previews fuer ContainerOpenView, DetailInteractionView und kleine Objektgruppen. Visualisierung nur als ASCII-Product-Wireframes, ASCII-QA-Overlays, ASCII-Mobile-Frames, Mermaid-Flows, Markdown-Tabellen und Product-/Device-/Accessibility-/QA-Checklisten. Keine PNGs, keine Tests, keine App-Integration, keine finale ContainerOpenView-UI, keine finale DetailInteractionView-UI, keine Container-Implementierung, keine finale Datenstruktur, keine Runtime-Konfiguration, keine App-/Assetfreigabe, keine Implementierungsfreigabe, kein Code, kein Asset, kein `frame_started`. |
| M14-C2 | Container QA Product Preview Visual Review | `Review gestartet / M14-C als Product-Preview-Plan bestaetigt` | Reiner Dokumentations- und Visualisierungs-Reviewblock in `docs/world_design/302-container-qa-product-preview-visual-review.md`. Prueft den M14-C-Plan visuell/textuell gegen Product-Wirkung, Beispielpfade, QA-Zonen, Copy-Regeln, Product-States, Device-/Accessibility-Regeln und Guardrails. Ergebnis: M14-C ist als Product-Preview-Plan grundsaetzlich brauchbar; kleine Copy-/Layout-/QA-Hinweise bleiben fuer spaetere Preview-Bloecke. Visualisierung nur als ASCII-Review-Overlays, ASCII-Mobile-Frames, ASCII-State-Review-Skizzen, Mermaid-Flows, Markdown-Tabellen und Product-/Device-/Accessibility-/QA-Review-Checklisten. Keine PNGs, keine Tests, keine App-Integration, keine finale ContainerOpenView-UI, keine finale DetailInteractionView-UI, keine Container-Implementierung, keine finale Datenstruktur, keine Runtime-Konfiguration, keine App-/Assetfreigabe, keine Implementierungsfreigabe, kein Code, kein Asset, kein `frame_started`. |
| M14-D | Device/Accessibility Review Harness Plan | `Planung gestartet / Harness-Pruefung textuell definiert` | Reiner Dokumentations- und Visualisierungsplanungsblock in `docs/world_design/303-device-accessibility-review-harness-plan.md`. Plant nur spaetere Review-Harness-Pruefungen fuer Foundation Choice, Word-to-Island, Sense Selection, Fallbacks, ContainerOpenView, DetailInteractionView, Pagination, Tali/Vori-Bubbles, Safe Exit und Guardrail States. Visualisierung nur als ASCII-Harness-Flows, ASCII-Device-Frames, ASCII-QA-Check-Overlays, Mermaid-Flows, Markdown-Tabellen und Device-/Accessibility-/Tap-Target-/Text-Containment-Checklisten. Keine PNGs, keine Screenshots, keine Tests, keine Widget-Tests, keine Test-Harness-Implementierung, keine Flutter-/Dart-Dateien, keine App-Integration, keine finale UI, keine finale Datenstruktur, keine Runtime-Konfiguration, keine App-/Assetfreigabe, keine Implementierungsfreigabe, kein Code, kein Asset, kein `frame_started`. |
| M14-D2 | Device/Accessibility Review Harness Visual Review | `Review gestartet / M14-D als Harness-Plan bestaetigt` | Reiner Dokumentations- und Visualisierungs-Reviewblock in `docs/world_design/304-device-accessibility-review-harness-visual-review.md`. Prueft den M14-D-Plan visuell/textuell gegen Coverage, Device-/Accessibility-Kategorien, ASCII-Harness-Frames, Harness-States, Runtime-Misread-Prevention und Guardrails. Ergebnis: M14-D ist als Review-Harness-Plan grundsaetzlich brauchbar; kleine Hinweise zu `harness_passed`, spaeteren Review-/Testtypen und nicht-finalen Device-Werten bleiben fuer spaetere Gate-Bloecke. Visualisierung nur als ASCII-Review-Overlays, ASCII-Device-Frames, ASCII-Harness-Review-Skizzen, Mermaid-Flows, Markdown-Tabellen und Device-/Accessibility-/Tap-Target-/Text-Containment-Review-Checklisten. Keine PNGs, keine Screenshots, keine Tests, keine Widget-Tests, keine Test-Harness-Implementierung, keine Flutter-/Dart-Dateien, keine App-Integration, keine finale UI, keine finale Datenstruktur, keine Runtime-Konfiguration, keine App-/Assetfreigabe, keine Implementierungsfreigabe, kein Code, kein Asset, kein `frame_started`. |
| M14-E | Small Implementation Slice Candidate Review | `Gate gestartet / keine Implementierungsfreigabe` | Reiner Dokumentations- und Gate-Reviewblock in `docs/world_design/305-small-implementation-slice-candidate-review.md`. Prueft nur, ob spaetere kleine Slices fuer Foundation Choice, Word-to-Island, Sense Selection, Fallbacks, Container, Device/Accessibility Harness oder bestehende Mock-Slice-Erweiterungen denkbar waeren. Ergebnis: keine direkte Implementierungsfreigabe; spaetere Review-/Harness-Kandidaten sind denkbar; ein sehr kleiner spaeterer Foundation-Choice-Slice koennte nach weiterem Gate theoretisch geprueft werden. `frame_started`, neue Assets, Growth/Garden, Sensitive/Special, Runtime-Konfiguration und automatische Wortplatzierung bleiben blockiert. Visualisierung nur als ASCII-Gate-Flows, ASCII-Decision-Maps, Mermaid-Flows, Markdown-Tabellen und Readiness-/Blocker-/Scope-Matrizen. Keine PNGs, keine Screenshots, keine Tests, keine Widget-Tests, keine Test-Harness-Implementierung, keine Flutter-/Dart-Dateien, keine App-Integration, keine finale UI, keine finale Datenstruktur, keine Runtime-Konfiguration, keine App-/Assetfreigabe, keine Implementierungsfreigabe, kein Code, kein Asset, kein `frame_started`. |
| M14-E2 | Small Implementation Slice Candidate Visual Review | `Review gestartet / M14-E als Candidate Review bestaetigt` | Reiner Dokumentations- und Visualisierungs-Reviewblock in `docs/world_design/306-small-implementation-slice-candidate-visual-review.md`. Prueft nur M14-E visuell/textuell gegen Readiness-Level, Minimal-Slice-Kriterien, Kandidatenmatrix, Gate-Visualisierungen, `frame_started`-Blockade, Harness-Gates und Misread-Risiken. Ergebnis: M14-E ist als Candidate Review grundsaetzlich brauchbar; `implementation-candidate-later` bleibt aber ausdruecklich keine aktuelle Codefreigabe und braucht immer eigenes Gate, separaten Implementierungs-Prompt und ausdrueckliche Nutzerfreigabe. Visualisierung nur als ASCII-Review-Flows, ASCII-Decision-Maps, Mermaid-Flows, Markdown-Tabellen und Readiness-/Blocker-/Scope-Matrizen. Keine PNGs, keine Screenshots, keine Tests, keine Widget-Tests, keine Test-Harness-Implementierung, keine Flutter-/Dart-Dateien, keine App-Integration, keine finale UI, keine finale Datenstruktur, keine Runtime-Konfiguration, keine automatische Wortplatzierung, keine App-/Assetfreigabe, keine Implementierungsfreigabe, kein Code, kein Asset, kein `frame_started`. |
| M14-V1 | Visual Backfill For Docs 283-306 | `Visual Backfill gestartet / PNG-Dokumentationspreviews erzeugt` | Reiner Dokumentations- und Visualisierungsblock in `docs/world_design/307-visual-backfill-283-306.md`. Ergaenzt echte PNG-Dokumentationsvisualisierungen fuer `283` bis `306` unter `docs/world_design/previews/m14_visual_backfill_283_306/`, inklusive Kontaktuebersicht und Generator-Script. Die PNGs sind Dokumentationspreviews, keine finale UI, keine App-Screens, keine Spielassets und keine Asset-Dateien unter `assets/`. Keine App-Integration, keine Flutter-/Dart-Dateien, keine Tests, keine Widget-Tests, keine Test-Harness-Implementierung, keine Screenshots, keine Runtime-Konfiguration, keine App-/Assetfreigabe, keine Implementierungsfreigabe, kein Code, kein `frame_started`. |
| M14-V1-B | Visual Backfill Quality Review | `Review gestartet / PNG-Dokumentationspreviews geprueft` | Reiner Dokumentations- und Reviewblock in `docs/world_design/308-visual-backfill-quality-review.md`. Prueft nur die bestehenden M14-V1-PNGs unter `docs/world_design/previews/m14_visual_backfill_283_306/` auf Existenz, Dateigroesse, Titel, Untertitel, Footer, Text-Containment, Lesbarkeit, Ueberladung und Misread-Risiken. Ergebnis: Die Visuals sind als Dokumentationspreviews brauchbar; `13_small_implementation_candidate_gate.png` braucht nur eine kleine Kontextnote zu `implementation-candidate-later`. Keine neuen PNGs, keine PNG-Aenderungen, keine Tests, keine Widget-Tests, keine Screenshots, keine Flutter-/Dart-Dateien, keine App-Integration, keine Spielassets, keine Asset-Dateien unter `assets/`, keine finale UI, keine Runtime-Konfiguration, keine Implementierungsfreigabe, kein Code, kein `frame_started`. |
| M15-A | Foundation Choice Implementation Gate | `Gate gestartet / keine Implementierungsfreigabe` | Reiner Dokumentations- und Gate-Reviewblock in `docs/world_design/309-foundation-choice-implementation-gate.md`. Prueft nur, ob ein spaeterer minimaler Foundation-Choice-Slice als lokale, nicht persistente, nicht finale Product Preview denkbar waere. Empfehlung: Option 3, ein minimaler spaeterer Slice ist theoretisch denkbar, aber nur mit separatem Implementierungs-Prompt und ausdruecklicher Nutzerfreigabe. Keine PNGs, keine PNG-Aenderungen, keine Screenshots, keine Tests, keine Widget-Tests, keine Flutter-/Dart-Dateien, keine App-Integration, keine finale UI, keine Runtime-Konfiguration, keine Persistenz, keine Supabase Writes, keine SRS-/`word_progress`-Aenderung, keine Reward Bridge, keine App-/Assetfreigabe, keine Implementierungsfreigabe, kein Code, keine automatische Wortplatzierung, kein `frame_started`. |
| M15-A2 | Foundation Choice Minimal Slice Implementation Prompt Draft | `Prompt-Draft gestartet / keine Implementierung` | Reiner Dokumentations- und Prompt-Planungsblock in `docs/world_design/310-foundation-choice-minimal-slice-prompt-draft.md`. Erstellt nur einen spaeteren Copy-&-Paste-Implementierungs-Prompt als Entwurf und markiert ihn ausdruecklich als nicht freigegeben. Der Draft begrenzt einen moeglichen spaeteren Slice auf lokale Preview-/Demo-Darstellung, drei Foundation-Karten, Tali/Vori-Platzhalter, lokale In-Memory-Auswahl, Safe Exit und `spaeter aenderbar`. Keine Implementierung, keine Flutter-/Dart-Dateien, keine Tests, keine Widget-Tests, keine App-Integration, keine finale UI, keine Runtime-Konfiguration, keine Persistenz, keine Supabase Writes, keine SRS-/`word_progress`-Aenderung, keine Reward Bridge, keine PNGs, keine PNG-Aenderungen, keine Screenshots, keine Assets, keine App-/Assetfreigabe, keine Implementierungsfreigabe, kein Code, keine automatische Wortplatzierung, kein `frame_started`. |
| M15-A3 | Foundation Choice Prompt Visual Review | `Visual Review gestartet / keine Implementierungsfreigabe` | Reiner Dokumentations- und Visualisierungsblock in `docs/world_design/311-foundation-choice-prompt-visual-review.md`. Prueft nur den M15-A2-Prompt-Draft visuell/textuell und erzeugt PNG-Dokumentationspreviews unter `docs/world_design/previews/m15_a3_foundation_choice_prompt_visual_review/`: Scope Boundary, Later Prompt Gate Flow, Risk Map, Stop Rules Summary und Contact Sheet. Ergebnis: Prompt-Draft ist brauchbar, kleine Praezisierung zu spaeterem Einstiegspunkt/Testfreigabe bleibt fuer einen echten Implementierungsblock. Keine Implementierung, keine Flutter-/Dart-Dateien, keine Tests, keine Widget-Tests, keine App-Integration, keine finale UI, keine Runtime-Konfiguration, keine Persistenz, keine Supabase Writes, keine SRS-/`word_progress`-Aenderung, keine Reward Bridge, keine Screenshots, keine Spielassets, keine Asset-Dateien unter `assets/`, keine App-/Assetfreigabe, keine Implementierungsfreigabe, kein Code, keine automatische Wortplatzierung, kein `frame_started`. |
| M15-A4 | Foundation Choice Final Pre-Implementation Checklist | `Checkliste gestartet / keine Implementierungsfreigabe` | Reiner Dokumentations- und Checklistenblock in `docs/world_design/312-foundation-choice-final-pre-implementation-checklist.md`. Prueft nur, ob der spaetere Foundation-Choice-Minimal-Slice eng genug fuer ausdrueckliche Nutzerfreigabe waere. Ergebnis: `ready-for-explicit-user-approval`, aber Entry Point und Tests bleiben vor Code explizit zu bestaetigen. Dokumentiert die spaetere Freigabeformulierung, fuehrt sie aber nicht aus. Keine Implementierung, keine Flutter-/Dart-Dateien, keine Tests, keine Widget-Tests, keine App-Integration, keine finale UI, keine Runtime-Konfiguration, keine Persistenz, keine Supabase Writes, keine SRS-/`word_progress`-Aenderung, keine Reward Bridge, keine PNGs, keine PNG-Aenderungen, keine Screenshots, keine Assets, keine App-/Assetfreigabe, keine Implementierungsfreigabe, kein Code, keine automatische Wortplatzierung, kein `frame_started`. |
| M15-B | Foundation Choice Preview Code Review And Visual Harness Plan | `Code Review gestartet / keine Integration` | Enger Code-Review- und Visual-Harness-Planungsblock in `docs/world_design/313-foundation-choice-preview-code-review.md`. Prueft nur den isolierten Preview-Code in `lib/features/world/local_world/ui/widgets/foundation_choice_preview.dart`: nicht integriert, nicht geroutet, nicht exportiert, lokale In-Memory-Auswahl, Safe Exit und `spaeter aenderbar` sichtbar. Ergaenzt eine PNG-Dokumentationspreview unter `docs/world_design/previews/m15_b_foundation_choice_code_review/01_code_scope_review_map.png`. Ergebnis: Scope-konform, nur Minor Note zu `Lernfokus lokal merken` vor spaeterer Integration. Keine App-Integration, keine Home-/Onboarding-/World-Routing-Integration, keine Persistenz, keine Runtime-Konfiguration, keine Supabase Writes, keine lokalen DB-Writes, keine SRS-/`word_progress`-Aenderung, keine Reward Bridge, keine automatische Wortplatzierung, keine Assetfreigabe, keine Tests, keine Widget-Tests, keine Screenshots, kein Build-State, kein `frame_started`. |
| M15-C | Foundation Choice Local Preview Harness Gate | `Harness Gate gestartet / keine Harness-Implementierung` | Reiner Dokumentations- und Gate-Planungsblock in `docs/world_design/314-foundation-choice-local-preview-harness-gate.md`. Prueft nur, ob ein spaeterer isolierter lokaler Preview-Harness fuer `FoundationChoicePreview` sinnvoll und eng genug waere. Ergaenzt PNG-Dokumentationspreviews unter `docs/world_design/previews/m15_c_foundation_choice_local_preview_harness_gate/`: Harness Gate Map, Device Check Scope Map und Contact Sheet. Empfehlung: Ein spaeterer isolierter Preview-Harness ist theoretisch denkbar, aber nur nach eigenem Prompt und ausdruecklicher Freigabe. Keine Harness-Implementierung, keine Flutter-/Dart-Dateien, keine App-Integration, keine Home-/Onboarding-/World-Routing-Integration, keine Tests, keine Widget-Tests, keine Screenshots, keine Runtime-Konfiguration, keine Persistenz, keine Supabase Writes, keine lokalen DB-Writes, keine SRS-/`word_progress`-Aenderung, keine Reward Bridge, keine automatische Wortplatzierung, keine Assetfreigabe, kein Build-State, kein `frame_started`. |
| M15-D | Foundation Choice Local Preview Harness Implementation Gate | `Implementation Gate gestartet / keine Harness-Freigabe` | Reiner Dokumentations- und Gate-Block in `docs/world_design/315-foundation-choice-local-preview-harness-implementation-gate.md`. Prueft nur, ob ein spaeterer isolierter Local Preview Harness fuer `FoundationChoicePreview` als sehr kleiner Implementierungs-Slice sauber freigabefaehig waere. Ergaenzt PNG-Dokumentationspreviews unter `docs/world_design/previews/m15_d_foundation_choice_harness_implementation_gate/`: Harness Implementation Gate Map, Allowed vs Blocked Scope und Contact Sheet. Empfehlung: Ein spaeterer isolierter Harness-Slice ist theoretisch freigabefaehig, aber nur mit separatem Implementierungs-Prompt und ausdruecklicher Nutzerfreigabe. Keine Harness-Implementierung, keine Flutter-/Dart-Dateien, keine App-Integration, keine Home-/Onboarding-/World-Routing-Integration, keine Tests, keine Widget-Tests, keine Screenshots, keine Runtime-Konfiguration, keine Persistenz, keine Supabase Writes, keine lokalen DB-Writes, keine SRS-/`word_progress`-Aenderung, keine Reward Bridge, keine automatische Wortplatzierung, keine Assetfreigabe, kein Build-State, kein `frame_started`. |
| M15-D2 | Foundation Choice Harness Implementation Prompt Draft | `Prompt-Draft gestartet / keine Harness-Implementierung` | Reiner Dokumentations- und Prompt-Planungsblock in `docs/world_design/316-foundation-choice-harness-implementation-prompt-draft.md`. Erstellt nur einen spaeteren Copy-&-Paste-Implementierungs-Prompt fuer einen minimalen isolierten `FoundationChoicePreview`-Harness als Entwurf und markiert ihn ausdruecklich als nicht freigegeben. Ergaenzt PNG-Dokumentationspreviews unter `docs/world_design/previews/m15_d2_foundation_choice_harness_prompt_draft/`: Harness Prompt Scope Boundary, Harness Prompt Execution Flow und Contact Sheet. Keine Harness-Implementierung, keine Flutter-/Dart-Dateien, keine App-Integration, keine Home-/Onboarding-/World-Routing-Integration, keine Tests, keine Widget-Tests, keine Screenshots, keine Runtime-Konfiguration, keine Persistenz, keine Supabase Writes, keine lokalen DB-Writes, keine SRS-/`word_progress`-Aenderung, keine Reward Bridge, keine automatische Wortplatzierung, keine Assetfreigabe, kein Build-State, kein `frame_started`. |
| M16-A | First World Element Slice Scope And Visual Plan | `Scope-/Visual-Plan gestartet / keine Code- oder Assetfreigabe` | Beschleunigter, aber sicherer Planungs- und Visualisierungsblock in `docs/world_design/317-first-world-element-slice-scope-and-visual-plan.md`. Prueft Kandidaten fuer den ersten sichtbaren Welt-/Bau-Element-Slice: neutraler Plot-Marker, Foundation-Fokus-Indikator, lokale Build-Preview-Flaeche, Grundstueck-/Bauplatz-Karte und Plot-/Anchor-Greybox. Empfehlung: neutraler lokaler Plot-Marker als naechster moeglicher Code-Kandidat; lokale Build-Preview-Flaeche als zweitbeste Option. Ergaenzt PNG-Dokumentationspreviews unter `docs/world_design/previews/m16_a_first_world_element_slice/`: Candidate Map, Recommended Next Slice Flow, Allowed vs Blocked Scope und Contact Sheet. Keine Flutter-/Dart-Dateien, keine App-Integration, keine Tests, keine Screenshots, keine Runtime-Konfiguration, keine Persistenz, keine Supabase Writes, keine lokalen DB-Writes, keine SRS-/`word_progress`-Aenderung, keine Reward Bridge, keine automatische Wortplatzierung, keine neuen Spielassets, keine Asset-Dateien unter `assets/`, kein finales Inselbild, kein `frame_started`, keine Bauzustaende. |
| M16-I | Theme Island Plot Capacity And In-Place Build Wheel Plan | `Planung/Visualisierung gestartet / keine Implementierung` | Reiner Dokumentations- und Visualisierungsblock in `docs/world_design/318-theme-island-plot-capacity-and-build-wheel-plan.md`. Schaerft die ThemeIsland-Regel: Theme analysieren, benoetigte Grundstuecke ableiten, Groessen bestimmen, Inselkapazitaet/Layout ableiten, austauschbare Slots platzieren und spaeter ein In-Place Build-Wheel als Overlay planen. Ergaenzt PNG-Dokumentationspreviews unter `docs/world_design/previews/m16_i_theme_island_plot_capacity_build_wheel/`: Theme-to-Plot Pipeline, Village Plot Capacity Map, In-Place Build Wheel Flow, Allowed vs Blocked Scope und Contact Sheet. Keine Flutter-/Dart-Dateien, keine App-Integration, keine Route, keine neue Seite, keine Build-Wheel-Implementierung, keine Tests, keine Screenshots, keine Runtime-Konfiguration, keine Persistenz, keine Assets, keine automatische Wortplatzierung, kein Build-State, kein `frame_started`, keine Bauzustaende. |
| M16-J | Village Plot Capacity Local Preview Scope | `Scope-/Visual-Plan gestartet / keine Implementierung` | Beschleunigter, aber sicherer Dokumentations- und Visualisierungsblock in `docs/world_design/319-village-plot-capacity-local-preview-scope.md`. Leitet aus M16-I einen spaeteren lokalen Multi-Slot-Preview-Kandidaten `VillagePlotCapacityPreview` fuer Dorf/Zuhause/Alltag ab. Slot-Struktur: Haus gross, Garage/Carport mittel, Garten gross/flexibel, Beet/Feld mittel/gross, Vorhof mittel, Baum/Natur klein/mittel, Weg/Platz verbindend, Erweiterung reserve. Ergaenzt PNG-Dokumentationspreviews unter `docs/world_design/previews/m16_j_village_plot_capacity_local_preview/`: Slot Size Map, Slot Exchangeability Flow, Allowed vs Blocked Scope und Contact Sheet. Keine Flutter-/Dart-Dateien, keine App-Integration, keine Route, keine neue Seite, keine Build-Wheel-Implementierung, keine Tests, keine Screenshots, keine Runtime-Konfiguration, keine Persistenz, keine Assets, keine automatische Wortplatzierung, kein Build-State, kein `frame_started`, keine Bauzustaende. |
| M16-K | Global ThemeIsland Category Plot Capacity Matrix | `globale Matrix gestartet / M16-J eingeordnet` | Reiner Dokumentations- und Visualisierungsblock in `docs/world_design/320-global-theme-island-plot-capacity-matrix.md`. Sammelt die bereits dokumentierten Kategorien aus Taxonomy, Priorisierung, Routing, Plot-Capability, Roadmap und Capability-Sheets: Zuhause/Alltag, Schule/Lernen, Garten/Natur, Kueste/Meer/Hafen/Strand, Essen/Restaurant/Cafe, Einkauf/Versorgung, Land/Farm, Stadt/Dorfzentrum, Verkehr/Reisen, Arbeit/Industrie, Freizeit/Outdoor/Sport, Technik/Digital, oeffentliche Gebaeude/Verwaltung, Gesundheit/Notfall, Kultur/Gesellschaft und sensible Bereiche. M16-J bleibt ein Dorf-Beispiel, nicht die globale Grundlage. Ergaenzt PNG-Dokumentationspreviews unter `docs/world_design/previews/m16_k_global_theme_island_plot_capacity_matrix/`: Global Category Map, Size Mix Comparison, Coast/Harbor Example, Allowed vs Blocked Scope und Contact Sheet. Keine Flutter-/Dart-Dateien, keine App-Integration, keine Route, keine neue Seite, keine Build-Wheel-Implementierung, keine Tests, keine Screenshots, keine Runtime-Konfiguration, keine Persistenz, keine Assets, keine automatische Wortplatzierung, kein Build-State, kein `frame_started`, keine Bauzustaende. |
| M16-L | Global World Semantics Consistency Audit | `Audit/Visualisierung gestartet / Pflichtfilter fuer Folgeprompts` | Reiner Dokumentations-, Audit- und Visualisierungsblock in `docs/world_design/321-global-world-semantics-consistency-audit.md`. Konsolidiert bestehende Regeln aus Taxonomy, Word-to-Island Routing, Plot-Capabilities, Sensitive Policy, Mobile/Clutter, Depth/Container, Asset Scope und M16-I/J/K. Ergebnis: M16-J bleibt brauchbares Dorf-Beispiel, aber nicht alleiniger Commit-/Code-Kandidat; M16-K bleibt brauchbare globale Kategorie-Matrix, muss aber durch Word-Type-Routing, Multi-Home, Representation Decision und Codex/Blueprint/Backlog-Fallbacks ergaenzt werden. Ergaenzt PNG-Dokumentationspreviews unter `docs/world_design/previews/m16_l_global_world_semantics_consistency_audit/`: Semantics Decision Pipeline, Word Type Representation Map, Multi-Home Examples, M16-I/J/K Gap Map, Future Prompt Checklist und Contact Sheet. Keine Flutter-/Dart-Dateien, keine App-Integration, keine Route, keine neue Seite, keine Tests, keine Screenshots, keine Runtime-Konfiguration, keine Persistenz, keine Assets, keine automatische Wortplatzierung, kein Build-State, kein `frame_started`, keine Bauzustaende. |
| M16-M | Next Safe Preview Slice Decision Gate | `Entscheidungs-Gate gestartet / naechster Preview-Kandidat empfohlen` | Reiner Dokumentations- und Entscheidungsblock in `docs/world_design/322-next-safe-preview-slice-decision-gate.md`. Vergleicht `VillagePlotCapacityPreview`, `GlobalThemeIslandPreviewSelector`, `CoastHarborPlotCapacityPreview`, `WordSemanticsDecisionPreview` und `BuildWheelOverlayPreviewPlan` nach Architektur-Sicherheit, Spielnaehe, Misread-Risiko, M16-L-Naehe, Mobile-Lesbarkeit, Assetfreiheit, Auto-Placement-Risiko, Build-State-Risiko und naechstem Codewert. Entscheidung: `WordSemanticsDecisionPreview` ist der sicherste naechste Preview-Kandidat; Dorf bleibt zu eng, Global Selector wirkt zu stark wie Onboarding, Coast/Harbor ist wegen Water/Dock/Boat-Gates noch riskant, Build-Wheel ist zu frueh. Ergaenzt PNG-Dokumentationspreviews unter `docs/world_design/previews/m16_m_next_safe_preview_slice_decision_gate/`: Candidate Matrix, Risk/Value Map, Recommended Flow, Allowed vs Blocked Scope und Contact Sheet. Keine Flutter-/Dart-Dateien, keine App-Integration, keine Route, keine neue Seite, keine Build-Wheel-Implementierung, keine Tests, keine Screenshots, keine Runtime-Konfiguration, keine Persistenz, keine Assets, keine automatische Wortplatzierung, kein Build-State, kein `frame_started`, keine Bauzustaende. |
| M16-N | Word Semantics Decision Preview Scope | `Scope/Visualisierung gestartet / keine Implementierung` | Reiner Dokumentations- und Visualisierungsblock in `docs/world_design/323-word-semantics-decision-preview-scope.md`. Konkretisiert die M16-M-Empfehlung `WordSemanticsDecisionPreview`: Word/User Intent -> Context/Sense -> Word-Type -> Safety -> Theme Candidates -> Plot/Depth -> Representation Decision -> User Choice -> Preview Only -> Later Gate. Beispielkarten fuer `Haus`, `Garage`, `Baum`, `schwimmen`, `Angst`, `lernen`, `Messer` und `Polizei` zeigen Multi-Home, Action, Emotion, Container, Sensitive und Policy Gates. Ergaenzt PNG-Dokumentationspreviews unter `docs/world_design/previews/m16_n_word_semantics_decision_preview_scope/`: Pipeline, Example Cards, Representation Outputs, Allowed vs Blocked Scope und Contact Sheet. Keine Flutter-/Dart-Dateien, keine App-Integration, keine Route, keine neue Seite, keine Tests, keine Screenshots, keine Runtime-Konfiguration, keine Persistenz, keine Assets, keine automatische Wortplatzierung, kein Build-State, kein `frame_started`, keine Bauzustaende. |
| M16-O | Word Semantics Preview Implementation Gate | `Implementation Gate gestartet / keine Implementierung` | Reiner Dokumentations- und Gate-Block in `docs/world_design/324-word-semantics-preview-implementation-gate.md`. Prueft, ob ein spaeterer minimaler isolierter `WordSemanticsDecisionPreview`-Code-Slice sinnvoll und sicher genug waere. Gate-Entscheidung: theoretisch spaeter moeglich, aber nur als isoliertes lokales Preview-Widget unter `lib/features/world/local_world/ui/widgets/`, ohne echte Routing-Implementierung, ohne finale Datenstruktur, ohne App-Integration, ohne Route, ohne Persistenz, ohne Assets, ohne automatische Wortplatzierung, ohne Build-State und ohne `frame_started`. Ergaenzt PNG-Dokumentationspreviews unter `docs/world_design/previews/m16_o_word_semantics_preview_implementation_gate/`: Gate Scope Map, Allowed Later vs Blocked Now, File Boundary Map, Example Word Guardrail Map und Contact Sheet. Keine Flutter-/Dart-Dateien, keine App-Integration, keine Route, keine neue Seite, keine Tests, keine Screenshots, keine Runtime-Konfiguration, keine Persistenz, keine Assets, keine automatische Wortplatzierung, kein Build-State, kein `frame_started`, keine Bauzustaende. |
| M16-P | Word Semantics Decision Preview Implementation Prompt Draft | `Prompt-Draft gestartet / keine Implementierung` | Reiner Dokumentations- und Prompt-Draft-Block in `docs/world_design/325-word-semantics-preview-implementation-prompt-draft.md`. Bereitet einen spaeteren Copy-&-Paste-Implementierungs-Prompt fuer einen minimalen isolierten `WordSemanticsDecisionPreview`-Code-Slice vor, fuehrt ihn aber nicht aus. Der spaetere Scope bleibt auf `lib/features/world/local_world/ui/widgets/word_semantics_decision_preview.dart` und optionalen Launch-Target nach separater Freigabe beschraenkt; Beispielwortkarten, lokale `setState`-Auswahl, Context/Sense, Word Type, Safety/Sensitive, Candidate ThemeIsland(s), Candidate Plot/Depth, Representation Decision und Preview Only/Later Gate sind nur als spaetere lokale Preview geplant. Ergaenzt PNG-Dokumentationspreviews unter `docs/world_design/previews/m16_p_word_semantics_preview_prompt_draft/`: Prompt Scope Boundary, Later Prompt Execution Flow, Preview Widget Content Map, Stop Rules und Contact Sheet. Keine Flutter-/Dart-Dateien, keine neue Dart-Datei, keine App-Integration, keine Route, keine neue Seite, keine Tests, keine Screenshots, keine Runtime-Konfiguration, keine Persistenz, keine Assets, keine automatische Wortplatzierung, kein Build-State, kein `frame_started`, keine Bauzustaende. |
| M16-R | Scalable Word Semantics Architecture Plan | `Architekturplanung/Visualisierung gestartet / keine Implementierung` | Reiner Dokumentations- und Visualisierungsblock in `docs/world_design/326-scalable-word-semantics-architecture-plan.md`. Klaert, dass `WordSemanticsDecisionPreview` mit acht Beispielwoertern nur ein lokaler Architektur-Prototyp ist und nicht das Massensystem fuer tausende oder 20.000+ Woerter. Zentrale Regel: 20.000 Woerter werden nicht zu 20.000 sichtbaren Karten, Weltobjekten, Grundstuecken oder Gebaeuden, sondern zu moeglichen Semantic Profiles, gefilterten Vorschlaegen, Safe Fallbacks und kleinen Review-Queues. Ergaenzt PNG-Dokumentationspreviews unter `docs/world_design/previews/m16_r_scalable_word_semantics_architecture/`: Many Words Pipeline, Status Lifecycle, Mass Word UI Strategy, Allowed vs Blocked Scope und Contact Sheet. Keine Flutter-/Dart-Dateien, keine App-Integration, keine Route, keine neue Seite, keine Tests, keine Screenshots, keine Runtime-Konfiguration, keine Persistenz, keine Assets, keine automatische Wortplatzierung, kein Build-State, kein `frame_started`, keine Bauzustaende. |
| Phase 2H | `building_level_1` | `geplant` / spaeter | Erst nach Rohbau-Qualitaet und Balancing. |

Aktuell erlaubter naechster Schritt:

Phase 2E-E ist abgeschlossen und committed:
`c82880e4 feat: polish forest clearing foundation guidance`.

Phase 2F ist abgeschlossen und committed:
`b13d2162 fix: refine foundation complete guidance flow`.

Phase 2G ist als Planungsblock gestartet:
`docs/world_design/243-frame-started-plan.md`.

Der Asset-Prompt-/Freigabeblock fuer `frame_started` ist vorbereitet:
`docs/world_design/244-frame-started-asset-prompt.md`.

Der Anchor-/Alignment-Definitionsblock fuer `frame_started` ist gestartet:
`docs/world_design/245-build-alignment-and-anchor-system.md`.

Der Masterlayout-/Plot-System-Block fuer die Waldlichtung ist gestartet:
`docs/world_design/246-island-master-layout-and-modular-plot-system.md`.

Der Greybox-/Scale-/Plot-Messblock ist gestartet:
`docs/world_design/247-island-greybox-scale-and-plot-metrics.md`.

Der konkrete Plot-Metrik-/Koordinaten-Greybox-Block ist gestartet:
`docs/world_design/248-island-plot-metrics-and-greybox-layout.md`.

Der sichtbare Greybox-Preview-/Layout-Pruefblock ist gestartet:
`docs/world_design/249-island-greybox-preview-plan.md`.

Der Debug-Greybox-Preview-Erzeugungsblock ist gestartet. Preview-Dateien
wurden als Dokumentationsmaterial erzeugt:
`docs/world_design/previews/phase2g_m3_island_greybox/`.

Der visuelle Greybox-Layout-Review ist gestartet:
`docs/world_design/250-island-greybox-layout-review.md`.

Die nachgebesserte Variante-B-Debug-Greybox wurde erzeugt:
`docs/world_design/previews/phase2g_m5_island_greybox_variant_b/`.

Die manuelle Sichtpruefung fuer Variante B wurde vorbereitet:
`docs/world_design/251-island-greybox-variant-b-manual-review.md`.

Die Variante-B-Greybox darf nach der Nutzerpruefung nicht als feste
Gebaeudeanordnung bestaetigt werden. Die flexible Plot-/Learning-Semantics-
Planung ist gestartet:
`docs/world_design/252-flexible-plot-placement-and-learning-semantics.md`.
Die Planung wurde in Phase 2G-M6-B mit konkreter Entscheidungslogik vertieft:
Placement Decision Pipeline, Capability Matrix, Word Placement Requirements,
Visual Representation Tiers, User Choice, Ambiguity Handling, Visual Clutter
und Rebuild/Move/Personalization.
Die Planung wurde in Phase 2G-M6-C erneut vertieft: abstrakte
Datenmodell-Skizzen, Learning Progress vs. Build Progress, Browser-/Real-
World-Import, Representation Priority, Sensitive/Abstract Handling und
Learning Mode Integration.
Die Planung wurde in Phase 2G-M6-D erneut vertieft: Progression ohne feste
Baureihenfolge, First Session / Free Start Choice, Import Governance,
User Goal / Category Priority und Next Greybox Renaming Requirements.
Die Planung wurde in Phase 2G-M6-E erneut vertieft: Personal Learning
Archipelago, Candidate Theme Islands, First Island Choice, Island Roadmap,
Theme Islands mit flexiblen Plot-Slots, Word-to-Island Routing, Free/Paid-
Prinzipien und Production Scope Control.
Die Planung wurde in Phase 2G-M6-F erneut vertieft: Archipelago Navigation,
Shared Codex/Blueprint/Backlog, Cross-Island Word Routing, Multi-Home Words,
Island Slot Lifecycle, Island Ownership/Identity und UX Complexity Control.

Die Planung wurde in Phase 2G-M7 als abstrakte Capability-Greybox-Planung
gestartet:
`docs/world_design/253-capability-greybox-plan.md`.
M7 ersetzt feste Variante-B-Rollenlabels durch neutrale Plot-Slots und
bereitet `allowedFunctions`, `isUserSelectable`, `unlockState`, Anchors,
Sockets und Footprints fuer eine spaetere Debug-Greybox vor.

Die Debug-Capability-Greybox wurde in Phase 2G-M7-B erzeugt:
`docs/world_design/previews/phase2g_m7_capability_greybox/`.
Die Preview-Dateien sind nur Dokumentations-/Debugmaterial.

Die visuelle Pruefung wurde in Phase 2G-M7-C gestartet:
`docs/world_design/254-capability-greybox-visual-review.md`.
M7-B ist als technische Debug-Greybox grundsaetzlich brauchbar. Eine
vereinfachte Nutzer-/Produktansicht bleibt als moeglicher M7-D-Schritt offen.

Der World-Depth-/Gameplay-/Retention-Researchblock wurde in Phase 2G-M8
gestartet:
`docs/world_design/255-world-depth-gameplay-retention-research.md`.
M8 klaert, dass `objectAnchors` optionale technische Moeglichkeiten sind, dass
kleine Woerter in Interior-, Object-, Container- und Detailansichten gehoeren
koennen, und dass Talvori Aufgaben, Challenges, Rewards und Progression
braucht, statt nur eine Museumsansicht zu sein.

Die vereinfachte Depth-/Container-Nutzerflow-Preview wurde in Phase 2G-M9
gestartet:
`docs/world_design/256-depth-container-user-flow-preview-plan.md`.
Die Preview-Dateien liegen unter
`docs/world_design/previews/phase2g_m9_depth_container_user_flow/` und zeigen
den Beispiel-Flow Haus/Kueche -> Schublade -> Besteck mit Storyboard,
Depth-Level-Stack und Interaction-/Reward-Loop.

Der naechste sinnvolle Schritt ist nicht Phase-2G-Code und nicht
Asset-Freigabe. Die visuelle M9-B-Pruefung bestaetigt M9 als ersten
vereinfachten Beispiel-Flow grundsaetzlich, blockiert aber jede allgemeine
Container-Systementscheidung aus nur einem Kuechenbeispiel. Phase 2G-M10 hat
den ersten Follow-up-Punkt als emotionalere Produktflow-Preview erzeugt.
Phase 2G-M10-D bewertet M10 als grundsaetzlich brauchbar. Phase 2G-M10-B hat
den Challenge-Interaktionsvergleich gestartet und Preview-Dateien unter
`docs/world_design/previews/phase2g_m10b_challenge_interaction_comparison/`
erzeugt. Phase 2G-M10-B2 bewertet diese Previews visuell als grundsaetzlich
brauchbare erste Challenge-Empfehlung. Phase 2G-M10-C hat den Tali/Vori
Companion Reaction Flow gestartet und Preview-Dateien unter
`docs/world_design/previews/phase2g_m10c_companion_reaction_flow/` erzeugt.
Phase 2G-M10-C2 bewertet M10-C als grundsaetzlich brauchbare erste
Companion-Reaktionsrichtung. Phase 2G-M11 wurde danach als Multi-Example
Container Flow Preview gestartet und erzeugt Preview-Dateien unter
`docs/world_design/previews/phase2g_m11_multi_example_container_flows/`.
Phase 2G-M11-B bewertet diese Previews als grundsaetzlich brauchbare
Multi-Flow-Richtung. Als naechster Schritt sind nur dokumentarische
Folgepruefungen erlaubt: Mobile-Komplexitaet fuer Hafen/Bootskajute,
Clutter-/Kleinteile fuer Schule/Federmappe, Fairness-/Timer fuer
Gartenwachstum oder ein weiterer reiner Planungsblock fuer Container-
Systemarchitektur. Phase 2G-M11-C hat zusaetzlich den World Content
Taxonomy-/Location-Katalog gestartet. Als naechster Schritt ist nur Review
oder weitere Strukturierung dieses Katalogs erlaubt. Die Preview-Dateien und
der Katalog sind kein finales Inselbild, keine finale UI, keine Spielassets,
keine Assetliste und keine finale ThemeIsland-Roadmap. `frame_started` bleibt
gestoppt.

Phase 2G-M11-C2 bewertet den Taxonomy-Katalog als erste
Content-/Location-Grundlage grundsaetzlich brauchbar. Als naechster Schritt
ist nur ein reiner Planungsblock fuer ThemeIsland-Priorisierung,
Word-to-Island-Routing-Matrix, Plot-Capability-Ableitung,
Sensitive-Content-Regeln oder Mobile-/Clutter-Regeln erlaubt. Keine
Taxonomy-Kategorie darf dadurch automatisch zur Asset-, Code- oder
ThemeIsland-Umsetzung werden.

Phase 2G-M12 priorisiert ThemeIsland-Kandidaten nur als Planungsgrundlage.
Als naechster Schritt ist nur visuelle M12-Pruefung, M12-Nachbesserung,
M12-B Word-to-Island Routing Matrix, M12-C Plot-Capability Derivation,
M12-D Sensitive Content Representation Rules oder M12-E Mobile And Clutter
Rules erlaubt. Keine ThemeIsland-Umsetzung, keine finale Roadmap und keine
Assetproduktion duerfen aus M12 abgeleitet werden.

Phase 2G-M12-A2 bewertet M12 als erste ThemeIsland-Priorisierung
grundsaetzlich brauchbar. Als naechster Schritt ist nur M12-B
Word-to-Island Routing Matrix, M12-C Plot-Capability Derivation, M12-D
Sensitive Content Representation Rules, M12-E Mobile And Clutter Rules oder
eine begruendete M12-Nachbesserung erlaubt. Keine Early-Insel darf ohne
Routing, Capabilities und passende Mobile-/Clutter-/Fairness-Regeln in
Umsetzung gehen.

Phase 2G-M12-B startet die Word-to-Island Routing Matrix als Planungs- und
Previewgrundlage. Als naechster Schritt ist nur M12-B-Review, M12-B-
Nachbesserung, M12-C Plot-Capability Derivation, M12-D Sensitive Content
Representation Rules oder M12-E Mobile And Clutter Rules erlaubt. Keine
Routing-Implementierung, keine automatische Wortplatzierung, keine
Datenstruktur-Freigabe, keine ThemeIsland-Umsetzung und keine Assetproduktion
duerfen aus M12-B abgeleitet werden.

Phase 2G-M12-B2 bewertet M12-B als erste Routing-Planungsrichtung
grundsaetzlich brauchbar. Als naechster Schritt ist nur M12-B2-Review,
M12-B/M12-B2-Nachbesserung, M12-C Plot-Capability Derivation, M12-D Sensitive
Content Representation Rules oder M12-E Mobile And Clutter Rules erlaubt.
Keine finale Routing-Implementierung, keine automatische Wortplatzierung,
keine Datenstruktur-Freigabe, keine ThemeIsland-Umsetzung und keine
Assetfreigabe duerfen aus M12-B2 abgeleitet werden.

Phase 2G-M12-C startet die Plot-Capability Derivation als Planungs- und
Previewgrundlage. Als naechster Schritt ist nur M12-C-Review, M12-C-
Nachbesserung, M12-D Sensitive Content Representation Rules oder M12-E Mobile
And Clutter Rules erlaubt. Keine finale Plot-Datenstruktur, keine Runtime-
Konfiguration, keine Plot-Implementierung, keine ThemeIsland-Umsetzung und
keine Assetfreigabe duerfen aus M12-C abgeleitet werden.

Phase 2G-M12-C2 bewertet M12-C als erste Plot-Capability-Planungsrichtung
grundsaetzlich brauchbar. Als naechster Schritt ist nur M12-C2-Review,
M12-C/M12-C2-Nachbesserung, M12-D Sensitive Content Representation Rules oder
M12-E Mobile And Clutter Rules erlaubt. Keine finale Plot-Datenstruktur,
keine Runtime-Konfiguration, keine Plot-Implementierung, keine ThemeIsland-
Umsetzung und keine Assetfreigabe duerfen aus M12-C2 abgeleitet werden.

Phase 2G-M12-D startet die Sensitive Content Representation Rules als
Planungs- und Previewgrundlage. Als naechster Schritt ist nur M12-D-Review,
M12-D-Nachbesserung oder M12-E Mobile And Clutter Rules erlaubt. Keine finale
Safety-Implementierung, keine Moderations-Implementierung, keine automatische
Visualisierung sensibler Begriffe, keine sensible ThemeIsland-Umsetzung und
keine Assetfreigabe duerfen aus M12-D abgeleitet werden.

Phase 2G-M12-D2 bewertet M12-D als erste Sensitive-Content-Planungsrichtung
grundsaetzlich brauchbar. Als naechster Schritt ist nur M12-D2-Review,
M12-D/M12-D2-Nachbesserung oder M12-E Mobile And Clutter Rules erlaubt. Keine
finale Safety-Implementierung, keine Moderations-Implementierung, keine
automatische Visualisierung sensibler Begriffe, keine sensible ThemeIsland-
Umsetzung und keine Assetfreigabe duerfen aus M12-D2 abgeleitet werden.

Phase 2G-M12-E startet Mobile And Clutter Rules For Small Objects als
Planungs- und Previewgrundlage. Preview-Dateien liegen unter
`docs/world_design/previews/phase2g_m12e_mobile_clutter_rules/`. M12-E klaert
erste Planungswerte und Stop-Gates fuer TinyObjects, SmallTools,
ContainerItems, AmbientDecoration, InteractiveFocusObjects, BuildingParts,
SequenceObjects und SensitiveSmallObjects. Als naechster Schritt ist nur
M12-E-Review, M12-E-Nachbesserung oder ein begruendeter Folgeblock fuer
Mobile-/Clutter-/Accessibility-Pruefung erlaubt. Keine finale Mobile-UI,
keine finale Datenstruktur, keine Runtime-Konfiguration, keine Container-
Implementierung, keine ThemeIsland-Umsetzung und keine Assetfreigabe duerfen
aus M12-E abgeleitet werden.

Phase 2G-M12-E2 bewertet M12-E als erste Mobile-/Clutter-Planungsrichtung
grundsaetzlich brauchbar. Als naechster Schritt ist nur M12-E2-Review,
M12-E/M12-E2-Nachbesserung oder ein spaeterer Folgeblock fuer echte Device-,
Accessibility-, Pagination- oder Tap-Target-Pruefung erlaubt. Keine finale
Mobile-UI, keine finale Datenstruktur, keine Runtime-Konfiguration, keine
Container-Implementierung, keine automatische Wortplatzierung, keine
ThemeIsland-Umsetzung und keine Assetfreigabe duerfen aus M12-E2 abgeleitet
werden.

Phase 2G-M12-F bewertet die gesamte M12-Kette als konsolidierte
Planungsgrundlage. Als naechster Schritt ist nur M12-F-Review,
M12-F-Nachbesserung oder ein reiner M13-Folgeplanungsblock erlaubt. Keine
finale ThemeIsland-Roadmap, keine Implementierungsfreigabe, keine finale
Datenstruktur, keine Runtime-Konfiguration, keine automatische Wortplatzierung,
keine App-/Assetfreigabe und kein `frame_started` duerfen aus M12-F abgeleitet
werden.

Phase 2G-M13 startet den ThemeIsland Roadmap Draft als Planungs- und
Visualisierungsblock. Preview-Dateien liegen unter
`docs/world_design/previews/phase2g_m13_theme_island_roadmap_draft/`. Als
naechster Schritt ist nur M13-Review, M13-Nachbesserung, M13-B Onboarding
Choice Review, M13-C ThemeIsland Capability Sheets, M13-D
Word-to-Island-UX-Flow, M13-E Device And Accessibility Preview Plan,
M13-F Container Pagination And Tap Target Rules oder M13-G Sensitive Content
Policy Deepening, M13-H Growth And Timer Fairness Rules oder M13-I Asset
Prioritization Scope Gate oder M13-J Consolidated M13 Readiness Review erlaubt.
Keine finale ThemeIsland-Roadmap, keine ThemeIsland-Umsetzung, keine
Implementierungsfreigabe, keine finale Datenstruktur, keine
Runtime-Konfiguration, keine automatische Wortplatzierung, keine App-/
Assetfreigabe und kein `frame_started` duerfen aus M13 abgeleitet werden.

Phase 2G-M13-A2 bewertet den ThemeIsland Roadmap Draft visuell und inhaltlich
als ersten brauchbaren Roadmap-Draft. Die Bestaetigung gilt nur fuer die
Planungsrichtung der Roadmap-Wellen und nicht fuer eine finale Startinsel,
ThemeIsland-Umsetzung, finale Datenstruktur, Runtime-Konfiguration,
Implementierungsfreigabe oder App-/Assetfreigabe. Als naechster sinnvoller
reiner Planungsblock bleibt M13-B Early Island Onboarding Choice Review offen.

Phase 2G-M13-B startet den Early Island Onboarding Choice Review als reinen
Planungs- und Visualisierungsblock. Preview-Dateien liegen unter
`docs/world_design/previews/phase2g_m13b_early_island_onboarding_choice/`.
Die vorlaeufige Empfehlung ist ein Hybrid: kurze Tali/Vori-Frage, drei
Foundation-Karten, reversible Bestaetigung und Codex-/Blueprint-/Backlog-
Fallback fuer unpassende Woerter. Daraus folgen keine finale Onboarding-UI,
keine finale Startinsel, keine Onboarding-Implementierung, keine
ThemeIsland-Umsetzung, keine finale Datenstruktur, keine Runtime-Konfiguration,
keine App-/Assetfreigabe und kein `frame_started`.

Phase 2G-M13-B2 bewertet die M13-B-Previews visuell und inhaltlich. Ergebnis
fuer den Review-Stand: Hybrid ist als erste Onboarding-Choice-
Planungsrichtung brauchbar, weil er kurze Tali/Vori-Erklaerung, drei
Foundation-Karten, reversible Bestaetigung und Codex-/Blueprint-/Backlog-
Fallback verbindet. Daraus folgen keine finale Onboarding-UI, keine finale
Startinsel, keine Onboarding-Implementierung, keine ThemeIsland-Umsetzung,
keine finale Datenstruktur, keine Runtime-Konfiguration, keine automatische
Wortplatzierung, keine App-/Assetfreigabe und kein `frame_started`.

Phase 2G-M13-C startet ThemeIsland Capability Sheets als reinen
Dokumentationsblock. Die Sheets konkretisieren Lernbereiche, Worttypen,
Zonen, Plot-/Gebaeude-Faehigkeiten, Container-/Depth-Ideen, Gates und Risiken
fuer Foundation, Expansion, System-Heavy und Sensitive/Special. Sie sind nur
Planungsstruktur: keine finale Roadmap, keine finale Startinsel, keine finale
Datenstruktur, keine Runtime-Konfiguration, keine ThemeIsland-Umsetzung, keine
App-/Assetfreigabe, kein Code und kein `frame_started`.

Phase 2G-M13-D startet den Word-to-Island UX Flow als reinen
Dokumentationsblock. M13-D beschreibt aus Nutzersicht, wie ein gelerntes,
importiertes oder manuell hinzugefuegtes Wort ueber Kontext/Sense, Worttyp,
Safety, ThemeIsland-Kandidat, Depth-Kandidat und Nutzerentscheidung zu
PlacementCandidate, Blueprint, Codex oder Backlog gefuehrt wird. Der Flow
bleibt Planungsstruktur: keine finale Routing-Implementierung, keine finale
Routing-Datenstruktur, keine Runtime-Konfiguration, keine automatische
Wortplatzierung, keine ThemeIsland-Umsetzung, keine App-/Assetfreigabe, kein
Code und kein `frame_started`.

Phase 2G-M13-E startet den Device And Accessibility Preview Plan als reinen
Dokumentationsblock. M13-E klaert, wie spaetere Previews vor einer Umsetzung
gegen Device-Groessen, Portrait-Fokus, Tap-Ziele, Text-Containment,
Accessibility, Mobile-Clutter und UX-Komplexitaet geprueft werden. Der Block
erzeugt keine Preview-PNGs, keine Tests, keine App-Integration, keine finale
UI, keine finale Datenstruktur, keine Runtime-Konfiguration, keine App-/
Assetfreigabe, keinen Code und kein `frame_started`.

Phase 2G-M13-F startet Container Pagination And Tap Target Rules als reinen
Dokumentations- und Visualisierungsplanungsblock. M13-F klaert, wie
ContainerOpenView, DetailInteractionView, kleine Objektgruppen und
Lernobjekte spaeter ueber Pagination, klare Fokusobjekte, ausreichend grosse
Tap-Ziele, kontextuelle Labels, Clutter-Begrenzung und QA-Overlay-Regeln
mobile bedienbar bleiben. Der Block nutzt nur Mermaid, ASCII-Wireframes und
Markdown-Tabellen. Er erzeugt keine PNGs, keine Tests, keine App-Integration,
keine finale UI, keine finale Datenstruktur, keine Runtime-Konfiguration,
keine App-/Assetfreigabe, keinen Code und kein `frame_started`.

Phase 2G-M13-G startet Sensitive Content Policy Deepening als reinen
Dokumentations- und Visualisierungsplanungsblock. M13-G vertieft sensible
Kategorien, Safe Representation Tiers, automatische Visualisierungsstopps,
Tali/Vori-Verhalten, User-Control, Privacy und harte Policy-Gates. Der Block
nutzt nur Mermaid, ASCII-Flows, Markdown-Tabellen und Policy-Matrizen. Er
erzeugt keine PNGs, keine Tests, keine App-Integration, keine finale Safety-
Implementierung, keine Moderations-Implementierung, keine finale
Datenstruktur, keine Runtime-Konfiguration, keine automatische Klassifikation,
keine App-/Assetfreigabe, keinen Code und kein `frame_started`.

Phase 2G-M13-H startet Growth And Timer Fairness Rules als reinen
Dokumentations- und Visualisierungsplanungsblock. M13-H vertieft faire
Wachstumsarten, Timer-Regeln, weiche Daily-/Comeback-Momente, Tali/Vori-
Erinnerungston, Fairness-Gates und harte Blocker gegen Verfall, Schuld,
FOMO, Pay-to-Win und monetarisierte Streak-Rettung. Der Block nutzt nur
Mermaid, ASCII-Flows, Markdown-Tabellen, Fairness-/Timer-Matrizen und
Decision-Flows. Er erzeugt keine PNGs, keine Tests, keine App-Integration,
keine finale Growth-Implementierung, keine Timer-Implementierung, keine
Retention-Implementierung, keine Monetarisierungsregel, keine finale
Datenstruktur, keine Runtime-Konfiguration, keine App-/Assetfreigabe, keinen
Code und kein `frame_started`.

Phase 2G-M13-I startet Asset Prioritization Scope Gate als reinen
Dokumentations- und Visualisierungsplanungsblock. M13-I vertieft
Asset-Kategorien, Prioritaetslogik, Scope-Gates, harte Blocker und
Entscheidungsflows gegen automatische Assetproduktion aus Taxonomy, Roadmap,
Routing, Capability Sheets, Onboarding, Growth- oder Sensitive-Planung. Der
Block nutzt nur Mermaid, ASCII-Flows, Markdown-Tabellen, Scope-/Asset-Matrizen
und Gate-/Decision-Flows. Er erzeugt keine PNGs, keine Tests, keine App-
Integration, keine Assetproduktion, keine finale Assetliste, keine finale
Produktionsfreigabe, keine finale Datenstruktur, keine Runtime-Konfiguration,
keine App-/Assetfreigabe, keinen Code und kein `frame_started`.

Phase 2G-M13-J startet Consolidated M13 Readiness Review als reinen
Dokumentations- und Visualisierungsplanungsblock. M13-J prueft M13-B bis M13-I
als zusammenhaengende Planungsgrundlage und dokumentiert, welche
Folgebloecke weiterhin noetig bleiben. Der Block nutzt nur Mermaid,
ASCII-Flows, Markdown-Tabellen, Readiness-Matrix und Gate-/Decision-Flows. Er
erzeugt keine PNGs, keine Tests, keine App-Integration, keine Assetproduktion,
keine finale Assetliste, keine finale Produktionsfreigabe, keine finale
ThemeIsland-Roadmap, keine finale Startinsel, keine finale Onboarding-UI,
keine finale Datenstruktur, keine Runtime-Konfiguration, keine App-/
Assetfreigabe, keinen Code und kein `frame_started`.

Phase 2G-M13-K startet Early Onboarding Product Wireframe Plan als reinen
Dokumentations- und Visualisierungsplanungsblock. M13-K plant eine kurze
mobile-first Onboarding-Richtung mit Tali/Vori-Begruessung, drei Foundation-
Lernfokus-Karten, Auswahl/Bestaetigung, spaeterer Aenderbarkeit und Safe Exit
ueber Codex/Blueprint/Backlog. Der Block nutzt nur ASCII-Wireframes,
Mermaid-Flows, Markdown-Tabellen, Product-Wireframe-Beschreibungen und
QA-/Device-Checklisten. Er erzeugt keine PNGs, keine Tests, keine
App-Integration, keine finale Onboarding-UI, keine finale Startinsel, keine
finale ThemeIsland-Roadmap, keine finale Datenstruktur, keine
Runtime-Konfiguration, keine App-/Assetfreigabe, keinen Code und kein
`frame_started`.

Phase 2G-M13-L startet Word-to-Island Product UX Preview Plan als reinen
Dokumentations- und Visualisierungsplanungsblock. M13-L plant eine mobile-first
UX-Preview-Richtung fuer Wort-Eingang, Vorschlagskarte, Sense-Auswahl,
Container-Hinweis, Blueprint/Codex/Backlog und sensible oder abstrakte
Fallbacks. Der Block nutzt nur ASCII-Wireframes, Mermaid-Flows,
Markdown-Tabellen, Product-UX-Beschreibungen und QA-/Device-Checklisten. Er
erzeugt keine PNGs, keine Tests, keine App-Integration, keine finale
Word-to-Island-UI, keine finale Word-to-Island-Implementierung, keine finale
Routing-Datenstruktur, keine Runtime-Konfiguration, keine automatische
Wortplatzierung, keine App-/Assetfreigabe, keinen Code und kein
`frame_started`.

Phase 2G-M13-M startet Container QA Overlay Preview Plan als reinen
Dokumentations- und Visualisierungsplanungsblock. M13-M plant textuelle
QA-Overlay-Ebenen fuer Safe Area, Container Bounds, Focus Object Zone, Label
Zone, Tap Target Zone, Pagination Zone, Tali/Vori Exclusion Zone und
Blocked/Overflow Zone. Der Block nutzt nur ASCII-Wireframes,
ASCII-QA-Overlays, Mermaid-Flows, Markdown-Tabellen und QA-/Device-
Checklisten. Er erzeugt keine PNGs, keine Tests, keine App-Integration, keine
finale ContainerOpenView-UI, keine finale DetailInteractionView-UI, keine
Container-Implementierung, keine finale Datenstruktur, keine
Runtime-Konfiguration, keine App-/Assetfreigabe, keinen Code und kein
`frame_started`.

Phase 2G-M13-N startet Foundation Choice Device Preview Plan als reinen
Dokumentations- und Visualisierungsplanungsblock. M13-N plant textuelle
Device-Klassen, Small-/Standard-/Large-Phone-Wireframes, Safe-Area-/
Tap-Zone-Overlays, Accessibility-Regeln und Text-Containment fuer die
Foundation Choice. Der Block nutzt nur ASCII-Device-Wireframes,
ASCII-Safe-Area-/Tap-Zone-Overlays, Mermaid-Flows, Markdown-Tabellen und
Device-/Accessibility-/Text-Containment-Checklisten. Er erzeugt keine PNGs,
keine Tests, keine App-Integration, keine finale Onboarding-UI, keine finale
Foundation-Choice-UI, keine finale Startinsel, keine finale Datenstruktur,
keine Runtime-Konfiguration, keine App-/Assetfreigabe, keinen Code und kein
`frame_started`.

Phase 2G-M13-O startet ThemeIsland Roadmap Scope Freeze Review als reinen
Dokumentations- und Visualisierungsplanungsblock. M13-O prueft nur, ob die
Roadmap als nicht-finale Planungsgrundlage eingefroren werden kann. Scope
Freeze bedeutet Planungsstabilitaet, nicht Umsetzung. Der Block nutzt nur
Mermaid-Flows, ASCII-Gate-Flows, Markdown-Tabellen, Scope-Freeze-Matrizen und
Decision-/Readiness-Maps. Er erzeugt keine PNGs, keine Tests, keine
App-Integration, keine finale ThemeIsland-Roadmap, keine finale Startinsel,
keine finale Onboarding-UI, keine finale Foundation-Choice-UI, keine finale
Datenstruktur, keine Runtime-Konfiguration, keine App-/Assetfreigabe, keinen
Code und kein `frame_started`.

Phase 2G-M13-P startet Implementation Candidate Gate als reinen
Dokumentations- und Visualisierungsplanungsblock. M13-P prueft nur, ob
spaetere Product-/Review-Harness-/Implementation-Kandidaten denkbar sind. Der
Block nutzt nur Mermaid-Flows, ASCII-Gate-Flows, Markdown-Tabellen,
Implementation-Readiness-Matrizen und Decision-/Blocker-Maps. Er erzeugt keine
PNGs, keine Tests, keine App-Integration, keine finale Implementierungsfreigabe,
keine finale ThemeIsland-Roadmap, keine finale Startinsel, keine finale
Onboarding-UI, keine finale Foundation-Choice-UI, keine finale
Word-to-Island-UI, keine finale Container-UI, keine finale Datenstruktur, keine
Runtime-Konfiguration, keine App-/Assetfreigabe, keinen Code und kein
`frame_started`.

M14-A startet den Foundation Choice Product Preview Plan als reinen
Dokumentations- und Visualisierungsplanungsblock. M14-A plant nur
produktnahe Preview-Zustaende, Copy-Regeln, Product-Flow und
ASCII-Product-Previews fuer die Foundation Choice. Der Block nutzt nur
ASCII-Product-Wireframes, ASCII-Mobile-Frames, ASCII-State-Previews,
Mermaid-Flows, Markdown-Tabellen und Product-/Device-/Accessibility-
Checklisten. Er erzeugt keine PNGs, keine Tests, keine App-Integration, keine
finale Foundation-Choice-UI, keine finale Onboarding-UI, keine finale
Startinsel, keine finale ThemeIsland-Roadmap, keine finale Datenstruktur,
keine Runtime-Konfiguration, keine App-/Assetfreigabe, keine
Implementierungsfreigabe, keinen Code und kein `frame_started`.

M14-A2 startet den Foundation Choice Product Preview Visual Review als reinen
Dokumentations- und Visualisierungs-Reviewblock. M14-A2 prueft nur M14-A
visuell/textuell gegen Product-Flow, Foundation-Karten, Copy-Regeln,
Product-States, Device-/Accessibility-Regeln und Guardrails. Der Block nutzt
nur ASCII-Review-Overlays, ASCII-Mobile-Frames, ASCII-State-Review-Skizzen,
Mermaid-Flows, Markdown-Tabellen und Product-/Device-/Accessibility-Review-
Checklisten. Er erzeugt keine PNGs, keine Tests, keine App-Integration, keine
finale Foundation-Choice-UI, keine finale Onboarding-UI, keine finale
Startinsel, keine finale Datenstruktur, keine Runtime-Konfiguration, keine
App-/Assetfreigabe, keine Implementierungsfreigabe, keinen Code und kein
`frame_started`.

M14-B startet den Word-to-Island Product Preview Plan als reinen
Dokumentations- und Visualisierungsplanungsblock. M14-B plant nur
produktnahe Preview-Zustaende, Copy-Regeln, Product-Flow und
ASCII-Product-Previews fuer Word-to-Island. Der Block nutzt nur
ASCII-Product-Wireframes, ASCII-Mobile-Frames, ASCII-State-Previews,
Mermaid-Flows, Markdown-Tabellen und Product-/Device-/Accessibility-
Checklisten. Er erzeugt keine PNGs, keine Tests, keine App-Integration, keine
finale Word-to-Island-UI, keine finale Word-to-Island-Implementierung, keine
finale Routing-Datenstruktur, keine Runtime-Konfiguration, keine automatische
Wortplatzierung, keine App-/Assetfreigabe, keine Implementierungsfreigabe,
keinen Code und kein `frame_started`.

M14-B2 startet den Word-to-Island Product Preview Visual Review als reinen
Dokumentations- und Visualisierungs-Reviewblock. M14-B2 prueft nur M14-B
visuell/textuell gegen Product-Flow, Sense-/Route-Logik, Safety-/Clutter-
Regeln, Copy-Regeln, Product-States, Device-/Accessibility-Regeln und
Guardrails. Der Block nutzt nur ASCII-Review-Overlays, ASCII-Mobile-Frames,
ASCII-State-Review-Skizzen, Mermaid-Flows, Markdown-Tabellen und Product-/
Device-/Accessibility-Review-Checklisten. Er erzeugt keine PNGs, keine Tests,
keine App-Integration, keine finale Word-to-Island-UI, keine
Word-to-Island-Implementierung, keine finale Routing-Datenstruktur, keine
Runtime-Konfiguration, keine automatische Wortplatzierung, keine
App-/Assetfreigabe, keine Implementierungsfreigabe, keinen Code und kein
`frame_started`.

M14-C startet den Container QA Product Preview Plan als reinen
Dokumentations- und Visualisierungsplanungsblock. M14-C plant nur
produktnahe Preview-Zustaende, Copy-Regeln, Product-Flow,
ASCII-Product-Previews und QA-Zonen fuer `ContainerOpenView`,
`DetailInteractionView` und kleine Objektgruppen. Der Block nutzt nur
ASCII-Product-Wireframes, ASCII-QA-Overlays, ASCII-Mobile-Frames,
Mermaid-Flows, Markdown-Tabellen und Product-/Device-/Accessibility-/QA-
Checklisten. Er erzeugt keine PNGs, keine Tests, keine App-Integration, keine
finale ContainerOpenView-UI, keine finale DetailInteractionView-UI, keine
Container-Implementierung, keine finale Datenstruktur, keine
Runtime-Konfiguration, keine App-/Assetfreigabe, keine Implementierungsfreigabe,
keinen Code und kein `frame_started`.

M14-C2 startet den Container QA Product Preview Visual Review als reinen
Dokumentations- und Visualisierungs-Reviewblock. M14-C2 prueft nur M14-C
visuell/textuell gegen Product-Wirkung, Beispielpfade, QA-Zonen, Copy-Regeln,
Product-States, Device-/Accessibility-Regeln und Guardrails. Der Block nutzt
nur ASCII-Review-Overlays, ASCII-Mobile-Frames,
ASCII-State-Review-Skizzen, Mermaid-Flows, Markdown-Tabellen und Product-/
Device-/Accessibility-/QA-Review-Checklisten. Er erzeugt keine PNGs, keine
Tests, keine App-Integration, keine finale ContainerOpenView-UI, keine finale
DetailInteractionView-UI, keine Container-Implementierung, keine finale
Datenstruktur, keine Runtime-Konfiguration, keine App-/Assetfreigabe, keine
Implementierungsfreigabe, keinen Code und kein `frame_started`.

M14-D startet den Device/Accessibility Review Harness Plan als reinen
Dokumentations- und Visualisierungsplanungsblock. M14-D plant nur spaetere
Review-Harness-Pruefungen fuer Device, Accessibility, Text-Containment,
Tap-Ziele, Safe Areas, Companion Collision, Pagination und Guardrail Copy. Der
Block nutzt nur ASCII-Harness-Flows, ASCII-Device-Frames,
ASCII-QA-Check-Overlays, Mermaid-Flows, Markdown-Tabellen und Device-/
Accessibility-/Tap-Target-/Text-Containment-Checklisten. Er erzeugt keine
PNGs, keine Screenshots, keine Tests, keine Widget-Tests, keine
Test-Harness-Implementierung, keine Flutter-/Dart-Dateien, keine App-
Integration, keine finale UI, keine finale Datenstruktur, keine
Runtime-Konfiguration, keine App-/Assetfreigabe, keine Implementierungsfreigabe,
keinen Code und kein `frame_started`.

M14-D2 startet den Device/Accessibility Review Harness Visual Review als
reinen Dokumentations- und Visualisierungs-Reviewblock. M14-D2 prueft nur
M14-D visuell/textuell gegen Coverage, ASCII-Harness-Frames,
Device-/Accessibility-Kategorien, Harness-States,
Runtime-Misread-Prevention und Guardrails. Der Block nutzt nur
ASCII-Review-Overlays, ASCII-Device-Frames, ASCII-Harness-Review-Skizzen,
Mermaid-Flows, Markdown-Tabellen und Device-/Accessibility-/Tap-Target-/
Text-Containment-Review-Checklisten. Er erzeugt keine PNGs, keine
Screenshots, keine Tests, keine Widget-Tests, keine
Test-Harness-Implementierung, keine Flutter-/Dart-Dateien, keine App-
Integration, keine finale UI, keine finale Datenstruktur, keine
Runtime-Konfiguration, keine App-/Assetfreigabe, keine Implementierungsfreigabe,
keinen Code und kein `frame_started`.

M14-E startet den Small Implementation Slice Candidate Review als reinen
Dokumentations- und Gate-Reviewblock. M14-E prueft nur, ob spaetere kleine
Slices denkbar waeren. Der Block nutzt nur ASCII-Gate-Flows,
ASCII-Decision-Maps, Mermaid-Flows, Markdown-Tabellen und Readiness-/
Blocker-/Scope-Matrizen. Er erzeugt keine PNGs, keine Screenshots, keine
Tests, keine Widget-Tests, keine Test-Harness-Implementierung, keine
Flutter-/Dart-Dateien, keine App-Integration, keine finale UI, keine finale
Datenstruktur, keine Runtime-Konfiguration, keine App-/Assetfreigabe, keine
Implementierungsfreigabe, keinen Code, keine automatische Wortplatzierung und
kein `frame_started`.

M14-E2 startet den Small Implementation Slice Candidate Visual Review als
reinen Dokumentations- und Visualisierungs-Reviewblock. M14-E2 prueft nur
M14-E visuell/textuell gegen Readiness-Level, Minimal-Slice-Kriterien,
Kandidatenmatrix, Gate-Visualisierungen, `frame_started`-Blockade,
Harness-Gates und Misread-Risiken. `implementation-candidate-later` bleibt
ausdruecklich keine aktuelle Codefreigabe und braucht immer eigenes Gate,
separaten Implementierungs-Prompt und ausdrueckliche Nutzerfreigabe. Der Block
nutzt nur ASCII-Review-Flows, ASCII-Decision-Maps, Mermaid-Flows,
Markdown-Tabellen und Readiness-/Blocker-/Scope-Matrizen. Er erzeugt keine
PNGs, keine Screenshots, keine Tests, keine Widget-Tests, keine
Test-Harness-Implementierung, keine Flutter-/Dart-Dateien, keine
App-Integration, keine finale UI, keine finale Datenstruktur, keine
Runtime-Konfiguration, keine App-/Assetfreigabe, keine Implementierungsfreigabe,
keinen Code, keine automatische Wortplatzierung und kein `frame_started`.

M14-V1 startet den Visual Backfill For Docs 283-306 als reinen
Dokumentations- und Visualisierungsblock. M14-V1 erzeugt echte PNG-
Dokumentationsvisualisierungen unter
`docs/world_design/previews/m14_visual_backfill_283_306/` und dokumentiert das
Inventar in `docs/world_design/307-visual-backfill-283-306.md`. Die PNGs sind
Dokumentationspreviews, keine finale UI, keine App-Screens, keine Spielassets
und keine Asset-Dateien unter `assets/`. Es entsteht keine App-Integration,
keine Flutter-/Dart-Datei, kein Test, kein Widget-Test, keine
Test-Harness-Implementierung, kein Screenshot, keine Runtime-Konfiguration,
keine App-/Assetfreigabe, keine Implementierungsfreigabe, kein Code und kein
`frame_started`.

M14-V1-B startet den Visual Backfill Quality Review als reinen
Dokumentations- und Reviewblock. M14-V1-B prueft nur die bestehenden PNG-
Dokumentationspreviews aus M14-V1 in
`docs/world_design/previews/m14_visual_backfill_283_306/`. Die Pruefung
bewertet Lesbarkeit, Text-Containment, Contact Sheet, kritische Einzelbilder
und Misread-Risiken. Es entstehen keine neuen PNGs, keine PNG-Aenderungen,
keine Screenshots, keine Tests, keine Widget-Tests, keine Flutter-/Dart-
Dateien, keine App-Integration, keine Spielassets, keine Asset-Dateien unter
`assets/`, keine finale UI, keine Runtime-Konfiguration, keine
Implementierungsfreigabe, kein Code und kein `frame_started`.

M15-A startet das Foundation Choice Implementation Gate als reinen
Dokumentations- und Gate-Reviewblock. M15-A prueft nur, ob ein spaeterer
minimaler Foundation-Choice-Slice sauber auf eine lokale, nicht persistente,
nicht finale Product Preview begrenzt werden koennte. Der Block bestaetigt
keine direkte Implementierung. Ein spaeterer Minimal-Slice ist hoechstens
theoretisch denkbar, wenn ein separater Implementierungs-Prompt und
ausdrueckliche Nutzerfreigabe folgen. Es entstehen keine neuen PNGs, keine
PNG-Aenderungen, keine Screenshots, keine Tests, keine Widget-Tests, keine
Flutter-/Dart-Dateien, keine App-Integration, keine finale UI, keine
Runtime-Konfiguration, keine Persistenz, keine Supabase Writes, keine
SRS-/`word_progress`-Aenderung, keine Reward Bridge, keine App-/Assetfreigabe,
keine Implementierungsfreigabe, kein Code, keine automatische Wortplatzierung
und kein `frame_started`.

M15-A2 startet den Foundation Choice Minimal Slice Implementation Prompt Draft
als reinen Dokumentations- und Prompt-Planungsblock. M15-A2 erstellt nur einen
spaeteren Implementierungs-Prompt als Dokument und fuehrt ihn nicht aus. Der
Draft-Prompt bleibt nicht freigegeben und darf erst nach ausdruecklicher
Nutzerfreigabe als separater Implementierungsblock verwendet werden. Es
entstehen keine Implementierung, keine Flutter-/Dart-Dateien, keine Tests,
keine Widget-Tests, keine App-Integration, keine finale UI, keine
Runtime-Konfiguration, keine Persistenz, keine Supabase Writes, keine
SRS-/`word_progress`-Aenderung, keine Reward Bridge, keine PNGs, keine
PNG-Aenderungen, keine Screenshots, keine Assets, keine App-/Assetfreigabe,
keine Implementierungsfreigabe, kein Code, keine automatische Wortplatzierung
und kein `frame_started`.

M15-A3 startet den Foundation Choice Prompt Visual Review als reinen
Dokumentations- und Visualisierungsblock. M15-A3 prueft nur den Prompt-Draft
aus M15-A2 und ergaenzt echte PNG-Dokumentationspreviews unter
`docs/world_design/previews/m15_a3_foundation_choice_prompt_visual_review/`.
Diese PNGs sind keine App-Screens, keine finale UI, keine Spielassets und
keine Implementierungsfreigabe. Es entstehen keine Implementierung, keine
Flutter-/Dart-Dateien, keine Tests, keine Widget-Tests, keine App-Integration,
keine finale UI, keine Runtime-Konfiguration, keine Persistenz, keine Supabase
Writes, keine SRS-/`word_progress`-Aenderung, keine Reward Bridge, keine
Screenshots, keine Asset-Dateien unter `assets/`, keine App-/Assetfreigabe,
keine Implementierungsfreigabe, kein Code, keine automatische Wortplatzierung
und kein `frame_started`.

M15-A4 startet die Foundation Choice Final Pre-Implementation Checklist als
reinen Dokumentations- und Checklistenblock. M15-A4 prueft nur, ob ein
spaeterer Minimal-Slice bereit fuer ausdrueckliche Nutzerfreigabe waere.
Die Checkliste kommt zu `ready-for-explicit-user-approval`, aber nur fuer einen
spaeteren separaten Implementierungs-Prompt nach ausdruecklicher Freigabe.
Es entstehen keine Implementierung, keine Flutter-/Dart-Dateien, keine Tests,
keine Widget-Tests, keine App-Integration, keine finale UI, keine
Runtime-Konfiguration, keine Persistenz, keine Supabase Writes, keine
SRS-/`word_progress`-Aenderung, keine Reward Bridge, keine PNGs, keine
PNG-Aenderungen, keine Screenshots, keine Assets, keine App-/Assetfreigabe,
keine Implementierungsfreigabe, kein Code, keine automatische Wortplatzierung
und kein `frame_started`.

M15-B startet den Foundation Choice Preview Code Review und Visual Harness Plan
als engen Code-Review- und Dokumentationsblock. M15-B prueft nur den bereits
isolierten Preview-Code und plant nur einen spaeteren Visual Harness. Eine PNG-
Dokumentationspreview liegt unter
`docs/world_design/previews/m15_b_foundation_choice_code_review/`. Daraus
folgen keine App-Integration, keine Home-/Onboarding-/World-Routing-
Integration, keine Persistenz, keine Runtime-Konfiguration, keine Tests, keine
Widget-Tests, keine Screenshots, keine Assets, keine App-/Assetfreigabe, keine
automatische Wortplatzierung und kein `frame_started`.

M15-C startet das Foundation Choice Local Preview Harness Gate als reinen
Dokumentations- und Gate-Planungsblock. M15-C prueft nur, ob ein spaeterer
isolierter lokaler Preview-Harness denkbar waere, und ergaenzt
Dokumentationspreviews unter
`docs/world_design/previews/m15_c_foundation_choice_local_preview_harness_gate/`.
Daraus folgen keine Harness-Implementierung, keine Flutter-/Dart-Dateien,
keine App-Integration, keine Home-/Onboarding-/World-Routing-Integration,
keine Tests, keine Widget-Tests, keine Screenshots, keine Runtime-
Konfiguration, keine Persistenz, keine Assets, keine automatische
Wortplatzierung und kein `frame_started`.

M15-D startet das Foundation Choice Local Preview Harness Implementation Gate
als reinen Dokumentations- und Gate-Block. M15-D prueft nur, ob ein spaeterer
isolierter Harness-Slice freigabefaehig waere, und ergaenzt
Dokumentationspreviews unter
`docs/world_design/previews/m15_d_foundation_choice_harness_implementation_gate/`.
Daraus folgen keine Harness-Implementierung, keine Flutter-/Dart-Dateien,
keine App-Integration, keine Home-/Onboarding-/World-Routing-Integration,
keine Tests, keine Widget-Tests, keine Screenshots, keine Runtime-
Konfiguration, keine Persistenz, keine Assets, keine automatische
Wortplatzierung und kein `frame_started`.

M15-D2 startet den Foundation Choice Harness Implementation Prompt Draft als
reinen Dokumentations- und Prompt-Planungsblock. M15-D2 erstellt nur den
spaeteren Harness-Implementierungs-Prompt als nicht freigegebenes Dokument und
ergaenzt Dokumentationspreviews unter
`docs/world_design/previews/m15_d2_foundation_choice_harness_prompt_draft/`.
Daraus folgen keine Harness-Implementierung, keine Flutter-/Dart-Dateien,
keine App-Integration, keine Home-/Onboarding-/World-Routing-Integration,
keine Tests, keine Widget-Tests, keine Screenshots, keine Runtime-
Konfiguration, keine Persistenz, keine Assets, keine automatische
Wortplatzierung und kein `frame_started`.

M16-A startet den First World Element Slice Scope And Visual Plan als
beschleunigten, aber sicheren Planungs- und Visualisierungsblock. Ziel ist der
Uebergang vom trockenen Foundation-Choice-Harness zu einem ersten sichtbaren
Welt-Element, ohne Architekturbruch. M16-A empfiehlt als naechsten moeglichen
Code-Slice einen neutralen lokalen Plot-Marker. Dokumentationspreviews liegen
unter `docs/world_design/previews/m16_a_first_world_element_slice/`. Daraus
folgen keine Flutter-/Dart-Dateien, keine App-Integration, keine Tests, keine
Screenshots, keine Runtime-Konfiguration, keine Persistenz, keine Assets,
keine automatische Wortplatzierung und kein `frame_started`.

M16-I startet den Theme Island Plot Capacity And In-Place Build Wheel Plan als
reinen Dokumentations- und Visualisierungsblock. Ziel ist, ThemeIslands nicht
als kleine feste Inseln mit wenigen Slots zu planen, sondern Inselgroesse,
Grundstuecksanzahl und Grundstuecksgroessen aus dem jeweiligen Themenbedarf
abzuleiten. Das Build-Wheel bleibt ein spaeteres In-Place-Overlay-Konzept:
kein neuer Screen, keine Route, keine Persistenz, kein Build-State.
Dokumentationspreviews liegen unter
`docs/world_design/previews/m16_i_theme_island_plot_capacity_build_wheel/`.
Daraus folgen keine Flutter-/Dart-Dateien, keine App-Integration, keine Tests,
keine Screenshots, keine Runtime-Konfiguration, keine Persistenz, keine
Assets, keine automatische Wortplatzierung und kein `frame_started`.

M16-J startet den Village Plot Capacity Local Preview Scope als reinen
Dokumentations- und Visualisierungsblock. Ziel ist, aus M16-I einen spaeteren
lokalen Multi-Slot-Preview-Slice fuer Dorf/Zuhause/Alltag abzuleiten:
unterschiedliche Grundstuecksgroessen, austauschbare Slots, verbindender
Weg/Platz und lokale Slot-Auswahl, aber keine Gebaeude, keine Assets, keine
Build-Wheel-Implementierung und keine echte Platzierung. Dokumentationspreviews
liegen unter
`docs/world_design/previews/m16_j_village_plot_capacity_local_preview/`.
Daraus folgen keine Flutter-/Dart-Dateien, keine App-Integration, keine Route,
keine Tests, keine Screenshots, keine Runtime-Konfiguration, keine Persistenz,
keine Assets, keine automatische Wortplatzierung, kein Build-State und kein
`frame_started`.

M16-K startet die Global ThemeIsland Category Plot Capacity Matrix als reinen
Dokumentations- und Visualisierungsblock. Ziel ist, die vorhandenen Kategorien
aus Taxonomy, Priorisierung, Routing, Capability-Ableitung, Roadmap und
Capability-Sheets global einzusammeln, bevor ein weiterer dorf-spezifischer
Slice freigegeben wird. M16-J bleibt ein enges Dorf-/Zuhause-/Alltag-Beispiel.
Die globale Grundlage umfasst auch Kueste/Meer/Hafen, Garten/Natur, Farm/Land,
Stadt/Dorfzentrum, Verkehr/Reisen, Arbeit/Industrie, Freizeit/Outdoor/Sport,
Technik/Digital, oeffentliche Gebaeude/Verwaltung, Gesundheit/Notfall,
Kultur/Gesellschaft und sensible Bereiche. Dokumentationspreviews liegen unter
`docs/world_design/previews/m16_k_global_theme_island_plot_capacity_matrix/`.
Daraus folgen keine Flutter-/Dart-Dateien, keine App-Integration, keine Route,
keine Tests, keine Screenshots, keine Runtime-Konfiguration, keine Persistenz,
keine Assets, keine automatische Wortplatzierung, kein Build-State und kein
`frame_started`.

M16-L startet den Global World Semantics Consistency Audit als reinen
Dokumentations-, Audit- und Visualisierungsblock. Ziel ist, die bestehenden
Regeln aus Taxonomy, Word-to-Island-Routing, Plot-Capabilities, Sensitive
Policy, Mobile-/Clutter, Depth-/Container, Asset-Scope und M16-I/J/K als
Pflichtfilter fuer alle zukuenftigen World-Prompts zu konsolidieren. M16-L
stellt klar: Kategorie- und Plot-Capacity-Profile reichen nicht aus; jedes Wort
braucht Context/Sense, Word-Type-Routing, Safety, Representation Decision,
User Choice und sichere Fallbacks wie Codex, Blueprint oder Backlog.
Dokumentationspreviews liegen unter
`docs/world_design/previews/m16_l_global_world_semantics_consistency_audit/`.
Daraus folgen keine Flutter-/Dart-Dateien, keine App-Integration, keine Route,
keine Tests, keine Screenshots, keine Runtime-Konfiguration, keine Persistenz,
keine Assets, keine automatische Wortplatzierung, kein Build-State und kein
`frame_started`.

M16-M startet das Next Safe Preview Slice Decision Gate als reinen
Dokumentations- und Entscheidungsblock. Ziel ist, nach M16-I/J/K/L nicht
direkt in Dorf, Kueste, globale Auswahl oder Build-Wheel zu springen, sondern
den sichersten naechsten Preview-Slice zu bestimmen. M16-M empfiehlt
`WordSemanticsDecisionPreview`, weil dieser Kandidat M16-L sichtbar macht:
Context/Sense, Word-Type, Safety, Representation Decision, User Choice und
Codex/Blueprint/Backlog-Fallbacks werden vor jeder sichtbaren Welt- oder
Plot-Ableitung geprueft. Dokumentationspreviews liegen unter
`docs/world_design/previews/m16_m_next_safe_preview_slice_decision_gate/`.
Daraus folgen keine Flutter-/Dart-Dateien, keine App-Integration, keine Route,
keine Tests, keine Screenshots, keine Runtime-Konfiguration, keine Persistenz,
keine Assets, keine automatische Wortplatzierung, kein Build-State und kein
`frame_started`.

M16-N startet den Word Semantics Decision Preview Scope als reinen
Dokumentations- und Visualisierungsblock. Ziel ist, die M16-M-Empfehlung
`WordSemanticsDecisionPreview` zu konkretisieren, ohne sie zu implementieren:
Word/User Intent -> Context/Sense -> Word-Type -> Safety -> Theme Candidates
-> Plot/Depth -> Representation Decision -> User Choice -> Preview Only ->
Later Gate. Dokumentationspreviews liegen unter
`docs/world_design/previews/m16_n_word_semantics_decision_preview_scope/`.
Daraus folgen keine Flutter-/Dart-Dateien, keine App-Integration, keine Route,
keine Tests, keine Screenshots, keine Runtime-Konfiguration, keine Persistenz,
keine Assets, keine automatische Wortplatzierung, kein Build-State und kein
`frame_started`.

M16-O startet das Word Semantics Preview Implementation Gate als reinen
Dokumentations- und Gate-Block. Ziel ist zu pruefen, ob ein spaeterer
minimaler isolierter `WordSemanticsDecisionPreview`-Code-Slice ueberhaupt
sinnvoll und sicher waere. Gate-Entscheidung: spaeter theoretisch moeglich,
aber nur als isoliertes lokales Preview-Widget nach separatem Prompt und
ausdruecklicher Nutzerfreigabe. Dokumentationspreviews liegen unter
`docs/world_design/previews/m16_o_word_semantics_preview_implementation_gate/`.
Daraus folgen keine Flutter-/Dart-Dateien, keine App-Integration, keine Route,
keine Tests, keine Screenshots, keine Runtime-Konfiguration, keine Persistenz,
keine Assets, keine automatische Wortplatzierung, kein Build-State und kein
`frame_started`.

M16-P startet den Word Semantics Decision Preview Implementation Prompt Draft
als reinen Dokumentations- und Prompt-Draft-Block. Ziel ist, einen spaeteren
Implementierungs-Prompt fuer einen minimalen isolierten
`WordSemanticsDecisionPreview`-Code-Slice vorzubereiten, ohne ihn
auszufuehren. Der Draft beschreibt nur einen spaeteren Scope fuer
`lib/features/world/local_world/ui/widgets/word_semantics_decision_preview.dart`
und einen optionalen Launch-Target nach separater Freigabe. Dokumentations-
previews liegen unter
`docs/world_design/previews/m16_p_word_semantics_preview_prompt_draft/`.
Daraus folgen keine Flutter-/Dart-Dateien, keine neue Dart-Datei, keine App-
Integration, keine Route, keine Tests, keine Screenshots, keine Runtime-
Konfiguration, keine Persistenz, keine Assets, keine automatische
Wortplatzierung, kein Build-State und kein `frame_started`.

M16-R startet den Scalable Word Semantics Architecture Plan als reinen
Dokumentations- und Visualisierungsblock. Ziel ist sicherzustellen, dass
tausende oder 20.000+ Woerter nicht zu tausenden sichtbaren Karten,
Weltobjekten, Grundstuecken oder Gebaeuden werden. `WordSemanticsDecisionPreview`
bleibt ein Mini-Prototyp mit acht Beispielwoertern. Ein spaeteres System
braucht Semantic Profiles, Statuswerte, Queues, Filter, Safe Fallbacks und
eigene Gates fuer Datenmodell, Persistenz, Performance, AI/Classification,
Privacy, Sensitive Review und App-Integration. Dokumentationspreviews liegen
unter
`docs/world_design/previews/m16_r_scalable_word_semantics_architecture/`.
Daraus folgen keine Flutter-/Dart-Dateien, keine App-Integration, keine Route,
keine Tests, keine Screenshots, keine Runtime-Konfiguration, keine Persistenz,
keine Assets, keine automatische Wortplatzierung, kein Build-State und kein
`frame_started`.

Kein Uebergang zu Code, Assets oder `frame_started` ist erlaubt, solange die
offenen M9-/M9-B-Fragen nicht geprueft oder bewusst zurueckgestellt und
begruendet wurden.

Vor Phase 2G oder jedem weiteren Ausbau ausserhalb des abgeschlossenen lokalen
2F-Mock-Slices muss erneut geprueft werden:

- Professional Game Development Research Gate,
- Build-Feedback-Konzept,
- Asset-Produktionsregeln,
- State-/Modulsystem,
- Scale-/Dimension-Regeln,
- keine Erweiterung des Scopes ohne Dokumentation.

Entscheidung nach Phase 2E-E:

Phase 2E-E ist als lokaler Proof-of-Concept fuer die buildable Waldlichtung
bestanden.

Der Slice beweist nur:

- Asset-Layering mit `base.png` + `foundation_started.png`,
- lokale BuildState-Umschaltung `empty -> foundation_started`,
- basic Nutzerfuehrung mit Hinweistext und kontrastreichem Fokus,
- minimaler visueller Feedback-Moment mit vorbereiteter ID
  `build.foundation.started`.

Der Slice beweist noch nicht:

- vollstaendige Bauarchitektur,
- Balancing,
- Reward Bridge,
- Persistenz,
- Kategorie-System,
- Sound-/FX-System,
- Expansion oder PlacedItems.

Offene Punkte nach abgeschlossenem Phase-2F-Mock-Slice:

- `foundation_complete` ist nur als lokaler Mock-Slice abgeschlossen;
  produktive Bau-/Lernlogik bleibt blockiert.
- Phase 2G (`frame_started` / Rohbau) ist geplant und als Asset-Prompt
  vorbereitet, aber vollstaendig gestoppt.
- Der nicht freigegebene `frame_started.png`-Kandidat wurde geloescht und darf
  nicht committed werden.
- Anchor-/Support-Punkte fuer `foundation_complete` sind in
  `docs/world_design/245-build-alignment-and-anchor-system.md` definiert.
- Vor weiterer Asset-Freigabe fehlt zusaetzlich ein Insel-Masterlayout mit
  Plot-Typen, Plot-Groessen, ConnectionSockets, BuildAnchors,
  PathAnchors, DecorationAnchors, ExpansionSockets und Footprints.
- Phase 2G-M1 hat relative Plotgroessen, Mindestkapazitaet und erste
  Socket-Kompatibilitaeten geplant; konkrete Pixel-/Canvas-Metriken und
  Greybox-Preview fehlen weiterhin.
- Phase 2G-M2 hat vorlaeufige logische Greybox-Metriken definiert:
  `P = 100 x 72gu`, `starter_home_plot = 1.5P`, `pathWidth = 16gu`,
  `socketWidth = 18gu` und eine erste Koordinaten-Greybox. Eine visuelle
  Greybox-Preview und Mobile-Lesbarkeitspruefung fehlen weiterhin.
- Phase 2G-M3 hat die sichtbare Greybox-Preview geplant, aber noch keine
  Preview-Dateien erzeugt. Status-Legende, Socket-Overlay,
  Footprint-Overlay, Sicherheitszonen-Overlay und Mobile-Lesbarkeitspruefung
  muessen in einem spaeteren Debug-Preview-Block sichtbar geprueft werden.
- Phase 2G-M4 hat die geplanten Debug-Greybox-Preview-Dateien erzeugt:
  Plot-Greybox, Socket-Overlay, Footprint-/Safety-Overlay, Status-Legende und
  README. Die manuelle Nutzerpruefung und echte Mobile-Lesbarkeit bleiben
  offen.
- Phase 2G-M5 hat M4 visuell bewertet. Ergebnis: M4 ist technisch hilfreich,
  aber nicht visuell bestaetigt. Sichtbare Risiken sind die lineare
  Markt-/Hub-Achse, der lange `market_square`-Schwanz, die unnatuerliche
  `water_edge_east`-Diagonale und die rasterhafte Gesamtform.
- Phase 2G-M5-B hat eine Variante-B-Debug-Greybox erzeugt. Sichtbare
  Verbesserung: weniger lineare Markt-/Hub-Achse, `market_square` naeher am
  Hub, `water_edge_east` klarer als Randzone, Starterbereich organischer
  gerahmt. Offen bleiben manuelle visuelle Bestaetigung, Mobile-Lesbarkeit,
  Footprint-/Safety-Dichte und finale Layout-Entscheidung.
- Phase 2G-M5-C hat die manuelle Variante-B-Sichtpruefung vorbereitet.
  Dokumentiert sind Prueffragen, Bewertungskriterien, Entscheidungsmoeglichkeiten
  und offene Pruefpunkte. Die Sichtpruefung ist ausgewertet: Variante B darf
  nicht als finale feste Gebaeudeanordnung bestaetigt werden.
- Phase 2G-M6 hat die Nutzererkenntnis aufgenommen, dass Variante B zu sehr
  wie eine feste Gebaeudeanordnung wirkt. Die neue Regel: Plots sind flexible
  Grundstuecksflaechen mit Capabilities; Nutzer waehlen kompatible Nutzungen.
  Lernwoerter werden nicht blind platziert, sondern ueber Semantik,
  Blueprints, Backlogs, Szenen, Companion-Vorschlaege oder Codex abgebildet.
- Phase 2G-M6-B hat die fehlende Entscheidungslogik ergaenzt. Offen bleiben
  die Pruefung der Pipeline, die spaetere konkrete Datenmodellierung, echte
  UI-/UX-Entscheidungen fuer Nutzerwahl, Rebuild/Move-Regeln und eine neue
  Greybox mit abstrakten Capability-Labels.
- Phase 2G-M6-C hat tieferliegende Planungsdetails ergaenzt. Offen bleiben
  konkrete Datenmodell-Entscheidungen, Import-Safety-Regeln, Sense-Auswahl-UX,
  Rebuild/Move-Folgen, Learning-Mode-Produktentscheidungen und jede
  Implementierung.
- Phase 2G-M6-D hat Progression ohne Zwang, freie Erstwahl, Import-
  Governance, Kategorie-/Nutzerziel-Priorisierung und Anforderungen an eine
  abstrakte Capability-Greybox ergaenzt. Offen bleiben echte Onboarding-UX,
  konkrete Import-Governance, Datenschutz-/Cloud-Entscheidungen und eine neue
  Debug-Greybox ohne feste Gebaeuderollen.
- Phase 2G-M6-E hat die Archipel-Strategie ergaenzt. Offen bleiben konkrete
  ThemeIsland-Priorisierung, erste Inselwahl, Word-to-Island-Routing-UX,
  Monetarisierungsdokument, Scope-Gates und eine moegliche zweite
  Themeninsel-Preview.
- Phase 2G-M6-F hat die Verbindungslogik zwischen mehreren Inseln ergaenzt.
  Offen bleiben konkrete Archipel-Navigation, gemeinsame Backlog-/Blueprint-
  Datenstruktur, IslandSlot-Limits, Owner-Marker, Social-/Privacy-Konzept und
  UX-Reduktion fuer viele Inseln.
- Phase 2G-M7 hat die naechste abstrakte Capability-Greybox geplant. Offen
  bleiben die manuelle Pruefung der Plot-Metadaten, die eigentliche
  Debug-Preview-Erzeugung, eine moegliche einfache Nutzer-/Produktansicht
  neben der technischen Vollansicht und die Kompatibilitaet mit spaeteren
  ThemeIsland-Capabilities.
- Phase 2G-M7-B hat die Debug-Capability-Greybox erzeugt. Offen bleiben die
  manuelle visuelle Pruefung, die Frage, ob eine vereinfachte Nutzer-/
  Produktansicht zusaetzlich noetig ist, und moegliche Nachbesserung der
  Metadaten oder Layoutdichte.
- Phase 2G-M7-C hat die visuelle Pruefung gestartet. Ergebnis: M7-B ist als
  technische Debug-Greybox brauchbar, aber nicht als Nutzeransicht. Offen
  bleiben Nutzerbestaetigung, moegliche kleine Nachbesserungen und M7-D als
  vereinfachte Nutzer-/Produktansicht.
- Phase 2G-M8 hat World Depth, Container-/Zoom-System, Gameplay-Motivation,
  Retention und faire Monetarisierungsgrundlagen gestartet. Offen bleiben
  Nutzer-/Produktansicht fuer Depth/Container, konkrete Container-UX,
  Interaction-Design, Fairness-Gates fuer Retention, eigenes Monetarisierungs-
  dokument und jede Implementierung.
- Phase 2G-M9 hat eine erste vereinfachte Nutzer-/Produktansicht fuer den
  Depth-/Container-Flow erzeugt.
- Phase 2G-M9-B hat die visuelle Pruefung gestartet. Ergebnis: Der
  Kueche-Schublade-Besteck-Flow ist als erster vereinfachter Nutzer-/
  Produktflow brauchbar. Weitere Beispiel-Flows wie Schule/Federmappe,
  Hafen/Bootskajute und Garten/Beet wurden spaeter in M11 sichtbar geplant.
  Offen bleiben M11-Review, moegliche Flow-/Mobile-Nachbesserung und
  spaetere emotionale/spielerische Nutzer-UX-Pruefungen fuer weitere Themen.
- Die offenen M9-/M9-B-Punkte sind verbindliche Follow-ups: M10 Emotional
  Product Flow Preview, M10-B Challenge Interaction Comparison, M10-C
  Companion Reaction Flow und M11 Multi-Example Container Flow Previews. Sie
  duerfen vor Code-/Assetfreigaben nicht stillschweigend uebersprungen werden.
- Phase 2G-M10 hat die emotionalere Produktflow-Preview erzeugt. Offen bleibt
  nicht mehr die grundsaetzliche visuelle Brauchbarkeit, sondern die
  formale Bestaetigung. M10-D bewertet M10 als grundsaetzlich brauchbar.
  M10-B ist als Challenge-Interaktionsvergleich gestartet und hat Preview-
  Dateien erzeugt. M10-B2 bewertet die erste Empfehlung als brauchbar; finale
  Challenge-Systementscheidung und Implementierung bleiben offen.
  M10-C ist als Companion Reaction Flow gestartet und hat Preview-Dateien
  erzeugt. M10-C2 bewertet die erste Companion-Richtung als brauchbar; finale
  Companion-UX, Implementierung, Voice/Audio/Animation/Rive, Personality-
  Varianten und Comeback-Erinnerungen bleiben offen. M11 hat mehrere
  Beispiel-Flows sichtbar geplant; M11-B bewertet die Multi-Flow-Richtung als
  brauchbar. Offen bleiben Mobile-Komplexitaet fuer Hafen/Bootskajute,
  Clutter-/Kleinteile fuer Schule/Federmappe, Fairness-/Timer fuer
  Gartenwachstum und jede finale Container-Systemarchitektur. M11-C nimmt den
  World-Content-Katalog auf. M11-C2 bewertet ihn als erste Content-/
  Location-Grundlage grundsaetzlich brauchbar; offen bleiben ThemeIsland-
  Priorisierung, Word-to-Island-Routing-Matrix, Plot-Capability-Ableitung,
  Sensitive-Content-Regeln und Mobile-/Clutter-Regeln.
  M12 startet die ThemeIsland-Priorisierung und erzeugt Preview-Dateien.
  M12-A2 bewertet diese erste Priorisierung als grundsaetzlich brauchbar;
  offen bleiben Word-to-Island-Routing-Matrix, Plot-Capability-Ableitung,
  Sensitive-Content-Regeln und Mobile-/Clutter-Regeln.
  M12-B startet die Routing-Matrix und erzeugt Preview-Dateien; offen bleiben
  M12-B-Review, Plot-Capability-Ableitung, Sensitive-Content-Regeln und
  Mobile-/Clutter-Regeln.
  M12-B2 bewertet diese erste Routing-Richtung als grundsaetzlich brauchbar;
  offen bleiben Plot-Capability-Ableitung, Sensitive-Content-Regeln und
  Mobile-/Clutter-Regeln.
  M12-C startet die Plot-Capability-Ableitung und erzeugt Preview-Dateien;
  offen bleiben M12-C-Review, Sensitive-Content-Regeln und Mobile-/Clutter-
  Regeln.
  M12-C2 bewertet diese erste Capability-Richtung als grundsaetzlich
  brauchbar; offen bleiben Sensitive-Content-Regeln und Mobile-/Clutter-
  Regeln.
  M12-D startet Sensitive-Content-Regeln und erzeugt Preview-Dateien; offen
  bleiben M12-D-Review und Mobile-/Clutter-Regeln.
  M12-D2 bewertet diese erste Sensitive-Content-Richtung als grundsaetzlich
  brauchbar. M12-E startet Mobile-/Clutter-Regeln und erzeugt Preview-
  Dateien; offen bleiben M12-E-Review, echte Mobile-/Accessibility-Pruefung
  und jede Umsetzung.
- Es gibt kein echtes Bau-/Lern-/Reward-System.
- Es gibt keine Persistenz.
- Es gibt keine Ressourcenlogik.
- Es gibt keine Sound-/FX-Schicht.
- Es gibt kein Expansion-/PlacedItem-/Interior-System.
- Es gibt keine Cloud-/Supabase-Logik.

Aktuell nicht erlaubt / weiterhin blockiert:

- keine Persistenz,
- keine Supabase Writes,
- keine SRS-/`word_progress`-Aenderung,
- keine Reward Bridge,
- keine echte Ressourcenlogik,
- keine Expansion,
- keine PlacedItems,
- keine Interiors/ObjectDetail,
- keine produktive Bau-/Lernlogik,
- keine Sounddateien oder Audio-Implementierung,
- kein neues Bauasset ohne Plot-Typ,
- kein neues Bauasset ohne Anchor,
- kein neues Bauasset ohne Footprint,
- kein neues Bauasset ohne Anschluss-/Socket-Konzept, wenn es mit Wegen oder
  Grundstuecken verbunden wird,
- kein neues Inselasset ohne Masterlayout,
- kein neues Plot-Asset ohne Plotgroesse,
- kein Gebaeudeasset ohne Gebaeude-Footprint,
- kein Wegasset ohne Socket-Kompatibilitaet,
- kein Dekoasset ohne Deko-Sicherheitszone,
- keine Insel als vollstaendige Privatinsel behandeln, wenn sie nur
  `StarterCorePlot` ist,
- kein weiterer Ausbau, wenn die Inselgroesse fuer die geplante Landschaft
  nicht reicht,
- keine Einzelassets nur nach Augenmass,
- kein finales Inselbild aus einer Debug-Greybox ableiten,
- keine Greybox ohne Status-Legende,
- kein Plot ohne sichtbaren Socket,
- kein Weg ohne pruefbare Verbindung,
- kein Gebaeude-Footprint ohne Sicherheitsabstand,
- kein Starterlayout, das weniger als 7 funktionale Slots zeigt,
- keine Ausbauinsel, die nicht mindestens 12 geplante Slots plausibel
  vorbereitet,
- keine Asset-Produktion, bevor die Greybox visuell geprueft wurde,
- keine Greybox als bestaetigt behandeln, wenn sie zu linear oder rasterhaft
  wirkt,
- keine Market-/Hub-Struktur als langer isolierter Schwanz,
- keine WaterEdge-Verbindung ueber unnatuerlich lange Diagonale ohne
  Uebergangsplot,
- keine Expansion ohne nachvollziehbare Randlogik,
- keine Bauzustaende, solange der `starter_home_plot` im bestaetigten Layout
  nicht feststeht,
- keine Variante-B-Greybox als bestaetigt behandeln, bevor die manuelle
  visuelle Pruefung abgeschlossen ist,
- keine Variante-B-Greybox als finale feste Gebaeudeanordnung behandeln,
- kein Nutzer muss mit Hausbau beginnen,
- kein Wort darf falsch oder ohne passenden Kontext platziert werden,
- kein `Fenster` ohne Wand oder passenden Hauszustand,
- keine `Giesskanne` ohne Garten, Hof oder geeigneten Objektanker,
- kein abstraktes Wort als beliebiges physisches Objekt erzwingen,
- keine automatische Platzierung ohne Nutzerbestaetigung,
- keine Kategorie hart codieren,
- keine Spielassets, bevor Plot-Flexibilitaet und Wort-Semantik geklaert sind,
- kein Wort-zu-Welt-System ohne Placement Decision Pipeline,
- kein Word-to-World-System ohne abstrakte Datenmodell-Skizze,
- kein Import-Feature ohne Kontext-/Sense-/Safety-Pruefung,
- keine sichtbare Darstellung bei mehrdeutigen Woertern ohne Sense-
  Entscheidung,
- kein sensibler oder abstrakter Begriff automatisch als Weltobjekt,
- keine Kopplung, bei der Lernfortschritt automatisch starre Baupositionen
  erzwingt,
- kein Lernmodus darf ohne Nutzerbestaetigung sichtbare Weltobjekte
  massenhaft erzeugen,
- keine freie Plot-Platzierung ohne Onboarding-Erklaerung,
- keine Progression, die den Nutzer faktisch wieder zum Hausstart zwingt,
- kein Import ohne Governance-/Privacy-/Safety-Regeln,
- keine sensible Kategorie ohne Bestaetigung und neutrale Darstellung,
- keine naechste Greybox mit festen Gebaeude-Rollenlabels,
- keine Capability-Greybox ohne `allowedFunctions` und `isUserSelectable`,
- keine Kategorie-Priorisierung ohne Nutzerziel und Satzkontext,
- keine einzelne Insel darf alle Lernwelten erzwingen,
- kein Meer-/Tauchen-/Boot-Thema auf Waldlichtung pressen, wenn Kuesteninsel
  sinnvoller ist,
- keine Stadt-/Krankenhaus-/Flughafen-Komplexitaet auf Starterinsel pressen,
- keine Themeninsel ohne eigene Plot-Capabilities,
- keine Themeninsel ohne Word-to-Island-Routing,
- keine Monetarisierung ohne eigenes spaeteres Dokument,
- keine Paywall, die Core Learning blockiert,
- keine Multi-Island-Produktion ohne Scope-Gate,
- kein Multi-Island-System ohne Archipel-Navigation,
- kein Themeninsel-System ohne gemeinsamen Codex-/Blueprint-/Backlog-Plan,
- kein Multi-Home-Wort ohne Cross-Island-Routing,
- kein Insel-Slot-System ohne Status/Lifecycle,
- keine mehreren privaten Inseln ohne Besitzer-/Identitaetslogik,
- keine Archipel-Roadmap, die den Nutzer mit zu vielen Optionen ueberfordert,
- keine Social-/Showcase-Funktion ohne eigenes Privacy-/Social-Konzept,
- keine neue Greybox mit festen Gebaeude-Rollenlabels,
- keine Capability-Greybox ohne `allowedFunctions`,
- keine Capability-Greybox ohne `isUserSelectable`,
- keine Capability-Greybox ohne klare Trennung zwischen technischer
  Debugansicht und spaeterer Nutzeransicht,
- keine Asset-Produktion aus Capability-Greybox ableiten,
- keine Codefreigabe aus Capability-Greybox ableiten,
- keine technische Capability-Greybox als Nutzeransicht verwenden,
- keine Nutzer-UX aus der technischen Vollansicht ableiten, ohne vereinfachte
  Produktansicht,
- keine Asset- oder Codefreigabe aus M7-B ableiten,
- keine Weiterarbeit an `frame_started`, solange Capability-Greybox und
  Nutzeransicht nicht geklaert sind,
- kein `objectAnchor` als Pflichtobjekt interpretieren,
- keine sichtbare Ueberfuellung durch zu viele Objekte auf einer Ebene,
- keine technische Anchor-/Capability-Ansicht als Nutzeransicht verwenden,
- keine Container-/Zoom-Logik ohne Depth-System,
- keine reine Museumsansicht ohne Interaktion oder Challenge,
- keine Retention-Mechanik ohne Fairness-/Ethikpruefung,
- keine Monetarisierung ohne eigenes Dokument,
- keine manipulative Pay-to-Win- oder Dark-Pattern-Mechanik,
- keine Plot-Freigabe ohne Capability Matrix,
- kein Objekt sichtbar platzieren ohne Placement Requirements,
- kein abstraktes Wort ohne passenden Repraesentationstyp,
- keine Weltvisualisierung, die Mobile-Lesbarkeit ueberlaedt,
- kein Umbauen oder Verschieben ohne definierte Folgen fuer Wortobjekte,
  Blueprints und Backlogs,
- keine Dokumentations-Preview als finales Inselbild oder Spielasset
  behandeln,
- keine Phase-2G-Asset-Freigabe ohne Anchor-/Debug-Overlay-Check,
- keine Phase-2G-Asset-Erzeugung oder Nachbesserung ohne Bezug auf
  Masterlayout-, Plot-, Anchor- und Footprint-Regeln,
- kein Phase-2G-Code ohne Asset, Preview, Device-Check und Freigabe,
- keine finale Freigabe nur auf Textbasis, wenn der Zustand visuell pruefbar
  sein muss,
- keine Asset- oder Layout-Entscheidung ohne passende Preview-, Greybox- oder
  Overlay-Pruefung,
- keine technische Debugansicht als Nutzeransicht verwenden,
- keine komplexe Systementscheidung ohne Flow-/Diagrammpruefung, wenn die
  Zusammenhaenge sonst unklar bleiben,
- keine Spielasset-Erzeugung aus einer Dokumentationsvisualisierung ableiten,
- keine Depth-/Container-Logik ohne visuelle Nutzerflow-Pruefung,
- keine Container-Ansicht als reine Objektliste ohne Challenge,
- keine Nutzeransicht mit zu vielen technischen Labels,
- keine Mini-Challenge ohne klares Feedback und Reward Moment,
- keine Spielasset- oder Codefreigabe aus M9 ableiten,
- keine Produktentscheidung aus nur einem M9-Beispiel-Flow fuer alle Themen
  ableiten,
- kein Container-System ohne mehrere Beispiel-Flows bestaetigen,
- keine finale Nutzer-UX ohne emotionale/spielerische Pruefung ableiten,
- keine Code- oder Assetfreigabe aus M9 oder M9-B ableiten,
- keine allgemeine Container-Systementscheidung, bevor mehrere Beispiel-Flows
  geprueft wurden,
- keine finale Depth-/Container-UX, bevor emotionale/spielerische Wirkung
  visualisiert wurde,
- keine Challenge-Implementierung, bevor Challenge-Arten verglichen wurden,
- keine Companion-UX, bevor Tali/Vori-Reaktionsflow visualisiert wurde,
- keine offenen M9-/M9-B-Follow-ups stillschweigend ueberspringen,
- keine emotionale M10-Produktpreview als finale UI lesen,
- keine Sound-/FX-Implementierung aus M10 ableiten,
- keine Companion-Implementierung aus M10 ableiten,
- keine Challenge-Art final entscheiden, bevor M10-B erfolgt,
- keine allgemeine Container-UX bestaetigen, bevor M10-B, M10-C und M11
  geprueft sind,
- keine finale Produktentscheidung aus M10 allein ableiten,
- keine Challenge-Art aus M10 ableiten,
- keine Tali/Vori-Companion-UX aus M10 ableiten,
- keine App- oder Assetfreigabe aus M10 oder M10-D ableiten,
- keine Challenge-Implementierung aus M10-B ableiten,
- keine Challenge-Art final waehlen, bevor M10-B visuell geprueft wurde,
- keine Drag-and-drop-Entscheidung ohne Mobile-Bedienbarkeitspruefung,
- keine Audio-Challenge ohne Accessibility-/Silent-Mode-Alternative,
- keine allgemeine Challenge-Systementscheidung ohne weitere Beispiel-Flows,
- keine App- oder Assetfreigabe aus M10-B ableiten,
- keine Challenge-Implementierung aus M10-B2 ableiten,
- keine finale Challenge-Systementscheidung ohne M11 ableiten,
- keine Audio-Challenge ohne Silent-/Accessibility-Fallback planen,
- kein Drag-and-drop ohne Mobile-Bedienbarkeitspruefung entscheiden,
- keine App- oder Assetfreigabe aus M10-B oder M10-B2 ableiten,
- keine Companion-Implementierung aus M10-C ableiten,
- keine Voice-/Audio-/Animation-Freigabe aus M10-C ableiten,
- keine Companion-UX final entscheiden, bevor M10-C visuell geprueft wurde,
- keine Companion-Reaktion planen, die Challenge automatisch loest,
- keine Companion-Reaktion planen, die Druck, Schuldgefuehl oder harte Streak-
  Mechanik erzeugt,
- keine App- oder Assetfreigabe aus M10-C ableiten,
- keine Companion-Implementierung aus M10-C2 ableiten,
- keine finale Companion-UX ohne spaetere Detailpruefung ableiten,
- keine Voice-/Audio-/Animation-/Rive-Freigabe aus M10-C2 ableiten,
- keine Companion-Personality-Varianten ohne eigenes Konzept planen,
- keine Comeback-Erinnerungen ohne Fairness-/Druck-Pruefung planen,
- keine App- oder Assetfreigabe aus M10-C oder M10-C2 ableiten,
- keine allgemeine Container-Systemarchitektur aus nur einem Flow ableiten,
- keine finale Container-Systemarchitektur ohne M11-Review bestaetigen,
- keine Flow-Implementierung ohne spaetere UX-/Mobile-Pruefung planen,
- keine Mini-Sequenzen implementieren, bevor Aktionen und Reihenfolgen separat
  geprueft sind,
- keine App- oder Assetfreigabe aus M11 ableiten,
- keine finale Container-Systemarchitektur aus M11-B ableiten,
- keine Flow-Implementierung ohne spaetere UX-/Mobile-Pruefung ableiten,
- keine Hafen-/Kajuten-UX ohne separate Mobile-Komplexitaetspruefung
  bestaetigen,
- keine Garten-Wachstumsmechanik ohne Fairness-/Timer-Pruefung planen,
- keine Schulobjekt-Ansicht ohne Clutter-/Kleinteile-Pruefung als
  Produktentscheidung behandeln,
- keine App- oder Assetfreigabe aus M11 oder M11-B ableiten,
- keine Umsetzung eines Katalogbegriffs ohne Routing-Entscheidung,
- keine grosse Kategorie auf die Starterinsel pressen,
- keine Assetproduktion aus dem Taxonomy-Katalog ableiten,
- keine ThemeIsland-Umsetzung ohne Priorisierung und Scope-Gate starten,
- keine Deko-Massenproduktion ohne Clutter-Regeln planen,
- keine oeffentlichen, medizinischen, religioesen oder politischen Gebaeude
  ohne sensible Darstellungspruefung planen,
- keine Verkehrs-/Strassenlogik ohne eigenes Connector-/Path-Konzept
  umsetzen,
- keine Fahrzeug-/Parklogik ohne Groessen- und Interaktionsregeln planen,
- keine ThemeIsland-Roadmap ohne Taxonomy-Review erstellen,
- keine Word-to-Island-Routing-Matrix ohne Taxonomy-Review erstellen,
- keine Plot-Capability-Ableitung ohne Kategoriepruefung planen,
- keine sensible Kategorie ohne eigene Darstellungs- und Safety-Regeln
  behandeln,
- keine Deko-/Kleinteile-Produktion ohne Mobile-/Clutter-Regeln planen,
- keine technische, Verkehrs- oder Fahrzeuglogik ohne eigenes Systemkonzept
  planen,
- keine Taxonomy-Begriffe als automatische Asset-Auftraege lesen,
- keine finale ThemeIsland-Roadmap aus M12-A2 ableiten,
- keine ThemeIsland-Umsetzung aus M12-A2 ableiten,
- keine Assetproduktion aus M12-A2 ableiten,
- keine Early-Insel ohne M12-B Word-to-Island Routing planen,
- keine Early-Insel ohne M12-C Plot-Capability-Ableitung planen,
- keine Schule/Federmappe ohne Mobile-/Clutter-Regeln planen,
- kein Gartenwachstum ohne Fairness-/Timer-Regeln planen,
- Zuhause/Alltag nicht als Pflicht-Hausstart erzwingen,
- keine sensiblen Inseln ohne M12-D Sensitive-Content-Regeln planen,
- keinen Word-to-Island-Routing-Code aus M12-B ableiten,
- keine automatische Wortplatzierung aus M12-B ableiten,
- kein sichtbares Objekt ohne passende Depth-Ebene planen,
- kein Multi-home-Wort ohne Nutzer- oder Kontextentscheidung final platzieren,
- keinen sensiblen Begriff ohne M12-D-Regeln sichtbar machen,
- kein Gebaeudeteil ohne passenden Gebaeudezustand oder Blueprint platzieren,
- kein Verb als statisches Objekt erzwingen,
- keinen Digitalbegriff ohne Digital-Object-/UI-Abgrenzung planen,
- keine Assetproduktion aus Routing-Karten ableiten,
- keine finale Routing-Implementierung aus M12-B2 ableiten,
- keine automatische Wortplatzierung aus M12-B2 ableiten,
- keine Datenstruktur-Freigabe aus M12-B2 ableiten,
- keine Plot-Capability-Ableitung ohne M12-C planen,
- keine sensiblen Begriffe ohne M12-D behandeln,
- keine Kleinteile-/Container-Umsetzung ohne M12-E Mobile-/Clutter-Regeln
  planen,
- keine Multi-home-Entscheidung ohne Nutzerziel, Satzkontext oder
  Sense-Auswahl finalisieren,
- keine App- oder Assetfreigabe aus M12-B oder M12-B2 ableiten,
- keine Plot-Capability-Implementierung aus M12-C ableiten,
- keine finale Plot-Datenstruktur aus M12-C ableiten,
- keine Runtime-Konfiguration aus M12-C ableiten,
- keine Early-Insel-Umsetzung nur wegen M12-C starten,
- keine Schule/Federmappe ohne M12-E Mobile-/Clutter-Regeln umsetzen,
- kein Gartenwachstum ohne Fairness-/Timer-Regeln umsetzen,
- keine `water`-, `farm`-, `travel`-, `vehicle`-, `digital`- oder
  `sensitive`-Plots ohne eigene Folgepruefungen umsetzen,
- keine Assetproduktion aus Plot-Capability-Karten ableiten,
- keine automatische Wortplatzierung aus Plot-Capabilities ableiten,
- keine finale Plot-Datenstruktur aus M12-C2 ableiten,
- keine Runtime-Konfiguration aus M12-C2 ableiten,
- keine Plot-Implementierung aus M12-C2 ableiten,
- keine ThemeIsland-Umsetzung aus M12-C2 ableiten,
- keine sensitive Plot-Funktion ohne M12-D planen,
- keine Kleinteile-/Container-/Schulobjekt-Umsetzung ohne M12-E planen,
- keine Gartenwachstums- oder Farm-Mechanik ohne Fairness-/Timer-Regeln
  planen,
- keine Water-/Travel-/Vehicle-/Digital-Plots ohne eigene Folgepruefung
  planen,
- keine App- oder Assetfreigabe aus M12-C oder M12-C2 ableiten,
- keine sensible ThemeIsland-Umsetzung aus M12-D ableiten,
- keine automatische Visualisierung sensibler Begriffe planen,
- keine Gebaeude-, Symbol- oder Assetproduktion fuer sensible Begriffe aus
  M12-D ableiten,
- keine medizinische, juristische oder politische Beratung im Spielsystem
  planen,
- keine Retention-Mechanik mit Angst, Krankheit, Tod, Schuld, Politik oder
  Religion planen,
- keine Companion-Reaktion planen, die sensible Inhalte dramatisiert oder
  Druck erzeugt,
- keine pauschale Symbolik fuer Religion, Politik, Identitaet oder soziale
  Gruppen planen,
- keine finale Sensitive-Content-Implementierung ohne spaetere Safety-/UX-
  Pruefung planen,
- keine App- oder Assetfreigabe aus M12-D ableiten,
- keine finale Sensitive-Content-Implementierung aus M12-D2 ableiten,
- keine Moderations-Implementierung aus M12-D2 ableiten,
- keine automatische Visualisierung sensibler Begriffe aus M12-D2 ableiten,
- keine sensible ThemeIsland-Umsetzung aus M12-D2 ableiten,
- keine Gebaeude-, Symbol- oder Assetproduktion fuer sensible Begriffe aus
  M12-D2 ableiten,
- keine App- oder Assetfreigabe aus M12-D oder M12-D2 ableiten,
- keine Kleinteile- oder Container-Implementierung aus M12-E ableiten,
- keine finale Mobile-UI aus M12-E ableiten,
- keine finalen Clutter-Grenzwerte als Runtime-Werte aus M12-E uebernehmen,
- keine TinyObjects dauerhaft in IslandView platzieren,
- keine ueberfuellten Container-Ansichten als Nutzeransicht freigeben,
- keine Labels dauerhaft ueberall anzeigen,
- keine Deko planen, die Lernobjekte verdeckt,
- keine sensitiveSmallObjects ohne M12-D-Regeln platzieren,
- keine App- oder Assetfreigabe aus M12-E ableiten,
- keine automatische Wortplatzierung aus Clutter-Regeln ableiten,
- keine finale Mobile-UI aus M12-E2 ableiten,
- keine finale Datenstruktur aus M12-E2 ableiten,
- keine Runtime-Konfiguration aus M12-E2 ableiten,
- keine Container-Implementierung aus M12-E2 ableiten,
- keine automatische Wortplatzierung aus M12-E2 ableiten,
- keine Device- oder Accessibility-Entscheidung ohne spaetere echte Mobile-
  Pruefung treffen,
- keine App- oder Assetfreigabe aus M12-E oder M12-E2 ableiten,
- keine finale ThemeIsland-Roadmap aus M12-F ableiten,
- keine Implementierungsfreigabe aus M12-F ableiten,
- keine finale Datenstruktur aus M12-F ableiten,
- keine Runtime-Konfiguration aus M12-F ableiten,
- keine automatische Wortplatzierung aus M12-F ableiten,
- keine Plot- oder Container-Implementierung aus M12-F ableiten,
- keine Safety- oder Moderations-Implementierung aus M12-F ableiten,
- keine App-, Code- oder Assetfreigabe aus M12-F ableiten,
- kein `frame_started` oder Bauzustaende aus M12-F weiterbauen,
- keine finale ThemeIsland-Roadmap aus M13 ableiten,
- keine Implementierungsfreigabe aus M13 ableiten,
- keine finale Datenstruktur aus M13 ableiten,
- keine Runtime-Konfiguration aus M13 ableiten,
- keine automatische Wortplatzierung aus M13 ableiten,
- keine ThemeIsland-Umsetzung aus M13 ableiten,
- keine Assets aus M13 erzeugen,
- keine Early-Insel ohne Onboarding-Choice-Review planen,
- keine Early-Insel ohne Device-/Accessibility-/Tap-Target-Pruefung planen,
- keine Garten-/Farm-Wachstumslogik ohne Fairness-/Timer-Regeln planen,
- keine Kuesten-/Hafeninsel ohne Water-/Dock-/Mobile-
  Komplexitaetspruefung planen,
- keine Stadt-/Verkehr-/Technikinsel ohne eigenes Systemkonzept planen,
- keine Sensitive-/Special-Insel ohne vertiefte Safety-/UX-/Policy-Regeln
  planen,
- keine App- oder Assetfreigabe aus M13 ableiten,
- kein `frame_started` oder Bauzustand aus M13 weiterbauen,
- keine finale ThemeIsland-Roadmap aus M13-A2 ableiten,
- keine finale Startinsel aus M13-A2 ableiten,
- keine Implementierungsfreigabe aus M13-A2 ableiten,
- keine finale Datenstruktur aus M13-A2 ableiten,
- keine Runtime-Konfiguration aus M13-A2 ableiten,
- keine automatische Wortplatzierung aus M13-A2 ableiten,
- keine ThemeIsland-Umsetzung aus M13-A2 ableiten,
- keine Assets aus M13-A2 erzeugen,
- keine Foundation-Insel ohne M13-B Onboarding Choice Review planen,
- keine Foundation-Insel ohne Device-/Accessibility-/Tap-Target-Pruefung
  planen,
- keine Garten-/Farm-Wachstumslogik ohne Fairness-/Timer-Regeln planen,
- keine Kuesten-/Hafeninsel ohne Water-/Dock-/Mobile-
  Komplexitaetspruefung planen,
- keine Stadt-/Verkehr-/Technikinsel ohne eigenes Systemkonzept planen,
- keine Sensitive-/Special-Insel ohne vertiefte Safety-/UX-/Policy-Regeln
  planen,
- keine App- oder Assetfreigabe aus M13/M13-A2 ableiten,
- kein `frame_started` oder Bauzustand aus M13/M13-A2 weiterbauen,
- keine finale Startinsel aus M13-B ableiten,
- keinen Pflicht-Hausstart aus M13-B ableiten,
- keine finale Onboarding-UI aus M13-B ableiten,
- keine Onboarding-Implementierung aus M13-B ableiten,
- keine automatische Wortplatzierung aus M13-B ableiten,
- keine ThemeIsland-Umsetzung aus M13-B ableiten,
- keine Assets aus M13-B erzeugen,
- keine irreversible Erstwahl planen,
- keine Premium-/Paywall-Logik im Start-Onboarding planen,
- keine Foundation-Insel ohne spaetere Device-/Accessibility-/Tap-Target-
  Pruefung planen,
- keinen Garten-/Growth-Start ohne Fairness-/Timer-Regeln planen,
- keine App- oder Assetfreigabe aus M13-B ableiten,
- kein `frame_started` oder Bauzustand aus M13-B weiterbauen,
- keine finale Onboarding-UI aus M13-B2 ableiten,
- keine finale Startinsel aus M13-B2 ableiten,
- keine Onboarding-Implementierung aus M13-B2 ableiten,
- keine ThemeIsland-Umsetzung aus M13-B2 ableiten,
- keine finale Datenstruktur aus M13-B2 ableiten,
- keine Runtime-Konfiguration aus M13-B2 ableiten,
- keine automatische Wortplatzierung aus M13-B2 ableiten,
- keine Assets aus M13-B2 erzeugen,
- keine irreversible Erstwahl planen,
- keinen Pflicht-Hausstart planen,
- keinen Premium-/Paywall-Druck im Start-Onboarding planen,
- keine Garten-/Growth-Mechanik ohne Fairness-/Timer-Regeln planen,
- keine Foundation-Insel ohne echte Device-/Accessibility-/Tap-Target-
  Pruefung planen,
- keine App- oder Assetfreigabe aus M13-B/M13-B2 ableiten,
- kein `frame_started` oder Bauzustand aus M13-B/M13-B2 weiterbauen,
- keine ThemeIsland-Umsetzung aus M13-C ableiten,
- keine finale ThemeIsland-Roadmap aus M13-C ableiten,
- keine finale Startinsel aus M13-C ableiten,
- keine finale Onboarding-UI aus M13-C ableiten,
- keine finale Datenstruktur aus M13-C ableiten,
- keine Runtime-Konfiguration aus M13-C ableiten,
- keine automatische Wortplatzierung aus M13-C ableiten,
- keine Assetproduktion aus M13-C ableiten,
- keine App- oder Assetfreigabe aus M13-C ableiten,
- keinen Code aus M13-C ableiten,
- kein `frame_started` oder Bauzustand aus M13-C weiterbauen,
- keine finale Word-to-Island-Implementierung aus M13-D ableiten,
- keine finale Routing-Datenstruktur aus M13-D ableiten,
- keine Runtime-Konfiguration aus M13-D ableiten,
- keine automatische Wortplatzierung aus M13-D ableiten,
- keine automatische ThemeIsland-Auswahl ohne Nutzerbestaetigung planen,
- keine sichtbare Platzierung ohne passende Depth-Ebene planen,
- keine Kleinteile dauerhaft in IslandView platzieren,
- keine Gebaeudeteile ohne passenden Blueprint oder Bauzustand platzieren,
- keine Verben als statische Objekte erzwingen,
- keine sensiblen Begriffe automatisch visualisieren,
- keine App- oder Assetfreigabe aus M13-D ableiten,
- keinen Code aus M13-D ableiten,
- kein `frame_started` oder Bauzustand aus M13-D weiterbauen,
- keine UI-Implementierung aus M13-E ableiten,
- keine finalen Device-Regeln als Runtime-Konfiguration aus M13-E ableiten,
- keine finalen Accessibility-Regeln als Runtime-Konfiguration aus M13-E
  ableiten,
- keine Preview-PNG-Erzeugung aus M13-E ableiten,
- keine Tests aus M13-E ableiten,
- keine App- oder Assetfreigabe aus M13-E ableiten,
- keinen Code aus M13-E ableiten,
- kein `frame_started` oder Bauzustand aus M13-E weiterbauen,
- keine finale Onboarding-UI aus M13-E ableiten,
- keine finale ThemeIsland-UI aus M13-E ableiten,
- keine finale Word-to-Island-UI aus M13-E ableiten,
- keine finale Container-/Depth-UI aus M13-E ableiten,
- keine Container-Implementierung aus M13-F ableiten,
- keine finale ContainerOpenView-UI aus M13-F ableiten,
- keine finale DetailInteractionView-UI aus M13-F ableiten,
- keine finale Pagination-Logik aus M13-F ableiten,
- keine Runtime-Konfiguration aus M13-F ableiten,
- keine Tests aus M13-F ableiten,
- keine PNG-Erzeugung aus M13-F ableiten,
- keine App- oder Assetfreigabe aus M13-F ableiten,
- keinen Code aus M13-F ableiten,
- kein `frame_started` oder Bauzustand aus M13-F weiterbauen,
- keine Kleinteile dauerhaft in IslandView platzieren,
- keine TinyObject-Tap-Ziele ohne Container, Zoom oder DetailInteraction
  planen,
- keine Growth-/Timer-Mechanik ohne Fairness-Regeln planen,
- keine sensitiveSmallObjects ohne M12-D-Regeln planen,
- keine Safety-Implementierung aus M13-G ableiten,
- keine Moderations-Implementierung aus M13-G ableiten,
- keine finale Sensitive-Datenstruktur aus M13-G ableiten,
- keine Runtime-Konfiguration aus M13-G ableiten,
- keine automatische Klassifikation aus M13-G ableiten,
- keine automatische Visualisierung sensibler Begriffe planen,
- keine sensible ThemeIsland-Umsetzung aus M13-G ableiten,
- keine sensiblen Gebaeude, Symbole oder Assets aus M13-G ableiten,
- keine medizinische, juristische oder politische Beratung planen,
- keine Companion-Dramatisierung planen,
- keine Retention-/Streak-/Paywall-Mechanik mit sensiblen Begriffen planen,
- keine Social-/Showcase-Sichtbarkeit sensibler Inhalte planen,
- keine PNG-Erzeugung aus M13-G ableiten,
- keine Tests aus M13-G ableiten,
- keine App- oder Assetfreigabe aus M13-G ableiten,
- keinen Code aus M13-G ableiten,
- kein `frame_started` oder Bauzustand aus M13-G weiterbauen,
- keine Growth-Implementierung aus M13-H ableiten,
- keine Timer-Implementierung aus M13-H ableiten,
- keine Retention-Implementierung aus M13-H ableiten,
- keine Monetarisierungsregel aus M13-H ableiten,
- keine finale Datenstruktur aus M13-H ableiten,
- keine Runtime-Konfiguration aus M13-H ableiten,
- keine Pflanzenverfall- oder Verlustmechanik planen,
- keine harte Streak-Strafe planen,
- keine monetarisierte Streak-Rettung planen,
- keine Pay-to-Win-Beschleunigung planen,
- keine Push-Drucklogik ohne eigenes Konzept planen,
- keine Schuld-/Angst-/FOMO-Mechanik planen,
- keine sensiblen Begriffe als Retention-Ausloeser planen,
- keine Social-Ranking-Drucklogik planen,
- keine PNG-Erzeugung aus M13-H ableiten,
- keine Tests aus M13-H ableiten,
- keine App- oder Assetfreigabe aus M13-H ableiten,
- keinen Code aus M13-H ableiten,
- kein `frame_started` oder Bauzustand aus M13-H weiterbauen,
- keine Assetproduktion aus M13-I ableiten,
- keine finale Assetliste aus M13-I ableiten,
- keine App- oder Assetfreigabe aus M13-I ableiten,
- keine ThemeIsland-Base-Produktion aus M13-I ableiten,
- kein `frame_started` aus M13-I ableiten,
- keine Bauzustaende aus M13-I ableiten,
- keine TinyObject-Massenproduktion planen,
- keine Sensitive-/Special-Assets planen,
- keine Companion-Animation-/Voice-/Audio-Assets planen,
- keine Growth-/Timer-Druckassets planen,
- keine Social-/Showcase-Assets planen,
- keine PNG-Erzeugung aus M13-I ableiten,
- keine Tests aus M13-I ableiten,
- keinen Code aus M13-I ableiten,
- keine Runtime-Konfiguration aus M13-I ableiten,
- keine automatische Assetproduktion aus Taxonomy, Routing, Capability Sheets,
  Onboarding oder Roadmap ableiten,
- keine Codefreigabe aus M13-J ableiten,
- keine Assetfreigabe aus M13-J ableiten,
- keine App-Integration aus M13-J ableiten,
- keine finale ThemeIsland-Roadmap aus M13-J ableiten,
- keine finale Startinsel aus M13-J ableiten,
- keine finale Onboarding-UI aus M13-J ableiten,
- keine finale Word-to-Island-Implementierung aus M13-J ableiten,
- keine finale Container-/Depth-UI aus M13-J ableiten,
- keine finale Sensitive-Policy-Implementierung aus M13-J ableiten,
- keine finale Growth-/Timer-Implementierung aus M13-J ableiten,
- keine finale Assetliste aus M13-J ableiten,
- keine Runtime-Konfiguration aus M13-J ableiten,
- keine PNG-Erzeugung aus M13-J ableiten,
- keine Tests aus M13-J ableiten,
- kein `frame_started` oder Bauzustand aus M13-J weiterbauen,
- keine finale Onboarding-UI aus M13-K ableiten,
- keine App-Integration aus M13-K ableiten,
- keine Codefreigabe aus M13-K ableiten,
- keine Assetfreigabe aus M13-K ableiten,
- keine finale Startinsel aus M13-K ableiten,
- keine ThemeIsland-Umsetzung aus M13-K ableiten,
- keine finale Datenstruktur aus M13-K ableiten,
- keine Runtime-Konfiguration aus M13-K ableiten,
- keine PNG-Erzeugung aus M13-K ableiten,
- keine Tests aus M13-K ableiten,
- kein `frame_started` oder Bauzustand aus M13-K weiterbauen,
- keine finale Word-to-Island-UI aus M13-L ableiten,
- keine Word-to-Island-Implementierung aus M13-L ableiten,
- keine Routing-Datenstruktur aus M13-L ableiten,
- keine Runtime-Konfiguration aus M13-L ableiten,
- keine automatische Wortplatzierung aus M13-L ableiten,
- keine App-Integration aus M13-L ableiten,
- keine Codefreigabe aus M13-L ableiten,
- keine Assetfreigabe aus M13-L ableiten,
- keine PNG-Erzeugung aus M13-L ableiten,
- keine Tests aus M13-L ableiten,
- kein `frame_started` oder Bauzustand aus M13-L weiterbauen,
- keine finale ContainerOpenView-UI aus M13-M ableiten,
- keine finale DetailInteractionView-UI aus M13-M ableiten,
- keine Container-Implementierung aus M13-M ableiten,
- keine finale Datenstruktur aus M13-M ableiten,
- keine Runtime-Konfiguration aus M13-M ableiten,
- keine App-Integration aus M13-M ableiten,
- keine Codefreigabe aus M13-M ableiten,
- keine Assetfreigabe aus M13-M ableiten,
- keine PNG-Erzeugung aus M13-M ableiten,
- keine Tests aus M13-M ableiten,
- kein `frame_started` oder Bauzustand aus M13-M weiterbauen,
- keine finale Foundation-Choice-UI aus M13-N ableiten,
- keine finale Onboarding-UI aus M13-N ableiten,
- keine finale Startinsel aus M13-N ableiten,
- keine App-Integration aus M13-N ableiten,
- keine Codefreigabe aus M13-N ableiten,
- keine Assetfreigabe aus M13-N ableiten,
- keine finale Datenstruktur aus M13-N ableiten,
- keine Runtime-Konfiguration aus M13-N ableiten,
- keine PNG-Erzeugung aus M13-N ableiten,
- keine Tests aus M13-N ableiten,
- kein `frame_started` oder Bauzustand aus M13-N weiterbauen,
- keine finale ThemeIsland-Roadmap aus M13-O ableiten,
- keine ThemeIsland-Umsetzung aus M13-O ableiten,
- keine finale Startinsel aus M13-O ableiten,
- keine finale Onboarding-UI aus M13-O ableiten,
- keine finale Foundation-Choice-UI aus M13-O ableiten,
- keine finale Datenstruktur aus M13-O ableiten,
- keine Runtime-Konfiguration aus M13-O ableiten,
- keine App-Integration aus M13-O ableiten,
- keine Codefreigabe aus M13-O ableiten,
- keine Assetfreigabe aus M13-O ableiten,
- keine PNG-Erzeugung aus M13-O ableiten,
- keine Tests aus M13-O ableiten,
- kein `frame_started` oder Bauzustand aus M13-O weiterbauen,
- keine Codefreigabe aus M13-P ableiten,
- keine Implementierung aus M13-P ableiten,
- keine Tests aus M13-P ableiten,
- keine App-Integration aus M13-P ableiten,
- keine Assetfreigabe aus M13-P ableiten,
- keine PNG-Erzeugung aus M13-P ableiten,
- keine finale ThemeIsland-Roadmap aus M13-P ableiten,
- keine finale Startinsel aus M13-P ableiten,
- keine finale Onboarding-UI aus M13-P ableiten,
- keine finale Foundation-Choice-UI aus M13-P ableiten,
- keine finale Word-to-Island-UI aus M13-P ableiten,
- keine finale Container-UI aus M13-P ableiten,
- keine finale Datenstruktur aus M13-P ableiten,
- keine Runtime-Konfiguration aus M13-P ableiten,
- kein `frame_started` oder Bauzustand aus M13-P weiterbauen,
- keine finale Foundation-Choice-UI aus M14-A ableiten,
- keine finale Onboarding-UI aus M14-A ableiten,
- keine finale Startinsel aus M14-A ableiten,
- keine finale ThemeIsland-Roadmap aus M14-A ableiten,
- keine App-Integration aus M14-A ableiten,
- keine Codefreigabe aus M14-A ableiten,
- keine Implementierungsfreigabe aus M14-A ableiten,
- keine Assetfreigabe aus M14-A ableiten,
- keine finale Datenstruktur aus M14-A ableiten,
- keine Runtime-Konfiguration aus M14-A ableiten,
- keine automatische Wortplatzierung aus M14-A ableiten,
- keine PNG-Erzeugung aus M14-A ableiten,
- keine Tests aus M14-A ableiten,
- keine Spielassets aus M14-A ableiten,
- kein `frame_started` oder Bauzustand aus M14-A weiterbauen,
- keine finale Foundation-Choice-UI aus M14-A2 ableiten,
- keine finale Onboarding-UI aus M14-A2 ableiten,
- keine finale Startinsel aus M14-A2 ableiten,
- keine App-Integration aus M14-A2 ableiten,
- keine Codefreigabe aus M14-A2 ableiten,
- keine Implementierungsfreigabe aus M14-A2 ableiten,
- keine Assetfreigabe aus M14-A2 ableiten,
- keine finale Datenstruktur aus M14-A2 ableiten,
- keine Runtime-Konfiguration aus M14-A2 ableiten,
- keine automatische Wortplatzierung aus M14-A2 ableiten,
- keine PNG-Erzeugung aus M14-A2 ableiten,
- keine Tests aus M14-A2 ableiten,
- keine Spielassets aus M14-A2 ableiten,
- kein `frame_started` oder Bauzustand aus M14-A2 weiterbauen,
- keine finale Word-to-Island-UI aus M14-B ableiten,
- keine Word-to-Island-Implementierung aus M14-B ableiten,
- keine finale Routing-Datenstruktur aus M14-B ableiten,
- keine Runtime-Konfiguration aus M14-B ableiten,
- keine automatische Wortplatzierung aus M14-B ableiten,
- keine App-Integration aus M14-B ableiten,
- keine Codefreigabe aus M14-B ableiten,
- keine Implementierungsfreigabe aus M14-B ableiten,
- keine Assetfreigabe aus M14-B ableiten,
- keine PNG-Erzeugung aus M14-B ableiten,
- keine Tests aus M14-B ableiten,
- keine Spielassets aus M14-B ableiten,
- kein `frame_started` oder Bauzustand aus M14-B weiterbauen,
- keine finale Word-to-Island-UI aus M14-B2 ableiten,
- keine Word-to-Island-Implementierung aus M14-B2 ableiten,
- keine finale Routing-Datenstruktur aus M14-B2 ableiten,
- keine Runtime-Konfiguration aus M14-B2 ableiten,
- keine automatische Wortplatzierung aus M14-B2 ableiten,
- keine App-Integration aus M14-B2 ableiten,
- keine Codefreigabe aus M14-B2 ableiten,
- keine Implementierungsfreigabe aus M14-B2 ableiten,
- keine Assetfreigabe aus M14-B2 ableiten,
- keine PNG-Erzeugung aus M14-B2 ableiten,
- keine Tests aus M14-B2 ableiten,
- keine Spielassets aus M14-B2 ableiten,
- kein `frame_started` oder Bauzustand aus M14-B2 weiterbauen,
- keine finale ContainerOpenView-UI aus M14-C ableiten,
- keine finale DetailInteractionView-UI aus M14-C ableiten,
- keine Container-Implementierung aus M14-C ableiten,
- keine finale Datenstruktur aus M14-C ableiten,
- keine Runtime-Konfiguration aus M14-C ableiten,
- keine App-Integration aus M14-C ableiten,
- keine Codefreigabe aus M14-C ableiten,
- keine Implementierungsfreigabe aus M14-C ableiten,
- keine Assetfreigabe aus M14-C ableiten,
- keine PNG-Erzeugung aus M14-C ableiten,
- keine Tests aus M14-C ableiten,
- keine Spielassets aus M14-C ableiten,
- kein `frame_started` oder Bauzustand aus M14-C weiterbauen,
- keine finale ContainerOpenView-UI aus M14-C2 ableiten,
- keine finale DetailInteractionView-UI aus M14-C2 ableiten,
- keine Container-Implementierung aus M14-C2 ableiten,
- keine finale Datenstruktur aus M14-C2 ableiten,
- keine Runtime-Konfiguration aus M14-C2 ableiten,
- keine App-Integration aus M14-C2 ableiten,
- keine Codefreigabe aus M14-C2 ableiten,
- keine Implementierungsfreigabe aus M14-C2 ableiten,
- keine Assetfreigabe aus M14-C2 ableiten,
- keine PNG-Erzeugung aus M14-C2 ableiten,
- keine Tests aus M14-C2 ableiten,
- keine Spielassets aus M14-C2 ableiten,
- kein `frame_started` oder Bauzustand aus M14-C2 weiterbauen,
- keine Harness-Implementierung aus M14-D ableiten,
- keine Tests aus M14-D ableiten,
- keine Widget-Tests aus M14-D ableiten,
- keine Flutter-/Dart-Dateien aus M14-D ableiten,
- keine App-Integration aus M14-D ableiten,
- keine finale UI aus M14-D ableiten,
- keine finale Datenstruktur aus M14-D ableiten,
- keine Runtime-Konfiguration aus M14-D ableiten,
- keine Codefreigabe aus M14-D ableiten,
- keine Implementierungsfreigabe aus M14-D ableiten,
- keine Assetfreigabe aus M14-D ableiten,
- keine PNG-Erzeugung aus M14-D ableiten,
- keine Screenshots aus M14-D ableiten,
- keine Spielassets aus M14-D ableiten,
- kein `frame_started` oder Bauzustand aus M14-D weiterbauen,
- keine Harness-Implementierung aus M14-D2 ableiten,
- keine Tests aus M14-D2 ableiten,
- keine Widget-Tests aus M14-D2 ableiten,
- keine Flutter-/Dart-Dateien aus M14-D2 ableiten,
- keine App-Integration aus M14-D2 ableiten,
- keine finale UI aus M14-D2 ableiten,
- keine finale Datenstruktur aus M14-D2 ableiten,
- keine Runtime-Konfiguration aus M14-D2 ableiten,
- keine Codefreigabe aus M14-D2 ableiten,
- keine Implementierungsfreigabe aus M14-D2 ableiten,
- keine Assetfreigabe aus M14-D2 ableiten,
- keine PNG-Erzeugung aus M14-D2 ableiten,
- keine Screenshots aus M14-D2 ableiten,
- keine Spielassets aus M14-D2 ableiten,
- kein `frame_started` oder Bauzustand aus M14-D2 weiterbauen,
- keine Implementierung aus M14-E ableiten,
- keine Tests aus M14-E ableiten,
- keine Widget-Tests aus M14-E ableiten,
- keine Flutter-/Dart-Dateien aus M14-E ableiten,
- keine App-Integration aus M14-E ableiten,
- keine finale UI aus M14-E ableiten,
- keine finale Datenstruktur aus M14-E ableiten,
- keine Runtime-Konfiguration aus M14-E ableiten,
- keine Codefreigabe aus M14-E ableiten,
- keine Implementierungsfreigabe aus M14-E ableiten,
- keine Assetfreigabe aus M14-E ableiten,
- keine PNG-Erzeugung aus M14-E ableiten,
- keine Screenshots aus M14-E ableiten,
- keine Spielassets aus M14-E ableiten,
- keine automatische Wortplatzierung aus M14-E ableiten,
- kein `frame_started` oder Bauzustand aus M14-E weiterbauen,
- keine Implementierung aus M14-E2 ableiten,
- keine Tests aus M14-E2 ableiten,
- keine Widget-Tests aus M14-E2 ableiten,
- keine Flutter-/Dart-Dateien aus M14-E2 ableiten,
- keine App-Integration aus M14-E2 ableiten,
- keine finale UI aus M14-E2 ableiten,
- keine finale Datenstruktur aus M14-E2 ableiten,
- keine Runtime-Konfiguration aus M14-E2 ableiten,
- keine Codefreigabe aus M14-E2 ableiten,
- keine Implementierungsfreigabe aus M14-E2 ableiten,
- keine Assetfreigabe aus M14-E2 ableiten,
- keine PNG-Erzeugung aus M14-E2 ableiten,
- keine Screenshots aus M14-E2 ableiten,
- keine Spielassets aus M14-E2 ableiten,
- keine automatische Wortplatzierung aus M14-E2 ableiten,
- kein `frame_started` oder Bauzustand aus M14-E2 weiterbauen,
- keine App-Integration aus M14-V1 ableiten,
- keine Flutter-/Dart-Dateien aus M14-V1 ableiten,
- keine Tests aus M14-V1 ableiten,
- keine Widget-Tests aus M14-V1 ableiten,
- keine Test-Harness-Implementierung aus M14-V1 ableiten,
- keine Screenshots aus M14-V1 ableiten,
- keine Spielassets aus M14-V1 ableiten,
- keine Asset-Dateien unter `assets/` aus M14-V1 ableiten,
- keine finale UI aus M14-V1 ableiten,
- keine Runtime-Konfiguration aus M14-V1 ableiten,
- keine Codefreigabe aus M14-V1 ableiten,
- keine Implementierungsfreigabe aus M14-V1 ableiten,
- keine App-/Assetfreigabe aus M14-V1 ableiten,
- kein `frame_started` oder Bauzustand aus M14-V1 weiterbauen,
- keine PNG-Aenderung aus M14-V1-B ableiten,
- keine neuen PNGs aus M14-V1-B ableiten,
- keine Implementierung aus M14-V1-B ableiten,
- keine Tests aus M14-V1-B ableiten,
- keine Widget-Tests aus M14-V1-B ableiten,
- keine Flutter-/Dart-Dateien aus M14-V1-B ableiten,
- keine App-Integration aus M14-V1-B ableiten,
- keine finale UI aus M14-V1-B ableiten,
- keine Runtime-Konfiguration aus M14-V1-B ableiten,
- keine Codefreigabe aus M14-V1-B ableiten,
- keine Implementierungsfreigabe aus M14-V1-B ableiten,
- keine Assetfreigabe aus M14-V1-B ableiten,
- keine Screenshots aus M14-V1-B ableiten,
- keine Spielassets aus M14-V1-B ableiten,
- keine Asset-Dateien unter `assets/` aus M14-V1-B ableiten,
- kein `frame_started` oder Bauzustand aus M14-V1-B weiterbauen,
- keine Implementierung aus M15-A ableiten,
- keine Tests aus M15-A ableiten,
- keine Widget-Tests aus M15-A ableiten,
- keine Flutter-/Dart-Dateien aus M15-A ableiten,
- keine App-Integration aus M15-A ableiten,
- keine finale UI aus M15-A ableiten,
- keine Runtime-Konfiguration aus M15-A ableiten,
- keine Persistenz aus M15-A ableiten,
- keine Supabase Writes aus M15-A ableiten,
- keine SRS-/`word_progress`-Aenderung aus M15-A ableiten,
- keine Reward Bridge aus M15-A ableiten,
- keine Codefreigabe aus M15-A ableiten,
- keine Implementierungsfreigabe aus M15-A ableiten,
- keine Assetfreigabe aus M15-A ableiten,
- keine PNG-Erzeugung aus M15-A ableiten,
- keine PNG-Aenderung aus M15-A ableiten,
- keine Screenshots aus M15-A ableiten,
- keine Spielassets aus M15-A ableiten,
- keine Asset-Dateien unter `assets/` aus M15-A ableiten,
- keine automatische Wortplatzierung aus M15-A ableiten,
- kein `frame_started` oder Bauzustand aus M15-A weiterbauen,
- keine Implementierung aus M15-A2 ableiten,
- keine Flutter-/Dart-Dateien aus M15-A2 ableiten,
- keine Tests aus M15-A2 ableiten,
- keine Widget-Tests aus M15-A2 ableiten,
- keine App-Integration aus M15-A2 ableiten,
- keine finale UI aus M15-A2 ableiten,
- keine Runtime-Konfiguration aus M15-A2 ableiten,
- keine Persistenz aus M15-A2 ableiten,
- keine Supabase Writes aus M15-A2 ableiten,
- keine SRS-/`word_progress`-Aenderung aus M15-A2 ableiten,
- keine Reward Bridge aus M15-A2 ableiten,
- keine Codefreigabe aus M15-A2 ableiten,
- keine Implementierungsfreigabe aus M15-A2 ableiten,
- keine Assetfreigabe aus M15-A2 ableiten,
- keine PNG-Erzeugung aus M15-A2 ableiten,
- keine PNG-Aenderung aus M15-A2 ableiten,
- keine Screenshots aus M15-A2 ableiten,
- keine Spielassets aus M15-A2 ableiten,
- keine Asset-Dateien unter `assets/` aus M15-A2 ableiten,
- keine automatische Wortplatzierung aus M15-A2 ableiten,
- kein `frame_started` oder Bauzustand aus M15-A2 weiterbauen,
- keine Implementierung aus M15-A3 ableiten,
- keine Flutter-/Dart-Dateien aus M15-A3 ableiten,
- keine Tests aus M15-A3 ableiten,
- keine Widget-Tests aus M15-A3 ableiten,
- keine App-Integration aus M15-A3 ableiten,
- keine finale UI aus M15-A3 ableiten,
- keine Runtime-Konfiguration aus M15-A3 ableiten,
- keine Persistenz aus M15-A3 ableiten,
- keine Supabase Writes aus M15-A3 ableiten,
- keine SRS-/`word_progress`-Aenderung aus M15-A3 ableiten,
- keine Reward Bridge aus M15-A3 ableiten,
- keine Codefreigabe aus M15-A3 ableiten,
- keine Implementierungsfreigabe aus M15-A3 ableiten,
- keine Assetfreigabe aus M15-A3 ableiten,
- keine Screenshots aus M15-A3 ableiten,
- keine Spielassets aus M15-A3 ableiten,
- keine Asset-Dateien unter `assets/` aus M15-A3 ableiten,
- keine automatische Wortplatzierung aus M15-A3 ableiten,
- kein `frame_started` oder Bauzustand aus M15-A3 weiterbauen,
- keine Implementierung aus M15-A4 ableiten,
- keine Flutter-/Dart-Dateien aus M15-A4 ableiten,
- keine Tests aus M15-A4 ableiten,
- keine Widget-Tests aus M15-A4 ableiten,
- keine App-Integration aus M15-A4 ableiten,
- keine finale UI aus M15-A4 ableiten,
- keine Runtime-Konfiguration aus M15-A4 ableiten,
- keine Persistenz aus M15-A4 ableiten,
- keine Supabase Writes aus M15-A4 ableiten,
- keine SRS-/`word_progress`-Aenderung aus M15-A4 ableiten,
- keine Reward Bridge aus M15-A4 ableiten,
- keine Codefreigabe aus M15-A4 ableiten,
- keine Implementierungsfreigabe aus M15-A4 ableiten,
- keine Assetfreigabe aus M15-A4 ableiten,
- keine PNG-Erzeugung aus M15-A4 ableiten,
- keine PNG-Aenderung aus M15-A4 ableiten,
- keine Screenshots aus M15-A4 ableiten,
- keine Spielassets aus M15-A4 ableiten,
- keine Asset-Dateien unter `assets/` aus M15-A4 ableiten,
- keine automatische Wortplatzierung aus M15-A4 ableiten,
- kein `frame_started` oder Bauzustand aus M15-A4 weiterbauen,
- keine App-Integration aus M15-B ableiten,
- keine Home-/Onboarding-/World-Routing-Integration aus M15-B ableiten,
- keine Persistenz aus M15-B ableiten,
- keine Runtime-Konfiguration aus M15-B ableiten,
- keine Supabase Writes aus M15-B ableiten,
- keine lokalen DB-Writes aus M15-B ableiten,
- keine SRS-/`word_progress`-Aenderung aus M15-B ableiten,
- keine Reward Bridge aus M15-B ableiten,
- keine automatische Wortplatzierung aus M15-B ableiten,
- keine Assetfreigabe aus M15-B ableiten,
- keine Tests aus M15-B ableiten,
- keine Widget-Tests aus M15-B ableiten,
- keine Screenshots aus M15-B ableiten,
- kein Build-State aus M15-B ableiten,
- kein `frame_started` oder Bauzustand aus M15-B weiterbauen,
- keine Harness-Implementierung aus M15-C ableiten,
- keine Flutter-/Dart-Dateien aus M15-C ableiten,
- keine App-Integration aus M15-C ableiten,
- keine Home-/Onboarding-/World-Routing-Integration aus M15-C ableiten,
- keine Tests aus M15-C ableiten,
- keine Widget-Tests aus M15-C ableiten,
- keine Screenshots aus M15-C ableiten,
- keine Persistenz aus M15-C ableiten,
- keine Runtime-Konfiguration aus M15-C ableiten,
- keine Supabase Writes aus M15-C ableiten,
- keine lokalen DB-Writes aus M15-C ableiten,
- keine SRS-/`word_progress`-Aenderung aus M15-C ableiten,
- keine Reward Bridge aus M15-C ableiten,
- keine automatische Wortplatzierung aus M15-C ableiten,
- keine Assetfreigabe aus M15-C ableiten,
- kein Build-State aus M15-C ableiten,
- kein `frame_started` oder Bauzustand aus M15-C weiterbauen,
- keine Harness-Implementierung aus M15-D ableiten,
- keine Flutter-/Dart-Dateien aus M15-D ableiten,
- keine App-Integration aus M15-D ableiten,
- keine Home-/Onboarding-/World-Routing-Integration aus M15-D ableiten,
- keine Tests aus M15-D ableiten,
- keine Widget-Tests aus M15-D ableiten,
- keine Screenshots aus M15-D ableiten,
- keine Persistenz aus M15-D ableiten,
- keine Runtime-Konfiguration aus M15-D ableiten,
- keine Supabase Writes aus M15-D ableiten,
- keine lokalen DB-Writes aus M15-D ableiten,
- keine SRS-/`word_progress`-Aenderung aus M15-D ableiten,
- keine Reward Bridge aus M15-D ableiten,
- keine automatische Wortplatzierung aus M15-D ableiten,
- keine Assetfreigabe aus M15-D ableiten,
- kein Build-State aus M15-D ableiten,
- kein `frame_started` oder Bauzustand aus M15-D weiterbauen,
- keine Harness-Implementierung aus M15-D2 ableiten,
- keine Flutter-/Dart-Dateien aus M15-D2 ableiten,
- keine App-Integration aus M15-D2 ableiten,
- keine Home-/Onboarding-/World-Routing-Integration aus M15-D2 ableiten,
- keine Tests aus M15-D2 ableiten,
- keine Widget-Tests aus M15-D2 ableiten,
- keine Screenshots aus M15-D2 ableiten,
- keine Persistenz aus M15-D2 ableiten,
- keine Runtime-Konfiguration aus M15-D2 ableiten,
- keine Supabase Writes aus M15-D2 ableiten,
- keine lokalen DB-Writes aus M15-D2 ableiten,
- keine SRS-/`word_progress`-Aenderung aus M15-D2 ableiten,
- keine Reward Bridge aus M15-D2 ableiten,
- keine automatische Wortplatzierung aus M15-D2 ableiten,
- keine Assetfreigabe aus M15-D2 ableiten,
- kein Build-State aus M15-D2 ableiten,
- kein `frame_started` oder Bauzustand aus M15-D2 weiterbauen,
- keine Flutter-/Dart-Dateien aus M16-A ableiten,
- keine App-Integration aus M16-A ableiten,
- keine Tests aus M16-A ableiten,
- keine Screenshots aus M16-A ableiten,
- keine Persistenz aus M16-A ableiten,
- keine Runtime-Konfiguration aus M16-A ableiten,
- keine Supabase Writes aus M16-A ableiten,
- keine lokalen DB-Writes aus M16-A ableiten,
- keine SRS-/`word_progress`-Aenderung aus M16-A ableiten,
- keine Reward Bridge aus M16-A ableiten,
- keine automatische Wortplatzierung aus M16-A ableiten,
- keine Assetfreigabe aus M16-A ableiten,
- keine neuen Spielassets aus M16-A ableiten,
- keine Asset-Dateien unter `assets/` aus M16-A ableiten,
- kein finales Inselbild aus M16-A ableiten,
- kein `frame_started` oder Bauzustand aus M16-A weiterbauen,
- keine Implementierung aus M16-I ableiten,
- keine Flutter-/Dart-Dateien aus M16-I ableiten,
- keine App-Integration aus M16-I ableiten,
- keine Route oder neue Seite aus M16-I ableiten,
- keine Build-Wheel-Implementierung aus M16-I ableiten,
- keine Tests oder Screenshots aus M16-I ableiten,
- keine Persistenz aus M16-I ableiten,
- keine Runtime-Konfiguration aus M16-I ableiten,
- keine Supabase Writes oder lokalen DB-Writes aus M16-I ableiten,
- keine SRS-/`word_progress`-Aenderung aus M16-I ableiten,
- keine Reward Bridge aus M16-I ableiten,
- keine automatische Wortplatzierung aus M16-I ableiten,
- keine Assets oder Asset-Dateien unter `assets/` aus M16-I ableiten,
- kein Build-State aus M16-I ableiten,
- kein `frame_started` oder Bauzustand aus M16-I weiterbauen,
- keine Implementierung aus M16-J ableiten,
- keine Flutter-/Dart-Dateien aus M16-J ableiten,
- keine App-Integration aus M16-J ableiten,
- keine Route oder neue Seite aus M16-J ableiten,
- keine Build-Wheel-Implementierung aus M16-J ableiten,
- keine Tests oder Screenshots aus M16-J ableiten,
- keine Persistenz aus M16-J ableiten,
- keine Runtime-Konfiguration aus M16-J ableiten,
- keine Supabase Writes oder lokalen DB-Writes aus M16-J ableiten,
- keine SRS-/`word_progress`-Aenderung aus M16-J ableiten,
- keine Reward Bridge aus M16-J ableiten,
- keine automatische Wortplatzierung aus M16-J ableiten,
- keine Assets oder Asset-Dateien unter `assets/` aus M16-J ableiten,
- kein Build-State aus M16-J ableiten,
- kein `frame_started` oder Bauzustand aus M16-J weiterbauen,
- keine Implementierung aus M16-K ableiten,
- keine Flutter-/Dart-Dateien aus M16-K ableiten,
- keine App-Integration aus M16-K ableiten,
- keine Route oder neue Seite aus M16-K ableiten,
- keine Build-Wheel-Implementierung aus M16-K ableiten,
- keine Tests oder Screenshots aus M16-K ableiten,
- keine Persistenz aus M16-K ableiten,
- keine Runtime-Konfiguration aus M16-K ableiten,
- keine Supabase Writes oder lokalen DB-Writes aus M16-K ableiten,
- keine SRS-/`word_progress`-Aenderung aus M16-K ableiten,
- keine Reward Bridge aus M16-K ableiten,
- keine automatische Wortplatzierung aus M16-K ableiten,
- keine Assets oder Asset-Dateien unter `assets/` aus M16-K ableiten,
- kein Build-State aus M16-K ableiten,
- kein `frame_started` oder Bauzustand aus M16-K weiterbauen,
- keine Implementierung aus M16-L ableiten,
- keine Flutter-/Dart-Dateien aus M16-L ableiten,
- keine App-Integration aus M16-L ableiten,
- keine Route oder neue Seite aus M16-L ableiten,
- keine Build-Wheel-Implementierung aus M16-L ableiten,
- keine Tests oder Screenshots aus M16-L ableiten,
- keine Persistenz aus M16-L ableiten,
- keine Runtime-Konfiguration aus M16-L ableiten,
- keine Supabase Writes oder lokalen DB-Writes aus M16-L ableiten,
- keine SRS-/`word_progress`-Aenderung aus M16-L ableiten,
- keine Reward Bridge aus M16-L ableiten,
- keine automatische Wortplatzierung aus M16-L ableiten,
- keine Assets oder Asset-Dateien unter `assets/` aus M16-L ableiten,
- kein Build-State aus M16-L ableiten,
- kein `frame_started` oder Bauzustand aus M16-L weiterbauen,
- keine Implementierung aus M16-M ableiten,
- keine Flutter-/Dart-Dateien aus M16-M ableiten,
- keine App-Integration aus M16-M ableiten,
- keine Route oder neue Seite aus M16-M ableiten,
- keine Build-Wheel-Implementierung aus M16-M ableiten,
- keine Tests oder Screenshots aus M16-M ableiten,
- keine Persistenz aus M16-M ableiten,
- keine Runtime-Konfiguration aus M16-M ableiten,
- keine Supabase Writes oder lokalen DB-Writes aus M16-M ableiten,
- keine SRS-/`word_progress`-Aenderung aus M16-M ableiten,
- keine Reward Bridge aus M16-M ableiten,
- keine automatische Wortplatzierung aus M16-M ableiten,
- keine Assets oder Asset-Dateien unter `assets/` aus M16-M ableiten,
- kein Build-State aus M16-M ableiten,
- kein `frame_started` oder Bauzustand aus M16-M weiterbauen,
- keine Implementierung aus M16-N ableiten,
- keine Flutter-/Dart-Dateien aus M16-N ableiten,
- keine App-Integration aus M16-N ableiten,
- keine Route oder neue Seite aus M16-N ableiten,
- keine Tests oder Screenshots aus M16-N ableiten,
- keine Persistenz aus M16-N ableiten,
- keine Runtime-Konfiguration aus M16-N ableiten,
- keine Supabase Writes oder lokalen DB-Writes aus M16-N ableiten,
- keine SRS-/`word_progress`-Aenderung aus M16-N ableiten,
- keine Reward Bridge aus M16-N ableiten,
- keine automatische Wortplatzierung aus M16-N ableiten,
- keine Assets oder Asset-Dateien unter `assets/` aus M16-N ableiten,
- kein Build-State aus M16-N ableiten,
- kein `frame_started` oder Bauzustand aus M16-N weiterbauen,
- keine Implementierung aus M16-O ableiten,
- keine Flutter-/Dart-Dateien aus M16-O ableiten,
- keine App-Integration aus M16-O ableiten,
- keine Route oder neue Seite aus M16-O ableiten,
- keine Tests oder Screenshots aus M16-O ableiten,
- keine Persistenz aus M16-O ableiten,
- keine Runtime-Konfiguration aus M16-O ableiten,
- keine Supabase Writes oder lokalen DB-Writes aus M16-O ableiten,
- keine SRS-/`word_progress`-Aenderung aus M16-O ableiten,
- keine Reward Bridge aus M16-O ableiten,
- keine automatische Wortplatzierung aus M16-O ableiten,
- keine Assets oder Asset-Dateien unter `assets/` aus M16-O ableiten,
- kein Build-State aus M16-O ableiten,
- kein `frame_started` oder Bauzustand aus M16-O weiterbauen,
- keine Implementierung aus M16-P ableiten,
- keine Flutter-/Dart-Dateien aus M16-P ableiten,
- keine neue Dart-Datei aus M16-P ableiten,
- keine App-Integration aus M16-P ableiten,
- keine Route oder neue Seite aus M16-P ableiten,
- keine Tests oder Screenshots aus M16-P ableiten,
- keine Persistenz aus M16-P ableiten,
- keine Runtime-Konfiguration aus M16-P ableiten,
- keine Supabase Writes oder lokalen DB-Writes aus M16-P ableiten,
- keine SRS-/`word_progress`-Aenderung aus M16-P ableiten,
- keine Reward Bridge aus M16-P ableiten,
- keine automatische Wortplatzierung aus M16-P ableiten,
- keine Build-Wheel-Implementierung aus M16-P ableiten,
- keine Assets oder Asset-Dateien unter `assets/` aus M16-P ableiten,
- kein Build-State aus M16-P ableiten,
- kein `frame_started` oder Bauzustand aus M16-P weiterbauen,
- keine Implementierung aus M16-R ableiten,
- keine Flutter-/Dart-Dateien aus M16-R ableiten,
- keine App-Integration aus M16-R ableiten,
- keine Route oder neue Seite aus M16-R ableiten,
- keine Tests oder Screenshots aus M16-R ableiten,
- keine Persistenz aus M16-R ableiten,
- keine Runtime-Konfiguration aus M16-R ableiten,
- keine Supabase Writes oder lokalen DB-Writes aus M16-R ableiten,
- keine SRS-/`word_progress`-Aenderung aus M16-R ableiten,
- keine Reward Bridge aus M16-R ableiten,
- keine automatische Wortplatzierung aus M16-R ableiten,
- keine Build-Wheel-Implementierung aus M16-R ableiten,
- keine Assets oder Asset-Dateien unter `assets/` aus M16-R ableiten,
- kein Build-State aus M16-R ableiten,
- kein `frame_started` oder Bauzustand aus M16-R weiterbauen,
- keine Foundation-Insel ohne spaetere Device-/Accessibility-/Tap-Target-
  Pruefung planen,
- keine Garten-/Growth-Mechanik ohne Fairness-/Timer-Regeln planen,
- keine Schule-/Kleinteile-Umsetzung ohne Mobile-/Clutter-Regeln planen,
- keinen Zuhause-/Alltag-Start als Pflicht-Hausstart planen,
- keine Sensitive-/Special-Insel ohne vertiefte Sensitive-Content-/Safety-/
  UX-Regeln planen,
- keine Stadt-/Verkehr-/Technikinsel ohne eigenes Systemkonzept planen,
- keine Kuesten-/Hafeninsel ohne Water-/Dock-/Mobile-
  Komplexitaetspruefung planen,
- keine automatische Darstellung sensibler oder abstrakter Begriffe planen,
- keine ThemeIsland-Umsetzung aus M12 ableiten,
- keine finale ThemeIsland-Roadmap aus M12 ableiten,
- keine Assetproduktion aus M12 ableiten,
- keine Kuesten-/Hafeninsel ohne Mobile-Komplexitaetspruefung planen,
- keine Gesundheits-, Politik-, Religion-, Gerichts-, Polizei- oder
  Krankenhausinsel ohne Sensitive-Content-Regeln planen,
- keine Reise-/Verkehrsinsel ohne Connector-/Path-/Vehicle-Konzept planen,
- keine Technik-/Digitalinsel ohne eigene Digital-Object-/UI-Abgrenzung
  planen,
- keine fruehe Insel planen, wenn sie zu viele neue Systeme gleichzeitig
  erzwingt,
- keine Preview committen, wenn wichtige Texte aus Karten, Rahmen oder Panels
  herauslaufen,
- kein weiterer Bau-Code ausserhalb der abgeschlossenen lokalen Mock-Slices.

## 6. Dokument-Abhaengigkeiten

Fuehrende Abhaengigkeiten:

- Economy/Balancing muss vor Reward/Baukosten beachtet werden.
- In-World-Learning UI muss vor Aufgaben-UI beachtet werden.
- Build Progression/Zones muss vor BuildZones/Items beachtet werden.
- Onboarding muss vor erstem Nutzerflow beachtet werden.
- Asset Production muss vor Bau-Code beachtet werden.
- Cloud, Monetization und Social sind noch nicht ausgearbeitet und duerfen
  nicht gebaut werden.

Konsequenzen:

- Kein Reward- oder Ressourcen-Code ohne `224`.
- Keine Aufgabenkarte ohne `225`.
- Keine BuildZone-/Item-Logik ohne `226`.
- Kein erster Nutzerfluss ohne `232`.
- Kein neuer Bau-Code ohne `234`.
- Keine Cloud Writes ohne spaeteres Cloud-/Persistenzdokument.
- Keine Monetarisierung ohne spaeteres Monetarisierungsdokument.
- Keine Social-Funktion ohne spaeteres Social-/Moderationsdokument.

## 7. Asset-Freigabe-Checkliste

Vor Asset-Nutzung pruefen:

- PNG transparent.
- Kein Space-Hintergrund.
- Keine UI, Schrift oder Buttons.
- Bauflaeche wirkt natuerlich.
- Base und Overlay passen perspektivisch.
- `logicalBounds` sind dokumentiert.
- BuildZone-Anker sind dokumentiert.
- Aufbau-Assets haben `referenceState`, `build_center`, Support-Anker,
  `safe_inner_build_polygon` und `max_frame_footprint_polygon`.
- Aufbau-Assets sind einem Plot-Typ und einem `building_footprint_polygon`
  zugeordnet.
- Plot-Sockets und Weg-/Zaun-/Deko-Anker sind fuer anschlussrelevante Assets
  dokumentiert.
- Support-Fuesse/Kontaktpunkte sitzen sichtbar auf dem Referenzzustand und
  nicht ausserhalb des zulaessigen Fundaments.
- Debug-Overlay-Pruefung mit Referenzzustand wurde bestanden.
- `foundation_started` wirkt nicht wie Overlay.
- Device-Screenshot wurde geprueft.
- Status ist `freigegeben`.

Wenn ein Punkt fehlt, bleibt das Asset blockiert.

## 8. Code-Freigabe-Checkliste

Vor jedem World-Codeprompt pruefen:

- Passendes Planungsdokument existiert.
- Verwendete Assets sind freigegeben.
- Template-Metadaten sind vorhanden.
- Scope ist klein genug.
- Keine offenen visuellen Blocker.
- Keine Supabase Writes, ausser explizit geplant.
- Keine SRS-/`word_progress`-Aenderung, ausser explizit geplant.
- Keine Reward Bridge, ausser explizit geplant.
- Keine Persistenz, ausser explizit geplant.
- Tests oder Device-Check sind definiert.

Wenn der Prompt versucht, fehlende Assets durch Code zu kaschieren, wird der
Prompt gestoppt oder auf Asset-/Planungsarbeit zurueckgefuehrt.

## 8a. Visualisierungspflicht Fuer Entscheidungsrelevante Systeme

Talvori-Entscheidungen sollen nicht nur textlich dokumentiert werden. Sobald
ein Zustand, System, Flow, Layout, Bauzustand, Plot-System, Lernlogik,
UI-Entscheidung, Retention-Loop oder eine Freigabe entscheidungsrelevant wird,
muss geprueft werden, ob eine visuelle Darstellung noetig ist.

Geeignete Visualisierungen:

- Diagramm,
- Flowchart,
- Greybox,
- Debug-Preview,
- Statusbild,
- Nutzerflow-Bild,
- Vorher/Nachher-Bild,
- Overlay-Pruefung,
- einfache Produktansicht,
- technische QA-Ansicht.

Zweck:

- fehlende Elemente frueh erkennen,
- Ueberladung sichtbar machen,
- falsche Annahmen pruefen,
- unklare Zustaende klaeren,
- falsche Reihenfolgen und nicht bedachte Abhaengigkeiten entdecken,
- technische Debugsicht und spaetere Nutzer-/Produktansicht trennen.

Regeln:

- Bei finalen oder freigaberelevanten Entscheidungen braucht es mindestens
  eine visuelle Pruefung oder eine dokumentierte Begruendung, warum keine
  visuelle Darstellung noetig ist.
- Technische Debugansichten und Nutzer-/Produktansichten muessen getrennt
  werden, wenn die technische Ansicht zu komplex ist.
- Dokumentations-/Preview-Bilder sind keine Spielassets.
- Dokumentations-/Preview-Bilder geben keine automatische Code- oder
  Assetfreigabe.
- Eine Visualisierung darf eine Entscheidung pruefbar machen, aber nicht
  heimlich neue Architektur, neue Assets oder App-Integration freigeben.
- Preview-Texte muessen sichtbar innerhalb ihrer Karten, Rahmen oder Panels
  bleiben.
- Kein Label darf aus einer Box herauslaufen oder abgeschnitten wirken.
- Karten, Panels und Flow-Knoten brauchen ausreichend Padding fuer lange Titel.
- Lange Titel muessen umgebrochen, gekuerzt oder mit groesserer Box
  dargestellt werden.
- Neue Dokumentationsdiagramme muessen zusaetzlich pruefen, dass Karten,
  Labels, Pfeile, Titel, Footer, Legenden, Rahmen und Contact-Sheet-Kacheln
  nicht ueberlappen und dass kein Inhalt abgeschnitten wird.
- Vor Commit soll bei neuen Preview-PNGs eine kurze visuelle
  Text-Containment-Pruefung erfolgen.
- Wenn eine unkritische Dokumentationsauffaelligkeit sichtbar ist, darf sie als
  Quality Note dokumentiert werden; fuer spaetere Previews bleibt sie trotzdem
  als Qualitaetsregel verbindlich.

## 9. Phase-2E ToDo-Liste

Konkrete ToDos:

- Buildable Waldlichtung-Konzept finalisieren.
- Asset-Prompt fuer base erstellen.
- Base-Asset erzeugen.
- Alpha/Transparenz pruefen.
- `foundation_started`-Prompt erstellen.
- Overlay-Asset erzeugen.
- Overlay auf base visuell pruefen.
- `template.md` erstellen.
- BuildZone-Anker definieren.
- Device-Screenshot pruefen.
- Entscheidung dokumentieren.
- Erst dann Codeprompt formulieren.

Aktueller Schwerpunkt:

Die ToDos bis einschliesslich Device-Screenshot waren Asset- und
Dokumentationsarbeit und sind fuer Phase 2E-D erledigt.
Die lokale Device-Mock-Preview, der isolierte Widget-Test-Harness und die
Anker-/Bounds-Dokumentation sind erledigt. Die Freigabeentscheidung fuer Phase
2E-D ist dokumentiert. Phase 2E-E ist als kleiner lokaler Mock-Code-Slice
umgesetzt, visuell geprueft, bestanden und mit Commit
`c82880e4 feat: polish forest clearing foundation guidance` abgeschlossen.
Die Planung von Phase 2F (`foundation_complete` Konzept, Asset, Scope,
Feedback und Tests) ist mit
`docs/world_design/242-foundation-complete-plan.md` gestartet und fuer den
engen lokalen Mock-Slice abgeschlossen.
`foundation_complete.png` wurde erzeugt, lokal vorgeprueft, formal
freigegeben, als lokaler Phase-2F-Mock-Slice umgesetzt, auf Geraet geprueft
und mit Commit `b13d2162 fix: refine foundation complete guidance flow`
abgeschlossen. Phase 2G-Planung (`frame_started` / Rohbau) wurde mit
`docs/world_design/243-frame-started-plan.md` gestartet. Der
Asset-Prompt-/Freigabeblock wurde in
`docs/world_design/244-frame-started-asset-prompt.md` vorbereitet. Die
nachfolgende lokale Sichtpruefung des `frame_started.png`-Kandidaten hat einen
zusaetzlichen Anchor-/Alignment-Block erzwungen:
`docs/world_design/245-build-alignment-and-anchor-system.md`. Danach wurde
Phase 2G vollstaendig gestoppt, weil vor weiteren Bauassets zuerst das
Waldlichtung-Masterlayout mit modularen Plot-Flaechen und Anschlussregeln
geplant werden muss:
`docs/world_design/246-island-master-layout-and-modular-plot-system.md`.
Der Greybox-/Scale-/Plot-Messblock wurde in
`docs/world_design/247-island-greybox-scale-and-plot-metrics.md` gestartet.
Der konkrete Plot-Metrik-/Koordinaten-Greybox-Block wurde in
`docs/world_design/248-island-plot-metrics-and-greybox-layout.md` gestartet.
Der sichtbare Greybox-Preview-/Layout-Pruefblock wurde in
`docs/world_design/249-island-greybox-preview-plan.md` gestartet. Der
Debug-Greybox-Preview-Erzeugungsblock hat die geplanten Preview-Dateien unter
`docs/world_design/previews/phase2g_m3_island_greybox/` erzeugt. Der visuelle
Greybox-Layout-Review wurde in
`docs/world_design/250-island-greybox-layout-review.md` gestartet. Ergebnis:
M4 ist technisch pruefbar, aber visuell zu linear/rasterhaft und sollte durch
eine neue M5-Greybox-Variante nachgebessert werden. Die Variante-B-Preview und
manuelle Sichtpruefung haben danach gezeigt, dass feste Rollen wie
`starter_home`, `garden_west` oder `market_square` nicht als finale
Gebaeudepositionen bestaetigt werden duerfen. Die flexible
Plot-/Learning-Semantics-Planung wurde in
`docs/world_design/252-flexible-plot-placement-and-learning-semantics.md`
gestartet. Asset-Freigabe und Code bleiben blockiert, bis Plot-Capabilities,
Nutzerplatzierung, Wort-Semantik, Anchor, Footprint, sichtbare Preview,
Device-Check, Freigabe und Tests definiert sind.

## 10. Stop-Regeln

Ein Schritt wird gestoppt, wenn:

- Asset nicht buildable wirkt,
- Overlay wie UI oder Marker wirkt,
- Bauflaeche nicht klar ist,
- Perspektive nicht passt,
- ein aufbauendes BuildAreaState-Asset nicht auf definierten Support-Ankern
  oder innerhalb des zulaessigen Footprints steht,
- ein neues Bauasset keinen Plot-Typ hat,
- ein neues Bauasset keinen Anchor hat,
- ein neues Bauasset keinen Footprint hat,
- ein anschlussrelevantes Asset kein Socket-/Connection-Konzept hat,
- ein neues Inselasset ohne Masterlayout gestartet wird,
- ein Plot-Asset ohne Plotgroesse gestartet wird,
- ein Gebaeudeasset ohne Gebaeude-Footprint gestartet wird,
- ein Wegasset ohne Socket-Kompatibilitaet gestartet wird,
- ein Dekoasset ohne Deko-Sicherheitszone gestartet wird,
- eine Insel als vollstaendige Privatinsel behandelt wird, obwohl sie nur
  `StarterCorePlot` ist,
- `frame_started` weitergebaut werden soll, bevor `starter_home_plot` im
  Masterlayout definiert ist,
- ein finales Inselbild aus einer Debug-Greybox abgeleitet werden soll,
- eine Greybox ohne Status-Legende entsteht,
- ein Plot ohne sichtbaren Socket bewertet wird,
- ein Weg ohne pruefbare Verbindung entsteht,
- ein Gebaeude-Footprint ohne Sicherheitsabstand eingezeichnet wird,
- das Starterlayout weniger als 7 funktionale Slots zeigt,
- die Ausbauinsel nicht mindestens 12 geplante Slots plausibel vorbereitet,
- Asset-Produktion gestartet wird, bevor die Greybox visuell geprueft wurde,
- eine Greybox als bestaetigt behandelt wird, obwohl sie zu linear oder
  rasterhaft wirkt,
- eine Plot-Greybox als feste Gebaeudeanordnung behandelt wird,
- ein Nutzer mit Hausbau beginnen muss,
- ein Lernwort ohne passenden Kontext platziert werden soll,
- ein `Fenster` ohne Wand oder passenden Hauszustand platziert werden soll,
- eine `Giesskanne` ohne Garten, Hof oder geeigneten Objektanker platziert
  werden soll,
- ein abstraktes Wort als beliebiges physisches Objekt erzwungen wird,
- automatische Platzierung ohne Nutzerbestaetigung geplant wird,
- Kategorien hart codiert werden,
- Spielassets erzeugt werden, bevor Plot-Flexibilitaet und Wort-Semantik
  geklaert sind,
- ein Wort-zu-Welt-System ohne Placement Decision Pipeline geplant wird,
- ein Word-to-World-System ohne abstrakte Datenmodell-Skizze geplant wird,
- ein Import-Feature ohne Kontext-/Sense-/Safety-Pruefung geplant wird,
- ein mehrdeutiges Wort sichtbar dargestellt werden soll, ohne dass Sense
  entschieden oder bestaetigt ist,
- ein sensibler oder abstrakter Begriff automatisch als Weltobjekt erscheinen
  soll,
- Lernfortschritt automatisch starre Baupositionen erzwingen soll,
- ein Lernmodus ohne Nutzerbestaetigung sichtbare Weltobjekte massenhaft
  erzeugen soll,
- freie Plot-Platzierung ohne Onboarding-Erklaerung geplant wird,
- Progression den Nutzer faktisch wieder zum Hausstart zwingt,
- Import ohne Governance-/Privacy-/Safety-Regeln geplant wird,
- eine sensible Kategorie ohne Bestaetigung und neutrale Darstellung sichtbar
  werden soll,
- die naechste Greybox feste Gebaeude-Rollenlabels nutzt,
- eine Capability-Greybox ohne `allowedFunctions` und `isUserSelectable`
  geplant wird,
- Kategorie-Priorisierung ohne Nutzerziel und Satzkontext geplant wird,
- eine einzelne Insel alle Lernwelten tragen soll,
- Meer-, Tauchen- oder Boot-Themen auf die Waldlichtung gepresst werden,
  obwohl eine Kuesteninsel sinnvoller ist,
- Stadt-, Krankenhaus- oder Flughafen-Komplexitaet auf die Starterinsel
  gepresst wird,
- eine Themeninsel ohne eigene Plot-Capabilities geplant wird,
- eine Themeninsel ohne Word-to-Island-Routing geplant wird,
- Monetarisierung ohne eigenes spaeteres Dokument geplant wird,
- eine Paywall Core Learning blockiert,
- Multi-Island-Produktion ohne Scope-Gate gestartet wird,
- ein Multi-Island-System ohne Archipel-Navigation geplant wird,
- ein Themeninsel-System ohne gemeinsamen Codex-/Blueprint-/Backlog-Plan
  geplant wird,
- ein Multi-Home-Wort ohne Cross-Island-Routing geplant wird,
- ein Insel-Slot-System ohne Status/Lifecycle geplant wird,
- mehrere private Inseln ohne Besitzer-/Identitaetslogik geplant werden,
- eine Archipel-Roadmap den Nutzer mit zu vielen Optionen ueberfordert,
- Social- oder Showcase-Funktionen ohne eigenes Privacy-/Social-Konzept
  geplant werden,
- ein Plot ohne Capability Matrix freigegeben wird,
- ein Objekt sichtbar platziert wird, ohne Placement Requirements zu erfuellen,
- ein abstraktes Wort ohne passenden Repraesentationstyp visualisiert wird,
- eine Weltvisualisierung Mobile-Lesbarkeit ueberlaedt,
- eine finale Freigabe nur textlich erfolgen soll, obwohl der Zustand visuell
  pruefbar sein muss,
- eine Asset- oder Layout-Entscheidung ohne passende Preview-, Greybox- oder
  Overlay-Pruefung getroffen werden soll,
- eine technische Debugansicht als Nutzeransicht verwendet werden soll,
- eine komplexe Systementscheidung ohne Flow-/Diagrammpruefung getroffen
  werden soll, obwohl die Zusammenhaenge sonst unklar bleiben,
- aus einer Dokumentationsvisualisierung eine Spielasset-Erzeugung abgeleitet
  werden soll,
- eine neue entscheidungsrelevante Preview committed werden soll, obwohl
  wichtige Texte aus Panels herauslaufen, abgeschnitten wirken oder nicht
  eindeutig innerhalb ihrer Karten/Rahmen stehen,
- eine dokumentierte unkritische Preview-Auffaelligkeit fuer spaetere Previews
  ignoriert werden soll, statt sie als Text-Containment-Regel zu
  beruecksichtigen,
- Depth-/Container-Logik ohne visuelle Nutzerflow-Pruefung weiter geplant wird,
- eine Container-Ansicht als reine Objektliste ohne Challenge geplant wird,
- eine Nutzeransicht zu viele technische Labels zeigt,
- eine Mini-Challenge kein klares Feedback und keinen Reward Moment hat,
- aus M9 eine Spielasset- oder Codefreigabe abgeleitet wird,
- aus nur einem M9-Beispiel-Flow eine Produktentscheidung fuer alle Themen
  abgeleitet wird,
- ein Container-System ohne mehrere Beispiel-Flows bestaetigt wird,
- finale Nutzer-UX ohne emotionale/spielerische Pruefung abgeleitet wird,
- aus M9 oder M9-B Code- oder Assetfreigabe abgeleitet wird,
- eine allgemeine Container-Systementscheidung getroffen wird, bevor mehrere
  Beispiel-Flows geprueft wurden,
- finale Depth-/Container-UX abgeleitet wird, bevor emotionale/spielerische
  Wirkung visualisiert wurde,
- eine Challenge implementiert werden soll, bevor Challenge-Arten verglichen
  wurden,
- Companion-UX geplant oder implementiert wird, bevor der Tali/Vori-
  Reaktionsflow visualisiert wurde,
- offene M9-/M9-B-Follow-ups stillschweigend uebersprungen werden,
- die emotionale M10-Produktpreview als finale UI gelesen wird,
- aus M10 Sound-/FX-Implementierung abgeleitet wird,
- aus M10 Companion-Implementierung abgeleitet wird,
- eine Challenge-Art final entschieden werden soll, bevor M10-B erfolgt,
- eine allgemeine Container-UX bestaetigt werden soll, bevor M10-B, M10-C
  und M11 geprueft sind,
- aus M10 allein eine finale Produktentscheidung abgeleitet wird,
- aus M10 eine Challenge-Art abgeleitet wird,
- aus M10 Tali/Vori-Companion-UX abgeleitet wird,
- aus M10 oder M10-D App-, Code- oder Assetfreigabe abgeleitet wird,
- aus M10-B eine Challenge-Implementierung abgeleitet wird,
- eine Challenge-Art final gewaehlt wird, bevor M10-B visuell geprueft wurde,
- Drag-and-drop ohne Mobile-Bedienbarkeitspruefung entschieden wird,
- Audio-Challenges ohne Accessibility- und Silent-Mode-Alternative entschieden
  werden,
- eine allgemeine Challenge-Systementscheidung ohne weitere Beispiel-Flows
  getroffen wird,
- aus M10-B App-, Code- oder Assetfreigabe abgeleitet wird,
- aus M10-B2 eine Challenge-Implementierung abgeleitet wird,
- eine finale Challenge-Systementscheidung ohne M11 getroffen wird,
- Audio-Challenges ohne Silent- und Accessibility-Fallback geplant werden,
- Drag-and-drop ohne Mobile-Bedienbarkeitspruefung geplant oder entschieden
  wird,
- aus M10-B oder M10-B2 App-, Code- oder Assetfreigabe abgeleitet wird,
- aus M10-C Companion-Implementierung abgeleitet wird,
- aus M10-C Voice-, Audio- oder Animationsfreigabe abgeleitet wird,
- Companion-UX final entschieden werden soll, bevor M10-C visuell geprueft
  wurde,
- Tali/Vori eine Challenge automatisch loesen soll,
- Tali/Vori Druck, Schuldgefuehl oder harte Streak-Mechanik erzeugen soll,
- aus M10-C App-, Code- oder Assetfreigabe abgeleitet wird,
- aus M10-C2 Companion-Implementierung abgeleitet wird,
- finale Companion-UX ohne spaetere Detailpruefung entschieden wird,
- aus M10-C2 Voice-, Audio-, Animation- oder Rive-Freigabe abgeleitet wird,
- Companion-Personality-Varianten ohne eigenes Konzept geplant werden,
- Comeback-Erinnerungen ohne Fairness-/Druck-Pruefung geplant werden,
- aus M10-C oder M10-C2 App-, Code- oder Assetfreigabe abgeleitet wird,
- aus nur einem Flow eine allgemeine Container-Systemarchitektur abgeleitet
  werden soll,
- eine finale Container-Systemarchitektur ohne M11-Review bestaetigt werden
  soll,
- ein Flow implementiert werden soll, bevor UX- und Mobile-Pruefung erfolgt
  sind,
- Mini-Sequenzen implementiert werden sollen, bevor Aktionen und Reihenfolgen
  separat geprueft sind,
- aus M11 App-, Code- oder Assetfreigabe abgeleitet wird,
- aus M11-B eine finale Container-Systemarchitektur abgeleitet werden soll,
- Flow-Implementierung ohne spaetere UX-/Mobile-Pruefung geplant wird,
- Hafen-/Kajuten-UX ohne separate Mobile-Komplexitaetspruefung bestaetigt
  werden soll,
- Garten-Wachstumsmechanik ohne Fairness-/Timer-Pruefung geplant oder
  implementiert werden soll,
- Schulobjekt-Ansicht ohne Clutter-/Kleinteile-Pruefung als Produktentscheidung
  behandelt werden soll,
- aus M11 oder M11-B App-, Code- oder Assetfreigabe abgeleitet wird,
- ein Katalogbegriff ohne Routing-Entscheidung umgesetzt werden soll,
- eine grosse Kategorie auf die Starterinsel gepresst werden soll,
- aus dem Taxonomy-Katalog Assetproduktion abgeleitet wird,
- eine ThemeIsland-Umsetzung ohne Priorisierung und Scope-Gate gestartet wird,
- Deko-Massenproduktion ohne Clutter-Regeln geplant wird,
- oeffentliche, medizinische, religioese oder politische Gebaeude ohne
  sensible Darstellungspruefung geplant werden,
- Verkehrs-/Strassenlogik ohne eigenes Connector-/Path-Konzept umgesetzt
  werden soll,
- Fahrzeug-/Parklogik ohne Groessen- und Interaktionsregeln geplant wird,
- eine ThemeIsland-Roadmap ohne Taxonomy-Review erstellt werden soll,
- eine Word-to-Island-Routing-Matrix ohne Taxonomy-Review erstellt werden soll,
- Plot-Capabilities ohne Kategoriepruefung abgeleitet werden sollen,
- eine sensible Kategorie ohne eigene Darstellungs- und Safety-Regeln
  behandelt werden soll,
- Deko- oder Kleinteile-Produktion ohne Mobile-/Clutter-Regeln geplant wird,
- technische, Verkehrs- oder Fahrzeuglogik ohne eigenes Systemkonzept geplant
  wird,
- Taxonomy-Begriffe als automatische Asset-Auftraege gelesen werden,
- aus M12 eine ThemeIsland-Umsetzung abgeleitet wird,
- aus M12 eine finale ThemeIsland-Roadmap abgeleitet wird,
- aus M12 Assetproduktion abgeleitet wird,
- eine Kuesten- oder Hafeninsel ohne Mobile-Komplexitaetspruefung geplant
  wird,
- eine Gesundheits-, Politik-, Religion-, Gerichts-, Polizei- oder
  Krankenhausinsel ohne Sensitive-Content-Regeln geplant wird,
- eine Reise- oder Verkehrsinsel ohne Connector-/Path-/Vehicle-Konzept geplant
  wird,
- eine Technik- oder Digitalinsel ohne eigene Digital-Object-/UI-Abgrenzung
  geplant wird,
- eine fruehe Insel zu viele neue Systeme gleichzeitig erzwingt,
- aus M12-A2 eine finale ThemeIsland-Roadmap abgeleitet wird,
- aus M12-A2 eine ThemeIsland-Umsetzung abgeleitet wird,
- aus M12-A2 Assetproduktion abgeleitet wird,
- eine Early-Insel ohne M12-B Word-to-Island Routing geplant wird,
- eine Early-Insel ohne M12-C Plot-Capability-Ableitung geplant wird,
- Schule/Federmappe ohne Mobile-/Clutter-Regeln geplant wird,
- Gartenwachstum ohne Fairness-/Timer-Regeln geplant wird,
- Zuhause/Alltag als Pflicht-Hausstart erzwungen wird,
- sensible Inseln ohne M12-D Sensitive-Content-Regeln geplant werden,
- aus M12-B Word-to-Island-Routing-Code abgeleitet wird,
- aus M12-B automatische Wortplatzierung abgeleitet wird,
- ein sichtbares Objekt ohne passende Depth-Ebene geplant wird,
- ein Multi-home-Wort ohne Nutzer- oder Kontextentscheidung final platziert
  wird,
- ein sensibler Begriff ohne M12-D-Regeln sichtbar gemacht wird,
- ein Gebaeudeteil ohne passenden Gebaeudezustand oder Blueprint platziert
  wird,
- ein Verb als statisches Objekt erzwungen wird,
- ein Digitalbegriff ohne Digital-Object-/UI-Abgrenzung geplant wird,
- aus Routing-Karten Assetproduktion abgeleitet wird,
- aus M12-B2 eine finale Routing-Implementierung abgeleitet wird,
- aus M12-B2 automatische Wortplatzierung abgeleitet wird,
- aus M12-B2 eine Datenstruktur-Freigabe abgeleitet wird,
- Plot-Capabilities ohne M12-C abgeleitet werden,
- sensible Begriffe ohne M12-D behandelt oder sichtbar gemacht werden,
- Kleinteile- oder Container-Umsetzung ohne M12-E Mobile-/Clutter-Regeln
  geplant wird,
- Multi-home-Entscheidungen ohne Nutzerziel, Satzkontext oder Sense-Auswahl
  finalisiert werden,
- aus M12-B oder M12-B2 App-, Code- oder Assetfreigabe abgeleitet wird,
- aus M12-C Plot-Capability-Implementierung abgeleitet wird,
- aus M12-C eine finale Plot-Datenstruktur abgeleitet wird,
- aus M12-C Runtime-Konfiguration abgeleitet wird,
- eine Early-Insel nur wegen M12-C umgesetzt werden soll,
- Schule/Federmappe ohne M12-E Mobile-/Clutter-Regeln umgesetzt wird,
- Gartenwachstum ohne Fairness-/Timer-Regeln umgesetzt wird,
- `water`-, `farm`-, `travel`-, `vehicle`-, `digital`- oder
  `sensitive`-Plots ohne eigene Folgepruefungen umgesetzt werden,
- aus Plot-Capability-Karten Assetproduktion abgeleitet wird,
- aus Plot-Capabilities automatische Wortplatzierung abgeleitet wird,
- aus M12-C2 eine finale Plot-Datenstruktur abgeleitet wird,
- aus M12-C2 Runtime-Konfiguration abgeleitet wird,
- aus M12-C2 Plot-Implementierung abgeleitet wird,
- aus M12-C2 ThemeIsland-Umsetzung abgeleitet wird,
- eine sensitive Plot-Funktion ohne M12-D geplant wird,
- Kleinteile-, Container- oder Schulobjekt-Umsetzung ohne M12-E geplant wird,
- Gartenwachstums- oder Farm-Mechanik ohne Fairness-/Timer-Regeln geplant
  wird,
- Water-, Travel-, Vehicle- oder Digital-Plots ohne eigene Folgepruefung
  geplant werden,
- aus M12-C oder M12-C2 App-, Code- oder Assetfreigabe abgeleitet wird,
- aus M12-D eine sensible ThemeIsland-Umsetzung abgeleitet wird,
- sensible Begriffe automatisch visualisiert werden,
- Gebaeude, Symbole oder Assets fuer sensible Begriffe aus M12-D abgeleitet
  werden,
- medizinische, juristische oder politische Beratung im Spielsystem geplant
  wird,
- Retention-Mechaniken mit Angst, Krankheit, Tod, Schuld, Politik oder
  Religion geplant werden,
- Companion-Reaktionen sensible Inhalte dramatisieren oder Druck erzeugen,
- pauschale Symbolik fuer Religion, Politik, Identitaet oder soziale Gruppen
  geplant wird,
- aus M12-D App-, Code- oder Assetfreigabe abgeleitet wird,
- finale Sensitive-Content-Implementierung ohne spaetere Safety-/UX-Pruefung
  geplant wird,
- aus M12-D2 eine finale Sensitive-Content-Implementierung abgeleitet wird,
- aus M12-D2 eine Moderations-Implementierung abgeleitet wird,
- aus M12-D2 automatische Visualisierung sensibler Begriffe abgeleitet wird,
- aus M12-D2 eine sensible ThemeIsland-Umsetzung abgeleitet wird,
- Gebaeude, Symbole oder Assets fuer sensible Begriffe aus M12-D2 abgeleitet
  werden,
- aus M12-D oder M12-D2 App-, Code- oder Assetfreigabe abgeleitet wird,
- aus M12-E eine Kleinteile- oder Container-Implementierung abgeleitet wird,
- aus M12-E eine finale Mobile-UI abgeleitet wird,
- M12-E-Planungswerte als finale Runtime-Grenzwerte uebernommen werden,
- TinyObjects dauerhaft in IslandView platziert werden,
- ueberfuellte Container-Ansichten als Nutzeransicht freigegeben werden,
- Labels dauerhaft ueberall angezeigt werden,
- Deko Lernobjekte verdeckt,
- sensitiveSmallObjects ohne M12-D-Regeln platziert werden,
- aus M12-E App-, Code- oder Assetfreigabe abgeleitet wird,
- automatische Wortplatzierung aus Clutter-Regeln abgeleitet wird,
- aus M12-E2 eine finale Mobile-UI abgeleitet wird,
- aus M12-E2 eine finale Datenstruktur abgeleitet wird,
- aus M12-E2 Runtime-Konfiguration abgeleitet wird,
- aus M12-E2 Container-Implementierung abgeleitet wird,
- aus M12-E2 automatische Wortplatzierung abgeleitet wird,
- Device- oder Accessibility-Entscheidungen ohne spaetere echte Mobile-
  Pruefung getroffen werden,
- aus M12-E oder M12-E2 App-, Code- oder Assetfreigabe abgeleitet wird,
- aus M12-F eine finale ThemeIsland-Roadmap abgeleitet wird,
- aus M12-F eine Implementierungsfreigabe abgeleitet wird,
- aus M12-F eine finale Datenstruktur abgeleitet wird,
- aus M12-F Runtime-Konfiguration abgeleitet wird,
- aus M12-F automatische Wortplatzierung abgeleitet wird,
- aus M12-F eine Plot- oder Container-Implementierung abgeleitet wird,
- aus M12-F eine Safety- oder Moderations-Implementierung abgeleitet wird,
- aus M12-F App-, Code- oder Assetfreigabe abgeleitet wird,
- `frame_started` oder Bauzustaende aus M12-F weitergebaut werden,
- aus M13 eine finale ThemeIsland-Roadmap abgeleitet wird,
- aus M13 eine Implementierungsfreigabe abgeleitet wird,
- aus M13 eine finale Datenstruktur abgeleitet wird,
- aus M13 Runtime-Konfiguration abgeleitet wird,
- aus M13 automatische Wortplatzierung abgeleitet wird,
- aus M13 eine ThemeIsland-Umsetzung abgeleitet wird,
- aus M13 Assets erzeugt werden,
- eine Early-Insel ohne Onboarding-Choice-Review geplant wird,
- eine Early-Insel ohne Device-/Accessibility-/Tap-Target-Pruefung geplant
  wird,
- Garten- oder Farm-Wachstumslogik ohne Fairness-/Timer-Regeln geplant wird,
- eine Kuesten- oder Hafeninsel ohne Water-/Dock-/Mobile-
  Komplexitaetspruefung geplant wird,
- eine Stadt-, Verkehrs- oder Technikinsel ohne eigenes Systemkonzept geplant
  wird,
- eine Sensitive- oder Special-Insel ohne vertiefte Safety-/UX-/Policy-Regeln
  geplant wird,
- aus M13 App-, Code- oder Assetfreigabe abgeleitet wird,
- `frame_started` oder Bauzustaende aus M13 weitergebaut werden,
- aus M13-A2 eine finale ThemeIsland-Roadmap abgeleitet wird,
- aus M13-A2 eine finale Startinsel abgeleitet wird,
- aus M13-A2 eine Implementierungsfreigabe abgeleitet wird,
- aus M13-A2 eine finale Datenstruktur abgeleitet wird,
- aus M13-A2 Runtime-Konfiguration abgeleitet wird,
- aus M13-A2 automatische Wortplatzierung abgeleitet wird,
- aus M13-A2 eine ThemeIsland-Umsetzung abgeleitet wird,
- aus M13-A2 Assets erzeugt werden,
- eine Foundation-Insel ohne M13-B Onboarding Choice Review geplant wird,
- eine Foundation-Insel ohne Device-/Accessibility-/Tap-Target-Pruefung
  geplant wird,
- Garten- oder Farm-Wachstumslogik ohne Fairness-/Timer-Regeln geplant wird,
- eine Kuesten- oder Hafeninsel ohne Water-/Dock-/Mobile-
  Komplexitaetspruefung geplant wird,
- eine Stadt-, Verkehrs- oder Technikinsel ohne eigenes Systemkonzept geplant
  wird,
- eine Sensitive- oder Special-Insel ohne vertiefte Safety-/UX-/Policy-Regeln
  geplant wird,
- aus M13/M13-A2 App-, Code- oder Assetfreigabe abgeleitet wird,
- `frame_started` oder Bauzustaende aus M13/M13-A2 weitergebaut werden,
- aus M13-B eine finale Startinsel abgeleitet wird,
- aus M13-B ein Pflicht-Hausstart abgeleitet wird,
- aus M13-B eine finale Onboarding-UI abgeleitet wird,
- aus M13-B eine Onboarding-Implementierung abgeleitet wird,
- aus M13-B automatische Wortplatzierung abgeleitet wird,
- aus M13-B eine ThemeIsland-Umsetzung abgeleitet wird,
- aus M13-B Assets erzeugt werden,
- eine irreversible Erstwahl geplant wird,
- Premium- oder Paywall-Logik im Start-Onboarding geplant wird,
- eine Foundation-Insel ohne spaetere Device-/Accessibility-/Tap-Target-
  Pruefung geplant wird,
- ein Garten- oder Growth-Start ohne Fairness-/Timer-Regeln geplant wird,
- aus M13-B App-, Code- oder Assetfreigabe abgeleitet wird,
- `frame_started` oder Bauzustaende aus M13-B weitergebaut werden,
- aus M13-B2 eine finale Onboarding-UI abgeleitet wird,
- aus M13-B2 eine finale Startinsel abgeleitet wird,
- aus M13-B2 eine Onboarding-Implementierung abgeleitet wird,
- aus M13-B2 eine ThemeIsland-Umsetzung abgeleitet wird,
- aus M13-B2 eine finale Datenstruktur abgeleitet wird,
- aus M13-B2 Runtime-Konfiguration abgeleitet wird,
- aus M13-B2 automatische Wortplatzierung abgeleitet wird,
- aus M13-B2 Assets erzeugt werden,
- eine irreversible Erstwahl geplant wird,
- ein Pflicht-Hausstart geplant wird,
- Premium- oder Paywall-Druck im Start-Onboarding geplant wird,
- eine Garten- oder Growth-Mechanik ohne Fairness-/Timer-Regeln geplant wird,
- eine Foundation-Insel ohne echte Device-/Accessibility-/Tap-Target-
  Pruefung geplant wird,
- aus M13-B/M13-B2 App-, Code- oder Assetfreigabe abgeleitet wird,
- `frame_started` oder Bauzustaende aus M13-B/M13-B2 weitergebaut werden,
- aus M13-C eine ThemeIsland-Umsetzung abgeleitet wird,
- aus M13-C eine finale ThemeIsland-Roadmap abgeleitet wird,
- aus M13-C eine finale Startinsel abgeleitet wird,
- aus M13-C eine finale Onboarding-UI abgeleitet wird,
- aus M13-C eine finale Datenstruktur abgeleitet wird,
- aus M13-C Runtime-Konfiguration abgeleitet wird,
- aus M13-C automatische Wortplatzierung abgeleitet wird,
- aus M13-C Assetproduktion abgeleitet wird,
- aus M13-C App-, Code- oder Assetfreigabe abgeleitet wird,
- `frame_started` oder Bauzustaende aus M13-C weitergebaut werden,
- aus M13-D eine finale Word-to-Island-Implementierung abgeleitet wird,
- aus M13-D eine finale Routing-Datenstruktur abgeleitet wird,
- aus M13-D Runtime-Konfiguration abgeleitet wird,
- aus M13-D automatische Wortplatzierung abgeleitet wird,
- eine automatische ThemeIsland-Auswahl ohne Nutzerbestaetigung geplant wird,
- eine sichtbare Platzierung ohne passende Depth-Ebene geplant wird,
- Kleinteile dauerhaft in IslandView platziert werden,
- Gebaeudeteile ohne passenden Blueprint oder Bauzustand platziert werden,
- Verben als statische Objekte erzwungen werden,
- sensible Begriffe automatisch visualisiert werden,
- aus M13-D App-, Code- oder Assetfreigabe abgeleitet wird,
- `frame_started` oder Bauzustaende aus M13-D weitergebaut werden,
- aus M13-E eine UI-Implementierung abgeleitet wird,
- aus M13-E finale Device-Regeln als Runtime-Konfiguration abgeleitet werden,
- aus M13-E finale Accessibility-Regeln als Runtime-Konfiguration abgeleitet
  werden,
- aus M13-E Preview-PNG-Erzeugung abgeleitet wird,
- aus M13-E Tests abgeleitet werden,
- aus M13-E App-, Code- oder Assetfreigabe abgeleitet wird,
- `frame_started` oder Bauzustaende aus M13-E weitergebaut werden,
- aus M13-E eine finale Onboarding-UI abgeleitet wird,
- aus M13-E eine finale ThemeIsland-UI abgeleitet wird,
- aus M13-E eine finale Word-to-Island-UI abgeleitet wird,
- aus M13-E eine finale Container-/Depth-UI abgeleitet wird,
- aus M13-F eine Container-Implementierung abgeleitet wird,
- aus M13-F eine finale ContainerOpenView-UI abgeleitet wird,
- aus M13-F eine finale DetailInteractionView-UI abgeleitet wird,
- aus M13-F eine finale Pagination-Logik abgeleitet wird,
- aus M13-F Runtime-Konfiguration abgeleitet wird,
- aus M13-F Tests abgeleitet werden,
- aus M13-F PNG-Erzeugung abgeleitet wird,
- aus M13-F App-, Code- oder Assetfreigabe abgeleitet wird,
- `frame_started` oder Bauzustaende aus M13-F weitergebaut werden,
- Kleinteile dauerhaft in IslandView platziert werden,
- TinyObject-Tap-Ziele ohne Container, Zoom oder DetailInteraction geplant
  werden,
- Growth-/Timer-Mechanik ohne Fairness-Regeln geplant wird,
- sensitiveSmallObjects ohne M12-D-Regeln geplant werden,
- aus M13-G eine Safety-Implementierung abgeleitet wird,
- aus M13-G eine Moderations-Implementierung abgeleitet wird,
- aus M13-G eine finale Sensitive-Datenstruktur abgeleitet wird,
- aus M13-G Runtime-Konfiguration abgeleitet wird,
- aus M13-G automatische Klassifikation abgeleitet wird,
- sensible Begriffe automatisch visualisiert werden,
- aus M13-G eine sensible ThemeIsland-Umsetzung abgeleitet wird,
- aus M13-G sensible Gebaeude, Symbole oder Assets abgeleitet werden,
- medizinische, juristische oder politische Beratung geplant wird,
- Companion-Dramatisierung geplant wird,
- Retention-/Streak-/Paywall-Mechanik mit sensiblen Begriffen geplant wird,
- Social-/Showcase-Sichtbarkeit sensibler Inhalte geplant wird,
- aus M13-G PNG-Erzeugung abgeleitet wird,
- aus M13-G Tests abgeleitet werden,
- aus M13-G App-, Code- oder Assetfreigabe abgeleitet wird,
- `frame_started` oder Bauzustaende aus M13-G weitergebaut werden,
- aus M13-H eine Growth-Implementierung abgeleitet wird,
- aus M13-H eine Timer-Implementierung abgeleitet wird,
- aus M13-H eine Retention-Implementierung abgeleitet wird,
- aus M13-H eine Monetarisierungsregel abgeleitet wird,
- aus M13-H eine finale Datenstruktur abgeleitet wird,
- aus M13-H Runtime-Konfiguration abgeleitet wird,
- Pflanzenverfall oder Verlustmechanik geplant wird,
- harte Streak-Strafe geplant wird,
- monetarisierte Streak-Rettung geplant wird,
- Pay-to-Win-Beschleunigung geplant wird,
- Push-Drucklogik ohne eigenes Konzept geplant wird,
- Schuld-, Angst- oder FOMO-Mechanik geplant wird,
- sensible Begriffe als Retention-Ausloeser geplant werden,
- Social-Ranking-Drucklogik geplant wird,
- aus M13-H PNG-Erzeugung abgeleitet wird,
- aus M13-H Tests abgeleitet werden,
- aus M13-H App-, Code- oder Assetfreigabe abgeleitet wird,
- `frame_started` oder Bauzustaende aus M13-H weitergebaut werden,
- aus M13-I Assetproduktion abgeleitet wird,
- aus M13-I eine finale Assetliste abgeleitet wird,
- aus M13-I App- oder Assetfreigabe abgeleitet wird,
- aus M13-I ThemeIsland-Base-Produktion abgeleitet wird,
- aus M13-I `frame_started` abgeleitet wird,
- aus M13-I Bauzustaende abgeleitet werden,
- TinyObject-Massenproduktion geplant wird,
- Sensitive- oder Special-Assets geplant werden,
- Companion-Animation-, Voice- oder Audio-Assets geplant werden,
- Growth- oder Timer-Druckassets geplant werden,
- Social- oder Showcase-Assets geplant werden,
- aus M13-I PNG-Erzeugung abgeleitet wird,
- aus M13-I Tests abgeleitet werden,
- aus M13-I Code abgeleitet wird,
- aus M13-I Runtime-Konfiguration abgeleitet wird,
- aus Taxonomy, Routing, Capability Sheets, Onboarding oder Roadmap
  automatische Assetproduktion abgeleitet wird,
- aus M13-J Codefreigabe abgeleitet wird,
- aus M13-J Assetfreigabe abgeleitet wird,
- aus M13-J App-Integration abgeleitet wird,
- aus M13-J eine finale ThemeIsland-Roadmap abgeleitet wird,
- aus M13-J eine finale Startinsel abgeleitet wird,
- aus M13-J eine finale Onboarding-UI abgeleitet wird,
- aus M13-J eine finale Word-to-Island-Implementierung abgeleitet wird,
- aus M13-J eine finale Container-/Depth-UI abgeleitet wird,
- aus M13-J eine finale Sensitive-Policy-Implementierung abgeleitet wird,
- aus M13-J eine finale Growth-/Timer-Implementierung abgeleitet wird,
- aus M13-J eine finale Assetliste abgeleitet wird,
- aus M13-J Runtime-Konfiguration abgeleitet wird,
- aus M13-J PNG-Erzeugung abgeleitet wird,
- aus M13-J Tests abgeleitet werden,
- `frame_started` oder Bauzustaende aus M13-J weitergebaut werden,
- aus M13-K eine finale Onboarding-UI abgeleitet wird,
- aus M13-K App-Integration abgeleitet wird,
- aus M13-K Codefreigabe abgeleitet wird,
- aus M13-K Assetfreigabe abgeleitet wird,
- aus M13-K eine finale Startinsel abgeleitet wird,
- aus M13-K ThemeIsland-Umsetzung abgeleitet wird,
- aus M13-K eine finale Datenstruktur abgeleitet wird,
- aus M13-K Runtime-Konfiguration abgeleitet wird,
- aus M13-K PNG-Erzeugung abgeleitet wird,
- aus M13-K Tests abgeleitet werden,
- `frame_started` oder Bauzustaende aus M13-K weitergebaut werden,
- aus M13-L eine finale Word-to-Island-UI abgeleitet wird,
- aus M13-L eine Word-to-Island-Implementierung abgeleitet wird,
- aus M13-L eine Routing-Datenstruktur abgeleitet wird,
- aus M13-L Runtime-Konfiguration abgeleitet wird,
- aus M13-L automatische Wortplatzierung abgeleitet wird,
- aus M13-L App-Integration abgeleitet wird,
- aus M13-L Codefreigabe abgeleitet wird,
- aus M13-L Assetfreigabe abgeleitet wird,
- aus M13-L PNG-Erzeugung abgeleitet wird,
- aus M13-L Tests abgeleitet werden,
- `frame_started` oder Bauzustaende aus M13-L weitergebaut werden,
- aus M13-M eine finale ContainerOpenView-UI abgeleitet wird,
- aus M13-M eine finale DetailInteractionView-UI abgeleitet wird,
- aus M13-M Container-Implementierung abgeleitet wird,
- aus M13-M eine finale Datenstruktur abgeleitet wird,
- aus M13-M Runtime-Konfiguration abgeleitet wird,
- aus M13-M App-Integration abgeleitet wird,
- aus M13-M Codefreigabe abgeleitet wird,
- aus M13-M Assetfreigabe abgeleitet wird,
- aus M13-M PNG-Erzeugung abgeleitet wird,
- aus M13-M Tests abgeleitet werden,
- `frame_started` oder Bauzustaende aus M13-M weitergebaut werden,
- aus M13-N eine finale Foundation-Choice-UI abgeleitet wird,
- aus M13-N eine finale Onboarding-UI abgeleitet wird,
- aus M13-N eine finale Startinsel abgeleitet wird,
- aus M13-N App-Integration abgeleitet wird,
- aus M13-N Codefreigabe abgeleitet wird,
- aus M13-N Assetfreigabe abgeleitet wird,
- aus M13-N eine finale Datenstruktur abgeleitet wird,
- aus M13-N Runtime-Konfiguration abgeleitet wird,
- aus M13-N PNG-Erzeugung abgeleitet wird,
- aus M13-N Tests abgeleitet werden,
- `frame_started` oder Bauzustaende aus M13-N weitergebaut werden,
- aus M13-O eine finale ThemeIsland-Roadmap abgeleitet wird,
- aus M13-O ThemeIsland-Umsetzung abgeleitet wird,
- aus M13-O eine finale Startinsel abgeleitet wird,
- aus M13-O eine finale Onboarding-UI abgeleitet wird,
- aus M13-O eine finale Foundation-Choice-UI abgeleitet wird,
- aus M13-O eine finale Datenstruktur abgeleitet wird,
- aus M13-O Runtime-Konfiguration abgeleitet wird,
- aus M13-O App-Integration abgeleitet wird,
- aus M13-O Codefreigabe abgeleitet wird,
- aus M13-O Assetfreigabe abgeleitet wird,
- aus M13-O PNG-Erzeugung abgeleitet wird,
- aus M13-O Tests abgeleitet werden,
- `frame_started` oder Bauzustaende aus M13-O weitergebaut werden,
- aus M13-P Codefreigabe abgeleitet wird,
- aus M13-P Implementierung abgeleitet wird,
- aus M13-P Tests abgeleitet werden,
- aus M13-P App-Integration abgeleitet wird,
- aus M13-P Assetfreigabe abgeleitet wird,
- aus M13-P PNG-Erzeugung abgeleitet wird,
- aus M13-P eine finale ThemeIsland-Roadmap abgeleitet wird,
- aus M13-P eine finale Startinsel abgeleitet wird,
- aus M13-P eine finale Onboarding-UI abgeleitet wird,
- aus M13-P eine finale Foundation-Choice-UI abgeleitet wird,
- aus M13-P eine finale Word-to-Island-UI abgeleitet wird,
- aus M13-P eine finale Container-UI abgeleitet wird,
- aus M13-P eine finale Datenstruktur abgeleitet wird,
- aus M13-P Runtime-Konfiguration abgeleitet wird,
- `frame_started` oder Bauzustaende aus M13-P weitergebaut werden,
- aus M14-A eine finale Foundation-Choice-UI abgeleitet wird,
- aus M14-A eine finale Onboarding-UI abgeleitet wird,
- aus M14-A eine finale Startinsel abgeleitet wird,
- aus M14-A eine finale ThemeIsland-Roadmap abgeleitet wird,
- aus M14-A App-Integration abgeleitet wird,
- aus M14-A Codefreigabe abgeleitet wird,
- aus M14-A Implementierungsfreigabe abgeleitet wird,
- aus M14-A Assetfreigabe abgeleitet wird,
- aus M14-A eine finale Datenstruktur abgeleitet wird,
- aus M14-A Runtime-Konfiguration abgeleitet wird,
- aus M14-A automatische Wortplatzierung abgeleitet wird,
- aus M14-A PNG-Erzeugung abgeleitet wird,
- aus M14-A Tests abgeleitet werden,
- aus M14-A Spielassets abgeleitet werden,
- `frame_started` oder Bauzustaende aus M14-A weitergebaut werden,
- aus M14-A2 eine finale Foundation-Choice-UI abgeleitet wird,
- aus M14-A2 eine finale Onboarding-UI abgeleitet wird,
- aus M14-A2 eine finale Startinsel abgeleitet wird,
- aus M14-A2 App-Integration abgeleitet wird,
- aus M14-A2 Codefreigabe abgeleitet wird,
- aus M14-A2 Implementierungsfreigabe abgeleitet wird,
- aus M14-A2 Assetfreigabe abgeleitet wird,
- aus M14-A2 eine finale Datenstruktur abgeleitet wird,
- aus M14-A2 Runtime-Konfiguration abgeleitet wird,
- aus M14-A2 automatische Wortplatzierung abgeleitet wird,
- aus M14-A2 PNG-Erzeugung abgeleitet wird,
- aus M14-A2 Tests abgeleitet werden,
- aus M14-A2 Spielassets abgeleitet werden,
- `frame_started` oder Bauzustaende aus M14-A2 weitergebaut werden,
- aus M14-B eine finale Word-to-Island-UI abgeleitet wird,
- aus M14-B eine Word-to-Island-Implementierung abgeleitet wird,
- aus M14-B eine finale Routing-Datenstruktur abgeleitet wird,
- aus M14-B Runtime-Konfiguration abgeleitet wird,
- aus M14-B automatische Wortplatzierung abgeleitet wird,
- aus M14-B App-Integration abgeleitet wird,
- aus M14-B Codefreigabe abgeleitet wird,
- aus M14-B Implementierungsfreigabe abgeleitet wird,
- aus M14-B Assetfreigabe abgeleitet wird,
- aus M14-B PNG-Erzeugung abgeleitet wird,
- aus M14-B Tests abgeleitet werden,
- aus M14-B Spielassets abgeleitet werden,
- `frame_started` oder Bauzustaende aus M14-B weitergebaut werden,
- aus M14-B2 eine finale Word-to-Island-UI abgeleitet wird,
- aus M14-B2 eine Word-to-Island-Implementierung abgeleitet wird,
- aus M14-B2 eine finale Routing-Datenstruktur abgeleitet wird,
- aus M14-B2 Runtime-Konfiguration abgeleitet wird,
- aus M14-B2 automatische Wortplatzierung abgeleitet wird,
- aus M14-B2 App-Integration abgeleitet wird,
- aus M14-B2 Codefreigabe abgeleitet wird,
- aus M14-B2 Implementierungsfreigabe abgeleitet wird,
- aus M14-B2 Assetfreigabe abgeleitet wird,
- aus M14-B2 PNG-Erzeugung abgeleitet wird,
- aus M14-B2 Tests abgeleitet werden,
- aus M14-B2 Spielassets abgeleitet werden,
- `frame_started` oder Bauzustaende aus M14-B2 weitergebaut werden,
- aus M14-C eine finale ContainerOpenView-UI abgeleitet wird,
- aus M14-C eine finale DetailInteractionView-UI abgeleitet wird,
- aus M14-C eine Container-Implementierung abgeleitet wird,
- aus M14-C eine finale Datenstruktur abgeleitet wird,
- aus M14-C Runtime-Konfiguration abgeleitet wird,
- aus M14-C App-Integration abgeleitet wird,
- aus M14-C Codefreigabe abgeleitet wird,
- aus M14-C Implementierungsfreigabe abgeleitet wird,
- aus M14-C Assetfreigabe abgeleitet wird,
- aus M14-C PNG-Erzeugung abgeleitet wird,
- aus M14-C Tests abgeleitet werden,
- aus M14-C Spielassets abgeleitet werden,
- `frame_started` oder Bauzustaende aus M14-C weitergebaut werden,
- aus M14-C2 eine finale ContainerOpenView-UI abgeleitet wird,
- aus M14-C2 eine finale DetailInteractionView-UI abgeleitet wird,
- aus M14-C2 eine Container-Implementierung abgeleitet wird,
- aus M14-C2 eine finale Datenstruktur abgeleitet wird,
- aus M14-C2 Runtime-Konfiguration abgeleitet wird,
- aus M14-C2 App-Integration abgeleitet wird,
- aus M14-C2 Codefreigabe abgeleitet wird,
- aus M14-C2 Implementierungsfreigabe abgeleitet wird,
- aus M14-C2 Assetfreigabe abgeleitet wird,
- aus M14-C2 PNG-Erzeugung abgeleitet wird,
- aus M14-C2 Tests abgeleitet werden,
- aus M14-C2 Spielassets abgeleitet werden,
- `frame_started` oder Bauzustaende aus M14-C2 weitergebaut werden,
- aus M14-D eine Harness-Implementierung abgeleitet wird,
- aus M14-D Tests abgeleitet werden,
- aus M14-D Widget-Tests abgeleitet werden,
- aus M14-D Flutter-/Dart-Dateien abgeleitet werden,
- aus M14-D App-Integration abgeleitet wird,
- aus M14-D eine finale UI abgeleitet wird,
- aus M14-D eine finale Datenstruktur abgeleitet wird,
- aus M14-D Runtime-Konfiguration abgeleitet wird,
- aus M14-D Codefreigabe abgeleitet wird,
- aus M14-D Implementierungsfreigabe abgeleitet wird,
- aus M14-D Assetfreigabe abgeleitet wird,
- aus M14-D PNG-Erzeugung abgeleitet wird,
- aus M14-D Screenshots abgeleitet werden,
- aus M14-D Spielassets abgeleitet werden,
- `frame_started` oder Bauzustaende aus M14-D weitergebaut werden,
- aus M14-D2 eine Harness-Implementierung abgeleitet wird,
- aus M14-D2 Tests abgeleitet werden,
- aus M14-D2 Widget-Tests abgeleitet werden,
- aus M14-D2 Flutter-/Dart-Dateien abgeleitet werden,
- aus M14-D2 App-Integration abgeleitet wird,
- aus M14-D2 eine finale UI abgeleitet wird,
- aus M14-D2 eine finale Datenstruktur abgeleitet wird,
- aus M14-D2 Runtime-Konfiguration abgeleitet wird,
- aus M14-D2 Codefreigabe abgeleitet wird,
- aus M14-D2 Implementierungsfreigabe abgeleitet wird,
- aus M14-D2 Assetfreigabe abgeleitet wird,
- aus M14-D2 PNG-Erzeugung abgeleitet wird,
- aus M14-D2 Screenshots abgeleitet werden,
- aus M14-D2 Spielassets abgeleitet werden,
- `frame_started` oder Bauzustaende aus M14-D2 weitergebaut werden,
- aus M14-E eine Implementierung abgeleitet wird,
- aus M14-E Tests abgeleitet werden,
- aus M14-E Widget-Tests abgeleitet werden,
- aus M14-E Flutter-/Dart-Dateien abgeleitet werden,
- aus M14-E App-Integration abgeleitet wird,
- aus M14-E eine finale UI abgeleitet wird,
- aus M14-E eine finale Datenstruktur abgeleitet wird,
- aus M14-E Runtime-Konfiguration abgeleitet wird,
- aus M14-E Codefreigabe abgeleitet wird,
- aus M14-E Implementierungsfreigabe abgeleitet wird,
- aus M14-E Assetfreigabe abgeleitet wird,
- aus M14-E PNG-Erzeugung abgeleitet wird,
- aus M14-E Screenshots abgeleitet werden,
- aus M14-E Spielassets abgeleitet werden,
- aus M14-E automatische Wortplatzierung abgeleitet wird,
- `frame_started` oder Bauzustaende aus M14-E weitergebaut werden,
- aus M14-E2 eine Implementierung abgeleitet wird,
- aus M14-E2 Tests abgeleitet werden,
- aus M14-E2 Widget-Tests abgeleitet werden,
- aus M14-E2 Flutter-/Dart-Dateien abgeleitet werden,
- aus M14-E2 App-Integration abgeleitet wird,
- aus M14-E2 eine finale UI abgeleitet wird,
- aus M14-E2 eine finale Datenstruktur abgeleitet wird,
- aus M14-E2 Runtime-Konfiguration abgeleitet wird,
- aus M14-E2 Codefreigabe abgeleitet wird,
- aus M14-E2 Implementierungsfreigabe abgeleitet wird,
- aus M14-E2 Assetfreigabe abgeleitet wird,
- aus M14-E2 PNG-Erzeugung abgeleitet wird,
- aus M14-E2 Screenshots abgeleitet werden,
- aus M14-E2 Spielassets abgeleitet werden,
- aus M14-E2 automatische Wortplatzierung abgeleitet wird,
- `frame_started` oder Bauzustaende aus M14-E2 weitergebaut werden,
- aus M14-V1 App-Integration abgeleitet wird,
- aus M14-V1 Flutter-/Dart-Dateien abgeleitet werden,
- aus M14-V1 Tests abgeleitet werden,
- aus M14-V1 Widget-Tests abgeleitet werden,
- aus M14-V1 Test-Harness-Implementierung abgeleitet wird,
- aus M14-V1 Screenshots abgeleitet werden,
- aus M14-V1 Spielassets abgeleitet werden,
- aus M14-V1 Asset-Dateien unter `assets/` abgeleitet werden,
- aus M14-V1 eine finale UI abgeleitet wird,
- aus M14-V1 Runtime-Konfiguration abgeleitet wird,
- aus M14-V1 Codefreigabe abgeleitet wird,
- aus M14-V1 Implementierungsfreigabe abgeleitet wird,
- aus M14-V1 App-/Assetfreigabe abgeleitet wird,
- `frame_started` oder Bauzustaende aus M14-V1 weitergebaut werden,
- aus M14-V1-B bestehende PNGs geaendert werden,
- aus M14-V1-B neue PNGs abgeleitet werden,
- aus M14-V1-B eine Implementierung abgeleitet wird,
- aus M14-V1-B Tests abgeleitet werden,
- aus M14-V1-B Widget-Tests abgeleitet werden,
- aus M14-V1-B Flutter-/Dart-Dateien abgeleitet werden,
- aus M14-V1-B App-Integration abgeleitet wird,
- aus M14-V1-B eine finale UI abgeleitet wird,
- aus M14-V1-B Runtime-Konfiguration abgeleitet wird,
- aus M14-V1-B Codefreigabe abgeleitet wird,
- aus M14-V1-B Implementierungsfreigabe abgeleitet wird,
- aus M14-V1-B Assetfreigabe abgeleitet wird,
- aus M14-V1-B Screenshots abgeleitet werden,
- aus M14-V1-B Spielassets abgeleitet werden,
- aus M14-V1-B Asset-Dateien unter `assets/` abgeleitet werden,
- `frame_started` oder Bauzustaende aus M14-V1-B weitergebaut werden,
- aus M15-A eine Implementierung abgeleitet wird,
- aus M15-A Tests abgeleitet werden,
- aus M15-A Widget-Tests abgeleitet werden,
- aus M15-A Flutter-/Dart-Dateien abgeleitet werden,
- aus M15-A App-Integration abgeleitet wird,
- aus M15-A eine finale UI abgeleitet wird,
- aus M15-A Runtime-Konfiguration abgeleitet wird,
- aus M15-A Persistenz abgeleitet wird,
- aus M15-A Supabase Writes abgeleitet werden,
- aus M15-A SRS-/`word_progress`-Aenderungen abgeleitet werden,
- aus M15-A eine Reward Bridge abgeleitet wird,
- aus M15-A Codefreigabe abgeleitet wird,
- aus M15-A Implementierungsfreigabe abgeleitet wird,
- aus M15-A Assetfreigabe abgeleitet wird,
- aus M15-A PNG-Erzeugung abgeleitet wird,
- aus M15-A PNG-Aenderung abgeleitet wird,
- aus M15-A Screenshots abgeleitet werden,
- aus M15-A Spielassets abgeleitet werden,
- aus M15-A Asset-Dateien unter `assets/` abgeleitet werden,
- aus M15-A automatische Wortplatzierung abgeleitet wird,
- `frame_started` oder Bauzustaende aus M15-A weitergebaut werden,
- aus M15-A2 eine Implementierung abgeleitet wird,
- aus M15-A2 Flutter-/Dart-Dateien abgeleitet werden,
- aus M15-A2 Tests abgeleitet werden,
- aus M15-A2 Widget-Tests abgeleitet werden,
- aus M15-A2 App-Integration abgeleitet wird,
- aus M15-A2 eine finale UI abgeleitet wird,
- aus M15-A2 Runtime-Konfiguration abgeleitet wird,
- aus M15-A2 Persistenz abgeleitet wird,
- aus M15-A2 Supabase Writes abgeleitet werden,
- aus M15-A2 SRS-/`word_progress`-Aenderungen abgeleitet werden,
- aus M15-A2 eine Reward Bridge abgeleitet wird,
- aus M15-A2 Codefreigabe abgeleitet wird,
- aus M15-A2 Implementierungsfreigabe abgeleitet wird,
- aus M15-A2 Assetfreigabe abgeleitet wird,
- aus M15-A2 PNG-Erzeugung abgeleitet wird,
- aus M15-A2 PNG-Aenderung abgeleitet wird,
- aus M15-A2 Screenshots abgeleitet werden,
- aus M15-A2 Spielassets abgeleitet werden,
- aus M15-A2 Asset-Dateien unter `assets/` abgeleitet werden,
- aus M15-A2 automatische Wortplatzierung abgeleitet wird,
- `frame_started` oder Bauzustaende aus M15-A2 weitergebaut werden,
- aus M15-A3 eine Implementierung abgeleitet wird,
- aus M15-A3 Flutter-/Dart-Dateien abgeleitet werden,
- aus M15-A3 Tests abgeleitet werden,
- aus M15-A3 Widget-Tests abgeleitet werden,
- aus M15-A3 App-Integration abgeleitet wird,
- aus M15-A3 eine finale UI abgeleitet wird,
- aus M15-A3 Runtime-Konfiguration abgeleitet wird,
- aus M15-A3 Persistenz abgeleitet wird,
- aus M15-A3 Supabase Writes abgeleitet werden,
- aus M15-A3 SRS-/`word_progress`-Aenderungen abgeleitet werden,
- aus M15-A3 eine Reward Bridge abgeleitet wird,
- aus M15-A3 Codefreigabe abgeleitet wird,
- aus M15-A3 Implementierungsfreigabe abgeleitet wird,
- aus M15-A3 Assetfreigabe abgeleitet wird,
- aus M15-A3 Screenshots abgeleitet werden,
- aus M15-A3 Spielassets abgeleitet werden,
- aus M15-A3 Asset-Dateien unter `assets/` abgeleitet werden,
- aus M15-A3 automatische Wortplatzierung abgeleitet wird,
- `frame_started` oder Bauzustaende aus M15-A3 weitergebaut werden,
- aus M15-A4 eine Implementierung abgeleitet wird,
- aus M15-A4 Flutter-/Dart-Dateien abgeleitet werden,
- aus M15-A4 Tests abgeleitet werden,
- aus M15-A4 Widget-Tests abgeleitet werden,
- aus M15-A4 App-Integration abgeleitet wird,
- aus M15-A4 eine finale UI abgeleitet wird,
- aus M15-A4 Runtime-Konfiguration abgeleitet wird,
- aus M15-A4 Persistenz abgeleitet wird,
- aus M15-A4 Supabase Writes abgeleitet werden,
- aus M15-A4 SRS-/`word_progress`-Aenderungen abgeleitet werden,
- aus M15-A4 eine Reward Bridge abgeleitet wird,
- aus M15-A4 Codefreigabe abgeleitet wird,
- aus M15-A4 Implementierungsfreigabe abgeleitet wird,
- aus M15-A4 Assetfreigabe abgeleitet wird,
- aus M15-A4 PNG-Erzeugung abgeleitet wird,
- aus M15-A4 PNG-Aenderung abgeleitet wird,
- aus M15-A4 Screenshots abgeleitet werden,
- aus M15-A4 Spielassets abgeleitet werden,
- aus M15-A4 Asset-Dateien unter `assets/` abgeleitet werden,
- aus M15-A4 automatische Wortplatzierung abgeleitet wird,
- `frame_started` oder Bauzustaende aus M15-A4 weitergebaut werden,
- aus M15-B App-Integration abgeleitet wird,
- aus M15-B Home-/Onboarding-/World-Routing-Integration abgeleitet wird,
- aus M15-B Persistenz abgeleitet wird,
- aus M15-B Runtime-Konfiguration abgeleitet wird,
- aus M15-B Supabase Writes abgeleitet werden,
- aus M15-B lokale DB-Writes abgeleitet werden,
- aus M15-B SRS-/`word_progress`-Aenderungen abgeleitet werden,
- aus M15-B eine Reward Bridge abgeleitet wird,
- aus M15-B automatische Wortplatzierung abgeleitet wird,
- aus M15-B Assetfreigabe abgeleitet wird,
- aus M15-B Tests oder Widget-Tests abgeleitet werden,
- aus M15-B Screenshots abgeleitet werden,
- aus M15-B Build-State abgeleitet wird,
- `frame_started` oder Bauzustaende aus M15-B weitergebaut werden,
- aus M15-C Harness-Implementierung abgeleitet wird,
- aus M15-C Flutter-/Dart-Dateien abgeleitet werden,
- aus M15-C App-Integration abgeleitet wird,
- aus M15-C Home-/Onboarding-/World-Routing-Integration abgeleitet wird,
- aus M15-C Tests oder Widget-Tests abgeleitet werden,
- aus M15-C Screenshots abgeleitet werden,
- aus M15-C Persistenz abgeleitet wird,
- aus M15-C Runtime-Konfiguration abgeleitet wird,
- aus M15-C Supabase Writes oder lokale DB-Writes abgeleitet werden,
- aus M15-C SRS-/`word_progress`-Aenderungen abgeleitet werden,
- aus M15-C eine Reward Bridge abgeleitet wird,
- aus M15-C automatische Wortplatzierung abgeleitet wird,
- aus M15-C Assetfreigabe abgeleitet wird,
- aus M15-C Build-State abgeleitet wird,
- `frame_started` oder Bauzustaende aus M15-C weitergebaut werden,
- aus M15-D Harness-Implementierung abgeleitet wird,
- aus M15-D Flutter-/Dart-Dateien abgeleitet werden,
- aus M15-D App-Integration abgeleitet wird,
- aus M15-D Home-/Onboarding-/World-Routing-Integration abgeleitet wird,
- aus M15-D Tests oder Widget-Tests abgeleitet werden,
- aus M15-D Screenshots abgeleitet werden,
- aus M15-D Persistenz abgeleitet wird,
- aus M15-D Runtime-Konfiguration abgeleitet wird,
- aus M15-D Supabase Writes oder lokale DB-Writes abgeleitet werden,
- aus M15-D SRS-/`word_progress`-Aenderungen abgeleitet werden,
- aus M15-D eine Reward Bridge abgeleitet wird,
- aus M15-D automatische Wortplatzierung abgeleitet wird,
- aus M15-D Assetfreigabe abgeleitet wird,
- aus M15-D Build-State abgeleitet wird,
- `frame_started` oder Bauzustaende aus M15-D weitergebaut werden,
- aus M15-D2 Harness-Implementierung abgeleitet wird,
- aus M15-D2 Flutter-/Dart-Dateien abgeleitet werden,
- aus M15-D2 App-Integration abgeleitet wird,
- aus M15-D2 Home-/Onboarding-/World-Routing-Integration abgeleitet wird,
- aus M15-D2 Tests oder Widget-Tests abgeleitet werden,
- aus M15-D2 Screenshots abgeleitet werden,
- aus M15-D2 Persistenz abgeleitet wird,
- aus M15-D2 Runtime-Konfiguration abgeleitet wird,
- aus M15-D2 Supabase Writes oder lokale DB-Writes abgeleitet werden,
- aus M15-D2 SRS-/`word_progress`-Aenderungen abgeleitet werden,
- aus M15-D2 eine Reward Bridge abgeleitet wird,
- aus M15-D2 automatische Wortplatzierung abgeleitet wird,
- aus M15-D2 Assetfreigabe abgeleitet wird,
- aus M15-D2 Build-State abgeleitet wird,
- `frame_started` oder Bauzustaende aus M15-D2 weitergebaut werden,
- aus M16-A Flutter-/Dart-Dateien abgeleitet werden,
- aus M16-A App-Integration abgeleitet wird,
- aus M16-A Tests abgeleitet werden,
- aus M16-A Screenshots abgeleitet werden,
- aus M16-A Persistenz abgeleitet wird,
- aus M16-A Runtime-Konfiguration abgeleitet wird,
- aus M16-A Supabase Writes oder lokale DB-Writes abgeleitet werden,
- aus M16-A SRS-/`word_progress`-Aenderungen abgeleitet werden,
- aus M16-A eine Reward Bridge abgeleitet wird,
- aus M16-A automatische Wortplatzierung abgeleitet wird,
- aus M16-A Assetfreigabe abgeleitet wird,
- aus M16-A neue Spielassets oder Asset-Dateien unter `assets/` abgeleitet
  werden,
- aus M16-A ein finales Inselbild abgeleitet wird,
- `frame_started` oder Bauzustaende aus M16-A weitergebaut werden,
- eine Foundation-Insel ohne spaetere Device-/Accessibility-/Tap-Target-
  Pruefung geplant wird,
- eine Garten- oder Growth-Mechanik ohne Fairness-/Timer-Regeln geplant wird,
- eine Schule- oder Kleinteile-Umsetzung ohne Mobile-/Clutter-Regeln geplant
  wird,
- Zuhause oder Alltag als Pflicht-Hausstart geplant wird,
- eine Sensitive- oder Special-Insel ohne vertiefte Sensitive-Content-,
  Safety- und UX-Regeln geplant wird,
- eine Stadt-, Verkehrs- oder Technikinsel ohne eigenes Systemkonzept geplant
  wird,
- eine Kuesten- oder Hafeninsel ohne Water-/Dock-/Mobile-
  Komplexitaetspruefung geplant wird,
- sensible oder abstrakte Begriffe automatisch dargestellt werden,
- eine Preview committed werden soll, obwohl wichtige Texte aus Karten,
  Rahmen oder Panels herauslaufen,
- Umbauen oder Verschieben ohne definierte Folgen fuer Wortobjekte,
  Blueprints und Backlogs geplant wird,
- eine Market-/Hub-Struktur als langer isolierter Schwanz geplant wird,
- `water_edge_east` ueber eine unnatuerlich lange Diagonale ohne
  Uebergangsplot angebunden wird,
- Expansion ohne nachvollziehbare Randlogik geplant wird,
- Bauzustaende weitergebaut werden, solange der `starter_home_plot` im
  bestaetigten Layout nicht feststeht,
- die Inselgroesse fuer die geplante Landschaft nicht reicht,
- Einzelassets nur nach Augenmass erzeugt werden,
- Pfosten/Fuesse sichtbar ausserhalb des Referenzfundaments landen,
- kein Debug-Overlay-Check fuer ein aufbauendes Asset dokumentiert ist,
- Status nicht `freigegeben` ist,
- Code versucht, fehlende Assets zu kaschieren,
- Scope groesser wird als geplant,
- neue Nutzerfuehrung nicht ausreichend kontrastreich ist,
- Baufeedback nur als harter Bildwechsel ohne klaren Moment wirkt,
- Supabase beruehrt wird,
- SRS oder `word_progress` beruehrt werden,
- Reward Bridge beruehrt wird,
- Persistenz beruehrt wird.

Stoppen bedeutet:

- keine weitere Implementierung in diesem Block,
- Blocker benennen,
- naechste sichere Planungs- oder Asset-Aufgabe ableiten.

## 11. Update-Regel

Nach jedem Block muss dokumentiert werden:

- was geaendert wurde,
- welche Dateien betroffen sind,
- welcher Status sich geaendert hat,
- welche ToDos erledigt sind,
- welche ToDos offen bleiben,
- ob der naechste Schritt erlaubt oder blockiert ist.

Wenn ein Status geaendert wird, muss die Begruendung sichtbar sein.
Die Roadmap-Tabelle in Abschnitt 5 muss nach jedem relevanten Block aktiv
aktualisiert werden. Statusaenderungen duerfen nicht nur im Chat stehen,
sondern muessen im Dokument nachvollziehbar sein.

Nach jedem abgeschlossenen Planungs-, Asset- oder Codeblock wird committed.
Wenn nicht committed wird, muss der Grund dokumentiert werden. Kein neuer Block
startet mit unklarem oder dirty Arbeitsstand.

Beispiel:

```text
Phase 2E-B: generiert -> nachbessern
Grund: Bauflaeche wirkt zu kuenstlich und `foundation_started` passt nicht zur
Perspektive.
Naechster Schritt: Prompt fuer Base-Asset ueberarbeiten.
```

## 12. Professional Game Development Research Gate

Vor groesseren Entscheidungen zu Game Design, Weltarchitektur,
Asset-Produktion, Buildable Islands, Economy/Balancing, Retention,
Monetarisierung, Cloud/Backend, Social, Animation, Roadmap oder Code-Slices
muss geprueft werden:

- Wie wuerden professionelle Game-Entwickler oder erfahrene Studios dieses
  Problem typischerweise angehen?
- Gibt es bewaehrte Begriffe oder Methoden wie Prototype, Greybox/Blockout,
  Vertical Slice, Pre-Production, Production Gate, LiveOps, Economy Balancing,
  Level Design, Asset Pipeline, LOD oder Content Pipeline?
- Gibt es aktuelle Quellen, Artikel, Dokumentationen oder Best Practices, die
  fuer die Entscheidung relevant sind?
- Was davon passt zu Talvori?
- Was passt nicht zu Talvori?
- Welche konkrete Ableitung ergibt sich daraus fuer Talvori?

Regel:

Codex soll bei solchen Entscheidungen nicht nur raten. Wenn die Frage
professionelles Game Design, Asset-Produktion, Economy, Retention,
Monetarisierung, Social, Cloud oder technische Architektur betrifft, soll Codex
nach Moeglichkeit aktuelle Quellen recherchieren oder klar dokumentieren, wenn
keine Recherche durchgefuehrt wurde.

Jede research-informed Entscheidung haelt kurz fest:

- recherchierte Orientierung / Quelle / Methode,
- Ableitung fuer Talvori,
- Entscheidung,
- Risiken,
- was dadurch erlaubt ist,
- was dadurch blockiert ist.

Beispiele:

- Vor finaler Asset-Produktion pruefen: Wie arbeiten Profis mit
  Greybox/Blockout, Asset Pipeline und Vertical Slice?
- Vor Balancing pruefen: Wie arbeiten Aufbau-/Mobile-Games mit Quellen,
  Senken, Progression und Anti-Farming?
- Vor Monetarisierung pruefen: Wie decken Lern-/Mobile-Produkte Kosten, ohne
  Pay-to-Win zu werden?
- Vor Cloud-Entscheidung pruefen: Was muss lokal bleiben, was muss
  server-authoritative sein?
- Vor Social pruefen: Wie werden sichere Kommunikation, Moderation und
  Missbrauchsschutz geplant?

Stop-Regel:

Wenn eine groessere Entscheidung getroffen werden soll, aber kein
Professional-Research-Gate durchgefuehrt wurde, wird der Schritt gestoppt oder
auf einen Recherche-/Planungsblock zurueckgefuehrt.

## 13. Prueffragen Vor Jedem Neuen Chat/Codex-Prompt

Vor jedem neuen Chat oder Codex-Prompt pruefen:

- Was ist das Ziel?
- Welches Dokument ist fuehrend?
- Sind Abhaengigkeiten erfuellt?
- Ist ein Asset freigegeben?
- Ist der Scope klein?
- Gibt es einen Testplan?
- Wird etwas an Datenlogik, SRS, Reward oder Cloud geaendert?
- Wurde geprueft, wie professionelle Game-Entwickler dieses Problem loesen
  wuerden?
- Ist eine aktuelle Recherche noetig?
- Wurde die Ableitung fuer Talvori dokumentiert?
- Ist ein Commit danach geplant?

Wenn die Antwort auf eine dieser Fragen unklar ist, muss der Prompt zuerst
praezisiert oder als Planungsblock formuliert werden.

## 14. Akzeptanzkriterien

Dieses Dokument ist gut, wenn:

- klar ist, was als naechstes erlaubt ist,
- klar ist, was blockiert ist,
- Phase 2E nicht wieder auf unvorbereiteten Assets startet,
- ToDos und Statuswerte vorhanden sind,
- Code-Gates und Asset-Gates klar sind,
- das Professional-Research-Gate vor groesseren Entscheidungen sichtbar ist,
- es als Checkliste vor neuen Prompts nutzbar ist.
