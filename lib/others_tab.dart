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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: () => answersModel.clearHistory(),
                child: const Text("Clear Answer History"),
                style: ElevatedButton.styleFrom(
                  primary: themeModel.currentTheme.primaryColor,
                ),
              ),
              SizedBox(width: 10),
              ShareButton(answersModel: answersModel), // Add the ShareButton here
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              answersModel.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 25),
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
            ),
          ),
        ],
      ),
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
