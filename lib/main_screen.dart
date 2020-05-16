import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:simple_pomodoro/constants/app_colors.dart';

import 'settings_page.dart';
import 'timer_page.dart';

class MainScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MainScreenState();
  }
}

class _MainScreenState extends State<MainScreen> {
  _PageType selectedPage = _PageType.time;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _selectPage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: pageIndex,
        onTap: _changeSelection,
        unselectedItemColor: AppColors.icons_dark,
        selectedItemColor: AppColors.icons_highlight,
        items: [
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.home),
            title: Text('Home'),
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.tasks),
            title: Text('Plan'),
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.hourglass),
            title: Text('Timer'),
          ),
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.chartBar), title: Text('Charts')),
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.cog), title: Text('Settings'))
        ],
      ),
    );
  }

  Widget _selectPage() {
    switch (selectedPage) {
      case _PageType.home:
        return Container();
      case _PageType.graph:
        return Container();
      case _PageType.time:
        return TimerPage();
      case _PageType.settings:
        return SettingsPage();
      case _PageType.plan:
        return Container();
    }
  }

  int get pageIndex {
    switch (selectedPage) {
      case _PageType.home:
        return 0;
      case _PageType.graph:
        return 3;
      case _PageType.time:
        return 2;
      case _PageType.settings:
        return 4;
      case _PageType.plan:
        return 1;
    }
    return 2;
  }

  void _changeSelection(int value) {
    switch (value) {
      case 0:
        selectedPage = _PageType.home;
        break;
      case 1:
        selectedPage = _PageType.plan;
        break;
      case 2:
        selectedPage = _PageType.time;
        break;
      case 3:
        selectedPage = _PageType.graph;
        break;
      case 4:
        selectedPage = _PageType.settings;
        break;
    }
    setState(() {});
  }
}

enum _PageType { home, graph, time, settings, plan }
