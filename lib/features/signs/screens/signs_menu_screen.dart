import 'package:flutter/material.dart';

import 'signs_exam_screen.dart';
import 'signs_study_screen.dart';

class SignsMenuScreen extends StatelessWidget {
  const SignsMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Signs'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: const Color(0xFFFFFBEB),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.local_library_rounded,
                      size: 52,
                      color: Color(0xFFD97706),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Signs theo 2 chế độ',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Tách riêng học và thi giống Grammar: học để hiểu nghĩa biển báo, thi để kiểm tra phản xạ.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.45,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _MenuCard(
                icon: Icons.school_rounded,
                iconColor: const Color(0xFF2563EB),
                iconBackground: const Color(0xFFEFF6FF),
                title: 'Chế độ học',
                subtitle:
                    'Xem đáp án ngay, có giải thích, có nhóm biển báo và lưu tiến độ đang học.',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SignsStudyScreen()),
                  );
                },
              ),
              const SizedBox(height: 16),
              _MenuCard(
                icon: Icons.assignment_rounded,
                iconColor: const Color(0xFFDC2626),
                iconBackground: const Color(0xFFFEF2F2),
                title: 'Chế độ thi',
                subtitle:
                    'Làm đề ngẫu nhiên như bài kiểm tra, không hiện giải thích ngay, cuối bài có thống kê kết quả.',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SignsExamScreen()),
                  );
                },
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hướng phát triển tiếp theo',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• Thêm từ vựng nổi bật cho từng biển báo\n'
                      '• Tạo phần luyện lại câu sai\n'
                      '• Thêm nghe phát âm đáp án\n'
                      '• Theo dõi nhóm biển báo yếu nhất',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Color(0xFF4B5563),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}