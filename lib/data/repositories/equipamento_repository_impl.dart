// lib/data/repositories/equipamento_repository_impl.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../core/network/api_client.dart';
import '../../core/error/exceptions.dart';
import '../models/equipamento_model.dart';
import '../../domain/entities/equipamento.dart';
import '../../domain/repositories/equipamento_repository.dart';

class EquipamentoRepositoryImpl implements EquipamentoRepository {
  final ApiClient apiClient;

  EquipamentoRepositoryImpl(this.apiClient);

  @override
  Future<List<Equipamento>> getEquipamentos({int? clienteId}) async {
     try {
      final Map<String, dynamic> queryParameters = {};
      if (clienteId != null) {
        queryParameters['clienteId'] = clienteId;
      }

      final response = await apiClient.get('/equipamentos', queryParameters: queryParameters);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data;
        final List<EquipamentoModel> equipamentoModels = jsonList.map((json) => EquipamentoModel.fromJson(json)).toList();
        final List<Equipamento> equipamentos = equipamentoModels.map((model) => model.toEntity()).toList();
        return equipamentos;
      } else {
         throw ApiException('Falha ao carregar equipamentos: Status ${response.statusCode}');
      }
    } on ApiException {
       rethrow;
    } on DioException catch (e) {
        throw ApiException('Erro de rede ao carregar equipamentos: ${e.message}');
    } catch (e) {
       throw ApiException('Erro inesperado ao carregar equipamentos: ${e.toString()}');
    }
  }

  @override
  Future<Equipamento> getEquipamentoById(int id) async {
     try {
      final response = await apiClient.get('/equipamentos/$id');

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = response.data;
        final EquipamentoModel equipamentoModel = EquipamentoModel.fromJson(json);
        return equipamentoModel.toEntity();
      } else {
         throw ApiException('Falha ao carregar equipamento ${id}: Status ${response.statusCode}');
      }
    } on ApiException {
       rethrow;
    } on DioException catch (e) {
        throw ApiException('Erro de rede ao carregar equipamento ${id}: ${e.message}');
    } catch (e) {
       throw ApiException('Erro inesperado ao carregar equipamento ${id}: ${e.toString()}');
    }
  }

// lib/data/repositories/equipamento_repository_impl.dart

  @override
  Future<Equipamento> createEquipamento(Equipamento equipamento) async {
    try {
      // Use the fromEntity factory constructor for proper conversion
      final EquipamentoModel equipamentoModel = EquipamentoModel.fromEntity(equipamento);

      // DEBUG: Verifique o JSON que será enviado (muito útil para depuração)
      if (kDebugMode) {
        print('JSON sendo enviado para createEquipamento: ${equipamentoModel.toJson()}');
      }

      final response = await apiClient.post('/equipamentos', data: equipamentoModel.toJson());

      if (response.statusCode == 201 || response.statusCode == 200) { // Backend might return 200 OK for successful creation too
        final Map<String, dynamic> json = response.data;
        final EquipamentoModel createdEquipamentoModel = EquipamentoModel.fromJson(json);
        return createdEquipamentoModel.toEntity();
      } else {
        // Provide more specific error details from the response if available
        String errorMessage = 'Falha ao criar equipamento: Status ${response.statusCode}';
        if (response.data != null && response.data is Map && (response.data as Map).containsKey('message')) {
          errorMessage += ' - Mensagem: ${(response.data as Map)['message']}';
        }
        throw ApiException(errorMessage);
      }
    } on ApiException {
      rethrow;
    } on DioException catch (e, stackTrace) { // Add stackTrace for better debugging
      // Enhanced error logging for DioException
      if (kDebugMode) {
        print('*******************************************');
        print('*** ERRO DioException em createEquipamento ***');
        print('URI: ${e.requestOptions.uri}');
        print('Mensagem: ${e.message}');
        print('Status Code: ${e.response?.statusCode}');
        print('Response Data: ${e.response?.data}');
        print('Stack Trace:');
        print(stackTrace);
        print('*******************************************');
      }
      String userFacingMessage = 'Erro de rede ao criar equipamento. Verifique sua conexão ou tente novamente.';
      if (e.response?.data != null && e.response!.data is Map && (e.response!.data as Map).containsKey('message')) {
        userFacingMessage = (e.response!.data as Map)['message'];
      } else if (e.message != null && e.message!.isNotEmpty) {
        userFacingMessage = e.message!;
      }
      throw ApiException(userFacingMessage);
    } catch (e, stackTrace) { // Add stackTrace for better debugging
      // General unexpected error
      if (kDebugMode) {
        print('*******************************************');
        print('*** ERRO Inesperado em createEquipamento ***');
        print('Erro: ${e.toString()}');
        print('Tipo do Erro: ${e.runtimeType}');
        print('Stack Trace:');
        print(stackTrace);
        print('*******************************************');
      }
      throw ApiException('Erro inesperado ao criar equipamento: ${e.toString()}');
    }
  }

  @override
  Future<Equipamento> updateEquipamento(Equipamento equipamento) async {
       try {
         final EquipamentoModel equipamentoModel = EquipamentoModel(
            id: equipamento.id, // Incluir ID
           tipo: equipamento.tipo,
           marcaModelo: equipamento.marcaModelo,
           numeroSerieChassi: equipamento.numeroSerieChassi,
           horimetro: equipamento.horimetro,
           clienteId: equipamento.clienteId,
        );

      final response = await apiClient.put('/equipamentos/${equipamento.id}', data: equipamentoModel.toJson());

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = response.data;
        final EquipamentoModel updatedEquipamentoModel = EquipamentoModel.fromJson(json);
        return updatedEquipamentoModel.toEntity();
      } else {
         throw ApiException('Falha ao atualizar equipamento ${equipamento.id}: Status ${response.statusCode}');
      }
    } on ApiException {
       rethrow;
    } on DioException catch (e) {
        throw ApiException('Erro de rede ao atualizar equipamento ${equipamento.id}: ${e.message}');
    } catch (e) {
       throw ApiException('Erro inesperado ao atualizar equipamento ${equipamento.id}: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteEquipamento(int id) async {
       try {
      final response = await apiClient.delete('/equipamentos/$id');

      if (response.statusCode == 204) {
        return;
      } else {
         throw ApiException('Falha ao deletar equipamento ${id}: Status ${response.statusCode}');
      }
    } on ApiException {
       rethrow;
    } on DioException catch (e) {
        throw ApiException('Erro de rede ao deletar equipamento ${id}: ${e.message}');
    } catch (e) {
       throw ApiException('Erro inesperado ao deletar equipamento ${id}: ${e.toString()}');
    }
  }
}