import 'package:sembast/sembast.dart';
import '../../../core/db/database_service.dart';
import '../../models/sync_queue_item_model.dart';

class SyncQueueLocalDataSource {
  final DatabaseService _databaseService;
  final _store = intMapStoreFactory.store('sync_queue');

  SyncQueueLocalDataSource(this._databaseService);

  Future<void> addToQueue(SyncQueueItemModel item) async {
    final db = await _databaseService.database;
    await _store.add(db, item.toJson());
  }

  Future<List<SyncQueueItemModel>> getQueue() async {
    final db = await _databaseService.database;
    final records = await _store.find(db);
    return records.map((snapshot) {
      final item = SyncQueueItemModel.fromJson(snapshot.value);
      item.id = snapshot.key; // Assign the database key to the model
      return item;
    }).toList();
  }

  Future<void> removeFromQueue(int id) async {
    final db = await _databaseService.database;
    await _store.record(id).delete(db);
  }
} 