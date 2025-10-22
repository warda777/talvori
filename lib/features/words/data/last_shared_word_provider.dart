import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/services.dart';

const _appGroupId = 'group.com.talvori.app'; // <- exakt wie in Xcode
const _fileName   = 'last_shared_word.txt';
const _prefsKey   = 'last_shared_word';

final lastSharedWordProvider = FutureProvider<String?>((ref) async {
  try {
    // nur iOS: App-Group lesen
    if (Platform.isIOS) {
      final dir = await _getAppGroupDirectory(_appGroupId);
      if (dir != null) {
        final file = File(p.join(dir, _fileName));
        if (await file.exists()) {
          final s = (await file.readAsString()).trim();
          if (s.isNotEmpty) return s;
        }
      }
    }
  } catch (_) {/* ignore and fall back */}

  // Fallback: SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final s = prefs.getString(_prefsKey)?.trim();
  return (s == null || s.isEmpty) ? null : s;
});

// Lokale Implementierung für App Group Directory
Future<String?> _getAppGroupDirectory(String appGroupId) async {
  try {
    const platform = MethodChannel('app_group_directory');
    final String? directory = await platform.invokeMethod('getAppGroupDirectory');
    return directory;
  } catch (e) {
    return null;
  }
}
