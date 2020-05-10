import 'dart:async';

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_pomodoro/interfaces/timer_view_model.dart';

import '../constants/settings_keys.dart';

class TimerViewModelImpl implements TimerViewModel {
  static const oneSec = const Duration(seconds: 1);
  static const Duration pomodoroSizeDefault =
      const Duration(minutes: SettingsKeys.defaultIntervalSizeInMinutes);
  static Duration pomodoroSize = pomodoroSizeDefault;

  Stream<DateTime> _timer;
  StreamController<String> _timeFormatted =
      StreamController<String>.broadcast();
  StreamController<bool> _timerStateActive;
  StreamController<bool> _timerIsEnded;
  StreamSubscription _timeSubscription;
  StreamController<String> _finishedPomodoros;

  TimerViewModelImpl() {
    _timerStateActive = new StreamController();
    _timerStateActive.add(false);
    _timerIsEnded = new StreamController();
    _timeFormatted = new StreamController();
    _finishedPomodoros = new StreamController();

    DateTime pomodoroTime = new DateTime.fromMicrosecondsSinceEpoch(
        pomodoroSizeDefault.inMicroseconds);
    _timeFormatted.add(DateFormat.ms().format(pomodoroTime));

    _getDefaultPomodoroValue();
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
        DateTime now = new DateTime.now();
        _finishedPomodoros.add(
            DateFormat.yMd().format(now) + " " + DateFormat.Hm().format(now));
        timer.cancel();
        controller.close(); // Ask stream to shut down and tell listeners.
      }
    }

    void startTimer() {
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

  @override
  Stream<String> get timeTillEndReadable => _timeFormatted.stream;

  @override
  Stream<String> get finishedPomodoros => _finishedPomodoros.stream;

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
}
