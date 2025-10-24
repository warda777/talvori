import 'dart:async';

class WordTimerHelper {
  static Timer? start({
    required Duration tick,
    required void Function() onExpire,
    required void Function(double newRemaining) onTick,
    required double initialMillis,
  }) {
    double remaining = initialMillis;
    return Timer.periodic(tick, (t) {
      remaining -= tick.inMilliseconds;
      if (remaining <= 0) {
        t.cancel();
        onExpire();
      } else {
        onTick(remaining);
      }
    });
  }
}
