class StressResult {
  final int score;
  final String state;
  final List<String> triggers;
  final String recommendation;

  StressResult({
    required this.score,
    required this.state,
    required this.triggers,
    required this.recommendation,
  });

  Map<String, dynamic> toMap() {
    return {
      'score': score,
      'state': state,
      'triggers': triggers,
      'recommendation': recommendation,
    };
  }
}