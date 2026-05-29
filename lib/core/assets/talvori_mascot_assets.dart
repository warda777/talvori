enum TalvoriMascotMood {
  greeting,
  idle,
  happy,
  happyHighThumb,
  proud,
  bored,
  tired,
  sad,
  angryFists,
  furious,
  surprisedStop,
  thinkingChin,
  thinkingSkeptical,
}

enum TaliEmotion {
  neutral,
  happy,
  thinking,
  bored,
  surprised,
  cool,
  hurra,
  embarrassed,
  sleepy,
  loveEyes,
  wink,
  party,
  starEyes,
}

enum TaliEvent {
  appReady,
  userIdle,
  chatOpened,
  userMessageSent,
  aiThinking,
  aiResponseSuccess,
  aiResponseError,
  wordCorrect,
  wordWrong,
  pointsGained,
  dailyGoalReached,
}

enum TalvoriMascotStyle { male, female }

class TalvoriMascotAssets {
  const TalvoriMascotAssets._();

  static const angryFists = 'assets/images/mascot/talvori_angry_fists.png';
  static const bored = 'assets/images/mascot/talvori_bored.png';
  static const furious = 'assets/images/mascot/talvori_furious.png';
  static const greeting = 'assets/images/mascot/talvori_greeting.png';
  static const happy = 'assets/images/mascot/talvori_happy.png';
  static const happyHighThumb =
      'assets/images/mascot/talvori_happy_high_thumb.png';
  static const idle = 'assets/images/mascot/talvori_idle.png';
  static const proud = 'assets/images/mascot/talvori_proud.png';
  static const sad = 'assets/images/mascot/talvori_sad.png';
  static const surprisedStop =
      'assets/images/mascot/talvori_surprised_stop.png';
  static const thinkingChin = 'assets/images/mascot/talvori_thinking_chin.png';
  static const thinkingSkeptical =
      'assets/images/mascot/talvori_thinking_skeptical.png';
  static const tired = 'assets/images/mascot/talvori_tired.png';
  static const spirit = 'assets/images/mascot/talvori_spirit_mascot.png';
  static const taliFemaleLaugh = 'assets/images/mascot/tali_female_laugh.png';
  static const taliFemaleNeutral =
      'assets/images/mascot/tali_female_neutral.png';
  static const taliFemaleBored = 'assets/images/mascot/tali_female_bored.png';
  static const taliFemaleSurprised =
      'assets/images/mascot/tali_female_surprised.png';
  static const taliFemaleCool = 'assets/images/mascot/tali_female_cool.png';
  static const taliFemaleHurra = 'assets/images/mascot/tali_female_hurra.png';
  static const taliFemaleEmbarrassed =
      'assets/images/mascot/tali_female_embarrassed.png';
  static const taliFemaleSleepy = 'assets/images/mascot/tali_female_sleepy.png';
  static const taliFemaleLoveEyes =
      'assets/images/mascot/tali_female_love_eyes.png';
  static const taliFemaleWink = 'assets/images/mascot/tali_female_wink.png';
  static const taliFemaleParty = 'assets/images/mascot/tali_female_party.png';
  static const taliFemaleStarEyes =
      'assets/images/mascot/tali_female_star_eyes.png';
  static const taliMaleLaugh = 'assets/images/mascot/tali_male_laugh.png';
  static const taliMaleNeutral = 'assets/images/mascot/tali_male_neutral.png';
  static const taliMaleBored = 'assets/images/mascot/tali_male_bored.png';
  static const taliMaleSurprised =
      'assets/images/mascot/tali_male_surprised.png';
  static const taliMaleCool = 'assets/images/mascot/tali_male_cool.png';
  static const taliMaleHurra = 'assets/images/mascot/tali_male_hurra.png';
  static const taliMaleEmbarrassed =
      'assets/images/mascot/tali_male_embarrassed.png';
  static const taliMaleSleepy = 'assets/images/mascot/tali_male_sleepy.png';
  static const taliMaleLoveEyes =
      'assets/images/mascot/tali_male_love_eyes.png';
  static const taliMaleWink = 'assets/images/mascot/tali_male_wink.png';
  static const taliMaleParty = 'assets/images/mascot/tali_male_party.png';
  static const taliMaleStarEyes =
      'assets/images/mascot/tali_male_star_eyes.png';
  static const taliLaugh = taliFemaleLaugh;
  static const taliNeutral = taliFemaleNeutral;
  static const taliBored = taliFemaleBored;
  static const taliSurprised = taliFemaleSurprised;
  static const taliCool = taliFemaleCool;
  static const taliHurra = taliFemaleHurra;
  static const taliEmbarrassed = taliFemaleEmbarrassed;
  static const taliSleepy = taliFemaleSleepy;
  static const taliLoveEyes = taliFemaleLoveEyes;
  static const taliWink = taliFemaleWink;
  static const taliParty = taliFemaleParty;
  static const taliStarEyes = taliFemaleStarEyes;

  static const Map<TaliEmotion, String> _femaleSpiritAssets = {
    TaliEmotion.neutral: taliFemaleNeutral,
    TaliEmotion.happy: taliFemaleLaugh,
    TaliEmotion.bored: taliFemaleBored,
    TaliEmotion.surprised: taliFemaleSurprised,
    TaliEmotion.cool: taliFemaleCool,
    TaliEmotion.hurra: taliFemaleHurra,
    TaliEmotion.embarrassed: taliFemaleEmbarrassed,
    TaliEmotion.sleepy: taliFemaleSleepy,
    TaliEmotion.loveEyes: taliFemaleLoveEyes,
    TaliEmotion.wink: taliFemaleWink,
    TaliEmotion.party: taliFemaleParty,
    TaliEmotion.starEyes: taliFemaleStarEyes,
  };

  static const Map<TaliEmotion, String> _maleSpiritAssets = {
    TaliEmotion.neutral: taliMaleNeutral,
    TaliEmotion.happy: taliMaleLaugh,
    TaliEmotion.bored: taliMaleBored,
    TaliEmotion.surprised: taliMaleSurprised,
    TaliEmotion.cool: taliMaleCool,
    TaliEmotion.hurra: taliMaleHurra,
    TaliEmotion.embarrassed: taliMaleEmbarrassed,
    TaliEmotion.sleepy: taliMaleSleepy,
    TaliEmotion.loveEyes: taliMaleLoveEyes,
    TaliEmotion.wink: taliMaleWink,
    TaliEmotion.party: taliMaleParty,
    TaliEmotion.starEyes: taliMaleStarEyes,
  };

  static String pathFor(TalvoriMascotMood mood) {
    return switch (mood) {
      TalvoriMascotMood.greeting => greeting,
      TalvoriMascotMood.idle => idle,
      TalvoriMascotMood.happy => happy,
      TalvoriMascotMood.happyHighThumb => happyHighThumb,
      TalvoriMascotMood.proud => proud,
      TalvoriMascotMood.bored => bored,
      TalvoriMascotMood.tired => tired,
      TalvoriMascotMood.sad => sad,
      TalvoriMascotMood.angryFists => angryFists,
      TalvoriMascotMood.furious => furious,
      TalvoriMascotMood.surprisedStop => surprisedStop,
      TalvoriMascotMood.thinkingChin => thinkingChin,
      TalvoriMascotMood.thinkingSkeptical => thinkingSkeptical,
    };
  }

  static String spiritPathFor(
    TaliEmotion emotion, {
    TalvoriMascotStyle style = TalvoriMascotStyle.female,
  }) {
    final assets = _spiritAssetsFor(style);
    return assets[emotion] ?? neutralSpiritPathFor(style: style);
  }

  static String neutralSpiritPathFor({
    TalvoriMascotStyle style = TalvoriMascotStyle.female,
  }) {
    return _spiritAssetsFor(style)[TaliEmotion.neutral] ?? spirit;
  }

  static TaliEmotion emotionForLegacyMood(TalvoriMascotMood mood) {
    return switch (mood) {
      TalvoriMascotMood.greeting => TaliEmotion.neutral,
      TalvoriMascotMood.idle => TaliEmotion.neutral,
      TalvoriMascotMood.happy => TaliEmotion.happy,
      TalvoriMascotMood.happyHighThumb => TaliEmotion.hurra,
      TalvoriMascotMood.proud => TaliEmotion.starEyes,
      TalvoriMascotMood.bored => TaliEmotion.bored,
      TalvoriMascotMood.tired => TaliEmotion.sleepy,
      TalvoriMascotMood.sad => TaliEmotion.embarrassed,
      TalvoriMascotMood.angryFists => TaliEmotion.cool,
      TalvoriMascotMood.furious => TaliEmotion.cool,
      TalvoriMascotMood.surprisedStop => TaliEmotion.surprised,
      TalvoriMascotMood.thinkingChin => TaliEmotion.thinking,
      TalvoriMascotMood.thinkingSkeptical => TaliEmotion.wink,
    };
  }

  static TaliEmotion emotionForEvent(TaliEvent event) {
    return switch (event) {
      TaliEvent.appReady => TaliEmotion.neutral,
      TaliEvent.userIdle => TaliEmotion.bored,
      TaliEvent.chatOpened => TaliEmotion.neutral,
      TaliEvent.userMessageSent => TaliEmotion.thinking,
      TaliEvent.aiThinking => TaliEmotion.thinking,
      TaliEvent.aiResponseSuccess => TaliEmotion.happy,
      TaliEvent.aiResponseError => TaliEmotion.surprised,
      TaliEvent.wordCorrect => TaliEmotion.happy,
      TaliEvent.wordWrong => TaliEmotion.embarrassed,
      TaliEvent.pointsGained => TaliEmotion.starEyes,
      TaliEvent.dailyGoalReached => TaliEmotion.party,
    };
  }

  static Map<TaliEmotion, String> _spiritAssetsFor(TalvoriMascotStyle style) {
    return switch (style) {
      TalvoriMascotStyle.female => _femaleSpiritAssets,
      TalvoriMascotStyle.male => _maleSpiritAssets,
    };
  }
}
