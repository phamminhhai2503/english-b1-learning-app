import 'package:flutter/material.dart';

import 'st_exam_screen.dart';
import 'st_study_screen.dart';

class STMenuScreen extends StatelessWidget {
  const STMenuScreen({super.key});

  void _goTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sentence Transformation'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _MenuCard(
              icon: Icons.school_rounded,
              iconColor: const Color(0xFF2563EB),
              iconBackground: const Color(0xFFEFF6FF),
              title: 'Học Transformation',
              subtitle:
                  'Viết câu, kiểm tra ngay từng câu, xem đáp án đúng và giải thích.',
              onTap: () => _goTo(context, const STStudyScreen()),
            ),
            const SizedBox(height: 16),
            _MenuCard(
              icon: Icons.assignment_rounded,
              iconColor: const Color(0xFFDC2626),
              iconBackground: const Color(0xFFFEF2F2),
              title: 'Thi Transformation',
              subtitle:
                  'Làm hết bài rồi mới nộp, chấm điểm toàn bộ một lần như bài kiểm tra.',
              onTap: () => _goTo(context, const STExamScreen()),
            ),
          ],
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
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
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
      ),
    );
  }
}
