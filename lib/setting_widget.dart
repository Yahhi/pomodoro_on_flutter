import 'package:flutter/material.dart';
import 'package:simple_pomodoro/setting.dart';
import 'package:simple_pomodoro/setting_saver.dart';

abstract class SettingWidget extends StatefulWidget {
  final Setting setting;
  final SettingSaver listener;

  SettingWidget(this.setting, this.listener);

  void updateSettingValue(String newValue);
}
