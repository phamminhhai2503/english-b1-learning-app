import 'package:flutter/material.dart';

import '../models/grammar_question.dart';
import '../services/grammar_session_service.dart';
import '../services/grammar_storage_service.dart';
import '../widgets/grammar_option_tile.dart';
import '../widgets/grammar_progress_header.dart';
import '../widgets/grammar_question_card.dart';
import '../widgets/grammar_question_picker_sheet.dart';

class GrammarStudyScreen extends StatefulWidget {
  const GrammarStudyScreen({super.key});

  @override
  State<GrammarStudyScreen> createState() => _GrammarStudyScreenState();
}

class _GrammarStudyScreenState extends State<GrammarStudyScreen> {
  final GrammarSessionService _sessionService = GrammarSessionService();
  final GrammarStorageService _storageService = GrammarStorageService();

  List<GrammarQuestion> _allQuestions = [];
  List<GrammarQuestion> _questions = [];
  final Map<int, String> _selectedAnswers = {};

  int _currentIndex = 0;
  int? _pageFilter;
  String? _sectionFilter;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initScreen();
  }

  Future<void> _initScreen() async {
    try {
      _allQuestions = await _sessionService.loadAllQuestions();
      final saved = await _storageService.getStudySession();

      if (saved != null && saved.questions.isNotEmpty) {
        setState(() {
          _questions = saved.questions;
          _selectedAnswers
            ..clear()
            ..addAll(saved.answers);
          _currentIndex = saved.currentIndex.clamp(
            0,
            saved.questions.length - 1,
          );
          _pageFilter = saved.pageFilter;
          _sectionFilter = saved.sectionFilter;
          _isLoading = false;
        });
        return;
      }

      _startNewStudy();
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi load dữ liệu: $e')));
    }
  }

  void _startNewStudy() {
    final filtered = _sessionService.filterQuestions(
      source: _allQuestions,
      page: _pageFilter,
      section: _sectionFilter,
    );

    final built = _sessionService.buildSessionQuestions(
      source: filtered,
      shuffleQuestions: true,
      shuffleOptions: true,
    );

    setState(() {
      _questions = built;
      _selectedAnswers.clear();
      _currentIndex = 0;
      _isLoading = false;
    });

    _saveProgress();
  }

  Future<void> _saveProgress() async {
    await _storageService.saveStudySession(
      questions: _questions,
      answers: _selectedAnswers,
      currentIndex: _currentIndex,
      pageFilter: _pageFilter,
      sectionFilter: _sectionFilter,
    );
  }

  void _selectAnswer(String answer) {
    if (_selectedAnswers.containsKey(_currentIndex)) return;

    setState(() {
      _selectedAnswers[_currentIndex] = answer;
    });
    _saveProgress();
  }

  void _goToNext() {
    if (_currentIndex >= _questions.length - 1) return;
    setState(() => _currentIndex++);
    _saveProgress();
  }

  void _goToPrevious() {
    if (_currentIndex <= 0) return;
    setState(() => _currentIndex--);
    _saveProgress();
  }

  void _jumpToQuestion(int index) {
    Navigator.pop(context);
    setState(() => _currentIndex = index);
    _saveProgress();
  }

  void _showQuestionPicker() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => GrammarQuestionPickerSheet(
        totalQuestions: _questions.length,
        currentIndex: _currentIndex,
        answeredCount: _selectedAnswers.length,
        isAnswered: (index) => _selectedAnswers.containsKey(index),
        isCorrectAt: (index) =>
            _selectedAnswers[index] == _questions[index].answer,
        submitted: true,
        onTapQuestion: _jumpToQuestion,
      ),
    );
  }

  Widget _buildExplanationCard({
    required GrammarQuestion question,
    required String? selectedAnswer,
  }) {
    if (selectedAnswer == null) {
      return const SizedBox.shrink();
    }

    final isCorrect = selectedAnswer == question.answer;
    final title = isCorrect ? 'Chính xác' : 'Đáp án đúng: ${question.answer}';

    final bgColor = isCorrect ? Colors.green.shade50 : Colors.orange.shade50;
    final borderColor =
        isCorrect ? Colors.green.shade200 : Colors.orange.shade200;
    final titleColor =
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
          Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            question.explanation,
            style: const TextStyle(fontSize: 15, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionMeta(GrammarQuestion question) {
    return Row(
      children: [
        _tag('ID ${question.id}'),
        const SizedBox(width: 8),
        if ((question.page ?? 0) > 0) _tag('Page ${question.page}'),
        const SizedBox(width: 8),
        if ((question.section ?? '').isNotEmpty)
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: _tag(question.section!),
            ),
          ),
      ],
    );
  }

  Widget _tag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1D4ED8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Học Grammar')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Học Grammar')),
        body: const Center(child: Text('Không có dữ liệu câu hỏi')),
      );
    }

    final question = _questions[_currentIndex];
    final selectedAnswer = _selectedAnswers[_currentIndex];
    final score = _selectedAnswers.entries
        .where((e) => _questions[e.key].answer == e.value)
        .length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Học Grammar'),
        actions: [
          IconButton(
            tooltip: 'Danh sách câu',
            onPressed: _showQuestionPicker,
            icon: const Icon(Icons.grid_view_rounded),
          ),
          IconButton(
            tooltip: 'Làm lại',
            onPressed: _startNewStudy,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            GrammarProgressHeader(
              currentIndex: _currentIndex,
              totalQuestions: _questions.length,
              answeredCount: _selectedAnswers.length,
              score: score,
              showStats: true,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  children: [
                    _buildQuestionMeta(question),
                    const SizedBox(height: 12),
                    GrammarQuestionCard(question: question),
                    const SizedBox(height: 16),
                    ...question.options.map(
                      (option) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GrammarOptionTile(
                          option: option,
                          selectedAnswer: selectedAnswer,
                          correctAnswer: question.answer,
                          submitted: selectedAnswer != null,
                          showInstantFeedback: true,
                          onTap: () => _selectAnswer(option),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildExplanationCard(
                      question: question,
                      selectedAnswer: selectedAnswer,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _currentIndex > 0 ? _goToPrevious : null,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Câu trước'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          _currentIndex < _questions.length - 1 ? _goToNext : null,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Câu sau'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}