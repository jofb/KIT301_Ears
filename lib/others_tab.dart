import 'package:flutter/material.dart';
import 'package:kit301_ears/answers.dart';
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
    return Consumer2<CategoriesModel, AnswersModel>(builder: buildTab);
  }

  Widget buildTab(BuildContext context, CategoriesModel model,
      AnswersModel answersModel, _) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
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
                    icon: Icon(Icons.delete,
                        color: Theme.of(context).colorScheme.error),
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
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        );
      },
    );
  }
}
