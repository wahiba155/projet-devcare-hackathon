import 'dart:async';

class InactivityService {
  int seconds = 0;
  Timer? timer;

  void start() {
    timer = Timer.periodic(Duration(seconds: 1), (_) {
      seconds++;
    });
  }

  void reset() {
    seconds = 0;
  }

  int getStressFromInactivity() {
    if (seconds > 2700) return 40; // 45 min
    if (seconds > 1800) return 20;
    return 0;
  }

  void stop() {
    timer?.cancel();
  }
}