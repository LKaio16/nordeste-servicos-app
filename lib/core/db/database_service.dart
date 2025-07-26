import 'package:sembast/sembast.dart';
import 'database_factory.dart'
    if (dart.library.io) 'database_factory_io.dart'
    if (dart.library.html) 'database_factory_web.dart';

class DatabaseService {
  static const String dbName = 'nordeste_servicos.db';
  Database? _database;

  Future<Database> get database async {
    if (_database == null) {
      await _init();
    }
    return _database!;
  }

  Future<void> _init() async {
    final dbPath = await getDatabasePath(dbName);
    _database = await getDatabaseFactory().openDatabase(dbPath);
  }
} 