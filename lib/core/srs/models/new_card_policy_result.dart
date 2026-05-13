import 'new_card_policy.dart';

class NewCardPolicyResult {
  const NewCardPolicyResult({
    required this.policy,
    required this.allowedNewCardCount,
    required this.maxNewCardsForMode,
    required this.stopsAutomaticRefill,
    required this.isHardLearningBlock,
  });

  final NewCardPolicy policy;
  final int allowedNewCardCount;
  final int maxNewCardsForMode;
  final bool stopsAutomaticRefill;
  final bool isHardLearningBlock;

  bool get allowsNewCards => allowedNewCardCount > 0;
}
