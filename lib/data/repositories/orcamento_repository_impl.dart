// lib/data/repositories/orcamento_repository_impl.dart

import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/error/exceptions.dart';
import '../models/orcamento_model.dart';
import '../models/status_orcamento_model.dart'; // Para usar o enum model no filtro
import '../../domain/entities/orcamento.dart';
import '../../domain/repositories/orcamento_repository.dart';

class OrcamentoRepositoryImpl implements OrcamentoRepository {
  final ApiClient apiClient;

  OrcamentoRepositoryImpl(this.apiClient);

  @override
  Future<List<Orcamento>> getOrcamentos({
    int? clienteId,
    StatusOrcamentoModel? status,
    int? ordemServicoOrigemId,
  }) async {
     try {
      final Map<String, dynamic> queryParameters = {};
      if (clienteId != null) {
        queryParameters['clienteId'] = clienteId;
      }
      if (status != null) {
        queryParameters['status'] = status.name; // Envia o nome do enum como String
      }
      if (ordemServicoOrigemId != null) {
        queryParameters['ordemServicoOrigemId'] = ordemServicoOrigemId;
      }

      final response = await apiClient.get('/orcamentos', queryParameters: queryParameters);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data;
        final List<OrcamentoModel> orcamentoModels = jsonList.map((json) => OrcamentoModel.fromJson(json)).toList();
        final List<Orcamento> orcamentos = orcamentoModels.map((model) => model.toEntity()).toList();
        return orcamentos;
      } else {
         throw ApiException('Falha ao carregar orçamentos: Status ${response.statusCode}');
      }
    } on ApiException {
       rethrow;
    } on DioException catch (e) {
        throw ApiException('Erro de rede ao carregar orçamentos: ${e.message}');
    } catch (e) {
       throw ApiException('Erro inesperado ao carregar orçamentos: ${e.toString()}');
    }
  }

  @override
  Future<Orcamento> getOrcamentoById(int id) async {
     try {
      final response = await apiClient.get('/orcamentos/$id');

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = response.data;
        final OrcamentoModel orcamentoModel = OrcamentoModel.fromJson(json);
        return orcamentoModel.toEntity();
      } else {
         throw ApiException('Falha ao carregar orçamento ${id}: Status ${response.statusCode}');
      }
    } on ApiException {
       rethrow;
    } on DioException catch (e) {
        throw ApiException('Erro de rede ao carregar orçamento ${id}: ${e.message}');
    } catch (e) {
       throw ApiException('Erro inesperado ao carregar orçamento ${id}: ${e.toString()}');
    }
  }

  @override
  Future<Orcamento> createOrcamento(Orcamento orcamento) async {
      try {
        // Pode ser necessário criar um DTO/Model específico para criação,
        // dependendo de como a API espera receber os dados.
        // Assumindo que o modelo gerado pode ser usado.
         final OrcamentoModel orcamentoModel = OrcamentoModel(
            // ID não enviado
            numeroOrcamento: orcamento.numeroOrcamento, // Pode ser gerado na API
            dataCriacao: orcamento.dataCriacao, // Pode ser gerado na API
            dataValidade: orcamento.dataValidade,
            status: orcamento.status,
            clienteId: orcamento.clienteId,
            ordemServicoOrigemId: orcamento.ordemServicoOrigemId,
            observacoesCondicoes: orcamento.observacoesCondicoes,
            valorTotal: orcamento.valorTotal, // Pode ser calculado na API
         );

      final response = await apiClient.post('/orcamentos', data: orcamentoModel.toJson());

      if (response.statusCode == 201) {
        final Map<String, dynamic> json = response.data;
        final OrcamentoModel createdOrcamentoModel = OrcamentoModel.fromJson(json);
        return createdOrcamentoModel.toEntity();
      } else {
         throw ApiException('Falha ao criar orçamento: Status ${response.statusCode}');
      }
    } on ApiException {
       rethrow;
    } on DioException catch (e) {
        throw ApiException('Erro de rede ao criar orçamento: ${e.message}');
    } catch (e) {
       throw ApiException('Erro inesperado ao criar orçamento: ${e.toString()}');
    }
  }

  @override
  Future<Orcamento> updateOrcamento(Orcamento orcamento) async {
       try {
         final OrcamentoModel orcamentoModel = OrcamentoModel(
            id: orcamento.id, // Incluir ID
            numeroOrcamento: orcamento.numeroOrcamento,
            dataCriacao: orcamento.dataCriacao,
            dataValidade: orcamento.dataValidade,
            status: orcamento.status,
            clienteId: orcamento.clienteId,
            ordemServicoOrigemId: orcamento.ordemServicoOrigemId,
            observacoesCondicoes: orcamento.observacoesCondicoes,
            valorTotal: orcamento.valorTotal,
         );

      final response = await apiClient.put('/orcamentos/${orcamento.id}', data: orcamentoModel.toJson());

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = response.data;
        final OrcamentoModel updatedOrcamentoModel = OrcamentoModel.fromJson(json);
        return updatedOrcamentoModel.toEntity();
      } else {
         throw ApiException('Falha ao atualizar orçamento ${orcamento.id}: Status ${response.statusCode}');
      }
    } on ApiException {
       rethrow;
    } on DioException catch (e) {
        throw ApiException('Erro de rede ao atualizar orçamento ${orcamento.id}: ${e.message}');
    } catch (e) {
       throw ApiException('Erro inesperado ao atualizar orçamento ${orcamento.id}: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteOrcamento(int id) async {
       try {
      final response = await apiClient.delete('/orcamentos/$id');

      if (response.statusCode == 204) {
        return;
      } else {
         throw ApiException('Falha ao deletar orçamento ${id}: Status ${response.statusCode}');
      }
    } on ApiException {
       rethrow;
    } on DioException catch (e) {
        throw ApiException('Erro de rede ao deletar orçamento ${id}: ${e.message}');
    } catch (e) {
       throw ApiException('Erro inesperado ao deletar orçamento ${id}: ${e.toString()}');
    }
  }
}