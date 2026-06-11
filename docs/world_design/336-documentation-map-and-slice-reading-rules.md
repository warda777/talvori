# M16-AB: Documentation Map and Slice Reading Rules

Stand: 2026-06-11

Status: `Dokumentations-/Visual-Slice gestartet / keine Implementierung`

## 1. Zweck und Non-Goals

M16-AB erstellt eine zentrale Dokumentenlandkarte und verbindliche
Pflichtlektuere-Regeln pro Slice-Typ. Ziel ist, dass kuenftige
Codex-Prompts die richtigen Grundlagen lesen, betroffene M16-T-IDs nennen,
Stop-Regeln wiederholen und bestehende Gates nicht vergessen.

M16-AB gibt keine Implementierung frei.

Non-Goals:

- keine Implementierung,
- keine App-Integration,
- keine Route,
- keine neue Seite,
- keine Persistenz,
- keine Supabase/local DB Writes,
- keine SRS-/`word_progress`-Aenderung,
- keine automatische Wortplatzierung,
- kein Build-State,
- kein Build-Wheel-Code,
- keine Assets und keine Asset-Dateien unter `assets/`,
- kein `frame_started`,
- keine Bauzustaende,
- keine Tests oder Widget-Tests,
- keine Screenshots als Repo-Artefakte.

## 2. Gepruefte Grundlage

| Dokument | Rolle fuer M16-AB |
| --- | --- |
| `AGENTS.md` | Kurze Codex-Verfassung, Plugin-/Skill-Routing und externe Write-Grenzen. |
| `docs/world_design/talvori_game_bible.md` | Primaere Produkt-, Game-, Lern- und Sprachreferenz fuer Talvori Welt. |
| `docs/world_design/328-talvori-learning-game-readiness-todo-checklist.md` | Fuehrendes M16-T-Backlog, Dashboard, Statuslegende und ID-System. |
| `docs/world_design/327-talvori-learning-game-logic-readiness-review.md` | Readiness Review, Staerken, Blocker und produktive System-Gates. |
| `docs/world_design/329-talvori-product-delivery-dashboard-and-scrum-lite.md` | Scrum-lite-Modell, Definition of Ready/Done, MVP-Roadmap und Research-Gate. |
| `docs/world_design/330-minimal-playable-learning-loop-contract.md` | Produktanker, Core Loop, Event-Trennung und Learning-to-World Contract. |
| `docs/world_design/331-minimal-word-outcome-detail-gate.md` | Outcome-Definitionen, Queue-Ausgaenge und Reward/Placement/BuildState-Grenzen. |
| `docs/world_design/332-reward-budget-and-review-queue-control-gate.md` | Reward-Budget, Queue-Budget, Safe Defaults und Anti-Druck-Regeln. |
| `docs/world_design/333-minimal-semantic-profile-and-routing-priority-gate.md` | Minimal Semantic Profile, Word-Type-Routing, Confidence und Konfliktprioritaeten. |
| `docs/world_design/334-companion-and-sensitive-return-safety-gate.md` | Companion-Policy, Pause, Fehlerkommunikation und sensitive Darstellungsleiter. |
| `docs/world_design/335-learning-states-and-srs-boundary-gate.md` | Lernzustaende und strikte SRS-/`word_progress`-Boundary. |

## 3. Betroffene M16-T-IDs

| ID | M16-AB Entscheidung | Grund |
| --- | --- | --- |
| `M16T-DOC-001` | `[x]` | Dokumentationslandkarte liegt als zentrale Datei vor. |
| `M16T-DOC-002` | `[x]` | Slice-Typen mit Pflichtlektuere-Regeln sind dokumentiert. |
| `M16T-DASH-004` | `[x]` | Dashboard-Update-Regel ist operationalisiert: 328 muss nach ID-Aenderungen aktualisiert werden. |
| `M16T-META-002` | `[x]` | Jeder kuenftige Prompt muss relevante M16-T-IDs nennen. |
| `M16T-META-003` | `[x]` | Nach jedem Slice muss die Liste aktualisiert oder bewusst unveraendert berichtet werden. |
| `M16T-META-004` | `[x]` | M16-S und M16-T bleiben Pflichtgrundlage fuer Readiness-/Gate-Slices. |
| `M16T-GIT-001` | `[x]` | `git status --short` ist vor Commit und im Abschlussbericht Pflicht. |
| `M16T-GIT-002` | `[x]` | Scope-Check gegen Stop-Regeln und erwartete Dateien ist Pflicht. |

## 4. Dokumentenlandkarte

### 4.1 Readiness / Steuerung / Dashboard

| Dokument | Wann fuehrend? |
| --- | --- |
| `327-talvori-learning-game-logic-readiness-review.md` | Bei Readiness-, Audit-, Risiko- und Produktlogik-Entscheidungen. |
| `362-notion-linear-project-management-mapping.md` | Bei Projektmanagement-, Notion-, Linear-, GitHub-, externer Tool-Sync- oder Plugin-Write-Grenzen. |
| `talvori_game_bible.md` | Bei Produktidentitaet, Sprachschicht, Language Passport, Zielsprachen, Internal Corpus, Optional Capture, Context Before Vocabulary und Talvori-Welt-Grundlogik. |
| `328-talvori-learning-game-readiness-todo-checklist.md` | Bei jedem Slice mit M16-T-IDs, Dashboard, Status oder Fortschritt. |
| `329-talvori-product-delivery-dashboard-and-scrum-lite.md` | Bei Scrum-lite, MVP-Roadmap, Change-/Idea-Intake und Research-Gates. |
| `336-documentation-map-and-slice-reading-rules.md` | Bei jedem neuen World-/Learning-/Semantics-/Docs-/Commit-Slice als Lese-Kompass. |
| `369-codex-prompt-compression-and-slice-template-gate.md` | Bei Kurzprompt-, Template-, Prompt-Kompressions-, Standardcheck- oder Slice-Arbeitsvertrag-Fragen. |
| `prompt_templates/` | Wiederverwendbare Arbeitsvertraege fuer Docs-only, Review, Art/Master-Reference, Visual Documentation und Implementation Slices; ersetzt 336 nicht und gibt keine Implementierung frei. |

### 4.2 Minimaler Lernloop

| Dokument | Kernregel |
| --- | --- |
| `330-minimal-playable-learning-loop-contract.md` | Lernen erzeugt Moeglichkeit, keine automatische Platzierung. |
| `335-learning-states-and-srs-boundary-gate.md` | Lernzustaende bleiben fachlich und schreiben nicht SRS/`word_progress`. |
| `talvori_game_bible.md` | Building creates context; learning uses context; language grows from words into sentences, pronunciation and conversations. |

### 4.3 Word Outcomes

| Dokument | Kernregel |
| --- | --- |
| `323-word-semantics-decision-preview-scope.md` | Beispielwort-Entscheidungen zeigen sichere Representation Outcomes. |
| `331-minimal-word-outcome-detail-gate.md` | `CodexOnly`, `WorldCandidate`, `ContainerItem`, `ActionChallenge`, `ContextCard`, `SensitiveGated`, `NeedsUserChoice` sind MVP-Outcomes. |

### 4.4 Reward / Queue / Anti-Druck

| Dokument | Kernregel |
| --- | --- |
| `332-reward-budget-and-review-queue-control-gate.md` | Wenige Vorschlaege, kleine Review-Queue, Later immer erlaubt, kein Druck. |
| `334-companion-and-sensitive-return-safety-gate.md` | Tali/Vori spricht optional, ruhig und ohne Schuld oder Pflichtentscheidung. |

### 4.5 Semantik / Routing / Confidence

| Dokument | Kernregel |
| --- | --- |
| `321-global-world-semantics-consistency-audit.md` | Pflichtpipeline: Word -> Context/Sense -> Word Type -> Safety -> Representation -> User Choice -> Later Gate. |
| `333-minimal-semantic-profile-and-routing-priority-gate.md` | Safety > Sense > Word Type > Clutter > Confidence > User Choice > Capability > Reward. |
| `270-word-to-island-routing-matrix.md` | Routing macht Vorschlaege, keine automatische Platzierung. |
| `284-word-to-island-ux-flow.md` | Word-to-Island UX bleibt User-Choice- und Fallback-getrieben. |

### 4.6 Companion / Sensitive / Pause

| Dokument | Kernregel |
| --- | --- |
| `334-companion-and-sensitive-return-safety-gate.md` | Keine Schuld, keine Beratung, keine sensitive Retention-Trigger. |
| `274-sensitive-content-representation-rules.md` | Sensitive Inhalte bevorzugen Codex, ContextCard, Backlog, Later, Hide oder Policy-Gate. |

### 4.7 Learning States / SRS Boundary

| Dokument | Kernregel |
| --- | --- |
| `335-learning-states-and-srs-boundary-gate.md` | `imported`, `seen`, `practiced`, `unsure`, `contextRich`, `understood`, `reviewCandidate`, `worldFeedbackEligible`, `blockedBySafety`, `parked` sind fachliche MVP-Zustaende, keine SRS-Werte. |
| bestehende Lern-/SRS-Dokumentation spaeter | Erst mit eigenem SRS-/Migration-/Test-Gate fuehrend. |

### 4.8 World / Island / Plot / Build

| Dokument | Kernregel |
| --- | --- |
| `318-theme-island-plot-capacity-and-build-wheel-plan.md` | Thema -> Plotbedarf -> Groessenmix -> Island Capacity -> Slot-Auswahl -> spaeteres In-place Wheel. |
| `320-global-theme-island-plot-capacity-matrix.md` | Dorf ist nur ein Beispiel; Kategorien brauchen eigene Plot-Familien. |
| `272-plot-capability-derivation.md` | Plot-Capability ist Erlaubnis, keine Pflichtbelegung. |
| `351-starter-island-infrastructure-strategy-gate.md` | Starter-Insel-Infrastruktur trennt fixe Grundform, freie Slots, Kategorie-Templates, Varianten, Unlocks und BuildChoice. |
| `353-starter-island-identity-biome-and-category-scope-gate.md` | Uferhain-Identitaet, Starter-Biome, Kategorie-Scope, Terrain-Varianten und Future-Island-Grenzen fuer die erste Starter-Insel. |
| `355-talvori-core-construction-learning-spine.md` | Fuehrender Construction-Learning-Spine: Insel, Slot, Kategorie, BuildChoice, Bauphase, Lernhandlung, Ausbau, Raum und Container gehoeren zusammen. |
| `356-first-local-construction-learning-vertical-slice-gate.md` | Erstes lokales Construction-Learning-Vertical-Slice-Gate: Uferhain -> Zuhause -> Haus -> Grundstueckszoom -> Fundament-Candidate -> Lernhandlung -> lokales Feedback. |
| `357-game-like-island-selection-and-construction-camera-flow-gate.md` | Korrigiert den ersten Construction-Learning-Codepfad zu Game-like Insel-Showcase, Insel betreten, Kamera-Zoom, Bauplatz, visueller BuildChoice und minimalem HUD. |
| `361-local-construction-preview-boundary-and-flow-rejoin-gate.md` | Boundary fuer den Flow-Rejoin nach M16-BQ: lokale Preview verbindet Uferhain, Slot, BuildChoice, Kamera/Fokus und object-based Worker-Bauplatz, ohne App-Integration, Route, Persistenz oder BuildState. |
| `363-professional-island-build-flow-design-gate.md` | Design-before-Code-Gate nach gestopptem M16-BT: komplexe Inselbau-, Slot-, Kamera- und BuildChoice-Flows brauchen Research, Wireflow, visuelle Preview und Visual-QA vor weiterem Flutter-Code. |
| `365-modern-mobile-game-direction-board.md` | Modernes Mobile-Game-Direction-Board nach gestopptem M16-BX: M16-BY definiert Cozy Island Diorama Builder, Build Station am Slot und Worker/Companion als inhaltliche Richtung, ohne das konkrete v2-Board als visuelles Zielbild freizugeben. |
| `367-talvori-art-bible-v1.md` | Talvori Art Bible v1: Style-System-Gate fuer Kamera, Perspektive, Diorama-Stil, Figuren, Gebaeude, Build Station, UI/HUD, Metadaten und QA; keine Asset- oder Code-Freigabe. |
| `368-starter-island-master-reference-set.md` | Master-Reference-Brief-Gate fuer Uferhain, Build Station, Haus-Bauphasen, Worker/Tali/Vori, UI/HUD und Slot/Marker/Layer; keine Asset-, Bild-, App-Screen- oder Code-Freigabe. |
| `370-asset-family-and-export-spec.md` | Asset-Family-/Export-Spec-Gate fuer Familien, Layer, Exportformate, Groessen, Benennung, Metadaten, QA-Status und spaeteres Asset-Gate; keine Asset-, Bild-, Candidate- oder Code-Freigabe. |
| `371-starter-island-asset-candidate-gate.md` | Starter-Island-Asset-Candidate-Gate: entscheidet `island_base` als erste Candidate-Familie und definiert M16-CF-Grenzen; keine Asset-, Bild-, Candidate-, Engine-ready- oder Code-Freigabe. |
| `372-starter-island-base-candidate-generation-gate.md` | M16-CF-Freigabeplanung fuer M16-CG: definiert Dokumentationspfad, Dateinamen, Tool-Rollen, Prompt/Negative Prompt, Metadaten und QA fuer spaetere `island_base`-Candidates; erzeugt selbst keine Bilder/Dateien. |
| `previews/m16_cg_starter_island_base_candidate_generation/` | M16-CG-`island_base`-Dokumentationscandidates fuer Uferhain: drei Candidate-PNGs, Contact Sheet und Metadata-/QA-Datei; Kontextmaterial, keine Assets, keine App-Screens und keine Engine-ready Candidates. |
| `373-candidate-a-structure-lock-and-postprocess-brief.md` | M16-CI-Structure-Lock: Candidate A ist primaere Uferhain-`island_base`-Strukturreferenz, aber kein Asset, kein Zielbild, kein Engine-ready Candidate und keine Code-/App-Freigabe. |
| `374-candidate-a-layer-and-postprocess-plan.md` | M16-CJ-Layer-/Postprocess-Plan: uebersetzt Candidate A in getrennte Familien und Reihenfolge fuer `island_base`, `water_paths`, `terrain_layers`, `slot_markers`, `build_stations`, `building_phases`, `workers_companions` und `ui_hud_bubbles`; keine Bild-, Asset-, Engine-ready-, App- oder Code-Freigabe. |
| `375-candidate-a-external-postprocess-and-layer-production-brief.md` | M16-CK-External-Production-Brief: definiert externe Rollen, Ziel-Layer, spaetere Dokumentationspfade, Dateinamen, Metadaten und QA fuer Candidate-A-Postprocess; keine Bild-, Asset-, Engine-ready-, App-, Code- oder `assets/`-Freigabe. |
| `317-first-world-element-slice-scope-and-visual-plan.md` | Erste World-Elemente bleiben lokale, neutrale Previews. |

### 4.9 Container / Depth

| Dokument | Kernregel |
| --- | --- |
| `256-depth-container-user-flow-preview-plan.md` | Depth/Container brauchen eigene User-Flow-Grenzen. |
| `264-multi-example-container-flow-previews.md` | Mehrere Container-Beispiele verhindern Kleinteil-Clutter in der IslandView. |
| `276-mobile-clutter-rules-small-objects.md` | Kleine Objekte bekommen nicht automatisch eigene Grundstuecke. |

### 4.10 Mobile / Clutter / Accessibility

| Dokument | Kernregel |
| --- | --- |
| `276-mobile-clutter-rules-small-objects.md` | Mobile-Dichte, Labels und TinyObjects muessen begrenzt werden. |
| `277-mobile-clutter-visual-review.md` | Visual Review fuer kleine Objekte und UI-Dichte. |
| `335-learning-states-and-srs-boundary-gate.md` | Review/World-Feedback darf Mobile nicht mit Pflichtfragen ueberladen. |

### 4.11 Assets

| Dokument | Kernregel |
| --- | --- |
| `289-asset-prioritization-scope-gate.md` | Asset-Scope braucht eigenes Gate; keine Spielassets in Planungs-Slices. |
| `366-ai-art-production-pipeline-and-style-consistency-gate.md` | KI-Art-Produktion braucht Rollen, Style/Structure References, Style Bible, Master References, Asset-QA und Engine-ready Exportregeln; Referenzbilder sind Richtung, keine Assets. |
| `367-talvori-art-bible-v1.md` | Definiert die visuelle Sprache, Style-Metadaten und QA-Grenzen, bevor M16-CB Master References oder M16-CC Asset-Family-Spec entstehen. |
| `368-starter-island-master-reference-set.md` | Definiert Starter-Island-, Build-Station-, Figuren-, HUD- und Slot/Layer-Reference-Briefs fuer M16-CC; keine Master-Reference-Bilder und keine Assets. |
| `370-asset-family-and-export-spec.md` | Definiert Asset-Familien, Layer, Exportformate, Groessen, Benennung, Source-/Prompt-/Reference-Metadaten, QA-Status und Gate-Regeln, bevor echte Dateien oder Engine-ready Candidates entstehen duerfen. |
| `371-starter-island-asset-candidate-gate.md` | Definiert das erste Starter-Island-Candidate-Gate: `island_base` zuerst, M16-CF nur mit expliziter Bild-/Tool-/Pfad-/Metadaten-/QA-Freigabe; keine `assets/`-Writes oder Engine-ready Candidates. |
| `372-starter-island-base-candidate-generation-gate.md` | Definiert die konkrete M16-CG-Vorbereitung fuer `island_base`: erlaubter Dokumentationspfad, Dateinamen, Prompt-/Negative-Prompt-Anforderungen, Pflichtmetadaten, QA und Maximalstatus `asset_candidate`. |
| `previews/m16_cg_starter_island_base_candidate_generation/talvori_island_base_uferhain_candidate_metadata.md` | Fuehrende M16-CG-Candidate-Metadaten und QA fuer die Uferhain-`island_base`-PNGs; pruefen vor jeder weiteren Candidate-, Asset-, Layer- oder Engine-ready-Entscheidung. |
| `previews/m16_cg_starter_island_base_candidate_generation/talvori_island_base_uferhain_contact_sheet_1x.png` | M16-CG-Contact-Sheet fuer schnelle visuelle Candidate-Review; Dokumentationsvisual, kein Spielasset und kein App-Screen. |
| `373-candidate-a-structure-lock-and-postprocess-brief.md` | Fuehrender Structure-/Postprocess-Brief fuer Candidate A: Silhouette, Flussarm, Lichtung, Hain, Slot-Reserve, Layer-Trennung und Boundary gegen Asset-/Engine-ready-/Code-Freigabe. |
| `374-candidate-a-layer-and-postprocess-plan.md` | Konkreter Layer-/Postprocess-Plan fuer Candidate A: Reihenfolge, Familiengrenzen, Postprocess-Regeln, QA und Boundary gegen neue Bilder, `assets/`, Engine-ready, approved Asset und Code. |
| `375-candidate-a-external-postprocess-and-layer-production-brief.md` | Externer Produktionsbrief fuer Candidate A: klaert ChatGPT/image_gen-, Figma/Photopea/Photoshop/Aseprite-/Artist- und Codex-Rollen, spaetere Layer-Dateinamen, Metadaten, QA und Maximalstatus `layer_postprocess_candidate`. |
| `assets/images/world/buildable_islands/forest_clearing/template.md` | Waldlichtung/Previews sind Starter-/Testformen, keine App-/Assetfreigabe. |

### 4.12 Datenmodell / Persistenz / Backend

| Dokument | Kernregel |
| --- | --- |
| `326-scalable-word-semantics-architecture-plan.md` | Semantic Profiles, Queues und Fallbacks sind Konzept, keine Datenstruktur. |
| `335-learning-states-and-srs-boundary-gate.md` | Kein SRS-/`word_progress`-Write, kein Provider-Call, keine ContextHint-Speicherung ohne Gate. |
| `327-talvori-learning-game-logic-readiness-review.md` | Datenmodell, Persistenz, Migration und Supabase Writes bleiben produktive Blocker. |

### 4.13 Research / Benchmark

| Dokument | Kernregel |
| --- | --- |
| `329-talvori-product-delivery-dashboard-and-scrum-lite.md` | Research-Gates leiten Prinzipien ab, kopieren aber keine Mechaniken blind. |
| `328-talvori-learning-game-readiness-todo-checklist.md` | `M16T-RESEARCH-002` und `M16T-RESEARCH-003` sind eigene Detail-Gates. |
| `345-play-first-learning-experience-doctrine.md` | Game-Patterns muessen in Play-First-Regeln uebersetzt werden, bevor Mechaniken entstehen. |

### 4.14 Play-First / Gameplay Doctrine

| Dokument | Kernregel |
| --- | --- |
| `345-play-first-learning-experience-doctrine.md` | Talvori ist kein Vokabeltrainer mit Spieldeko, sondern ein Spiel, dessen Spielhandlungen Lernnutzen erzeugen. |
| `340-gameplay-pillars-and-mvp-quest-loop-research-prep.md` | Gameplay Pillars, Quest-/Challenge-Loop und Spass ohne Lernschaden. |
| `343-habit-motivation-pressure-free-retention-research.md` | Motivation und Retention ohne Druck, Streak-Schuld oder Pflicht. |
| `344-supercell-clash-progression-social-pressure-research.md` | Aufbaufortschritt und Social/Competition-Risiken ohne MVP-Freigabe. |
| `358-fun-adventure-curiosity-reward-gameplay-spine-gate.md` | Hoechste Fun-/Adventure-/Curiosity-/Reward-Regel: jeder relevante Slice braucht Player Hook, kleine Huerde, Spielhandlung, Belohnung als neue Moeglichkeit und Anti-Druck-Abgrenzung. |
| `359-successful-game-pattern-translation-for-talvori-construction-play.md` | Uebersetzt erfolgreiche Spielmuster in object-first Bauplatzregeln: sichtbares Problem vor Text, manipuliertes Objekt, sichtbare Weltveraenderung, naechste Moeglichkeit. |
| `360-character-assisted-world-action-rule.md` | Verbindliche Pruefung, ob Figur, Worker, Tali/Vori oder Weltobjekt eine Bau-, Reparatur-, Sammel-, Container- oder Objektaktion sichtbar und spielerischer ausfuehren soll. |

### 4.15 Interaction Patterns / UI-Entscheidung

| Dokument | Kernregel |
| --- | --- |
| `350-interaction-pattern-decision-matrix.md` | Wheel, Drag, Popup, HUD, Bottom-Sheet, Showcase, Werkbank, Codex-Seite und Map/Board werden nach Aktionstyp, Risiko, Informationsmenge und Spielkontext bewusst gewaehlt. |
| `363-professional-island-build-flow-design-gate.md` | Komplexe Island-/Slot-/BuildChoice-/Kamera-Flows brauchen Flow, Wireflow, Visual-Konzept, Interaktionsregeln und Visual-QA vor Code. |
| `365-modern-mobile-game-direction-board.md` | Fuehrende BuildChoice-Richtung ist Build Station am Slot als Weltobjekt; Wheel nur als kleiner Teil der Station, nicht als alleinige Label-Wolke oder UI-Menue. |
| `350-interaction-pattern-decision-matrix.md` Research-Check | Bei unklarer UI-/Spielaufbau-Entscheidung muss vor Umsetzung ein kurzer Benchmark-/Research-Check gegen erfolgreiche Spiel-/UI-Muster erfolgen. |

### 4.16 Visual-QA / Preview-Diagramme

| Dokument | Kernregel |
| --- | --- |
| `322-next-safe-preview-slice-decision-gate.md` | Visual-QA prueft Text-Containment, Innenabstand, Kartenabstand, Footer und Contact Sheet. |
| `365-modern-mobile-game-direction-board.md` | M16-BY-Visuals sind Direction-Board-Dokumentationsmaterial; das konkrete v2-Board ist nur abgelehnter Zwischenstand. Kuenftige High-Fidelity- oder Code-Slices muessen die konzeptionelle Cozy-Island-Diorama-Richtung und Build Station am Slot beruecksichtigen. |
| `366-ai-art-production-pipeline-and-style-consistency-gate.md` | Pipeline-Visuals duerfen Prozessdiagramme sein, aber keine neuen Spielbilder; finale Assets brauchen eigenes Asset-Gate. |
| `367-talvori-art-bible-v1.md` | Visuelle Docs zu Insel, Build Station, Figuren, Gebaeuden, HUD, Farbe, Licht, Kamera oder Asset-Familien muessen das Style-System lesen und duerfen daraus keine Asset- oder Code-Freigabe ableiten. |
| `368-starter-island-master-reference-set.md` | Visuelle Folgearbeiten zu Starter-Insel/Uferhain, Build Station, Haus-Bauphasen, Figuren, HUD oder Slot/Layer muessen die Briefs lesen; 368 selbst erzeugt keine Bilder/Previews. |
| `370-asset-family-and-export-spec.md` | Visuelle Folgearbeiten mit Asset-Familien, Export, Layern, Groessen, Namen, QA-Status oder Engine-ready Candidates muessen die Spec lesen; 370 selbst erzeugt keine Bilder/Assets. |
| `371-starter-island-asset-candidate-gate.md` | Visuelle Folgearbeiten zum ersten Starter-Island-Candidate muessen `island_base` als erste Familie und die M16-CF-Grenzen lesen; 371 selbst erzeugt keine Bilder/Assets/Candidates. |
| `372-starter-island-base-candidate-generation-gate.md` | M16-CG oder andere `island_base`-Bildgenerierungs-Slices muessen 372 lesen; 372 selbst erzeugt keinen Preview-Ordner, keine PNG/SVG und keine Candidates. |
| `previews/m16_cg_starter_island_base_candidate_generation/` | Bestehende M16-CG-Candidates muessen mit Metadata-Datei und Contact Sheet gelesen werden; sie bleiben Dokumentationscandidates mit Maximalstatus `asset_candidate`. |
| `373-candidate-a-structure-lock-and-postprocess-brief.md` | Spaetere Uferhain-/Candidate-A-/Layer-/Postprocess-Visuals muessen 373 lesen; 373 ist keine Bild-, Asset-, App-, Code- oder Engine-ready-Freigabe. |
| `374-candidate-a-layer-and-postprocess-plan.md` | Spaetere Candidate-A-/Uferhain-`island_base`-/Layer-/Postprocess-/Asset-Candidate-/Engine-ready-/Flutter-Folgearbeiten muessen 374 lesen; 374 ist keine Bild-, Asset-, Code-, App-, Engine-ready- oder `assets/`-Freigabe. |
| `375-candidate-a-external-postprocess-and-layer-production-brief.md` | Spaetere externe Bildarbeit, Candidate-A-Layerproduktion, Postprocess, Asset-Candidates oder Engine-ready-Gates muessen 375 lesen; 375 ist keine Bild-, Asset-, Code-, App-, Engine-ready- oder `assets/`-Freigabe. |
| alle M16-S bis M16-AA Preview-Ordner | Dokumentationsvisuals sind keine App-Screens, keine Screenshots, keine Assets. |

Kuenftige Visual Documentation Slices sollen bevorzugt PNG und SVG erzeugen:
PNG fuer schnelle Vorschau, SVG fuer verlustfreie Zoom- und
Dokumentationsqualitaet. Text-Containment, ausreichender Innenabstand,
lesbare Contact Sheets und keine Ueberlappungen von Karten, Labels, Pfeilen,
Titeln, Footern oder Legenden sind harte Commit-Voraussetzungen.

## 5. Slice-Typen mit Pflichtlektuere

Jeder Slice darf zusaetzliche Docs nennen. Die folgende Liste ist die
Mindest-Pflichtlektuere pro Slice-Typ.

| Slice-Typ | Pflichtlektuere |
| --- | --- |
| Learning Loop Slice | `328`, `345`, `355` wenn Welt-/Bau-/Ausbau-Fortschritt betroffen ist, `356` wenn der erste Foundation-/Haus-Vertical-Slice oder M16-BK betroffen ist, `358` wenn Spielhandlung, Hook, Mission, Reward oder Motivation betroffen ist, `359` wenn Bauaufgabe, Puzzle, objektbasierte Lernhandlung oder Belohnung als Weltveraenderung betroffen ist, `360` wenn Figur/Worker/Tali/Vori, sichtbare Objektaktion, Bauhandlung, Reparatur, Sammeln, Tragen, Oeffnen oder Container betroffen ist, `327`, `330`, `331`, `332`, `335`, `329` |
| Language Layer / Onboarding Slice | `talvori_game_bible.md`, `328`, `336`, `345`, `330`, `331`, `333`, `335` und betroffene Feature-Docs; Pflicht wenn Produktidentitaet, Sprachschicht, aktive Zielsprache, UI language, Companion language, Language Passport, Level/Scaffolding, Internal Corpus, Optional Capture, Import/Sharing oder Context Before Vocabulary betroffen sind. |
| Word Outcome Slice | `328`, `330`, `331`, `333`, `321`, `323`, `274`, `276` |
| Reward / Queue Slice | `328`, `330`, `331`, `332`, `334`, `327`, `326` |
| Gameplay / Quest / Challenge Slice | `328`, `345` mit Play-First + Island-First Rule, `350`, `355`, `356` wenn erster Construction-Learning-Vertical-Slice, Haus/Fundament oder M16-BK betroffen ist, `357` wenn Insel-Showcase, Kamera-Zoom, Bauplatz, BuildChoice oder M16-BM betroffen ist, `358` fuer Player Hook, kleine Huerde, Spielspannung, Belohnung/neue Moeglichkeit und Anti-Druck-Abgrenzung, `359` fuer sichtbares Problem, manipuliertes Objekt, Weltveraenderung und kein Button-Quiz, `360` fuer Character-assisted Action, indirekte Worker-Steuerung, Arbeitsbewegung und Movement-/Pathfinding-Abgrenzung, `340`, `330`, `331`, `332`, `333`, `334`, `337` |
| Semantics / AI Slice | `328`, `321`, `323`, `326`, `333`, `335`, `274`, `276`, `284` |
| Companion / Sensitive Slice | `328`, `334`, `274`, `333`, `331`, `332`, `327` |
| Learning State / SRS Slice | `328`, `330`, `331`, `332`, `333`, `334`, `335` und spaeter SRS-/Migration-Docs |
| World / Island / Plot Slice | `talvori_game_bible.md` wenn Produktidentitaet, Sprachanker oder Context Before Vocabulary betroffen ist, `328`, `345` mit Play-First + Island-First Rule, `350`, `351`, `353` wenn Starter-Insel, Biome, Kategorie-Scope, Terrain-Variante oder Insel-Identitaet betroffen ist, `355` wenn Weltfortschritt, BuildChoice, Bauphase, Raum oder Container/Depth betroffen ist, `356` wenn Uferhain-Startslot, Zuhause/Haus, Grundstueckszoom oder Fundament-Candidate betroffen ist, `357` wenn Inselauswahl, Weltansicht, Kamera-Fokus, Bauplatz oder M16-BM betroffen ist, `358` wenn Weltneugier, Spielspannung, Belohnung, Mission oder naechster Hook betroffen ist, `359` wenn Bauplatzproblem, Objektmanipulation oder sichtbare Weltveraenderung betroffen ist, `360` wenn eine Figur, ein Worker, Tali/Vori oder ein Weltobjekt eine Weltaktion sichtbar tragen koennte, `367` wenn visuelle Qualitaet, Stil, Figuren, HUD, Gebaeude, Insel, Build Station oder Asset-Familien betroffen sind, `368` wenn Starter-Insel/Uferhain, Build Station, Haus-Bauphasen, Worker/Tali/Vori, UI/HUD, Slot/Marker/Layer oder Master References betroffen sind, `370` wenn Asset-Familien, Export, Layer, Groessen, Benennung, Metadaten, QA-Status, Engine-ready Candidates oder `assets/`-Grenzen betroffen sind, `371` wenn Starter-Island-Candidate, `island_base`, Uferhain-Asset-Reihenfolge oder M16-CF betroffen ist, `372` wenn `island_base`-Candidate-Generierung, M16-CG, Dokumentationspfad, Dateinamen, Prompts oder Candidate-QA betroffen sind, `373` wenn Candidate A, Uferhain-Struktur, `island_base`-Structure-Lock, Layerplanung oder Postprocess betroffen ist, `374` wenn Candidate A, Uferhain-`island_base`, Layertrennung, Postprocess-Reihenfolge, spaetere Asset-Candidates, Engine-ready-Gates oder Flutter-Integration betroffen sind, `375` wenn externe Bildarbeit, Candidate-A-Layerproduktion, Postprocess-Brief, spaetere Layer-Candidates oder Engine-ready-Gates betroffen sind, `321`, `318`, `320`, `272`, `273`, `276`, `331`, `333` |
| Construction Rejoin / Buildsite Preview Slice | `328`, `336`, `345`, `350`, `351`, `353`, `355`, `356`, `357`, `358`, `359`, `360`, `361`, `363`, `365`, bei visueller Qualitaet auch `366`, `367`, `368` und `370` wenn Inselbau-Flow, Uferhain, Slot-Freiheit, BuildChoice-Pattern, Build Station, Haus-Bauphasen, Kamera/Pan/Zoom, moderne Game-Direction, Figuren, HUD, Slot/Layer, Asset-Familien, Export, Benennung oder komplexe Layout-Entscheidung betroffen ist; jeder Rejoin-Slice muss klaeren, welcher isolierte Proof verbunden wird, was Preview bleibt, welche Datei geaendert werden darf, ob BQ als Muster/Kopie/Import/Referenz genutzt wird, ob die M16-BY-Richtung, M16-BZ-Pipeline, Art Bible, Master-Reference-Briefs und Asset-Spec beruecksichtigt werden und warum keine App-Integration, Route, Navigation, Persistenz oder BuildState entsteht. |
| Professional Design / UX Gate Slice | `AGENTS.md`, `talvori_game_bible.md`, `328`, `336`, `350`, `351`, `353`, `355`, `357`, `358`, `359`, `360`, `361`, `363`, `365`, bei Art-/Asset-/Style-/Master-Reference-Fragen auch `366`, `367`, `368`, `370`, `371`, `372`, `373`, `374`, `375` und betroffene Fachdocs; komplexe World-/UI-/BuildChoice-/Kamera- oder Inselbau-Entscheidungen muessen Game-DNA, Flow, Wireflow, Pattern-Entscheidung, starkes Referenzbild als Art-Direction-Reference, Art-Bible-Style-Regeln, Master-Reference-Briefs, Asset-Familien-/Export-Regeln, Candidate-Gate-Reihenfolge, M16-CG-Freigabegrenzen, Candidate-A-Structure-Lock, Candidate-A-Layer-/Postprocess-Plan, externen Candidate-A-Postprocess-Brief, Kamera-/Gestenmodell, Copy, Visual-QA und erlaubte Folge-Dateien klaeren, bevor neuer Code entsteht. |
| Container / Depth Slice | `328`, `355` wenn Container als Ausbau-/Lernspine betroffen ist, `358` wenn Oeffnen, Finden, Sammeln, Container-Hook oder Belohnung als neue Moeglichkeit betroffen ist, `360` wenn Figur/Worker/Tali/Vori oder Objektaktion das Oeffnen, Sortieren, Tragen, Bergen oder Einsammeln sichtbarer machen koennte, `331`, `333`, `276`, `256`, `257`, `264`, `265` |
| Build-Wheel Slice | `328`, `350`, `351`, `353` wenn Starter-Insel, Terrain-Variante oder Kategorie-Scope betroffen ist, `355`, `356` wenn Zuhause/Haus/Fundament-Vertical-Slice betroffen ist, `357` wenn BuildChoice visuell, Showcase oder Bauplatz-Kamera betroffen ist, `358` wenn Bauhandlung, Spielspannung, Belohnung oder naechster Hook betroffen ist, `359` wenn BuildChoice in Bauplatz-Puzzle, Objekt- oder Weltveraenderung uebersetzt wird, `360` wenn BuildChoice oder Bauabschnitt durch Worker-/Figurenhandlung lebendiger werden koennte, `368` wenn Build Station, Slot/Marker/Layer oder Haus-Bauphasen betroffen sind, `370` wenn Asset-Familien, Layer, Export, Groessen, Benennung oder Engine-ready Candidates betroffen sind, `318`, `320`, `331`, `332`, `333`, `327`; Build-Wheel-Code bleibt bis eigenem Gate blockiert. |
| Mobile / Accessibility Slice | `328`, `276`, `277`, relevante Preview-/Visual-Reviews und Stop-Regeln aus `327`. |
| Asset Slice | `328`, `289`, `366`, `367`, `368` wenn Starter-Insel/Uferhain, Build Station, Haus-Bauphasen, Figuren, HUD, Slot/Marker/Layer oder Master References betroffen sind, `370` wenn Asset-Familien, Exportformate, Layer, Groessen, Benennung, Source-/Prompt-/Reference-Metadaten, QA-Status, Engine-ready Candidates oder `assets/`-Grenzen betroffen sind, `371` wenn Starter-Island-Candidate, `island_base`, M16-CF, Candidate-Erzeugung oder erste Asset-Familien-Reihenfolge betroffen ist, `372` wenn `island_base`-Candidate-Bildgenerierung, M16-CG, erlaubte Candidate-Dateinamen, Dokumentationspfad, Prompt/Negative Prompt, Metadaten oder QA betroffen sind, `373` wenn Candidate A, Structure-Lock, Postprocess, Layerplanung oder spaetere `island_base`-Asset-/Engine-ready-Entscheidungen betroffen sind, `374` wenn Candidate A, Uferhain-`island_base`, Layertrennung, Postprocess, spaetere Asset-Candidates, Engine-ready-Gates, `assets/`-Pfadschutz oder Flutter-Folgearbeit betroffen sind, `375` wenn externe Bildarbeit, Layerproduktion, spaetere Dateinamen/Pfade, Layer-Candidate-Metadaten oder Candidate-A-Postprocess-QA betroffen sind, `274`, `276`, `320`, `assets/images/world/buildable_islands/forest_clearing/template.md`; keine finalen Assets ohne Asset-Gate, keine Bilder nach `assets/` ohne Freigabe, keine freien Einzelprompts als Produktionspipeline, keine Abweichung von Art Bible, Master-Reference-Briefs, Asset-Spec, Candidate-Gate, Candidate-A-Structure-Lock, Candidate-A-Layer-/Postprocess-Plan oder externem Postprocess-Brief ohne neues Style-/Reference-/Asset-Gate. |
| AI Art / Asset Pipeline Slice | `AGENTS.md`, `talvori_game_bible.md`, `328`, `336`, `365`, `366`, `367`, `368` wenn Master References, Starter-Insel/Uferhain, Build Station, Haus-Bauphasen, Figuren, HUD, Slot/Marker/Layer oder M16-CC betroffen sind, `370` wenn Asset-Familien, Export, Layer, Groessen, Benennung, Metadaten, QA-Status oder Engine-ready Candidates betroffen sind, `371` wenn Starter-Island-Asset-Candidate, `island_base`, M16-CF oder Candidate-Erzeugungsgrenzen betroffen sind, `372` wenn M16-CG, konkrete `island_base`-Bildgenerierung, Tool-Rollen, Prompt/Negative Prompt, erlaubter Pfad, Dateinamen oder Candidate-QA betroffen sind, `373` wenn Candidate-A-Struktur, Postprocess, Layer-Trennung oder spaetere Candidate-A-Folgearbeit betroffen ist, `374` wenn Candidate-A-Layerfamilien, Postprocess-Reihenfolge, neue Bildfreigabe, spaetere Asset-Candidates oder Engine-ready-Abgrenzung betroffen sind, `375` wenn externe Postprocess-/Layer-Produktion, ChatGPT/image_gen- oder Design-Tool-Rollen, spaetere Pfade/Dateinamen, Layer-Candidate-Metadaten oder QA betroffen sind, `289` und betroffene Asset-Scope-Docs; klaert Rollen, Referenzen, Style Bible, Master-Reference-Briefs, Asset-Family-/Export-Spec, Candidate-Gate-Reihenfolge, M16-CG-Freigabegrenzen, Candidate-A-Structure-Lock, Candidate-A-Layer-/Postprocess-Plan, externen Postprocess-Brief, Tool-Pipeline, Postprocess, QA, Exportmetadaten und Stop-Regeln. Codex darf Bilder nicht nachzeichnen, sondern nur dokumentieren, strukturieren und pruefen. |
| Art Bible / Style System Slice | `AGENTS.md`, `talvori_game_bible.md`, `328`, `336`, `365`, `366`, `367` falls vorhanden, `368` falls Master References bereits existieren oder Folge-Specs betroffen sind, `370` falls Asset-Familien, Export, Layer, Benennung oder Metadaten bereits existieren oder geaendert werden, `350`, `351`, `353`, `355`, `357`, `359`, `360`; klaert visuelle Sprache, Kamera, Perspektive, Diorama-Proportionen, Figuren, Gebaeude, Build Station, UI/HUD, Asset-Familien-Grenzen, Metadaten und QA, ohne Assets, App-Screens oder Code freizugeben. |
| Data / Persistence Slice | `328`, `326`, `327`, `333`, `335`, plus eigenes Datenmodell-/Migration-/Privacy-Gate. |
| UI / MVP Screen Slice | `328`, `345` mit Play-First + Island-First Rule, `350`, `351` wenn Starter-Insel, Plot-Slot, Kategorie, Variante, Unlock oder BuildChoice betroffen ist, `353` wenn Inselidentitaet, Starter-Biome oder Terrain-Variante betroffen ist, `355` wenn Spielmoment, BuildChoice, Bau-/Ausbaufortschritt, Raum oder Container betroffen ist, `356` wenn erster lokaler Foundation-/Haus-Vertical-Slice oder M16-BK betroffen ist, `357` wenn Showcase, Weltansicht, Kamera-Zoom, Bauplatz, Bauphase oder minimales HUD betroffen ist, `358` wenn Player Hook, UI-Reward, Spielspannung, Mission oder Textreduktion fuer Spielgefuehl betroffen ist, `359` wenn Text durch sichtbares Problem, Objektmanipulation und Weltveraenderung ersetzt werden muss, `360` wenn sichtbare Figuren-/Worker-Handlung UI-Bestaetigung ersetzen oder staerken koennte, `367` wenn HUD, Bubbles, Figuren, Gebaeude, Build Station, Inselstil oder mobile Lesbarkeit betroffen sind, `368` wenn Uferhain, Build Station, Haus-Bauphasen, Figuren, HUD oder Slot/Marker/Layer betroffen sind, `370` wenn Asset-Familien, Export, Layer, Groessen, Benennung oder Engine-ready Candidates fuer UI/HUD/Bubbles oder Weltobjekte betroffen sind, `337`, `332`, `334`, betroffene Feature-Docs und Visual-/Accessibility-Regeln. |
| App-Integration Slice | `talvori_game_bible.md` wenn Produktidentitaet, Sprachschicht, Language Passport, Internal Corpus, Optional Capture oder Context Before Vocabulary in App-Flow ueberfuehrt wuerde, `328`, `345` mit Play-First + Island-First Rule, `350`, `351` wenn World/Island/Plot betroffen ist, `353` wenn Starter-Insel oder Future-Island-Family betroffen ist, `355` wenn Construction-Learning-Spine betroffen ist, `356` wenn erster Foundation-/Haus-Vertical-Slice betroffen ist, `357` wenn Kamera-/Showcase-Flow betroffen ist, `358` wenn Gameplay-Hook, Reward/neue Moeglichkeit oder Mission in App-Flow ueberfuehrt wuerde, `327`, `329`, betroffene Feature-Docs, Architecture/Boundary Gate und Route-Gate. |
| Implementierungs-Slice | `talvori_game_bible.md` wenn Produktidentitaet, Sprachschicht, Zielsprachen, Language Passport, Internal Corpus, Optional Capture oder Context Before Vocabulary betroffen sind, `328`, `336`, `345` mit Play-First + Island-First Rule, `350` wenn UI, World, Gameplay, Navigation oder Interaktion betroffen ist, `351` wenn Starter-Insel, Plot-Slots, Kategorie-Templates, Varianten, Unlocks oder BuildChoice betroffen sind, `353` wenn Starter-Insel-Identitaet, Biome, Kategorie-Scope oder Terrain-Variante betroffen sind, `355` wenn Spielmoment, BuildChoice, Bau-/Ausbaufortschritt, Raum, Container/Depth oder Lernhandlung betroffen ist, `356` wenn erster lokaler Foundation-/Haus-Vertical-Slice, Grundstueckszoom, Fundament-Candidate oder M16-BK betroffen ist, `357` wenn Insel-Showcase, Kamera-Zoom, Bauplatz, visuelle BuildChoice, M16-BM oder Construction-HUD betroffen ist, `358` wenn Gameplay, World, BuildChoice, Learning, Mission, Reward, Hook oder Spielspannung betroffen ist, `359` wenn Bauaufgabe, Puzzle, Mission, Belohnung, Objektmanipulation oder Button-Quiz-Risiko betroffen ist, `360` wenn Figur/Worker/Tali/Vori, Objektaktion, Bauhandlung, Reparatur, Sammeln, Tragen, Oeffnen, Werkstatt oder Container betroffen ist, `361` wenn isolierte Proofs, BQ-Muster, Uferhain/Slot/BuildChoice/Kamera und Buildsite-Rejoin verbunden werden, `363` und `365` wenn komplexer Island-/Slot-/BuildChoice-/Kamera-Code nach M16-BY entsteht, `367` wenn visuelle Qualitaet, Art Style, HUD, Figuren, Build Station, Insel oder Gebaeude betroffen sind, `368` wenn Uferhain, Build Station, Haus-Bauphasen, Worker/Tali/Vori, HUD oder Slot/Marker/Layer betroffen sind, `370` wenn Asset-Familien, Layer, Export, Groessen, Benennung, Metadaten, QA-Status, Engine-ready Candidates oder Dateien unter `assets/` betroffen waeren, `371` wenn Starter-Island-Candidates, `island_base` oder M16-CF/M16-Candidate-Grenzen betroffen waeren, `372` wenn `island_base`-Candidate-Dateien, M16-CG, Dokumentationspfad, Dateinamen, Prompts oder Candidate-QA betroffen waeren, `373` wenn Candidate A, Uferhain-Struktur, Layer-/Postprocess-Plan oder spaetere `island_base`-Entscheidungen betroffen waeren, `374` wenn Candidate A, Uferhain-`island_base`, Layertrennung, Postprocess-Reihenfolge, spaetere Asset-Candidates, Engine-ready-Gates oder Flutter-Integration betroffen waeren, `375` wenn externe Postprocess-/Layer-Produktion, Layer-Candidate-Dateinamen/Pfade, Metadaten, QA oder Candidate-A-Produktionsgrenzen betroffen waeren; Folge-Code muss Cozy Island Diorama Builder, Build Station am Slot, Art Bible, Master-Reference-Briefs, Asset-Spec, Candidate-Gate, Candidate-A-Structure-Lock, Candidate-A-Layer-/Postprocess-Plan und externen Postprocess-Brief beruecksichtigen und darf nicht nur auf abgelehntem Low-Fidelity-Wireflow, v1-Uebergangsboard oder v2-Zwischenvorschau basieren, betroffene Fachdocs, erwartete Dateien und harte Scope-/Stop-Regeln. |
| Research / Benchmark Slice | `328`, `345`, `329`, `327`, betroffene M16-T-IDs und eigene Research-Frage. |
| Project Management / External Tool Sync Slice | `AGENTS.md`, `talvori_game_bible.md`, `328`, `336`, `362` und betroffene Tool-/Plugin-Regeln; keine Notion-, Linear-, GitHub-, Supabase-, API-Key- oder sonstigen externen Writes ohne ausdrueckliche Freigabe. |
| Prompt Compression / Template Slice | `AGENTS.md`, `328`, `336`, `369` falls vorhanden, `docs/world_design/prompt_templates/README.md` falls vorhanden, betroffene Template-Dateien; klaert Kurzprompt-Pflichtfelder, Template-Vererbung, Standardchecks, Output-Regeln, Commit-Grenzen und External-Write-Grenzen, ohne Implementierung freizugeben. |
| Visual Documentation Slice | `328`, `327`, relevante Fachdocs, Visual-QA-Regel, erwarteter Preview-Ordner; bei komplexem Island-Build-Flow auch `363` und `365`, aber nicht das abgelehnte v2-Board als Zielbild verwenden; bei Art-/Asset-Pipeline auch `366`; bei Stil, Kamera, Figuren, HUD, Gebaeuden, Insel, Build Station oder Asset-Familien auch `367`; bei Starter-Insel/Uferhain, Build Station, Haus-Bauphasen, Figuren, HUD, Slot/Marker/Layer oder Master References auch `368`; bei Asset-Familien, Exportformaten, Layern, Groessen, Benennung, Metadaten, QA-Status oder Engine-ready Candidates auch `370`; bei Starter-Island-Candidate, `island_base` oder M16-CF auch `371`; bei M16-CG, Candidate-Bildgenerierung, erlaubtem Dokumentationspfad, Dateinamen, Prompt/Negative Prompt oder Uferhain-QA auch `372`; bei Candidate A, Uferhain-Struktur, Layerplanung, Postprocess oder Structure-Lock auch `373`; bei Candidate-A-Layerfamilien, Postprocess-Reihenfolge, Uferhain-`island_base`, Asset-Candidates, Engine-ready-Gates oder Flutter-Folgearbeit auch `374`; bei externer Bildarbeit, Layerproduktion, Pfad-/Dateinamenplanung, Metadaten, QA oder Candidate-A-Postprocess-Brief auch `375`; bevorzugt PNG + SVG erzeugen, sofern der Prompt Visuals erlaubt. |
| Commit / Review Slice | `328`, `336`, erwartete Dateien, `git status --short`, `git diff --check`, Scope-Check. |

Zusaetzliche M16-CG-Kandidatenregel:

- Wenn ein spaeterer Slice Uferhain-`island_base`-Candidates, Candidate-Auswahl,
  Asset-Review, Layer-Planung, Engine-ready-Vorbereitung oder Bild-QA
  betrifft, muessen neben 371/372 auch die M16-CG-Metadatendatei und das
  Contact Sheet im Preview-Ordner gelesen werden.
- Die Candidate-PNGs bleiben Dokumentationsmaterial mit Maximalstatus
  `asset_candidate`: keine Assets, keine App-Screens, keine Engine-ready
  Candidates, keine approved Assets und keine Produktintegration.
- Candidate A ist nach 373 nur primaere Strukturreferenz. 373 darf nicht als
  Asset-, Code-, App-, Engine-ready- oder finales Zielbild-Gate gelesen
  werden.
- 374 ist der konkrete Candidate-A-Layer-/Postprocess-Plan. Er ist Pflicht,
  wenn Candidate A, Uferhain-`island_base`, Layertrennung, Postprocess,
  spaetere Asset-Candidates, Engine-ready-Gates oder Flutter-Integration
  betroffen sind. 374 ist keine Bild-, Asset-, Code-, App-, Engine-ready- oder
  `assets/`-Freigabe.
- 375 ist der externe Candidate-A-Postprocess- und Layer-Production-Brief. Er
  ist Pflicht, wenn externe Bildarbeit, ChatGPT/image_gen, Figma/Photopea/
  Photoshop/Aseprite/Artist, Candidate-A-Layerproduktion, spaetere
  Dokumentationspfade, Dateinamen, Layer-Candidate-Metadaten, QA,
  Asset-Candidates oder Engine-ready-Gates betroffen sind. 375 ist keine
  Bild-, Asset-, Code-, App-, Engine-ready- oder `assets/`-Freigabe.

## 6. Prompt-Regel fuer kuenftige Codex-Prompts

Kuenftige Codex-Prompts duerfen als Kurzprompt auf ein Template aus
`docs/world_design/prompt_templates/` verweisen. Ein Kurzprompt ist nur gueltig,
wenn er mindestens enthaelt:

- Slice-ID,
- Template-Name,
- Ziel,
- erwartete Dateien oder erlaubte Dateibereiche,
- besondere Grenzen oder Abweichungen,
- klare Nicht-Commit-Regel oder ausdrueckliche separate Commit-Freigabe.

Bei Kurzprompts erbt Codex Pflichtlektuere, M16-T-ID-Abgleich,
Standard-Stop-Regeln, Output-Regeln, Scope-Check, `git status --short`,
`git diff --check`, Commit-Grenzen und External-Write-Grenzen aus 336 und dem
genannten Template. Templates ersetzen 336 nicht und geben keine
Implementierung frei.

Wenn kein Template genannt ist oder die Aufgabe komplex/riskant ist, muss
Codex den passenden Slice-Typ aus 336 ableiten und berichten. Bei unklarer
Template- oder ID-Lage bleibt der Slice Analyse/Review und darf keine
Implementierung starten.

Jeder kuenftige Vollprompt oder aus Template geerbte Arbeitsvertrag fuer
World, Learning, Semantics, Reward, Queue, Companion, Sensitive, Plot, Build,
Container, Assets, Data, App-Integration, Research, Visuals oder Review muss
beruecksichtigen:

- Sprint-ID,
- Ziel,
- betroffene M16-T-IDs,
- Pflichtlektuere,
- wenn Notion, Linear, GitHub, Supabase, API-Keys oder externe Plugins
  betroffen sind: Source-of-Truth-Regel aus `362`, geplante externe Rolle,
  ob nur gelesen/geplant oder geschrieben wird, und ausdrueckliche
  No-Write-Grenze ohne Freigabe,
- Talvori Game Bible aus `talvori_game_bible.md`, wenn
  Produktidentitaet, Sprachschicht, aktive Zielsprache, UI language,
  Companion language, Language Passport, Level/Scaffolding, Internal Corpus,
  Optional Capture, Import/Sharing oder Context Before Vocabulary betroffen
  sind,
- Antwort auf: Welcher Weltkontext wird gebaut oder veraendert, welche
  Sprachschicht und aktive Zielsprache gelten, wie bleiben UI language, target
  language und Companion language getrennt, welche Language-Passport- oder
  Skill-Profil-Annahme gilt, ist Internal Corpus oder Optional Capture
  betroffen, was ist Weltfortschritt vs. Sprachfortschritt und wie werden
  fortgeschrittene Nutzer nicht durch offensichtliche Basics gezwungen?,
- Play-First-Rule aus `345`, wenn MVP, Gameplay, Quest, Challenge, World,
  Companion, UI oder Implementierung betroffen ist,
- Island-First Play Rule aus `345`, wenn MVP, Gameplay, Quest, Challenge,
  World, UI, App-Integration oder Implementierung betroffen ist,
- Antwort auf: Wo auf der Insel, auf dem Plot oder in der Welt-Szene passiert
  der Spielmoment?,
- Interaction Pattern Decision Matrix aus `350`, wenn UI, World, Gameplay,
  App-Integration oder Implementierung mit Interaktion betroffen ist,
- Antwort auf: Welche UI-Art wird genutzt, warum passt sie zur Aktion, warum
  ist sie nicht zu gross oder zu klein und welche Alternative wurde bewusst
  nicht gewaehlt?,
- Starter Island Infrastructure Strategy aus `351`, wenn World, Island, Plot,
  UI, BuildChoice, Unlock, Kategorie-Template oder Starter-Insel-Preview
  betroffen ist,
- Antwort auf: Welche Infrastruktur-Ebene wird beruehrt, ist es fixe
  Infrastruktur, freier Slot, Kategorie-Template, Variante, Unlock oder
  BuildChoice, wird Terrain veraendert oder nur ein Slot genutzt und ist es
  MVP, nach MVP oder blockiert?,
- Starter Island Identity, Biome and Category Scope Gate aus `353`, wenn
  Starter-Insel, Biome, Kategorie-Scope, Terrain-Variante, Future-Island-Family
  oder Insel-Identitaet betroffen ist,
- Antwort auf: Welche Inselidentitaet gilt, welche Kategorie-Templates sind im
  Scope, welche Terrain-Variante wird erzeugt und ist die Entscheidung MVP,
  nach MVP oder blockiert?,
- wenn Kategorie- oder BuildChoice-Scope betroffen ist: Antwort auf, welche
  sichtbaren Nutzerbegriffe gelten, welche internen Systembegriffe dahinter
  liegen, was Hauptkategorie ist und was nur spaetere BuildChoice-Unterauswahl
  bleibt,
- Core Construction Learning Spine aus `355`, wenn Weltfortschritt,
  Spielmoment, BuildChoice, Bau-/Ausbaufortschritt, Raum, Container/Depth oder
  Lernhandlung betroffen ist,
- Antwort auf: Welche Spine-Stufe wird beruehrt, welche Bau-/Ausbau-/
  Weltaktion wird unterstuetzt, welcher sichtbare Fortschritt entsteht, welche
  Lernhandlung erzeugt oder erklaert diesen Fortschritt und warum ist es kein
  isoliertes Lernfenster?,
- First Local Construction-Learning Vertical Slice Gate aus `356`, wenn der
  erste Foundation-/Haus-Vertical-Slice, M16-BK, Grundstueckszoom,
  Fundament-Candidate oder die erste Bauteile-sortieren-Lernhandlung betroffen
  ist,
- Antwort auf: Ist es Insel, Slot, Kategorie, BuildChoice, Grundstueckszoom,
  Bauphase, Lernhandlung oder Feedback, welche sichtbare Bauhandlung entsteht,
  warum ist es kein Lernfenster und welche Stop-Regeln verhindern BuildState,
  Persistenz, Assets, Route und App-Integration?,
- Game-like Island Selection and Construction Camera Flow Gate aus `357`, wenn
  Inselauswahl, Weltansicht, Grundstueckszoom, BuildChoice, Bauphase,
  Bauplatz-HUD, M16-BM oder ein erster Foundation-Codepfad betroffen ist,
- Antwort auf: Ist dies Showcase, Weltansicht, Kamera-Zoom, Bauplatz oder HUD,
  warum dominiert der Spielraum, wie wird Text reduziert, welche erfolgreichen
  Spielmuster wurden uebertragen und warum ist es nicht Formular, Flow-Chart
  oder Lernfenster?,
- Fun, Adventure, Curiosity and Reward Gameplay Spine Gate aus `358`, wenn
  Gameplay, World, UI, BuildChoice, Learning, Mission, Reward, Hook,
  Spielspannung oder Implementierung betroffen ist,
- Antwort auf: Was ist der Player Hook, was ist die kleine Huerde, welche
  Spielhandlung entsteht, welche Belohnung oder neue Moeglichkeit entsteht,
  warum will der Spieler weitermachen, welche erfolgreichen Spielmuster wurden
  uebertragen und welche Druck-/FOMO-/Pay-to-Win-Muster wurden verworfen?,
- Successful Game Pattern Translation for Talvori Construction Play aus `359`,
  wenn Spielhandlung, Bauaufgabe, Puzzle, Mission, Belohnung, Object-first-Flow
  oder Button-Quiz-Risiko betroffen ist,
- Antwort auf: Was sieht der Spieler vor dem Text, was ist das sichtbare
  Problem, welches Objekt wird manipuliert, was veraendert sich sichtbar,
  welche neue Moeglichkeit entsteht und warum ist es kein Button-Quiz?,
- Character-Assisted World Action Rule aus `360`, wenn Figur, Worker,
  Tali/Vori, Objektaktion, Bauhandlung, Reparatur, Sammeln, Tragen, Oeffnen,
  Werkstatt/Crafting oder Container betroffen ist,
- Antwort auf: Auftrag oder direkte Steuerung, welche Figur oder welches
  Objekt handelt sichtbar, welche Arbeitsbewegung entsteht, welche
  Weltveraenderung entsteht, welche neue Moeglichkeit entsteht und warum wird
  kein Movement-/Pathfinding-Scope geoeffnet?,
- Local Construction Preview Boundary and Flow Rejoin Gate aus `361`, wenn
  ein isolierter Proof, BQ-Muster, Uferhain/Slot/BuildChoice/Kamera-Fokus oder
  object-based Worker-Bauplatzmoment wieder in einen lokalen Flow verbunden
  wird,
- Antwort auf: Welcher isolierte Proof wird verbunden, was bleibt Preview und
  was bleibt blockiert, welche Datei darf geaendert werden, wird BQ als
  Muster, Kopie, Import oder Referenz genutzt, warum entsteht keine
  App-Integration, Route, Navigation, Persistenz oder BuildState?,
- Professional Island Build Flow Design Gate aus `363`, wenn komplexer
  Island-/World-/Slot-/BuildChoice-/Kamera-Code, ein Rejoin-Flow, ein
  Build-Wheel, eine Karte mit Pan/Zoom oder ein visueller Island-Build-Flow
  betroffen ist,
- Antwort auf: Ist Flow, Wireflow, BuildChoice-Pattern, Kamera-/Gestenmodell,
  Slotanzahl, Copy, Visual-QA und erlaubter Folge-Datei-Scope vor Code
  geklaert; wenn nein, muss zuerst ein Design-/Wireflow-Slice entstehen?,
- Modern Mobile Game Direction Board aus `365`, wenn High-Fidelity-Flow,
  neuer Wireflow, Rejoin-Code oder komplexer Island-/Slot-/BuildChoice-/
  Kamera-Code nach dem gestoppten M16-BX betroffen ist,
- Antwort auf: Ist die moderne Talvori Game-DNA akzeptiert, wird BuildChoice
  als Build Station am Slot statt Bottom-Sheet/List/Labelwolke behandelt,
  basiert der naechste Schritt auf der konzeptionellen M16-BY-Richtung und
  nicht auf dem abgelehnten v2-Board, welche Patterns wurden wegen Schul-/
  Worksheet-/Menue-Gefuehl verworfen und warum basiert Folge-Code nicht nur
  auf abgelehntem Low-Fidelity-Wireflow, v1-Uebergangsboard oder
  v2-Zwischenvorschau?,
- AI Art Production Pipeline aus `366`, wenn KI-Bilder, Referenzbilder,
  Spielgrafiken, Style Bible, Master References, Asset-Familien,
  Engine-ready Export, Art Direction oder Bildkonsistenz betroffen sind,
- Antwort auf: Was ist nur Art-Direction-Reference, was ist Style Reference,
  was ist Structure Reference, welches Tool generiert, was wird manuell
  nachbearbeitet, welche QA prueft Stilbruch, welche Metadaten sind noetig
  und warum entsteht noch kein finales Asset unter `assets/`?,
- Antwort auf: Warum zeichnet Codex keine hochwertigen Spielbilder nach und
  warum sind freie Einzelprompts keine Produktionspipeline?,
- Talvori Art Bible v1 aus `367`, wenn visuelle Qualitaet, Kamera,
  Perspektive, Diorama-Stil, Figuren, Worker, Tali/Vori, Gebaeude, Bauphasen,
  Build Station, UI/HUD, Bubbles, mobile Lesbarkeit, Asset-Familien oder
  M16-CB/M16-CC betroffen sind,
- Antwort auf: Welche Art-Bible-Regel gilt fuer Kamera, Perspektive, Licht,
  Farbe, Formensprache, Detailgrad, Figuren, Build Station, HUD und
  Asset-Familien; warum ist 367 nur Style-System-Gate und keine Asset-,
  App-Screen-, Code- oder Implementierungsfreigabe?,
- Starter Island Master Reference Set aus `368`, wenn Starter-Insel/Uferhain,
  Build Station, Haus-Bauphasen, Worker/Tali/Vori, UI/HUD/Bubbles,
  Slot/Marker/Layer, Master References oder M16-CC betroffen sind,
- Antwort auf: Welche Master-Reference-Briefs gelten, warum sind sie nur
  Reference-Briefs und keine Bilder, Assets, App-Screens oder Code, wie bleibt
  Uferhain eine Kuestenhain-/Flussufer-Starterinsel, wie bleiben Slots
  neutral, Build Station weltlich und Layerbarkeit vorbereitet?,
- Asset Family and Export Spec aus `370`, wenn Asset-Familien,
  Exportformate, Layer, Groessen/Skalierung, Benennung,
  Source-/Prompt-/Reference-Metadaten, QA-Status, Engine-ready Candidates,
  Dateien unter `assets/` oder ein Folge-Asset-Gate betroffen sind,
- Antwort auf: Welche Asset-Familie und welches Status-Level gilt, warum
  entstehen noch keine Dateien, Assets, Bilder oder Engine-ready Candidates,
  welche Export-, Layer-, Groessen-, Benennungs-, Metadaten- und QA-Regeln
  greifen und warum bleibt ein eigenes Asset-Gate vor Produktintegration
  zwingend?,
- Starter Island Asset Candidate Gate aus `371`, wenn ein erster
  Starter-Island-Candidate, `island_base`, M16-CF, Candidate-Erzeugung,
  Starter-Insel-Pfadgrenzen oder Asset-Familien-Reihenfolge betroffen ist,
- Antwort auf: Warum ist `island_base` die erste Candidate-Familie, warum
  warten `terrain_layers`, `slot_markers`, `build_stations` und
  `building_phases`, welche Tool-/Source-/Metadaten-/QA-/Pfadgrenzen gelten,
  ob M16-CF echte Candidate-Erzeugung ausdruecklich erlaubt oder weiter
  blockiert und warum bleiben Engine-ready Candidates, `assets/` und
  Produktintegration geschlossen?,
- Starter Island Base Candidate Generation Gate aus `372`, wenn M16-CG,
  `island_base`-Bildgenerierung, erlaubter Dokumentationspfad, Dateinamen,
  Tool-Rollen, Prompt/Negative Prompt, Pflichtmetadaten oder Uferhain-QA
  betroffen sind,
- Antwort auf: Erlaubt der aktuelle Prompt wirklich Bilder und den
  Dokumentationspfad aus 372, welche Dateinamen sind erlaubt, welche
  Prompt-/Negative-Prompt-Regeln gelten, welche Metadaten und QA werden
  geschrieben, warum ist der Status maximal `asset_candidate`, und warum
  bleiben `engine_ready_candidate`, `approved_asset`, `assets/`, Flutter und
  App-Integration blockiert?,
- wenn die UI-/Spielaufbau-Entscheidung unklar ist: Antwort auf, ob Research
  noetig war, welche Benchmark-Muster geprueft wurden, welche Spiel-/UI-Logik
  als Vorbild diente, warum das gewaehlte Muster passt und warum Alternativen
  verworfen wurden,
- erwartete Dateien,
- Non-Goals,
- Stop-Regeln,
- Checks,
- klare Nicht-Commit-Regel oder separate Commit-Freigabe,
- Update von `docs/world_design/328-talvori-learning-game-readiness-todo-checklist.md`,
  wenn M16-T-IDs geaendert, erledigt, teilweise erledigt, blockiert oder
  ausgelagert werden.

Wenn ein Prompt keine betroffenen M16-T-IDs nennt, muss Codex sie aus 328
ableiten und im Abschluss berichten. Wenn die ID-Lage unklar ist, bleibt der
Slice ein Planungs-/Audit-Slice und darf keine Implementierung freigeben.

## 7. Output-Regel fuer kuenftige Codex-Ausgaben

Jede kuenftige Codex-Ausgabe muss berichten:

- genutztes Template, falls ein Kurzprompt oder Template-System verwendet
  wurde,
- welche Regeln aus 336 und Template geerbt wurden,
- erstellte/geaenderte Dateien,
- geaenderte M16-T-IDs,
- neuer Fortschritt, wenn 328 geaendert wurde,
- welche IDs erledigt, teilweise erledigt, unveraendert offen, blockiert oder
  ausgelagert bleiben,
- Visual-QA-Ergebnis, wenn PNGs erzeugt wurden,
- Stop-Regel-Nachweis,
- Ergebnis von `git diff --check`,
- Ergebnis von `git status --short`,
- bei unklaren UI-/Spielaufbau-Entscheidungen: ob Research noetig war,
  welche Benchmark-Muster geprueft wurden, warum das gewaehlte Muster passt
  und warum Alternativen verworfen wurden,
- bei Projektmanagement-/External-Tool-Sync-Slices: Source-of-Truth-Regel,
  Notion-/Linear-/GitHub-Mapping, Plugin-Write-Regeln, ob externe Writes
  blockiert blieben und welcher Repo-Commit oder welches Repo-Dokument die
  Wahrheit traegt,
- bei Art-/Asset-/AI-Art-/Master-Reference-Slices: relevantes Asset-Status-
  Level, betroffene Asset-Familien, angewendete Style-/Master-/Export-Regeln,
  ob 370 greifen musste, warum keine echten Assets oder Engine-ready
  Candidates entstanden sind und welches eigene Asset-Gate vor
  Produktintegration noetig bleibt,
- bei Produktidentitaet, Sprachschicht, aktiver Zielsprache, Language
  Passport, Internal Corpus, Optional Capture oder Context Before Vocabulary:
  relevanter Game-Bible-Bezug, aktive Zielsprache, UI-/target-/Companion-
  Sprachtrennung, Weltfortschritt-vs-Sprachfortschritt und Scaffolding fuer
  Beginner, Advanced oder Very Advanced,
- bei Gameplay-/World-/BuildChoice-/Learning- oder Implementierungs-Slices:
  Player Hook, kleine Huerde, Spielhandlung, Belohnung/neue Moeglichkeit,
  naechster freiwilliger Hook und blockierte Druckmuster,
- bei Bauaufgaben, Puzzles, Missionen oder Belohnungen: sichtbares Problem vor
  Text, manipuliertes Objekt, sichtbare Weltveraenderung, neue Moeglichkeit und
  Button-Quiz-Abgrenzung,
- bei Figur-/Worker-/Tali/Vori- oder Objektaktionen: Auftrag-vs-direkte-
  Steuerung, sichtbare Arbeitsbewegung, Weltveraenderung, neue Moeglichkeit
  und Movement-/Pathfinding-Abgrenzung,
- Scope-Check gegen `lib/`, `assets/`, `test/` und `integration_test/`, wenn
  der Slice Docs-only bleiben muss.

## 8. Dashboard-Update-Regel

`M16T-DASH-004` wird mit M16-AB operationalisiert.

Nach jedem Slice gilt:

- Wenn M16-T-IDs betroffen sind, muss 328 aktualisiert werden.
- Gesamtzahlen muessen stimmen.
- Bereichs-Dashboard muss fuer betroffene bestehende Bereiche aktualisiert
  werden.
- Neue oder geaenderte IDs muessen im Abschnitt `Aktueller Stand` sichtbar
  werden.
- `Naechste empfohlene IDs` muessen nach der neuen Lage aktualisiert werden.
- Wenn keine ID geaendert wird, muss der Abschluss explizit sagen, dass 328
  unveraendert bleibt.

## 9. Commit-/Review-Regel

`M16T-GIT-001` und `M16T-GIT-002` werden mit M16-AB operationalisiert.

Vor jedem Commit:

- `git status --short` ausfuehren und berichten.
- `git diff --check` ausfuehren und berichten.
- Scope gegen erwartete Dateien pruefen.
- Bei Docs-only-Slices pruefen, dass `lib/`, `assets/`, `test/` und
  `integration_test/` unveraendert bleiben, ausser der Prompt erlaubt eine
  genau benannte Ausnahme.
- Keine Commit-Freigabe bei unerwarteten Dateien.
- Commit erst nach separater Freigabe.

## 10. Docs sind keine Implementierungsfreigabe

Auch wenn ein Gate, Plan, Prompt-Draft oder Visual dokumentiert ist, ist
dadurch kein Code freigegeben.

Code braucht immer:

- eigenen Implementierungs-Prompt,
- ausdrueckliche Nutzerfreigabe,
- geplante Dateien,
- Stop-Regeln,
- Checks,
- Format-/Analyse-/Testregeln, falls Code betroffen ist,
- Abschlussbericht,
- kein Commit ohne separate Freigabe.

Planungsdocs duerfen Architektur, Scope, Gate-Entscheidung, Visuals und
Prompt-Drafts vorbereiten. Sie duerfen keine App-Route, Persistenz,
SRS-/`word_progress`-Aenderung, automatische Wortplatzierung, Build-State,
Assets, Tests oder App-Integration freigeben.

## 11. Visualisierungen

M16-AB erzeugt Dokumentationsvisualisierungen unter:

`docs/world_design/previews/m16_ab_documentation_map/`

Visuals:

- `documentation_map_overview.png`
- `slice_type_reading_matrix.png`
- `prompt_output_contract.png`
- `dashboard_update_flow.png`
- `commit_review_guardrails.png`
- optional `00_contact_sheet.png`

Diese PNGs sind Dokumentationsmaterial, keine App-Screens, keine Screenshots,
keine Spielassets und keine Dateien unter `assets/`.

Visual-QA:

- Text bleibt in Karten/Rahmen/Panels.
- Ausreichender Innenabstand.
- Kartenabstaende.
- Keine Ueberlappung von Karten, Labels, Pfeilen, Titeln, Footern oder
  Legenden.
- Contact Sheet vollstaendig lesbar, falls erzeugt.
- Keine abgeschnittenen Inhalte.

## 12. Stop-Regeln

Aus M16-AB folgt ausdruecklich:

- Keine App-Integration.
- Keine Route.
- Keine Flutter-/Dart-Codeaenderung.
- Keine Persistenz.
- Keine Supabase/local DB Writes.
- Keine SRS-/`word_progress`-Aenderung.
- Keine automatische Wortplatzierung.
- Kein Build-Wheel-Code.
- Keine Assets oder Asset-Dateien unter `assets/`.
- Kein Build-State.
- Kein `frame_started`.
- Keine Bauzustaende.
- Keine Screenshots als Repo-Artefakte.
- Keine Tests oder Widget-Tests.
- Keine Commit-Ausfuehrung.
