import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'audio_procesing/language.dart';
import 'audio_procesing/spectrogram.dart';
import 'audio_recorder.dart';
import 'audio_procesing/ml_inference.dart';

class InvitationTab extends StatefulWidget {
  const InvitationTab({super.key});

  @override
  State<InvitationTab> createState() => _InvitationTabState();
}

class _InvitationTabState extends State<InvitationTab> {
  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageModel>(builder: buildTab);
  }

  @override
  Widget buildTab(BuildContext context, language, _) {
    if (language.labels.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.blueGrey,
        ),
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
            "Invitation to Speak Page - Current Language: ${language.getText()} (${language.getCode()})"),
        AudioRecorder(
          onFinished: () {
            print('I AM FINISHED RECORDING');

            if (kIsWeb) {
              language.setLanguage(2);
              return;
            }
            predictLanguage('my_file.wav');
            // TODO run inference and then update the language model
            // note that importing the ml stuff WILL break the web version of the app.
          },
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () {
              language.setLanguage(0);
            },
            child: Text('Estonian'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () {
              language.setLanguage(1);
            },
            child: Text('Mongolian'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () {
              language.setLanguage(2);
            },
            child: Text('Tamil'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () {
              language.setLanguage(3);
            },
            child: Text('Turkish'),
          ),
        )
      ],
    );
  }
}
