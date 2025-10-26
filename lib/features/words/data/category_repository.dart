import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class Category {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final int wordCount;
  final String? groupSlug;
  final String? groupName;

  const Category({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    required this.wordCount,
    this.groupSlug,
    this.groupName,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json['id'] as String,
    name: json['name'] as String,
    slug: json['slug'] as String,
    description: json['description'] as String?,
    wordCount: (json['word_count'] as int?) ?? 0,
    groupSlug: json['group_slug'] as String?,
    groupName: json['group_name'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'slug': slug,
    'description': description,
    'word_count': wordCount,
    'group_slug': groupSlug,
    'group_name': groupName,
  };
}

class CategoryRepository {

  Future<List<Category>?> _getCachedCategories() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final raw = sp.getString('cached_categories');
      if (raw == null) return null;
      final List list = jsonDecode(raw);
      return list.map((m) => Category.fromJson(m as Map<String, dynamic>)).toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> _setCachedCategories(List<Category> categories) async {
    try {
      final sp = await SharedPreferences.getInstance();
      final data = categories.map((c) => c.toJson()).toList();
      await sp.setString('cached_categories', jsonEncode(data));
    } catch (_) {/* silent */}
  }

  Future<List<Category>> fetchCategories() async {
    final baseUrl = '${dotenv.env['SUPABASE_URL']}/rest/v1/categories';
    final apiKey = dotenv.env['SUPABASE_ANON_KEY']!;
    final etagKey = 'categories';
    
    final prefs = await SharedPreferences.getInstance();
    final oldEtag = prefs.getString('etag_cat_$etagKey');

    final headers = {
      'apikey': apiKey,
      'Authorization': 'Bearer $apiKey',
      'Accept': 'application/json',
      if (oldEtag != null) 'If-None-Match': oldEtag,
    };

    final uri = Uri.parse('$baseUrl?select=id,name,slug,description,word_count,group_slug,group_name&order=name.asc');

    final resp = await http.get(uri, headers: headers);

    // 304: keine Änderungen → Cache zurückgeben
    if (resp.statusCode == 304) {
      final cached = await _getCachedCategories();
      return cached ?? [];
    }

    if (resp.statusCode != 200) {
      throw Exception('HTTP ${resp.statusCode}: ${resp.reasonPhrase}');
    }

    // Neuen ETag speichern
    final newEtag = resp.headers['etag'];
    if (newEtag != null) {
      await prefs.setString('etag_cat_$etagKey', newEtag);
    }

    // Daten parsen
    final List data = jsonDecode(resp.body);
    final categories = data.map((m) => Category.fromJson(m)).toList();

    // Cache aktualisieren
    await _setCachedCategories(categories);

    return categories;
  }
}