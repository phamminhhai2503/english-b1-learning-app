import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/grammar_question.dart';

class GrammarStorageService {
  static const String _studyQuestionsKey = 'grammar_study_questions';
  static const String _studyAnswersKey = 'grammar_study_answers';
  static const String _studyIndexKey = 'grammar_study_index';
  static const String _studyPageFilterKey = 'grammar_study_page_filter';
  static const String _studySectionFilterKey = 'grammar_study_section_filter';

  static const String _examQuestionsKey = 'grammar_exam_questions';
  static const String _examAnswersKey = 'grammar_exam_answers';
  static const String _examIndexKey = 'grammar_exam_index';
  static const String _examSubmittedKey = 'grammar_exam_submitted';
  static const String _examPageFilterKey = 'grammar_exam_page_filter';
  static const String _examSectionFilterKey = 'grammar_exam_section_filter';
  static const String _examModeKey = 'grammar_exam_mode';

  Future<void> saveStudySession({
    required List<GrammarQuestion> questions,
    required Map<int, String> answers,
    required int currentIndex,
    int? pageFilter,
    String? sectionFilter,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _studyQuestionsKey,
      json.encode(questions.map((q) => q.toJson()).toList()),
    );
    await prefs.setString(
      _studyAnswersKey,
      json.encode(answers.map((k, v) => MapEntry(k.toString(), v))),
    );
    await prefs.setInt(_studyIndexKey, currentIndex);

    if (pageFilter != null) {
      await prefs.setInt(_studyPageFilterKey, pageFilter);
    } else {
      await prefs.remove(_studyPageFilterKey);
    }

    if (sectionFilter != null && sectionFilter.trim().isNotEmpty) {
      await prefs.setString(_studySectionFilterKey, sectionFilter);
    } else {
      await prefs.remove(_studySectionFilterKey);
    }
  }

  Future<GrammarStoredStudySession?> getStudySession() async {
    final prefs = await SharedPreferences.getInstance();
    final questionsRaw = prefs.getString(_studyQuestionsKey);

    if (questionsRaw == null) return null;

    final List<dynamic> decodedQuestions = json.decode(questionsRaw);
    final questions = decodedQuestions
        .map((item) => GrammarQuestion.fromJson(item))
        .toList();

    final answersRaw = prefs.getString(_studyAnswersKey);
    final answers = <int, String>{};

    if (answersRaw != null) {
      final Map<String, dynamic> decodedAnswers = json.decode(answersRaw);
      for (final entry in decodedAnswers.entries) {
        answers[int.parse(entry.key)] = entry.value as String;
      }
    }

    return GrammarStoredStudySession(
      questions: questions,
      answers: answers,
      currentIndex: prefs.getInt(_studyIndexKey) ?? 0,
      pageFilter: prefs.getInt(_studyPageFilterKey),
      sectionFilter: prefs.getString(_studySectionFilterKey),
    );
  }

  Future<void> clearStudySession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_studyQuestionsKey);
    await prefs.remove(_studyAnswersKey);
    await prefs.remove(_studyIndexKey);
    await prefs.remove(_studyPageFilterKey);
    await prefs.remove(_studySectionFilterKey);
  }

  Future<void> saveExamSession({
    required List<GrammarQuestion> questions,
    required Map<int, String> answers,
    required int currentIndex,
    required bool submitted,
    int? pageFilter,
    String? sectionFilter,
    required String mode,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _examQuestionsKey,
      json.encode(questions.map((q) => q.toJson()).toList()),
    );
    await prefs.setString(
      _examAnswersKey,
      json.encode(answers.map((k, v) => MapEntry(k.toString(), v))),
    );
    await prefs.setInt(_examIndexKey, currentIndex);
    await prefs.setBool(_examSubmittedKey, submitted);
    await prefs.setString(_examModeKey, mode);

    if (pageFilter != null) {
      await prefs.setInt(_examPageFilterKey, pageFilter);
    } else {
      await prefs.remove(_examPageFilterKey);
    }

    if (sectionFilter != null && sectionFilter.trim().isNotEmpty) {
      await prefs.setString(_examSectionFilterKey, sectionFilter);
    } else {
      await prefs.remove(_examSectionFilterKey);
    }
  }

  Future<GrammarStoredExamSession?> getExamSession() async {
    final prefs = await SharedPreferences.getInstance();
    final questionsRaw = prefs.getString(_examQuestionsKey);

    if (questionsRaw == null) return null;

    final List<dynamic> decodedQuestions = json.decode(questionsRaw);
    final questions = decodedQuestions
        .map((item) => GrammarQuestion.fromJson(item))
        .toList();

    final answersRaw = prefs.getString(_examAnswersKey);
    final answers = <int, String>{};

    if (answersRaw != null) {
      final Map<String, dynamic> decodedAnswers = json.decode(answersRaw);
      for (final entry in decodedAnswers.entries) {
        answers[int.parse(entry.key)] = entry.value as String;
      }
    }

    return GrammarStoredExamSession(
      questions: questions,
      answers: answers,
      currentIndex: prefs.getInt(_examIndexKey) ?? 0,
      submitted: prefs.getBool(_examSubmittedKey) ?? false,
      pageFilter: prefs.getInt(_examPageFilterKey),
      sectionFilter: prefs.getString(_examSectionFilterKey),
      mode: prefs.getString(_examModeKey) ?? 'all',
    );
  }

  Future<void> clearExamSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_examQuestionsKey);
    await prefs.remove(_examAnswersKey);
    await prefs.remove(_examIndexKey);
    await prefs.remove(_examSubmittedKey);
    await prefs.remove(_examPageFilterKey);
    await prefs.remove(_examSectionFilterKey);
    await prefs.remove(_examModeKey);
  }
}

class GrammarStoredStudySession {
  final List<GrammarQuestion> questions;
  final Map<int, String> answers;
  final int currentIndex;
  final int? pageFilter;
  final String? sectionFilter;

  GrammarStoredStudySession({
    required this.questions,
    required this.answers,
    required this.currentIndex,
    this.pageFilter,
    this.sectionFilter,
  });
}

class GrammarStoredExamSession {
  final List<GrammarQuestion> questions;
  final Map<int, String> answers;
  final int currentIndex;
  final bool submitted;
  final int? pageFilter;
  final String? sectionFilter;
  final String mode;

  GrammarStoredExamSession({
    required this.questions,
    required this.answers,
    required this.currentIndex,
    required this.submitted,
    this.pageFilter,
    this.sectionFilter,
    required this.mode,
  });
}