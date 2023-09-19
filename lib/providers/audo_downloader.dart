import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class AudioDownloader extends ChangeNotifier {
  bool loading = false;

  AudioDownloader() {}

  Future<void> loadAudio(List<String> labels) async {
    loading = true;
    notifyListeners();

    final appDir = await getApplicationDocumentsDirectory();
    // ensure audio directory exists
    final audioDir = Directory("${appDir.path}/audio");

    if (!await Directory(audioDir.path).exists()) {
      await Directory(audioDir.path).create();
    }

    List<DownloadTask> downloads = [];

    // get the firebase instance
    var instance = FirebaseStorage.instance.ref();

    // now search the the instance for all our labels
    for (String label in labels) {
      // ensure labelled directory exists
      final labelDir = Directory("${audioDir.path}/$label");

      if (!await Directory(labelDir.path).exists()) {
        await Directory(labelDir.path).create();
      }

      ListResult list = await instance.child(label).list();

      // now for every item we download and place in folder
      for (Reference item in list.items) {
        String filePath = "${labelDir.path}/${item.name}";
        // finally download
        File file = File(filePath);
        final downloadTask = item.writeToFile(file);
        downloads.add(downloadTask);
      }
    }

    await Future.wait(downloads).then((value) {
      loading = false;
      notifyListeners();
    });
  }
}
