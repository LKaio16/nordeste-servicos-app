import 'package:sembast/sembast.dart';
import '../../../core/db/database_service.dart';
import '../../models/ordem_servico_model.dart';

class OsLocalDataSource {
  final DatabaseService _databaseService;
  final _store = intMapStoreFactory.store('ordens_servico');

  OsLocalDataSource(this._databaseService);

  Future<void> saveOrUpdateOs(OrdemServicoModel os) async {
    final db = await _databaseService.database;
    await _store.record(os.id!).put(db, os.toJson());
  }

  Future<OrdemServicoModel?> getOsById(int id) async {
    final db = await _databaseService.database;
    final record = await _store.record(id).get(db);
    if (record != null) {
      return OrdemServicoModel.fromJson(record);
    }
    return null;
  }

  Future<List<OrdemServicoModel>> getAllOs() async {
    final db = await _databaseService.database;
    final records = await _store.find(db);
    return records.map((snapshot) => OrdemServicoModel.fromJson(snapshot.value)).toList();
  }

  Future<void> deleteOs(int id) async {
    final db = await _databaseService.database;
    await _store.record(id).delete(db);
  }

  Future<void> clearAll() async {
    final db = await _databaseService.database;
    await _store.delete(db);
  }
} 