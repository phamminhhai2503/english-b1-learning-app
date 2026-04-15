import 'package:flutter/material.dart';

import '../features/grammar/screens/grammar_menu_screen.dart';
import '../features/sentence_transformation/screens/st_menu_screen.dart';
import '../features/signs/screens/signs_menu_screen.dart';
import '../features/speaking/screens/speaking_topics_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _goTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: SafeArea(
        child: Column(
          children: [
            const _HomeHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                child: Column(
                  children: [
                    _MenuCard(
                      title: 'Grammar',
                      subtitle:
                          'Học ngữ pháp theo chế độ học hoặc thi, có lưu tiến độ.',
                      icon: Icons.quiz_rounded,
                      iconBackground: const Color(0xFF2563EB),
                      onTap: () => _goTo(context, const GrammarMenuScreen()),
                    ),
                    const SizedBox(height: 16),
                    _MenuCard(
                      title: 'Signs',
                      subtitle:
                          'Học và thi biển báo theo 2 chế độ riêng, có giải thích và lưu tiến độ.',
                      icon: Icons.local_library_rounded,
                      iconBackground: const Color(0xFFF59E0B),
                      onTap: () => _goTo(context, const SignsMenuScreen()),
                    ),
                    const SizedBox(height: 16),
                    _MenuCard(
                      title: 'Speaking',
                      subtitle:
                          'Luyện nói theo chủ đề, nói xong mới hiện đáp án mẫu.',
                      icon: Icons.record_voice_over_rounded,
                      iconBackground: const Color(0xFF8B5CF6),
                      onTap: () => _goTo(context, const SpeakingTopicsScreen()),
                    ),
                    const SizedBox(height: 16),
                    _MenuCard(
                      title: 'Sentence Transformation',
                      subtitle:
                          'Viết lại câu theo yêu cầu, kiểm tra ngay hoặc nộp bài cuối, có chỉ ra lỗi sai.',
                      icon: Icons.edit_note_rounded,
                      iconBackground: const Color(0xFF059669),
                      onTap: () => _goTo(context, const STMenuScreen()),
                    ),
                    const SizedBox(height: 22),
                    const _QuickInfoCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF2563EB),
            Color(0xFF3B82F6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'English Study App',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                ),
                child: const Text(
                  'Offline',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Chọn phần bạn muốn học. App chạy đơn giản, nhẹ và không cần đăng nhập.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.95),
              fontSize: 14,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBackground;
  final VoidCallback onTap;

  const _MenuCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBackground,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFE5E7EB),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
            color: Colors.white,
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickInfoCard extends StatelessWidget {
  const _QuickInfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.lightbulb_rounded,
              color: Color(0xFF4F46E5),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gợi ý học',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Nên học Grammar trước, sau đó học Signs và Sentence Transformation theo chế độ học rồi mới chuyển sang chế độ thi.',
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.45,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}