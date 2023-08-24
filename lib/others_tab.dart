import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:kit301_ears/answers.dart';
import 'package:kit301_ears/colours.dart';
import 'package:provider/provider.dart';

import 'category.dart';

class OthersTab extends StatefulWidget {
  const OthersTab({super.key});

  @override
  State<OthersTab> createState() => _OthersTabState();
}

class _OthersTabState extends State<OthersTab> {
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
                    padding: EdgeInsets.all(4.0),
                    child: Row(
                      children: [
                        Text(
                          answersModel.toString(),
                          style: TextStyle(color: themeModel.currentTheme.primaryColor, fontSize: 30)
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(left: 20.0),
                            child: Divider(
                              color: themeModel.currentTheme.cardColor,
                              thickness: 3,
                            ),
                          )
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Text(
                      answersModel.toStringSimple(),
                      style: TextStyle(color: themeModel.currentTheme.primaryColor, fontSize: 20)
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
                    title: Text(history[index].question.full),
                    subtitle: Text(history[index].response),
                    trailing: IconButton(
                      icon: Icon(Icons.delete,
                          color: themeModel.currentTheme.errorColor),
                      onPressed: () {
                        _showDeleteConfirmation(
                            context, answersModel, history[index]);
                      },
                    ),
                  );
                },
                itemCount: answersModel.history.length,
                padding: EdgeInsets.only(bottom: 80)
              ),
            ),
          ],
        ),
        Positioned(
          bottom: 24.0,
          right: 24.0,
          child: _buildFab(context),
        )
      ],
    );
  }

  void _showDeleteConfirmation(
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

  Widget _buildFab(BuildContext context) {
    final icons = [ Icons.car_crash_rounded, Icons.share_rounded, Icons.delete_rounded ];
    final fabText = ['Select Casualty Position', 'Share Answer History', 'Clear Answer History'];
    return FabWithIcons(
      icons: icons,
      fabText: fabText,
    );
  }
}

class ShareButton extends StatelessWidget {
  final AnswersModel answersModel;

  const ShareButton({required this.answersModel});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        _shareHistory(context, answersModel);
      },
      child: Text('Share History'),
    );
  }

  void _shareHistory(BuildContext context, AnswersModel answersModel) {
    final StringBuffer buffer = StringBuffer();

    // Build the history list as a formatted string
    buffer.writeln('Answers History (${answersModel.language}) on ${answersModel.toStringSimple()}\n');
    for (var answer in answersModel.history) {
      buffer.writeln('${answer.question.full}\n${answer.response}\n');
    }

    // Share the formatted history via the share API
    Share.share(buffer.toString().trim(),);
  }
}

class FabWithIcons extends StatefulWidget {
  FabWithIcons({required this.icons, required this.fabText});
  final List<IconData> icons;
  final List<String> fabText;
  //ValueChanged<int> onIconTapped;
  @override
  State createState() => FabWithIconsState();
}

class FabWithIconsState extends State<FabWithIcons> with TickerProviderStateMixin {
  late AnimationController _controller;

  void _shareHistory(BuildContext context, AnswersModel answersModel) {
    final StringBuffer buffer = StringBuffer();

    // Build the history list as a formatted string
    buffer.writeln('Answers History (${answersModel.language}) on ${answersModel.toStringSimple()}\n');
    for (var answer in answersModel.history) {
      buffer.writeln('${answer.question.full}\n${answer.response}\n');
    }

    // Share the formatted history via the share API
    Share.share(buffer.toString().trim(),);
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
    return Consumer<AnswersModel>(builder: _buildThing);
  }

  Widget _buildThing(BuildContext context, AnswersModel answersModel, _) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: List.generate(widget.icons.length, (int index) {
        return _buildChild(index, answersModel);
      }).toList()..add(
        _buildFab(),
      ),
    );
  }

  Widget _buildChild(int index, AnswersModel answersModel) {
    Color backgroundColor = Theme.of(context).cardColor;
    Color foregroundColor = Theme.of(context).scaffoldBackgroundColor;
    return Container(
      height: 65.0,
      alignment: FractionalOffset.centerRight,
      child: ScaleTransition(
        scale: CurvedAnimation(
          parent: _controller,
          curve: Interval(
              0.0,
              1.0 - index / widget.icons.length / 2.0,
              curve: Curves.easeOut
          ),
        ),
        child: FloatingActionButton.extended(
          isExtended: true,
          onPressed: () async {
            if (widget.fabText[index] == 'Select Casualty Position') {
              //print("first");
              var response = await showDialog(
                barrierColor:
                    Colors.black.withOpacity(0.75),
                context: context,
                builder: (BuildContext context) {
                  return SeatPositionDialog();
                });

              if (response != null) {
                // append to answers history
                answersModel.addAnswer(Question('Answeree Seating Position', 'Answeree Seating Position', 'text', '999', '999'), response);
              }
            } else if (widget.fabText[index] == 'Share Answer History') {
              //ShareButton(answersModel: answersModel);
              _shareHistory(context, answersModel);
            } else if (widget.fabText[index] == 'Clear Answer History') {
              answersModel.clearHistory();
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
        )
      ),
    );
  }

  Widget _buildFab() {
    return FloatingActionButton(
      onPressed: () {
        if (_controller.isDismissed) {
          _controller.forward();
        } else {
          _controller.reverse();
        }
      },
      backgroundColor: Theme.of(context).cardColor,
      elevation: 2.0,
      child: Icon(
        Icons.arrow_upward_rounded,
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
    );
  }
}

class SeatPositionDialog extends StatefulWidget {
  @override
  _SeatPositionDialogState createState() => _SeatPositionDialogState();
}

class _SeatPositionDialogState extends State<SeatPositionDialog> {
  String? selectedSeat;
  
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
                _buildCarGraphic(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 60.0,
                          horizontal: 80.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        backgroundColor: Theme.of(context).errorColor,
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontSize: 30.0),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, selectedSeat);
                      },
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 60.0,
                            horizontal: 80.0,
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

  Widget _buildCarGraphic() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildSeatButton('Front Left'),
        _buildSeatButton('Front Right'),
        _buildSeatButton('Back Left'),
        _buildSeatButton('Back Middle'),
        _buildSeatButton('Back Right'),
      ],
    );
  }

  Widget _buildSeatButton(String seatName) {
    bool isSelected = selectedSeat == seatName;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedSeat = isSelected ? null : seatName;
        });
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: isSelected ? Theme.of(context).scaffoldBackgroundColor : Colors.black,
        backgroundColor: isSelected ? Theme.of(context).indicatorColor : Theme.of(context).accentColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding:
            const EdgeInsets.symmetric(vertical: 45.0, horizontal: 20.0),
      ),
      child: Text(seatName),
    );
  }
}