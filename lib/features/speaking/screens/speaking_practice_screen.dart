import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../models/speaking_item.dart';
import '../models/speaking_result.dart';
import '../services/speaking_compare_service.dart';
import '../services/speaking_storage_service.dart';
import '../widgets/speaking_result_card.dart';
import '../widgets/speaking_topic_sheet.dart';

class SpeakingPracticeScreen extends StatefulWidget {
  final List<SpeakingItem> items;
  final int initialIndex;

  const SpeakingPracticeScreen({
    super.key,
    required this.items,
    required this.initialIndex,
  });

  @override
  State<SpeakingPracticeScreen> createState() => _SpeakingPracticeScreenState();
}

class _SpeakingPracticeScreenState extends State<SpeakingPracticeScreen> {
  final SpeakingStorageService _storageService = SpeakingStorageService();
  final SpeakingCompareService _compareService = SpeakingCompareService();
  final stt.SpeechToText _speech = stt.SpeechToText();

  late int _currentIndex;

  bool _speechAvailable = false;
  bool _isListening = false;
  bool _isInitializingSpeech = true;
  bool _isStopping = false;
  bool _hasProcessedResult = false;

  String _spokenText = '';
  String _liveSpokenText = '';
  String _lastError = '';

  List<stt.LocaleName> _availableLocales = [];
  String? _selectedLocaleId;

  SpeakingResult? _result;
  bool _showSample = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    unawaited(_initSpeech());
    unawaited(_storageService.saveCurrentIndex(_currentIndex));
  }

  @override
  void dispose() {
    _speech.cancel();
    super.dispose();
  }

  SpeakingItem get _item => widget.items[_currentIndex];

  Future<bool> _requestMicPermission() async {
    if (kIsWeb) return true;

    final status = await Permission.microphone.status;
    if (status.isGranted) return true;

    final result = await Permission.microphone.request();
    return result.isGranted;
  }

  String? _pickBestEnglishLocale(List<stt.LocaleName> locales) {
    if (kIsWeb) return null;

    for (final locale in locales) {
      if (locale.localeId.toLowerCase() == 'en_us') {
        return locale.localeId;
      }
    }

    for (final locale in locales) {
      if (locale.localeId.toLowerCase().startsWith('en_')) {
        return locale.localeId;
      }
    }

    return null;
  }

  Future<void> _initSpeech() async {
    try {
      final hasPermission = await _requestMicPermission();

      if (!hasPermission) {
        if (!mounted) return;
        setState(() {
          _speechAvailable = false;
          _isInitializingSpeech = false;
          _lastError = 'Microphone permission denied';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bạn chưa cấp quyền microphone cho ứng dụng'),
          ),
        );
        return;
      }

      final available = await _speech.initialize(
        onStatus: (status) async {
          debugPrint('Speech status: $status');

          if (!mounted) return;

          if (_isListening &&
              !_isStopping &&
              !_hasProcessedResult &&
              (status == 'done' || status == 'notListening')) {
            final hasWords = _spokenText.trim().isNotEmpty ||
                _liveSpokenText.trim().isNotEmpty;

            if (hasWords) {
              await _finalizeSpeechResult();
            } else {
              setState(() {
                _isListening = false;
                _isStopping = false;
              });
            }
          }
        },
        onError: (error) async {
          debugPrint('Speech error: $error');
          _lastError = error.errorMsg;

          if (!mounted) return;

          if (error.errorMsg == 'error_language_unavailable') {
            setState(() {
              _isListening = false;
              _isStopping = false;
              _selectedLocaleId = null;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Thiết bị không hỗ trợ en_US. App sẽ dùng ngôn ngữ mặc định của máy.',
                ),
              ),
            );
            return;
          }

          final hasWords = _spokenText.trim().isNotEmpty ||
              _liveSpokenText.trim().isNotEmpty;

          if (_isListening &&
              !_isStopping &&
              !_hasProcessedResult &&
              hasWords) {
            await _finalizeSpeechResult();
            return;
          }

          setState(() {
            _isListening = false;
            _isStopping = false;
          });
        },
        debugLogging: true,
      );

      final locales = await _speech.locales();
      final bestLocale = _pickBestEnglishLocale(locales);

      if (!mounted) return;

      setState(() {
        _speechAvailable = available;
        _isInitializingSpeech = false;
        _availableLocales = locales;
        _selectedLocaleId = bestLocale;
      });

      if (!available && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Không khởi tạo được nhận diện giọng nói. Hãy kiểm tra quyền mic và trình duyệt/thiết bị.',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _speechAvailable = false;
        _isInitializingSpeech = false;
        _lastError = e.toString();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không khởi tạo được mic: $e')),
      );
    }
  }

  Future<void> _resetSessionState() async {
    await _speech.cancel();

    if (!mounted) return;

    setState(() {
      _spokenText = '';
      _liveSpokenText = '';
      _result = null;
      _showSample = false;
      _isListening = false;
      _isStopping = false;
      _hasProcessedResult = false;
      _lastError = '';
    });
  }

  Future<void> _saveIndex() async {
    await _storageService.saveCurrentIndex(_currentIndex);
  }

  Future<void> _goToTopic(int index) async {
    await _speech.cancel();

    if (!mounted) return;

    setState(() {
      _currentIndex = index;
      _spokenText = '';
      _liveSpokenText = '';
      _result = null;
      _showSample = false;
      _isListening = false;
      _isStopping = false;
      _hasProcessedResult = false;
      _lastError = '';
    });

    await _saveIndex();
  }

  void _goToNext() {
    if (_currentIndex >= widget.items.length - 1) return;
    unawaited(_goToTopic(_currentIndex + 1));
  }

  void _goToPrevious() {
    if (_currentIndex <= 0) return;
    unawaited(_goToTopic(_currentIndex - 1));
  }

  Future<void> _retryCurrentTopic() async {
    await _resetSessionState();
  }

  Future<void> _startListening() async {
    if (_isInitializingSpeech) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đang khởi tạo microphone, chờ một chút...'),
        ),
      );
      return;
    }

    if (!_speechAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            kIsWeb
                ? 'Web chưa sẵn sàng nhận mic. Hãy cho phép microphone và chạy bằng localhost hoặc HTTPS.'
                : 'Thiết bị không hỗ trợ nhận giọng nói hoặc chưa được cấp quyền mic.',
          ),
        ),
      );
      return;
    }

    if (_isListening || _isStopping) return;

    final hasPermission = await _requestMicPermission();
    if (!hasPermission) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bạn chưa cấp quyền microphone'),
        ),
      );
      return;
    }

    await _speech.cancel();
    await Future.delayed(const Duration(milliseconds: 150));

    if (!mounted) return;

    setState(() {
      _spokenText = '';
      _liveSpokenText = '';
      _result = null;
      _showSample = false;
      _isListening = true;
      _isStopping = false;
      _hasProcessedResult = false;
      _lastError = '';
    });

    try {
      await _speech.listen(
        localeId: kIsWeb ? null : _selectedLocaleId,
        listenFor: const Duration(seconds: 20),
        pauseFor: const Duration(seconds: 3),
        listenOptions: stt.SpeechListenOptions(
          partialResults: !kIsWeb,
          cancelOnError: false,
        ),
        onResult: (result) {
          if (!mounted || _hasProcessedResult) return;

          final words = result.recognizedWords.trim();
          if (words.isEmpty) return;

          if (kIsWeb) {
            _spokenText = words;
            setState(() {
              _liveSpokenText = words;
            });
            return;
          }

          setState(() {
            _liveSpokenText = words;
          });

          if (result.finalResult) {
            _spokenText = words;
          }
        },
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isListening = false;
        _isStopping = false;
        _lastError = e.toString();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể bắt đầu ghi âm: $e')),
      );
    }
  }

  Future<void> _stopListening() async {
    if (!_isListening || _isStopping) return;
    await _finalizeSpeechResult(forceStop: true);
  }

  String _preCleanRawSpeech(String text) {
    return text
        .replaceAll(RegExp(r'\b(\w+)\1+\b', caseSensitive: false), r'\1')
        .replaceAll('ithe', 'i the')
        .replaceAll('amthe', 'am the')
        .replaceAll('dothe', 'do the')
        .replaceAll('whenthe', 'when the')
        .replaceAll('thethe', 'the')
        .trim();
  }

  String _limitWords(String text, {int maxWords = 60}) {
    final words = text.trim().split(RegExp(r'\s+'));
    if (words.length <= maxWords) return text.trim();
    return words.take(maxWords).join(' ');
  }

  Future<void> _finalizeSpeechResult({bool forceStop = false}) async {
    if (_hasProcessedResult) return;

    _hasProcessedResult = true;
    _isStopping = true;

    if (forceStop) {
      await _speech.stop();
    }

    if (!mounted) return;

    final finalText = _spokenText.trim().isNotEmpty
        ? _spokenText.trim()
        : _liveSpokenText.trim();

    final cleanedText = _limitWords(
      _compareService.cleanRecognizedText(
        _preCleanRawSpeech(finalText),
      ),
    );

    if (cleanedText.isEmpty) {
      setState(() {
        _isListening = false;
        _isStopping = false;
        _spokenText = '';
        _result = null;
        _showSample = false;
        _hasProcessedResult = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            kIsWeb
                ? 'Không nhận được âm thanh. Hãy kiểm tra quyền mic của trình duyệt, nói rõ hơn và thử lại.'
                : 'Không nhận được giọng nói. Hãy thử nói rõ hơn và gần micro hơn.',
          ),
        ),
      );
      return;
    }

    final compareResult = _compareService.compare(
      recognizedText: cleanedText,
      expectedText: _item.sampleAnswer,
    );

    setState(() {
      _isListening = false;
      _isStopping = false;
      _spokenText = cleanedText;
      _liveSpokenText = cleanedText;
      _result = compareResult;
      _showSample = true;
    });
  }

  void _showTopicList() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => SpeakingTopicSheet(
        items: widget.items,
        currentIndex: _currentIndex,
        onSelectTopic: (index) {
          Navigator.pop(context);
          unawaited(_goToTopic(index));
        },
      ),
    );
  }

  Widget _buildTopHeader() {
    final progress = widget.items.isEmpty
        ? 0.0
        : (_currentIndex + 1) / widget.items.length;

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
                  'Bài ${_currentIndex + 1}/${widget.items.length}',
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
          ],
        ),
      ),
    );
  }

  Widget _buildPromptCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _item.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _item.prompt,
            style: const TextStyle(
              fontSize: 16,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMicCard() {
    final helperText = _isInitializingSpeech
        ? 'Đang khởi tạo microphone...'
        : _isListening
            ? 'Đang nghe... Hãy nói liền mạch và rõ ràng.'
            : kIsWeb
                ? 'Web cần được cấp quyền microphone. Hãy bấm bắt đầu nói rồi cho phép mic trên trình duyệt.'
                : 'Đáp án đang được ẩn. Hãy bấm bắt đầu nói trước.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Icon(
            _isListening ? Icons.mic : Icons.mic_none_rounded,
            size: 42,
            color: _isListening ? Colors.red : Colors.black87,
          ),
          const SizedBox(height: 12),
          Text(
            helperText,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
            ),
          ),
          if (_liveSpokenText.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Text(
                _liveSpokenText,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isInitializingSpeech
                  ? null
                  : (_isListening ? _stopListening : _startListening),
              icon: Icon(
                _isListening ? Icons.stop_circle_rounded : Icons.mic_rounded,
              ),
              label: Text(
                _isListening ? 'Dừng và chấm điểm' : 'Bắt đầu nói',
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          if (_result != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _retryCurrentTopic,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Nói lại bài này'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
          if (_lastError.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Mic log: $_lastError',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.redAccent,
              ),
            ),
          ],
          if (_availableLocales.isNotEmpty && !kIsWeb) ...[
            const SizedBox(height: 8),
            Text(
              'Locale đang dùng: ${_selectedLocaleId ?? "mặc định thiết bị"}',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSampleCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDDD6FE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Đáp án mẫu',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6D28D9),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _item.sampleAnswer,
            style: const TextStyle(
              fontSize: 15,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Speaking Practice'),
        actions: [
          IconButton(
            tooltip: 'Danh sách bài',
            onPressed: _showTopicList,
            icon: const Icon(Icons.grid_view_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPromptCard(),
                    const SizedBox(height: 16),
                    _buildMicCard(),
                    const SizedBox(height: 16),
                    if (_result != null) SpeakingResultCard(result: _result!),
                    if (_showSample) const SizedBox(height: 16),
                    if (_showSample) _buildSampleCard(),
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
                      child: const Text('Bài trước'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _currentIndex < widget.items.length - 1
                          ? _goToNext
                          : null,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Bài sau'),
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