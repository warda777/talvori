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
}
