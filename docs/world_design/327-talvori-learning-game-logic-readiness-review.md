# M16-S: Talvori Learning Game Logic Readiness Review

Stand: 2026-06-07

Status: `Dokumentations-/Visual-Audit gestartet / keine Implementierung`

## 1. Ziel

M16-S prueft kritisch, ob Talvori als Lernspiel-, Welt-, Semantik- und
Bau-System konzeptionell bereit fuer weitere Slices ist oder ob vor
produktiven Systemen noch Gates fehlen.

M16-S ist ein reiner Dokumentations- und Visual-Audit-Block. Daraus folgen
keine Flutter-/Dart-Dateien, keine App-Integration, keine Route, keine neue
Seite, keine Tests, keine Screenshots, keine Runtime-Konfiguration, keine
Persistenz, keine Supabase Writes, keine lokalen DB-Writes, keine
SRS-/`word_progress`-Aenderung, keine Reward Bridge, keine automatische
Wortplatzierung, keine Build-Wheel-Implementierung, keine Assets, keine
Asset-Dateien unter `assets/`, kein Build-State, kein `frame_started` und
keine Bauzustaende.

## 2. Gepruefte Grundlage

| Dokument | Beitrag fuer M16-S |
| --- | --- |
| `docs/world_design/235-world-production-roadmap-and-checklists.md` | Zentrale Roadmap, Stop-Regeln, Phasenlogik und Schutz vor App-/Asset-/Persistenzfreigabe. |
| `docs/world_design/270-word-to-island-routing-matrix.md` | Routing macht Vorschlaege, keine automatische Platzierung; Multi-Home, Word-Type und Fallbacks sind Pflicht. |
| `docs/world_design/272-plot-capability-derivation.md` | Plot-Capabilities sind Erlaubnisse, keine Pflichtbelegung; Depth, Adjacency und Risk Flags bleiben gated. |
| `docs/world_design/274-sensitive-content-representation-rules.md` | Sensitive und abstrakte Inhalte brauchen Codex, ContextCard, CompanionDialog, Backlog oder RequiresUserChoice. |
| `docs/world_design/276-mobile-clutter-rules-small-objects.md` | TinyObjects und ContainerItems duerfen Mobile-Ansichten nicht ueberladen. |
| `docs/world_design/284-word-to-island-ux-flow.md` | Wort -> Sense -> Safety -> Theme/Depth -> User Choice -> Placement/Blueprint/Codex/Backlog. |
| `docs/world_design/318-theme-island-plot-capacity-and-build-wheel-plan.md` | ThemeIsland-Kapazitaet entsteht aus Thema, Plotbedarf, Groessenmix und spaeterem in-place Wheel. |
| `docs/world_design/320-global-theme-island-plot-capacity-matrix.md` | Globale Kategorien verhindern eine zu enge Dorf-/Zuhause-Logik. |
| `docs/world_design/321-global-world-semantics-consistency-audit.md` | Pflichtpipeline fuer Context/Sense, Word-Type, Safety, Representation Decision, User Choice und Later Gate. |
| `docs/world_design/322-next-safe-preview-slice-decision-gate.md` | Empfiehlt WordSemanticsDecisionPreview als sicheren naechsten Preview-Slice. |
| `docs/world_design/323-word-semantics-decision-preview-scope.md` | Konkretisiert Beispielwort-Entscheidungen und sichere Ausgaenge. |
| `docs/world_design/326-scalable-word-semantics-architecture-plan.md` | Skaliert Semantik auf 20.000+ Woerter ueber Profile, Filter, Queues und Fallbacks statt 20.000 Weltobjekte. |
| `assets/images/world/buildable_islands/forest_clearing/template.md` | Waldlichtung bleibt Starter-/Testform; keine Asset-/Appfreigabe und kein `frame_started`. |

## 3. Executive Verdict

| Frage | Urteil | Begruendung |
| --- | --- | --- |
| Solide konzeptionelle Basis? | ja | Taxonomy, Routing, Plot-Capabilities, Sensitive-Regeln, Clutter-Regeln, ThemeIsland-Kapazitaet und skalierbare Semantik sind konsistent dokumentiert. |
| Produktionsreif fuer echte Systeme? | nein | Datenmodell, Persistenz, Reward Bridge, Review Queue, Confidence Scoring, App-Integration, Tests, Accessibility, Performance und Asset Scope fehlen als produktive Gates. |
| Bereit fuer kleine lokale Preview-Slices? | ja, mit engem Scope | Lokale isolierte Previews koennen Guardrails sichtbar machen, solange sie keine App-Route, Persistenz, Assets, Build-State oder automatische Platzierung erzeugen. |
| Bereit fuer produktive Platzierung/Bauen? | nein | Learning-to-World Contract, Reward Bridge und Build-State-Gates fehlen. |

Wichtigste Staerken:

- Talvori hat einen starken Produktkern: Woerter lernen, im Kontext verstehen
  und daraus eine persoenliche Welt aufbauen.
- Die Semantik-Gates verhindern bereits viele Fehlableitungen: Nicht jedes
  Wort wird gebaut, nicht jedes Wort bekommt einen Plot, nicht jedes Wort wird
  sichtbar.
- Die ThemeIsland-Planung ist breiter als Dorf/Zuhause und kann Wasser,
  Farm, Stadt, Schule, Technik, Kultur und sensitive Bereiche unterscheiden.
- Codex, Blueprint, Backlog, ContextCard, ActionChallenge und ContainerItem
  sind als legitime Ausgaenge dokumentiert.
- Mobile-Clutter, Sensitive-Policy, Growth-Fairness und Asset-Scope werden
  bereits als Stop-Gates behandelt.

Wichtigste Blocker:

- Kein produktiver Learning-to-World Contract.
- Keine freigegebene Reward Bridge.
- Keine Persistenz-/Datenmodell-/Migration-Gates.
- Kein Review-Queue-System fuer 20.000+ Woerter.
- Kein Confidence Scoring und keine AI-/Classification-Provider-Governance.
- Keine produktive Build-Wheel-Architektur.
- Keine App-Integration, keine Tests, keine Accessibility- oder Performance-
  Freigabe.
- Kein Asset-Scope fuer echte Weltobjekte oder Bauzustaende.

## 4. Bereichspruefung

| Bereich | Readiness | Bewertung | Wichtigster Gate |
| --- | --- | --- | --- |
| Spielziel und Lernziel | strong | "Meine Woerter bauen eine Welt" ist als North Star klar und bleibt lernorientiert. | Produkt-Loop-Definition vor App-Integration. |
| Core Loop | needs gate | Lernen -> Vorschlag -> Nutzerentscheidung -> Weltfeedback ist plausibel, aber noch nicht produktiv kontrahiert. | Learning-to-World Contract. |
| Lernloop | strong | Bestehende Lern-/SRS-Basis bleibt wertvoll und soll nicht direkt veraendert werden. | Kein SRS-/`word_progress`-Eingriff ohne eigenes Gate. |
| Reward Loop | risky | Reward-Idee ist stark, aber Reward Bridge ist nicht umgesetzt und darf SRS nicht korrumpieren. | Reward Bridge Gate. |
| World/Island Loop | needs gate | ThemeIsland-, Plot- und Capacity-Planung ist gut, aber echte Insel-/Plot-Systeme fehlen. | World Data Model und Integration Gate. |
| Word-to-Island-Logik | strong | Routing macht Vorschlaege, keine automatische Platzierung. | Produktives Routing-Gate. |
| Semantik-Logik | strong | M16-L/R definieren Pflichtpipeline und skalierbare Profile. | Profile/Queue/Confidence Gate. |
| 20.000+-Wort-Skalierung | needs gate | Architekturidee ist klar: Profile, Filter, Queue, Fallbacks. | Datenmodell, Performance, Privacy, Review Queue. |
| ThemeIsland-/Plot-Capacity | strong | Kategorien und Plot-Familien sind breit dokumentiert. | Produktives Plot-Capacity-Gate. |
| Build-Wheel-Idee | risky | In-place Overlay ist sinnvoll, aber leicht als Bau-Freigabe misslesbar. | Build-Wheel UX/Architecture Gate. |
| Container/Depth-System | needs gate | Depth-Regeln sind gut, aber noch keine Architektur oder Runtime. | Container/Depth Implementation Gate. |
| Tali/Vori Companion | needs gate | Companion kann Erklaerungen und Vorschlaege tragen, darf aber nicht entscheiden oder draengen. | Companion Copy/Safety Gate. |
| Motivation/Retention ohne Druck | strong in principle | Fairness-Regeln gegen Schuld, Streak-Druck, Verfall und Pay-to-Win sind dokumentiert. | Reward/Fairness Gate. |
| Mobile-Clutter | strong | TinyObjects, Labels und Container-Objektlisten sind klar begrenzt. | Device/Accessibility Gate. |
| Sensitive/Policy | strong | Sensitive Inhalte werden neutral und optional behandelt. | Sensitive Review Gate. |
| Asset-Scope | needs gate | Assetproduktion ist klar blockiert, aber spaetere Assetfamilien fehlen. | Asset Scope Gate. |
| Technische Architektur | needs gate | Trennung der Domänen ist als Regel vorhanden, aber neue produktive Module fehlen. | Architecture/Boundary Gate. |
| Dokumentationsstand | strong | Die Dokumentation ist reich, aber verteilt und muss pro Prompt als Pflichtfilter gelesen werden. | Pflichtlektüre-Regel. |
| Visuelle Pruefbarkeit | needs gate | PNG-Dokumentationsvisuals sind hilfreich; echte Device-/A11y-Pruefung fehlt fuer produktive UI. | Visual Harness/Device Gate. |

## 5. Kritische Tabellen

### Strong

| Thema | Warum stark | Nutzung fuer naechste Slices |
| --- | --- | --- |
| Word-to-Island Routing | Vorschlag statt Platzierung ist klar. | Jeder Slice startet mit Context/Sense und Word-Type. |
| Plot-Capabilities | Funktionen sind Erlaubnisse, keine Belegung. | Plot-Previews duerfen nur Capability zeigen. |
| Sensitive Rules | Codex/ContextCard/Backlog schlagen sichtbare Symbole. | Sensitive bleibt policy-gated. |
| Mobile-Clutter | Kleine Objekte werden nicht zu Inselmassen. | Container/Depth statt Objektwolken. |
| Scalable Semantics | 20.000+ Woerter werden ueber Profile/Queues gefuehrt. | Keine Massenkarten und keine Massenobjekte. |

### Risky

| Thema | Risiko | Gegenregel |
| --- | --- | --- |
| Reward Loop | Kann als Druck oder als SRS-Mutation wirken. | Reward Bridge getrennt und fair planen. |
| Build-Wheel | Kann wie Bau-/Assetfreigabe wirken. | Wheel nur Preview bis Build/Persist-Gate. |
| ThemeIsland Capacity | Kann als feste Slot-/Gebaeudeliste gelesen werden. | Slots bleiben austauschbar und konfigurierbar. |
| Companion Guidance | Kann zu stark lenken oder sensible Themen dramatisieren. | Neutral, optional, keine Pflichtentscheidung. |
| Growth/Farm | Kann Timer- oder Retention-Druck erzeugen. | Keine Strafe, kein Verfall, kein Pay-to-Win. |

### Missing

| Fehlendes System | Warum es fehlt | Gate vor Produkt |
| --- | --- | --- |
| Learning-to-World Contract | Lernereignisse sind noch nicht formal an Weltreaktionen gebunden. | Contract Gate. |
| Productive Semantic Profile Model | Felder sind Konzept, keine Datenstruktur. | Data Model Gate. |
| Review Queue | 20.000+ Woerter brauchen Queue und Filter. | Review Queue Gate. |
| Confidence Scoring | Automatische Vorschlaege brauchen Schwellen und Unsicherheitslogik. | Confidence Gate. |
| Persistence/Migration | Keine Speicherung ist freigegeben. | DB/Supabase/Migration Gate. |
| Undo/Reversibility | Nutzer muss Welt-/Semantikentscheidungen aendern koennen. | Undo Gate. |

### Too Complex

| Thema | Warum aktuell zu komplex | Sichere Alternative |
| --- | --- | --- |
| Produktives Build-Wheel | Koppelt Slot, Kandidat, Asset, Build-State und Persistenz. | Nur Dokumentations-/Preview-Plan. |
| Automatische Wortplatzierung | Wuerde Semantik, Safety, Clutter und User Choice umgehen. | Vorschlaege und Fallbacks. |
| Wasser-/Hafen-System | Braucht Water, Dock, Boat, Travel und Mobile-Regeln. | Kategorieprofil/Preview ohne Systemlogik. |
| Farm/Growth-System | Braucht Timer-Fairness und Produktionsgrenzen. | Kein Growth ohne Gate. |
| Sensitive ThemeIslands | Brauchen Policy, Privacy, Opt-in und neutrale Darstellung. | Codex/ContextCard/Backlog. |

### Blocked Before Product Systems

| Blocker | Grund | Was muss vorher passieren? |
| --- | --- | --- |
| Persistenz | Kein Datenmodell, keine Migration, keine Datenschutzentscheidung. | Data/Persistence Gate. |
| Reward Bridge | Darf SRS/`word_progress` nicht veraendern. | LearningResult Contract und Tests. |
| Build-State | Kein `frame_started`, keine Bauzustaende. | Build-State Gate. |
| Assets | Keine Assetfamilien oder Scope-Freigaben. | Asset Scope und Visual QA. |
| App-Integration | Lokale Previews sind nicht produktive Screens. | Navigation/App Gate. |
| Supabase Writes | Ohne explizite Freigabe verboten. | Backend/Data Safety Gate. |

### Safe Next Steps

| Safe Step | Warum sicher | Grenzen |
| --- | --- | --- |
| Weitere Docs-/Visual-Audits | Schaerft Regeln ohne Produktwirkung. | Keine Implementierung. |
| Lokale isolierte Preview-Slices | Machen eine Regel sichtbar. | Keine Route, keine Persistenz, keine Assets. |
| Code-Review vorhandener Previews | Prüft Scope und Copy. | Keine Integration. |
| Visual Harness Plan | Bereitet Device-Pruefung vor. | Keine Tests/Screenshots ohne Freigabe. |
| Prompt-Draft fuer enges Gate | Verhindert Scope Drift. | Nicht ausfuehren ohne Freigabe. |

## 6. Learning-to-World Contract

Dieser Vertrag ist noch nicht produktiv implementiert. Er definiert nur, was
spaeter sicher unterschieden werden muss.

| Lernereignis | Erlaubte Weltreaktion spaeter | Blockierte Reaktion jetzt |
| --- | --- | --- |
| Wort gelernt | Codex-Fortschritt, semantischer Vorschlag, Review-Queue-Eintrag | sichtbares Objekt, Plot, Gebaeude, Build-State |
| Uebung abgeschlossen | sanftes Feedback, moeglicher Reward-Vorschlag | direkte Ressource mit Persistenz, SRS-Mutation |
| Wort importiert | Semantic Profile Kandidat, Context/Sense-Check | automatische ThemeIsland- oder Plotplatzierung |
| Satz/Context erkannt | bessere Sense-Kandidaten | finale Zuordnung ohne Nutzerentscheidung |
| Nutzer bestaetigt Vorschlag | Preview Candidate oder Blueprint vormerken | Build/Persistenz ohne Gate |
| Sensitive Wort erkannt | Codex/ContextCard/Backlog/Policy Gate | Symbol, Gebaeude, Reward, Druckmechanik |

Pflichtregeln:

- Keine automatische Wortplatzierung.
- Kein Build-State.
- Keine SRS-/`word_progress`-Aenderung.
- Keine direkte Kopplung von Lernlogik und Renderer.
- Weltreaktion bleibt Vorschlag, Preview oder Fallback, bis ein eigenes Gate
  echte Persistenz, Reward Bridge oder Build-State erlaubt.

## 7. Minimal Word Outcome Taxonomy

| Outcome | Bedeutung | Typische Beispiele | Stop-Regel |
| --- | --- | --- | --- |
| `CodexOnly` | Wort bleibt neutral erklaert, ohne Weltobjekt. | Angst, Gerechtigkeit, digitales Konzept | Keine sichtbare Platzierung. |
| `WorldCandidate` | Wort koennte spaeter sichtbar werden. | Haus, Baum, Garage nach Kontext | User Choice und Gate erforderlich. |
| `ContainerItem` | Kleines Objekt gehoert in Container/Depth. | Loeffel, Bleistift, Messer nach Safety | Nicht dauerhaft in IslandView. |
| `ActionChallenge` | Verb/Aktion wird als Aufgabe oder Sequenz gedacht. | schwimmen, lernen, kochen | Kein statisches Objekt. |
| `ContextCard` | Kontext, Sense oder sensibles Thema wird erklaert. | Polizei, Gesundheit, Freiheit | Keine Symbolpflicht. |
| `SensitiveGated` | Inhalt bleibt policy-gated. | Religion, Gericht, Notfall, Krieg | Keine automatische Visualisierung. |
| `NeedsUserChoice` | Mehrdeutigkeit oder Multi-Home braucht Entscheidung. | Haus, Bank, Garage, Baum | Kein Default als finale Platzierung. |

## 8. Reward ohne Druck

Reward darf Lernmotivation staerken, aber nicht bestrafen.

Erlaubt als Planungsrichtung:

- Lernen fuehrt zu sanftem Fortschrittssignal.
- Tali/Vori darf relevante Vorschlaege anbieten.
- Nutzer darf freiwillig entscheiden.
- Weltfeedback bleibt klein, reversibel und gated.
- Pausen duerfen Rueckkehr erleichtern.
- Sichtbare Weltveraenderung erfolgt nur nach Gate.

Nicht erlaubt:

- Strafmechaniken.
- Automatische Weltstrafe.
- Pflichtentscheidung nach jeder Lerneinheit.
- Streak-Schuld.
- Verfall oder Ruinen als Druck.
- Sensitive Themen als Retention-Trigger.
- Paywall vor erstem Wow-Moment.

## 9. Produktive-Systeme-Gates

Vor echten produktiven Systemen braucht Talvori eigene Gates fuer:

| Gate | Warum erforderlich |
| --- | --- |
| Datenmodell | `WordSemanticProfile`, WorldCandidate, Blueprint und ReviewQueue sind noch Konzepte. |
| Persistenz | Speicherung braucht Datenschutz, Migration und Undo. |
| Lokale DB/Supabase | Keine Writes ohne explizite Freigabe und Safety-Plan. |
| Migration | Bestehende SRS-/`word_progress`-Semantik darf nicht korrumpiert werden. |
| Offline/Sync | Talvori bleibt offline-first relevant; Konflikte muessen geloest werden. |
| Confidence Scoring | Automatische Profile brauchen Schwellen und Unsicherheitsausgaenge. |
| Review Queue | Nutzer darf nicht mit 20.000 Entscheidungen belastet werden. |
| Sensitive Review | Policy, Privacy, Opt-in und neutrale Darstellung sind Pflicht. |
| Undo/Reversibility | Nutzer muss Sense, Insel, Fallback oder Preview spaeter aendern koennen. |
| App-Integration | Lokale Previews sind keine produktiven Routen. |
| Tests/Accessibility/Performance | Produktive Systeme brauchen Analyse, Tests, Mobile/A11y und Lastpruefung. |
| Asset Scope | Kein Wort erzeugt automatisch ein Asset. |
| Keine automatische Platzierung | Vorschlag bleibt Vorschlag, bis User Choice und Gate passen. |

## 10. Readiness-Entscheidung

M16-S bewertet Talvori als konzeptionell stark, aber nicht produktionsreif.

Entscheidung:

- Weitere kleine lokale Preview-Slices sind sinnvoll, wenn sie genau ein
  Konzept sichtbar machen und Stop-Regeln einhalten.
- Produktive Systeme fuer Reward, Semantik, World Placement, Build-Wheel,
  Persistenz, Assets oder App-Integration bleiben blockiert.
- Vor jedem produktiven Schritt muss ein Gate den Learning-to-World Contract,
  Word Outcome Taxonomy, Review Queue, Sensitive/Clutter/Fairness-Regeln und
  Undo/Reversibility pruefen.

## 11. Dokumentationsvisualisierungen

M16-S ergaenzt echte PNG-Dokumentationsvisualisierungen unter:

`docs/world_design/previews/m16_s_learning_game_readiness/`

Erzeugte Visuals:

- `learning_to_world_contract.png`
- `semantic_scaling_funnel.png`
- `readiness_risk_matrix.png`
- `reward_loop_without_pressure.png`
- `productive_system_gate_map.png`
- optional `00_contact_sheet.png`

Diese PNGs sind Dokumentationsmaterial. Sie sind keine App-Screens, keine
Screenshots, keine finalen UI-PNGs, keine Spielassets und keine Dateien unter
`assets/`.

Visual-Quality-Regel:

Alle M16-S-Visuals muessen Text-Containment, Innenabstand, Kartenabstand,
ueberlappungsfreie Karten, Labels, Pfeile, Titel, Footer und Legenden,
lesbares Contact Sheet sowie nicht abgeschnittene Inhalte pruefen.

## 12. Stop-Regeln

Aus M16-S folgt ausdruecklich:

- Keine App-Integration.
- Keine Route.
- Keine Flutter-Codeaenderung.
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

## 13. Fortlaufende Checkliste

Die aus M16-S abgeleitete fortlaufende Checkliste liegt in
`docs/world_design/328-talvori-learning-game-readiness-todo-checklist.md`.
