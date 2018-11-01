import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_pomodoro/setting.dart';
import 'package:simple_pomodoro/setting_saver.dart';
import 'package:simple_pomodoro/settings_keys.dart';

class SettingsViewModel implements SettingSaver {
  static const interruptionOptions = [
    SettingsKeys.enabledText,
    SettingsKeys.disabledText
  ];
  static const melodyOptions = [SettingsKeys.defaultAlarmAudioPath, "dzin.mp3"];
  static const intervalOptions = [
    "5 min",
    "10 min",
    "15 min",
    "20 min",
    "25 min",
    "30 min",
    "45 min",
    "60 min"
  ];

  StreamController<List<String>> _actualSettingValues;
  Map<String, Setting> settings;

  SettingsViewModel() {
    settings = new Map();
    _actualSettingValues = new StreamController();

    Setting intervalLength = new Setting(
        SettingsKeys.KEY_POMODORO_SIZE,
        "Pomodoro interval",
        Setting.TYPE_SELECT,
        "${SettingsKeys.defaultIntervalSizeInMinutes} min");
    intervalLength.possibleOptions = intervalOptions;
    settings[SettingsKeys.KEY_POMODORO_SIZE] = intervalLength;

    Setting melody = new Setting(
        SettingsKeys.KEY_ALARM_MELODY,
        "Finishing melody",
        Setting.TYPE_SELECT,
        SettingsKeys.defaultAlarmAudioPath);
    melody.possibleOptions = melodyOptions;
    settings[SettingsKeys.KEY_ALARM_MELODY] = melody;

    Setting interruptions = new Setting(SettingsKeys.KEY_INTERRUPTIONS_ENABLED,
        "Interruptions", Setting.TYPE_SWITCH, SettingsKeys.enabledText);
    interruptions.possibleOptions = interruptionOptions;
    settings[SettingsKeys.KEY_INTERRUPTIONS_ENABLED] = interruptions;

    _getSettingsValues();
  }

  void _getSettingsValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int valuePomodoroSize = prefs.getInt(SettingsKeys.KEY_POMODORO_SIZE) ??
        SettingsKeys.defaultIntervalSizeInMinutes;
    String valueAlarmMelody = prefs.getString(SettingsKeys.KEY_ALARM_MELODY) ??
        SettingsKeys.defaultAlarmAudioPath;
    bool interruptionsEnabled =
        prefs.getBool(SettingsKeys.KEY_INTERRUPTIONS_ENABLED) ??
            SettingsKeys.defaultInterruptionEnabled;

    _actualSettingValues
        .add([SettingsKeys.KEY_POMODORO_SIZE, "$valuePomodoroSize min"]);
    _actualSettingValues.add([SettingsKeys.KEY_ALARM_MELODY, valueAlarmMelody]);
    _actualSettingValues.add([
      SettingsKeys.KEY_INTERRUPTIONS_ENABLED,
      interruptionsEnabled
          ? SettingsKeys.enabledText
          : SettingsKeys.disabledText
    ]);
  }

  Stream<List<String>> get actualSettings => _actualSettingValues.stream;

  @override
  void saveSetting(String key, String newValue) {
    print("saving key: $key, value: $newValue");
    _saveSettingToPreferences(key, newValue);
    _actualSettingValues.add([key, newValue]);
  }

  void _saveSettingToPreferences(String key, String newValue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    switch (key) {
      case SettingsKeys.KEY_POMODORO_SIZE:
        int minutes = int.tryParse(newValue.substring(0, newValue.length - 4));
        prefs.setInt(key, minutes);
        break;
      case SettingsKeys.KEY_ALARM_MELODY:
        prefs.setString(key, newValue);
        break;
      case SettingsKeys.KEY_INTERRUPTIONS_ENABLED:
        prefs.setBool(key, newValue == SettingsKeys.enabledText);
        break;
    }
  }
}
