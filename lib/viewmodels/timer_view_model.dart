import 'dart:async';

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_pomodoro/model/saved_interval.dart';
import 'package:simple_pomodoro/providers/storage_provider.dart';

import '../constants/settings_keys.dart';

class TimerViewModel {
  static const oneSec = const Duration(seconds: 1);
  static const Duration pomodoroSizeDefault =
      const Duration(minutes: SettingsKeys.defaultIntervalSizeInMinutes);
  static Duration pomodoroSize = pomodoroSizeDefault;

  Stream<DateTime> _timer;
  final StreamController<String> _timeFormatted =
      StreamController<String>.broadcast();
  final StreamController<bool> _timerStateActive = StreamController();
  final StreamController<bool> _timerIsEnded = StreamController();
  StreamSubscription _timeSubscription;
  final StreamController<List<SavedInterval>> _finishedPomodoros =
      StreamController();
  DateTime _started;
  var _savedIntervals = <SavedInterval>[];

  TimerViewModel() {
    _timerStateActive.add(false);

    DateTime pomodoroTime = new DateTime.fromMicrosecondsSinceEpoch(
        pomodoroSizeDefault.inMicroseconds);
    _timeFormatted.add(DateFormat.ms().format(pomodoroTime));

    _getDefaultPomodoroValue();
    _loadSavedIntervals();
  }

  Stream<DateTime> timedCounter(Duration interval, Duration maxCount) {
    StreamController<DateTime> controller;
    Timer timer;
    DateTime counter =
        new DateTime.fromMicrosecondsSinceEpoch(maxCount.inMicroseconds);

    void tick(_) {
      counter = counter.subtract(oneSec);
      controller.add(counter); // Ask stream to send counter values as event.
      if (counter.millisecondsSinceEpoch == 0) {
        final interval = SavedInterval(25, 0, _started);
        StorageProvider().insertInterval(interval);
        _savedIntervals.add(interval);
        _finishedPomodoros.add(_savedIntervals);
        timer.cancel();
        controller.close(); // Ask stream to shut down and tell listeners.
      }
    }

    void startTimer() {
      _started = DateTime.now();
      timer = Timer.periodic(interval, tick);
    }

    void stopTimer() {
      if (timer != null) {
        timer.cancel();
        timer = null;
      }
    }

    controller = StreamController<DateTime>(
        onListen: startTimer,
        onPause: stopTimer,
        onResume: startTimer,
        onCancel: stopTimer);

    return controller.stream;
  }

  void _onTimeChange(DateTime newTime) {
    _timeFormatted.add(DateFormat.ms().format(newTime));
  }

  void _handleTimerEnd() {
    _timerIsEnded.add(true);
    _timerStateActive.add(false);
    _timeSubscription = null;
  }

  @override
  Stream<bool> get timeIsOver => _timerIsEnded.stream;

  @override
  void changeTimerState() {
    if (_timeSubscription == null) {
      _onTimeChange(
          new DateTime.fromMicrosecondsSinceEpoch(pomodoroSize.inMicroseconds));
      print("subscribe");
      _timer = timedCounter(oneSec, pomodoroSize);
      _timerIsEnded.add(false);
      _timerStateActive.add(true);
      _timeSubscription = _timer.listen(_onTimeChange);
      _timeSubscription.onDone(_handleTimerEnd);
    } else {
      if (_timeSubscription.isPaused) {
        _timeSubscription.resume();
        _timerStateActive.add(true);
      } else {
        _timeSubscription.pause();
        _timerStateActive.add(false);
      }
    }
  }

  @override
  Stream<bool> get timerIsActive {
    return _timerStateActive.stream;
  }

  Stream<String> get timeTillEndReadable => _timeFormatted.stream;

  Stream<List<SavedInterval>> get finishedPomodoros =>
      _finishedPomodoros.stream;

  void _getDefaultPomodoroValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int value = prefs.getInt(SettingsKeys.KEY_POMODORO_SIZE) ??
        SettingsKeys.defaultIntervalSizeInMinutes;

    pomodoroSize = new Duration(minutes: value);
    DateTime pomodoroTime =
        new DateTime.fromMicrosecondsSinceEpoch(pomodoroSize.inMicroseconds);
    _onTimeChange(pomodoroTime);
  }

  void updateSettings() {
    _getDefaultPomodoroValue();
  }

  void _loadSavedIntervals() async {
    _savedIntervals = await StorageProvider().getAllIntervals();
  }
}
