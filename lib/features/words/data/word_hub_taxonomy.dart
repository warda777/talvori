class HubSubcat {
  final String key;
  final String label;
  final String? supabaseId; // UUID deiner word_categories (später befüllen)
  const HubSubcat({required this.key, required this.label, this.supabaseId});
}

class HubSection {
  final String key;
  final String title;
  final String focus;
  final List<HubSubcat> subcats;
  const HubSection({required this.key, required this.title, required this.focus, required this.subcats});
}

// Acht Bereiche + Tabs (Labels = deine neuen Kategorien)
const hubSections = <HubSection>[
  HubSection(
    key: 'life_daily_flow',
    title: 'Life & Daily Flow',
    focus: 'Alltag & Routinen',
    subcats: [
      HubSubcat(key: 'health_fitness', label: 'Health & Fitness'),
      HubSubcat(key: 'home_living', label: 'Home & Living'),
      HubSubcat(key: 'food_cooking', label: 'Food & Cooking'),
      HubSubcat(key: 'style_fashion', label: 'Style & Fashion'),
      HubSubcat(key: 'money_shopping', label: 'Money & Shopping'),
    ],
  ),
  HubSection(
    key: 'people_mind',
    title: 'People & Mind',
    focus: 'Zwischenmenschliches, Emotionen',
    subcats: [
      HubSubcat(key: 'personality', label: 'Personality'),
      HubSubcat(key: 'feelings', label: 'Feelings'),
      HubSubcat(key: 'relationships', label: 'Relationships'),
      HubSubcat(key: 'thoughts', label: 'Thoughts'),
    ],
  ),
  HubSection(
    key: 'society_systems',
    title: 'Society & Systems',
    focus: 'Welt, Arbeit, Bildung',
    subcats: [
      HubSubcat(key: 'tech_innovation', label: 'Tech & Innovation'),
      HubSubcat(key: 'work_careers', label: 'Work & Careers'),
      HubSubcat(key: 'school_studies', label: 'School & Studies'),
      HubSubcat(key: 'media_news', label: 'Media & News'),
      HubSubcat(key: 'law_politics', label: 'Law & Politics'),
    ],
  ),
  HubSection(
    key: 'nature_beyond',
    title: 'Nature & Beyond',
    focus: 'Umwelt, Tiere, Wissenschaft',
    subcats: [
      HubSubcat(key: 'environment', label: 'Environment'),
      HubSubcat(key: 'animals', label: 'Animals'),
      HubSubcat(key: 'nature', label: 'Nature'),
      HubSubcat(key: 'space', label: 'Space'),
      HubSubcat(key: 'science', label: 'Science'),
    ],
  ),
  HubSection(
    key: 'action_adventure',
    title: 'Action & Adventure',
    focus: 'Bewegung & Reisen',
    subcats: [
      HubSubcat(key: 'sports', label: 'Sports'),
      HubSubcat(key: 'travel', label: 'Travel'),
      HubSubcat(key: 'gaming', label: 'Gaming'),
      HubSubcat(key: 'transport', label: 'Transport'),
    ],
  ),
  HubSection(
    key: 'culture_creativity',
    title: 'Culture & Creativity',
    focus: 'Ausdruck & Kunst',
    subcats: [
      HubSubcat(key: 'music_entertainment', label: 'Music & Entertainment'),
      HubSubcat(key: 'art_literature', label: 'Art & Literature'),
    ],
  ),
  HubSection(
    key: 'language_tools',
    title: 'Language Tools',
    focus: 'Lernhilfen & Grammatik',
    subcats: [
      HubSubcat(key: 'top_500', label: 'Top 500 Words'),
      HubSubcat(key: 'phrases_idioms', label: 'Phrases & Idioms'),
      HubSubcat(key: 'irregular_verbs', label: 'Irregular Verbs'),
      HubSubcat(key: 'grammar_syntax', label: 'Grammar & Syntax'),
    ],
  ),
  HubSection(
    key: 'levels_progress',
    title: 'Levels & Progress',
    focus: 'Sprachstufen & Lernpfade',
    subcats: [
      HubSubcat(key: 'a1', label: 'A1'),
      HubSubcat(key: 'a2', label: 'A2'),
      HubSubcat(key: 'b1', label: 'B1'),
      HubSubcat(key: 'b2', label: 'B2'),
      HubSubcat(key: 'c1', label: 'C1'),
      HubSubcat(key: 'c2', label: 'C2'),
    ],
  ),
];
