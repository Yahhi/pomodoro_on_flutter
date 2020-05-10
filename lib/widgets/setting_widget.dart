import 'package:flutter/material.dart';
import 'package:simple_pomodoro/interfaces/setting_saver.dart';
import 'package:simple_pomodoro/model/setting.dart';

abstract class SettingWidget extends StatelessWidget {
  final Setting setting;
  final SettingSaver listener;

  SettingWidget(this.setting, this.listener);
}
