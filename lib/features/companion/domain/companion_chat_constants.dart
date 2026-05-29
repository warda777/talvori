import 'package:talvori/core/assets/talvori_mascot_assets.dart';

class CompanionChatConstants {
  const CompanionChatConstants._();

  static const legacyChatId = 'talvori-companion';
  static const taliChatId = 'tali';
  static const voriChatId = 'vori';
  static const chatId = taliChatId;
  static const title = 'Tali';
  static const avatarKey = 'companion:tali';

  static String chatIdForStyle(TalvoriMascotStyle style) {
    return switch (style) {
      TalvoriMascotStyle.female => taliChatId,
      TalvoriMascotStyle.male => voriChatId,
    };
  }

  static String avatarKeyForStyle(TalvoriMascotStyle style) {
    return switch (style) {
      TalvoriMascotStyle.female => 'companion:tali',
      TalvoriMascotStyle.male => 'companion:vori',
    };
  }

  static TalvoriMascotStyle styleForChatId(String chatId) {
    return switch (chatId) {
      voriChatId => TalvoriMascotStyle.male,
      _ => TalvoriMascotStyle.female,
    };
  }

  static bool isCompanionChatId(String chatId) {
    return chatId == taliChatId ||
        chatId == voriChatId ||
        chatId == legacyChatId;
  }
}
