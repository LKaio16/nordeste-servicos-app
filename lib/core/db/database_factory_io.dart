import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

DatabaseFactory getDatabaseFactory() => databaseFactoryIo;

Future<String> getDatabasePath(String dbName) async {
  final appDir = await getApplicationDocumentsDirectory();
  return join(appDir.path, dbName);
} 