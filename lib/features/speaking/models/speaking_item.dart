class SpeakingItem {
  final int id;
  final String title;
  final String prompt;
  final String sampleAnswer;

  SpeakingItem({
    required this.id,
    required this.title,
    required this.prompt,
    required this.sampleAnswer,
  });

  factory SpeakingItem.fromJson(Map<String, dynamic> json) {
    return SpeakingItem(
      id: json['id'] as int,
      title: json['title'] as String,
      prompt: json['prompt'] as String,
      sampleAnswer: json['sampleAnswer'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'prompt': prompt,
      'sampleAnswer': sampleAnswer,
    };
  }
}