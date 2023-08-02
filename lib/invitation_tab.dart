import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:rive/rive.dart';

import 'audio_procesing/language.dart';
import 'audio_procesing/spectrogram.dart';
import 'audio_recorder.dart';

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
    return AudioRecorder(
      onFinished: () {
        print('I AM FINISHED RECORDING');

        if (kIsWeb) {
          language.setLanguage(2);
          return;
        }
        // run inference here
      },
    );
  }
}
