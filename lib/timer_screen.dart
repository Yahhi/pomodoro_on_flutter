import 'dart:async';

import 'package:audioplayers/audio_cache.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:simple_pomodoro/constants/settings_keys.dart';
import 'package:simple_pomodoro/model/menu_choice.dart';
import 'package:simple_pomodoro/model/saved_interval.dart';
import 'package:simple_pomodoro/viewmodels/timer_view_model.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  final String title = "Pomodoro timer";

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  static const iconCancel = Icons.cancel;
  static const iconStart = Icons.alarm;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  Icon iconTimerStart = new Icon(iconStart);
  Icon iconTimerPause = new Icon(iconCancel);
  Icon iconTimer;

  static const List<Choice> choices = const <Choice>[
    const Choice(title: 'Settings', icon: Icons.settings),
  ];

  final player = AudioCache();
  TimerViewModel viewModel = TimerViewModel();

  @override
  initState() {
    iconTimer = iconTimerStart;
    super.initState();
    viewModel.timerIsActive.listen(_setIconForButton);
    viewModel.timeIsOver.listen(informTimerFinished);
    WidgetsBinding.instance.addObserver(this);
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('alarm');
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
    if (finished != null) {
      if (finished) {
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

  void _setIconForButton(bool started) {
    if (started != null) {
      setState(() {
        if (started) {
          iconTimer = iconTimerPause;
        } else {
          iconTimer = iconTimerStart;
        }
      });
    }
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
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: <Widget>[
            // action button
            PopupMenuButton<Choice>(
              onSelected: _select,
              itemBuilder: (BuildContext context) {
                return choices.map((Choice choice) {
                  return PopupMenuItem<Choice>(
                    value: choice,
                    child: Text(choice.title),
                  );
                }).toList();
              },
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Center(
                  child: StreamBuilder<String>(
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
        floatingActionButton: FloatingActionButton(
          child: iconTimer,
          onPressed: _actionTimer,
          tooltip: 'Start/Stop timer',
        ),
      ),
    );
  }

  void _select(Choice choice) async {
    if (choice.title == "Settings") {
      await Navigator.of(context).pushNamed("/settings");
      viewModel.updateSettings();
    }
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
    debugPrint("zzzzz");
    player.play(SettingsKeys.defaultAlarmAudioPath);
  }
}
