import 'package:flutter/material.dart';

class GrammarOptionTile extends StatelessWidget {
  final String option;
  final String? selectedAnswer;
  final String correctAnswer;
  final bool submitted;
  final bool showInstantFeedback;
  final VoidCallback onTap;

  const GrammarOptionTile({
    super.key,
    required this.option,
    required this.selectedAnswer,
    required this.correctAnswer,
    required this.submitted,
    required this.showInstantFeedback,
    required this.onTap,
  });

  bool get _isSelected => option == selectedAnswer;
  bool get _isCorrect => option == correctAnswer;
  bool get _isWrongSelected =>
      option == selectedAnswer && option != correctAnswer;

  bool get _shouldShowResult => submitted && showInstantFeedback;

  Color _backgroundColor() {
    if (_shouldShowResult) {
      if (_isCorrect) return Colors.green.shade100;
      if (_isWrongSelected) return Colors.red.shade100;
      return Colors.white;
    }

    if (_isSelected) {
      return const Color(0xFFEFF6FF);
    }

    return Colors.white;
  }

  Color _borderColor() {
    if (_shouldShowResult) {
      if (_isCorrect) return Colors.green;
      if (_isWrongSelected) return Colors.red;
      return Colors.grey.shade300;
    }

    if (_isSelected) {
      return const Color(0xFF2563EB);
    }

    return Colors.grey.shade300;
  }

  Color _textColor() {
    if (_shouldShowResult) {
      if (_isCorrect) return Colors.green.shade800;
      if (_isWrongSelected) return Colors.red.shade800;
      return const Color(0xFF111827);
    }

    if (_isSelected) {
      return const Color(0xFF1D4ED8);
    }

    return const Color(0xFF111827);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: _backgroundColor(),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _borderColor(), width: 1.4),
        ),
        child: Text(
          option,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _textColor(),
          ),
        ),
      ),
    );
  }
}