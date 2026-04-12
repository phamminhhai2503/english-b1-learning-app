import 'package:flutter/material.dart';

class SignsResultScreen extends StatelessWidget {
  final int totalQuestions;
  final int answeredQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final int unansweredQuestions;
  final bool hasWrongQuestions;

  const SignsResultScreen({
    super.key,
    required this.totalQuestions,
    required this.answeredQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.unansweredQuestions,
    required this.hasWrongQuestions,
  });

  @override
  Widget build(BuildContext context) {
    final percent = totalQuestions == 0
        ? 0
        : ((correctAnswers / totalQuestions) * 100).round();

    String message;
    if (percent >= 80) {
      message = 'Làm rất tốt rồi';
    } else if (percent >= 50) {
      message = 'Tiếp tục ôn thêm nhé';
    } else {
      message = 'Nên học lại phần này';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kết quả bài thi Signs'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.emoji_events_rounded,
                      size: 70,
                      color: Colors.amber,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '$correctAnswers / $totalQuestions câu đúng',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$percent%',
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _StatRow(label: 'Đã trả lời', value: '$answeredQuestions'),
                    _StatRow(label: 'Câu đúng', value: '$correctAnswers'),
                    _StatRow(label: 'Câu sai', value: '$wrongAnswers'),
                    _StatRow(
                      label: 'Chưa trả lời',
                      value: '$unansweredQuestions',
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: const Text(
                        'Bạn có thể xem lại đáp án ngay trên bài thi hoặc làm lại những câu đã sai.',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.45,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF92400E),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (hasWrongQuestions) ...[
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context, 'redo_wrong'),
                    child: const Text('Làm lại câu sai'),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, 'review'),
                  child: const Text('Xem lại bài làm'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonal(
                  onPressed: () => Navigator.pop(context, 'restart'),
                  child: const Text('Làm lại từ đầu'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4B5563),
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }
}