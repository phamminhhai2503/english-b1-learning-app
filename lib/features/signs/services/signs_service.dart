import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

import '../models/signs_question.dart';

class SignsService {
  static const String assetPath = 'assets/data/signs/signs_questions.json';

  final Random _random = Random();

  Future<List<SignsQuestion>> loadAllQuestions() async {
    final jsonString = await rootBundle.loadString(assetPath);
    final List<dynamic> jsonData = json.decode(jsonString) as List<dynamic>;

    return jsonData
        .map((item) => SignsQuestion.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  List<SignsQuestion> filterQuestions({
    required List<SignsQuestion> source,
    String? category,
  }) {
    if (category == null || category.trim().isEmpty || category == 'all') {
      return List<SignsQuestion>.from(source);
    }

    return source.where((q) => q.category == category).toList();
  }

  List<SignsQuestion> buildSessionQuestions({
    required List<SignsQuestion> source,
    int? limit,
    bool shuffleQuestions = true,
    bool shuffleOptions = true,
  }) {
    final result = source.map((question) {
      final options = List<String>.from(question.options);
      if (shuffleOptions) {
        options.shuffle(_random);
      }
      return question.copyWith(options: options);
    }).toList();

    if (shuffleQuestions) {
      result.shuffle(_random);
    }

    if (limit != null && limit > 0 && limit < result.length) {
      return result.take(limit).toList();
    }

    return result;
  }

  List<String> extractAvailableCategories(List<SignsQuestion> questions) {
    final categories = questions
        .map((q) => q.category)
        .where((value) => value.trim().isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    return categories;
  }

  String getCategoryLabel(String category) {
    switch (category) {
      case 'transport_travel':
        return 'Transport & Travel';
      case 'public_places':
        return 'Public Places';
      case 'shopping_services':
        return 'Shopping & Services';
      case 'safety_rules':
        return 'Safety Rules';
      case 'school_workplace':
        return 'School & Workplace';
      default:
        return 'General Signs';
    }
  }

  String getCategoryDescription(String category) {
    switch (category) {
      case 'transport_travel':
        return 'Biển báo về xe cộ, bến bãi, vé tàu xe và di chuyển.';
      case 'public_places':
        return 'Biển báo trong thư viện, bệnh viện, khu công cộng và nơi sinh hoạt chung.';
      case 'shopping_services':
        return 'Biển báo trong cửa hàng, thanh toán, giao hàng và dịch vụ.';
      case 'safety_rules':
        return 'Biển cảnh báo nguy hiểm, an toàn lao động và nội quy bắt buộc.';
      case 'school_workplace':
        return 'Biển báo trong trường học, cơ quan và khu làm việc.';
      default:
        return 'Nhóm biển báo tổng hợp để ôn luyện chung.';
    }
  }

  String getDifficultyLabel(String difficulty) {
    switch (difficulty) {
      case 'medium':
        return 'Trung bình';
      case 'hard':
        return 'Khó';
      default:
        return 'Cơ bản';
    }
  }
}