import 'package:flutter/material.dart';

/// Returns themed iconography for Word Hub categories.
///
/// Each category key maps to a representative [IconData] that can be tinted
/// with the category's stroke color inside the UI.
class CategoryIllustrations {
  static final Map<String, IconData> _iconByKey = {
    // Life & Daily Flow
    'health_fitness': Icons.favorite_outline,
    'home_living': Icons.home_outlined,
    'food_cooking': Icons.restaurant_menu,
    'style_fashion': Icons.checkroom_outlined,
    'money_shopping': Icons.shopping_bag_outlined,

    // People & Mind
    'personality': Icons.psychology_alt_outlined,
    'feelings': Icons.emoji_emotions_outlined,
    'relationships': Icons.favorite_border,
    'thoughts': Icons.lightbulb_outline,

    // Society & Systems
    'tech_innovation': Icons.memory,
    'work_careers': Icons.work_outline,
    'school_studies': Icons.school_outlined,
    'media_news': Icons.article_outlined,
    'law_politics': Icons.gavel_outlined,

    // Nature & Beyond
    'environment': Icons.eco_outlined,
    'animals': Icons.pets_outlined,
    'nature': Icons.terrain_outlined,
    'space': Icons.travel_explore,
    'science': Icons.science_outlined,

    // Action & Adventure
    'sports': Icons.sports_soccer,
    'travel': Icons.flight_takeoff,
    'gaming': Icons.videogame_asset,
    'transport': Icons.directions_car_filled_outlined,

    // Culture & Creativity
    'music_entertainment': Icons.music_note,
    'art_literature': Icons.palette_outlined,

    // Language Tools
    'top_500': Icons.star_outline,
    'phrases_idioms': Icons.forum_outlined,
    'irregular_verbs': Icons.translate,
    'grammar_syntax': Icons.text_fields,

    // Levels & Progress
    'a1': Icons.layers_outlined,
    'a2': Icons.layers,
    'b1': Icons.layers_rounded,
    'b2': Icons.auto_awesome_motion,
    'c1': Icons.auto_graph,
    'c2': Icons.workspace_premium,
  };

  static IconData? iconFor(String key) => _iconByKey[key];
}
