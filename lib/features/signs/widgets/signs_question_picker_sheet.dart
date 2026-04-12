import 'package:flutter/material.dart';

class SignsQuestionPickerSheet extends StatelessWidget {
  final int totalQuestions;
  final int currentIndex;
  final int answeredCount;
  final bool Function(int index) isAnswered;
  final bool Function(int index) isCorrectAt;
  final bool submitted;
  final ValueChanged<int> onTapQuestion;

  const SignsQuestionPickerSheet({
    super.key,
    required this.totalQuestions,
    required this.currentIndex,
    required this.answeredCount,
    required this.isAnswered,
    required this.isCorrectAt,
    required this.submitted,
    required this.onTapQuestion,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.72,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 46,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Danh sách câu hỏi',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  'Đã làm: $answeredCount/$totalQuestions',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: totalQuestions,
              itemBuilder: (context, index) {
                final answered = isAnswered(index);
                final isCurrent = index == currentIndex;

                Color bgColor = Colors.white;
                Color borderColor = const Color(0xFFD1D5DB);
                Color textColor = const Color(0xFF111827);

                if (answered && submitted) {
                  if (isCorrectAt(index)) {
                    bgColor = Colors.green.shade50;
                    borderColor = Colors.green.shade300;
                    textColor = Colors.green.shade800;
                  } else {
                    bgColor = Colors.orange.shade50;
                    borderColor = Colors.orange.shade300;
                    textColor = Colors.orange.shade800;
                  }
                } else if (answered) {
                  bgColor = const Color(0xFFEFF6FF);
                  borderColor = const Color(0xFF93C5FD);
                  textColor = const Color(0xFF1D4ED8);
                }

                if (isCurrent) {
                  borderColor = const Color(0xFF111827);
                }

                return InkWell(
                  onTap: () => onTapQuestion(index),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor, width: 1.4),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}