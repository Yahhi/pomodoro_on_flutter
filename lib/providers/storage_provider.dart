import 'package:path/path.dart';
import 'package:simple_pomodoro/model/saved_interval.dart';
import 'package:sqflite/sqflite.dart';

class StorageProvider {
  Database _db;
  Future opened;

  static StorageProvider _singleton;
  factory StorageProvider() {
    if (_singleton == null) {
      _singleton = StorageProvider._internal();
    }
    return _singleton;
  }

  StorageProvider._internal() {
    opened = _open();
  }

  Future _open() async {
    final databasePath = await getDatabasesPath();
    String path = join(databasePath, "db.db");
    _db = await openDatabase(path, version: 1,
        onUpgrade: (Database db, int oldVersion, int version) async {
      //TODO upgrade
    }, onCreate: (Database db, int version) async {
      await db.execute('''
create table saved_interval ( 
  started integer primary key, 
  minutes integer not null,
  seconds integer not null,
  project_id integer)
''');
    });
  }

  /// Close database.
  Future close() async {
    await _db.close();
  }

  Future<List<SavedInterval>> getAllIntervals() async {
    await opened;
    List<Map> maps =
        await _db.query('saved_interval', orderBy: 'started DESC', limit: 10);
    List<SavedInterval> result = [];
    for (final map in maps) {
      result.add(SavedInterval.fromMap(map));
    }
    return result;
  }

  Future<int> insertInterval(SavedInterval interval) {
    return _db.insert('saved_interval', interval.map);
  }
}
