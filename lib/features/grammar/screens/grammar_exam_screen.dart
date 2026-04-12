import 'package:flutter/material.dart';

import '../models/grammar_question.dart';
import '../services/grammar_session_service.dart';
import '../services/grammar_storage_service.dart';
import '../widgets/grammar_option_tile.dart';
import '../widgets/grammar_progress_header.dart';
import '../widgets/grammar_question_card.dart';
import '../widgets/grammar_question_picker_sheet.dart';
import 'grammar_result_screen.dart';

class GrammarExamScreen extends StatefulWidget {
  const GrammarExamScreen({super.key});

  @override
  State<GrammarExamScreen> createState() => _GrammarExamScreenState();
}

class _GrammarExamScreenState extends State<GrammarExamScreen> {
  final GrammarSessionService _sessionService = GrammarSessionService();
  final GrammarStorageService _storageService = GrammarStorageService();

  List<GrammarQuestion> _allQuestions = [];
  List<GrammarQuestion> _questions = [];
  final Map<int, String> _selectedAnswers = {};

  int _currentIndex = 0;
  int? _pageFilter;
  String? _sectionFilter;
  String _mode = 'all';
  bool _submitted = false;
  bool _isLoading = true;
  bool _isHandlingBack = false;

  @override
  void initState() {
    super.initState();
    _initScreen();
  }

  Future<void> _initScreen() async {
    try {
      _allQuestions = await _sessionService.loadAllQuestions();
      final saved = await _storageService.getExamSession();

      // Chỉ khôi phục nếu là bài thi chưa nộp
      if (saved != null && saved.questions.isNotEmpty && !saved.submitted) {
        setState(() {
          _questions = saved.questions;
          _selectedAnswers
            ..clear()
            ..addAll(saved.answers);
          _currentIndex = saved.currentIndex.clamp(
            0,
            saved.questions.length - 1,
          );
          _submitted = false;
          _pageFilter = saved.pageFilter;
          _sectionFilter = saved.sectionFilter;
          _mode = saved.mode;
          _isLoading = false;
        });
        return;
      }

      _startNewExam();
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi load dữ liệu: $e')));
    }
  }

  void _startNewExam({
    List<GrammarQuestion>? customQuestions,
    String mode = 'all',
  }) {
    final filtered = customQuestions ??
        _sessionService.filterQuestions(
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
      _submitted = false;
      _mode = mode;
      _isLoading = false;
    });

    _saveProgress();
  }

  Future<void> _saveProgress() async {
    await _storageService.saveExamSession(
      questions: _questions,
      answers: _selectedAnswers,
      currentIndex: _currentIndex,
      submitted: _submitted,
      pageFilter: _pageFilter,
      sectionFilter: _sectionFilter,
      mode: _mode,
    );
  }

  Future<void> _clearProgress() async {
    await _storageService.clearExamSession();
  }

  void _selectAnswer(String answer) {
    if (_submitted) return;

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

  int _getScore() {
    int score = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (_selectedAnswers[i] == _questions[i].answer) {
        score++;
      }
    }
    return score;
  }

  int _getWrongCount() {
    int wrong = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (_selectedAnswers.containsKey(i) &&
          _selectedAnswers[i] != _questions[i].answer) {
        wrong++;
      }
    }
    return wrong;
  }

  int _getUnansweredCount() {
    return _questions.length - _selectedAnswers.length;
  }

  bool _isAnswered(int index) => _selectedAnswers.containsKey(index);

  bool _isCorrectAt(int index) {
    if (!_selectedAnswers.containsKey(index)) return false;
    return _selectedAnswers[index] == _questions[index].answer;
  }

  Future<String?> _openResultScreen() async {
    return Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => GrammarResultScreen(
          totalQuestions: _questions.length,
          answeredQuestions: _selectedAnswers.length,
          correctAnswers: _getScore(),
          wrongAnswers: _getWrongCount(),
          unansweredQuestions: _getUnansweredCount(),
          hasWrongQuestions: _getWrongCount() > 0,
        ),
      ),
    );
  }

  Future<void> _submitExam() async {
    if (_selectedAnswers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn chưa chọn đáp án nào.')),
      );
      return;
    }

    setState(() {
      _submitted = true;
    });

    await _saveProgress();

    if (!mounted) return;

    final action = await _openResultScreen();
    if (!mounted) return;

    if (action == 'redo_wrong') {
      _redoWrongQuestions();
      return;
    }

    if (action == 'restart') {
      _startNewExam(mode: 'all');
      return;
    }

    // review -> ở lại màn thi để xem lại đáp án
  }

  Future<void> _handleBackPressed() async {
    if (_isHandlingBack || !mounted) return;

    // Nếu đã nộp rồi thì thoát bình thường
    if (_submitted) {
      Navigator.of(context).pop();
      return;
    }

    _isHandlingBack = true;

    setState(() {
      _submitted = true;
    });

    await _saveProgress();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Thoát giữa chừng bị tính là gian lận. Hệ thống đã chấm điểm bài thi hiện tại.',
        ),
      ),
    );

    final action = await _openResultScreen();

    if (!mounted) return;

    if (action == 'redo_wrong') {
      _redoWrongQuestions();
      _isHandlingBack = false;
      return;
    }

    if (action == 'restart') {
      await _clearProgress();
      _startNewExam(mode: 'all');
      _isHandlingBack = false;
      return;
    }

    // review hoặc đóng kết quả -> thoát khỏi màn thi và xóa phiên cũ
    await _clearProgress();

    if (!mounted) return;
    Navigator.of(context).pop();

    _isHandlingBack = false;
  }

  void _redoWrongQuestions() {
    final wrongQuestions = <GrammarQuestion>[];

    for (int i = 0; i < _questions.length; i++) {
      if (_selectedAnswers.containsKey(i) &&
          _selectedAnswers[i] != _questions[i].answer) {
        wrongQuestions.add(_questions[i]);
      }
    }

    if (wrongQuestions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không có câu sai để làm lại.')),
      );
      return;
    }

    _startNewExam(customQuestions: wrongQuestions, mode: 'wrong_only');
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
        isAnswered: _isAnswered,
        isCorrectAt: _isCorrectAt,
        submitted: _submitted,
        onTapQuestion: _jumpToQuestion,
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

  Widget _buildExplanationCard({
    required GrammarQuestion question,
    required String? selectedAnswer,
  }) {
    if (!_submitted) {
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Thi Grammar')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Thi Grammar')),
        body: const Center(child: Text('Không có dữ liệu câu hỏi')),
      );
    }

    final question = _questions[_currentIndex];
    final selectedAnswer = _selectedAnswers[_currentIndex];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _handleBackPressed();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Thi Grammar'),
          actions: [
            IconButton(
              tooltip: 'Danh sách câu',
              onPressed: _showQuestionPicker,
              icon: const Icon(Icons.grid_view_rounded),
            ),
            IconButton(
              tooltip: 'Nộp bài',
              onPressed: _submitted ? null : _submitExam,
              icon: const Icon(Icons.task_alt),
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
              score: 0,
              showStats: false,
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
                            submitted: _submitted,
                            showInstantFeedback: false,
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
                        onPressed: _currentIndex < _questions.length - 1
                            ? _goToNext
                            : null,
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
      ),
    );
  }
}