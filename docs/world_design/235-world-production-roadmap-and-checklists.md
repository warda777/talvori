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
- Der naechste Blocker betrifft die Pruefung dieser flexiblen
  Plot-/Learning-Semantics-Planung und ihrer M6-B-/M6-C-/M6-D-/M6-E-/M6-F-
  Entscheidungslogik sowie der M7-C-, M8-, M9-, M9-B-, M10-, M10-D-, M10-B-
  M10-B2-, M10-C-, M10-C2-, M11-, M11-B-, M11-C-, M11-C2- und M12-
  Bewertung.
  Danach duerfen nur M7-B als technische Debug-Greybox bestaetigt, gezielt
  nachgebessert, M9 als erster Beispiel-Flow dokumentarisch bestaetigt, M10
  als emotionalere Produktflow-Preview dokumentarisch bestaetigt, M10-B als
  erste Challenge-Empfehlung dokumentarisch bestaetigt, M10-C als erste
  Companion-Reaktionsrichtung dokumentarisch bestaetigt, M11 als Multi-Flow-
  Richtung dokumentarisch bestaetigt, der World-Content-Katalog als erste
  Content-/Location-Grundlage bestaetigt, M12 als erste ThemeIsland-
  Priorisierung dokumentarisch bestaetigt oder konkrete Taxonomy-/Routing-
  Follow-ups geplant werden.
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
  M12 startet die ThemeIsland-Priorisierung und erzeugt Preview-Dateien; offen
  bleiben M12-Review, Word-to-Island-Routing-Matrix, Plot-Capability-
  Ableitung, Sensitive-Content-Regeln und Mobile-/Clutter-Regeln.
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
