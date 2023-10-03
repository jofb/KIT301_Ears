import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:kit301_ears/providers/themes.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'providers/category.dart';
import 'providers/answers.dart';
import 'utils/log.dart';
import 'providers/language.dart';
import 'widgets/dialog.dart';

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
            'You may need to download them from the internet. (Go to Settings > \'Download Questions\')',
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
                          child: OutlinedButton(
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
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: themeModel.currentTheme.dividerColor,
                                width: 2,
                              ),
                            ),
                            child:
                                Text('Change language: ${language.getText()}',
                                    style: const TextStyle(
                                      fontSize: 18,
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
                                      tileColor: themeModel
                                          .currentTheme.colorScheme.secondary,
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
                            bool audioAvailable =
                                question.hasAudioAvailable(language.getCode());
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
                              case 'scalerating':
                                followUpWidget = () async {
                                  // get the answer from the dialog
                                  var response = await showDialog(
                                      barrierColor:
                                          Colors.black.withOpacity(0.75),
                                      context: context,
                                      builder: (BuildContext context) {
                                        return const ScaleRatingDialog();
                                      });

                                  if (response != null) {
                                    // append to answers history
                                    answersModel.addAnswer(question, response);
                                  }
                                };
                                break;
                              case 'multiplechoice':
                                followUpWidget = () async {
                                  // get the answer from the dialog
                                  final response = await showDialog(
                                      barrierColor:
                                          Colors.black.withOpacity(0.75),
                                      context: context,
                                      builder: (BuildContext context) {
                                        return const MultipleChoiceDialog();
                                      });

                                  if (response != null) {
                                    // append to answers history
                                    answersModel.addAnswer(question, response);
                                  }
                                };
                                break;
                            }

                            IconData? trailingIcon;
                            if (!audioAvailable) {
                              trailingIcon = Icons.volume_off_outlined;
                            } else if (tileSelected) {
                              trailingIcon = Icons.volume_up_outlined;
                            }

                            // plays audio and creates follow functionality when button is pressed
                            buttonTapFn() {
                              // play audio
                              playAudio(
                                  language.getCode(), question.audioId, index);
                              // then create the follow up widget
                              followUpWidget();
                            }

                            // returns a dialog confirming question text, used in long press
                            buttonConfirmFn() {
                              setState(() {
                                _selectedItemIndex = index;
                              });
                              showDialog(
                                context: context,
                                barrierColor: Colors.black.withOpacity(0.75),
                                builder: (BuildContext context) {
                                  return ConfirmationDialog(
                                    question: question,
                                    onTap: buttonTapFn,
                                    onPop: () {
                                      setState(() {
                                        _selectedItemIndex = -1;
                                      });
                                    },
                                    audioAvailable: audioAvailable,
                                  );
                                },
                              );
                            }

                            return Container(
                              margin: EdgeInsets.fromLTRB(
                                  8, 8, 8, isLastItem ? 8 : 0),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Theme.of(context).dividerColor,
                                    width: 2),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Material(
                                elevation: tileSelected ? 5.0 : 3.0,
                                shadowColor: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(10.0),
                                child: ListTile(
                                    tileColor: audioAvailable
                                        ? Theme.of(context)
                                            .colorScheme
                                            .secondary
                                        : Colors.grey[500],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    title: Text(
                                      questions[index].short,
                                      style: TextStyle(
                                          color: tileSelected
                                              ? Theme.of(context)
                                                  .scaffoldBackgroundColor
                                              : Colors.black,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    selected: tileSelected,
                                    selectedTileColor:
                                        Theme.of(context).cardColor,
                                    trailing: trailingIcon != null
                                        ? Transform.scale(
                                            scale: 1.5,
                                            child: Icon(
                                              trailingIcon,
                                              color: Theme.of(context)
                                                  .scaffoldBackgroundColor,
                                            ),
                                          )
                                        : null,
                                    onTap: audioAvailable
                                        ? buttonTapFn
                                        : buttonConfirmFn,
                                    onLongPress: buttonConfirmFn),
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

class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({
    super.key,
    required this.onPop,
    required this.question,
    required this.onTap,
    this.audioAvailable = true,
  });

  final Question question;
  final Function onPop;
  final Function onTap;
  final bool audioAvailable;

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
                0.8, //Gets dimension of the screen * 80%
            height: MediaQuery.of(context).size.height *
                0.8, //Gets dimension of the screen * 80%
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
                Flexible(
                  child: SingleChildScrollView(
                    child: Text(
                      question.full,
                      style: const TextStyle(fontSize: 20.0),
                    ),
                  ),
                ),
                if (!audioAvailable)
                  Text(
                    'There is currently no audio available for this question',
                    style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor),
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
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontSize: 24.0),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: audioAvailable
                          ? () {
                              Navigator.of(context).pop();
                              onTap();
                            }
                          : null,
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
