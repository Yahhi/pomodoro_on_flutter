import 'package:flutter/material.dart';
import 'package:simple_pomodoro/interfaces/setting_saver.dart';
import 'package:simple_pomodoro/model/setting.dart';
import 'package:simple_pomodoro/widgets/setting_widget.dart';

class SettingWithSwitch extends SettingWidget {
  SettingWithSwitch(Setting setting, SettingSaver listener)
      : super(setting, listener);

  @override
  Widget build(BuildContext context) {
    return new SwitchListTile(
        title: new Text(setting.title),
        subtitle: new Text(setting.value),
        value: setting.value == setting.possibleOptions.first,
        onChanged: _saveSetting);
  }

  void _saveSetting(bool value) {
    listener.saveSetting(setting.key,
        value ? setting.possibleOptions.first : setting.possibleOptions.last);
  }
}
