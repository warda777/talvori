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
      LocalSeedWord(
        id: 'seed-basics-food',
        term: 'food',
        translation: 'Essen',
        sortOrder: 4,
      ),
      LocalSeedWord(
        id: 'seed-basics-house',
        term: 'house',
        translation: 'Haus',
        sortOrder: 5,
      ),
      LocalSeedWord(
        id: 'seed-basics-family',
        term: 'family',
        translation: 'Familie',
        sortOrder: 6,
      ),
      LocalSeedWord(
        id: 'seed-basics-friend',
        term: 'friend',
        translation: 'Freund',
        sortOrder: 7,
      ),
      LocalSeedWord(
        id: 'seed-basics-day',
        term: 'day',
        translation: 'Tag',
        sortOrder: 8,
      ),
      LocalSeedWord(
        id: 'seed-basics-night',
        term: 'night',
        translation: 'Nacht',
        sortOrder: 9,
      ),
      LocalSeedWord(
        id: 'seed-basics-morning',
        term: 'morning',
        translation: 'Morgen',
        sortOrder: 10,
      ),
      LocalSeedWord(
        id: 'seed-basics-evening',
        term: 'evening',
        translation: 'Abend',
        sortOrder: 11,
      ),
      LocalSeedWord(
        id: 'seed-basics-work',
        term: 'work',
        translation: 'Arbeit',
        sortOrder: 12,
      ),
      LocalSeedWord(
        id: 'seed-basics-school',
        term: 'school',
        translation: 'Schule',
        sortOrder: 13,
      ),
      LocalSeedWord(
        id: 'seed-basics-book',
        term: 'book',
        translation: 'Buch',
        sortOrder: 14,
      ),
      LocalSeedWord(
        id: 'seed-basics-phone',
        term: 'phone',
        translation: 'Telefon',
        sortOrder: 15,
      ),
      LocalSeedWord(
        id: 'seed-basics-car',
        term: 'car',
        translation: 'Auto',
        sortOrder: 16,
      ),
      LocalSeedWord(
        id: 'seed-basics-city',
        term: 'city',
        translation: 'Stadt',
        sortOrder: 17,
      ),
      LocalSeedWord(
        id: 'seed-basics-street',
        term: 'street',
        translation: 'Strasse',
        sortOrder: 18,
      ),
      LocalSeedWord(
        id: 'seed-basics-doctor',
        term: 'doctor',
        translation: 'Arzt',
        sortOrder: 19,
      ),
      LocalSeedWord(
        id: 'seed-basics-health',
        term: 'health',
        translation: 'Gesundheit',
        sortOrder: 20,
      ),
      LocalSeedWord(
        id: 'seed-basics-body',
        term: 'body',
        translation: 'Koerper',
        sortOrder: 21,
      ),
      LocalSeedWord(
        id: 'seed-basics-heart',
        term: 'heart',
        translation: 'Herz',
        sortOrder: 22,
      ),
      LocalSeedWord(
        id: 'seed-basics-sport',
        term: 'sport',
        translation: 'Sport',
        sortOrder: 23,
      ),
      LocalSeedWord(
        id: 'seed-basics-walk',
        term: 'walk',
        translation: 'gehen',
        sortOrder: 24,
      ),
      LocalSeedWord(
        id: 'seed-basics-rest',
        term: 'rest',
        translation: 'Ruhe',
        sortOrder: 25,
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
