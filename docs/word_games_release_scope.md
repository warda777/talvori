# Wortspiele Release-Scope

Stand: 2026-05-30

Dieses Dokument finalisiert den Wortspiel-Scope fuer den Talvori-MVP. Es beschreibt, welche sichtbaren Wortspiele im MVP als nutzbar gelten, welche nur vorbereitet sind und welche Store-Aussagen vermieden werden muessen.

## 1. Gepruefte Bereiche

Gepruefte Dateien und Bereiche:

- `lib/features/home/ui/screens/vocab_screen.dart`
- `lib/features/home/application/vocab_controller.dart`
- `lib/features/home/ui/widgets/vocab_tile.dart`
- `lib/features/home/ui/widgets/vocab_promo_card.dart`
- `lib/features/home/ui/screens/word_duel_preview_screen.dart`
- einzelne Wortspiel-Screens unter `lib/features/home/ui/screens/*game_screen.dart`
- Wortspiel-Tests unter `test/features/*game_screen_test.dart`
- `test/features/home_screen_layout_test.dart`
- `docs/store_metadata_draft.md`
- `docs/store_release_checklist.md`
- `docs/release_mvp_remaining_plan.md`

## 2. Sichtbare Wortspiele

Der Wortspiele-Hub zeigt aktuell diese Bereiche:

### Schnellspiele

- Blitzrunde
- Wort-Jagd
- Wort-Duell
- Hoer-Fang
- Wort erkennen

### Woerter Bauen

- Wort-Match
- Wort-Puzzle
- Lueckenwort
- Hangman
- Silben-Regen
- Wortpfad
- Wortsuche

### Smart Challenges

- Hoer & Schreib
- Kontext-Challenge
- Gegenwort
- Synonym-Raetsel
- Boss-Fight
- Daily Word Quest

## 3. MVP-Tauglich Nutzbar

Als MVP-tauglich nutzbar gelten alle Wortspiele, die im Hub auf echte Spielscreens fuehren und durch Tests abgedeckt sind:

- Blitzrunde
- Wort-Jagd
- Hoer-Fang
- Wort erkennen
- Wort-Match
- Wort-Puzzle
- Lueckenwort
- Hangman
- Silben-Regen
- Wortpfad
- Wortsuche
- Hoer & Schreib
- Kontext-Challenge
- Gegenwort
- Synonym-Raetsel
- Boss-Fight
- Daily Word Quest

Einschraenkung:

- KI-basierte Spiele wie Kontext-Challenge, Gegenwort und Synonym-Raetsel duerfen nur vorsichtig beworben werden. Sie muessen mit Fehler-/Fallback-Zustaenden leben koennen und duerfen nicht als fehlerfreie KI-Funktion beworben werden.
- Spiele mit kleinen Wortbestaenden haben eigene leere oder zu-kleine-Zustandslogik. Diese Zustaende bleiben vor Store-Screenshots nochmals manuell zu pruefen.

## 4. Nur Vorschau / Geplant

### Wort-Duell

Status: Vorschau

Begruendung:

- `Wort-Duell` oeffnet `WordDuelPreviewScreen`.
- Es startet keinen echten Multiplayer.
- Der Preview-Screen sagt explizit, dass der Mehrspieler-Modus vorbereitet ist.
- Der Screen veraendert keine Punkte und keinen Lernfortschritt.

Store-Regel:

- Wort-Duell darf im MVP nicht als fertiger Multiplayer-Modus beworben werden.
- Falls sichtbar, nur als vorbereiteter Ausblick oder gar nicht in Store-Screenshots verwenden.

## 5. Geaenderte Texte

Direkt verbessert:

- Die Standard-Kachelmarke wurde von `bald spielbar` auf `spielbar` geaendert.
- Wort-Duell erhaelt die Kachelmarke `Vorschau`.
- Der Promo-Text im Wortspiele-Hub sagt nicht mehr, dass Wortspiele erst bald kommen, sondern beschreibt kurze Runden und markierte KI-/Ausblick-Modi.

Nicht geaendert:

- Keine Spiel-Logik
- Keine Navigation
- Keine Datenquellen
- Keine Rewards-/Progress-Logik
- Keine KI-Logik
- Keine neuen Spiele

## 6. Vorhandene Tests

Vorhandene Testabdeckung umfasst unter anderem:

- `test/features/home_screen_layout_test.dart`
- `test/features/word_duel_preview_screen_test.dart`
- `test/features/speed_round_game_screen_test.dart`
- `test/features/word_hunt_game_screen_test.dart`
- `test/features/audio_catch_game_screen_test.dart`
- `test/features/word_recognition_game_screen_test.dart`
- `test/features/word_match_game_screen_test.dart`
- `test/features/gap_word_game_screen_test.dart`
- `test/features/word_puzzle_game_screen_test.dart`
- `test/features/hangman_game_screen_test.dart`
- `test/features/syllable_rain_game_screen_test.dart`
- `test/features/word_path_game_screen_test.dart`
- `test/features/word_search_game_screen_test.dart`
- `test/features/listen_and_write_game_screen_test.dart`
- `test/features/context_challenge_game_screen_test.dart`
- `test/features/opposite_word_game_screen_test.dart`
- `test/features/synonym_riddle_game_screen_test.dart`
- `test/features/boss_fight_game_screen_test.dart`
- `test/features/daily_word_quest_game_screen_test.dart`
- `test/features/game_word_source_picker_test.dart`
- `test/features/word_game_progress_controller_test.dart`
- `test/features/word_game_rewards_controller_test.dart`

Der Hub-Test prueft jetzt auch, dass spielbare Karten nicht mehr als `bald spielbar` markiert werden und Wort-Duell als `Vorschau` erscheint.

## 7. Offene Risiken

- KI-Spiele koennen je nach Konfiguration oder Netzwerkzustand Fehler-/Fallback-Zustaende zeigen.
- Sehr kleine Wortbestaende muessen fuer Store-Screenshots vermieden oder bewusst als leerer Zustand gezeigt werden.
- Wort-Duell ist sichtbar, aber nicht als echter Multiplayer nutzbar.
- Daily Word Quest und Boss-Fight sollten vor Screenshot-Erstellung nochmal auf echten Release-Daten geprueft werden.
- Store-Texte duerfen Wortspiele nicht als kompetitives Multiplayer- oder Premium-Angebot darstellen.

## 8. Store- und Screenshot-Regeln

Store-Beschreibung:

- Wortspiele duerfen als unterstuetzende Lernform genannt werden.
- Keine Aussage wie `Mehrspieler-Duell verfuegbar`.
- Keine Aussage wie `KI ist fehlerfrei`.
- Keine Aussage zu Premium-/Abo-Spielen.

Screenshots:

- Nur stabile, spielbare Wortspielbereiche zeigen.
- Wort-Duell nicht als fertiges Feature zeigen.
- KI-Spiele nur zeigen, wenn der konkrete Screenshot stabil und nicht irrefuehrend ist.
- Keine Preview-Karte als Haupt-Screenshot verwenden.

## 9. Empfehlung

Fuer den MVP ist der Wortspiele-Scope ausreichend, wenn Store-Texte bei `Wortspiele entdecken`, `kurze Uebungen` oder `spielerisch festigen` bleiben. Wort-Duell bleibt als sichtbare Vorschau, darf aber nicht als fertiger Multiplayer beworben werden.
