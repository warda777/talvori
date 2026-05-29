# Lokale Grundlage für „Wörter, die ich kenne“

## Ausgangspunkt

Der V-Button oben links im HomeScreen führt aktuell noch in den alten `VocabSortScreen`. Dieser Pfad hängt an `VocabSortController` und `SupabaseWordRepository` und schreibt bekannte Wörter über die alte Supabase-/`user_words`-Logik.

Für den nächsten Umbau soll zuerst die lokale Datenbasis stehen, bevor der V-Button selbst auf eine neue UI umgestellt wird.

## Entscheidung

Talvori nutzt für den MVP einen Hybrid-Ansatz:

- `word_world_memberships.is_known` bleibt membership-bezogen.
- Ein Wort kann also in einer Wortwelt bekannt sein und in einer anderen weiterhin aktiv bleiben.
- Die globale Ansicht „Wörter, die ich kenne“ sammelt alle Wörter, die in mindestens einer Membership `is_known = 1` haben.
- Es wird kein neues globales Known-Feld auf `words` eingeführt.

Das passt zur vorhandenen lokalen Datenbank und vermeidet neue Migrationen.

## Repository-Methoden

`WordRepository` stellt jetzt lokale Known-Methoden bereit:

- `loadKnownWords()`
- `loadKnownWordsForCategory(...)`
- `loadUnknownWordsForReview(...)`
- `countKnownWords()`
- `restoreKnownWord(...)`

`loadKnownWords()` dedupliziert Wörter, falls dasselbe Wort in mehreren Wortwelten als bekannt markiert ist.

## Provider-Änderung

Die lokale Quelle `LocalLearningSource.knownWords` basiert jetzt auf `word_world_memberships.is_known`.

Vorher wurde „Wörter, die ich kenne“ aus SRS-Fortschritt (`isMastered` oder Stage 5) abgeleitet. Für den V-Button-MVP ist die Ansicht jetzt bewusst manuell/membership-basiert.

## Controller-Methoden

`CategoryVocabularyController` enthält vorbereitende Datenmethoden:

- `markKnown(categoryId, word)`
- `restoreKnown(categoryId, word)`

Beide Methoden arbeiten lokal über `setWordWorldMembershipKnown(...)` beziehungsweise `restoreKnownWord(...)` und invalidieren Kategorie-, Known-, Count- und Practice-Provider.

## Practice-/Lernmodus-Auswirkung

Normale lokale Practice-Karten laden Wörter über `loadWordsForWordWorld(...)`. Diese Methode filtert standardmäßig:

- `is_disabled = 0`
- `is_known = 0`

Dadurch erscheinen bekannte Membership-Wörter nicht mehr im normalen Practice-/Lernmodus-Pfad. Verwaltungs- und Vocab-Listen können sie weiterhin anzeigen, wenn sie bewusst mit `includeDisabled: true` beziehungsweise dem vorhandenen Kategorie-Provider geladen werden.

## Noch offen

- V-Button auf eine neue lokale „Wörter prüfen“-UI umbauen.
- Alten `VocabSortScreen` ablösen oder lokal neu verdrahten.
- Swipe- oder Review-Karten-UI für „Kenne ich“ / „Noch lernen“ bauen.
- Rückgängig-Funktion sichtbar in der UI anbieten.
- Optional SRS-mastered Wörter später als eigene Quelle von manuell bekannten Wörtern trennen.
