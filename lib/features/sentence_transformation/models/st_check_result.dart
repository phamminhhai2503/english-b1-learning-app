class STCheckResult {
  final bool isCorrect;
  final String userAnswer;
  final String expectedAnswer;
  final List<String> matchedWords;
  final List<String> missingWords;
  final List<String> extraWords;
  final double matchPercent;

  const STCheckResult({
    required this.isCorrect,
    required this.userAnswer,
    required this.expectedAnswer,
    required this.matchedWords,
    required this.missingWords,
    required this.extraWords,
    required this.matchPercent,
  });
}
