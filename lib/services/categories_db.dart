import 'package:expenses_tracker_app/models/category.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class CategoriesDatabase {
  static Database _database;
  static List<Category> categories;

  final String dbName = "expenses.db";
  final String tableName = 'categories';
  final version = 1;

  // make into a Singleton
  CategoriesDatabase._privateConstructor();
  static final CategoriesDatabase instance = CategoriesDatabase._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database;

    _database = await initialize();
    return _database;
  }

  initialize() async {
//    print("Initializing categories database");
    return await openDatabase(join(await getDatabasesPath(), dbName),
      onCreate: (db, version) {
        return db.execute("CREATE TABLE ${tableName}(id INTEGER PRIMARY KEY, name TEXT, icon TEXT)");
      },
      version: 1
    );
  }

  Future<int> insert(Category category) async {
//    print("Inserting ${category.name} into database");
    Database db = await instance.database;
    await db.insert(tableName, category.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Category>> fetchAll() async {
    print("Fetching all categories");
    Database db = await instance.database;
    List<Map<String, dynamic>> categoriesMaps = await db.query(tableName);

    return List.generate(categoriesMaps.length, (index) {
      return Category.fromJson(categoriesMaps[index]);
    });
  }


  Future<Category> getDefault() async {
    Database db = await instance.database;
    var results = await db.query(tableName, where: "id = ?", whereArgs: [1]);
    return Category.fromJson(results[0]);
  }

  Future<Category> fetch(int id) async {
    Database db = await instance.database;
    var results = await db.query(tableName, where: "id = ?", whereArgs: [id]);
    return Category.fromJson(results[0]);
  }

//  final String dbName = "expenses.db";
//  Database _database;
//  final String tableName = 'categories';
//
//  Future<void> initialize() async {
//    print("Initializing categories database");
//    _database = openDatabase(join(await getDatabasesPath(), dbName),
//      onCreate: (db, version) {
//        return db.execute("CREATE TABLE ${tableName}(id INTEGER PRIMARY KEY, name TEXT, icon TEXT)");
//      },
//      version: 1
//    );
//    print(_database);
//  }
//
//  Future<void> insert(Category category) async {
//    print("Inserting ${category.name} into database");
//    print(_database);
//    Database db = await _database;
//    await db.insert(tableName, category.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
//  }
//
//  Future<List<Category>> fetchAll() async {
//    print("Fetching all categories");
//    List<Map<String, dynamic>> categoriesMaps = await _database.query(tableName);
//
//    return List.generate(categoriesMaps.length, (index) {
//      return Category.fromJson(categoriesMaps[index]);
//    });
//  }
}