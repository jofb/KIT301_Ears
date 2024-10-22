import 'dart:math';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:kit301_ears/providers/answers.dart';
import 'package:kit301_ears/providers/themes.dart';
import 'package:provider/provider.dart';

import 'widgets/dialog.dart';
import 'providers/category.dart';
import 'utils/log.dart';

class AnswersTab extends StatefulWidget {
  const AnswersTab({super.key});

  @override
  State<AnswersTab> createState() => _AnswersTabState();
}

class _AnswersTabState extends State<AnswersTab> {
  @override
  Widget build(BuildContext context) {
    return Consumer3<CategoriesModel, AnswersModel, ThemeModel>(
        builder: buildTab);
  }

  Widget buildTab(BuildContext context, CategoriesModel model,
      AnswersModel answersModel, ThemeModel themeModel, _) {
    return Stack(
      alignment: AlignmentDirectional.bottomEnd,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Row(
                      children: [
                        Text(answersModel.toString(),
                            style: TextStyle(
                                color: themeModel.currentTheme.primaryColor,
                                fontSize: 30)),
                        const Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(left: 20.0),
                            child: Divider(
                              color: Colors.grey,
                              thickness: 1,
                            ),
                          ),
                        ),
                        if (answersModel.carSeatIndex != null)
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 8.0, right: 8.0),
                            child: Icon(Icons.drive_eta_rounded,
                                color: themeModel.currentTheme.primaryColor),
                          ),
                        if (answersModel.carSeatIndex != null)
                          Column(
                            children: [
                              Text(
                                'Casualty Position',
                                style: TextStyle(
                                  color: themeModel.currentTheme.primaryColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                answersModel.carSeatToString(),
                                style: TextStyle(
                                  color: themeModel.currentTheme.primaryColor,
                                  fontSize: 16,
                                ),
                              )
                            ],
                          )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      answersModel.toStringSimple(),
                      style: TextStyle(
                          color: themeModel.currentTheme.primaryColor,
                          fontSize: 20),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                  itemBuilder: (context, index) {
                    List<Answer> history = answersModel.history;
                    return ListTile(
                      title: Text(
                        history[index].question.full,
                        style: TextStyle(
                            color: themeModel.currentTheme.primaryColor),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 4, 8.0, 0),
                        child: Text(
                          history[index].response,
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                              color: themeModel.currentTheme.primaryColor),
                        ),
                      ),
                      trailing: Wrap(
                        spacing: 12,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.edit,
                                color: themeModel
                                    .currentTheme.colorScheme.primary),
                            onPressed: () async {
                              // get the question type and response for use in dialogs
                              final type = history[index].question.type;
                              final response = history[index].response;

                              // return an edit dialog based on type
                              final dialogResponse = await showDialog(
                                barrierColor: Colors.black.withOpacity(0.75),
                                context: context,
                                builder: (BuildContext context) {
                                  switch (type) {
                                    case 'yesno':
                                      return const YesNoDialog();
                                    case 'scalerating':
                                      return ScaleRatingDialog(
                                        initalValue: double.parse(response),
                                      );
                                    case 'multiplechoice':
                                    default:
                                      return const MultipleChoiceDialog();
                                  }
                                },
                              );
                              if (dialogResponse != null && context.mounted) {
                                // append to answers history
                                answersModel.editAnswer(
                                    history[index], dialogResponse);
                              }
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete,
                                color:
                                    themeModel.currentTheme.colorScheme.error),
                            onPressed: () {
                              showDeleteConfirmation(
                                  context, answersModel, history[index]);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                  itemCount: answersModel.history.length,
                  padding: const EdgeInsets.only(bottom: 80)),
            ),
          ],
        ),
        Positioned(
          bottom: 24.0,
          right: 24.0,
          child: buildFab(context),
        )
      ],
    );
  }

  void showDeleteConfirmation(
      BuildContext context, AnswersModel answersModel, Answer answer) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Answer'),
          content: const Text('Are you sure you want to delete this answer?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                answersModel.removeAnswer(answer);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text(
                'Confirm',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildFab(BuildContext context) {
    final icons = [
      Icons.car_crash_rounded,
      Icons.share_rounded,
      Icons.delete_rounded
    ];
    final fabText = [
      'Select Casualty Position',
      'Share Answer History',
      'Clear Answer History'
    ];
    return FabWithIcons(
      icons: icons,
      fabText: fabText,
    );
  }
}

class FabWithIcons extends StatefulWidget {
  const FabWithIcons({super.key, required this.icons, required this.fabText});

  final List<IconData> icons;
  final List<String> fabText;
  //ValueChanged<int> onIconTapped;
  @override
  State createState() => FabWithIconsState();
}

class FabWithIconsState extends State<FabWithIcons>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  void shareHistory(BuildContext context, AnswersModel answersModel) {
    final StringBuffer buffer = StringBuffer();

    // Build the history list as a formatted string
    buffer.writeln(
        'Answers History (${answersModel.language.split(' ')[0]}) on ${answersModel.toStringSimple()}\n');
    for (var answer in answersModel.history) {
      buffer.writeln(
          'Question: ${answer.question.full}\nResponse: ${answer.response}\n');
    }

    buffer.writeln(
        'Casualty Seating Position: ${answersModel.carSeatToString()}');

    // Share the formatted history via the share API
    Share.share(
      buffer.toString().trim(),
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AnswersModel>(builder: buildThing);
  }

  Widget buildThing(BuildContext context, AnswersModel answersModel, _) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: List.generate(widget.icons.length, (int index) {
        return buildChild(index, answersModel);
      }).toList()
        ..add(
          buildFab(),
        ),
    );
  }

  Widget buildChild(int index, AnswersModel answersModel) {
    Color backgroundColor = Theme.of(context).cardColor;
    Color foregroundColor = Theme.of(context).scaffoldBackgroundColor;
    return Container(
      height: 65.0,
      width: 220,
      alignment: FractionalOffset.centerRight,
      child: ScaleTransition(
          scale: CurvedAnimation(
            parent: _controller,
            curve: Interval(
              0.0,
              1.0 - index / widget.icons.length / 2.0,
              curve: Curves.easeOut,
            ),
          ),
          child: FittedBox(
            child: FloatingActionButton.extended(
              heroTag: null,
              elevation: 4.0,
              isExtended: true,
              onPressed: () async {
                if (widget.fabText[index] == 'Select Casualty Position') {
                  //print("first");
                  final response = await showDialog(
                    barrierColor: Colors.black.withOpacity(0.75),
                    context: context,
                    builder: (BuildContext context) {
                      // we have the answers model current position
                      // and we have the list
                      return SeatPositionDialog(
                          list: answersModel.getCarSeatStrings(),
                          initial: answersModel.carSeatIndex);
                    },
                  );

                  if (response != null) {
                    // set car seat from dialog response
                    answersModel.setCarSeat(response);
                    logger.d('Car seat: $response');
                  }
                } else if (widget.fabText[index] == 'Share Answer History') {
                  //ShareButton(answersModel: answersModel);
                  shareHistory(context, answersModel);
                } else if (widget.fabText[index] == 'Clear Answer History' && answersModel.history.isNotEmpty) {
                  await showDialog(
                      barrierColor: Colors.black.withOpacity(0.75),
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Clear Answer History'),
                          content: const Text('Are you sure you want to clear all answers from the history?'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Close the dialog
                              },
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                answersModel.clearHistory();
                                Navigator.of(context).pop(); // Close the dialog
                              },
                              child: const Text(
                                'Confirm',
                                style: TextStyle(color: Colors.redAccent),
                              ),
                            ),
                          ],
                        );
                      }
                  );
                }
              },
              label: Text(
                widget.fabText[index],
                style: TextStyle(
                  color: foregroundColor,
                ),
              ),
              icon: Icon(
                widget.icons[index],
                color: foregroundColor,
              ),
              backgroundColor: backgroundColor,
            ),
          )),
    );
  }

  Widget buildFab() {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: FloatingActionButton(
        heroTag: null,
        onPressed: () {
          if (_controller.isDismissed) {
            _controller.forward();
          } else {
            _controller.reverse();
          }
        },
        backgroundColor: Theme.of(context).cardColor,
        elevation: 4.0,
        child: Transform.rotate(
          angle: 90 * pi / 180,
          child: RotationTransition(
            turns: Tween(begin: 0.0, end: 0.5).animate(_controller),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
          ),
        ),
      ),
    );
  }
}

class SeatPositionDialog extends StatefulWidget {
  const SeatPositionDialog({super.key, required this.list, this.initial});
  final List<String> list;
  final int? initial;

  @override
  State<SeatPositionDialog> createState() => _SeatPositionDialogState();
}

class _SeatPositionDialogState extends State<SeatPositionDialog> {
  String? selectedSeat;
  int? selectedIndex;

  @override
  void initState() {
    // selectedSeat = widget.initalSeat;
    selectedIndex = widget.initial;
    super.initState();
  }

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
                0.8, //Gets dimension of the screen * 70%
            height: MediaQuery.of(context).size.height *
                0.8, //Gets dimension of the screen * 70%
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 2),
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.fromLTRB(30.0, 16.0, 30.0, 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildCarGraphic(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 40.0,
                          horizontal: 60.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontSize: 30.0),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, selectedIndex);
                      },
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 40.0,
                            horizontal: 60.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          backgroundColor: Theme.of(context).indicatorColor),
                      child: const Text(
                        'Confirm',
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

  Widget buildCarGraphic() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(128.0, 0, 0, 0),
                  child: buildSeatButton(0),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 128.0, 0),
                  child: buildSeatButton(1),
                ),
              ],
            ),
            const SizedBox(height: 20), // Adjust the height as needed
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 0, 0, 0),
                  child: buildSeatButton(2),
                ),
                buildSeatButton(3),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 16.0, 0),
                  child: buildSeatButton(4),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Divider(
                color: Colors.grey,
                thickness: 2,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 0, 0, 0),
                  child: buildSeatButton(5),
                ),
                buildSeatButton(6),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 16.0, 0),
                  child: buildSeatButton(7),
                ),
              ],
            )
          ],
        ),
      ],
    );
  }

  Widget buildSeatButton(int seatIndex) {
    String title = widget.list[seatIndex];
    bool isSelected = selectedIndex == seatIndex;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedIndex = isSelected ? -1 : seatIndex;
        });
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: isSelected
            ? Theme.of(context).scaffoldBackgroundColor
            : Colors.black,
        backgroundColor: isSelected
            ? Theme.of(context).indicatorColor
            : Theme.of(context).colorScheme.secondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.all(40.0),
      ),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20.0),
      ),
    );
  }
}
