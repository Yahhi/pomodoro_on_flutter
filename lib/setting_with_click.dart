import 'package:flutter/material.dart';
import 'package:simple_pomodoro/setting.dart';
import 'package:simple_pomodoro/setting_saver.dart';
import 'package:simple_pomodoro/setting_widget.dart';

class SettingWithClick extends SettingWidget {
  SettingWithClickState state;

  SettingWithClick(Setting setting, SettingSaver listener)
      : super(setting, listener);

  @override
  SettingWithClickState createState() {
    state = new SettingWithClickState(setting, listener);
    return state;
  }

  @override
  void updateSettingValue(String newValue) {
    state.updateSettingValue(newValue);
  }
}

class SettingWithClickState extends State<SettingWithClick> {
  Setting setting;
  String _subtitle;
  SettingSaver listener;
  List<Widget> optionWidgets;

  SettingWithClickState(this.setting, this.listener) {
    _subtitle = setting.value;
    optionWidgets = _getOptionListForSetting();
  }

  @override
  Widget build(BuildContext context) {
    return new ListTile(
      title: new Text(setting.title),
      subtitle: new Text(_subtitle),
      trailing: new Icon(Icons.keyboard_arrow_down),
      onTap: _clickToChange,
    );
  }

  Future<Null> _clickToChange() async {
    String selected = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Select value'),
            children: optionWidgets,
          );
        });
    listener.saveSetting(setting.key, selected);
  }

  List<Widget> _getOptionListForSetting() {
    List<SimpleDialogOption> options = new List();
    for (String option in setting.possibleOptions) {
      options.add(new SimpleDialogOption(
        onPressed: () {
          Navigator.pop(context, option);
        },
        child: new Text(option),
      ));
    }
    return options;
  }

  void updateSettingValue(String newValue) {
    setState(() {
      _subtitle = newValue;
    });
  }
}
