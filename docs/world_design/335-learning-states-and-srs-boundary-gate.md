# M16-AA: Learning States and SRS Boundary Gate

Stand: 2026-06-08

Status: `Dokumentations-/Visual-Slice gestartet / keine Implementierung`

## 1. Zweck und Non-Goals

M16-AA definiert, welche minimalen Lernzustaende Talvori im MVP fachlich
braucht und wie diese strikt von SRS, `word_progress`, Semantikprofil, Reward,
Review Queue und Weltfeedback getrennt bleiben. Der Slice klaert Begriffe und
Grenzen. Er gibt keine technische Umsetzung frei.

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

| Dokument | Bedeutung fuer M16-AA |
| --- | --- |
| `docs/world_design/328-talvori-learning-game-readiness-todo-checklist.md` | Fuehrende M16-T-ID- und Dashboard-Liste. |
| `docs/world_design/330-minimal-playable-learning-loop-contract.md` | Event-Trennung und Learning-to-World Contract. |
| `docs/world_design/331-minimal-word-outcome-detail-gate.md` | Outcome-, Queue- und Reward-/BuildState-Grenzen. |
| `docs/world_design/332-reward-budget-and-review-queue-control-gate.md` | Reward-/Queue-Dosierung und Safe Defaults. |
| `docs/world_design/333-minimal-semantic-profile-and-routing-priority-gate.md` | Semantikprofil bleibt Konzept; Confidence und Safety begrenzen sichtbare Reaktionen. |
| `docs/world_design/334-companion-and-sensitive-return-safety-gate.md` | Pause, Fehler und sensitive Kommunikation duerfen keine Lern- oder Weltmutation ausloesen. |
| `docs/world_design/327-talvori-learning-game-logic-readiness-review.md` | Bestehende SRS-/Lernbasis bleibt geschuetzt. |
| `docs/world_design/326-scalable-word-semantics-architecture-plan.md` | Massensemantik braucht Profile/Queues/Fallbacks, nicht direkte Weltobjekte. |

## 3. Betroffene M16-T-IDs

| ID | M16-AA Entscheidung | Grund |
| --- | --- | --- |
| `M16T-LEARN-001` | `[x]` | Minimale Lernzustaende fuer den MVP sind fachlich definiert und gegen Welt-/Reward-/Semantiksysteme abgegrenzt. |
| `M16T-LEARN-002` | `[~]` | SRS-/`word_progress`-Boundary ist klar, aber ein echtes SRS-/Migration-/Test-Gate bleibt offen. |
| `M16T-AI-002` | `[~]` | Provider-Governance-Regeln sind als Stop-Regeln definiert, aber kein vollstaendiges Provider-Gate. |
| `M16T-AI-004` | `[~]` | Privacy-Grenzen fuer ContextHints sind definiert, aber kein vollstaendiges Privacy-/Provider-Gate. |

## 4. Minimale Lernzustaende als MVP-Konzept

Die folgenden Lernzustaende sind fachliche MVP-Begriffe. Sie sind keine finale
Datenstruktur, keine SRS-Logik, keine Runtime-Konfiguration und keine
Persistenzfreigabe.

| Lernzustand | Bedeutung | Darf entstehen durch | Darf erlauben | Darf nicht erlauben |
| --- | --- | --- | --- | --- |
| `imported` | Wort ist in Talvori angekommen, aber noch nicht gelernt. | Import, manuelle Eingabe, spaeterer Sammelpfad. | Semantik-Vorpruefung als Planung, Codex-/Backlog-Fallback. | SRS-Neubewertung, Weltplatzierung, Reward, DB Write ohne Gate. |
| `seen` | Nutzer hat das Wort mindestens einmal bewusst gesehen. | Lernansicht, Codex, ContextCard, freiwillige Review-Ansicht. | sanften Lernhinweis, optionalen Kontext. | "gelernt" behaupten, SRS-Wert schreiben, Weltfeedback erzwingen. |
| `practiced` | Wort wurde geuebt oder wiederholt, ohne technische SRS-Aussage. | Uebung, Wiederholung, Lernblock. | Lernereignis fuer Semantik- oder Reward-Vorschlag vorbereiten. | SRS/`word_progress` mutieren, BuildState, Placement. |
| `unsure` | Nutzer oder System sieht Unsicherheit. | falsche Antwort, niedrige Confidence, fehlender Kontext, Nutzerhinweis. | ContextCard, Codex, Later, ReviewCandidate. | negative Weltreaktion, Schuld, Pflichtreview, SRS-Abwertung. |
| `contextRich` | Wort hat brauchbaren Satz-, Ziel- oder Nutzungskontext. | Satzbeispiel, Importkontext, Nutzerhinweis, Companion-Erklaerung. | bessere Sense-Pruefung, ContextCard, spaeteres Review. | private ContextHints speichern oder senden ohne Privacy-Gate. |
| `understood` | Nutzer scheint die Bedeutung im aktuellen Lernkontext zu verstehen. | erfolgreiches Ueben oder klare Nutzerbestaetigung als fachliches Signal. | sanftes Feedback, optionalen Vorschlag, Codex-Hinweis. | finale SRS-Hochstufung, Placement, Persistenz. |
| `reviewCandidate` | Wort darf eventuell in die Review Queue. | Multi-Home, Unsicherheit, hohe Relevanz, Safety-/Clutter-Risiko. | Queue-Pruefung nach Budget und Prioritaet. | sofortige Sichtbarkeit, Pflichtentscheidung, negative Wirkung bei Ignorieren. |
| `worldFeedbackEligible` | Wort koennte minimales Weltfeedback als Vorschlag tragen. | klare Sense/Safety/Clutter-Pruefung plus passender Outcome. | kleinen freiwilligen Vorschlag oder Preview-Only-Hinweis. | automatische Platzierung, BuildState, Asset, Persistenz. |
| `blockedBySafety` | Safety, Sensitive, Privacy oder Policy stoppt aktive Welt-/Reviewwirkung. | Sensitive Flag, private Daten, niedrige Confidence, institutionelles Risiko. | `SensitiveGated`, `CodexOnly`, `ContextCard`, `Hide`, `Later`. | Reward, Deko, Retention-Trigger, visible world object. |
| `parked` | Wort bleibt bewusst zurueckgestellt. | Nutzer waehlt Later/Backlog/Hide, Gate fehlt, Queue-Budget voll. | spaeteres Review, Codex, Backlog. | Strafe, Verlust, SRS-Abwertung, versteckte Platzierung. |

## 5. Beziehungen der Lernzustaende

| Lernzustand | Semantikprofil | Reward | Review Queue | Weltfeedback | SRS / `word_progress` |
| --- | --- | --- | --- | --- | --- |
| `imported` | darf Profiling-Kandidaten vorbereiten | kein Reward-Default | nur bei Relevanz | kein Weltfeedback | keine Aenderung |
| `seen` | kann Context/Sense verbessern | kurzer Lernhinweis moeglich | nein, ausser Risiko/Unsicherheit | kein Placement | keine Aenderung |
| `practiced` | darf Semantikereignis anstossen | sanftes Signal moeglich | nur nach Budget | nur Vorschlag | keine Aenderung |
| `unsure` | Low-confidence oder contextMissing moeglich | kein Druck | moeglich, aber Later | kein Weltfeedback-Zwang | keine Abwertung |
| `contextRich` | ContextHint kann Sense klaeren | kein eigener Reward | moeglich | nur nach Gate | keine Aenderung |
| `understood` | Semantik kann trotzdem CodexOnly bleiben | sanftes Feedback moeglich | optional | nur Eligibility, kein Placement | keine Hochstufung |
| `reviewCandidate` | braucht Outcome/Safety/Confidence | kein Pflichtreward | Queue-Budget entscheidet | kein direkter Effekt | keine Aenderung |
| `worldFeedbackEligible` | braucht sichere Outcome-Pruefung | Vorschlag moeglich | optional | Preview/Fallback, reversibel | keine Aenderung |
| `blockedBySafety` | Safety gewinnt | kein Reward | nur neutral/opt-in | kein sichtbares Weltobjekt | keine Aenderung |
| `parked` | FallbackTarget moeglich | kein Verlust | spaeter moeglich | kein Effekt | keine Aenderung |

## 6. SRS-/`word_progress`-Boundary

Klare Regel:

- M16-AA definiert keine SRS-Logik.
- M16-AA definiert keine `word_progress`-Logik.
- Keine bestehenden SRS-Werte werden geaendert.
- Kein Schreibzugriff auf `word_progress`.
- Keine Migration.
- Keine Neubewertung bestehender Lernstaende.
- Kein UI-Event darf SRS oder `word_progress` aendern.
- Kein Companion-Text darf SRS oder `word_progress` aendern.
- Kein Reward-Signal darf SRS oder `word_progress` aendern.
- Kein Review-Confirm darf SRS oder `word_progress` aendern.
- Spaetere Aenderung nur mit eigenem SRS-/Migration-/Test-Gate.

SRS und `word_progress` bleiben bestehende Lernsysteme. M16-AA fuehrt nur
fachliche MVP-Lernzustaende ein, damit spaetere Slices sauber ueber Lernen
sprechen koennen, ohne bestehende Daten- oder Lernsemantik zu korrumpieren.

## 7. Lernzustand vs. Semantikzustand

Lernzustand und Semantikzustand sind verschiedene Achsen.

Beispiele:

- Ein Wort kann `understood` sein, aber `CodexOnly` bleiben.
- Ein Wort kann `unsure` sein, aber nicht weltreif.
- Ein Wort kann semantic `high confidence` haben, aber lernseitig unbekannt
  oder nur `imported` sein.
- Ein Wort kann oft geuebt sein, aber wegen Safety nie Weltfeedback erzeugen.
- Ein Wort kann `worldFeedbackEligible` sein, aber trotzdem keine Platzierung
  ausloesen.
- Ein Wort kann `contextRich` sein, aber wegen Privacy nicht gespeichert oder
  extern klassifiziert werden.

Pflichtregel:

Semantik darf Lernzustaende erklaeren oder fuer Vorschlaege nutzen. Semantik
darf keine SRS-/`word_progress`-Aenderung, keine Persistenz und keine
automatische Platzierung ausloesen.

## 8. Lernzustand vs. Reward

Reward ist Signal, kein Lernzustand.

Erlaubt:

- Lernzustand kann sanftes Feedback erlauben.
- `practiced` oder `understood` kann einen freiwilligen Vorschlag vorbereiten.
- `unsure` kann beruhigendes Feedback oder Codex/ContextCard erlauben.

Blockiert:

- Reward schreibt keinen SRS-Wert.
- Reward schreibt keinen `word_progress`-Wert.
- Reward erzeugt kein Placement.
- Reward erzeugt keinen BuildState.
- Reward erzeugt kein `frame_started`.
- Reward darf Lernzustand nicht kuenstlich aufwerten.
- Reward darf sensitive Inhalte nicht als Motivation verwenden.

## 9. Lernzustand vs. Review Queue

`reviewCandidate` bedeutet nur: Das Wort darf eventuell in die Queue. Es ist
kein sichtbarer Review-Zwang.

Regeln:

- Queue-Budget entscheidet Sichtbarkeit.
- Prioritaet entscheidet Reihenfolge.
- `Later` bleibt immer erlaubt.
- Review ignorieren hat keine negative Lernwirkung.
- Review Confirm schreibt keine SRS-/`word_progress`-Werte.
- Review Confirm erzeugt keine Persistenz ohne Gate.
- Review Confirm erzeugt kein Placement und keinen BuildState.
- Sensitive oder private Inhalte koennen trotz `reviewCandidate` blockiert
  oder geparkt bleiben.

## 10. Lernzustand vs. Weltfeedback

`worldFeedbackEligible` bedeutet nur: Ein minimaler Vorschlag koennte moeglich
sein.

Blockiert:

- keine automatische Platzierung,
- kein BuildState,
- kein `frame_started`,
- kein Asset,
- keine Persistenz,
- kein Supabase/local DB Write,
- keine App-Integration,
- keine SRS-/`word_progress`-Aenderung.

Erlaubt als Planung:

- Preview Only,
- Codex/Backlog/ContextCard,
- freiwilliger Vorschlag,
- reversibles Weltfeedback nur nach spaeterem Gate,
- spaeteres Undo-/Reversibility-Gate.

## 11. AI-/Provider-Governance und Privacy

M16-AA beruehrt `M16T-AI-002` und `M16T-AI-004`, gibt aber keine AI- oder
Provider-Integration frei.

Pflichtregeln:

- Klassifikation darf nicht ungeplant externe Provider nutzen.
- Satz-, Import- und ContextHint-Daten koennen privat sein.
- Keine Provider-Calls ohne eigenes Gate.
- Keine Speicherung privater ContextHints ohne Privacy-Gate.
- Keine Kosten-, Bias- oder Provider-Abhaengigkeit ohne Governance-Gate.
- Lokale/rule-based Planung ist der sichere Default.
- Low confidence landet in Safe Defaults oder Review, nie in Placement.
- Spaetere AI-Integration braucht Provider-, Privacy-, Cost-, Bias-,
  Confidence-, Fallback- und User-Control-Regeln.

Planungsentscheid:

`M16T-AI-002` und `M16T-AI-004` werden durch M16-AA teilweise vorbereitet,
bleiben aber nicht vollstaendig erledigt. Ein eigenes AI-/Privacy-Gate muss
spaeter klaeren, welche Daten lokal bleiben, welche optional gesendet werden
duerften, welche Provider ueberhaupt erlaubt sind und wie Nutzerkontrolle,
Kosten, Bias und Fallbacks funktionieren.

## 12. Beispiele

| Situation | Lernzustand | Sicherer MVP-Ausgang | Blockiert |
| --- | --- | --- | --- |
| Neues importiertes Wort | `imported` | Profiling-Kandidat, Codex/Backlog | SRS-Neubewertung, Weltplatzierung |
| Einmal gesehenes Wort | `seen` | kurzer Kontext, Lernen fortsetzen | "gelernt" behaupten, `word_progress` schreiben |
| Mehrfach geuebtes Wort | `practiced` oder `understood` | sanftes Feedback, optionaler Vorschlag | SRS-Hochstufung, BuildState |
| Falsch beantwortetes Wort | `unsure` | ContextCard, Codex, ruhige Wiederholung | Schuld, Abwertung, Weltstrafe |
| Unsicheres Wort | `unsure` / `reviewCandidate` | Later, NeedsUserChoice, Backlog | Pflichtreview, Default-Placement |
| Sensibles Wort | `blockedBySafety` | SensitiveGated, Hide, Later, CodexOnly | Reward, Deko, Retention-Trigger |
| CodexOnly-Wort | `seen` oder `understood` plus `CodexOnly` | Codex/ContextCard | sichtbares Objekt erzwingen |
| WorldCandidate-Wort | `worldFeedbackEligible` | freiwilliger Preview-Vorschlag | automatische Platzierung |
| NeedsUserChoice-Wort | `reviewCandidate` | kleine Queue-Frage, Later | finale Default-Kategorie |
| Nutzer ignoriert Review | `parked` | Later/Backlog, keine negative Wirkung | Druck, Verlust, SRS-Abwertung |
| Nutzer kehrt nach Pause zurueck | unveraendert oder `parked` | neutraler Wiedereinstieg | Schuld, Weltverfall, Pflichtentscheidung |

## 13. Gates vor Umsetzung

Vor produktiven Lernzustands-, SRS-, Provider- oder Privacy-Systemen braucht
Talvori spaeter eigene Gates fuer:

- SRS-/`word_progress`-Migration und Tests,
- Datenmodell,
- Persistenz,
- lokale DB/Supabase,
- Privacy,
- AI-/Provider-Governance,
- Confidence Scoring,
- Review Queue UI,
- Reward Bridge,
- Undo/Reversibility,
- App-Integration,
- Accessibility und Performance,
- keine automatische Platzierung.

## 14. Dokumentationsvisualisierungen

M16-AA ergaenzt Dokumentationsvisualisierungen unter:

`docs/world_design/previews/m16_aa_learning_states_srs_boundary/`

Geplante Visuals:

- `learning_state_boundaries.png`
- `srs_word_progress_firewall.png`
- `learning_vs_semantics_matrix.png`
- `learning_reward_queue_world_separation.png`
- `ai_provider_privacy_gate.png`
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

## 15. Stop-Regeln

Aus M16-AA folgt ausdruecklich:

- Keine Implementierung.
- Keine Flutter-/Dart-Dateien.
- Keine App-Integration.
- Keine Route.
- Keine neue Seite.
- Keine Tests und keine Widget-Tests.
- Keine Screenshots als Repo-Artefakte.
- Keine Runtime-Konfiguration.
- Keine Persistenz.
- Keine Supabase Writes.
- Keine lokalen DB-Writes.
- Keine SRS-/`word_progress`-Aenderung.
- Keine Reward Bridge.
- Keine automatische Wortplatzierung.
- Keine Build-Wheel-Implementierung.
- Keine Assets.
- Keine Asset-Dateien unter `assets/`.
- Kein Build-State.
- Kein `frame_started`.
- Keine Bauzustaende.
- Nicht committen.
