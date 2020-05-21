import 'package:flutter/material.dart';
import 'package:preferences/preferences.dart';

class settings_page extends StatelessWidget {
  List<String> entries;

  settings_page(this.entries);
  @override
  Widget build(BuildContext context) {
    List<String> dropDownOptions = ['test op 1', 'test op 2', 'test op 3'];
    entries = this.entries;
    return Scaffold(
      appBar: AppBar(
        title: Text('Preferences'),
      ),
      body: PreferencePage([
        PreferenceTitle('General'),
        DropdownPreference(
          'Test Pref 1',
          'drop_down_pref',
          values: dropDownOptions,
          defaultVal: dropDownOptions[0],
        ),
        SwitchPreference(
          "Notifications",
          "insert_the_variable_I_would_change_if_notifications_were_enabled",
          defaultVal: true,
        ),
        PreferenceTitle('Other section'),
        RadioPreference(
          'Light Theme',
          'light',
          'ui_theme',
          isDefault: true,
        ),
        RadioPreference(
          'Dark Theme',
          'dark',
          'ui_theme',
        ),
      ]),
    );

  }
}
