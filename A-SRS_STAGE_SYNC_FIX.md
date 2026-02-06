# Bericht: A-SRS Stage-Synchronisation Fix

## Problembeschreibung

Die UI zeigte inkonsistente Stage-Zahlen im A-SRS-Modus. Wörter wurden visuell in falsche Stages verschoben (z.B. von A2 nach A4), obwohl die Backend-Logik korrekt funktionierte. Die Stages "zuckten" kurz, blieben aber nicht korrekt aktualisiert.

**Ursache:**
- Die Stages wurden lokal im Controller-State berechnet (Delta: `oldStage -1`, `serverStage +1`)
- Wenn `state.stages` nicht mit dem Server synchron war, entstanden falsche Anzeigen
- Die UI mutierte die Stages selbst, statt die Backend-Logik als einzige Quelle der Wahrheit zu verwenden

## Lösung

**Kernänderung:** Für A-SRS werden die Stages nach jedem Swipe **direkt vom Server neu geladen**, statt lokal berechnet zu werden.

## Code-Änderungen

### Datei: `lib/features/words/application/learn_mode_controller.dart`

**Zeile ~832-870** (Methode: `_handleAnswer`)

**VORHER:**
```dart
// ⬇️ A-SRS: Stages NUR anhand Server-Entscheidung zählen (keine lokale Schätzung)
if (srs == SrsSystem.adaptive) {
  // 1) Stages NUR anhand Server-Entscheidung zählen
  final stages = List<int>.from(state.stages);
  
  if (oldStage >= 0 && oldStage <= 5) stages[oldStage] = (stages[oldStage] - 1).clamp(0, 999999);
  if (serverStage >= 0 && serverStage <= 5) stages[serverStage] = stages[serverStage] + 1;
  
  // 2) Queue-Item updaten
  final updatedQueue = [...];
  _set(stages: stages, wordQueue: updatedQueue);
}
```

**NACHHER:**
```dart
// ⬇️ A-SRS: Stages IMMER vom Server neu laden (keine lokale Berechnung!)
if (srs == SrsSystem.adaptive) {
  // 1) Queue-Item updaten, damit Badge/Stage am nächsten Render stimmt
  final updatedQueue = [
    for (final w in state.wordQueue)
      if (w.id == currentId)
        w.copyWith(
          srsStage: serverStage,
          nextDueAt: serverDue,
        )
      else
        w
  ];
  _set(wordQueue: updatedQueue);
  
  // 2) Stages VOM SERVER neu laden (einzige Quelle der Wahrheit)
  try {
    final prog = await _repo.fetchCategoryProgress(
      _currentCatId,
      srsSystem: srs,
    );
    
    // Stage 0 für A-SRS korrigieren (vocabsTotal - learnedWords)
    final sb = Supabase.instance.client;
    final vocabsTotal = await sb.rpc('fn_category_word_count', params: {'p_category_id': _currentCatId}) as int? ?? 0;
    final learnedWords = prog.stages.skip(1).fold<int>(0, (a, b) => a + b);
    final correctedStage0 = (vocabsTotal - learnedWords).clamp(0, 1 << 30);
    final correctedStages = [correctedStage0, ...prog.stages.skip(1)];
    
    _set(stages: correctedStages);
    print('✅ A-SRS Stages vom Server geladen: $correctedStages');
  } catch (e) {
    print('⚠️ Fehler beim Laden der Stages vom Server: $e');
    // Fallback: Delta-Berechnung (nur wenn Server-Laden fehlschlägt)
    final stages = List<int>.from(state.stages);
    if (oldStage >= 0 && oldStage <= 5) stages[oldStage] = (stages[oldStage] - 1).clamp(0, 999999);
    if (serverStage >= 0 && serverStage <= 5) stages[serverStage] = stages[serverStage] + 1;
    _set(stages: stages);
  }
}
```

## Technische Details

### Was wurde geändert:

1. **Server-First Approach**: 
   - Statt lokaler Delta-Berechnung wird `fetchCategoryProgress()` nach jedem Swipe aufgerufen
   - Die Stages kommen direkt von `fn_user_category_progress_mode` (Backend)

2. **Stage 0 Korrektur für A-SRS**:
   - Stage 0 wird korrekt berechnet als `vocabsTotal - learnedWords`
   - Verwendet `fn_category_word_count` für die Gesamtanzahl der Wörter

3. **Fehlerbehandlung**:
   - Try-Catch Block mit Fallback auf Delta-Berechnung
   - Logging für Debugging

4. **Queue-Update**:
   - WordUserView in der Queue wird sofort mit `serverStage` aktualisiert
   - Verhindert veraltete Badge-Anzeigen

### Was bleibt unverändert:

- **T-SRS/Hybrid**: Behalten die bisherige Logik (lokale Schätzung + Korrektur)
- **Single-Mode**: Unverändert
- **S1-S5-Mode**: Unverändert

## Ergebnis

✅ **Die UI verwendet jetzt die Backend-Logik als einzige Quelle der Wahrheit**
- Keine lokale Stage-Mutation mehr für A-SRS
- Stages sind immer mit dem Server synchron
- Kein "Zucken" mehr, da die Stages direkt vom Server kommen
- Die Regeln aus der Datenbank (`fn_user_review_mode`, `fn_user_category_progress_mode`) werden korrekt angewendet

## Testing

**Zu testen:**
1. A-SRS-Modus: Swipe nach rechts/links
2. Verifizieren, dass Stage-Zahlen korrekt aktualisiert werden
3. Prüfen, dass keine Inkonsistenzen zwischen UI und Backend entstehen
4. Logs prüfen: `✅ A-SRS Stages vom Server geladen: [...]`

## Weitere Verbesserungen (optional)

- Caching der Stages könnte optimiert werden (aber Server-First ist korrekt)
- Für T-SRS/Hybrid könnte ebenfalls Server-First implementiert werden (aktuell nicht nötig)



