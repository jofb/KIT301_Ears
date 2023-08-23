import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:provider/provider.dart';

import 'audio_procesing/language.dart';
import 'category.dart';
import 'colours.dart';

class SettingsWidget extends StatefulWidget {
  const SettingsWidget({super.key});

  @override
  State<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget>
    with TickerProviderStateMixin {
  late AnimationController audioProgressController;

  @override
  void initState() {
    audioProgressController = AnimationController(vsync: this)
      ..addListener(() {
        if (mounted) setState(() {});
      });
    super.initState();
  }

  @override
  Widget build(BuildContext build) {
    return Consumer3<CategoriesModel, ThemeModel, LanguageModel>(
      builder: buildScaffold,
    );
  }

  Widget buildScaffold(BuildContext context, CategoriesModel categoriesModel,
      ThemeModel themeModel, LanguageModel languageModel, _) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SettingsList(
        sections: [
          Section(
            title: 'General',
            tiles: [
              CustomSettingsTile(
                child: Row(
                  children: [
                    SizedBox(
                      width: 200,
                      child: DropdownButton(
                        value: themeModel.getThemeIndex(),
                        hint: const Text('Change colour theme'),
                        icon: const Icon(Icons.color_lens),
                        iconEnabledColor: themeModel.currentTheme.cardColor,
                        // map the colours list to the dropdown items
                        items: themeModel.themeList.map((value) {
                          int index = themeModel.themeList.indexOf(value);
                          return DropdownMenuItem(
                              value: index, child: Text(value.name));
                        }).toList(),
                        onChanged: (value) {
                          themeModel.setTheme(value);
                        },
                      ),
                    ),
                  ],
                ),
              )
            ],
            theme: themeModel.currentTheme,
          ),
          Section(
            title: 'Questions & Statements',
            tiles: [
              CustomSettingsTile(
                child: Row(
                  children: [
                    SettingsButton(
                      text: 'Update questions',
                      onPressed: () {
                        categoriesModel.loadCollection();
                      },
                      theme: themeModel.currentTheme,
                    ),
                    if (categoriesModel.loading)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Transform.scale(
                            scale: 0.8, child: CircularProgressIndicator()),
                      ),
                  ],
                ),
              ),
              CustomSettingsTile(
                child: Row(
                  children: [
                    SettingsButton(
                      text: 'Clear questions',
                      onPressed: () => categoriesModel.clearCollection(),
                      theme: themeModel.currentTheme,
                    ),
                  ],
                ),
              ),
            ],
            theme: themeModel.currentTheme,
          ),
          Section(
            title: 'Audio',
            tiles: [
              CustomSettingsTile(
                child: Row(
                  children: [
                    Column(
                      children: [
                        SettingsButton(
                          text: 'Download audio',
                          onPressed: () async {
                            // get language labels
                            List<String> labels = languageModel.labels
                                .map((l) => l['code']!)
                                .toList();

                            final appDir =
                                await getApplicationDocumentsDirectory();
                            // ensure audio directory exists
                            final audioDir = Directory("${appDir.path}/audio");

                            if (!await Directory(audioDir.path).exists()) {
                              await Directory(audioDir.path).create();
                            }

                            // get the firebase instance
                            var instance =
                                await FirebaseStorage.instance.ref("/");

                            // used for progress indicator
                            int total = 0;
                            int progress = 0;

                            // now search the the instance for all our labels
                            for (String label in labels) {
                              // ensure labelled directory exists
                              final labelDir =
                                  Directory("${audioDir.path}/$label");

                              if (!await Directory(labelDir.path).exists()) {
                                await Directory(labelDir.path).create();
                              }

                              ListResult list =
                                  await instance.child(label).list();

                              total += list.items.length;
                              // now for every item we download and place in folder
                              for (Reference item in list.items) {
                                String filePath =
                                    "${labelDir.path}/${item.name}";
                                // finally download
                                File file = File(filePath);
                                final downloadTask = item.writeToFile(file);
                                downloadTask.snapshotEvents.listen((event) {
                                  if (event.state == TaskState.success) {
                                    progress += 1;
                                    audioProgressController.value =
                                        progress / total;
                                  }
                                });
                              }
                            }
                          },
                          theme: themeModel.currentTheme,
                        ),
                        if (audioProgressController.status ==
                            AnimationStatus.forward)
                          SizedBox(
                            width: 200,
                            child: LinearProgressIndicator(
                                value: audioProgressController.value),
                          )
                      ],
                    ),
                  ],
                ),
              ),
            ],
            theme: themeModel.currentTheme,
          ),
          Section(
            title: 'Language Model',
            tiles: [
              CustomSettingsTile(
                child: Row(
                  children: [
                    SettingsButton(
                      text: 'Change model',
                      onPressed: () => print('not yet implemented!'),
                      theme: themeModel.currentTheme,
                    ),
                  ],
                ),
              ),
            ],
            theme: themeModel.currentTheme,
          ),
        ],
      ),
    );
  }
}

class SettingsButton extends StatelessWidget {
  const SettingsButton(
      {super.key,
      required this.onPressed,
      required this.text,
      required this.theme});

  final Function() onPressed;
  final String text;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(backgroundColor: theme.cardColor),
        child: Text(text, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}

class Section extends AbstractSettingsSection {
  const Section(
      {required this.title,
      required this.tiles,
      required this.theme,
      super.key});

  final String title;
  final List<AbstractSettingsTile> tiles;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
        title: Row(
          children: [
            Text(title,
                style: TextStyle(color: theme.primaryColor, fontSize: 30)),
            const Expanded(
                child: Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Divider(),
            )),
          ],
        ),
        tiles: tiles);
  }
}
