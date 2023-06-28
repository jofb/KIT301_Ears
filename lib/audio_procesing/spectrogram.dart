import 'package:fftea/fftea.dart';
import 'package:ml_linalg/linalg.dart';
import 'package:scidart/numdart.dart';
import 'dart:typed_data';

const melBreakFreqHertz = 700.0;
const melHighFreq = 1127.0;

/// TODO voice activity deteciton and filtering on recorded audio

// TODO add fn description
int msFrames(int sampleRate, int ms) {
  return ((sampleRate.toDouble()) * 1e-3 * (ms.toDouble())).toInt();
}

// map hertz frequencies to mel scale
List<double> hertzToMel(List<double> frequencies) {
  return frequencies
      .map((frequency) =>
          melHighFreq * log(1.0 + (frequency / melBreakFreqHertz)))
      .toList();
}

// returns the cmvn (central mean variance normalization) of given matrix
Matrix cmvn(Matrix x) {
  Matrix y = x.mapColumns((col) => Vector.filled(col.length, col.mean()));
  return x - y;
}

// computes an in-place STFT of given real input
// note that this will mutate the given input
void stft(
    List<double> input, Function(Float64x2List) reportChunk, int frameLength,
    [int chunkStride = 0, int fftLength = 512, Float64List? win]) {
  final fft = FFT(fftLength);
  var chunk = Float64List(fftLength);

  if (chunkStride <= 0) chunkStride = fftLength;

  for (int i = 0;; i += chunkStride) {
    final i2 = i + frameLength;
    // create the contents of the chunk
    if (i2 > input.length) {
      int j = 0;
      final stop = input.length - i;
      for (; j < stop; ++j) {
        chunk[j] = input[i + j];
      }
      for (; j < frameLength; ++j) {
        chunk[j] = 0;
      }
    } else {
      for (int j = 0; j < frameLength; ++j) {
        chunk[j] = input[i + j];
      }
    }
    // apply our window on first frameLength elements instead of entire array
    if (win != null) {
      chunk.setRange(
          0, frameLength, win.applyWindowReal(chunk.sublist(0, frameLength)));
    }

    // create a new fft based on chunk and then return that
    Float64x2List newChunk = fft.realFft(chunk);
    reportChunk(newChunk);
    // termination point
    if (i2 >= input.length) {
      break;
    }
  }
}

// computes a mel weights matrix given params
// heavily adapted from Scipy Python package
Matrix computeMelWeightsMatrix(
    {int numMelBins = 20,
    numSpectrogramBins = 129,
    sampleRate = 8000,
    lowerEdgeHertz = 125.0,
    upperEdgeHertz = 3800.0}) {
  const int bandsToZero = 1;
  List<double> linearFrequencies = [];

  // nyquist frequency
  var nyquistHertz = sampleRate / 2.0;
  // get linear space up to nyquist freq
  linearFrequencies = linspace(0, nyquistHertz, num: numSpectrogramBins);
  // slice out number of bands that should be maintained
  linearFrequencies = linearFrequencies.sublist(bandsToZero);

  // convert to mel scale
  List<double> spectrogramBinMel = hertzToMel(linearFrequencies);
  List<double> melBandEdgesLinSpace = [];

  var lowerEdgeMel = hertzToMel([lowerEdgeHertz])[0];
  var upperEdgeMel = hertzToMel([upperEdgeHertz])[0];

  melBandEdgesLinSpace =
      linspace(lowerEdgeMel, upperEdgeMel, num: numMelBins + 2);

  // creating the triples

  List<double> lowerMel = [];
  List<double> centerMel = [];
  List<double> upperMel = [];

  for (int i = 1; i < (numMelBins + 1); i++) {
    // continue up to num_mel_bins - 2
    lowerMel.add(melBandEdgesLinSpace[i - 1]);
    // continue up to num_mel_bins - 1
    centerMel.add(melBandEdgesLinSpace[i]);
    // continue up to bandEdges.length
    upperMel.add(melBandEdgesLinSpace[i + 1]);
  }

  Vector lowerMelVector = Vector.fromList(lowerMel);
  Vector centerMelVector = Vector.fromList(centerMel);
  Vector upperMelVector = Vector.fromList(upperMel);

  /* Computing the upper and lower slopes */
  // lower slope vector
  Vector a = centerMelVector - lowerMelVector;
  // upper slope vector
  Vector b = upperMelVector - centerMelVector;

  List<Vector> upperSlopes = [];
  List<Vector> lowerSlopes = [];
  // compute the list of vectors for slopes
  for (int i = 0; i < spectrogramBinMel.length; i++) {
    // upper slopes
    upperSlopes.add(Vector.empty());
    upperSlopes[i] = (upperMelVector - spectrogramBinMel[i]) / b;

    // lower slopes
    Vector temp = Vector.filled(lowerMelVector.length, spectrogramBinMel[i]);
    lowerSlopes.add(Vector.empty());

    lowerSlopes[i] = (temp - lowerMelVector) / a;
  }

  // TODO refactor this to actually use a matrix rather than a list

  List<List<double>> melWeightsMatrix = [];

  for (int i = 0; i < lowerSlopes.length; i++) {
    melWeightsMatrix.add([]);
    for (int j = 0; j < lowerSlopes[0].length; j++) {
      var minVal = min(upperSlopes[i][j], lowerSlopes[i][j]);
      melWeightsMatrix[i].add(minVal > 0 ? minVal : 0);
    }
  }

  // add the zeroed out bands back as zeroes
  melWeightsMatrix.insert(0, List.filled(melWeightsMatrix[0].length, 0.0));

  return Matrix.fromList(melWeightsMatrix);
}

// creates and returns a log mel spectrogram given a real signal
Matrix melSpectrogram(List<double> signal) {
  // processing constants
  // TODO should these be params?
  const sampleRate = 16000;
  const frameLengthMS = 25;
  const frameStepMS = 10;
  const power = 2.0;
  const fmin = 0.0;
  const fmax = 8000.0;
  const fftLength = 512;

  var frameLength = msFrames(sampleRate, frameLengthMS);
  var frameStep = msFrames(sampleRate, frameStepMS);

  var spectrogram = <Float64List>[];

  // perform an in place stft
  stft(signal, (Float64x2List freq) {
    spectrogram.add(freq.discardConjugates().magnitudes());
  }, frameLength, frameStep, fftLength, Window.hanning(frameLength));

  // TODO refactor this to just use the matrix rather than list of lists
  // create the power spectrogram
  List<List<double>> powerSpectrogram = [];
  spectrogram.forEach((element) {
    powerSpectrogram
        .add(element.map((e) => pow(e.abs(), power).toDouble()).toList());
  });

  // matrix used for converting to mel scale
  Matrix melWeights = computeMelWeightsMatrix(
      numMelBins: 40,
      numSpectrogramBins: powerSpectrogram[0].length,
      sampleRate: sampleRate,
      lowerEdgeHertz: fmin,
      upperEdgeHertz: fmax);

  /* Linear to Mel Spectrogram using the weights matrix */
  var melSpectrogram = Matrix.fromList(powerSpectrogram) * melWeights;

  /* Mel to Log scale */

  var logMelSpectrogram =
      melSpectrogram.mapElements((element) => log(element + 1e-06));

  /* Apply the cmvn and return */
  return cmvn(logMelSpectrogram);
}
