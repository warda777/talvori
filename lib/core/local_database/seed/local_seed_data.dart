class LocalSeedCategory {
  const LocalSeedCategory({
    required this.id,
    required this.name,
    required this.sortOrder,
    required this.words,
    this.description,
  });

  final String id;
  final String name;
  final String? description;
  final int sortOrder;
  final List<LocalSeedWord> words;
}

class LocalSeedWord {
  const LocalSeedWord({
    required this.id,
    required this.term,
    required this.translation,
    required this.sortOrder,
    this.exampleSentence,
    this.notes,
  });

  final String id;
  final String term;
  final String translation;
  final String? exampleSentence;
  final String? notes;
  final int sortOrder;
}

const localSeedCategories = <LocalSeedCategory>[
  LocalSeedCategory(
    id: 'seed-category-basics',
    name: 'Basics',
    description: 'Core everyday words.',
    sortOrder: 1,
    words: [
      LocalSeedWord(
        id: 'seed-basics-hello',
        term: 'hello',
        translation: 'hallo',
        exampleSentence: 'Hello, how are you?',
        notes: 'Basic greeting.',
        sortOrder: 1,
      ),
      LocalSeedWord(
        id: 'seed-basics-thank-you',
        term: 'thank you',
        translation: 'danke',
        exampleSentence: 'Thank you for your help.',
        notes: 'Polite phrase.',
        sortOrder: 2,
      ),
      LocalSeedWord(
        id: 'seed-basics-water',
        term: 'water',
        translation: 'Wasser',
        exampleSentence: 'I drink water.',
        notes: 'Everyday noun.',
        sortOrder: 3,
      ),
    ],
  ),
  LocalSeedCategory(
    id: 'seed-category-travel',
    name: 'Travel',
    description: 'Useful words for travel situations.',
    sortOrder: 2,
    words: [
      LocalSeedWord(
        id: 'seed-travel-ticket',
        term: 'ticket',
        translation: 'Fahrkarte',
        exampleSentence: 'I need a ticket.',
        notes: 'Transport word.',
        sortOrder: 1,
      ),
      LocalSeedWord(
        id: 'seed-travel-station',
        term: 'station',
        translation: 'Bahnhof',
        exampleSentence: 'The station is nearby.',
        notes: 'Place word.',
        sortOrder: 2,
      ),
      LocalSeedWord(
        id: 'seed-travel-hotel',
        term: 'hotel',
        translation: 'Hotel',
        exampleSentence: 'The hotel is quiet.',
        notes: 'Accommodation.',
        sortOrder: 3,
      ),
    ],
  ),
  LocalSeedCategory(
    id: 'seed-category-exam-practice',
    name: 'Exam Practice',
    description: 'Words for focused exam preparation.',
    sortOrder: 3,
    words: [
      LocalSeedWord(
        id: 'seed-exam-explain',
        term: 'explain',
        translation: 'erklaeren',
        exampleSentence: 'Please explain your answer.',
        notes: 'Common exam verb.',
        sortOrder: 1,
      ),
      LocalSeedWord(
        id: 'seed-exam-compare',
        term: 'compare',
        translation: 'vergleichen',
        exampleSentence: 'Compare the two examples.',
        notes: 'Task instruction.',
        sortOrder: 2,
      ),
      LocalSeedWord(
        id: 'seed-exam-result',
        term: 'result',
        translation: 'Ergebnis',
        exampleSentence: 'The result is clear.',
        notes: 'Academic noun.',
        sortOrder: 3,
      ),
    ],
  ),
];
