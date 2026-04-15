import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

import '../models/st_check_result.dart';
import '../models/st_question.dart';

class STService {
  static const String assetPath =
      'assets/data/sentence_transformation/st_questions.json';

  final Random _random = Random();

  Future<List<STQuestion>> loadAllQuestions() async {
    final jsonString = await rootBundle.loadString(assetPath);
    final List<dynamic> jsonData = json.decode(jsonString);
    return jsonData.map((item) => STQuestion.fromJson(item)).toList();
  }

  List<STQuestion> filterQuestions({
    required List<STQuestion> source,
    String? section,
  }) {
    if (section == null || section.trim().isEmpty || section == 'all') {
      return List<STQuestion>.from(source);
    }
    return source.where((q) => q.section == section).toList();
  }

  List<STQuestion> buildSessionQuestions({
    required List<STQuestion> source,
    bool shuffleQuestions = true,
  }) {
    final result = List<STQuestion>.from(source);
    if (shuffleQuestions) {
      result.shuffle(_random);
    }
    return result;
  }

  List<String> extractAvailableSections(List<STQuestion> questions) {
    return questions
        .map((q) => q.section)
        .whereType<String>()
        .where((s) => s.trim().isNotEmpty)
        .toSet()
        .toList()
      ..sort();
  }

  // Normalize: lowercase, expand contractions, strip punctuation, collapse spaces
  String _normalize(String text) {
    var result = text.toLowerCase();

    result = result
        .replaceAll("won't", 'will not')
        .replaceAll("wouldn't", 'would not')
        .replaceAll("couldn't", 'could not')
        .replaceAll("shouldn't", 'should not')
        .replaceAll("can't", 'cannot')
        .replaceAll("isn't", 'is not')
        .replaceAll("aren't", 'are not')
        .replaceAll("wasn't", 'was not')
        .replaceAll("weren't", 'were not')
        .replaceAll("haven't", 'have not')
        .replaceAll("hasn't", 'has not')
        .replaceAll("hadn't", 'had not')
        .replaceAll("don't", 'do not')
        .replaceAll("doesn't", 'does not')
        .replaceAll("didn't", 'did not')
        .replaceAll("i'm", 'i am')
        .replaceAll("i've", 'i have')
        .replaceAll("i'd", 'i would')
        .replaceAll("i'll", 'i will')
        .replaceAll("he's", 'he is')
        .replaceAll("she's", 'she is')
        .replaceAll("it's", 'it is')
        .replaceAll("they're", 'they are')
        .replaceAll("we're", 'we are');

    result = result
        .replaceAll(RegExp(r"[^\w\s]"), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    return result;
  }

  STCheckResult checkAnswer({
    required String userAnswer,
    required String expectedAnswer,
  }) {
    final normalizedUser = _normalize(userAnswer);
    final normalizedExpected = _normalize(expectedAnswer);

    final isCorrect = normalizedUser == normalizedExpected;

    final userWords =
        normalizedUser.isEmpty ? <String>[] : normalizedUser.split(' ');
    final expectedWords =
        normalizedExpected.isEmpty ? <String>[] : normalizedExpected.split(' ');

    final tempExpected = List<String>.from(expectedWords);
    final matchedWords = <String>[];
    final extraWords = <String>[];

    for (final word in userWords) {
      if (tempExpected.contains(word)) {
        matchedWords.add(word);
        tempExpected.remove(word);
      } else {
        extraWords.add(word);
      }
    }

    final missingWords = tempExpected;
    final totalExpected = expectedWords.isEmpty ? 1 : expectedWords.length;
    final matchPercent =
        (matchedWords.length / totalExpected * 100).clamp(0.0, 100.0);

    return STCheckResult(
      isCorrect: isCorrect,
      userAnswer: userAnswer.trim(),
      expectedAnswer: expectedAnswer.trim(),
      matchedWords: matchedWords,
      missingWords: missingWords,
      extraWords: extraWords,
      matchPercent: matchPercent,
    );
  }
}
