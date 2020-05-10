import 'package:flutter/material.dart';
import 'package:simple_pomodoro/interfaces/setting_saver.dart';
import 'package:simple_pomodoro/model/setting.dart';
import 'package:simple_pomodoro/widgets/setting_widget.dart';

class SettingWithSwitch extends SettingWidget {
  SettingWithSwitch(Setting setting, SettingSaver listener)
      : super(setting, listener);

  SettingWithSwitchState state;

  @override
  SettingWithSwitchState createState() {
    state = new SettingWithSwitchState(setting, listener);
    return state;
  }

  @override
  void updateSettingValue(String newValue) {
    this.state.updateSetting(newValue);
  }
}

class SettingWithSwitchState extends State<SettingWithSwitch> {
  Setting setting;
  bool _settingEnabled;
  String _subtitle;
  final SettingSaver listener;

  SettingWithSwitchState(this.setting, this.listener) {
    _subtitle = setting.value;
    _settingEnabled = setting.value == setting.possibleOptions.first;
  }

  @override
  Widget build(BuildContext context) {
    return new SwitchListTile(
        title: new Text(setting.title),
        subtitle: new Text(_subtitle),
        value: _settingEnabled,
        onChanged: _saveSetting);
  }

  void _saveSetting(bool value) {
    listener.saveSetting(setting.key,
        value ? setting.possibleOptions.first : setting.possibleOptions.last);
  }

  void updateSetting(String newValue) {
    setState(() {
      _settingEnabled = newValue == setting.possibleOptions.first;
      _subtitle = newValue;
    });
  }
}
