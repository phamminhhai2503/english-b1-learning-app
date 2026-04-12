class SpeakingResult {
  final String recognizedText;
  final String expectedText;
  final double matchPercent;
  final List<String> missingWords;
  final List<String> extraWords;
  final List<String> matchedWords;

  SpeakingResult({
    required this.recognizedText,
    required this.expectedText,
    required this.matchPercent,
    required this.missingWords,
    required this.extraWords,
    required this.matchedWords,
  });
}