import 'package:flutter/material.dart';

import '../models/grammar_question.dart';

class GrammarQuestionCard extends StatelessWidget {
  final GrammarQuestion question;

  const GrammarQuestionCard({
    super.key,
    required this.question,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Text(
        question.question,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          height: 1.45,
        ),
      ),
    );
  }
}