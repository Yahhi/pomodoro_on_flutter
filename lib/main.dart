
import 'package:flutter/material.dart';
import 'package:simple_pomodoro/settings_screen.dart';
import 'package:simple_pomodoro/timer_screen.dart';

void main() async {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Pomodoro',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(),
      routes: {
        '/settings': (context) => SettingsPage(),
      },
    );
  }
}


