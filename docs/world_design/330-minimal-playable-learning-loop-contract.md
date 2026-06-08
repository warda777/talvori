# M16-V: Minimal Playable Learning Loop Contract

Stand: 2026-06-08

Status: `Dokumentations-/Visual-Slice gestartet / keine Implementierung`

## 1. Ziel

M16-V definiert den ersten kleinen spielbaren Talvori-Lernloop fachlich, bevor
weiterer Code entsteht. Der Contract verbindet Lernen, Semantik, Reward,
Review Queue und minimales Weltfeedback so, dass ein spaeterer MVP-Slice klein
bleibt und keine automatische Wortplatzierung, keinen Build-State und keine
Persistenz erzeugt.

M16-V ist nur Dokumentation und Visualisierung. Daraus folgen keine Flutter-/
Dart-Dateien, keine App-Integration, keine Route, keine neue Seite, keine
Tests, keine Screenshots, keine Runtime-Konfiguration, keine Persistenz, keine
Supabase Writes, keine lokalen DB-Writes, keine SRS-/`word_progress`-
Aenderung, keine Reward Bridge, keine automatische Wortplatzierung, kein
Build-Wheel-Code, keine Assets, keine Asset-Dateien unter `assets/`, kein
Build-State, kein `frame_started` und keine Bauzustaende.

## 2. Gepruefte Grundlage

| Dokument | Bedeutung fuer M16-V |
| --- | --- |
| `docs/world_design/327-talvori-learning-game-logic-readiness-review.md` | Readiness Review: solide Basis, aber produktive Systeme brauchen Gates. |
| `docs/world_design/328-talvori-learning-game-readiness-todo-checklist.md` | Fuehrende ToDo-/Gate-Liste und Fortschrittsdashboard. |
| `docs/world_design/329-talvori-product-delivery-dashboard-and-scrum-lite.md` | MVP-Ziel, Scrum-lite-Modell und Product-Backlog-Regeln. |
| `docs/world_design/326-scalable-word-semantics-architecture-plan.md` | 20.000+ Woerter werden Profile/Queues/Fallbacks, nicht 20.000 Weltobjekte. |
| `docs/world_design/323-word-semantics-decision-preview-scope.md` | Beispielwort-Pipeline und sichere Representation Outcomes. |
| `docs/world_design/321-global-world-semantics-consistency-audit.md` | Pflichtpipeline von Context/Sense bis User Choice und Later Gate. |
| `docs/world_design/284-word-to-island-ux-flow.md` | Word-to-Island UX: Vorschlag, User Choice, Codex/Blueprint/Backlog. |
| `docs/world_design/274-sensitive-content-representation-rules.md` | Sensitive Inhalte bleiben neutral, optional und policy-gated. |
| `docs/world_design/276-mobile-clutter-rules-small-objects.md` | TinyObjects und ContainerItems duerfen Mobile-Ansichten nicht ueberladen. |

## 3. Betroffene M16-T-IDs

| ID | M16-V Entscheidung | Grund |
| --- | --- | --- |
| `M16T-MVP-004` | `[x]` | Minimal spielbarer Lernloop ist als Contract, Loop und Visuals definiert. |
| `M16T-PROD-001` | `[x]` | Produktanker fuer World-/Learning-Slices ist formuliert. |
| `M16T-PROD-002` | `[x]` | Lernziel, Spielziel und Weltfeedback sind getrennt. |
| `M16T-PROD-003` | `[~]` | Welt-dient-Lernen-Regel ist dokumentiert, muss aber in spaeteren Slices weiter angewendet werden. |
| `M16T-CORE-001` | `[x]` | Minimaler Core Loop ist dokumentiert und visualisiert. |
| `M16T-CORE-002` | `[x]` | Event-Trennung fuer Lern-, Semantik-, Reward-, Weltfeedback- und Persistenzereignis ist definiert. |
| `M16T-CORE-003` | `[~]` | UI-Event-Regel ist im Contract enthalten, muss aber in relevanten Implementierungs-Slices wiederholt werden. |
| `M16T-L2W-001` | `[x]` | Eigener Learning-to-World Contract liegt vor. |
| `M16T-L2W-002` | `[x]` | Lernfortschritt erzeugt Moeglichkeit, keine Platzierung. |
| `M16T-L2W-003` | `[~]` | Weltreif-Kriterien sind geplant, brauchen spaeter operative Gates. |
| `M16T-WOT-001` | `[x]` | Minimal Word Outcome Taxonomy fuer MVP ist als fuehrende Liste definiert. |
| `M16T-REWARD-001` | `[x]` | Reward-ohne-Druck-Prinzip ist verbindlich fuer den Minimal-Loop dokumentiert. |
| `M16T-QUEUE-001` | `[x]` | Minimale Review Queue ist als MVP-Konzept dokumentiert. |

## 4. Produktanker fuer den minimal spielbaren Lernloop

Produktanker:

> Talvori hilft dem Nutzer, ein Wort im Kontext zu lernen, daraus einen
> sicheren freiwilligen Weltvorschlag zu verstehen und ein kleines reversibles
> Weltfeedback zu erleben, ohne dass Lernen automatisch baut, platziert oder
> speichert.

Kurzform:

> Lernen oeffnet Moeglichkeiten. Der Nutzer entscheidet. Die Welt reagiert
> klein, sanft und reversibel.

Dieser Produktanker uebersetzt "Meine Woerter bauen eine Welt" in eine sichere
MVP-Regel: Woerter koennen Weltmoeglichkeiten erzeugen, aber nie automatisch
Weltobjekte, Bauzustaende, Persistenz oder Druck.

## 5. Lernziel, Spielziel und Weltfeedback

| Ebene | Ziel | Darf ausloesen | Darf nicht ausloesen |
| --- | --- | --- | --- |
| Lernziel | Wort verstehen, wiederholen und im Kontext anwenden. | Lernereignis, Semantikpruefung, optionaler Vorschlag. | Build-State, Platzierung, Persistenz, SRS-Mutation aus UI. |
| Spielziel | Die eigene Talvori Welt durch sinnvolle, freiwillige Entscheidungen wachsen sehen. | Review-Queue-Entscheidung, Preview/Fallback, spaeter gated Weltfeedback. | Pflichtentscheidung, Retention-Druck, automatische Belohnungsplatzierung. |
| Weltfeedback | Sichtbar machen, dass Lernen etwas ermoeglicht hat. | Kleines reversibles Signal, Candidate, Codex/Backlog/ContextCard. | Gebaeude, Bauzustand, `frame_started`, Asset, permanente Aenderung ohne Gate. |

Regel:

Die Welt dient dem Lernen. Sie ersetzt den Lernloop nicht und darf
Lernfortschritt nicht durch reine UI-Interaktion vortaeuschen.

## 6. Minimaler Core Loop

Der erste spielbare Loop darf fachlich nur diese Reihenfolge haben:

1. Nutzer lernt oder wiederholt ein Wort.
2. Ein Lernereignis entsteht.
3. Semantik prueft den Word Outcome.
4. Das System erzeugt einen sicheren Vorschlag oder Fallback.
5. Der Nutzer entscheidet freiwillig oder verschiebt.
6. Die Welt reagiert minimal und reversibel.
7. Tali/Vori erklaert optional, kurz und ohne Druck.

Nicht in diesem Loop:

- kein Build-Wheel,
- kein Build-State,
- keine echte Platzierung,
- keine Persistenz,
- keine App-Integration,
- keine SRS-/`word_progress`-Aenderung,
- keine Assets,
- keine automatische Wortplatzierung.

## 7. Event-Trennung

| Ereignis | Entsteht durch | Erlaubter naechster Schritt | Blockiert |
| --- | --- | --- | --- |
| Lernereignis | Uebung, Wiederholung, Import- oder Kontextlernhandlung | Semantikereignis vorbereiten, ohne SRS-Semantik zu veraendern. | direkte Weltplatzierung, Build-State, Persistenz. |
| Semantikereignis | Context/Sense, Word Type, Safety und Outcome-Pruefung | sicherer Vorschlag, Fallback oder Review-Queue-Eintrag. | finale Routing-Implementierung, automatische Platzierung. |
| Reward-Ereignis | spaeterer Reward-Vorschlag nach Lernereignis | sanftes Fortschrittssignal oder freiwillige Entscheidung. | Strafe, Pflichtentscheidung, BuildState, `frame_started`. |
| Weltfeedback-Ereignis | Nutzer bestaetigt oder verschiebt einen Vorschlag | kleines reversibles Feedback, Preview Only, Codex/Backlog/ContextCard. | permanente Weltveraenderung ohne Gate. |
| Persistenz-Ereignis | spaeteres eigenes Daten-/Persistenz-Gate | noch blockiert. | Supabase/local DB Writes, Migration, SRS-/`word_progress`-Aenderung. |

UI-Events wie Tap, Hover, Auswahl oder Preview duerfen allein keinen
Lernfortschritt, keinen Reward, keine Persistenz und keinen Build-State
erzeugen.

## 8. Learning-to-World Contract

### Erlaubte Beziehung

```text
Lernfortschritt
-> Semantikpruefung
-> sicherer Vorschlag oder Fallback
-> freiwillige Nutzerentscheidung
-> minimales reversibles Weltfeedback
```

### Verbotene Beziehung

```text
Lernfortschritt
-> automatische Platzierung
-> Build-State
-> Persistenz
```

Pflichtregeln:

- Lernfortschritt erzeugt eine Moeglichkeit, keine automatische Platzierung.
- Kein Lernereignis darf direkt Build-State, Placement oder Persistenz
  erzeugen.
- Kein Reward-Ereignis darf direkt `PlacementCandidate`, `BuildState` oder
  `frame_started` schreiben.
- Keine SRS-/`word_progress`-Aenderung ohne eigenes Gate.
- Weltfeedback bleibt klein, reversibel und als Preview/Fallback lesbar.
- Sensitive, mehrdeutige, abstrakte oder kleine Woerter gehen in sichere
  Outcomes, bis Context, User Choice und Gate passen.

## 9. "Weltreif" fuer den MVP

Ein Wort ist fuer sichtbares Weltfeedback im MVP nur als Vorschlag weltreif,
wenn alle Kriterien erfuellt sind:

| Kriterium | Mindestanforderung |
| --- | --- |
| Sense / Kontext | Bedeutung ist klar genug oder landet in `NeedsUserChoice`. |
| Word Type | Nomen, Aktion, Emotion, TinyObject, Sensitive usw. sind unterschieden. |
| Safety | Sensitive-/Policy-Risiko ist geprueft. |
| Clutter | TinyObjects und ContainerItems gehen nicht automatisch in IslandView. |
| Outcome | Ein MVP-Outcome ist gewaehlt: CodexOnly, WorldCandidate usw. |
| Nutzerentscheidung | Sichtbare Weltreaktion bleibt freiwillig und verschiebbar. |
| Gate | Build, Persistenz, Asset, Route und `frame_started` bleiben blockiert. |

Wenn ein Kriterium fehlt, ist der sichere Ausgang `CodexOnly`, `ContextCard`,
`Backlog`, `NeedsUserChoice` oder `SensitiveGated`.

## 10. Minimal Word Outcome Taxonomy fuer MVP

| Outcome | Bedeutung | MVP-Verhalten | Blockiert |
| --- | --- | --- | --- |
| `CodexOnly` | Wort wird neutral erklaert und gelernt, ohne Weltobjekt. | Codex/Erklaerung oder spaeterer Kontext. | sichtbare Platzierung. |
| `WorldCandidate` | Wort koennte spaeter Weltfeedback tragen. | Vorschlag mit User Choice und Later Gate. | automatisches Bauen oder Platzieren. |
| `ContainerItem` | Kleines Objekt gehoert eher in Container/Depth. | Container-/Depth-Fallback, Codex oder Backlog. | TinyObject in IslandView. |
| `ActionChallenge` | Verb/Aktion wird Aufgabe, Sequenz oder Kontext. | freiwillige Challenge-Idee oder ContextCard. | Verb als statisches Objekt. |
| `ContextCard` | Kontext, Sense oder abstrakte Bedeutung wird erklaert. | kurze Karte, Tali/Vori optional. | Symbolpflicht oder Deko-Zwang. |
| `SensitiveGated` | Inhalt braucht Policy/Opt-in/Safety. | neutraler Codex, ContextCard oder Backlog. | Reward, Druck, Symbol, Gebaeude. |
| `NeedsUserChoice` | Mehrdeutigkeit oder Multi-Home braucht Entscheidung. | Review Queue mit Later/Codex/Backlog/Confirm/Change. | Default-Kategorie als finale Platzierung. |

Diese Taxonomy ist fuer den MVP fuehrend, aber keine finale Datenstruktur und
keine Routing-Implementierung.

## 11. Reward ohne Druck

Reward im Minimal-Loop bedeutet:

- Lernen darf ein kleines positives Signal erzeugen.
- Talvori darf einen sinnvollen Vorschlag anbieten.
- Nutzer darf entscheiden, verschieben oder neutral im Codex lassen.
- Weltfeedback bleibt klein, reversibel und gated.
- Pausen werden sanft aufgefangen.

Nicht erlaubt:

- Strafe,
- Verfall,
- Streak-Schuld,
- Pflichtentscheidung nach jeder Lerneinheit,
- sensible Retention-Trigger,
- Weltstrafe,
- Build-State,
- automatische Platzierung,
- Paywall vor dem ersten Wow-Moment.

Reward ist nicht dasselbe wie Placement. Reward ist auch nicht dasselbe wie
BuildState. Der MVP braucht diese Trennung, bevor eine Reward Bridge spaeter
ueberhaupt freigegeben werden kann.

## 12. Minimale Review Queue

Die MVP-Review-Queue ist klein, selten und fokussiert.

Nicht:

- 20.000 Entscheidungen,
- Pflichtreview nach jeder Lerneinheit,
- Massenliste,
- automatische Weltplatzierung.

Sondern:

- nur wenige relevante Entscheidungen pro Session,
- priorisiert nach Risiko, Lernrelevanz und Unsicherheit,
- Tali/Vori darf optional erklaeren,
- Nutzer kann spaeter aendern.

Minimale Queue-Ausgaenge:

| Ausgang | Wirkung |
| --- | --- |
| `Later` | Entscheidung verschieben; keine Weltwirkung. |
| `Codex` | sicherer Lern-/Erklaerpfad ohne sichtbares Objekt. |
| `Backlog` | fuer spaeter vormerken, wenn Gate oder Kontext fehlt. |
| `Confirm` | Vorschlag als Preview/Fallback bestaetigen, noch kein Build. |
| `Change` | andere Bedeutung, Kategorie oder Outcome waehlen. |

Die Queue darf kein Build-Wheel, keine Persistenz und keinen `frame_started`
erzeugen.

## 13. Tali/Vori im Minimal-Loop

Tali/Vori ist im MVP-Loop optionaler Begleiter, nicht Entscheidungsautomat.

Erlaubt:

- kurz erklaeren, warum ein Wort `CodexOnly`, `NeedsUserChoice` oder
  `WorldCandidate` ist,
- sanft daran erinnern, dass Entscheidungen spaeter aenderbar sind,
- sensible Inhalte neutral und optional behandeln,
- "Spaeter" oder "nur Codex" respektieren.

Nicht erlaubt:

- Entscheidung erzwingen,
- Schuld erzeugen,
- sensible Themen dramatisieren,
- Reward oder Placement ausloesen,
- Lernfortschritt schreiben,
- Weltfeedback als Pflichtziel formulieren.

## 14. MVP-Nichtziele

M16-V gibt nicht frei:

- Build-Wheel,
- Build-State,
- `frame_started`,
- Bauzustaende,
- Persistenz,
- lokale DB/Supabase Writes,
- SRS-/`word_progress`-Aenderung,
- App-Integration,
- Route,
- Flutter-/Dart-Code,
- Tests oder Widget-Tests,
- Screenshots als Repo-Artefakte,
- Assets oder Asset-Dateien unter `assets/`,
- automatische Wortplatzierung,
- produktive Reward Bridge.

## 15. Naechste sichere Folge-IDs

Nach M16-V sind die naechsten sinnvollen fachlichen Detail-Gates:

| ID | Warum naechster Schritt |
| --- | --- |
| `M16T-WOT-002` | `CodexOnly` braucht Beispiele, UI-Regeln und Fallback-Grenzen. |
| `M16T-WOT-003` | `WorldCandidate` muss User Choice, Later Gate und kein Auto-Placement vertiefen. |
| `M16T-WOT-004` | `ContainerItem` muss Clutter/Depth-Regeln konkretisieren. |
| `M16T-WOT-005` | `ActionChallenge` muss Verben vom Bauen trennen. |
| `M16T-REWARD-002` | Reward-Budget braucht Session-/Feedbackgrenzen. |
| `M16T-REWARD-003` | Reward, Vorschlag, PlacementCandidate und BuildState muessen begrifflich getrennt bleiben. |
| `M16T-QUEUE-002` | Review Queue braucht Session-Budget. |
| `M16T-QUEUE-003` | Queue-Ausgaenge brauchen verbindliche Regeln. |

## 16. Dokumentationsvisualisierungen

M16-V ergaenzt Dokumentationsvisualisierungen unter:

`docs/world_design/previews/m16_v_minimal_learning_loop/`

Erzeugte Visuals:

- `minimal_learning_loop.png`
- `event_separation_contract.png`
- `learning_to_world_no_auto_placement.png`
- `mvp_word_outcome_taxonomy.png`
- `review_queue_minimal_flow.png`
- optional `00_contact_sheet.png`

Diese PNGs sind Dokumentationsmaterial. Sie sind keine App-Screens, keine
Screenshots, keine Spielassets und keine Dateien unter `assets/`.

Visual-QA-Regel:

- Text bleibt in Karten/Rahmen/Panels.
- Ausreichender Innenabstand.
- Kartenabstaende.
- Keine Ueberlappung von Karten, Labels, Pfeilen, Titeln, Footern oder
  Legenden.
- Contact Sheet vollstaendig lesbar, falls erzeugt.
- Keine abgeschnittenen Inhalte.

## 17. Stop-Regeln

Aus M16-V folgt ausdruecklich:

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
- Nicht committen.
