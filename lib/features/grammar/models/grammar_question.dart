class GrammarQuestion {
  final int id;
  final int? page;
  final String? section;
  final String question;
  final List<String> options;
  final String answer;
  final String explanation;

  GrammarQuestion({
    required this.id,
    this.page,
    this.section,
    required this.question,
    required this.options,
    required this.answer,
    required this.explanation,
  });

  factory GrammarQuestion.fromJson(Map<String, dynamic> json) {
    return GrammarQuestion(
      id: json['id'] as int,
      page: json['page'] as int?,
      section: json['section'] as String?,
      question: json['question'] as String,
      options: List<String>.from(json['options'] as List),
      answer: json['answer'] as String,
      explanation: json['explanation'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'page': page,
      'section': section,
      'question': question,
      'options': options,
      'answer': answer,
      'explanation': explanation,
    };
  }

  GrammarQuestion copyWith({
    int? id,
    int? page,
    String? section,
    String? question,
    List<String>? options,
    String? answer,
    String? explanation,
  }) {
    return GrammarQuestion(
      id: id ?? this.id,
      page: page ?? this.page,
      section: section ?? this.section,
      question: question ?? this.question,
      options: options ?? this.options,
      answer: answer ?? this.answer,
      explanation: explanation ?? this.explanation,
    );
  }
}