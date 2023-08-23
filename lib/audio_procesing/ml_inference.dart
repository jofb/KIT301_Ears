import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:ml_linalg/linalg.dart';
import 'package:scidart/numdart.dart';
import 'package:wav/wav.dart';

import 'spectrogram.dart';

Future<int> predictLanguage(String audioPath) async {
  final signal = await loadAudio(audioPath);
  // TODO add the VAD filtering here
  // ...
  // create the spectrogram
  final spectrogram = melSpectrogram(signal);
  // run inference and return the index
  int langIndex = await inference(spectrogram);
  return Future<int>.value(langIndex);
}

// load the audio file
Future<List<double>> loadAudio(String path) async {
  // first load the audio
  final tempDir = await getTemporaryDirectory();
  final wavFile = await Wav.readFile("${tempDir.path}/$path");
  final List<double> signal = wavFile.toMono();
  // delete the file
  File("${tempDir.path}/$path").delete();

  return signal;
}

// runs inference on given signal input
Future<int> inference(Matrix inputMatrix) async {
  // load the model from assets
  final Interpreter interpreter =
      await Interpreter.fromAsset('assets/ml/6lang_model_v2.tflite');

  // resize the input tensor to match input
  interpreter.resizeInputTensor(0, [1, inputMatrix.rows.length, 40]);
  interpreter.allocateTensors();

  // get the input and output shapes
  final List<int> inputShape = interpreter.getInputTensor(0).shape;
  final List<int> outputShape = interpreter.getOutputTensor(0).shape;

  // input and output tensors
  // input needs to be converted to a List<List<>>
  final input = inputMatrix.toList().reshape(inputShape);
  final output = List.filled(outputShape[1], 0).reshape(outputShape);

  // run the interpreter
  interpreter.run(input, output);

  // convert to double list for convenience
  final List<double> outputList = output[0] as List<double>;

  // final output int
  int langIndex = outputList.indexOf(outputList.reduce(max));

  interpreter.close();

  return Future<int>.value(langIndex);
}
