// lib/data/repositories/equipamento_repository_impl.dart

import 'package:dio/dio.dart';
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

  @override
  Future<Equipamento> createEquipamento(Equipamento equipamento) async {
      try {
        final EquipamentoModel equipamentoModel = EquipamentoModel(
           // ID não é enviado
           tipo: equipamento.tipo,
           marcaModelo: equipamento.marcaModelo,
           numeroSerieChassi: equipamento.numeroSerieChassi,
           horimetro: equipamento.horimetro,
           clienteId: equipamento.clienteId,
        );

      final response = await apiClient.post('/equipamentos', data: equipamentoModel.toJson());

      if (response.statusCode == 201) {
        final Map<String, dynamic> json = response.data;
        final EquipamentoModel createdEquipamentoModel = EquipamentoModel.fromJson(json);
        return createdEquipamentoModel.toEntity();
      } else {
         throw ApiException('Falha ao criar equipamento: Status ${response.statusCode}');
      }
    } on ApiException {
       rethrow;
    } on DioException catch (e) {
        throw ApiException('Erro de rede ao criar equipamento: ${e.message}');
    } catch (e) {
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