import 'package:shared_preferences/shared_preferences.dart';

class SpeakingStorageService {
  static const String _currentIndexKey = 'speaking_current_index';

  Future<void> saveCurrentIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_currentIndexKey, index);
  }

  Future<int> getCurrentIndex() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_currentIndexKey) ?? 0;
  }

  Future<void> clearProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentIndexKey);
  }
}