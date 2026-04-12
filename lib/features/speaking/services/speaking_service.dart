import 'dart:convert';
import 'package:flutter/services.dart';

import '../models/speaking_item.dart';

class SpeakingService {
  static const String assetPath =
      'assets/data//speaking/speaking_data.json';

  Future<List<SpeakingItem>> loadSpeakingItems() async {
    final jsonString = await rootBundle.loadString(assetPath);
    final List<dynamic> jsonData = json.decode(jsonString);

    return jsonData
        .map((item) => SpeakingItem.fromJson(item))
        .toList();
  }
}