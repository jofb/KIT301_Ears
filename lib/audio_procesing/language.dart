import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// would like to hear thoughts on this
class LanguageModel extends ChangeNotifier {
  // store the language mapper here too
  late int langIndex;
  List<Map<String, String>> labels = [];

  LanguageModel() {
    langIndex = 0;
    initLabels();
  }

  void initLabels() async {
    // can load from assets here if needed
    final rawJson = await rootBundle.loadString('assets/ml/label_maps.json');
    final list = await jsonDecode(rawJson).toList();
    // goofy deserialization of json to list
    for (var lang in list) {
      labels.add(Map<String, String>.from(
          {"code": lang['code'], "text": lang['text']}));
    }

    update();
  }

  void setLanguage(int lang) {
    langIndex = lang;
    update();
  }

  String getCode() {
    return labels[langIndex]['code']!;
  }

  String getText() {
    return labels[langIndex]['text']!;
  }

  List<String> getTextList() {
    return labels.map((e) => e['text']!).toList();
  }

  void update() {
    notifyListeners();
  }
}
