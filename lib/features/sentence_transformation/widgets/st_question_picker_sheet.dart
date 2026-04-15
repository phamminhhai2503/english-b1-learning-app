import 'package:flutter/material.dart';

class STQuestionPickerSheet extends StatelessWidget {
  final int totalQuestions;
  final int currentIndex;
  final int answeredCount;
  final bool Function(int index) isAnswered;
  final bool Function(int index) isCorrectAt;
  final bool submitted;
  final ValueChanged<int> onTapQuestion;

  const STQuestionPickerSheet({
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        child: Column(
          children: [
            Row(
              children: [
                const Text(
                  'Danh sách câu hỏi',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '$answeredCount/$totalQuestions đã làm',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                itemCount: totalQuestions,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  final isCurrent = index == currentIndex;
                  final answered = isAnswered(index);
                  final correct = submitted && isCorrectAt(index);
                  final wrong = submitted && answered && !isCorrectAt(index);

                  Color bgColor = Colors.white;
                  Color borderColor = Colors.grey.shade300;
                  Color textColor = Colors.black87;

                  if (answered) {
                    bgColor = const Color(0xFFEFF6FF);
                    borderColor = const Color(0xFF3B82F6);
                  }

                  if (submitted && correct) {
                    bgColor = const Color(0xFFDCFCE7);
                    borderColor = const Color(0xFF22C55E);
                  }

                  if (submitted && wrong) {
                    bgColor = const Color(0xFFFEE2E2);
                    borderColor = const Color(0xFFEF4444);
                  }

                  if (isCurrent) {
                    borderColor = Colors.black87;
                    textColor = Colors.black;
                  }

                  return InkWell(
                    onTap: () => onTapQuestion(index),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: borderColor, width: 1.5),
                      ),
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
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
      ),
    );
  }
}
