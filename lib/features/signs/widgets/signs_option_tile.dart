import 'package:flutter/material.dart';

class SignsOptionTile extends StatelessWidget {
  final String option;
  final String? selectedAnswer;
  final String correctAnswer;
  final bool submitted;
  final bool showInstantFeedback;
  final VoidCallback onTap;

  const SignsOptionTile({
    super.key,
    required this.option,
    required this.selectedAnswer,
    required this.correctAnswer,
    required this.submitted,
    required this.showInstantFeedback,
    required this.onTap,
  });

  bool get _shouldShowResult => submitted && showInstantFeedback;

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedAnswer == option;
    final isCorrect = correctAnswer == option;

    Color borderColor = const Color(0xFFE5E7EB);
    Color backgroundColor = Colors.white;
    Color textColor = const Color(0xFF111827);

    if (_shouldShowResult) {
      if (isCorrect) {
        borderColor = Colors.green.shade300;
        backgroundColor = Colors.green.shade50;
        textColor = Colors.green.shade800;
      } else if (isSelected) {
        borderColor = Colors.red.shade300;
        backgroundColor = Colors.red.shade50;
        textColor = Colors.red.shade800;
      }
    } else if (isSelected) {
      borderColor = const Color(0xFF2563EB);
      backgroundColor = const Color(0xFFEFF6FF);
      textColor = const Color(0xFF1D4ED8);
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor, width: 1.3),
        ),
        child: Text(
          option,
          style: TextStyle(
            fontSize: 15,
            height: 1.45,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }
}