import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SqlDB {
  static Database? _db;

  Future<Database?> get db async {
    if (_db == null) {
      _db = await intitialDB();
      return _db;
    }
    return _db;
  }

  intitialDB() async {
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, "todo.db");
    Database db = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    return db;
  }

  _onCreate(db, version) async {
    await db.execute('''
      CREATE TABLE "tasks" 
      (
        "id" INTEGER PRIMARY KEY,
        "title" TEXT ,
        "time" TEXT ,
        "date" TEXT
      )''');
    print("created====================");
  }

  _onUpgrade(db, oldVersion, newVersion) {
    print("upgraded============================");
  }

  readData(String sql) async {
    Database? mydb = await db;
    List<Map> response = await mydb!.rawQuery(sql);
    return response;
  }

  InsertData(String sql) async {
    Database? mydb = await db;
    int response = await mydb!.rawInsert(sql);
    return response;
  }

  UpdateData(String sql) async {
    Database? mydb = await db;
    int response = await mydb!.rawUpdate(sql);
    return response;
  }

  DeleteData(String sql) async {
    Database? mydb = await db;
    int response = await mydb!.rawDelete(sql);
    return response;
  }

  mydeldatabase() async {
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, "todo.db");
    await deleteDatabase(path);
  }
}
