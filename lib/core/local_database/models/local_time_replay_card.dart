class LocalReplayCard {
  const LocalReplayCard({
    required this.wordId,
    required this.term,
    required this.translation,
  });

  final String wordId;
  final String term;
  final String translation;
}

typedef LocalTimeReplayCard = LocalReplayCard;
