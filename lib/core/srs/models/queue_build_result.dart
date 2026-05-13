import 'new_card_policy.dart';
import 'session_item.dart';

class QueueBuildResult {
  const QueueBuildResult({
    required this.items,
    required this.newCardsIncluded,
    required this.reviewsIncluded,
    required this.newCardPolicy,
  });

  final List<SessionItem> items;
  final int newCardsIncluded;
  final int reviewsIncluded;
  final NewCardPolicy newCardPolicy;
}
