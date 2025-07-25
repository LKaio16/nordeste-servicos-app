// lib/data/repositories/os_repository_impl.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // Import for kDebugMode
import '../../core/network/api_client.dart';
import '../../core/error/exceptions.dart';
import '../models/ordem_servico_model.dart'; // Importe o modelo de dados
import '../../domain/entities/ordem_servico.dart'; // Importe a entidade de domínio
import '../../domain/repositories/os_repository.dart'; // Importe a interface do repositório
import '../../data/models/status_os_model.dart'; // Para usar o enum como parâmetro
import '../models/prioridade_os_model.dart';
import '../datasources/local/os_local_data_source.dart';
import '../datasources/local/sync_queue_local_data_source.dart';
import '../models/sync_queue_item_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';



class OsRepositoryImpl implements OsRepository {
  final ApiClient apiClient;
  final OsLocalDataSource localDataSource;
  final SyncQueueLocalDataSource syncQueue;
  final Connectivity connectivity;

  OsRepositoryImpl(this.apiClient, this.localDataSource, this.syncQueue, this.connectivity);

  @override
  Future<List<OrdemServico>> getOrdensServico({
    String? searchTerm,
    int? clienteId,
    int? tecnicoId,
    StatusOSModel? status,
    DateTime? dataAgendamento, // Adicionado
  }) async {
    try {
      // Verifica se há internet
      final hasInternet = await connectivity.checkConnectivity() != ConnectivityResult.none;
      
      if (!hasInternet) {
        // Se não há internet, filtra os dados locais pelos parâmetros fornecidos
        final localOs = await localDataSource.getAllOs();
        if (localOs.isNotEmpty) {
          var filteredOs = localOs;
          
          // Aplica filtros nos dados locais
          if (tecnicoId != null) {
            filteredOs = filteredOs.where((os) => os.tecnicoAtribuidoModel?.id == tecnicoId).toList();
          }
          if (clienteId != null) {
            filteredOs = filteredOs.where((os) => os.cliente.id == clienteId).toList();
          }
          if (status != null) {
            filteredOs = filteredOs.where((os) => os.status == status).toList();
          }
          if (searchTerm != null && searchTerm.isNotEmpty) {
            filteredOs = filteredOs.where((os) => 
              os.numeroOS.toLowerCase().contains(searchTerm.toLowerCase()) ||
              os.cliente.nomeCompleto.toLowerCase().contains(searchTerm.toLowerCase())
            ).toList();
          }
          
          return filteredOs.map((model) => model.toEntity()).toList();
        }
      }

      final Map<String, dynamic> queryParameters = {};
      if (searchTerm != null && searchTerm.isNotEmpty) queryParameters['searchTerm'] = searchTerm;
      if (clienteId != null) queryParameters['clienteId'] = clienteId;
      if (tecnicoId != null) queryParameters['tecnicoId'] = tecnicoId;
      if (status != null) queryParameters['status'] = status.name;
      if (dataAgendamento != null) queryParameters['dataAgendamento'] = dataAgendamento.toIso8601String(); // Adicionado

      final response = await apiClient.get('/ordens-servico', queryParameters: queryParameters);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data;
        final List<OrdemServicoModel> osModels = jsonList.map((json) => OrdemServicoModel.fromJson(json)).toList();

        // Cache the results
        await localDataSource.clearAll();
        for (var os in osModels) {
          await localDataSource.saveOrUpdateOs(os);
        }

        return osModels.map((model) => model.toEntity()).toList();
      } else {
        throw ApiException('Falha ao carregar ordens de serviço: Status ${response.statusCode}');
      }
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException('Erro de rede ao carregar ordens de serviço: ${e.message}');
    } catch (e) {
      throw ApiException('Erro inesperado ao carregar ordens de serviço: ${e.toString()}');
    }
  }

  @override
  Future<OrdemServico> getOrdemServicoById(int osId) async {
    final hasInternet = await connectivity.checkConnectivity() != ConnectivityResult.none;

    if (hasInternet) {
      try {
        final response = await apiClient.get('/ordens-servico/$osId');

        if (response.statusCode == 200) {
          final Map<String, dynamic> json = response.data;
          final OrdemServicoModel osModel = OrdemServicoModel.fromJson(json);
          // Cache the fresh result
          await localDataSource.saveOrUpdateOs(osModel);
          return osModel.toEntity();
        } else {
          // If network fails, try to fall back to cache
          final localOs = await localDataSource.getOsById(osId);
          if (localOs != null) {
            return localOs.toEntity();
          }
          throw ApiException('Falha ao carregar ordem de serviço $osId: Status ${response.statusCode}');
        }
      } on ApiException {
        rethrow;
      } on DioException catch (e) {
         // If network fails, try to fall back to cache
        final localOs = await localDataSource.getOsById(osId);
        if (localOs != null) {
          return localOs.toEntity();
        }
        throw ApiException('Erro de rede ao carregar ordem de serviço $osId: ${e.message}');
      } catch (e) {
        throw ApiException('Erro inesperado ao carregar ordem de serviço $osId: ${e.toString()}');
      }
    } else {
      // Se não houver internet, vá direto para o cache local
      final localOs = await localDataSource.getOsById(osId);
      if (localOs != null) {
        return localOs.toEntity();
      } else {
        throw Exception(
            'Dispositivo offline e sem dados de OS em cache.');
      }
    }
  }

  @override
  Future<OrdemServico> createOrdemServico(OrdemServico ordemServico) async {
    try {
      // CONVERTE A ENTIDADE OrdemServico PARA OrdemServicoModel
      // É AQUI QUE O PROBLEMA ESTÁ, PRECISAMOS GARANTIR QUE tecnicoAtribuido É UM UsuarioModel
      final OrdemServicoModel osModel = OrdemServicoModel.fromEntity(ordemServico);

      // DEBUG: Verifique o JSON que será enviado
      if (kDebugMode) {
        print('JSON sendo enviado para createOrdemServico: ${osModel.toJson()}');
      }

      // Check connectivity
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        // Offline: save to sync queue and local db with temporary ID
        final tempOs = osModel.copyWith(id: DateTime.now().millisecondsSinceEpoch * -1);
        await localDataSource.saveOrUpdateOs(tempOs);
        await syncQueue.addToQueue(
          SyncQueueItemModel(
            url: '/ordens-servico',
            method: 'POST',
            body: osModel.toJson(),
            timestamp: DateTime.now().millisecondsSinceEpoch,
            tempId: tempOs.id,
          ),
        );
        return tempOs.toEntity();
      }

      final response = await apiClient.post('/ordens-servico', data: osModel.toJson());

      if (response.statusCode == 201) {
        final Map<String, dynamic> json = response.data;
        final OrdemServicoModel createdOsModel = OrdemServicoModel.fromJson(json);
        // Cache the new OS
        await localDataSource.saveOrUpdateOs(createdOsModel);
        return createdOsModel.toEntity();
      } else {
        throw ApiException('Falha ao criar Ordem de Serviço: Status ${response.statusCode}');
      }
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      if (e.response != null) {
        throw ApiException('Erro da API ao criar OS: ${e.response!.data.toString()}');
      }
      throw ApiException('Erro de rede ao criar OS: ${e.message}');
    } catch (e) {
      throw ApiException('Erro inesperado ao criar OS: ${e.toString()}');
    }
  }

  @override
  Future<void> updateOrdemServico({
    required int osId,
    required int clienteId,
    required int equipamentoId,
    int? tecnicoAtribuidoId, // Continua recebendo o ID aqui
    required String problemaRelatado,
    String? analiseFalha,
    String? solucaoAplicada,
    required StatusOSModel status,
    PrioridadeOSModel? prioridade,
    DateTime? dataAgendamento,
  }) async {
    try {
      final Map<String, dynamic> requestData = {
        'clienteId': clienteId,
        'equipamentoId': equipamentoId,
        'problemaRelatado': problemaRelatado,
        'status': status.name,
        'prioridade': prioridade?.name,
        'dataAgendamento': dataAgendamento?.toIso8601String(),
        'analiseFalha': analiseFalha,
        'solucaoAplicada': solucaoAplicada,
      };

      // *** MUDANÇA AQUI: Condicionalmente, adicione o objeto tecnicoAtribuido ***
      if (tecnicoAtribuidoId != null) {
        requestData['tecnicoAtribuido'] = {'id': tecnicoAtribuidoId};
      } else {
        // Se tecnicoAtribuidoId for nulo, e você quer explicitamente desatribuir
        // ou permitir que o backend defina como nulo, você pode enviar:
        requestData['tecnicoAtribuido'] = null;
        // Ou, se você quer que o backend ignore o campo se for nulo,
        // apenas não o adicione ao mapa, e o `removeWhere` abaixo cuidará disso.
      }


      // Remove chaves com valores nulos para um PATCH mais limpo, se sua API suporta
      // Atenção: O `tecnicoAtribuido: null` será removido se esta linha for executada antes
      // de decidir enviar `null` para desatribuir. Se sua API espera 'tecnicoAtribuido': null
      // para desatribuição explícita, ajuste a ordem ou a condição.
      requestData.removeWhere((key, value) => value == null);

      if (kDebugMode) {
        print('JSON sendo enviado para updateOrdemServico: $requestData');
      }

       // Check connectivity
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        // Offline: update local db and add to sync queue
        final osToUpdate = await localDataSource.getOsById(osId);
        if (osToUpdate != null) {
          // This is a simplified update. A real implementation might need more complex merging logic.
          final updatedOs = osToUpdate.copyWith(
            status: status,
            analiseFalha: analiseFalha ?? osToUpdate.analiseFalha,
            solucaoAplicada: solucaoAplicada ?? osToUpdate.solucaoAplicada,
          );
          await localDataSource.saveOrUpdateOs(updatedOs);
          // Return the locally updated entity
          return;
        }
        await syncQueue.addToQueue(
          SyncQueueItemModel(
            url: '/ordens-servico/$osId',
            method: 'PUT',
            body: requestData,
            timestamp: DateTime.now().millisecondsSinceEpoch,
          ),
        );
        return;
      }

      final response = await apiClient.put(
        '/ordens-servico/$osId',
        data: requestData,
      );

      if (response.statusCode == 200) {
        // After update, fetch the updated OS and cache it
        final updatedOs = await getOrdemServicoById(osId);
        final osModel = OrdemServicoModel.fromEntity(updatedOs);
        await localDataSource.saveOrUpdateOs(osModel);
        return;
      } else {
        throw ApiException('Falha ao atualizar ordem de serviço $osId: Status ${response.statusCode}');
      }
    } on ApiException {
      rethrow;
    } on DioException catch (e, stackTrace) {
      String errorMessage = 'Erro de rede ao atualizar ordem de serviço $osId.';
      if (e.response != null) {
        errorMessage = 'Falha ao atualizar OS (Status ${e.response?.statusCode}): ';
        if (e.response?.data is String) {
          errorMessage += e.response!.data;
        }
        else if (e.response?.data is Map<String, dynamic>) {
          final responseData = e.response!.data as Map<String, dynamic>;
          errorMessage += responseData['message'] ?? responseData['error'] ?? responseData.toString();
        } else {
          errorMessage += e.response!.data.toString();
        }
      } else {
        errorMessage = 'Erro de conexão ao atualizar OS: ${e.message}';
      }
      if (kDebugMode) {
        print('*******************************************');
        print('*** ERRO DioException em updateOrdemServico ***');
        print('Mensagem: $errorMessage');
        print('Erro Original: ${e.error}');
        print('Tipo do Erro: ${e.type}');
        print('Resposta da API (data): ${e.response?.data}');
        print('Stack Trace:');
        print(stackTrace);
        print('*******************************************');
      }
      throw ApiException(errorMessage);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('*******************************************');
        print('*** ERRO Geral em updateOrdemServico ***');
        print('Erro: ${e.toString()}');
        print('Tipo do Erro: ${e.runtimeType}');
        print('Stack Trace:');
        print(stackTrace);
        print('*******************************************');
      }
      throw ApiException('Erro inesperado ao atualizar ordem de serviço $osId: ${e.toString()}');
    }
  }


  @override
  Future<void> deleteOrdemServico(int id) async {
    try {
       // Check connectivity
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        // Offline: delete from local db and add to sync queue
        await localDataSource.deleteOs(id);
        await syncQueue.addToQueue(
          SyncQueueItemModel(
            url: '/ordens-servico/$id',
            method: 'DELETE',
            body: {},
            timestamp: DateTime.now().millisecondsSinceEpoch,
          ),
        );
        return;
      }
      final response = await apiClient.delete('/ordens-servico/$id');

      if (response.statusCode == 204) {
        // Also delete from local cache
        await localDataSource.deleteOs(id);
        return;
      } else {
        throw ApiException('Falha ao deletar ordem de serviço $id: Status ${response.statusCode}');
      }
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException('Erro de rede ao deletar ordem de serviço $id: ${e.message}');
    } catch (e) {
      throw ApiException('Erro inesperado ao deletar ordem de serviço $id: ${e.toString()}');
    }
  }

  @override
  Future<String?> getNextOsNumber() async {
    try {
      final response = await apiClient.get('/ordens-servico/next-number');

      if (response.statusCode == 200) {
        if (response.data is String) {
          return response.data as String?;
        } else {
          if (kDebugMode) {
            print("WARN: getNextOsNumber recebeu tipo inesperado (${response.data.runtimeType}), tentando converter para String.");
          }
          return response.data?.toString();
        }
      } else {
        if (kDebugMode) {
          print("WARN: Falha ao obter próximo número da OS: Status ${response.statusCode}, Resposta: ${response.data}");
        }
        return null;
      }
    } on DioException catch (e, stackTrace) {
      if (kDebugMode) {
        print('*******************************************');
        print('*** ERRO DioException em getNextOsNumber ***');
        print('Mensagem: ${e.message}');
        print('Erro Original: ${e.error}');
        print('Tipo do Erro: ${e.type}');
        print('Resposta da API (data): ${e.response?.data}');
        print('Stack Trace:');
        print(stackTrace);
        print('*******************************************');
      }
      return null;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('*******************************************');
        print('*** ERRO Geral em getNextOsNumber ***');
        print('Erro: ${e.toString()}');
        print('Tipo do Erro: ${e.runtimeType}');
        print('Stack Trace:');
        print(stackTrace);
        print('*******************************************');
      }
      return null;
    }
  }

  @override
  Future<void> updateOrdemServicoStatus(int id, StatusOSModel status) async {
    try {
      // Check connectivity
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        // Offline: update local db and add to sync queue
        final osToUpdate = await localDataSource.getOsById(id);
        if (osToUpdate != null) {
          final updatedOs = osToUpdate.copyWith(status: status);
          await localDataSource.saveOrUpdateOs(updatedOs);
        }
        await syncQueue.addToQueue(
          SyncQueueItemModel(
            url: '/ordens-servico/$id/status',
            method: 'PATCH',
            body: {'status': status.name},
            timestamp: DateTime.now().millisecondsSinceEpoch,
          ),
        );
        return;
      }

      // O backend espera um objeto com uma chave "status"
      final response = await apiClient.patch(
        '/ordens-servico/$id/status',
        data: {'status': status.name},
      );

      if (response.statusCode != 200) {
        throw ApiException(
            'Falha ao atualizar o status da OS $id: Status ${response.statusCode}');
      }
      // Update local cache on success
      final updatedOs = await getOrdemServicoById(id);
      final osModel = OrdemServicoModel.fromEntity(updatedOs);
      await localDataSource.saveOrUpdateOs(osModel);

    } on DioException catch (e) {
      throw ApiException(
          'Erro de rede ao atualizar o status da OS $id: ${e.message}');
    } catch (e) {
      throw ApiException(
          'Erro inesperado ao atualizar o status da OS $id: ${e.toString()}');
    }
  }

  @override
  Future<Uint8List> downloadOsPdf(int osId) async {
    try {
      final response = await apiClient.get(
        '/ordens-servico/$osId/pdf',
        // ESSENCIAL: Define o tipo de resposta esperado como bytes
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode == 200) {
        return response.data as Uint8List;
      } else {
        throw ApiException('Falha ao baixar o PDF: Status ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw ApiException('Erro de rede ao baixar o PDF: ${e.message}');
    } catch (e) {
      throw ApiException('Erro inesperado ao baixar o PDF: ${e.toString()}');
    }
  }
}