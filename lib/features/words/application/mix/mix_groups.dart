import 'package:flutter/foundation.dart';

@immutable
class MixGroup {
  final String title;
  final List<String> items;
  const MixGroup(this.title, this.items);
}

@immutable
class MixSearchResult {
  final String group;
  final String item;
  const MixSearchResult({required this.group, required this.item});
}

/// Quelle für Gruppen (später leicht ersetzbar durch Taxonomy aus Supabase)
const mixGroups = <MixGroup>[
  MixGroup('Your collections', ['Want to memorize']),
  MixGroup('Action & Adventure', ['Gaming', 'Sports', 'Transport', 'Travel']),
  MixGroup('Culture & Creativity', ['Art & Literature', 'Music & Entertainment']),
  MixGroup('Language Tools', ['Grammar & Syntax', 'Irregular Verbs', 'Phrases & Idioms', 'Top 500 Words']),
  MixGroup('Levels & Progress', ['A1', 'A2', 'B1', 'B2', 'C1', 'C2']),
  MixGroup('Life & Daily Flow', ['Food & Cooking', 'Health & Fitness', 'Home & Living', 'Money & Shopping', 'Produktivitie', 'Style & Fashion']),
  MixGroup('Nature & Beyond', ['Animals', 'Environment', 'Nature', 'Science', 'Space']),
  MixGroup('People & Mind', ['Feelings', 'Personality', 'Relationships', 'Thoughts']),
  MixGroup('Society & Systems', ['Law & Politics', 'Media & News', 'School & Studies', 'Tech & Innovation', 'Work & Careers']),
];
