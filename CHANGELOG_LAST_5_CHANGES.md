# Bericht: Änderungen der letzten 5 Runden

## Übersicht
Dieser Bericht dokumentiert alle Änderungen, die in den letzten 5 Entwicklungsrunden vorgenommen wurden, um das Problem mit der A-SRS Stage-Synchronisation zwischen Frontend und Backend zu beheben.

---

## Problemstellung
Die UI zeigte inkorrekte Stage-Zahlen nach Swipes im A-SRS-Modus. Speziell:
- Wörter wurden von Stage 2 nach Stage 1 verschoben (statt nach Stage 3)
- Wörter blieben in Stage 1, obwohl sie korrekt beantwortet wurden (sollten nach Stage 2)
- Die CategoryDetailScreen zeigte während des Refreshs veraltete Stage-Werte

---

## Änderung 1: Debug-Logs für Fallback-Mechanismus hinzugefügt

**Datei:** `lib/features/words/ui/screens/category_detail_screen.dart`

**Änderung:**
- Debug-Logs hinzugefügt, um zu verfolgen, warum der Fallback auf `LearnModeController`-Stages nicht greift
- Loggt `currentId`, `learnCatId` und `learnStages` für besseres Debugging

**Code:**
```dart
debugPrint('🔍 CategoryDetail Fallback-Check: currentId=$currentId learnCatId=$learnCatId learnStages=$learnStages');
```

**Zweck:** Identifizierung, warum der Fallback-Mechanismus nicht funktioniert, wenn `categoryProgressProvider` während des Refreshs im Loading-State ist.

---

## Änderung 2: Fallback-Logik verbessert

**Datei:** `lib/features/words/ui/screens/category_detail_screen.dart`

**Änderung:**
- Fallback-Bedingung verbessert: Prüft jetzt auch, ob `learnStages` gültige Werte enthält (`any((s) => s >= 0)`)
- Explizite Debug-Logs hinzugefügt, wenn Fallback verwendet wird oder nicht verfügbar ist

**Code:**
```dart
final learnCatId = learnState.categoryId;
final learnStages = (learnCatId == currentId && currentId.isNotEmpty && learnState.stages.any((s) => s >= 0)) 
    ? learnState.stages 
    : null;

debugPrint('🔍 CategoryDetail Fallback-Check: currentId=$currentId learnCatId=$learnCatId learnStages=$learnStages');

// In loading()-Block:
if (learnStages != null) {
  debugPrint('✅ CategoryDetail: Verwende LearnModeController-Stages während Refresh: $learnStages');
  final total = learnStages.fold<int>(0, (a, b) => a + b);
  return (learnStages, total);
}
debugPrint('⚠️ CategoryDetail: Kein Fallback verfügbar, zeige Loading-State');
```

**Zweck:** Sicherstellen, dass der Fallback-Mechanismus korrekt funktioniert und die neuesten Stages aus dem `LearnModeController` verwendet werden, wenn der Provider gerade refresht.

---

## Änderung 3: Debug-Log korrigiert (verwendet jetzt korrekte Stages)

**Datei:** `lib/features/words/ui/screens/category_detail_screen.dart`

**Problem:** Der Debug-Log verwendete `progAsync.valueOrNull?.stages`, was während des Refreshs veraltete Werte zurückgab.

**Änderung:**
- Debug-Log verwendet jetzt `stages` aus dem `when()`-Block, der bereits den Fallback berücksichtigt

**Vorher:**
```dart
debugPrint(
  '🧾 UI stages: mode=${srs.mode} cat=$currentId '
  'loading=${progAsync.isLoading} hasValue=${progAsync.valueOrNull != null} '
  'total=${progAsync.valueOrNull?.total} stages=${progAsync.valueOrNull?.stages}',
);
```

**Nachher:**
```dart
debugPrint(
  '🧾 UI stages: mode=${srs.mode} cat=$currentId '
  'loading=${progAsync.isLoading} hasValue=${progAsync.valueOrNull != null} '
  'total=$totalWords stages=$stages',
);
```

**Zweck:** Debug-Logs zeigen jetzt die tatsächlich verwendeten Stages (inkl. Fallback), nicht die veralteten Werte aus dem Provider-Cache.

---

## Änderung 4: Backend-Validierung für A-SRS-Regeln hinzugefügt

**Datei:** `lib/features/words/application/learn_mode_controller.dart`

**Änderung:**
- Validierung hinzugefügt, die prüft, ob die Backend-Antwort den A-SRS-Regeln entspricht
- Gibt Warnung aus, wenn das Backend falsche Stage-Werte zurückgibt

**Code:**
```dart
// ⚠️ WARNUNG: Prüfe ob Backend-Antwort mit A-SRS-Regeln übereinstimmt
if (srs == SrsSystem.adaptive && correct) {
  final expectedStage = (oldStage < 5) ? oldStage + 1 : 5;
  if (serverStage != expectedStage) {
    print('⚠️ BACKEND-FEHLER: A-SRS-Regel verletzt!');
    print('⚠️   Wort in Stage $oldStage, korrekt beantwortet');
    print('⚠️   Erwartet: Stage $expectedStage');
    print('⚠️   Backend gibt zurück: Stage $serverStage');
    print('⚠️   Die Backend-Funktion fn_user_review_mode implementiert die A-SRS-Regeln nicht korrekt!');
  }
}
```

**Zweck:** 
- Identifizierung von Backend-Fehlern bei der A-SRS-Stage-Berechnung
- Klare Warnung, wenn die Backend-Funktion `fn_user_review_mode` die A-SRS-Regeln nicht korrekt implementiert

**Erwartete A-SRS-Regeln:**
- Stage 0 + correct → Stage 1
- Stage 1 + correct → Stage 2
- Stage 2 + correct → Stage 3
- Stage 3 + correct → Stage 4
- Stage 4 + correct → Stage 5
- Stage 5 + correct → Stage 5 (bleibt)

---

## Änderung 5: Verbesserte Fehlerbehandlung und Logging

**Datei:** `lib/features/words/ui/screens/category_detail_screen.dart`

**Änderung:**
- Explizite Logs hinzugefügt, wenn Fallback verwendet wird oder nicht verfügbar ist
- Bessere Unterscheidung zwischen Loading-State und Fallback-State

**Code:**
```dart
loading: () {
  // Während Refresh: Verwende LearnModeController-Stages als Fallback (falls verfügbar)
  if (learnStages != null) {
    debugPrint('✅ CategoryDetail: Verwende LearnModeController-Stages während Refresh: $learnStages');
    final total = learnStages.fold<int>(0, (a, b) => a + b);
    return (learnStages, total);
  }
  debugPrint('⚠️ CategoryDetail: Kein Fallback verfügbar, zeige Loading-State');
  // Sonst: Loading-State
  return (const [-1,-1,-1,-1,-1,-1], -1); // -1 = Loading-Indikator
},
```

**Zweck:** Bessere Nachverfolgbarkeit, welche Datenquelle verwendet wird (Provider vs. Fallback).

---

## Zusammenfassung der identifizierten Probleme

### Frontend-Probleme (behoben):
1. ✅ Fallback-Mechanismus funktioniert jetzt korrekt
2. ✅ Debug-Logs zeigen jetzt die korrekten Stages
3. ✅ UI verwendet jetzt die neuesten Stages aus `LearnModeController` während des Refreshs

### Backend-Probleme (identifiziert, aber nicht behoben):
1. ❌ **KRITISCH:** Die Backend-Funktion `fn_user_review_mode` implementiert die A-SRS-Regeln nicht korrekt
   - Stage 2 + correct → gibt Stage 1 zurück (sollte Stage 3 sein)
   - Stage 1 + correct → gibt Stage 1 zurück (sollte Stage 2 sein)
   - Stage 0 + correct → gibt Stage 1 zurück (korrekt)

**Empfehlung:** Die Backend-Funktion `fn_user_review_mode` muss repariert werden, um die A-SRS-Regeln korrekt zu implementieren. Die Validierung im Frontend zeigt jetzt klar an, wenn das Backend falsche Antworten gibt.

---

## Technische Details

### Verwendete Provider:
- `categoryProgressProvider`: Mode-aware Provider mit Key `({String catId, SrsSystem srs})`
- `learnModeControllerProvider`: Controller für Learn-Mode-State
- `srsModeControllerProvider`: Controller für SRS-Mode (adaptive/time/hybrid)

### Fallback-Mechanismus:
Wenn `categoryProgressProvider` während des Refreshs im Loading-State ist (`loading=true, hasValue=true`), verwendet die UI die Stages aus `learnModeControllerProvider` als Fallback, falls:
1. `learnState.categoryId == currentId`
2. `currentId.isNotEmpty`
3. `learnState.stages.any((s) => s >= 0)` (gültige Stages vorhanden)

### Debug-Logs:
- `🔍 CategoryDetail Fallback-Check`: Zeigt Fallback-Status
- `✅ CategoryDetail: Verwende LearnModeController-Stages während Refresh`: Fallback aktiv
- `⚠️ CategoryDetail: Kein Fallback verfügbar`: Kein Fallback verfügbar
- `⚠️ BACKEND-FEHLER: A-SRS-Regel verletzt!`: Backend gibt falsche Stage zurück

---

## Nächste Schritte

1. **Backend reparieren:** Die Funktion `fn_user_review_mode` muss die A-SRS-Regeln korrekt implementieren
2. **Testing:** Nach Backend-Fix die A-SRS-Stage-Progression testen
3. **Cleanup:** Debug-Logs können nach erfolgreichem Testing entfernt oder reduziert werden

---

## Dateien geändert

1. `lib/features/words/ui/screens/category_detail_screen.dart`
   - Fallback-Logik verbessert
   - Debug-Logs hinzugefügt/korrigiert
   
2. `lib/features/words/application/learn_mode_controller.dart`
   - Backend-Validierung für A-SRS-Regeln hinzugefügt
   - Warnung bei Backend-Fehlern

---

**Erstellt:** 2026-01-19
**Status:** Frontend-Fixes abgeschlossen, Backend-Fix erforderlich



