# M16-Z: Companion and Sensitive Return Safety Gate

Stand: 2026-06-08

Status: `Dokumentations-/Visual-Slice gestartet / keine Implementierung`

## 1. Zweck und Non-Goals

M16-Z legt fest, wie Tali/Vori, Rueckkehr nach Pause, Fehler, sensible Inhalte
und abstrakte Woerter im MVP kommuniziert werden duerfen. Ziel ist ein
Companion- und Copy-Rahmen, der begleitet und motiviert, aber niemals Schuld,
Druck, Angst, falsche Beratung, sensitive Retention-Trigger oder
Pflichtentscheidungen erzeugt.

M16-Z ist ein Safety-Gate. Es gibt keine Implementierung frei.

Non-Goals:

- keine Implementierung,
- keine finale Copy,
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

| Dokument | Bedeutung fuer M16-Z |
| --- | --- |
| `docs/world_design/328-talvori-learning-game-readiness-todo-checklist.md` | Fuehrende M16-T-ID- und Dashboard-Liste. |
| `docs/world_design/330-minimal-playable-learning-loop-contract.md` | Learning-to-World Contract: Lernen erzeugt Moeglichkeit, keine Platzierung, kein Build-State. |
| `docs/world_design/331-minimal-word-outcome-detail-gate.md` | Outcome-Regeln, Queue-Ausgaenge und neutrale Sensitive-/Context-Ausgaenge. |
| `docs/world_design/332-reward-budget-and-review-queue-control-gate.md` | Reward-Budget, Review-Queue-Budget, Safe Defaults und Anti-Druck-Regeln. |
| `docs/world_design/333-minimal-semantic-profile-and-routing-priority-gate.md` | Safety/Sensitive gewinnt vor Context, Word Type, User Choice, Capability und Reward. |
| `docs/world_design/327-talvori-learning-game-logic-readiness-review.md` | Readiness Review: Companion und sensitive Inhalte brauchen eigene Gates. |
| `docs/world_design/274-sensitive-content-representation-rules.md` | Sensitive Inhalte duerfen nicht automatisch visualisiert, belohnt oder dramatisiert werden. |
| `docs/world_design/276-mobile-clutter-rules-small-objects.md` | Companion-Hinweise bleiben kurz, optional und duerfen keine UI ueberdecken. |
| `docs/world_design/323-word-semantics-decision-preview-scope.md` | Beispielwoerter zeigen, dass Emotion, Sensitive, Action und Multi-Home anders behandelt werden muessen. |
| `docs/world_design/321-global-world-semantics-consistency-audit.md` | Globale Pflichtpipeline und Fallbacks fuer Codex, ContextCard, Backlog und SensitiveGated. |

## 3. Betroffene M16-T-IDs

| ID | M16-Z Entscheidung | Grund |
| --- | --- | --- |
| `M16T-REWARD-004` | `[x]` | Rueckkehr nach Pause ist ohne Schuld, Verlust, Weltverfall oder Pflichtentscheidung definiert. |
| `M16T-REWARD-005` | `[x]` | Sensitive und emotionale Inhalte sind als Retention-Trigger explizit blockiert. |
| `M16T-COMP-001` | `[x]` | Companion-Policy fuer Vorschlaege, Grenzen, Beratungsausschluss und Nicht-Entscheidung ist definiert. |
| `M16T-COMP-002` | `[x]` | Erlaubte und blockierte Companion-Sprechmomente sind dokumentiert. |
| `M16T-COMP-003` | `[x]` | Fehler- und Pausenkommunikation ist sanft, nicht beschamend und ohne Weltstrafe definiert. |
| `M16T-COMP-004` | `[x]` | Companion-Regeln fuer sensitive und abstrakte Woerter sind neutral und nicht dramatisierend definiert. |
| `M16T-SENS-001` | `[x]` | Sensitive-Darstellungsleiter priorisiert sichere Ausgaenge vor sichtbarer Weltrepraesentation. |
| `M16T-SENS-002` | `[x]` | Opt-in, Later, Hide, Backlog und ContextCard bleiben fuer sensible Themen jederzeit moeglich. |

## 4. Companion-Policy

Tali/Vori ist im MVP:

- erklaerender Begleiter,
- optionaler Vorschlagsgeber,
- Rueckfrage- und Einordnungshelfer bei Unsicherheit,
- sanfter Hinweisgeber bei `NeedsUserChoice`, `CodexOnly`, `ContextCard`,
  `SensitiveGated` oder Rueckkehr nach Pause.

Tali/Vori ist nicht:

- Entscheidungsautomat,
- Drucksystem,
- Reward-Ausloeser,
- Placement-Ausloeser,
- Persistenz-Ausloeser,
- Lernfortschritts-Ausloeser,
- medizinischer Coach,
- rechtlicher Coach,
- psychologischer Coach,
- Autoritaetsstimme fuer sensible Themen,
- Ersatz fuer Nutzerentscheidung oder Safety-Gate.

Pflichtregel:

Tali/Vori darf eine Entscheidung erklaeren oder verschieben helfen. Tali/Vori
darf keine Entscheidung erzwingen, keine Safety-Regel ueberstimmen und keinen
Welt-, Reward-, Build-, Placement-, Persistenz- oder SRS-Effekt ausloesen.

## 5. Companion-Sprechmomente

Erlaubte Sprechmomente:

| Moment | Erlaubte Companion-Rolle | Grenze |
| --- | --- | --- |
| Nach Lernblock | kurzer, sanfter Hinweis oder optionaler Vorschlag | nicht nach jedem Wort, kein Reward-Spam |
| Bei Unsicherheit | erklaeren, dass Kontext fehlt oder User Choice spaeter moeglich ist | keine Pflichtentscheidung |
| Bei `NeedsUserChoice` | Optionen neutral benennen und Later erlauben | kein Default als richtige Antwort darstellen |
| Bei `CodexOnly` | erklaeren, warum Codex sicherer ist | keine Abwertung des Wortes |
| Bei Rueckkehr nach Pause | neutral willkommen heissen und ruhig fortsetzen | keine Schuld, kein Verlust, kein Weltverfall |
| Bei sensiblen/abstrakten Woertern | Codex, ContextCard, Backlog, Hide, Later oder Opt-in neutral anbieten | keine Beratung, keine Dramatisierung |
| Bei freiwilligem Review | knappe Orientierung geben | Queue-Budget respektieren |

Nicht sprechen oder nur stark zurueckhaltend sprechen:

- nach jedem Wort,
- wenn das Queue-Budget voll ist,
- bei sensiblen Themen ohne Opt-in,
- wenn der Nutzer ein Review ignoriert,
- wenn der Nutzer nur lernen will,
- als Druck-/Retention-Trigger,
- mit medizinischer, rechtlicher oder psychologischer Beratung,
- mit Schuld-, Angst-, Verlust- oder FOMO-Sprache.

## 6. Rueckkehr-nach-Pause-Regel

Rueckkehr nach Pause ist im MVP neutral und entlastend.

Erlaubt:

- ruhiger Wiedereinstieg,
- optionaler kurzer Companion-Hinweis,
- keine Entscheidungspflicht,
- freiwilliges Review spaeter,
- unveraenderte Welt als sicherer Ausgang,
- kleine reversible Fortschrittssignale nur nach eigenem Gate.

Blockiert:

- Schuld,
- Verlust,
- Weltverfall,
- Ruinen oder Strafe,
- Warnung wie "du verlierst Fortschritt",
- Pflichtentscheidung,
- Streak-Schuld,
- sensitive oder emotionale Trigger als Rueckkehrmotiv.

Beispielprinzip, keine finale Copy:

> Willkommen zurueck, wir machen ruhig weiter.

## 7. Fehler-/Unsicherheits-Kommunikation

Fehler sind Lernsignale, keine Weltstrafe.

Erlaubt:

- kurz erklaeren,
- neutral wiederholen,
- auf Codex oder ContextCard verweisen,
- Unsicherheit als normalen Lernzustand zeigen,
- spaeteres Review freiwillig anbieten,
- Tali/Vori kurz und ruhig formulieren lassen.

Blockiert:

- Beschamung,
- negative Weltreaktion,
- Verlust,
- ueberdramatische Sprache,
- Fehlversuch als moralisches Scheitern,
- Druck, sofort zu korrigieren,
- SRS-/`word_progress`-Aenderung aus Companion- oder Preview-Copy.

## 8. Sensitive-Themen-Regeln

Sensitive Woerter duerfen gelernt werden, aber nicht als Druck-, Deko-,
Reward- oder automatische Weltmechanik funktionieren.

Pflichtregeln:

- Sensitive Woerter sind keine Deko.
- Sensitive Woerter sind kein Reward.
- Sensitive Woerter sind keine Retention-Trigger.
- Sensitive Woerter duerfen nicht dramatisiert werden.
- Keine medizinische Beratung.
- Keine rechtliche Beratung.
- Keine psychologische Beratung.
- Keine politische, religioese oder institutionelle Position als Spielziel.
- Keine Pflichtquest fuer sensible Themen.
- Opt-in, Later und Hide bleiben moeglich.
- Safety/Sensitive gewinnt gegen Reward, Weltwunsch, User Choice und
  Capability.

Neutrale Ausgaenge:

- `CodexOnly`,
- `ContextCard`,
- `Backlog`,
- `Later`,
- `Hide`,
- `SensitiveGated`.

## 9. Sensitive-Darstellungsleiter

Die sichere Darstellungsleiter fuer sensitive Inhalte lautet:

```text
nicht aktiv zeigen
-> Hide
-> Later
-> CodexOnly
-> ContextCard
-> Backlog
-> SensitiveGated
-> spaeteres Opt-in-Gate
-> keine sichtbare Weltrepraesentation ohne eigenes Gate
```

Lesart:

- Je mehr Safety-, Context-, Privacy-, Alters-, Policy- oder Clutter-Risiko
  besteht, desto frueher endet die Leiter in einem sicheren Fallback.
- Eine sichtbare Weltrepraesentation ist kein MVP-Default.
- Ein spaeteres Opt-in-Gate ist keine automatische Freigabe fuer Assets,
  Build-State, Placement oder Persistenz.

## 10. Companion-Beispieltexte

Die folgenden Saetze sind keine finale Produktcopy. Sie zeigen nur
Copy-Prinzipien.

| Situation | Sicheres Copy-Prinzip |
| --- | --- |
| Rueckkehr nach Pause | "Willkommen zurueck, wir machen ruhig weiter." |
| Falsch beantwortetes Wort | "Das war noch nicht sicher. Wir schauen es uns ruhig noch einmal an." |
| `CodexOnly` | "Dieses Wort bleibt erstmal im Codex. Es muss nichts in der Welt werden." |
| `NeedsUserChoice` | "Es gibt mehrere passende Bedeutungen. Du kannst spaeter entscheiden." |
| `SensitiveGated` | "Das ist ein sensibles Thema. Wir koennen es neutral im Codex lassen oder spaeter ansehen." |
| `ContextCard` | "Hier hilft ein kurzer Kontext mehr als ein Objekt." |
| Nutzer ignoriert Review | "Alles gut, wir lassen die Entscheidung fuer spaeter." |
| Nutzer waehlt Later | "Okay, wir parken das ruhig." |
| Nutzer fragt Tali/Vori nach Erklaerung | "Ich erklaere dir die Bedeutung neutral und kurz." |

Regeln fuer diese Beispielrichtung:

- kurz,
- ruhig,
- optional,
- keine Schuld,
- keine Drohung,
- keine Beratung,
- keine Pflichtentscheidung,
- kein "jetzt bauen",
- kein "jetzt speichern",
- kein "du verlierst".

## 11. Verbotene Formulierungen

Talvori darf im MVP keine Copy verwenden, die Schuld, Angst, Verlust,
Pflichtentscheidung oder sensitive Retention erzeugt.

Verbotene Beispiele:

- "Du hast versagt."
- "Du verlierst deinen Fortschritt."
- "Du musst jetzt entscheiden."
- "Wenn du nicht lernst, verfaellt deine Welt."
- "Deine Welt ist kaputt, weil du pausiert hast."
- "Dieses sensible Wort ist deine besondere Belohnung."
- "Du solltest medizinisch/rechtlich/psychologisch Folgendes tun..."
- "Tali/Vori weiss, welche Bedeutung richtig ist."
- "Ignorierst du das Review, verlierst du deine Chance."

Blockierte Muster:

- sensitive oder emotionale Woerter als Druckmittel,
- medizinische/rechtliche/psychologische Beratung durch Companion,
- Companion als Autoritaet statt Begleiter,
- negative Weltfolgen aus Fehlern oder Pausen,
- Zwangsreview nach jedem Lernereignis.

## 12. Gates vor Umsetzung

Vor produktiver Companion-, Sensitive-, Return-, Copy- oder Review-Umsetzung
braucht es spaeter eigene Gates fuer:

- finale Copy und Tone Review,
- Sensitive Review,
- Privacy,
- Alters-/Familienmodus, falls relevant,
- Accessibility,
- App-Integration,
- Persistenz,
- Datenmodell,
- Undo/Reversibility,
- Review Queue UI,
- SRS-/`word_progress`-Schutz,
- Tests,
- keine automatische Platzierung.

## 13. Dokumentationsvisualisierungen

M16-Z ergaenzt echte PNG-Dokumentationsvisualisierungen unter:

`docs/world_design/previews/m16_z_companion_sensitive_safety/`

Geplante Visuals:

- `companion_policy_boundaries.png`
- `companion_speaking_moments.png`
- `return_after_pause_flow.png`
- `sensitive_representation_ladder.png`
- `forbidden_pressure_copy.png`
- optional `00_contact_sheet.png`

Diese PNGs sind Dokumentationspreviews. Sie sind keine App-Screens, keine
Screenshots, keine finalen UI-PNGs, keine Spielassets und keine Dateien unter
`assets/`.

Visual-QA:

- Text bleibt in Karten/Rahmen/Panels.
- Ausreichender Innenabstand.
- Kartenabstaende.
- Keine Ueberlappung von Karten, Labels, Pfeilen, Titeln, Footern oder
  Legenden.
- Contact Sheet vollstaendig lesbar, falls erzeugt.
- Keine abgeschnittenen Inhalte.

## 14. Stop-Regeln

Aus M16-Z folgt ausdruecklich:

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
