import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/signs_question.dart';

class SignsStorageService {
  static const String _studyQuestionsKey = 'signs_study_questions';
  static const String _studyAnswersKey = 'signs_study_answers';
  static const String _studyIndexKey = 'signs_study_index';
  static const String _studyCategoryKey = 'signs_study_category';

  static const String _examQuestionsKey = 'signs_exam_questions';
  static const String _examAnswersKey = 'signs_exam_answers';
  static const String _examIndexKey = 'signs_exam_index';
  static const String _examSubmittedKey = 'signs_exam_submitted';
  static const String _examCategoryKey = 'signs_exam_category';
  static const String _examModeKey = 'signs_exam_mode';

  Future<void> saveStudySession({
    required List<SignsQuestion> questions,
    required Map<int, String> answers,
    required int currentIndex,
    String? categoryFilter,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _studyQuestionsKey,
      json.encode(questions.map((q) => q.toJson()).toList()),
    );
    await prefs.setString(
      _studyAnswersKey,
      json.encode(answers.map((key, value) => MapEntry(key.toString(), value))),
    );
    await prefs.setInt(_studyIndexKey, currentIndex);

    if (categoryFilter != null && categoryFilter.trim().isNotEmpty) {
      await prefs.setString(_studyCategoryKey, categoryFilter);
    } else {
      await prefs.remove(_studyCategoryKey);
    }
  }

  Future<SignsStoredStudySession?> getStudySession() async {
    final prefs = await SharedPreferences.getInstance();
    final questionsRaw = prefs.getString(_studyQuestionsKey);
    if (questionsRaw == null) return null;

    final List<dynamic> decodedQuestions = json.decode(questionsRaw);
    final questions = decodedQuestions
        .map((item) => SignsQuestion.fromJson(item as Map<String, dynamic>))
        .toList();

    final answersRaw = prefs.getString(_studyAnswersKey);
    final answers = <int, String>{};

    if (answersRaw != null) {
      final Map<String, dynamic> decodedAnswers =
          json.decode(answersRaw) as Map<String, dynamic>;
      for (final entry in decodedAnswers.entries) {
        answers[int.parse(entry.key)] = entry.value as String;
      }
    }

    return SignsStoredStudySession(
      questions: questions,
      answers: answers,
      currentIndex: prefs.getInt(_studyIndexKey) ?? 0,
      categoryFilter: prefs.getString(_studyCategoryKey),
    );
  }

  Future<void> clearStudySession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_studyQuestionsKey);
    await prefs.remove(_studyAnswersKey);
    await prefs.remove(_studyIndexKey);
    await prefs.remove(_studyCategoryKey);
  }

  Future<void> saveExamSession({
    required List<SignsQuestion> questions,
    required Map<int, String> answers,
    required int currentIndex,
    required bool submitted,
    String? categoryFilter,
    String? mode,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _examQuestionsKey,
      json.encode(questions.map((q) => q.toJson()).toList()),
    );
    await prefs.setString(
      _examAnswersKey,
      json.encode(answers.map((key, value) => MapEntry(key.toString(), value))),
    );
    await prefs.setInt(_examIndexKey, currentIndex);
    await prefs.setBool(_examSubmittedKey, submitted);

    if (categoryFilter != null && categoryFilter.trim().isNotEmpty) {
      await prefs.setString(_examCategoryKey, categoryFilter);
    } else {
      await prefs.remove(_examCategoryKey);
    }

    if (mode != null && mode.trim().isNotEmpty) {
      await prefs.setString(_examModeKey, mode);
    } else {
      await prefs.remove(_examModeKey);
    }
  }

  Future<SignsStoredExamSession?> getExamSession() async {
    final prefs = await SharedPreferences.getInstance();
    final questionsRaw = prefs.getString(_examQuestionsKey);
    if (questionsRaw == null) return null;

    final List<dynamic> decodedQuestions = json.decode(questionsRaw);
    final questions = decodedQuestions
        .map((item) => SignsQuestion.fromJson(item as Map<String, dynamic>))
        .toList();

    final answersRaw = prefs.getString(_examAnswersKey);
    final answers = <int, String>{};

    if (answersRaw != null) {
      final Map<String, dynamic> decodedAnswers =
          json.decode(answersRaw) as Map<String, dynamic>;
      for (final entry in decodedAnswers.entries) {
        answers[int.parse(entry.key)] = entry.value as String;
      }
    }

    return SignsStoredExamSession(
      questions: questions,
      answers: answers,
      currentIndex: prefs.getInt(_examIndexKey) ?? 0,
      submitted: prefs.getBool(_examSubmittedKey) ?? false,
      categoryFilter: prefs.getString(_examCategoryKey),
      mode: prefs.getString(_examModeKey),
    );
  }

  Future<void> clearExamSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_examQuestionsKey);
    await prefs.remove(_examAnswersKey);
    await prefs.remove(_examIndexKey);
    await prefs.remove(_examSubmittedKey);
    await prefs.remove(_examCategoryKey);
    await prefs.remove(_examModeKey);
  }
}

class SignsStoredStudySession {
  final List<SignsQuestion> questions;
  final Map<int, String> answers;
  final int currentIndex;
  final String? categoryFilter;

  SignsStoredStudySession({
    required this.questions,
    required this.answers,
    required this.currentIndex,
    this.categoryFilter,
  });
}

class SignsStoredExamSession {
  final List<SignsQuestion> questions;
  final Map<int, String> answers;
  final int currentIndex;
  final bool submitted;
  final String? categoryFilter;
  final String? mode;

  SignsStoredExamSession({
    required this.questions,
    required this.answers,
    required this.currentIndex,
    required this.submitted,
    this.categoryFilter,
    this.mode,
  });
}