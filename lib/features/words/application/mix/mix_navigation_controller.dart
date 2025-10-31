import 'package:flutter/material.dart';
import 'package:talvori/features/words/application/mix/mix_navigation_origin.dart';
import 'package:talvori/features/words/ui/screens/quick_sets_detail_screen.dart';

/// Controller für die Navigation-Logik im Mix-Flow.
/// Verwaltet die Back-Button-Navigation zwischen:
/// - Category Popup → Mix Builder → QuickSets Detail → Learn Mode
class MixNavigationController {
  /// Navigiert zurück basierend auf der Navigation-Herkunft.
  /// 
  /// - Wenn von Category Popup: zurück zum Popup
  /// - Wenn von Mix Builder: zurück zum Mix Builder
  /// - Wenn Wheel geändert wurde: zurück zur aktuellen Kategorie im Wheel
  static void handleBackNavigation(
    BuildContext context,
    MixNavigationOrigin? origin,
    int? currentQuickSetsIndex,
  ) {
    if (origin == null) {
      Navigator.of(context).pop();
      return;
    }

    if (origin.isFromCategoryPopup) {
      // Von Category Popup: einfach zurück
      Navigator.of(context).pop();
    } else if (origin.isFromMixBuilder) {
      // Von Mix Builder
      if (currentQuickSetsIndex != null && 
          origin.quickSetsIndex != null && 
          currentQuickSetsIndex != origin.quickSetsIndex) {
        // Wheel wurde geändert: navigiere zu neuem QuickSetsDetailScreen mit neuem Index
        // Pop den aktuellen Screen
        Navigator.of(context).pop();
        // Push neuen QuickSetsDetailScreen mit dem neuen Index
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => QuickSetsDetailScreen(
              initialIndex: currentQuickSetsIndex,
              navigationOrigin: MixNavigationOrigin.mixBuilder(
                quickSetsIndex: currentQuickSetsIndex,
              ),
            ),
          ),
        );
      } else {
        // Wheel nicht geändert oder kein Index gesetzt: zurück zum Mix Builder
        Navigator.of(context).pop();
      }
    }
  }
  
  /// Navigiert vom Mix Builder zum QuickSets Detail Screen
  static Future<void> navigateToQuickSets(
    BuildContext context, {
    int initialIndex = 4, // My mix
  }) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuickSetsDetailScreen(
          initialIndex: initialIndex,
          navigationOrigin: const MixNavigationOrigin.mixBuilder(),
        ),
      ),
    );
  }
  
  /// Navigiert zurück zum Category Popup
  static void navigateBackToCategoryPopup(BuildContext context) {
    Navigator.of(context).pop();
  }
}

