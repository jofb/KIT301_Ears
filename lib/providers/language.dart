import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  @override
  String toString() {
    return "${labels[langIndex]['text']!} (${labels[langIndex]['code']})";
  }

  List<String> getTextList() {
    return labels.map((e) => "${e['text']!} (${e['code']!})").toList();
  }

  String indexToString(int index) {
    if (labels.isEmpty) return '';
    return "${labels[index]['text']!} (${labels[index]['code']!})";
  }

  void update() {
    notifyListeners();
  }
}

class LanguageDialog extends StatefulWidget {
  const LanguageDialog(
      {super.key, required this.language, required this.onFinished});

  final LanguageModel language;
  final Function onFinished;

  @override
  State<LanguageDialog> createState() => _LanguageDialogState();
}

class _LanguageDialogState extends State<LanguageDialog> {
  List<int> _searchIndexes = [];
  List<String> _languageList = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    _languageList = widget.language.getTextList();
    _searchIndexes = search('');
    super.initState();
  }

  List<int> search(String searchCondition) {
    // early return when not searching just returns the full list
    if (searchCondition.isEmpty) return _languageList.asMap().keys.toList();

    List<int> search = [];
    for (int i = 0; i < _languageList.length; i++) {
      // check search condition against language list
      if (_languageList[i]
          .toLowerCase()
          .contains(searchCondition.toLowerCase())) {
        search.add(i);
      }
    }
    return search;
  }

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
                  padding: EdgeInsets.only(bottom: 3.0),
                  child: Text(
                    'Change Language',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: Icon(Icons.search),
                      ),
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller: _controller,
                          enableSuggestions: false,
                          autocorrect: false,
                          enableIMEPersonalizedLearning: false,
                          keyboardType: TextInputType.text,
                          onChanged: (value) {
                            setState(() {
                              _searchIndexes = search(value);
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Search Languages',
                            suffixIcon: _controller.text != ''
                                ? IconButton(
                                    onPressed: () {
                                      _controller.clear();
                                      setState(() {
                                        _searchIndexes = search('');
                                      });
                                    },
                                    icon: const Icon(Icons.clear, size: 18),
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: Container(
                    constraints:
                        const BoxConstraints(minHeight: 300, maxHeight: 300),
                    // wrapping in material fixes issue with selected background going out of bounds
                    child: Material(
                      child: ListView.builder(
                        itemCount: _searchIndexes.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(_languageList[_searchIndexes[index]]),
                            onTap: () {
                              // set the language then pop the dialog
                              widget.language
                                  .setLanguage(_searchIndexes[index]);
                              setState(() {});
                              widget.onFinished();
                              Navigator.pop(context);
                            },
                            selected: widget.language.langIndex ==
                                _searchIndexes[index],
                            selectedTileColor: Theme.of(context).primaryColor,
                            selectedColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
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
