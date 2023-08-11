import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:provider/provider.dart';

import 'category.dart';
import 'colours.dart';

class SettingsWidget extends StatefulWidget {
  const SettingsWidget({super.key});

  @override
  State<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  @override
  Widget build(BuildContext build) {
    return Consumer2<CategoriesModel, ThemeModel>(
      builder: buildScaffold,
    );
  }

  Widget buildScaffold(BuildContext context, CategoriesModel categoriesModel,
      ThemeModel themeModel, _) {
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
                        items: const [
                          DropdownMenuItem(
                            value: 0,
                            child: Text('Classic'),
                          ),
                          DropdownMenuItem(
                            value: 1,
                            child: Text('SES Theme'),
                          ),
                          DropdownMenuItem(
                            value: 2,
                            child: Text('Purple'),
                          ),
                        ],
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
