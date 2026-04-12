import 'package:flutter/material.dart';

import '../models/speaking_result.dart';

class SpeakingResultCard extends StatelessWidget {
  final SpeakingResult result;

  const SpeakingResultCard({
    super.key,
    required this.result,
  });

  Widget _buildWordWrap(String title, List<String> words, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 8),
        if (words.isEmpty)
          const Text('Không có')
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: words
                .map(
                  (word) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: color.withValues(alpha: 0.35)),
                    ),
                    child: Text(
                      word,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final scoreColor = result.matchPercent >= 80
        ? Colors.green
        : result.matchPercent >= 50
            ? Colors.orange
            : Colors.red;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kết quả nói',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text(
                'Độ khớp: ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${result.matchPercent.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: scoreColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Bạn đã nói',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            result.recognizedText.isEmpty
                ? '(Không nhận được nội dung)'
                : result.recognizedText,
            style: const TextStyle(height: 1.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Đáp án mẫu',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            result.expectedText,
            style: const TextStyle(height: 1.5),
          ),
          const SizedBox(height: 16),
          _buildWordWrap('Từ thiếu', result.missingWords, Colors.orange),
          const SizedBox(height: 16),
          _buildWordWrap('Từ thừa / sai', result.extraWords, Colors.red),
        ],
      ),
    );
  }
}