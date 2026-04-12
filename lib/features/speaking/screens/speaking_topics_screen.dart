import 'package:flutter/material.dart';

import '../models/speaking_item.dart';
import '../services/speaking_service.dart';
import '../screens/speaking_practice_screen.dart';
import '../widgets/speaking_topic_sheet.dart';

class SpeakingTopicsScreen extends StatefulWidget {
  const SpeakingTopicsScreen({super.key});

  @override
  State<SpeakingTopicsScreen> createState() => _SpeakingTopicsScreenState();
}

class _SpeakingTopicsScreenState extends State<SpeakingTopicsScreen> {
  final SpeakingService _speakingService = SpeakingService();

  List<SpeakingItem> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTopics();
  }

  Future<void> _loadTopics() async {
    try {
      final items = await _speakingService.loadSpeakingItems();

      if (!mounted) return;

      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi load Speaking: $e')),
      );
    }
  }

  void _openPractice(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SpeakingPracticeScreen(
          items: _items,
          initialIndex: index,
        ),
      ),
    );
  }

  void _showTopicSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => SpeakingTopicSheet(
        items: _items,
        currentIndex: -1,
        onSelectTopic: (index) {
          Navigator.pop(context);
          _openPractice(index);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Speaking')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Speaking')),
        body: const Center(child: Text('Không có dữ liệu Speaking')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Speaking'),
        actions: [
          IconButton(
            tooltip: 'Xem dạng sheet',
            onPressed: _showTopicSheet,
            icon: const Icon(Icons.grid_view_rounded),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = _items[index];
          return Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            child: InkWell(
              onTap: () => _openPractice(index),
              borderRadius: BorderRadius.circular(22),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.record_voice_over_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Topic ${item.id}: ${item.title}',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.prompt,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              height: 1.4,
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
        },
      ),
    );
  }
}