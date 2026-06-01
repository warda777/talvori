# Talvori Welt Architecture Notes

Stand: 2026-06-01

Diese Notizen skizzieren die technische Zielrichtung fuer Talvori Welt. Sie
sind keine Implementierung und keine Migration. Es wurden keine Produktivdaten,
keine Supabase-Daten, keine Imports, keine SQLite-/Vokabeldaten, keine SRS-Daten
und kein `word_progress` geaendert.

## 1. Architekturprinzip

Talvori Welt darf die bestehende Lernbasis nicht zerstoeren. Weltlogik,
Lernlogik, Companion-Logik, Social-Logik und Rendering bleiben getrennt.

Grundsatz:

- Lernen bleibt fachlich korrekt und testbar.
- SRS/`word_progress` bleibt unveraendert, bis es eine eigene Migration mit
  Tests gibt.
- Weltfortschritt wird aus LearningResult abgeleitet, nicht in die
  Lernengine hineingemischt.
- Rendering liest World State, aber entscheidet keine Rewards.
- KI darf Vorschlaege liefern; deterministische Logik entscheidet Besitz,
  Rewards, Premium und gespeicherte Weltzustaende.

## 2. Vorgeschlagene Module

### `features/home`

Moegliche Dateien:

- `world_home_screen.dart`
- `talvori_world_globe.dart`
- `home_top_status_bar.dart`
- `home_smart_hub_menu.dart`

Aufgabe:

- Talvori-Welt-Zentrale
- Globe als Hauptaktion
- Status- und Smart-Hub-Navigation
- Companion-Entry

Aktuelle Home-Entscheidung:

- Der Smart-Hub ersetzt im ersten Talvori-Welt-Home das permanente Bottom-Dock.
- Ziel ist ein ruhiger Hero-Screen: ein Planet, ein Companion, ein
  ausklappbarer Hub.

### `features/companion`

Moegliche Dateien:

- `selected_companion_service.dart`
- `companion_state.dart`
- `companion_persona.dart`
- `companion_chat_sheet.dart`

Aufgabe:

- aktive Persona Tali oder Vori
- Companion-Zustaende
- Bubble/Fokus/Chat-Sheet
- Quick Actions
- Trennung von Human Chat

### `features/world`

Moegliche Dateien:

- `world_region_screen.dart`
- `user_city_screen.dart`
- `plot_detail_screen.dart`

Aufgabe:

- lokale Region
- eigener Plot
- Gebaeude, Ressourcen und sichtbarer Fortschritt
- spaeter Freunde/Showcase-Anbindung

### `core/learning_rewards`

Moegliche Dateien:

- `learning_reward_bridge.dart`
- `reward_mapper.dart`
- `learning_result.dart`
- `world_reward_service.dart`
- `resource_wallet.dart`
- `reward_event.dart`

Aufgabe:

- Bruecke zwischen bestehender Lernlogik und Weltressourcen
- keine Mutation bestehender SRS-Semantik
- testbare Reward-Regeln

### `features/words`

Rolle:

- Word inventory / raw material provider
- liefert Woerter, Phrasen und Kategorien als Rohmaterial
- bleibt getrennt von Weltbesitz und Renderer

### `features/tagesimpuls`

Rolle:

- Sentence Sparks
- Companion message material
- kleine Kontextimpulse aus Woertern
- spaeter Quest-Ausloeser

### `features/games`

Rolle:

- Challenge modules for building quests
- bestehende Wortspiele koennen LearningResults liefern
- keine direkte Renderer-Kopplung

### `features/social`

Rolle:

- friends
- reactions
- showcase
- human chat later

Nicht im ersten Slice:

- global public chat
- voller Social Graph
- Moderationssystem

### `core/entitlements`

Moegliche Konzepte:

- `free`
- `welt_plus`
- `founder`
- `classroom`
- feature limits

Regel:

- Entitlements duerfen den ersten Wow-Moment nicht blockieren.
- Premium/Ownership darf nicht durch KI entschieden werden.

## 3. Reward Bridge Flow

Ziel:

Bestehende Lernlogik bleibt verantwortlich fuer Lernen. Die Welt reagiert auf
das Ergebnis.

Flow:

1. User answers an existing learning task.
2. Existing learning/SRS progress updates as before.
3. A `LearningResult` is emitted.
4. `RewardBridge` receives it.
5. `RewardMapper` converts it to resources.
6. `WorldRewardService` stores a `RewardEvent`.
7. `WorldRewardService` updates `ResourceWallet`.
8. UI shows building progress or build option.

Merksatz:

> SRS entscheidet Lernen. Reward Bridge entscheidet Ressourcen. Renderer zeigt
> Weltzustand.

## 4. LearningResult Entwurf

Ein spaeteres `LearningResult` koennte enthalten:

- `wordId`
- `categoryId` oder `wordWorldId`
- `modeId`
- `exerciseType`
- `wasCorrect`
- `quality`
- `duration`
- `streakContext`
- `source`
- `createdAt`

Wichtig:

- Es ist ein Event/DTO fuer Rewards.
- Es ersetzt keine `word_progress`-Zeile.
- Es darf keine SRS-Regeln duplizieren.

## 5. RewardMapper Entwurf

Beispielmapping:

- meaning recognition -> `stone`
- typing -> `wood`
- cloze sentence -> `glass`
- phrase/context -> `residents`
- Companion/NPC answer -> `light`

Moegliche Modifikatoren:

- erste korrekte Antwort des Tages
- Wortweltbezug
- Comeback
- schwieriges Wort
- Sentence Spark genutzt

Nicht erlaubt:

- Pay-to-win-Boni
- KI-generierte Besitzentscheidungen
- direkte Veraenderung von `word_progress`

## 6. World State Entwurf

Lokale fruehe Modelle:

- `WorldRegion`
- `UserPlot`
- `WorldBuilding`
- `BuildingLevel`
- `ResourceWallet`
- `RewardEvent`
- `CompanionWorldHint`

Erster Prototyp:

- nur lokal
- keine DB-Migration zwingend
- kann mit Provider/In-Memory/Fake Repository starten
- persistente Speicherung erst nach UI/Flow-Beweis

## 7. Rendering

Fruehe Optionen:

- Flutter Widgets
- `CustomPainter`
- einfache AnimationController fuer Globe/Pulse

Spaeter pruefen:

- Flame
- Rive
- Tiled
- JSON Map/Region Daten

Regel:

- Renderer bekommt World State.
- Renderer berechnet keine Lernrewards.
- Renderer schreibt keine SRS- oder `word_progress`-Daten.

## 8. Supabase Und Cloud

MVP-Welt-Prototyp:

- lokal zuerst
- keine Supabase Writes
- keine Cloud-Abhaengigkeit fuer ersten Wow-Moment

Spaeter:

- Account-Sync
- Cloud-Backup
- Friends/Showcase
- Chat Sync
- Content-Package-Sync

Supabase bleibt strategisch wichtig, aber nicht als Voraussetzung fuer den
lokalen Welt-Prototyp.

## 9. KI Grenzen

KI darf:

- Saetze vorschlagen
- Erklaerungen formulieren
- Companion-Antworten generieren
- Quest-Ideen aus 3-5 Woertern vorschlagen
- Kontext fuer importierte Woerter liefern

KI darf nicht:

- Ressourcenbesitz final entscheiden
- Premium/Entitlements entscheiden
- gespeicherten Weltzustand autoritativ veraendern
- SRS-Regeln veraendern
- ungepruefte Inhalte automatisch als final freigeben

## 10. Explizite Warnung

Do not mutate existing SRS/`word_progress` semantics without a dedicated
migration plan and tests.

Keine direkte Kopplung:

- Lernengine -> Renderer
- Renderer -> SRS
- KI -> Persistenter Besitz
- Supabase -> ungepruefter lokaler Fortschritt

Wenn Weltfortschritt gespeichert wird, muss er als eigene Welt-/Reward-Schicht
modelliert werden.
