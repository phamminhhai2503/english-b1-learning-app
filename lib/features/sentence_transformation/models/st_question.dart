class STQuestion {
  final int id;
  final String sentence;
  final String instruction;
  final String answer;
  final String explanation;
  final String? section;

  const STQuestion({
    required this.id,
    required this.sentence,
    required this.instruction,
    required this.answer,
    required this.explanation,
    this.section,
  });

  factory STQuestion.fromJson(Map<String, dynamic> json) {
    return STQuestion(
      id: json['id'] as int,
      sentence: json['sentence'] as String,
      instruction: json['instruction'] as String,
      answer: json['answer'] as String,
      explanation: json['explanation'] as String,
      section: json['section'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sentence': sentence,
      'instruction': instruction,
      'answer': answer,
      'explanation': explanation,
      'section': section,
    };
  }

  STQuestion copyWith({
    int? id,
    String? sentence,
    String? instruction,
    String? answer,
    String? explanation,
    String? section,
  }) {
    return STQuestion(
      id: id ?? this.id,
      sentence: sentence ?? this.sentence,
      instruction: instruction ?? this.instruction,
      answer: answer ?? this.answer,
      explanation: explanation ?? this.explanation,
      section: section ?? this.section,
    );
  }
}
