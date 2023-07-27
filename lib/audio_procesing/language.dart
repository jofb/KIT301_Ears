import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// Language model for screens to consume
class LanguageModel extends ChangeNotifier {
  // store the language mapper here too
  int langIndex = 0;
  List<Map<String, String>> labels = [];

  LanguageModel() {
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
    if (labels.isEmpty) return '';
    return labels[langIndex]['code']!;
  }

  String getText() {
    if (labels.isEmpty) return '';
    return labels[langIndex]['text']!;
  }

  List<String> getTextList() {
    return labels.map((e) => e['text']!).toList();
  }

  String indexToString(int index) {
    if (labels.isEmpty) return '';
    return "${labels[index]['text']!} (${labels[index]['code']!})";
  }

  void update() {
    notifyListeners();
  }
}

class LanguageDialog extends StatelessWidget {
  const LanguageDialog({super.key, required this.language});

  final LanguageModel language;

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          content: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Text(
                    'Change Language',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
                SingleChildScrollView(
                  child: Container(
                    constraints: BoxConstraints(maxHeight: 300),
                    child: Material(
                      // wrapping in container fixes issue with selected background going out of bounds
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: language.labels.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(language.indexToString(index)),
                            onTap: () {
                              language.setLanguage(index);
                              setState(() {});
                            },
                            selected: language.langIndex == index,
                            selectedTileColor: Theme.of(context).primaryColor,
                            selectedColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
