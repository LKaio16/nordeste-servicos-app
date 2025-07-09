// lib/data/repositories/registro_tempo_repository_impl.dart

import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/error/exceptions.dart';
import '../models/registro_tempo_model.dart';
import '../../domain/entities/registro_tempo.dart';
import '../../domain/repositories/registro_tempo_repository.dart';

class RegistroTempoRepositoryImpl implements RegistroTempoRepository {
  final ApiClient apiClient;

  RegistroTempoRepositoryImpl(this.apiClient);

  @override
  Future<List<RegistroTempo>> getRegistrosTempoByOsId(int osId) async {
    try {
      final response = await apiClient.get('/ordens-servico/$osId/registros-tempo');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data;
        final List<RegistroTempoModel> registroTempoModels = jsonList.map((json) => RegistroTempoModel.fromJson(json)).toList();
        final List<RegistroTempo> registrosTempo = registroTempoModels.map((model) => model.toEntity()).toList();
        return registrosTempo;
      } else {
        throw ApiException('Falha ao carregar registros de tempo da OS ${osId}: Status ${response.statusCode}');
      }
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException('Erro de rede ao carregar registros de tempo da OS ${osId}: ${e.message}');
    } catch (e) {
      throw ApiException('Erro inesperado ao carregar registros de tempo da OS ${osId}: ${e.toString()}');
    }
  }

  @override
  Future<RegistroTempo> getRegistroTempoById(int id) async {
    try {
      final response = await apiClient.get('/registros-tempo/$id');

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = response.data;
        final RegistroTempoModel registroTempoModel = RegistroTempoModel.fromJson(json);
        return registroTempoModel.toEntity();
      } else {
        throw ApiException('Falha ao carregar registro de tempo ${id}: Status ${response.statusCode}');
      }
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException('Erro de rede ao carregar registro de tempo ${id}: ${e.message}');
    } catch (e) {
      throw ApiException('Erro inesperado ao carregar registro de tempo ${id}: ${e.toString()}');
    }
  }

  @override
  Future<RegistroTempo> createRegistroTempo(RegistroTempo registro) async {
    try {
      final RegistroTempoModel registroTempoModel = RegistroTempoModel(
        ordemServicoId: registro.ordemServicoId,
        tecnicoId: registro.tecnicoId,
        tipoServicoId: registro.tipoServicoId,
        horaInicio: registro.horaInicio,
      );
      final response = await apiClient.post('/ordens-servico/${registro.ordemServicoId}/registros-tempo/iniciar', data: registroTempoModel.toJson());

      if (response.statusCode == 201) {
        final Map<String, dynamic> json = response.data;
        final RegistroTempoModel createdRegistroTempoModel = RegistroTempoModel.fromJson(json);
        return createdRegistroTempoModel.toEntity();
      } else {
        throw ApiException('Falha ao criar registro de tempo para OS ${registro.ordemServicoId}: Status ${response.statusCode}');
      }
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException('Erro de rede ao criar registro de tempo para OS ${registro.ordemServicoId}: ${e.message}');
    } catch (e) {
      throw ApiException('Erro inesperado ao criar registro de tempo para OS ${registro.ordemServicoId}: ${e.toString()}');
    }
  }

  @override
  Future<RegistroTempo> finalizarRegistroTempo(int osId, int registroId) async {
    try {
      // **CORREÇÃO APLICADA AQUI**
      // A URL agora inclui o osId, conforme definido no backend.
      final response = await apiClient.put('/ordens-servico/$osId/registros-tempo/$registroId/finalizar');

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = response.data;
        final RegistroTempoModel updatedRegistroTempoModel = RegistroTempoModel.fromJson(json);
        return updatedRegistroTempoModel.toEntity();
      } else {
        throw ApiException('Falha ao finalizar registro de tempo ${registroId}: Status ${response.statusCode}');
      }
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException('Erro de rede ao finalizar registro de tempo ${registroId}: ${e.message}');
    } catch (e) {
      throw ApiException('Erro inesperado ao finalizar registro de tempo ${registroId}: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteRegistroTempo(int id) async {
    try {
      final response = await apiClient.delete('/registros-tempo/$id');

      if (response.statusCode == 204) {
        return;
      } else {
        throw ApiException('Falha ao deletar registro de tempo ${id}: Status ${response.statusCode}');
      }
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException('Erro de rede ao deletar registro de tempo ${id}: ${e.message}');
    } catch (e) {
      throw ApiException('Erro inesperado ao deletar registro de tempo ${id}: ${e.toString()}');
    }
  }
}