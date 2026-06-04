# Talvori Welt: World-Design-Dokument-Map

Stand: 2026-06-04

Dieses Dokument ist die zentrale Uebersicht fuer alle World-Design-Dokumente.
Es ordnet Grundlagen, Detailplaene, Querschnittsthemen und Arbeitsregeln, damit
Talvori Welt vor weiterer Implementierung systematisch durchdacht wird.

Es ist ein reines Planungsdokument. Es wurden keine Dart-/Flutter-Dateien,
keine Assets, keine Supabase-Daten, keine SQLite-/Vokabeldaten, keine SRS-Daten,
kein `word_progress`, keine Reward Bridge, keine Persistenz, keine Secrets und
keine Release-Artefakte geaendert.

## 1. Zweck Des Dokument-Maps

Dieses Dokument ist die zentrale Uebersicht fuer alle World-Design-Dokumente.

Es soll verhindern, dass wichtige Querschnittsthemen vergessen werden:

- Lernwert,
- Weltwirkung,
- Balancing,
- Cloud/Kosten,
- Social/Sicherheit,
- Monetarisierung/Fairness,
- Performance,
- Datenschutz,
- SRS-/`word_progress`-Schutz,
- Testbarkeit.

Es legt fest, welches Detaildokument fuer welchen Bereich zustaendig ist.

Arbeitsregel:

Code soll erst folgen, wenn der passende Plan existiert. Je groesser der
Codeblock, desto klarer muss vorher dokumentiert sein:

- Ziel,
- Nicht-Ziele,
- Weltmodell,
- Lernwirkung,
- Balancing,
- Daten- und Kostenfolgen,
- Tests/Checks.

## 2. Bestehende Grundlagen

| Dokument | Rolle |
| --- | --- |
| `docs/220-talvori-world-professional-game-architecture-research.md` | Recherchiert Grundprinzipien professioneller 2.5D-/Aufbau-Welten: sichtbare Grafik und semantische Unsichtbar-Ebene, Tiles, Zonen, Nodes, Layer, Renderer-Unabhaengigkeit. |
| `docs/221-talvori-world-build-and-expansion-architecture.md` | Leitet daraus Talvori-Modelle fuer IslandObject, BuildZones, PathNodes, DockingPoints, Templates, Platzierungsvalidierung und Renderer-Trennung ab. |
| `docs/222-talvori-world-game-system-master-plan.md` | Denkt Talvori Welt als Gesamtsystem: Lernen, Ressourcen, Bauen, Social, Retention, Monetarisierung, Cloud, Betrieb und Folge-Dokumente. |
| `docs/world_design/223-learning-to-building-loop.md` | Konkretisiert den Kernloop: Lernarten erzeugen Ressourcen, Ressourcen erzeugen sichtbaren Baufortschritt, erste Aufgabenarten und erster technischer Slice. |

Diese Dokumente bilden den aktuellen Planungsunterbau. Neue World-Design-Dokumente
sollen sich auf sie beziehen und keine widerspruechlichen Nebensysteme
aufbauen.

## 3. Geplante Detaildokumente

| Dokument | Zweck |
| --- | --- |
| `docs/world_design/224-economy-balancing.md` | Ressourcen, Belohnungen, Kosten, Fortschrittsgeschwindigkeit, Quellen/Senken, weiche Limits und erste Diskussionswerte. |
| `docs/world_design/225-in-world-learning-ui.md` | Wie Lernaufgaben direkt in der Welt erscheinen: Bauplatz, Bibliothek, Bruecke, NPC, Companion, Nebelrettung und klassische Lernscreen-Ergaenzung. |
| `docs/world_design/226-build-progression-and-zones.md` | Bauphasen, Fundamente, BuildZones, Gebaeude, Deko, Innenraeume, Platzierungsregeln, PathNodes und Validierung. |
| `docs/world_design/227-monetization-and-cost-coverage.md` | Faire Einnahmemodelle, KI-/DeepL-/Cloud-Kosten, Plus, Founder, Cosmetics, Classroom/B2B, No-Pay-to-Win-Grenzen. |
| `docs/world_design/228-cloud-local-architecture.md` | Was lokal bleibt, was Cloud-authoritative ist, Cache, Sync, Offline, Konflikte, Skalierung, Preview/Detaildaten, Writes und Kostenkontrolle. |
| `docs/world_design/229-retention-liveops-comeback.md` | Daily Quests, Events, Comeback, saisonale Ziele, Streaks ohne Druck, private Nebel, sanfte Erinnerungen. |
| `docs/world_design/230-social-community-systems.md` | Freunde, Besuche, Reaktionen, gemeinsames Bauen, Community-Projekte, sichere Kommunikation, Moderationsgrenzen. |
| `docs/world_design/231-animation-and-liveliness.md` | Ambient, Bauanimation, Lernfeedback, Social-Animation, Comeback-Nebel, Companion-Reaktion, Performance und LOD. |
| `docs/world_design/232-onboarding-first-session.md` | Erste 1/5/15/30 Minuten, erster Wow-Moment, erste Insel, erste Aufgabe, erste Bauwirkung, Companion-Kommentar, erstes Tagesziel. |
| `docs/world_design/233-risk-checklist-and-cross-cutting-rules.md` | Kontrollliste fuer alle spaeteren Entscheidungen und Codebloecke: Schutzregeln, Datenrisiken, Kosten, Sicherheit, Tests, Scope-Grenzen. |

## 4. Querschnittsthemen

Jedes Detaildokument muss die folgenden Themen pruefen, soweit sie betroffen
sind:

- Lernwert: Welche Lernleistung wird geuebt?
- Weltwirkung: Was veraendert sich sichtbar in der Welt?
- Ressourcen/Balancing: Welche Quelle oder Senke entsteht?
- Kosten/KI/Cloud: Entstehen KI-, DeepL-, Storage-, Push- oder Cloud-Kosten?
- Monetarisierung/Fairness: Ist Premium fair und kein Lernersatz?
- Social/Sicherheit: Gibt es Freundes-, Community- oder Moderationsfolgen?
- Performance/Skalierung: Was passiert bei vielen Inseln, Items oder Events?
- Datenschutz/Moderation: Werden private Lern- oder Social-Daten geschuetzt?
- SRS-/`word_progress`-Schutz: Bleiben bestehende Lernsemantiken unangetastet?
- UI-Komplexitaet: Bleibt die Welt lesbar und nicht ueberladen?
- Spaeterer Rendererwechsel: Bleibt Logik getrennt vom Flutter-Renderer?
- Testbarkeit: Welche Regeln koennen automatisiert geprueft werden?
- Offline/Sync: Was kann lokal passieren, was braucht spaeter Cloud-Autoritaet?

## 5. Arbeitsregel Fuer Zukuenftige Features

Fuer spaetere Codex-Prompts und Implementierungsbloecke gelten diese Regeln:

- Kein groesserer Codeblock ohne passendes Detaildokument.
- Kein Reward-System ohne Balancing-Dokument.
- Keine Cloud Writes ohne Cloud-/Persistenzplan.
- Keine Social-Funktion ohne Social-/Moderationsplan.
- Keine Monetarisierung ohne Fairness- und Kostenpruefung.
- Keine In-World-Aufgabe ohne Learning-to-Building-Zuordnung.
- Keine Bau-/Connector-Funktion ohne BuildZone-/DockingPoint-Regeln.
- Keine KI-gestuetzte Weltwirkung ohne Kosten- und Kontrollregel.
- Keine Aenderung an SRS oder `word_progress` ohne eigenen Migrations- und
  Testplan.

Wenn ein Feature mehrere Bereiche beruehrt, muss das fuehrende Detaildokument
benannt werden. Die betroffenen Querschnittsdokumente muessen mindestens
geprueft werden.

## 6. Priorisierte Reihenfolge

Empfohlene Reihenfolge fuer die naechsten Detaildokumente:

1. `docs/world_design/224-economy-balancing.md`
2. `docs/world_design/225-in-world-learning-ui.md`
3. `docs/world_design/226-build-progression-and-zones.md`
4. `docs/world_design/232-onboarding-first-session.md`
5. `docs/world_design/227-monetization-and-cost-coverage.md`
6. `docs/world_design/228-cloud-local-architecture.md`
7. `docs/world_design/229-retention-liveops-comeback.md`
8. `docs/world_design/230-social-community-systems.md`
9. `docs/world_design/231-animation-and-liveliness.md`
10. `docs/world_design/233-risk-checklist-and-cross-cutting-rules.md`

Begruendung:

- Economy/Balancing muss vor jedem Reward- oder Baufortschritt klarer werden.
- In-World-Learning UI und Build Progression definieren den ersten spielbaren
  Kern.
- Onboarding/First Session entscheidet, ob Nutzer den Kern sofort verstehen.
- Monetarisierung und Cloud muessen vor teuren oder persistenten Features
  geplant werden.
- Retention, Social und Animation folgen, sobald der Kernloop sauber steht.
- Die Risk Checklist schliesst die Planungsphase als wiederverwendbare
  Kontrollinstanz.

## 7. Akzeptanzkriterien

Dieses Dokument ist gut, wenn:

- klar ist, welche Detaildokumente noch entstehen muessen,
- klar ist, welches Dokument wofuer zustaendig ist,
- Querschnittsthemen nicht vergessen werden,
- zukuenftige Codex-Prompts daran ausgerichtet werden koennen,
- spaetere Implementierung nicht mehr ohne Plan startet,
- Schutzregeln fuer SRS, `word_progress`, Supabase Writes, Reward Bridge,
  Persistenz und Secrets sichtbar bleiben.
