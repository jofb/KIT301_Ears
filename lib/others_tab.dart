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
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, //ttest
        children: <Widget>[
          Text("Others Page"),
          ElevatedButton(
            onPressed: () => {model.loadCollection()},
            child: Text("Update Question Files"),
          ),
          ElevatedButton(
            onPressed: () => {model.clearCollection()},
            child: Text("Clear Question Files"),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              answersModel.toString(),
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
                );
              },
              itemCount: answersModel.history.length,
            ),
          ),
        ],
      ),
    );
  }
}
