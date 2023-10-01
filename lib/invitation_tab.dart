import 'package:flutter/material.dart';
import 'package:kit301_ears/providers/answers.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'utils/log.dart';
import 'providers/language.dart';
import 'widgets/audio_recorder.dart';
import 'audio_processing/ml_inference.dart';

class InvitationTab extends StatefulWidget {
  const InvitationTab({super.key, required this.scaffoldMessengerKey});

  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  @override
  State<InvitationTab> createState() => _InvitationTabState();
}

class _InvitationTabState extends State<InvitationTab> {
  @override
  Widget build(BuildContext context) {
    return Consumer2<LanguageModel, AnswersModel>(builder: buildTab);
  }

  void navigateTab() {
    DefaultTabController.of(context).animateTo(1);
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
        await Future.delayed(const Duration(milliseconds: 400));

        // get the lang index and then update the language provider
        int langIndex = await predictLanguage('my_file.wav');
        language.setLanguage(langIndex);

        // create new answer history for new language
        answersModel.newHistory(language.toString());

        // notify using snackbar
        final snackBar = SnackBar(
          content: Text(
            'Language prediction complete. ${language.toString()}. A new answers history has been created',
            style: const TextStyle(
                fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          duration: const Duration(seconds: 5),
          backgroundColor: Colors.green,
          shape: const RoundedRectangleBorder(),
        );

        // show snackbar using scaffold messenger
        widget.scaffoldMessengerKey.currentState?.showSnackBar(snackBar);

        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final bool? questionsNav = prefs.getBool('questionsNav');

        if (questionsNav ?? false) {
          await Future.delayed(const Duration(milliseconds: 500));
          navigateTab();
        }
      },
    );
  }
}
