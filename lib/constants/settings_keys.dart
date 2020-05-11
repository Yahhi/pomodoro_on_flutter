class SettingsKeys {
  static const KEY_POMODORO_SIZE = "pomodoro_size";
  static const KEY_ALARM_MELODY = "pomodoro_alarm";
  static const KEY_INTERRUPTIONS_ENABLED = "interupt_enabled";

  static const defaultIntervalSizeInMinutes = 25;
  static const defaultAlarmAudioPath = "assets/sound_alarm.mp3";
  static const defaultInterruptionEnabled = true;

  static const enabledText = "Pomodoro can be paused";
  static const disabledText =
      "Pomodoro should run until end without interruptions";
}
