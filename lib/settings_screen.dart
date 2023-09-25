import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/audo_downloader.dart';
import 'providers/language.dart';
import 'providers/category.dart';
import 'providers/themes.dart';

class SettingsWidget extends StatefulWidget {
  const SettingsWidget({super.key, required this.scaffoldMessengerKey});

  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  @override
  State<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  bool downloadingAudio = false;

  SharedPreferences? userPrefs;

  void initPreferences() async {
    userPrefs = await SharedPreferences.getInstance();
    setState(() {});
  }

  @override
  void initState() {
    initPreferences();
    super.initState();
  }

  @override
  Widget build(BuildContext build) {
    return Consumer4<CategoriesModel, ThemeModel, LanguageModel,
        AudioDownloader>(
      builder: buildScaffold,
    );
  }

  Widget buildScaffold(
      BuildContext context,
      CategoriesModel categoriesModel,
      ThemeModel themeModel,
      LanguageModel languageModel,
      AudioDownloader audioDownloader,
      _) {
    if (userPrefs == null) {
      return const Center(child: CircularProgressIndicator());
    }
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
                child: ListTile(
                  title: const Text('Colour Theme'),
                  subtitle: const Text('Change the colour theme of the app.'),
                  trailing: SizedBox(
                    width: 200,
                    child: DropdownButton(
                      value: themeModel.themeIndex,
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
                  // leading: SizedBox(
                  //   width: 24,
                  // ),
                ),
              ),
              CustomSettingsTile(
                child: ListTile(
                  title: const Text('Questions Auto Navigation'),
                  subtitle: const Text(
                      'Should the app navigate to the questions screen automatically after completing a language prediction?'),
                  trailing: Switch(
                    value: userPrefs?.getBool('questionsNav') ?? true,
                    onChanged: (value) {
                      setState(() {
                        userPrefs?.setBool('questionsNav', value);
                      });
                    },
                    activeColor: Theme.of(context).indicatorColor,
                  ),
                  // leading: SizedBox(width: 24),
                ),
              )
            ],
            theme: themeModel.currentTheme,
          ),
          Section(
            title: 'Questions & Statements',
            tiles: [
              CustomSettingsTile(
                child: ListTile(
                  title: const Text('Download Question files'),
                  subtitle: const Text(
                      'Updates and downloads question files from the database. Requires an internet connection'),
                  trailing: DownloadButton(
                    enabled: !categoriesModel.loading,
                    onPressed: () {
                      Color colour = Theme.of(context).indicatorColor;
                      categoriesModel.clearCollection();
                      // remove this
                      categoriesModel.loading = true;
                      categoriesModel.update();
                      categoriesModel.loadCollection().then(
                            (_) => showSnackbar(
                                'Questions & Statements Updated', colour),
                          );
                    },
                  ),
                  // leading: showLoadingIndicator(categoriesModel.loading),
                ),
              ),
            ],
            theme: themeModel.currentTheme,
          ),
          Section(
            title: 'Audio',
            tiles: [
              CustomSettingsTile(
                child: ListTile(
                  title: const Text(
                    'Download Audio Files',
                  ),
                  subtitle: const Text(
                      'Updates and downloads audio files from the database. Note that this may take some time. Requires an internet connection'),
                  trailing: DownloadButton(
                    enabled: !audioDownloader.loading,
                    onPressed: () async {
                      final download = audioDownloader.loadAudio(
                          languageModel.labels.map((l) => l['code']!).toList());

                      download.then((_) {
                        categoriesModel.initCategories();
                        showSnackbar('All Audio Downloaded', Colors.green);
                      });
                    },
                  ),
                  // leading: showLoadingIndicator(downloadingAudio),
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
                      onPressed: () async {
                        Color colour = Theme.of(context).colorScheme.error;
                        showSnackbar(
                            'Language model changing unavailable', colour);
                      },
                      theme: themeModel.currentTheme,
                    ),
                  ],
                ),
              ),
            ],
            theme: themeModel.currentTheme,
          ),
          Section(
            title: 'About',
            tiles: const [
              CustomSettingsTile(
                child: ListTile(
                  title: Text('Version'),
                  subtitle: Text('1.0.0'),
                ),
              ),
              CustomSettingsTile(
                child: ListTile(
                  title: Text('Developers'),
                  subtitle: Padding(
                    padding: EdgeInsets.fromLTRB(4, 4, 4, 8),
                    child: Text(
                        '- Brayden Ransom-Frost\n- Leo Headley\n- Jordan Wylde-Browne\n- Theodore Ing Ting Tiong\n- Thomas Ambrose\n- Toby Coy'),
                  ),
                ),
              )
            ],
            theme: themeModel.currentTheme,
          ),
        ],
      ),
    );
  }

  void showSnackbar(String msg, Color colour) {
    // create snack bar
    final snackBar = SnackBar(
      content: Text(
        msg,
        style: const TextStyle(
            fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
      ),
      duration: const Duration(seconds: 3),
      backgroundColor: colour,
      shape: const RoundedRectangleBorder(),
    );

    // show snackbar using scaffold messenger
    widget.scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
  }
}

class DownloadButton extends StatelessWidget {
  const DownloadButton({
    super.key,
    required this.onPressed,
    required this.enabled,
  });

  final Function onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: enabled
          ? () {
              onPressed();
            }
          : null,
      style:
          FilledButton.styleFrom(backgroundColor: Theme.of(context).cardColor),
      child: enabled
          ? Icon(
              Icons.download,
              color: Theme.of(context).canvasColor,
            )
          : Transform.scale(
              scale: 0.5, child: const CircularProgressIndicator()),
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
                style: TextStyle(color: theme.primaryColor, fontSize: 28)),
            const Expanded(
                child: Padding(
              padding: EdgeInsets.only(left: 20.0),
              child: Divider(),
            )),
          ],
        ),
        tiles: tiles);
  }
}
