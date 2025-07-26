import 'package:connectivity_plus/connectivity_plus.dart';
import '../../data/datasources/local/sync_queue_local_data_source.dart';
import '../../data/models/ordem_servico_model.dart';
import '../network/api_client.dart';
import '../../data/datasources/local/os_local_data_source.dart';
import 'dart:async';

class SyncService {
  final SyncQueueLocalDataSource _syncQueue;
  final OsLocalDataSource _osLocalDataSource;
  final ApiClient _apiClient;
  final Connectivity _connectivity;
  StreamSubscription? _connectivitySubscription;
  bool _isSyncing = false;

  SyncService(this._syncQueue, this._osLocalDataSource, this._apiClient, this._connectivity);

  void start() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        processQueue();
      }
    });
  }

  void dispose() {
    _connectivitySubscription?.cancel();
  }

  Future<void> processQueue() async {
    if (_isSyncing) return;
    _isSyncing = true;

    final queue = await _syncQueue.getQueue();
    for (var item in queue) {
      try {
        switch (item.method) {
          case 'POST':
            final response = await _apiClient.post(item.url, data: item.body);
            if (response.statusCode == 201) {
              final newOs = OrdemServicoModel.fromJson(response.data);
              if (item.tempId != null) {
                await _osLocalDataSource.deleteOs(item.tempId!);
                await _osLocalDataSource.saveOrUpdateOs(newOs);
              }
            }
            break;
          case 'PUT':
            await _apiClient.put(item.url, data: item.body);
            break;
          case 'DELETE':
            await _apiClient.delete(item.url);
            break;
        }
        await _syncQueue.removeFromQueue(item.id!);
      } catch (e) {
        // Handle sync error, maybe log it or retry later
        print('Sync error for item ${item.id}: $e');
      }
    }

    _isSyncing = false;
  }
} 