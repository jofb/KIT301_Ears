import 'package:flutter/material.dart';
import 'package:kit301_ears/answers.dart';
import 'package:provider/provider.dart';

import 'log.dart';
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
        logger.i('Finished recording. Predicting language...');

        // get the lang index and then update the language provider
        int langIndex = await predictLanguage('my_file.wav');
        language.setLanguage(langIndex);

        // create new answer history for new language
        answersModel.newHistory(language.toString());
      },
    );
  }
}
