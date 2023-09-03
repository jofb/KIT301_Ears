import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:kit301_ears/colours.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'category.dart';
import 'answers.dart';
import 'log.dart';
import 'audio_procesing/language.dart';

class QuestionsTab extends StatefulWidget {
  const QuestionsTab({super.key});

  @override
  State<QuestionsTab> createState() => _QuestionsTabState();
}

class _QuestionsTabState extends State<QuestionsTab> {
  int _selectedCategoryIndex = 0;
  int _selectedItemIndex = -1;

  final player = AudioPlayer();
  void playAudio(String langCode, String id, int index) async {
    final appDir = await getApplicationDocumentsDirectory();
    // stop current future if needed
    if (player.state == PlayerState.playing) await player.stop();
    setState(() {
      _selectedItemIndex = index;
    });
    String path = "${appDir.path}/audio/$langCode/${langCode}_$id.mp3";
    // play audio
    player.play(UrlSource(path));
  }

  @override
  void initState() {
    player.onPlayerComplete.listen((e) {
      logger.d('Audio player complete');
      setState(() {
        _selectedItemIndex = -1;
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer4<CategoriesModel, LanguageModel, AnswersModel, ThemeModel>(
        builder: buildTab);
  }

  Widget buildTab(
      BuildContext context,
      CategoriesModel categoriesModel,
      LanguageModel language,
      AnswersModel answersModel,
      ThemeModel themeModel,
      _) {
    if (categoriesModel.categories.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'No Question & Statement files available',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          Text(
            'You may need to download them from the internet. (Go to Settings > \'Update Questions\')',
            style: TextStyle(fontSize: 20, color: Colors.grey[700]),
          )
        ],
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
                          child: ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) {
                                  return LanguageDialog(
                                    language: language,
                                    onFinished: () {
                                      answersModel
                                          .newHistory(language.toString());
                                    },
                                  );
                                },
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  themeModel.currentTheme.accentColor,
                            ),
                            child:
                                Text('Change language: ${language.getText()}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                    )),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
                          child: OutlinedButton(
                            onPressed: () {
                              player.stop();
                              setState(() {
                                _selectedItemIndex = -1;
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: themeModel.currentTheme.dividerColor,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.stop_circle_outlined,
                                  color: themeModel.currentTheme.cardColor,
                                ),
                                const Text('Stop audio',
                                    style: TextStyle(fontSize: 18)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: themeModel.currentTheme.dividerColor,
                                width: 2),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Card(
                            color:
                                themeModel.currentTheme.scaffoldBackgroundColor,
                            margin: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                final isLastItem = index ==
                                    categoriesModel.categories.length - 1;
                                return Container(
                                  margin: EdgeInsets.fromLTRB(
                                      8, 8, 8, isLastItem ? 8 : 0),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: themeModel
                                            .currentTheme.dividerColor,
                                        width: 2),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Material(
                                    elevation: index == _selectedCategoryIndex
                                        ? 5.0
                                        : 3.0,
                                    shadowColor:
                                        themeModel.currentTheme.primaryColor,
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: ListTile(
                                      tileColor:
                                          themeModel.currentTheme.accentColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      title: Text(
                                        categoriesModel
                                            .categories[index].categoryName,
                                        style: TextStyle(
                                            color:
                                                index == _selectedCategoryIndex
                                                    ? themeModel.currentTheme
                                                        .scaffoldBackgroundColor
                                                    : Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                      selected: index == _selectedCategoryIndex,
                                      selectedTileColor:
                                          themeModel.currentTheme.cardColor,
                                      trailing: index == _selectedCategoryIndex
                                          ? Transform.scale(
                                              scale: 1.5,
                                              child: Icon(
                                                Icons.arrow_forward_ios_rounded,
                                                color: themeModel.currentTheme
                                                    .scaffoldBackgroundColor,
                                              ),
                                            )
                                          : null,
                                      onTap: () {
                                        setState(() {
                                          _selectedCategoryIndex = index;
                                          _selectedItemIndex = -1;
                                        });
                                      },
                                    ),
                                  ),
                                );
                              },
                              itemCount: categoriesModel.categories.length,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                  child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: themeModel.currentTheme.dividerColor,
                            width: 2),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Card(
                        color: themeModel.currentTheme.scaffoldBackgroundColor,
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            // list of questions + current question
                            List<Question> questions = categoriesModel
                                .categories[_selectedCategoryIndex].questions;
                            final Question question = questions[index];

                            // checks whether tile should be disabled or selected for styling
                            bool tileDisabled =
                                !question.hasAudioAvailable(language.getCode());
                            bool tileSelected = _selectedItemIndex == index;

                            // used for styling
                            final isLastItem = index == questions.length - 1;
                            // should a special widget be used?
                            final type = question.type;
                            Function followUpWidget = () {};
                            switch (type) {
                              case 'yesno':
                                followUpWidget = () async {
                                  // get the answer from the dialog
                                  var response = await showDialog(
                                      barrierColor:
                                          Colors.black.withOpacity(0.75),
                                      context: context,
                                      builder: (BuildContext context) {
                                        return const YesNoDialog();
                                      });

                                  if (response != null) {
                                    // append to answers history
                                    answersModel.addAnswer(question, response);
                                  }
                                };
                                break;
                            }

                            IconData? trailingIcon;
                            if (tileDisabled) {
                              trailingIcon = Icons.volume_off_outlined;
                            } else if (tileSelected) {
                              trailingIcon = Icons.volume_up_outlined;
                            }

                            buttonTapFn() {
                              // play audio
                              playAudio(
                                  language.getCode(), question.audioId, index);
                              // then create the follow up widget
                              followUpWidget();
                            }

                            return Container(
                              margin: EdgeInsets.fromLTRB(
                                  8, 8, 8, isLastItem ? 8 : 0),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: themeModel.currentTheme.dividerColor,
                                    width: 2),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Material(
                                elevation: tileSelected ? 5.0 : 3.0,
                                shadowColor:
                                    themeModel.currentTheme.primaryColor,
                                borderRadius: BorderRadius.circular(10.0),
                                child: ListTile(
                                  enabled: question
                                      .hasAudioAvailable(language.getCode()),
                                  tileColor: tileDisabled
                                      ? Colors.grey[500]
                                      : themeModel.currentTheme.accentColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  title: Text(
                                    questions[index].short,
                                    style: TextStyle(
                                        color: tileSelected
                                            ? themeModel.currentTheme
                                                .scaffoldBackgroundColor
                                            : Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  selected: tileSelected,
                                  selectedTileColor:
                                      themeModel.currentTheme.cardColor,
                                  trailing: trailingIcon != null
                                      ? Transform.scale(
                                          scale: 1.5,
                                          child: Icon(
                                            trailingIcon,
                                            color: themeModel.currentTheme
                                                .scaffoldBackgroundColor,
                                          ),
                                        )
                                      : null,
                                  onTap: buttonTapFn,
                                  onLongPress: () {
                                    setState(() {
                                      _selectedItemIndex = index;
                                    });
                                    showDialog(
                                      context: context,
                                      barrierColor:
                                          Colors.black.withOpacity(0.75),
                                      builder: (BuildContext context) {
                                        return ConfirmationDialog(
                                          question: question,
                                          onTap: buttonTapFn,
                                          onPop: () {
                                            setState(() {
                                              _selectedItemIndex = -1;
                                            });
                                          },
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                          itemCount: categoriesModel
                              .categories[_selectedCategoryIndex]
                              .questions
                              .length,
                        ),
                      )),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Yes/No optional follow up dialog for questions
class YesNoDialog extends StatelessWidget {
  const YesNoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Container(
            width: MediaQuery.of(context).size.width *
                0.7, //Gets dimension of the screen * 70%
            height: MediaQuery.of(context).size.height *
                0.7, //Gets dimension of the screen * 70%
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 2),
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.fromLTRB(30.0, 50.0, 30.0, 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    children: <TextSpan>[
                      TextSpan(text: 'Select '),
                      TextSpan(
                        text: 'No',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                      TextSpan(text: ' or '),
                      TextSpan(
                        text: 'Yes',
                        style: TextStyle(color: Colors.green),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, 'No');
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 80.0,
                          horizontal: 100.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        backgroundColor: Colors.redAccent,
                      ),
                      child: const Text(
                        'No',
                        style: TextStyle(fontSize: 30.0),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, 'Yes');
                      },
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 80.0,
                            horizontal: 100.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          backgroundColor: Colors.green),
                      child: const Text(
                        'Yes',
                        style: TextStyle(fontSize: 30.0),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({
    super.key,
    required this.onPop,
    required this.question,
    required this.onTap,
  });

  final Question question;
  final Function onPop;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: WillPopScope(
        onWillPop: () async {
          onPop();
          return true;
        },
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Container(
            width: MediaQuery.of(context).size.width *
                0.7, //Gets dimension of the screen * 70%
            height: MediaQuery.of(context).size.height *
                0.7, //Gets dimension of the screen * 70%
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 2),
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.fromLTRB(30.0, 25.0, 30.0, 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  question.short,
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20.0),
                Text(
                  question.full,
                  style: const TextStyle(fontSize: 16.0),
                ),
                const SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        onPop();
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 50.0,
                          horizontal: 80.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        backgroundColor: Theme.of(context).errorColor,
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontSize: 24.0),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onTap();
                      },
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 50.0,
                            horizontal: 80.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          backgroundColor: Theme.of(context).indicatorColor),
                      child: const Text(
                        'Confirm',
                        style: TextStyle(fontSize: 24.0),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
