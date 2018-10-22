// This is a basic Flutter widget test.
// To perform an interaction with a widget in your test, use the WidgetTester utility that Flutter
// provides. For example, you can send tap and scroll gestures. You can also use WidgetTester to
// find child widgets in the widget tree, read text, and verify that the values of widget properties
// are correct.

import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:simple_pomodoro/main.dart';
import 'package:simple_pomodoro/timer_view_model_impl.dart';

void main() {

  testWidgets('Test on load timer is set to initial value', (WidgetTester tester) async {
    await tester.pumpWidget(new MyApp());

    String whatToExpect = DateFormat.ms().format(TimerViewModelImpl.pomodoroTime);
    expect(find.text(whatToExpect), findsOneWidget);
    expect(find.byIcon(Icons.alarm), findsOneWidget);
  });
}
