import 'package:flutter/material.dart';
import 'package:kit301_ears/answers.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'audio_procesing/language.dart';
import 'audio_recorder.dart';

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

  @override
  Widget buildTab(BuildContext context, LanguageModel language,
      AnswersModel answersModel, _) {
    if (language.labels.isEmpty) {
      return Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }
    return AudioRecorder(
      onFinished: () {
        print('I AM FINISHED RECORDING');

        if (kIsWeb) {
          language.setLanguage(2);
          // return;
        }
        // once inference is run we can create a new answers history for the language ...
        // TODO
        answersModel.newHistory(language.toString());

        // run inference here
      },
    );
  }
}
