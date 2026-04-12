class SignsQuestion {
  final int id;
  final String image;
  final String question;
  final List<String> options;
  final String answer;
  final String explanation;
  final String category;
  final String difficulty;

  const SignsQuestion({
    required this.id,
    required this.image,
    required this.question,
    required this.options,
    required this.answer,
    required this.explanation,
    required this.category,
    required this.difficulty,
  });

  factory SignsQuestion.fromJson(Map<String, dynamic> json) {
    return SignsQuestion(
      id: json['id'] as int,
      image: json['image'] as String,
      question: json['question'] as String,
      options: List<String>.from(json['options'] as List<dynamic>),
      answer: json['answer'] as String,
      explanation: json['explanation'] as String? ?? '',
      category: json['category'] as String? ?? 'general',
      difficulty: json['difficulty'] as String? ?? 'easy',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': image,
      'question': question,
      'options': options,
      'answer': answer,
      'explanation': explanation,
      'category': category,
      'difficulty': difficulty,
    };
  }

  SignsQuestion copyWith({
    int? id,
    String? image,
    String? question,
    List<String>? options,
    String? answer,
    String? explanation,
    String? category,
    String? difficulty,
  }) {
    return SignsQuestion(
      id: id ?? this.id,
      image: image ?? this.image,
      question: question ?? this.question,
      options: options ?? this.options,
      answer: answer ?? this.answer,
      explanation: explanation ?? this.explanation,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
    );
  }
}