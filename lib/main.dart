import 'dart:async';

import 'package:audioplayers/audio_cache.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

void main() async {
  flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
  runApp(new MyApp());
}

const oneSec = const Duration(seconds:1);
const interval = const Duration(minutes: 1);
const iconCancel = Icons.cancel;
const iconStart = Icons.alarm;
const alarmAudioPath = "sound_alarm.mp3";

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Pomodoro',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Pomodoro timer'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  DateTime duration = new DateTime.fromMicrosecondsSinceEpoch(interval.inMicroseconds);
  Timer counterSeconds;
  Icon iconTimerStarter = new Icon(iconStart);
  DateFormat minutesSeconds = new DateFormat("ms");
  static AudioCache player = new AudioCache();

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    var initializationSettingsAndroid =
      new AndroidInitializationSettings('alarm');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        selectNotification: onSelectNotification);
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

  Future _showNotification() async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        '120', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        110, 'Pomodoro', 'Time is over! Let\'s have a rest!' , platformChannelSpecifics,
        payload: 'item x');
  }

  void handleTick() {
    print(duration);
    setState(() {
      duration = duration.subtract(oneSec);
      if (duration.millisecondsSinceEpoch == 0) {
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
        stopTimer();
      }
    });
  }

  void _actionTimer() {
    if (counterSeconds == null) {
      startTimer();
    } else if (counterSeconds.isActive){
      stopTimer();
    } else {
      startTimer();
    }
  }

  void _setIconForButton(Icon icon) {
    setState(() {
      iconTimerStarter = icon;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return new Scaffold(
      appBar: new AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: new Text(widget.title),
      ),
      body: new Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: new Column(
          // Column is also layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug paint" (press "p" in the console where you ran
          // "flutter run", or select "Toggle Debug Paint" from the Flutter tool
          // window in IntelliJ) to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text(
              '${minutesSeconds.format(duration)}',
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: _actionTimer,
        tooltip: 'Increment',
        child: iconTimerStarter,
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void startTimer() {
    if (duration.millisecondsSinceEpoch == 0) {
      duration = new DateTime.fromMicrosecondsSinceEpoch(interval.inMicroseconds);
    }
    counterSeconds = new Timer.periodic(oneSec, (Timer t) => handleTick());
    _setIconForButton(new Icon(iconCancel));
  }

  void stopTimer() {
    counterSeconds.cancel();
    _setIconForButton(new Icon(iconStart));

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
    player.play(alarmAudioPath);
  }
}
