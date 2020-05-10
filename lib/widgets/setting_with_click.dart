import 'package:flutter/material.dart';
import 'package:simple_pomodoro/interfaces/setting_saver.dart';
import 'package:simple_pomodoro/model/setting.dart';
import 'package:simple_pomodoro/widgets/setting_widget.dart';

class SettingWithClick extends SettingWidget {
  SettingWithClick(Setting setting, SettingSaver listener)
      : super(setting, listener);

  @override
  Widget build(BuildContext context) {
    return new ListTile(
      title: new Text(setting.title),
      subtitle: new Text(setting.value),
      trailing: new Icon(Icons.keyboard_arrow_down),
      onTap: () {
        _clickToChange(context);
      },
    );
  }

  Future<Null> _clickToChange(BuildContext context) async {
    String selected = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Select value'),
            children: setting.possibleOptions
                .map((option) => SimpleDialogOption(
                      onPressed: () {
                        Navigator.pop(context, option);
                      },
                      child: new Text(option),
                    ))
                .toList(growable: false),
          );
        });
    listener.saveSetting(setting.key, selected);
  }
}
