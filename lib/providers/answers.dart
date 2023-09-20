import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'category.dart';

// tracks answer history for questions that require responses
class AnswersModel extends ChangeNotifier {
  // use datetime as a unique identifier for answer histories
  late DateTime dateTime;
  String language = 'Greek (el)';
  List<Answer> history = [];

  static const List<String> carSeatStrings = [
    'Front Left',
    'Front Right',
    'Back Left',
    'Back Middle',
    'Back Right',
    'Far Back Left',
    'Far Back Middle',
    'Far Back Right',
  ];

  int? carSeatIndex;

  AnswersModel() {
    dateTime = DateTime.now();
  }

  // reset list
  void newHistory(String language) {
    this.language = language;
    history = [];
    dateTime = DateTime.now();
    carSeatIndex = null;
    update();
  }

  // append to history
  void addAnswer(Question question, String response) {
    Answer answer = Answer(question.audioId, question, response);
    history.add(answer);
    update();
  }

  List<String> getCarSeatStrings() {
    return carSeatStrings;
  }

  // set driver position
  void setCarSeat(int i) {
    carSeatIndex = i == -1 ? null : i;
    update();
  }

  String carSeatToString() {
    return carSeatStrings[carSeatIndex ?? 0];
  }

  @override
  String toString() {
    return "$language Answers History";
  }

  String toStringSimple() {
    final formattedDateStart = DateFormat('E d MMMM yyyy ').format(dateTime);
    const formattedDateMid = "at";
    final formattedDateEnd = DateFormat(' h:mm a').format(dateTime);
    return "$formattedDateStart$formattedDateMid$formattedDateEnd";
  }

  void clearHistory() {
    history.clear();
    carSeatIndex = null;
    update();
  }

  void removeAnswer(Answer answer) {
    history.remove(answer);
    update();
  }

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
