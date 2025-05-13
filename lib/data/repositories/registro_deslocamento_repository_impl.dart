// lib/data/repositories/registro_deslocamento_repository_impl.dart

import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/error/exceptions.dart';
import '../models/registro_deslocamento_model.dart';
import '../../domain/entities/registro_deslocamento.dart';
import '../../domain/repositories/registro_deslocamento_repository.dart';

class RegistroDeslocamentoRepositoryImpl implements RegistroDeslocamentoRepository {
  final ApiClient apiClient;

  RegistroDeslocamentoRepositoryImpl(this.apiClient);

  @override
  Future<List<RegistroDeslocamento>> getRegistrosDeslocamentoByOsId(int osId) async {
      try {
      final response = await apiClient.get('/ordens-servico/$osId/registros-deslocamento'); // Endpoint da sua API

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data;
        final List<RegistroDeslocamentoModel> registroDeslocamentoModels = jsonList.map((json) => RegistroDeslocamentoModel.fromJson(json)).toList();
        final List<RegistroDeslocamento> registrosDeslocamento = registroDeslocamentoModels.map((model) => model.toEntity()).toList();
        return registrosDeslocamento;
      } else {
         throw ApiException('Falha ao carregar registros de deslocamento da OS ${osId}: Status ${response.statusCode}');
      }
    } on ApiException {
       rethrow;
    } on DioException catch (e) {
        throw ApiException('Erro de rede ao carregar registros de deslocamento da OS ${osId}: ${e.message}');
    } catch (e) {
       throw ApiException('Erro inesperado ao carregar registros de deslocamento da OS ${osId}: ${e.toString()}');
    }
  }

  @override
  Future<RegistroDeslocamento> getRegistroDeslocamentoById(int id) async {
       try {
      // Assumindo endpoint direto: /registros-deslocamento/{id} ou aninhado /ordens-servico/{osId}/registros-deslocamento/{id}
      final response = await apiClient.get('/registros-deslocamento/$id');

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = response.data;
        final RegistroDeslocamentoModel registroDeslocamentoModel = RegistroDeslocamentoModel.fromJson(json);
        return registroDeslocamentoModel.toEntity();
      } else {
         throw ApiException('Falha ao carregar registro de deslocamento ${id}: Status ${response.statusCode}');
      }
    } on ApiException {
       rethrow;
    } on DioException catch (e) {
        throw ApiException('Erro de rede ao carregar registro de deslocamento ${id}: ${e.message}');
    } catch (e) {
       throw ApiException('Erro inesperado ao carregar registro de deslocamento ${id}: ${e.toString()}');
    }
  }

  @override
  Future<RegistroDeslocamento> createRegistroDeslocamento(RegistroDeslocamento registro) async {
      try {
        // Pode ser necessário criar um DTO/Model específico para criação
         final RegistroDeslocamentoModel registroDeslocamentoModel = RegistroDeslocamentoModel(
            // ID não enviado
            ordemServicoId: registro.ordemServicoId,
            tecnicoId: registro.tecnicoId,
            data: registro.data,
            placaVeiculo: registro.placaVeiculo,
            kmInicial: registro.kmInicial,
            kmFinal: registro.kmFinal, // KM Final pode ser nulo na criação
            saidaDe: registro.saidaDe,
            chegadaEm: registro.chegadaEm, // Chegada Em pode ser nulo na criação
            // totalKm calculado na API
         );

      final response = await apiClient.post('/ordens-servico/${registro.ordemServicoId}/registros-deslocamento', data: registroDeslocamentoModel.toJson());

      if (response.statusCode == 201) {
        final Map<String, dynamic> json = response.data;
        final RegistroDeslocamentoModel createdRegistroDeslocamentoModel = RegistroDeslocamentoModel.fromJson(json);
        return createdRegistroDeslocamentoModel.toEntity();
      } else {
         throw ApiException('Falha ao criar registro de deslocamento para OS ${registro.ordemServicoId}: Status ${response.statusCode}');
      }
    } on ApiException {
       rethrow;
    } on DioException catch (e) {
        throw ApiException('Erro de rede ao criar registro de deslocamento para OS ${registro.ordemServicoId}: ${e.message}');
    } catch (e) {
       throw ApiException('Erro inesperado ao criar registro de deslocamento para OS ${registro.ordemServicoId}: ${e.toString()}');
    }
  }

  @override
  Future<RegistroDeslocamento> updateRegistroDeslocamento(RegistroDeslocamento registro) async {
       try {
         final RegistroDeslocamentoModel registroDeslocamentoModel = RegistroDeslocamentoModel(
            id: registro.id, // Incluir ID
            ordemServicoId: registro.ordemServicoId,
            tecnicoId: registro.tecnicoId,
            data: registro.data,
            placaVeiculo: registro.placaVeiculo,
            kmInicial: registro.kmInicial,
            kmFinal: registro.kmFinal,
            saidaDe: registro.saidaDe,
            chegadaEm: registro.chegadaEm,
            // totalKm calculado na API
         );

      // Assumindo endpoint direto: /registros-deslocamento/{id} ou aninhado /ordens-servico/{osId}/registros-deslocamento/{id}
      final response = await apiClient.put('/registros-deslocamento/${registro.id}', data: registroDeslocamentoModel.toJson());

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = response.data;
        final RegistroDeslocamentoModel updatedRegistroDeslocamentoModel = RegistroDeslocamentoModel.fromJson(json);
        return updatedRegistroDeslocamentoModel.toEntity();
      } else {
         throw ApiException('Falha ao atualizar registro de deslocamento ${registro.id}: Status ${response.statusCode}');
      }
    } on ApiException {
       rethrow;
    } on DioException catch (e) {
        throw ApiException('Erro de rede ao atualizar registro de deslocamento ${registro.id}: ${e.message}');
    } catch (e) {
       throw ApiException('Erro inesperado ao atualizar registro de deslocamento ${registro.id}: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteRegistroDeslocamento(int id) async {
      try {
      // Assumindo endpoint direto: /registros-deslocamento/{id} ou aninhado /ordens-servico/{osId}/registros-deslocamento/{id}
      final response = await apiClient.delete('/registros-deslocamento/$id');

      if (response.statusCode == 204) {
        return;
      } else {
         throw ApiException('Falha ao deletar registro de deslocamento ${id}: Status ${response.statusCode}');
      }
    } on ApiException {
       rethrow;
    } on DioException catch (e) {
        throw ApiException('Erro de rede ao deletar registro de deslocamento ${id}: ${e.message}');
    } catch (e) {
       throw ApiException('Erro inesperado ao deletar registro de deslocamento ${id}: ${e.toString()}');
    }
  }
}