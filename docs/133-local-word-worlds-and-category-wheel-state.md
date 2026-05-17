# Lokale Wortwelten und CategoryDetail-Wheel: aktueller Stand

## 1. Ausgangslage

Der lokale End-to-End-Lernflow funktioniert bereits:

Home -> Wortwelten local -> CategoryDetail local -> Start -> LearnMode local

Seit `docs/132-local-learnmode-end-to-end-state.md` wurden `WordHubScreen` im lokalen Modus und `CategoryDetailScreen` im lokalen Modus weiterentwickelt. Ziel war, aus dem technischen "Word Hub" eine produktnaehere lokale Themenauswahl zu machen und die lokale CategoryDetail-Wheel-Logik fachlich sauberer an die sichtbaren WordHub-Kacheln zu koppeln.

## 2. Wortwelten

Der lokale WordHub heisst sichtbar jetzt "Wortwelten". Der Online-Flow bleibt unveraendert und kann weiterhin den bestehenden "Word Hub"-Begriff verwenden.

Die lokale Wortwelten-Ansicht verwendet weiterhin die alte WordHub-Taxonomie als sichtbare Struktur. Die Kacheln bleiben also produktnahe Themenkacheln wie "Health & Fitness", "Home & Living", "Food & Cooking" oder "Travel".

Die lokalen Kacheln wurden optisch an den Dark-Neon-Stil angenaehert:

- dunkle Fuellung
- individuelle, harmonische Kachelfarben
- Neon-Umrandung
- innere schmale Kontur
- dezenter Glow
- klare weisse Schrift
- lokaler Counter unten rechts

Nicht gemappte Kacheln bleiben sichtbar. Sie starten aber nicht blind eine falsche lokale Kategorie und fallen insbesondere nicht automatisch auf `seed-category-basics` zurueck.

## 3. Kacheln als Wheel-Items

Die fachliche Korrektur ist:

- Eine WordHub-Section wie "Life & Daily Flow" ist nur eine Ueberschrift.
- Die Kacheln darunter sind die auswaehlbaren Lernkategorien.
- Das CategoryDetail-Wheel zeigt deshalb die WordHub-Kacheln selbst.

Beispiele fuer Wheel-Items:

- Health & Fitness
- Home & Living
- Food & Cooking
- Style & Fashion
- Money & Shopping
- Productivity
- Travel
- weitere WordHub-Kacheln aus der Taxonomie

Wichtig: "Health & Fitness" ist kein Container fuer "Basics", "Travel" oder "Exam Practice". Die vorherige Mehrfach-Item-Interpretation wurde fachlich korrigiert. "Health & Fitness" ist selbst eine Lernkategorie.

## 4. DisplayLabel vs. localCategoryId

Sichtbare Labels und technische lokale IDs sind getrennt:

- `displayLabel` ist der sichtbare Produktname, zum Beispiel `Health & Fitness`.
- `localCategoryId` ist die interne lokale Kategorie-ID, zum Beispiel `seed-category-basics`.

Seed-IDs werden nicht in der UI angezeigt. Die Trennung wird ueber `LocalCategoryDetailGroupItem` modelliert. Dadurch koennen Wortwelten-Kachel, CategoryDetail-Wheel, Vocabs-Counter und LearnMode-Start denselben fachlichen Bezug behalten, ohne technische IDs sichtbar zu machen.

## 5. Aktuelle Mappings

Aktueller lokaler Seed-/Teststand:

- `Health & Fitness` -> `seed-category-basics`
- `Travel` -> `seed-category-travel`
- nicht gemappte Kacheln -> kein Start, Count `0` oder Pending-Zustand

Es gibt keinen globalen Fallback auf `seed-category-basics`.

## 6. Counts

`localCategoryDetailGroupItemsProvider` reichert die provider-/DB-freien Resolver-Items lokal mit `vocabsCount` an.

Die Counts kommen aus der lokalen Datenbasis, nicht aus Supabase:

- Die Wortwelten-Kachel zeigt den Count der jeweils gemappten lokalen Kategorie.
- `Health & Fitness` zeigt aktuell den Count von `seed-category-basics`.
- `Travel` zeigt aktuell den Count von `seed-category-travel`.
- Nicht gemappte Kacheln zeigen keinen falschen Count aus einer anderen Kategorie.

Im lokalen CategoryDetail folgt der Vocabs-Counter dem aktuell ausgewaehlten Wheel-Item. Wenn sich das Wheel-Item aendert, muss der sichtbare Count zur internen `selectedCategoryId` passen.

## 7. CategoryDetail local

`CategoryDetailScreen` im lokalen Modus akzeptiert lokale Wheel-Items.

Das aktuell angetippte WordHub-Item bestimmt den lokalen `selectedIndex`. Dadurch ist beim Einstieg ueber "Health & Fitness" auch "Health & Fitness" im Wheel vorausgewaehlt.

Die lokale Auswahl trennt weiterhin:

- sichtbares Wheel-Label: `displayLabel`
- technisches Startziel: `localCategoryId`

`selectedCategoryId` folgt dem aktuell ausgewaehlten Wheel-Item. Der Startbutton oeffnet `LearnModeScreen(useLocalOfflineFlow: true, localCategoryId: selectedCategoryId)` fuer genau diese lokale Kategorie.

Nicht gemappte Items duerfen nicht blind `seed-category-basics` starten. Wenn ein Wheel-Item keine `localCategoryId` hat, muss der lokale Flow kontrolliert blockieren oder einen Hinweis anzeigen.

## 8. Tests

Gepruefte und relevante Testbereiche:

- `test/features/word_hub_screen_local_branch_test.dart`
- `test/features/category_detail_screen_local_branch_test.dart`
- `test/core/local_database/local_category_detail_group_resolver_test.dart`
- `test/core/local_database/local_category_detail_group_items_provider_test.dart`
- `test/core/local_database/local_word_count_provider_test.dart`
- `test/features/learn_mode_screen_local_branch_test.dart`

Diese Tests sichern insbesondere ab:

- lokale Wortwelten zeigt sichtbare Taxonomie-Labels
- keine technischen seed-IDs in der UI
- gemappte Kacheln erhalten lokale Counts
- nicht gemappte Kacheln starten nicht versehentlich eine falsche Kategorie
- CategoryDetail local nutzt Display-Labels fuer das Wheel
- Start nutzt intern die passende lokale Kategorie-ID

## 9. Bekannte offene Punkte

- Weitere Kategorien muessen spaeter lokal gemappt oder importiert werden.
- Nicht gemappte Kacheln brauchen ggf. bessere Nutzerkommunikation.
- Die lokale Datenbasis ist weiterhin ein Seed-/Bootstrap-Stand.
- Der Analyzer in `word_hub_screen.dart` enthaelt bekannte Alt-Issues, die bewusst nicht im Rahmen dieses Umbaus bereinigt wurden.

## 10. Naechster sinnvoller Schritt

Sinnvolle naechste Schritte sind:

- weitere Kategorien lokal importieren oder mappen
- die Nutzerfuehrung fuer nicht gemappte Kacheln verbessern
- den lokalen CategoryDetail-Vocabs-Click bzw. eine lokale Wortliste planen
