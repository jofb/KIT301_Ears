import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:permission_handler/permission_handler.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter_sound_platform_interface/flutter_sound_recorder_platform_interface.dart';

class AudioRecorder extends StatefulWidget {
  const AudioRecorder({super.key});

  @override
  State<AudioRecorder> createState() => _AudioRecorderState();
}

class _AudioRecorderState extends State<AudioRecorder> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _recorderIsInitialized = false;
  String _filePath = 'my_file';
  Codec _codec = Codec.aacADTS; // TODO look into alternative codecs

  @override
  void initState() {
    // open the recorder
    // TODO uncomment below to enable recorder
    // openRecorder().then((value) {
    //   setState(() {
    //     _recorderIsInitialized = true;
    //   });
    // });

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
  void startRecorder() {
    // needs a file path, a codec, and an audio source
    print('hello');
    _recorder
        .startRecorder(
            codec: _codec,
            toFile: _filePath,
            audioSource: AudioSource.microphone)
        .then((value) {
      setState(() {});
    });
  }

  // stops current recorder
  void stopRecorder() async {
    await _recorder.stopRecorder().then((value) {
      setState(() {});
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

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              final recordFn = getRecorderFunction();
              if (recordFn != null) recordFn();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  (_recorder.isRecording) ? Colors.red : Colors.green,
            ),
            child: Text(_recorder.isRecording ? 'Stop' : 'Record'),
          ),
        ],
      ),
    );
  }
}
