import '../models/speaking_result.dart';

class SpeakingCompareService {
  String _normalize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String cleanRecognizedText(String text) {
    var cleaned = text.toLowerCase();

    cleaned = cleaned
        .replaceAll('ithe', 'i the')
        .replaceAll('amthe', 'am the')
        .replaceAll('dothe', 'do the')
        .replaceAll('whenthe', 'when the')
        .replaceAll('thethe', 'the')
        .replaceAll('itis', 'it is');

    cleaned = cleaned.replaceAllMapped(
      RegExp(r'\b(\w+)\1+\b', caseSensitive: false),
      (match) => match.group(1) ?? '',
    );

    cleaned = _normalize(cleaned);

    if (cleaned.isEmpty) return cleaned;

    final words = cleaned.split(' ');
    final result = <String>[];

    for (final word in words) {
      if (word.trim().isEmpty) continue;

      if (result.isNotEmpty && result.last == word) {
        continue;
      }

      result.add(word);
    }

    if (result.length < 4) {
      return result.join(' ');
    }

    final reduced = <String>[];
    int i = 0;

    while (i < result.length) {
      if (i >= 2 &&
          reduced.length >= 2 &&
          reduced[reduced.length - 2] == result[i - 1] &&
          reduced[reduced.length - 1] == result[i]) {
        i++;
        continue;
      }

      reduced.add(result[i]);
      i++;
    }

    return reduced.join(' ');
  }

  SpeakingResult compare({
    required String recognizedText,
    required String expectedText,
  }) {
    final cleanedRecognized = cleanRecognizedText(recognizedText);
    final recognized = _normalize(cleanedRecognized);
    final expected = _normalize(expectedText);

    final recognizedWords =
        recognized.isEmpty ? <String>[] : recognized.split(' ');
    final expectedWords = expected.isEmpty ? <String>[] : expected.split(' ');

    final missingWords = <String>[];
    final extraWords = <String>[];
    final matchedWords = <String>[];

    final tempExpected = List<String>.from(expectedWords);

    for (final word in recognizedWords) {
      if (tempExpected.contains(word)) {
        matchedWords.add(word);
        tempExpected.remove(word);
      } else {
        extraWords.add(word);
      }
    }

    missingWords.addAll(tempExpected);

    final totalExpected = expectedWords.isEmpty ? 1 : expectedWords.length;
    final matchPercent = (matchedWords.length / totalExpected) * 100;

    return SpeakingResult(
      recognizedText: cleanedRecognized,
      expectedText: expectedText,
      matchPercent: matchPercent.clamp(0, 100),
      missingWords: missingWords,
      extraWords: extraWords,
      matchedWords: matchedWords,
    );
  }
}