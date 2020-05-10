import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:simple_pomodoro/model/setting.dart';
import 'package:simple_pomodoro/viewmodels/settings_view_model.dart';
import 'package:simple_pomodoro/widgets/setting_with_click.dart';
import 'package:simple_pomodoro/widgets/setting_with_switch.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with WidgetsBindingObserver {
  final viewModel = SettingsViewModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Center(
        child: StreamBuilder<List<Setting>>(
          stream: viewModel.actualSettings,
          initialData: [],
          builder: (context, snapshot) {
            return Column(
              children: viewModel.settings
                  .map((setting) => getAppropriateWidget(setting.key, setting))
                  .toList(),
            );
          },
        ),
      ),
    );
  }

  Widget getAppropriateWidget(String key, Setting value) {
    debugPrint(key);
    switch (value.type) {
      case Setting.TYPE_SELECT:
        return new SettingWithClick(value, viewModel);
      case Setting.TYPE_SWITCH:
        return new SettingWithSwitch(value, viewModel);
      default:
        return new Text("Unsupported type of setting");
    }
  }
}
