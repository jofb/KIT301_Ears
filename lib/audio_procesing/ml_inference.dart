import 'dart:typed_data';

import 'package:fftea/fftea.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:ml_linalg/linalg.dart';
import 'package:scidart/numdart.dart';
import 'package:provider/provider.dart';
import 'package:wav/wav.dart';
import 'dart:io';

import 'spectrogram.dart';

void predictLanguage(audioPath) async {
  final signal = await loadAudio(audioPath);
  print(signal);
  // final spectrogram = melSpectrogram(signal);
  // final spectrogram = await processAudio(signal);
  // inference(spectrogram);
}

Future<Matrix> processAudio(List<double> signal) {
  // constants
  const sampleRate = 16000;
  const frameLengthMS = 25;
  const frameStepMS = 10;
  const power = 2.0;
  const fmin = 0.0;
  const fmax = 8000.0;
  const fftLength = 512;

  var frameLength = msFrames(sampleRate, frameLengthMS);
  var frameStep = msFrames(sampleRate, frameStepMS);

  // first remove the silence (skipped for now while testing)
  // ...

  // next clamp the audio to fit for the stft
  final int signalLength = signal.length;
  final clampedSignal = signal.sublist(
      0, signalLength - ((signalLength - frameLength) % frameStep));

  var spectrogram = <Float64List>[];

  // perform the stft on the signal to create a spectrogram
  stft(clampedSignal, (Float64x2List freq) {
    spectrogram.add(freq.discardConjugates().magnitudes());
  }, frameLength, frameStep, fftLength, Window.hanning(frameLength));

  // convert to the power spectrogram
  // TODO ideally the powerspectrogram is a matrix instead of a List<List<double>>, it currently works it's just a bit inconsistent
  List<List<double>> powerSpectrogram = [];
  spectrogram.forEach((element) => {
        powerSpectrogram
            .add(element.map((e) => pow(e.abs(), power).toDouble()).toList())
      });

  // compute the mel weights for the mel spectrogram
  Matrix melWeights = computeMelWeightsMatrix(
      numMelBins: 40,
      numSpectrogramBins: powerSpectrogram[0].length,
      sampleRate: sampleRate,
      lowerEdgeHertz: fmin,
      upperEdgeHertz: fmax);

  // perform dot product to produce the mel spectrogram
  final melSpectrogram = (Matrix.fromList(powerSpectrogram)) * melWeights;

  // finally convert to a log mel spectrogram
  var logMelSpectrogram =
      melSpectrogram.mapElements((element) => log(element + 1e-06));

  // some normalization
  logMelSpectrogram = cmvn(logMelSpectrogram);

  // and return the full sepctrogram
  return Future<Matrix>.value(logMelSpectrogram);
}

// load the audio here
Future<List<double>> loadAudio(String path) async {
  // first load the audio
  final tempDir = await getTemporaryDirectory();
  final wavFile = await Wav.readFile("${tempDir.path}/$path");
  final List<double> signal = wavFile.toMono();

  return signal;
}

// runs inference on given signal input
void inference(Matrix inputMatrix) async {
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
  // TODO do we set this in a provider?

  interpreter.close();
}
