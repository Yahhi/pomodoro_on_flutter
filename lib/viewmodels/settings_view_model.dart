import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_pomodoro/constants/settings_keys.dart';
import 'package:simple_pomodoro/interfaces/setting_saver.dart';
import 'package:simple_pomodoro/model/setting.dart';

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

  final _actualSettingValues = StreamController<List<Setting>>();
  Stream<List<Setting>> get actualSettings => _actualSettingValues.stream;
  var settings = <Setting>[];

  SettingsViewModel() {
    _getSettingsValues();
  }

  void _getSettingsValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final intervalLength = Setting(
        SettingsKeys.KEY_POMODORO_SIZE,
        "Pomodoro interval",
        Setting.TYPE_SELECT,
        "${SettingsKeys.defaultIntervalSizeInMinutes} min",
        possibleOptions: intervalOptions);
    final valuePomodoroSize = prefs.getInt(SettingsKeys.KEY_POMODORO_SIZE) ??
        SettingsKeys.defaultIntervalSizeInMinutes;
    intervalLength.value = "$valuePomodoroSize min";
    settings.add(intervalLength);

    final melody = Setting(SettingsKeys.KEY_ALARM_MELODY, "Finishing melody",
        Setting.TYPE_SELECT, SettingsKeys.defaultAlarmAudioPath,
        possibleOptions: melodyOptions);
    melody.value = prefs.getString(SettingsKeys.KEY_ALARM_MELODY) ??
        SettingsKeys.defaultAlarmAudioPath;
    settings.add(melody);

    Setting interruptions = new Setting(SettingsKeys.KEY_INTERRUPTIONS_ENABLED,
        "Interruptions", Setting.TYPE_SWITCH, SettingsKeys.enabledText,
        possibleOptions: interruptionOptions);
    final interruptionsEnabled =
        prefs.getBool(SettingsKeys.KEY_INTERRUPTIONS_ENABLED) ??
            SettingsKeys.defaultInterruptionEnabled;
    interruptions.value = interruptionsEnabled
        ? SettingsKeys.enabledText
        : SettingsKeys.disabledText;
    settings.add(interruptions);

    _actualSettingValues.add(settings);
  }

  @override
  void saveSetting(String key, String newValue) {
    print("saving key: $key, value: $newValue");
    _saveSettingToPreferences(key, newValue);
    final editedSetting = settings.firstWhere((element) => element.key == key);
    editedSetting.value = newValue;
    _actualSettingValues.add(settings);
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
