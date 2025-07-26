import 'package:sembast/sembast.dart';
import 'package:sembast_web/sembast_web.dart';

DatabaseFactory getDatabaseFactory() => databaseFactoryWeb;

Future<String> getDatabasePath(String dbName) async {
  // For web, the database name is sufficient.
  return dbName;
} 