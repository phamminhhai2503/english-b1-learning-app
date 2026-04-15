import 'package:flutter/material.dart';

import '../models/st_check_result.dart';

class STAnswerFeedbackCard extends StatelessWidget {
  final STCheckResult result;
  final String explanation;

  const STAnswerFeedbackCard({
    super.key,
    required this.result,
    required this.explanation,
  });

  @override
  Widget build(BuildContext context) {
    final isCorrect = result.isCorrect;

    final bgColor = isCorrect ? Colors.green.shade50 : Colors.orange.shade50;
    final borderColor =
        isCorrect ? Colors.green.shade200 : Colors.orange.shade200;
    final headerColor =
        isCorrect ? Colors.green.shade800 : Colors.orange.shade800;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: headerColor,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                isCorrect ? 'Chính xác!' : 'Chưa đúng',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: headerColor,
                ),
              ),
              if (!isCorrect) ...[
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${result.matchPercent.toStringAsFixed(0)}% từ đúng',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.orange.shade900,
                    ),
                  ),
                ),
              ],
            ],
          ),

          if (!isCorrect) ...[
            const SizedBox(height: 14),
            // User answer with word highlighting
            const Text(
              'Câu bạn viết:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 6),
            _buildHighlightedAnswer(result),

            const SizedBox(height: 12),
            // Correct answer
            const Text(
              'Đáp án đúng:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              result.expectedAnswer,
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),

            if (result.missingWords.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  const _TagLabel(text: 'Thiếu:'),
                  ...result.missingWords.map(
                    (w) => _WordChip(
                      word: w,
                      color: Colors.red.shade600,
                      background: Colors.red.shade50,
                    ),
                  ),
                ],
              ),
            ],

            if (result.extraWords.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  const _TagLabel(text: 'Thừa:'),
                  ...result.extraWords.map(
                    (w) => _WordChip(
                      word: w,
                      color: Colors.purple.shade600,
                      background: Colors.purple.shade50,
                    ),
                  ),
                ],
              ),
            ],
          ],

          const SizedBox(height: 14),
          // Explanation
          const Text(
            'Giải thích:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            explanation,
            style: const TextStyle(fontSize: 15, height: 1.55),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightedAnswer(STCheckResult result) {
    // Split user answer into words and color each based on whether
    // it appears in the matched set.
    final rawWords = result.userAnswer.split(RegExp(r'\s+'));
    final tempMatched = List<String>.from(result.matchedWords);

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: rawWords.map((rawWord) {
        final clean = rawWord
            .toLowerCase()
            .replaceAll(RegExp(r"[^\w]"), '');
        final isMatched = tempMatched.contains(clean);
        if (isMatched) {
          tempMatched.remove(clean);
        }
        return _WordChip(
          word: rawWord,
          color: isMatched ? Colors.green.shade700 : Colors.red.shade600,
          background:
              isMatched ? Colors.green.shade50 : Colors.red.shade50,
        );
      }).toList(),
    );
  }
}

class _TagLabel extends StatelessWidget {
  final String text;
  const _TagLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Color(0xFF374151),
      ),
    );
  }
}

class _WordChip extends StatelessWidget {
  final String word;
  final Color color;
  final Color background;

  const _WordChip({
    required this.word,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        word,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
