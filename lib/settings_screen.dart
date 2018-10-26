
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key key}) : super(key: key);

  final String title = "Settings";

  @override
  _SettingsPageState createState() => new _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with WidgetsBindingObserver {
  List<String> _settings = [];

  _SettingsPageState() {
    _settings.add("pomodoro size");
    _settings.add("pomodoro_sound");
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Expanded(
              child: new ListView.builder(
                itemCount: _settings.length,
                itemBuilder: (BuildContext ctxt, int index) {
                  return new Text(_settings[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

}