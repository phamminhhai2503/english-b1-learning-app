import 'package:flutter/material.dart';

import '../models/st_check_result.dart';
import '../models/st_question.dart';
import '../services/st_service.dart';
import '../services/st_storage_service.dart';
import '../widgets/st_answer_feedback_card.dart';
import '../widgets/st_progress_header.dart';
import '../widgets/st_question_card.dart';
import '../widgets/st_question_picker_sheet.dart';

class STStudyScreen extends StatefulWidget {
  const STStudyScreen({super.key});

  @override
  State<STStudyScreen> createState() => _STStudyScreenState();
}

class _STStudyScreenState extends State<STStudyScreen> {
  final STService _service = STService();
  final STStorageService _storageService = STStorageService();

  List<STQuestion> _allQuestions = [];
  List<STQuestion> _questions = [];

  // Typed (but not yet checked) answers
  final Map<int, String> _userAnswers = {};

  // Submitted & checked answers
  final Map<int, String> _checkedAnswers = {};

  // Check results (derived on check, kept for display)
  final Map<int, STCheckResult> _checkResults = {};

  int _currentIndex = 0;
  String? _sectionFilter;
  bool _isLoading = true;

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
      final saved = await _storageService.getStudySession();

      if (saved != null && saved.questions.isNotEmpty) {
        _checkedAnswers
          ..clear()
          ..addAll(saved.checkedAnswers);
        _userAnswers
          ..clear()
          ..addAll(saved.userAnswers);

        // Rebuild check results from restored data
        for (int i = 0; i < saved.questions.length; i++) {
          final checked = _checkedAnswers[i];
          if (checked != null) {
            _checkResults[i] = _service.checkAnswer(
              userAnswer: checked,
              expectedAnswer: saved.questions[i].answer,
            );
          }
        }

        setState(() {
          _questions = saved.questions;
          _currentIndex =
              saved.currentIndex.clamp(0, saved.questions.length - 1);
          _sectionFilter = saved.sectionFilter;
          _isLoading = false;
        });

        _syncController();
        return;
      }

      _startNewStudy();
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Lỗi load dữ liệu: $e')));
    }
  }

  void _startNewStudy() {
    final filtered = _service.filterQuestions(
      source: _allQuestions,
      section: _sectionFilter,
    );
    final built = _service.buildSessionQuestions(source: filtered);

    setState(() {
      _questions = built;
      _userAnswers.clear();
      _checkedAnswers.clear();
      _checkResults.clear();
      _currentIndex = 0;
      _isLoading = false;
    });

    _syncController();
    _saveProgress();
  }

  void _syncController() {
    final checked = _checkedAnswers[_currentIndex];
    if (checked != null) {
      _controller.text = checked;
    } else {
      _controller.text = _userAnswers[_currentIndex] ?? '';
    }
    _controller.selection = TextSelection.collapsed(
      offset: _controller.text.length,
    );
  }

  Future<void> _saveProgress() async {
    await _storageService.saveStudySession(
      questions: _questions,
      userAnswers: _userAnswers,
      checkedAnswers: _checkedAnswers,
      currentIndex: _currentIndex,
      sectionFilter: _sectionFilter,
    );
  }

  void _checkCurrentAnswer() {
    if (_checkedAnswers.containsKey(_currentIndex)) return;

    final typed = _controller.text.trim();
    if (typed.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hãy nhập câu trả lời trước.')),
      );
      return;
    }

    final result = _service.checkAnswer(
      userAnswer: typed,
      expectedAnswer: _questions[_currentIndex].answer,
    );

    setState(() {
      _checkedAnswers[_currentIndex] = typed;
      _checkResults[_currentIndex] = result;
    });

    _saveProgress();
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

  void _saveCurrentInput() {
    if (!_checkedAnswers.containsKey(_currentIndex)) {
      _userAnswers[_currentIndex] = _controller.text;
    }
  }

  void _jumpToQuestion(int index) {
    Navigator.pop(context);
    _saveCurrentInput();
    setState(() => _currentIndex = index);
    _syncController();
    _saveProgress();
  }

  void _showQuestionPicker() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => STQuestionPickerSheet(
        totalQuestions: _questions.length,
        currentIndex: _currentIndex,
        answeredCount: _checkedAnswers.length,
        isAnswered: (i) => _checkedAnswers.containsKey(i),
        isCorrectAt: (i) => _checkResults[i]?.isCorrect ?? false,
        submitted: true,
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
    final isChecked = _checkedAnswers.containsKey(_currentIndex);
    final result = _checkResults[_currentIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Input field
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isChecked
                  ? (result?.isCorrect == true
                      ? Colors.green.shade300
                      : Colors.orange.shade300)
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
            readOnly: isChecked,
            maxLines: 3,
            minLines: 2,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: 'Nhập câu trả lời đã viết lại...',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              contentPadding: const EdgeInsets.all(16),
              border: InputBorder.none,
            ),
            style: const TextStyle(fontSize: 16, height: 1.5),
            onChanged: (val) {
              if (!isChecked) {
                _userAnswers[_currentIndex] = val;
              }
            },
          ),
        ),

        // Check button (only when not yet checked)
        if (!isChecked) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _checkCurrentAnswer,
              icon: const Icon(Icons.check_rounded),
              label: const Text('Kiểm tra'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],

        // Feedback card (shown after checking)
        if (isChecked && result != null) ...[
          const SizedBox(height: 16),
          STAnswerFeedbackCard(
            result: result,
            explanation: _questions[_currentIndex].explanation,
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Học Sentence Transformation')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Học Sentence Transformation')),
        body: const Center(child: Text('Không có dữ liệu câu hỏi')),
      );
    }

    final question = _questions[_currentIndex];
    final score =
        _checkResults.values.where((r) => r.isCorrect).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Học Sentence Transformation'),
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
            STProgressHeader(
              currentIndex: _currentIndex,
              totalQuestions: _questions.length,
              answeredCount: _checkedAnswers.length,
              score: score,
              showStats: true,
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
    );
  }
}
