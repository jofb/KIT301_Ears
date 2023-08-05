import 'package:flutter/material.dart';
import 'category.dart';

// tracks answer history for questions that require responses
class AnswersModel extends ChangeNotifier {
  // use datetime as a unique identifier for answer histories
  late DateTime dateTime;

  String language = 'English (en)';
  List<Answer> history = [];

  AnswersModel() {
    dateTime = DateTime.now();
  }

  // reset list
  void newHistory(String language) {
    this.language = language;
    history = [];
    dateTime = DateTime.now();
  }

  // append to history
  void addAnswer(Question question, String response) {
    Answer answer = Answer(question.audioId, question, response);
    history.add(answer);
    update();
  }

  @override
  String toString() {
    return "(${dateTime.toString()}) | ${language} Answers History";
  }

  // TODO
  // share?
  // clear?
  // remove?
  // etc

  void update() {
    notifyListeners();
  }
}

// answer wrapper
class Answer {
  final String id;
  final Question question;
  final String response;

  Answer(this.id, this.question, this.response);

  @override
  String toString() {
    return "${question.full}\t'$response'";
  }
}
