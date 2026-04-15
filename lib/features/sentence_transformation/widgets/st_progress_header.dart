import 'package:flutter/material.dart';

class STProgressHeader extends StatelessWidget {
  final int currentIndex;
  final int totalQuestions;
  final int answeredCount;
  final int score;
  final bool showStats;

  const STProgressHeader({
    super.key,
    required this.currentIndex,
    required this.totalQuestions,
    required this.answeredCount,
    required this.score,
    this.showStats = true,
  });

  @override
  Widget build(BuildContext context) {
    final progress =
        totalQuestions == 0 ? 0.0 : answeredCount / totalQuestions;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
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
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'Câu ${currentIndex + 1}/$totalQuestions',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              borderRadius: BorderRadius.circular(8),
            ),
            if (showStats) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _MiniInfo(
                      title: 'Đã kiểm tra',
                      value: '$answeredCount',
                      icon: Icons.edit_note_rounded,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MiniInfo(
                      title: 'Đúng',
                      value: '$score',
                      icon: Icons.emoji_events_rounded,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MiniInfo extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _MiniInfo({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$title: $value',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
