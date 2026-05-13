import 'review_answer.dart';

class SessionContext {
  const SessionContext({
    required this.sessionId,
    required this.currentPosition,
    required this.recentAnswers,
    required this.sameSessionWrongCountsByWordId,
    required this.remainingQueueSize,
  }) : assert(currentPosition >= 0),
       assert(remainingQueueSize >= 0);

  final String sessionId;
  final int currentPosition;
  final List<ReviewAnswer> recentAnswers;
  final Map<String, int> sameSessionWrongCountsByWordId;
  final int remainingQueueSize;

  int wrongCountForWord(String wordId) {
    return sameSessionWrongCountsByWordId[wordId] ?? 0;
  }
}
