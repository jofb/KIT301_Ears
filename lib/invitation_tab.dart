import 'package:flutter/material.dart';
import 'package:kit301_ears/answers.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'audio_procesing/language.dart';
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
    return Consumer2<LanguageModel, AnswersModel>(builder: buildTab);
  }

  Widget buildTab(BuildContext context, LanguageModel language,
      AnswersModel answersModel, _) {
    if (language.labels.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.blueGrey,
        ),
      );
    }

    return AudioRecorder(
      onFinished: () async {
        print('Finished recording. Predicting language...');

        // get the lang index and then update the language provider
        int langIndex = await predictLanguage('my_file.wav');
        language.setLanguage(langIndex);
        // note that importing the ml stuff WILL break the web version of the app.
        answersModel.newHistory(language.toString());
      },
    );
  }
}
