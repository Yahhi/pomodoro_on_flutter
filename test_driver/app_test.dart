import 'package:flutter_driver/flutter_driver.dart';
import 'package:intl/intl.dart';
import 'package:test/test.dart';

void main() {
  group("end-to-end test", () {
    FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

    test("Test on fab click timer is reduced after 1 second", () async {
      SerializableFinder fab = find.byTooltip('Start/Stop timer');
      await driver.waitFor(fab);
      await driver.tap(fab);

      await Future.delayed(const Duration(seconds: 1));

      const pomodoroSize = const Duration(minutes: 1);
      DateTime pomodoroTime =
          new DateTime.fromMicrosecondsSinceEpoch(pomodoroSize.inMicroseconds);
      String timeAfterUpdate =
          DateFormat.ms().format(pomodoroTime.subtract(Duration(seconds: 1)));
      await driver.waitFor(find.text(timeAfterUpdate));
    });
  });
}
