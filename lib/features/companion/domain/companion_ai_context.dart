class CompanionAiContext {
  const CompanionAiContext({
    this.userName,
    required this.myWordsCount,
    this.currentDiscoveryTip,
    this.lastCompanionMessage,
    this.learningStatus,
  });

  final String? userName;
  final int myWordsCount;
  final String? currentDiscoveryTip;
  final String? lastCompanionMessage;
  final String? learningStatus;

  Map<String, Object?> toJson() {
    return {
      if (userName != null && userName!.trim().isNotEmpty)
        'userName': userName!.trim(),
      'myWordsCount': myWordsCount,
      if (currentDiscoveryTip != null && currentDiscoveryTip!.trim().isNotEmpty)
        'currentDiscoveryTip': currentDiscoveryTip!.trim(),
      if (lastCompanionMessage != null &&
          lastCompanionMessage!.trim().isNotEmpty)
        'lastCompanionMessage': lastCompanionMessage!.trim(),
      if (learningStatus != null && learningStatus!.trim().isNotEmpty)
        'learningStatus': learningStatus!.trim(),
    };
  }
}
