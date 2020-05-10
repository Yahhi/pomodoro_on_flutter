import 'dart:async';

import 'package:audioplayers/audio_cache.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:simple_pomodoro/constants/settings_keys.dart';
import 'package:simple_pomodoro/model/menu_choice.dart';
import 'package:simple_pomodoro/viewmodels/timer_view_model_impl.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

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

  String timeInWidget = "";
  static AudioCache player = new AudioCache();
  TimerViewModelImpl viewModel;
  List<String> pomodoroFinishedItems = [];

  _MyHomePageState() {
    viewModel = new TimerViewModelImpl();
  }

  @override
  initState() {
    iconTimer = iconTimerStart;
    super.initState();
    viewModel.timerIsActive.listen(_setIconForButton);
    viewModel.timeIsOver.listen(informTimerFinished);
    viewModel.timeTillEndReadable.listen(secondChanger);
    viewModel.finishedPomodoros.listen(showPomodoroList);
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

  void secondChanger(String timeString) {
    if (timeString != null) {
      setState(() {
        timeInWidget = timeString;
      });
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
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
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
              Text(
                '$timeInWidget',
                style: Theme.of(context).textTheme.headline4,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: pomodoroFinishedItems.length,
                  itemBuilder: (BuildContext ctxt, int index) {
                    return Text(pomodoroFinishedItems[index]);
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
    player.fixedPlayer.pause();
  }

  void showPomodoroList(String event) {
    setState(() {
      pomodoroFinishedItems.add(event);
    });
  }
}
