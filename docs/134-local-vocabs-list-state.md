# Lokaler Vocabs- und Wortlisten-Pfad: aktueller Stand

## 1. Ausgangslage

Der lokale End-to-End-Lernflow funktioniert:

Wortwelten local -> CategoryDetail local -> Start -> LearnMode local

Wortwelten und das CategoryDetail-Wheel sind lokal angebunden. Die sichtbaren Labels und technischen lokalen Kategorie-IDs sind getrennt. Der Vocabs-Counter im lokalen CategoryDetail zeigt bereits die lokale Wortanzahl der aktuell ausgewaehlten Kategorie.

Ziel dieses Schritts war, den Klick auf die Vocabs-Kachel im lokalen Branch anzubinden.

## 2. Aktueller funktionierender Flow

Der aktuelle lokale Vocabs-Flow lautet:

Wortwelten -> Health & Fitness -> CategoryDetail local -> Vocabs -> LocalWordListScreen

## 3. Was funktioniert jetzt

- Der Klick auf die Vocabs-Kachel oeffnet eine lokale Wortliste.
- Die Wortliste nutzt `selectedCategoryId`.
- Der Titel nutzt das sichtbare `displayLabel`, zum Beispiel `Health & Fitness`.
- Technische seed-IDs werden in der Wortlisten-UI nicht angezeigt.
- Lokale Woerter und Uebersetzungen werden angezeigt.
- Leere Kategorien zeigen den Empty-State `Keine lokalen Wörter verfügbar`.
- Die Zuruecknavigation funktioniert ueber die normale Navigator-/AppBar-Navigation.

## 4. Technische Bausteine

Wichtige Bausteine:

- `localWordsForCategoryProvider`
- `WordRepository.loadWordsForCategory(...)`
- `localBootstrapProvider`
- `LocalWordListScreen`
- lokaler `CategoryDetailScreen.onVocabs`
- `LocalCategoryDetailGroupItem.displayLabel`
- `LocalCategoryDetailGroupItem.localCategoryId`

Der lokale Provider laedt ueber `localBootstrapProvider` und das lokale `WordRepository`. Er nutzt keine Supabase-Provider und keinen Online-`WordListController`.

## 5. Bewusst nicht geändert

- Der Online-`WordListScreen` bleibt unveraendert.
- Keine Supabase-Logik wurde geaendert.
- Kein Online-Flow wurde umgebaut.
- Kein LearnMode-Umbau.
- Kein WordHub-Umbau.

## 6. Tests

Dokumentierte und relevante Tests:

- `test/core/local_database/local_words_for_category_provider_test.dart`
- `test/features/local_word_list_screen_test.dart`
- `test/features/category_detail_screen_local_branch_test.dart`
- `test/core/local_database/local_word_count_provider_test.dart`
- `test/features/word_hub_screen_local_branch_test.dart`
- `test/features/learn_mode_screen_local_branch_test.dart`

Diese Tests sichern ab:

- lokale Woerter werden fuer eine lokale Kategorie geladen
- leere oder ungueltige Kategorie-IDs liefern eine leere Liste
- `LocalWordListScreen` zeigt Woerter und Uebersetzungen
- Empty-State erscheint bei leerer Kategorie
- CategoryDetail local oeffnet die lokale Wortliste mit `displayLabel`
- bestehende Wortwelten-, CategoryDetail- und LearnMode-local-Flows bleiben gruen

## 7. Bekannte offene Punkte

- Suche und Sortierung in der lokalen Wortliste fehlen noch.
- Wort-Detail und lokales Editieren sind noch nicht angebunden.
- Weitere Kategorien muessen spaeter importiert oder gemappt werden.
- Das Design der lokalen Wortliste kann spaeter an den Dark-Neon-Stil angepasst werden.

## 8. Nächster sinnvoller Schritt

Sinnvolle naechste Schritte sind:

- lokale Wortliste mit Suche und Sortierung erweitern
- lokale Wort-Detailansicht planen
- weitere Kategorien importieren oder mappen
