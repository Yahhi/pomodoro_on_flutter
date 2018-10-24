import 'dart:async';

import 'package:intl/intl.dart';
import 'package:simple_pomodoro/timer_view_model.dart';

class TimerViewModelImpl implements TimerViewModel {
  static const oneSec = const Duration(seconds:1);
  static const pomodoroSize = const Duration(minutes: 1);

  Stream<DateTime> _timer;
  StreamController<String> _timeFormatted = StreamController<String>.broadcast();
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

    DateTime pomodoroTime = new DateTime.fromMicrosecondsSinceEpoch(pomodoroSize.inMicroseconds);
    _timeFormatted.add(DateFormat.ms().format(pomodoroTime));
    print(DateFormat.ms().format(pomodoroTime));
  }

  static DateTime get pomodoroTime => new DateTime.fromMicrosecondsSinceEpoch(pomodoroSize.inMicroseconds);

  Stream<DateTime> timedCounter(Duration interval, Duration maxCount) {
    StreamController<DateTime> controller;
    Timer timer;
    DateTime counter = new DateTime.fromMicrosecondsSinceEpoch(maxCount.inMicroseconds);

    void tick(_) {
      counter = counter.subtract(oneSec);
      controller.add(counter); // Ask stream to send counter values as event.
      if (counter.millisecondsSinceEpoch == 0) {
        DateTime now = new DateTime.now();
        _finishedPomodoros.add(DateFormat.yMd().format(now) + " " + DateFormat.Hm().format(now));
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
}