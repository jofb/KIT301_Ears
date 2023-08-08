import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import 'category.dart';
import 'answers.dart';
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

  void playAudio(String langCode, String id, index) async {
    // stop current future if needed
    if (player.state == PlayerState.playing) await player.stop();
    setState(() {
      _selectedItemIndex = index;
    });
    // create the audio path and then check if it exists
    String path = "audio/$langCode/${langCode}_$id.mp3";
    print(path);

    if (await assetExists((path)) != null) {
      // play audio
      player.play(AssetSource(path));
    } else {
      // play default if null
      print("Playing default audio");
      player.play(AssetSource("audio/default_audio.mp3"));
    }
  }

  Future assetExists(String path) async {
    try {
      return await rootBundle.load("assets/$path");
    } catch (_) {
      return null;
    }
  }

  @override
  void initState() {
    player.onPlayerComplete.listen((e) {
      print('Audio player complete');
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
    return Consumer3<CategoriesModel, LanguageModel, AnswersModel>(
        builder: buildTab);
  }

  Widget buildTab(BuildContext context, CategoriesModel categoriesModel,
      LanguageModel language, AnswersModel answersModel, _) {
    if (categoriesModel.categories.isEmpty) {
      return Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }
    return Column(
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
                          answersModel.newHistory(language.toString());
                        },
                      );
                    },
                  );
                },
                child: Text('Current language: ${language.getText()}',
                    style: TextStyle(fontSize: 16)),
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
                child: Row(
                  children: [
                    Icon(
                      Icons.stop_circle_outlined,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const Text('Stop audio', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
          ],
        ),
        Expanded(
          flex: 1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 2),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      margin: EdgeInsets.zero,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          final isLastItem =
                              index == categoriesModel.categories.length - 1;
                          return Container(
                            margin: EdgeInsets.fromLTRB(
                                8, 8, 8, isLastItem ? 8 : 0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, width: 2),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: ListTile(
                              tileColor: Colors.grey[300],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              title: Text(
                                categoriesModel.categories[index].categoryName,
                                style: TextStyle(
                                    color: index == _selectedCategoryIndex
                                        ? Theme.of(context)
                                            .scaffoldBackgroundColor
                                        : Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20),
                              ),
                              selected: index == _selectedCategoryIndex,
                              selectedTileColor:
                                  Theme.of(context).colorScheme.error,
                              trailing: index == _selectedCategoryIndex
                                  ? Transform.scale(
                                      scale: 1.5,
                                      child: Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        color: Theme.of(context)
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
                          );
                        },
                        itemCount: categoriesModel.categories.length,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 4, 8, 8),
                  child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 2),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Card(
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
                            return Container(
                              margin: EdgeInsets.fromLTRB(
                                  8, 8, 8, isLastItem ? 8 : 0),
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.grey, width: 2),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: ListTile(
                                tileColor: Colors.grey[300],
                                title: Text(
                                  questions[index].short,
                                  style: TextStyle(
                                      color: index == _selectedItemIndex
                                          ? Theme.of(context)
                                              .scaffoldBackgroundColor
                                          : Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                                selected: index == _selectedItemIndex,
                                selectedTileColor:
                                    Theme.of(context).colorScheme.error,
                                trailing: index == _selectedItemIndex
                                    ? Transform.scale(
                                        scale: 1.5,
                                        child: Icon(
                                          Icons.volume_up_outlined,
                                          color: Theme.of(context)
                                              .scaffoldBackgroundColor,
                                        ),
                                      )
                                    : null,
                                onTap: () {
                                  // play audio
                                  playAudio(language.getCode(),
                                      question.audioId, index);
                                  // then create the follow up widget
                                  followUpWidget();
                                },
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
                                        onTap: () {
                                          // play audio
                                          playAudio(language.getCode(),
                                              question.audioId, index);
                                          // then create the follow up widget
                                          followUpWidget();
                                        },
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
                        style: TextStyle(fontSize: 18.0),
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
                        style: TextStyle(fontSize: 18.0),
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
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontSize: 18.0),
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
                          backgroundColor: Colors.green),
                      child: const Text(
                        'Confirm',
                        style: TextStyle(fontSize: 18.0),
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
