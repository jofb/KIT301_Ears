import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:ml_linalg/linalg.dart';
import 'package:scidart/numdart.dart';
import 'package:provider/provider.dart';

void predictLanguage(Matrix inputMatrix) async {
  // load the model from assets
  final Interpreter interpreter =
      await Interpreter.fromAsset('4lang_model.tflite');

  // resize the input tensor to match input
  interpreter.resizeInputTensor(0, [1, inputMatrix.rows.length, 40]);
  interpreter.allocateTensors();

  // get the input and output shapes
  final List<int> inputShape = interpreter.getInputTensor(0).shape;
  final List<int> outputShape = interpreter.getOutputTensor(0).shape;

  // input and output tensors
  // input needs to be converted to a List<List<>>
  final input = inputMatrix.toList().reshape(inputShape);
  final output = List.filled(4, 0).reshape(outputShape);

  // run the interpreter
  interpreter.run(input, output);

  // convert to double list for convenience
  final List<double> outputList = output[0] as List<double>;

  // final output int
  int langIndex = outputList.indexOf(outputList.reduce(max));
  // do we set this in a provider?

  interpreter.close();
}

// would like to hear thoughts on this
class Language extends ChangeNotifier {
  // store the language mapper here too
  late int langIndex;
  late List<Map<String, String>> labels;

  Language() {
    langIndex = 0;
    // this is temp
    labels = [
      {"code": "et", "text": "Estonian"},
      {"code": "mn", "text": "Mongolian"},
      {"code": "tm", "text": "Tamil"},
      {"code": "tr", "text": "Turkish"},
    ];
  }

  void initLabels() async {
    // can load from assets here if needed
  }

  void setLanguage(int lang) {
    langIndex = lang;
    update();
  }

  String getCode() {
    return labels[langIndex]['code']!;
  }

  String getText() {
    return labels[langIndex]['text']!;
  }

  List<String> getTextList() {
    return labels.map((e) => e['text']!).toList();
  }

  void update() {
    notifyListeners();
  }
}
