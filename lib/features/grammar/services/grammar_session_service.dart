import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

import '../models/grammar_question.dart';

class GrammarSessionService {
  static const String assetPath =
      'assets/data/grammar/grammar_questions.json';

  final Random _random = Random();

  Future<List<GrammarQuestion>> loadAllQuestions() async {
    final jsonString = await rootBundle.loadString(assetPath);
    final List<dynamic> jsonData = json.decode(jsonString);
    return jsonData
        .map((item) => GrammarQuestion.fromJson(item))
        .toList();
  }

  List<GrammarQuestion> filterQuestions({
    required List<GrammarQuestion> source,
    int? page,
    String? section,
  }) {
    Iterable<GrammarQuestion> filtered = source;

    if (page != null) {
      filtered = filtered.where((q) => q.page == page);
    }

    if (section != null && section.trim().isNotEmpty) {
      filtered = filtered.where((q) => q.section == section);
    }

    return filtered.toList();
  }

  List<GrammarQuestion> buildSessionQuestions({
    required List<GrammarQuestion> source,
    bool shuffleQuestions = true,
    bool shuffleOptions = true,
  }) {
    final result = source.map((q) {
      final options = List<String>.from(q.options);
      if (shuffleOptions) {
        options.shuffle(_random);
      }
      return q.copyWith(options: options);
    }).toList();

    if (shuffleQuestions) {
      result.shuffle(_random);
    }

    return result;
  }

  List<int> extractAvailablePages(List<GrammarQuestion> questions) {
    final pages = questions
        .map((q) => q.page)
        .whereType<int>()
        .toSet()
        .toList()
      ..sort();
    return pages;
  }

  List<String> extractAvailableSections(List<GrammarQuestion> questions) {
    final sections = questions
        .map((q) => q.section)
        .whereType<String>()
        .where((s) => s.trim().isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return sections;
  }
}