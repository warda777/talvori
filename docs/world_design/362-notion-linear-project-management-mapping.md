# M16-BV: Notion Linear Project Management Mapping

Stand: 2026-06-10

Status: `Dokumentations-/Planungs-Slice / keine Implementierung`

## 1. Zweck

M16-BV klaert, wie Talvori kuenftig ueber Repository, Notion, Linear und
GitHub gemanagt werden kann, ohne doppelte Wahrheit zu erzeugen.

Das Repository bleibt die fuehrende Quelle. Notion, Linear und GitHub duerfen
helfen, Arbeit sichtbar, planbar und reviewbar zu machen. Sie duerfen aber
keine stillen Produktentscheidungen, technischen Regeln oder produktiven
Freigaben erzeugen.

Dieses Dokument ist nur Planung. Es erstellt keine Notion-Seite, kein
Linear-Issue, kein GitHub-Issue, keinen PR, keine App-Integration, keine
Persistenz und keine externe Aenderung.

## 2. Source-of-Truth-Regel

Das Repository bleibt fuehrend fuer:

- `AGENTS.md`,
- `docs/world_design/talvori_game_bible.md`,
- M16-Dokumente,
- Code,
- technische Entscheidungen,
- Stop-Regeln,
- Commits.

Eine Entscheidung gilt erst als verbindlich, wenn sie als Repo-Artefakt
vorliegt und durch Commit in die Projektgeschichte eingegangen ist. Externe
Tools koennen Zusammenfassungen, Arbeitsauftraege und Sichten enthalten, aber
keine eigenstaendige Produkt- oder Architekturwahrheit.

## 3. Notion-Rolle

Notion ist geeignet fuer:

- lesbare Produktuebersicht,
- Game-Bible-Kurzfassung,
- Roadmap-Ansicht,
- Entscheidungslog,
- Research-Zusammenfassungen,
- offene Produktfragen,
- visuelle und konzeptionelle Uebersichten,
- Sprint-Review-Zusammenfassungen.

Notion ist nicht geeignet als:

- alleinige Wahrheit fuer Code-Regeln,
- Ersatz fuer `328` oder `336`,
- Ort fuer ungepruefte neue Entscheidungen,
- produktiver Daten- oder Backend-Speicher,
- Freigabestelle fuer App-Integration, Persistenz oder BuildState.

Notion sollte daher ein lesbarer Management-Spiegel sein: hilfreich fuer
Orientierung, Kommunikation und Review, aber immer auf Repo-Quellen
zurueckverlinkt.

## 4. Linear-Rolle

Linear ist geeignet fuer:

- konkrete Arbeitspakete,
- Sprints,
- Bugs,
- Review-Aufgaben,
- Visual-QA-Aufgaben,
- Blocker,
- M16-Slice-Tracking.

Linear ist nicht geeignet als:

- Game-Bible-Ersatz,
- vollstaendiges Dokumentationssystem,
- Ort fuer produktive Featurefreigabe ohne Repo-Gate,
- Ersatz fuer `git status`, Diff, Scope-Check oder Commit-Historie.

Linear sollte Arbeit steuerbar machen: was ist als Naechstes dran, wer wartet
worauf, was ist blockiert, welche Reviews fehlen. Die inhaltliche Entscheidung
bleibt im Repo.

## 5. GitHub-Rolle

GitHub ist geeignet fuer:

- Code,
- Commits,
- Branches,
- Pull Requests,
- technische Issues,
- spaetere Releases,
- Review-Verlauf und CI-Kontext.

GitHub Issues koennen technische Arbeit und Bugs spiegeln. Fuer Produkt- und
Game-Entscheidungen bleibt aber das Repo-Dokument massgeblich. Pull Requests
und Commits sind die Stelle, an der lokale Arbeit nachvollziehbar in die
Projektgeschichte uebergeht.

## 6. Mapping-Vorschlag

| Inhalt | Repo-Quelle | Notion | Linear | GitHub | Kommentar |
| --- | --- | --- | --- | --- | --- |
| `AGENTS.md` | `AGENTS.md` | Ja, Kurzfassung | Nein | Ja, via Repo | Harte Codex-Verfassung bleibt im Repo. |
| Game Bible | `docs/world_design/talvori_game_bible.md` | Ja, lesbare Kurzfassung | Nein | Ja, via Repo | Notion darf Produktbibel spiegeln, aber nicht ersetzen. |
| 328 Dashboard | `docs/world_design/328-talvori-learning-game-readiness-todo-checklist.md` | Ja, Roadmap-Auszug | Ja, Slice-/Milestone-Tracking | Ja, via Repo | Repo-Dashboard bleibt fuehrend; Linear darf Aufgaben daraus ableiten. |
| 336 Reading Rules | `docs/world_design/336-documentation-map-and-slice-reading-rules.md` | Ja, Prozessuebersicht | Nein | Ja, via Repo | Pflichtlektuere-Regeln bleiben Repo-Regeln. |
| M16-BT | zukuenftiges M16-BT-Prompt/Gate und Code-Diff | Ja, Sprint-Review | Ja, Code-Slice-Issue | Ja, Branch/PR spaeter | Rejoin-Code bleibt lokal/isoliert bis eigenes Gate. |
| M16-BV | `docs/world_design/362-notion-linear-project-management-mapping.md` | Ja, Management-Konzept | Ja, falls Sync-Aufgabe folgt | Ja, via Repo | Dieses Dokument definiert nur Mapping, keine externen Writes. |
| Blocker M16T-ARCH | `328`, Architektur-/Boundary-Gates | Ja, Risiko-Uebersicht | Ja, Blocker-Issues | Ja, technische Issues spaeter | App-Integration bleibt blockiert, bis Gate/Commit existiert. |
| Visual-QA | `336`, Visual-QA-Gates, Preview-Reviews | Ja, Beispiele/Review | Ja, QA-Aufgaben | Ja, PR-Review spaeter | Screenshots/Assets nur nach passendem Scope. |
| App-Integration-Gates | `328`, `336`, relevante Architecture-Gates | Ja, Entscheidungsuebersicht | Ja, Blocker/Planning | Ja, PR/Issue spaeter | Keine App-Integration ohne Repo-Gate. |
| Supabase-/Datenmodell-Gates | `328`, Data-/Persistence-Gates | Ja, Risiko-/Planungsuebersicht | Ja, blocked/data Issues | Ja, Migration/PR spaeter | Keine Writes ohne eigenes Gate und explizite Freigabe. |
| Research-Ergebnisse | Research-Dokumente im Repo | Ja, lesbare Zusammenfassung | Ja, Research-Task | Ja, falls Repo-Diff/PR | Notion ist gut fuer Synthese, Repo bleibt Quelle. |
| Design-/UI-Entscheidungen | `350`, `357`, UI-/Visual-Gates | Ja, visuelle Uebersicht | Ja, Design-/QA-Aufgaben | Ja, Code/PR spaeter | Figma/Canva nur mit Freigabe schreiben. |
| Bugs | Code, Logs, Reviews, spaeter Issues | Optional | Ja | Ja | Bugs koennen Linear/GitHub leben, brauchen bei Fixes Repo-Diff. |
| konkrete Code-Slices | Prompt, Diff, Checks, Commit | Review-Zusammenfassung | Ja, Issue | Ja, Branch/PR/Commit | Implementierung ist erst durch Repo-Checks und Commit verbindlich. |

## 7. Empfohlene Notion-Struktur

Reine Planungsstruktur, keine Erstellung in diesem Slice:

- Talvori Home,
- Product Bible,
- Roadmap,
- Decisions,
- Research,
- Open Questions,
- Sprint Reviews,
- Visual References.

Empfohlene Lesart:

- `Talvori Home` verlinkt auf Repo, Game Bible, Roadmap und aktuelle Slices.
- `Product Bible` fasst die Game Bible knapp und lesbar zusammen.
- `Roadmap` spiegelt 328 nur als Managementsicht.
- `Decisions` sammelt beschlossene Repo-Entscheidungen mit Link zur Quelle.
- `Research` fasst Research-Ergebnisse zusammen, ohne neue Regeln zu erfinden.
- `Open Questions` enthaelt Fragen, keine Freigaben.
- `Sprint Reviews` dokumentiert, was ein Slice ergeben hat.
- `Visual References` sammelt Konzeptbilder, Screenshots oder Links nur als
  Referenz, nicht als Asset-Freigabe.

## 8. Empfohlene Linear-Struktur

Reine Planungsstruktur, keine Erstellung in diesem Slice:

- Team: `Talvori`,
- Project: `Talvori Welt MVP`,
- Milestone: `M16 Local World Proof`,
- Labels:
  - `docs-gate`,
  - `code-slice`,
  - `visual-qa`,
  - `blocked`,
  - `research`,
  - `app-integration`,
  - `data`,
  - `design`,
  - `language-layer`.

Issue-Namenskonvention:

```text
M16-BT: Local Uferhain-to-Buildsite Rejoin Preview
```

Linear-Issues sollten enthalten:

- Slice-ID,
- Ziel in einem Satz,
- Repo-Quelle,
- erlaubte Dateien,
- harte Stop-Regeln,
- Definition of Done,
- Link zu Commit/PR nach Abschluss.

Linear darf keine eigene Freigabelogik fuer App-Integration, Persistenz,
BuildState, Supabase oder SRS/`word_progress` enthalten.

## 9. Sync-Regeln

- Repo-Commit erzeugt Wahrheit.
- Notion und Linear bekommen nur Zusammenfassungen, Roadmap-Sichten,
  Entscheidungsnotizen oder Aufgaben.
- Keine Entscheidung gilt nur, weil sie in Notion oder Linear steht.
- Externe Writes sind nur nach ausdruecklicher Freigabe erlaubt.
- Wenn Notion oder Linear dem Repo widersprechen, gilt das Repo bis zu einem
  neuen Repo-Commit.
- Wenn ein externer Eintrag eine neue Entscheidung fordert, muss daraus ein
  Repo-Slice, Gate oder Issue mit klarer Quelle entstehen.
- Management-Sync ist nachlaufend: erst Repo-Entscheidung, dann externer
  Spiegel.

## 10. Plugin-Write-Regeln

Konkrete Regeln fuer externe Tools:

- Notion create/update nur mit ausdruecklicher Freigabe.
- Linear create/update nur mit ausdruecklicher Freigabe.
- GitHub Issues/PRs/Kommentare nur mit ausdruecklicher Freigabe.
- Supabase niemals ohne eigenes Gate und ausdrueckliche Freigabe.
- Keine API-Key-Aktionen ohne ausdrueckliche Freigabe.
- Figma/Canva/Shutterstock/PostHog/Sentry/Hostinger-Writes nur nach eigener
  Freigabe und passendem Slice.
- Read-only Analyse darf helfen, wenn sie zur Aufgabe passt und keine
  vertraulichen oder produktiven Daten unnoetig oeffnet.

## 11. Naechster Moeglicher Folgeschritt

Zwei sinnvolle Pfade:

### Option A: M16-BW Notion Project Dashboard Draft

Ziel:

Ein reines lokales Draft-Dokument fuer eine Notion-Struktur erstellen, ohne
Notion zu beschreiben.

Nutzen:

- macht externe Management-Sicht vorbereitbar,
- reduziert spaeteres Chaos bei Notion-Sync,
- kann Product Bible, Roadmap und Decisions sauber spiegeln.

Risiko:

- verschiebt den naechsten spielbaren Produktbeweis,
- kann zu viel Prozess vor Spielmoment erzeugen.

### Option B: M16-BT Local Uferhain-to-Buildsite Rejoin Preview

Ziel:

Den naechsten isolierten Code-Proof bauen: Uferhain -> Slot -> Zuhause/Haus ->
Kamera/Fokus -> object-based Worker-Bauplatzmoment -> lokaler Hook.

Nutzen:

- setzt die wichtigste Produktbewegung nach M16-BQ fort,
- verbindet den Bauplatzmoment mit dem Talvori-Spine,
- beweist Spielgefuehl statt Management-Ordnung.

Risiko:

- Management-Sync bleibt noch manuell,
- der Code-Slice braucht strenge Scope-Grenzen, damit kein App-Flow entsteht.

Empfehlung:

```text
M16-BT Local Uferhain-to-Buildsite Rejoin Preview sollte als naechster
Produktschritt priorisiert werden.
```

M16-BW ist sinnvoll, sobald ein externer Management-Sync wirklich gestartet
werden soll. Vorher reicht M16-BV als Boundary: Repo bleibt Wahrheit, externe
Tools bleiben Spiegel.

## 12. M16-T-Update

M16-BV fuehrt die Gruppe `M16T-MGMT` ein:

- `M16T-MGMT-001` Repo as source of truth for project management,
- `M16T-MGMT-002` Notion as product overview mirror,
- `M16T-MGMT-003` Linear as work tracking mirror,
- `M16T-MGMT-004` External write approval rule.

Alle vier Items sind mit diesem Dokument fachlich dokumentiert. Sie erzeugen
keine externe Tool-Aktion und keine Implementierungsfreigabe.

## 13. Stop-Regeln

- keine Flutter-/Dart-Dateien,
- keine App-Integration,
- keine Route,
- keine Navigation,
- keine Persistenz,
- keine Supabase/local DB Writes,
- keine SRS-/`word_progress`-Aenderung,
- keine automatische Wortplatzierung,
- keine Assets,
- kein BuildState,
- keine Tests,
- keine Notion-Writes,
- keine Linear-Writes,
- keine GitHub-Writes,
- keine Plugin-Installation,
- kein Commit.
