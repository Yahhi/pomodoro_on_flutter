import 'dart:async';

import 'package:audioplayers/audio_cache.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:simple_pomodoro/constants/settings_keys.dart';
import 'package:simple_pomodoro/model/saved_interval.dart';
import 'package:simple_pomodoro/viewmodels/timer_view_model.dart';

class TimerPage extends StatefulWidget {
  TimerPage({Key key}) : super(key: key);

  final String title = "Pomodoro timer";

  @override
  _TimerPageState createState() => new _TimerPageState();
}

class _TimerPageState extends State<TimerPage> with WidgetsBindingObserver {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  final player = AudioCache();
  TimerViewModel viewModel = TimerViewModel();

  @override
  initState() {
    super.initState();
    viewModel.timeIsOver.listen(informTimerFinished);
    WidgetsBinding.instance.addObserver(this);
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  Future onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }

    /*await Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new SecondScreen(payload)),
    );*/
  }

  void informTimerFinished(bool finished) {
    print('timer is finished $finished');
    if (finished != null && finished) {
      if (_notification == null) {
        makeNoise();
      } else {
        switch (_notification.index) {
          case 0: // resumed
            makeNoise();
            break;
          default:
            _showNotification();
            break;
        }
      }
    }
  }

  Future _showNotification() async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        '120', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(110, 'Pomodoro',
        'Time is over! Let\'s have a rest!', platformChannelSpecifics,
        payload: 'item x');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/bg.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  StreamBuilder<String>(
                    stream: viewModel.timeTillEndReadable,
                    initialData: '00:00',
                    builder: (context, snapshot) {
                      return Text(
                        snapshot.data,
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Watch',
                            fontSize: 70),
                      );
                    },
                  ),
                  StreamBuilder<bool>(
                    stream: viewModel.timerIsActive,
                    initialData: false,
                    builder: (context, snapshot) {
                      return FloatingActionButton(
                        child: Icon(snapshot.data
                            ? FontAwesomeIcons.pause
                            : FontAwesomeIcons.play),
                        onPressed: _actionTimer,
                        tooltip: 'Start/Stop timer',
                      );
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: StreamBuilder<List<SavedInterval>>(
                stream: viewModel.finishedPomodoros,
                initialData: [],
                builder: (context, snapshot) {
                  return ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext ctxt, int index) {
                      final now = snapshot.data[index].started;
                      return Text(
                        DateFormat.yMd().format(now) +
                            " " +
                            DateFormat.Hm().format(now),
                        style: TextStyle(color: Colors.white),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _actionTimer() {
    viewModel.changeTimerState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  AppLifecycleState _notification;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      debugPrint("state changed to " + state.index.toString());
      _notification = state;
    });
  }

  void makeNoise() {
    print("zzzzz");
    player.play(SettingsKeys.defaultAlarmAudioPath);
  }
}
