import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:simple_pomodoro/model/setting.dart';
import 'package:simple_pomodoro/viewmodels/settings_view_model.dart';
import 'package:simple_pomodoro/widgets/setting_widget.dart';
import 'package:simple_pomodoro/widgets/setting_with_click.dart';
import 'package:simple_pomodoro/widgets/setting_with_switch.dart';

class SettingsPage extends StatefulWidget {
  final String title = "Settings";

  @override
  _SettingsPageState createState() => new _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with WidgetsBindingObserver {
  SettingsViewModel viewModel;

  List<Widget> _settingWidgets;

  _SettingsPageState() {
    viewModel = new SettingsViewModel();
    viewModel.actualSettings.listen(_changeSetting);
    _formSettingsList();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Center(
        child: new Column(
          children: _settingWidgets,
        ),
      ),
    );
  }

  void _changeSetting(List<String> event) {
    for (Widget widget in _settingWidgets) {
      if (widget is SettingWidget) {
        if (event[0] == widget.setting.key) {
          widget.updateSettingValue(event[1]);
          break;
        }
      }
    }
  }

  List<Widget> _formSettingsList() {
    _settingWidgets = new List();
    viewModel.settings.forEach(
        (key, value) => _settingWidgets.add(getAppropriateWidget(key, value)));
    return _settingWidgets;
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
