import 'package:flutter/material.dart';

import '../models/st_check_result.dart';
import '../models/st_question.dart';
import '../services/st_service.dart';
import '../services/st_storage_service.dart';
import '../widgets/st_answer_feedback_card.dart';
import '../widgets/st_progress_header.dart';
import '../widgets/st_question_card.dart';
import '../widgets/st_question_picker_sheet.dart';
import 'st_result_screen.dart';

class STExamScreen extends StatefulWidget {
  const STExamScreen({super.key});

  @override
  State<STExamScreen> createState() => _STExamScreenState();
}

class _STExamScreenState extends State<STExamScreen> {
  final STService _service = STService();
  final STStorageService _storageService = STStorageService();

  List<STQuestion> _allQuestions = [];
  List<STQuestion> _questions = [];

  // Typed answers (index → text)
  final Map<int, String> _userAnswers = {};

  // Check results (computed after submit)
  final Map<int, STCheckResult> _checkResults = {};

  int _currentIndex = 0;
  String? _sectionFilter;
  String _mode = 'all';
  bool _submitted = false;
  bool _isLoading = true;
  bool _isHandlingBack = false;

  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initScreen();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initScreen() async {
    try {
      _allQuestions = await _service.loadAllQuestions();
      final saved = await _storageService.getExamSession();

      if (saved != null && saved.questions.isNotEmpty && !saved.submitted) {
        _userAnswers
          ..clear()
          ..addAll(saved.userAnswers);

        setState(() {
          _questions = saved.questions;
          _currentIndex =
              saved.currentIndex.clamp(0, saved.questions.length - 1);
          _submitted = false;
          _sectionFilter = saved.sectionFilter;
          _mode = saved.mode;
          _isLoading = false;
        });

        _syncController();
        return;
      }

      _startNewExam();
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Lỗi load dữ liệu: $e')));
    }
  }

  void _startNewExam({
    List<STQuestion>? customQuestions,
    String mode = 'all',
  }) {
    final filtered = customQuestions ??
        _service.filterQuestions(
          source: _allQuestions,
          section: _sectionFilter,
        );
    final built = _service.buildSessionQuestions(source: filtered);

    _userAnswers.clear();
    _checkResults.clear();

    setState(() {
      _questions = built;
      _currentIndex = 0;
      _submitted = false;
      _mode = mode;
      _isLoading = false;
    });

    _syncController();
    _saveProgress();
  }

  void _syncController() {
    _controller.text = _userAnswers[_currentIndex] ?? '';
    _controller.selection =
        TextSelection.collapsed(offset: _controller.text.length);
  }

  Future<void> _saveProgress() async {
    await _storageService.saveExamSession(
      questions: _questions,
      userAnswers: _userAnswers,
      currentIndex: _currentIndex,
      submitted: _submitted,
      sectionFilter: _sectionFilter,
      mode: _mode,
    );
  }

  Future<void> _clearProgress() async {
    await _storageService.clearExamSession();
  }

  void _saveCurrentInput() {
    if (!_submitted) {
      final text = _controller.text;
      if (text.isNotEmpty) {
        _userAnswers[_currentIndex] = text;
      }
    }
  }

  void _goToNext() {
    if (_currentIndex >= _questions.length - 1) return;
    _saveCurrentInput();
    setState(() => _currentIndex++);
    _syncController();
    _saveProgress();
  }

  void _goToPrevious() {
    if (_currentIndex <= 0) return;
    _saveCurrentInput();
    setState(() => _currentIndex--);
    _syncController();
    _saveProgress();
  }

  void _jumpToQuestion(int index) {
    Navigator.pop(context);
    _saveCurrentInput();
    setState(() => _currentIndex = index);
    _syncController();
    _saveProgress();
  }

  // ── Scoring ──────────────────────────────────────────────────

  void _computeCheckResults() {
    _checkResults.clear();
    for (int i = 0; i < _questions.length; i++) {
      final ua = _userAnswers[i];
      if (ua != null && ua.trim().isNotEmpty) {
        _checkResults[i] = _service.checkAnswer(
          userAnswer: ua,
          expectedAnswer: _questions[i].answer,
        );
      }
    }
  }

  int _getScore() =>
      _checkResults.values.where((r) => r.isCorrect).length;

  int _getWrongCount() =>
      _checkResults.values.where((r) => !r.isCorrect).length;

  int _getUnansweredCount() =>
      _questions.length - _userAnswers.entries.where((e) => e.value.trim().isNotEmpty).length;

  bool _isAnswered(int index) {
    final ua = _userAnswers[index];
    return ua != null && ua.trim().isNotEmpty;
  }

  bool _isCorrectAt(int index) => _checkResults[index]?.isCorrect ?? false;

  // ── Submit & Back ─────────────────────────────────────────────

  Future<String?> _openResultScreen() async {
    return Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => STResultScreen(
          totalQuestions: _questions.length,
          answeredQuestions: _userAnswers.entries
              .where((e) => e.value.trim().isNotEmpty)
              .length,
          correctAnswers: _getScore(),
          wrongAnswers: _getWrongCount(),
          unansweredQuestions: _getUnansweredCount(),
          hasWrongQuestions: _getWrongCount() > 0,
        ),
      ),
    );
  }

  Future<void> _submitExam() async {
    _saveCurrentInput();

    final hasAny =
        _userAnswers.values.any((v) => v.trim().isNotEmpty);
    if (!hasAny) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn chưa nhập câu trả lời nào.')),
      );
      return;
    }

    _computeCheckResults();

    setState(() => _submitted = true);
    await _saveProgress();

    if (!mounted) return;

    final action = await _openResultScreen();
    if (!mounted) return;

    if (action == 'redo_wrong') {
      _redoWrongQuestions();
      return;
    }

    if (action == 'restart') {
      await _clearProgress();
      _startNewExam(mode: 'all');
      return;
    }

    // 'review': stay on exam screen to review answers
  }

  Future<void> _handleBackPressed() async {
    if (_isHandlingBack || !mounted) return;

    if (_submitted) {
      Navigator.of(context).pop();
      return;
    }

    _isHandlingBack = true;
    _saveCurrentInput();
    _computeCheckResults();

    setState(() => _submitted = true);
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

    await _clearProgress();
    if (!mounted) return;
    Navigator.of(context).pop();
    _isHandlingBack = false;
  }

  void _redoWrongQuestions() {
    final wrongQuestions = <STQuestion>[];
    for (int i = 0; i < _questions.length; i++) {
      final ua = _userAnswers[i];
      if (ua != null && ua.trim().isNotEmpty) {
        final result = _checkResults[i];
        if (result != null && !result.isCorrect) {
          wrongQuestions.add(_questions[i]);
        }
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

  // ── UI ────────────────────────────────────────────────────────

  void _showQuestionPicker() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => STQuestionPickerSheet(
        totalQuestions: _questions.length,
        currentIndex: _currentIndex,
        answeredCount:
            _userAnswers.values.where((v) => v.trim().isNotEmpty).length,
        isAnswered: _isAnswered,
        isCorrectAt: _isCorrectAt,
        submitted: _submitted,
        onTapQuestion: _jumpToQuestion,
      ),
    );
  }

  Widget _buildQuestionMeta(STQuestion question) {
    return Row(
      children: [
        _tag('ID ${question.id}'),
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

  Widget _buildAnswerArea() {
    final result = _checkResults[_currentIndex];
    final isCorrect = result?.isCorrect ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _submitted
                  ? (isCorrect
                      ? Colors.green.shade300
                      : (_userAnswers[_currentIndex]?.trim().isNotEmpty == true
                          ? Colors.orange.shade300
                          : Colors.grey.shade300))
                  : const Color(0xFFE5E7EB),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _controller,
            readOnly: _submitted,
            maxLines: 3,
            minLines: 2,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: _submitted
                  ? 'Chưa nhập câu trả lời'
                  : 'Nhập câu trả lời đã viết lại...',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              contentPadding: const EdgeInsets.all(16),
              border: InputBorder.none,
            ),
            style: const TextStyle(fontSize: 16, height: 1.5),
            onChanged: (val) {
              if (!_submitted) {
                _userAnswers[_currentIndex] = val;
              }
            },
          ),
        ),

        // Feedback shown after submit
        if (_submitted && result != null) ...[
          const SizedBox(height: 16),
          STAnswerFeedbackCard(
            result: result,
            explanation: _questions[_currentIndex].explanation,
          ),
        ],

        // Show correct answer if submitted but unanswered
        if (_submitted &&
            result == null &&
            (_userAnswers[_currentIndex]?.trim().isEmpty ?? true)) ...[
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bạn chưa làm câu này',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Đáp án: ${_questions[_currentIndex].answer}',
                  style: const TextStyle(fontSize: 15, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Thi Sentence Transformation')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Thi Sentence Transformation')),
        body: const Center(child: Text('Không có dữ liệu câu hỏi')),
      );
    }

    final question = _questions[_currentIndex];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _handleBackPressed();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Thi Sentence Transformation'),
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
              STProgressHeader(
                currentIndex: _currentIndex,
                totalQuestions: _questions.length,
                answeredCount: _userAnswers.values
                    .where((v) => v.trim().isNotEmpty)
                    .length,
                score: _submitted ? _getScore() : 0,
                showStats: _submitted,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildQuestionMeta(question),
                      const SizedBox(height: 12),
                      STQuestionCard(question: question),
                      const SizedBox(height: 16),
                      _buildAnswerArea(),
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
