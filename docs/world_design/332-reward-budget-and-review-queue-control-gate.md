# M16-X: Reward Budget and Review Queue Control Gate

Stand: 2026-06-08

Status: `Dokumentations-/Visual-Slice gestartet / keine Implementierung`

## 1. Zweck und Non-Goals

M16-X legt fest, wie Talvori im MVP Rewards, Weltvorschlaege,
Review-Entscheidungen und minimales Weltfeedback dosiert. Der Nutzer soll
Motivation und Orientierung erleben, aber keine Pflichtentscheidungen, keinen
Streak-Druck, keine Massenreviews und keine automatische Weltplatzierung.

M16-X gibt keine Implementierung frei.

Non-Goals:

- keine Implementierung,
- keine finale Datenstruktur,
- keine App-Integration,
- keine Route,
- keine neue Seite,
- keine Persistenz,
- keine Supabase/local DB Writes,
- keine SRS-/`word_progress`-Aenderung,
- keine automatische Wortplatzierung,
- kein Build-State,
- kein Build-Wheel,
- keine Assets und keine Asset-Dateien unter `assets/`,
- kein `frame_started`,
- keine Bauzustaende,
- keine Tests oder Widget-Tests,
- keine Screenshots als Repo-Artefakte.

## 2. Gepruefte Grundlage

| Dokument | Bedeutung fuer M16-X |
| --- | --- |
| `docs/world_design/328-talvori-learning-game-readiness-todo-checklist.md` | Fuehrende ToDo-/Gate-Liste und Dashboard. |
| `docs/world_design/330-minimal-playable-learning-loop-contract.md` | Minimaler Learning-to-World Contract und Event-Trennung. |
| `docs/world_design/331-minimal-word-outcome-detail-gate.md` | Outcome-Details, Queue-Ausgaenge und Reward-/Placement-Grenzen. |
| `docs/world_design/327-talvori-learning-game-logic-readiness-review.md` | Readiness Review: starke Basis, produktive Systeme bleiben gated. |
| `docs/world_design/326-scalable-word-semantics-architecture-plan.md` | 20.000+ Woerter werden Profile/Queues/Fallbacks, nicht sichtbare Objekte. |
| `docs/world_design/323-word-semantics-decision-preview-scope.md` | Beispielwort-Pipeline und sichere Representation Decisions. |
| `docs/world_design/321-global-world-semantics-consistency-audit.md` | Pflichtpipeline von Sense/Safety bis User Choice und Later Gate. |
| `docs/world_design/274-sensitive-content-representation-rules.md` | Sensitive Inhalte duerfen keine Rewards, Deko oder Retention-Trigger werden. |
| `docs/world_design/276-mobile-clutter-rules-small-objects.md` | Mobile-Dichte, TinyObject- und Clutter-Grenzen. |

## 3. Betroffene M16-T-IDs

| ID | M16-X Entscheidung | Grund |
| --- | --- | --- |
| `M16T-REWARD-002` | `[x]` | Pro Session/Loop sind Grenzen fuer Rewards, Vorschlaege und Weltfeedback definiert. |
| `M16T-QUEUE-002` | `[x]` | Review-Entscheidungen erhalten ein klares Session-Budget. |
| `M16T-QUEUE-004` | `[x]` | Queue-Priorisierung nach Risiko, Lernrelevanz, Confidence, Nutzerziel, Sensitive Flags, Clutter und Weltreife ist dokumentiert. |
| `M16T-SCALE-002` | `[x]` | Review-Queue-Budget verhindert Massenentscheidungen bei grossen Wortmengen. |
| `M16T-SCALE-003` | `[x]` | Safe Defaults sind definiert und erzeugen keine sichtbare Platzierung. |
| `M16T-SCALE-004` | `[x]` | Queue-Priorisierung ersetzt FIFO-Massenreview. |

## 4. Reward-Budget

Die folgenden Werte sind Planungsannahmen fuer den MVP. Sie sind keine
Runtime-Konfiguration, keine finale Produktmetrik und keine technische
Implementierung.

| Signal | MVP-Budget | Erlaubt | Blockiert |
| --- | --- | --- | --- |
| Sanftes Lernfeedback | nach einer sinnvollen Lernaktion oder einem kleinen Lernblock | kurzer positiver Hinweis, ruhige Bestaetigung, kein Druck | Streak-Schuld, Verlustwarnung, Pflichtaktion |
| Aktiver Weltvorschlag | maximal 0-2 sichtbare Vorschlaege pro Session | freiwillig ansehen, spaeter entscheiden, in Queue verschieben | Vorschlag nach jedem Wort, Reward-Spam, Auto-Placement |
| Review-Entscheidung | maximal wenige Entscheidungen pro Session, siehe Queue-Budget | Confirm, Change, Later, Codex, Backlog, Hide | Massenreview, Pflichtentscheidung, 20.000-Wort-Inbox |
| Weltfeedback | nur nach User Choice und spaeterem Gate | kleine reversible Preview oder Fallback-Signal | Build-State, Persistenz, `frame_started`, Asset |
| Sensitive Inhalte | kein Retention-/Reward-Budget | neutraler Codex, ContextCard, Later, Hide | Belohnung, Deko, Push-/Druckmechanik |

Regeln:

- Eine Lernaktion darf ein sanftes Feedback erzeugen, aber kein Build.
- Ein Lernblock darf eine kleine Moeglichkeit sichtbar machen, aber keine
  Pflichtentscheidung.
- Es duerfen nur wenige aktive Weltvorschlaege gleichzeitig sichtbar sein.
- Ignorieren, Verschieben oder Ablehnen eines Vorschlags hat keine Strafe.
- Sensitive Woerter duerfen nie als Retention-Trigger, Weltbelohnung oder
  Druckmittel verwendet werden.
- Keine Weltveraenderung entsteht ohne separates Gate.

## 5. Review-Queue-Session-Budget

Die Review Queue ist im MVP ein ruhiger Filter, keine Arbeitsliste mit allen
Woertern.

Planungsannahme:

- 0-3 aktive Review-Entscheidungen pro Session.
- 0 Entscheidungen, wenn sichere Defaults reichen.
- 0 Entscheidungen, wenn der Nutzer gerade nur lernen oder zurueckkehren will.
- 1 Entscheidung, wenn ein einzelnes Wort hoher Lernrelevanz oder hohes
  Fehlableitungsrisiko hat.
- 2-3 Entscheidungen nur nach einem abgeschlossenen Lernblock, Import-Review
  oder freiwilligem Oeffnen der Queue.

Review wird angezeigt, wenn:

- ein Wort mehrdeutig ist und hohe Lernrelevanz hat,
- ein falscher Default sichtbare Welt- oder Sensitive-Risiken haette,
- der Nutzer bewusst Review oeffnet,
- ein importierter Wortblock wenige klare Top-Fragen erzeugt,
- das Session-Budget noch frei ist.

Review wird nicht angezeigt, wenn:

- ein sicherer Default reicht,
- ein Wort niedrig relevant oder niedrig confidence ist und Backlog/Codex
  genuegt,
- das Session-Budget voll ist,
- ein sensibles Wort ohne Opt-in/Policy-Kontext auftaucht,
- der Nutzer gerade pausiert, zurueckkehrt oder Review ignoriert,
- die Entscheidung nur eine sichtbare Platzierung beschleunigen wuerde.

`Later` ist immer erlaubt. Eine Entscheidung nach jedem Wort ist blockiert.
Eine 20.000-Wort-Inbox ist blockiert.

## 6. Queue-Priorisierung

Queue-Priorisierung ist eine Planungsregel, kein Algorithmus und keine finale
Datenstruktur.

| Prioritaetsfaktor | Hoch priorisiert, wenn | Niedrig priorisiert, wenn | Stop-Regel |
| --- | --- | --- | --- |
| Risiko | falscher Ausgang koennte sensitive, falsche oder druckvolle Darstellung erzeugen | sicherer Codex/Backlog reicht | Safety vor Sichtbarkeit |
| Lernrelevanz | Wort ist aktuell wichtig, haeufig oder Ziel des Nutzers | selten, zufaellig, nicht aktiv gelernt | Lernen vor Retention |
| Unsicherheit / Confidence | mehrere plausible Bedeutungen oder Outcomes existieren | Sense und Outcome sind klar genug fuer Safe Default | Low confidence platziert nie |
| Nutzerziel | Nutzer hat Thema, Insel oder Wort bewusst fokussiert | kein aktueller Bezug | Nutzerziel ist Signal, kein Zwang |
| Sensitive Flags | neutraler Umgang braucht Nutzer-/Policy-Entscheidung | unkritisch und erklaerbar | Sensitive nie Reward/Deko |
| Clutter-Risiko | TinyObject oder kleine Detailflut droht | grosses, lesbares Konzept mit Gate | Mobile zuerst |
| Weltreife | Wort koennte spaeter WorldCandidate werden, aber braucht Choice | kein sinnvoller Weltbezug | Weltreif ist Gate, nicht Default |
| Wiederholung / Haeufigkeit | Wort taucht oft auf und verwirrt Nutzer | Einzelfall ohne Folgewirkung | Haeufigkeit allein baut nichts |

Priorisierungsreihenfolge bei Konflikten:

```text
Safety / Sensitive
-> Sense / Context
-> Clutter / Mobile
-> Lernrelevanz
-> Nutzerziel
-> Weltreife
-> Session-Budget
```

## 7. Safe Defaults

Safe Defaults verhindern, dass Talvori automatisch sichtbar baut, nur weil ein
Wort erkannt wurde.

| Default | Wann verwenden | Bewirkt | Darf nicht bewirken |
| --- | --- | --- | --- |
| `CodexOnly` | neutral lernbares, abstraktes, unklaeres oder nicht weltreifes Wort | Erklaer-/Lernraum | sichtbares Objekt, Plot, Build-State |
| `Backlog` | Gate, Context, Safety, Depth oder Insel fehlt | spaeter vormerken | versteckte Platzierung, Persistenz ohne Gate |
| `ContextCard` | Sense, Beispiel, Emotion oder abstrakte Bedeutung braucht Erklaerung | kleine Kontextkarte | Symbolzwang, Deko, Druck |
| `Later` | Nutzer will nicht entscheiden oder Budget ist voll | Entscheidung verschieben | Verlust, Schuld, Warnung |
| `Hide` | Nutzer will Wort nicht aktiv sehen oder Thema belastet | aus aktiver Queue ausblenden | Loeschen ohne Gate, Datenverlust |
| `ContainerItem` | kleines Objekt oder Detail gehoert in Depth/Container | Container-/Depth-Fallback | TinyObject in IslandView |
| `SensitiveGated` | Sensitive/Policy-/Privacy-Risiko | neutraler Gate-Ausgang | Reward, Deko, Push, Weltobjekt |

Kein Safe Default darf eine sichtbare Platzierung, einen Build-State,
Persistenz oder `frame_started` erzeugen.

## 8. Anti-Druck-Regeln

Talvori darf motivieren, aber nicht erpressen.

Blockiert:

- Streak-Schuld,
- Verfall,
- Ruinen als Strafe,
- Pflichtentscheidungen,
- Warnungen wie "du verlierst Fortschritt",
- Review-Zwang nach jeder Lerneinheit,
- Push-/Retention-Mechanik aus sensiblen Woertern,
- Weltstrafe nach Pause,
- Reward-Spam,
- automatische Weltplatzierung als Belohnung.

Erlaubt:

- sanfte Rueckmeldung nach Lernen,
- freiwilliger Vorschlag,
- `Later`,
- ruhige Rueckkehr nach Pause,
- kleine reversible Fortschrittssignale nach Gate,
- Tali/Vori nur als optionaler erklaerender Begleiter,
- Safe Defaults ohne Druck.

Pausen werden neutral behandelt. Ein Comeback darf willkommen heissen, aber
keine Schuld, keinen Verlust und keine Weltstrafe zeigen.

## 9. MVP-Entscheidungsfluss

```text
Learning event
-> optional reward signal
-> semantic outcome
-> queue eligibility
-> session budget
-> user choice
-> safe fallback or gated world feedback
```

Erlaubte Uebergaenge:

- Lernereignis darf Semantikpruefung anstossen.
- Semantikpruefung darf Outcome, Fallback oder Queue-Kandidatur erzeugen.
- Reward-Signal darf Aufmerksamkeit und Motivation geben.
- Queue-Budget entscheidet, ob die Frage jetzt sichtbar wird.
- Nutzerentscheidung darf spaeter eine Preview/Fallback-Weltreaktion erlauben.

Blockierte Uebergaenge:

- Learning event -> Placement,
- Learning event -> Build-State,
- Reward -> PlacementCandidate als MVP-Default,
- UI tap -> SRS-/`word_progress`-Aenderung,
- Review Ignore -> Strafe,
- Sensitive word -> Retention-Trigger,
- Queue Confirm -> Persistenz ohne Gate.

## 10. Beispiele

| Situation | MVP-Verhalten | Nicht erlaubt |
| --- | --- | --- |
| 10 gelernte Woerter in einer Session | ein sanftes Lernfeedback, hoechstens wenige Vorschlaege, 0-3 Review-Fragen | Frage nach jedem Wort, Weltobjekt pro Wort |
| 100 importierte Woerter | Batch-Profiling als Planung, Safe Defaults, wenige Top-Fragen nach Risiko/Relevanz | 100 Karten, sofortige Inselbelegung |
| 20.000 Woerter langfristig | Semantic Profiles, Filter, Fallbacks, Review Queue mit Budget | 20.000 sichtbare Karten/Objekte/Plots |
| sensibles Wort | `SensitiveGated`, Codex, ContextCard, Later oder Hide | Reward, Deko, Push, Pflichtreview |
| mehrdeutiges Wort | `NeedsUserChoice`, wenn relevant und Budget frei; sonst Later/ContextCard | Default-Sense als Platzierung |
| TinyObject | `ContainerItem`, Codex oder Backlog | eigenes Grundstueck oder Insel-Mikroobjekt |
| Verb/ActionChallenge | spaetere Challenge-Idee oder ContextCard | statisches Gebaeude, automatische Quest |
| Nutzer ignoriert Review | `Later` oder Safe Default, keine Strafe | Verlustwarnung, Streak-Druck |
| Nutzer kehrt nach Pause zurueck | neutrale Begruessung, optional ein kleiner Einstieg | Weltverfall, Schuld, Muss-Entscheidung |

## 11. Offene Gates vor produktiver Umsetzung

M16-X klaert Dosierung und Priorisierung, aber nicht die Umsetzung. Spaeter
braucht Talvori eigene Gates fuer:

- Datenmodell,
- Persistenz,
- lokale DB/Supabase,
- SRS-/`word_progress`-Sicherheit,
- Confidence Scoring,
- Review-Queue-UI,
- Companion-Copy,
- Sensitive Review,
- Accessibility,
- Performance,
- Undo/Reversibility,
- App-Integration,
- Tests,
- Analytics/Privacy,
- Reward Bridge,
- keine automatische Platzierung.

## 12. Dokumentationsvisualisierungen

M16-X erzeugt Dokumentationsvisuals unter:

`docs/world_design/previews/m16_x_reward_queue_control/`

Geplante Visuals:

- `reward_budget_limits.png`
- `review_queue_session_budget.png`
- `queue_priority_matrix.png`
- `safe_defaults_flow.png`
- `anti_pressure_rules.png`
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

## 13. Stop-Regeln

M16-X gibt nicht frei:

- App-Integration,
- Route,
- Flutter-/Dart-Codeaenderung,
- Persistenz,
- Supabase/local DB Writes,
- SRS-/`word_progress`-Aenderung,
- automatische Wortplatzierung,
- Build-Wheel-Code,
- Assets oder Asset-Dateien unter `assets/`,
- Build-State,
- `frame_started`,
- Bauzustaende,
- Screenshots als Repo-Artefakte,
- Tests oder Widget-Tests.

