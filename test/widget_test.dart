// This is a basic Flutter widget test.
// To perform an interaction with a widget in your test, use the WidgetTester utility that Flutter
// provides. For example, you can send tap and scroll gestures. You can also use WidgetTester to
// find child widgets in the widget tree, read text, and verify that the values of widget properties
// are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:simple_pomodoro/main.dart';
import 'package:simple_pomodoro/viewmodels/timer_view_model.dart';

void main() {
  testWidgets('Test on load timer is set to initial value',
      (WidgetTester tester) async {
    await tester.pumpWidget(new MyApp());

    String whatToExpect = DateFormat.ms().format(
        new DateTime.fromMicrosecondsSinceEpoch(
            TimerViewModel.pomodoroSize.inMicroseconds));
    expect(find.text(whatToExpect), findsOneWidget);
    expect(find.byIcon(Icons.alarm), findsOneWidget);
  });
}
