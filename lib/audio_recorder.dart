import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter_sound_platform_interface/flutter_sound_recorder_platform_interface.dart';
import 'package:rive/rive.dart';

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
  bool _recorderIsInitialized = false;
  String _filePath = 'my_file.wav';
  Codec _codec = Codec.aacADTS; // TODO look into alternative codecs
  // animation state
  Artboard? _artboard;
  SMIInput<bool>? _trigger;

  @override
  void initState() {
    // open the audio recorder
    openRecorder().then((value) {
      setState(() {
        _recorderIsInitialized = true;
      });
    });

    // load the animation asset
    rootBundle.load('assets/animation/fin.riv').then((data) async {
      final file = RiveFile.import(data);

      final artboard = file.mainArtboard;
      var controller =
          StateMachineController.fromArtboard(artboard, 'State Machine 1');

      if (controller != null) {
        artboard.addController(controller);
        _trigger = controller.findInput('Press');
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
            // codec: _codec,
            toFile: '${tempDir.path}/$_filePath',
            audioSource: AudioSource.microphone)
        .then((value) {
      setState(() {});
    });
  }

  // stops current recorder
  void stopRecorder() async {
    await _recorder.stopRecorder().then((value) {
      setState(() {});
      widget.onFinished();
    });
  }

  // returns function to stop or start the recorder
  Function? getRecorderFunction() {
    if (!_recorderIsInitialized) return null;
    return _recorder.isStopped ? startRecorder : stopRecorder;
  }

  @override
  void dispose() {
    // close resources for audio recorder
    _recorder.closeRecorder();
    super.dispose();
  }

  void onPressedFn() async {
    final recordFn = getRecorderFunction();
    if (recordFn != null) {
      recordFn();
      // stop recording early everytime if needed
      Future.delayed(Duration(seconds: widget.recordingTime), () {
        if (_recorder.isRecording) stopRecorder();
      });
    }
  }

  void toggleAnimation() {
    setState(() {
      _trigger?.value = true; // trigger the state machine
    });
  }

  @override
  Widget build(BuildContext context) {
    // return widget.child();
    if (_artboard == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Stack(
      children: [
        Positioned.fill(
          bottom: 32,
          child: Center(
            child: ElevatedButton(
              onPressed: () {
                // start or stop audio recorder
                final recordFn = getRecorderFunction();
                if (recordFn != null) {
                  recordFn();
                  // then we can stop the recorder in 8s if needed
                  Future.delayed(Duration(seconds: widget.recordingTime), () {
                    if (_recorder.isRecording) {
                      // stop animation and recorder
                      stopRecorder();
                      toggleAnimation();
                    }
                  });
                }
                // set animation state
                toggleAnimation();
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
