import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:simple_pomodoro/settings_screen.dart';
import 'package:simple_pomodoro/timer_screen.dart';

void main() async {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  final FirebaseAnalytics analytics = FirebaseAnalytics();
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Pomodoro',
      theme: new ThemeData(
          primarySwatch: Colors.blue, backgroundColor: Colors.transparent),
      home: new MyHomePage(),
      routes: {
        '/settings': (context) => SettingsPage(),
      },
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
    );
  }
}
