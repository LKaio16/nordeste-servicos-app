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
      final response = await apiClient.get('/ordens-servico/$osId/registros-tempo'); // Endpoint da sua API

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
      // Assumindo endpoint direto: /registros-tempo/{id} ou aninhado /ordens-servico/{osId}/registros-tempo/{id}
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
        // Pode ser necessário criar um DTO/Model específico para criação,
        // pois a hora de término e horas trabalhadas não são enviadas na criação.
         final RegistroTempoModel registroTempoModel = RegistroTempoModel(
            // ID não enviado
            ordemServicoId: registro.ordemServicoId,
            tecnicoId: registro.tecnicoId,
            tipoServicoId: registro.tipoServicoId,
            horaInicio: registro.horaInicio, // Hora início geralmente vem da API na resposta
            // horaTermino e horasTrabalhadas não enviados
         );

      final response = await apiClient.post('/ordens-servico/${registro.ordemServicoId}/registros-tempo', data: registroTempoModel.toJson());

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
  Future<RegistroTempo> finalizarRegistroTempo(int id) async {
       try {
      // Assumindo um endpoint específico para finalizar um registro de tempo
      final response = await apiClient.put('/registros-tempo/$id/finalizar'); // Ajuste o endpoint conforme sua API

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = response.data;
        final RegistroTempoModel updatedRegistroTempoModel = RegistroTempoModel.fromJson(json);
        return updatedRegistroTempoModel.toEntity();
      } else {
         throw ApiException('Falha ao finalizar registro de tempo ${id}: Status ${response.statusCode}');
      }
    } on ApiException {
       rethrow;
    } on DioException catch (e) {
        throw ApiException('Erro de rede ao finalizar registro de tempo ${id}: ${e.message}');
    } catch (e) {
       throw ApiException('Erro inesperado ao finalizar registro de tempo ${id}: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteRegistroTempo(int id) async {
      try {
      // Assumindo endpoint direto: /registros-tempo/{id} ou aninhado /ordens-servico/{osId}/registros-tempo/{id}
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