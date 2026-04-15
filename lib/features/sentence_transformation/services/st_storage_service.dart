import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/st_question.dart';

class STStorageService {
  // Study
  static const String _studyQuestionsKey = 'st_study_questions';
  static const String _studyUserAnswersKey = 'st_study_user_answers';
  static const String _studyCheckedAnswersKey = 'st_study_checked_answers';
  static const String _studyIndexKey = 'st_study_index';
  static const String _studySectionFilterKey = 'st_study_section_filter';

  // Exam
  static const String _examQuestionsKey = 'st_exam_questions';
  static const String _examUserAnswersKey = 'st_exam_user_answers';
  static const String _examIndexKey = 'st_exam_index';
  static const String _examSubmittedKey = 'st_exam_submitted';
  static const String _examSectionFilterKey = 'st_exam_section_filter';
  static const String _examModeKey = 'st_exam_mode';

  // ── STUDY ────────────────────────────────────────────────────

  Future<void> saveStudySession({
    required List<STQuestion> questions,
    required Map<int, String> userAnswers,
    required Map<int, String> checkedAnswers,
    required int currentIndex,
    String? sectionFilter,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _studyQuestionsKey,
      json.encode(questions.map((q) => q.toJson()).toList()),
    );
    await prefs.setString(
      _studyUserAnswersKey,
      json.encode(userAnswers.map((k, v) => MapEntry(k.toString(), v))),
    );
    await prefs.setString(
      _studyCheckedAnswersKey,
      json.encode(checkedAnswers.map((k, v) => MapEntry(k.toString(), v))),
    );
    await prefs.setInt(_studyIndexKey, currentIndex);
    if (sectionFilter != null && sectionFilter.trim().isNotEmpty) {
      await prefs.setString(_studySectionFilterKey, sectionFilter);
    } else {
      await prefs.remove(_studySectionFilterKey);
    }
  }

  Future<STStoredStudySession?> getStudySession() async {
    final prefs = await SharedPreferences.getInstance();
    final questionsRaw = prefs.getString(_studyQuestionsKey);
    if (questionsRaw == null) return null;

    final questions = (json.decode(questionsRaw) as List<dynamic>)
        .map((item) => STQuestion.fromJson(item))
        .toList();

    return STStoredStudySession(
      questions: questions,
      userAnswers: _decodeIntStringMap(prefs.getString(_studyUserAnswersKey)),
      checkedAnswers:
          _decodeIntStringMap(prefs.getString(_studyCheckedAnswersKey)),
      currentIndex: prefs.getInt(_studyIndexKey) ?? 0,
      sectionFilter: prefs.getString(_studySectionFilterKey),
    );
  }

  Future<void> clearStudySession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_studyQuestionsKey);
    await prefs.remove(_studyUserAnswersKey);
    await prefs.remove(_studyCheckedAnswersKey);
    await prefs.remove(_studyIndexKey);
    await prefs.remove(_studySectionFilterKey);
  }

  // ── EXAM ─────────────────────────────────────────────────────

  Future<void> saveExamSession({
    required List<STQuestion> questions,
    required Map<int, String> userAnswers,
    required int currentIndex,
    required bool submitted,
    String? sectionFilter,
    required String mode,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _examQuestionsKey,
      json.encode(questions.map((q) => q.toJson()).toList()),
    );
    await prefs.setString(
      _examUserAnswersKey,
      json.encode(userAnswers.map((k, v) => MapEntry(k.toString(), v))),
    );
    await prefs.setInt(_examIndexKey, currentIndex);
    await prefs.setBool(_examSubmittedKey, submitted);
    await prefs.setString(_examModeKey, mode);
    if (sectionFilter != null && sectionFilter.trim().isNotEmpty) {
      await prefs.setString(_examSectionFilterKey, sectionFilter);
    } else {
      await prefs.remove(_examSectionFilterKey);
    }
  }

  Future<STStoredExamSession?> getExamSession() async {
    final prefs = await SharedPreferences.getInstance();
    final questionsRaw = prefs.getString(_examQuestionsKey);
    if (questionsRaw == null) return null;

    final questions = (json.decode(questionsRaw) as List<dynamic>)
        .map((item) => STQuestion.fromJson(item))
        .toList();

    return STStoredExamSession(
      questions: questions,
      userAnswers: _decodeIntStringMap(prefs.getString(_examUserAnswersKey)),
      currentIndex: prefs.getInt(_examIndexKey) ?? 0,
      submitted: prefs.getBool(_examSubmittedKey) ?? false,
      sectionFilter: prefs.getString(_examSectionFilterKey),
      mode: prefs.getString(_examModeKey) ?? 'all',
    );
  }

  Future<void> clearExamSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_examQuestionsKey);
    await prefs.remove(_examUserAnswersKey);
    await prefs.remove(_examIndexKey);
    await prefs.remove(_examSubmittedKey);
    await prefs.remove(_examSectionFilterKey);
    await prefs.remove(_examModeKey);
  }

  // ── Helpers ──────────────────────────────────────────────────

  Map<int, String> _decodeIntStringMap(String? raw) {
    if (raw == null) return {};
    final decoded = json.decode(raw) as Map<String, dynamic>;
    return decoded.map((k, v) => MapEntry(int.parse(k), v as String));
  }
}

// ── Session data classes ──────────────────────────────────────

class STStoredStudySession {
  final List<STQuestion> questions;
  final Map<int, String> userAnswers;
  final Map<int, String> checkedAnswers;
  final int currentIndex;
  final String? sectionFilter;

  STStoredStudySession({
    required this.questions,
    required this.userAnswers,
    required this.checkedAnswers,
    required this.currentIndex,
    this.sectionFilter,
  });
}

class STStoredExamSession {
  final List<STQuestion> questions;
  final Map<int, String> userAnswers;
  final int currentIndex;
  final bool submitted;
  final String? sectionFilter;
  final String mode;

  STStoredExamSession({
    required this.questions,
    required this.userAnswers,
    required this.currentIndex,
    required this.submitted,
    this.sectionFilter,
    required this.mode,
  });
}
