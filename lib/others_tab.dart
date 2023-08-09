import 'package:flutter/material.dart';
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
    return Consumer3<CategoriesModel, AnswersModel, ThemeModel>(builder: buildTab);
  }

  Widget buildTab(BuildContext context, CategoriesModel model, AnswersModel answersModel, ThemeModel themeModel, _) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ElevatedButton(
            onPressed: () {
              themeModel.toggleTheme();
              print(themeModel.currentTheme);
            },
            child: Text('Toggle Theme'),
          ),
          ElevatedButton(
            onPressed: () => model.loadCollection(),
            child: Text("Update Question Files"),
          ),
          ElevatedButton(
            onPressed: () => model.clearCollection(),
            child: Text("Clear Question Files"),
          ),
          ElevatedButton(
            onPressed: () => answersModel.clearHistory(),
            child: Text("Clear Answer History"),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              answersModel.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 25),
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
                    icon: Icon(
                      Icons.delete,
                      color: themeModel.currentTheme.errorColor
                    ),
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
          title: Text('Delete Answer'),
          content: Text('Are you sure you want to delete this answer?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                answersModel.removeAnswer(answer);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
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
