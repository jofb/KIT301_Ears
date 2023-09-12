import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:async/async.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter_sound_platform_interface/flutter_sound_recorder_platform_interface.dart';
import 'package:rive/rive.dart';

import 'log.dart';

class AudioRecorder extends StatefulWidget {
  const AudioRecorder({super.key, required this.onFinished});

  final int recordingTime = 8;
  final Function onFinished;

  @override
  State<AudioRecorder> createState() => _AudioRecorderState();
}

class _AudioRecorderState extends State<AudioRecorder> {
  final FlutterSoundRecorder _recorder =
      FlutterSoundRecorder(logLevel: Level.error);

  CancelableOperation<void>? _recordingOperation;
  bool _recorderIsInitialized = false;
  String _filePath = 'my_file.wav';
  Codec _codec = Codec.aacADTS;
  // animation state
  Artboard? _artboard;
  SMIInput<bool>? _trigger;
  SMIInput<bool>? _complete; //A trigger for the boolean

  @override
  void initState() {
    // open the audio recorder
    openRecorder().then((value) {
      setState(() {
        _recorderIsInitialized = true;
      });
    });

    // load the animation asset
    rootBundle.load('assets/animation/letters.riv').then((data) async { /** Switch between the animations on this line */
      final file = RiveFile.import(data);

      final artboard = file.mainArtboard;
      var controller =
          StateMachineController.fromArtboard(artboard, 'State Machine 1');

      // rip out the mic recording animation and update the speed multiplier
      LinearAnimation micRecordingAnimation = artboard.animations
          .firstWhere((element) => element.name == 'MicRec') as LinearAnimation;
      artboard.internalRemoveAnimation(micRecordingAnimation);

      // speed multiplier is (original_duration) / (new_duration - fudging_number)
      // mic recording animation duration is (new_duration - fudging_number)
      micRecordingAnimation.speed = (15) / (widget.recordingTime - 0.2);

      // add the animation back
      artboard.internalAddAnimation(micRecordingAnimation);

      if (controller != null) {
        artboard.addController(controller);
        _trigger = controller.findInput('Press');
        _complete = controller.findInput('Complete');
      }

      setState(() {
        _artboard = artboard;
      });
    });
    setState(() {});
    super.initState();
  }

  // opens recorder resources
  Future openRecorder() async {
    // get microphone permissions
    // TODO this should trigger at start of application
    if (!kIsWeb) {
      var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        throw RecordingPermissionException('Microphone Permission not granted');
      }
    }

    // open the recorder
    await _recorder.openRecorder();
    // initialize web codec correctly
    if (!await _recorder.isEncoderSupported(_codec) && kIsWeb) {
      _codec = Codec.opusWebM;
      _filePath = 'tau_file.webm';
      if (!await _recorder.isEncoderSupported(_codec) && kIsWeb) {
        _recorderIsInitialized = true;
        return;
      }
    }
    // initializes the audio session (only needed on mobile)
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.record,
      avAudioSessionCategoryOptions:
          AVAudioSessionCategoryOptions.allowBluetooth |
              AVAudioSessionCategoryOptions.defaultToSpeaker,
      avAudioSessionMode: AVAudioSessionMode.spokenAudio,
      avAudioSessionRouteSharingPolicy:
          AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: const AndroidAudioAttributes(
        contentType: AndroidAudioContentType.speech,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.voiceCommunication,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));

    _recorderIsInitialized = true;
  }

  // record audio to file
  void startRecorder() async {
    final tempDir = await getTemporaryDirectory();
    // needs a file path, a codec, and an audio source
    _recorder
        .startRecorder(
          // codec: Codec.pcm16,
          toFile: '${tempDir.path}/$_filePath',
          audioSource: AudioSource.microphone,
          // toStream: sink,
        )
        .then((_) => setState(() {}));
  }

  // stops current recorder
  void stopRecorder({bool cancelled = false}) async {
    await _recorder.stopRecorder().then((value) {
      setState(() {});
      if (!cancelled) widget.onFinished();
    });
  }

  @override
  void dispose() {
    // close resources for audio recorder
    _recorder.closeRecorder();
    _recordingOperation?.cancel();
    super.dispose();
  }

  void toggleAnimation() {
    setState(() {
      _trigger?.value = true; // trigger the state machine
    });
  }

  void toggleCompleteAnimation() {
    setState(() {
      _complete?.value = true; //trigger the red end flash of the animation
    });
  }

  Future<void> delayedStopRecording() async {//TODO: trigger the red flash stop animation when (recordingTime - 0.5) is reached
    _recordingOperation = CancelableOperation.fromFuture(
      Future.delayed(
        Duration(seconds: widget.recordingTime),
      ),
    );

    try {
      await _recordingOperation?.value;

      toggleCompleteAnimation();
      stopRecorder();
    } catch (e) {
      logger.e(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_artboard == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Stack(
      children: [
        Positioned.fill(
          child: Center(
            child: ElevatedButton(
              onPressed: () {
                if (!_recorderIsInitialized) return;

                // either start recording or cancel it
                if (_recorder.isRecording) {
                  // stopping early > are you sure you want to cancel this?
                  // show dialog > if true then
                  bool stop = true;
                  if (stop) {
                    _recordingOperation?.cancel();
                    stopRecorder(cancelled: true);

                    // set animation state
                    toggleAnimation();
                  }
                } else {
                  // start recording and create operation for delayed stop
                  startRecorder();
                  delayedStopRecording();
                  // set animation state
                  toggleAnimation(); //I don't get it, why does the animation needs to be double clicked to transition without this?
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                side: BorderSide.none,
                shadowColor: Colors.transparent,
              ),
              child: Rive(artboard: _artboard!, fit: BoxFit.cover),
            ),
          ),
        )
      ],
    );
  }
}
