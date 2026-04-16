// lib/data/repositories/orcamento_repository_impl.dart


import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // Import for kDebugMode
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
  Future<Map<String, dynamic>> getOrcamentosListagem({
    int? clienteId,
    StatusOrcamentoModel? status,
    int? ordemServicoOrigemId,
    String? searchTerm,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final Map<String, dynamic> queryParameters = {
        'page': page,
        'size': size,
      };
      if (clienteId != null) queryParameters['clienteId'] = clienteId;
      if (status != null) queryParameters['status'] = status.name;
      if (ordemServicoOrigemId != null) queryParameters['ordemServicoOrigemId'] = ordemServicoOrigemId;
      if (searchTerm != null && searchTerm.isNotEmpty) queryParameters['searchTerm'] = searchTerm;

      final response = await apiClient.get('/orcamentos/paged', queryParameters: queryParameters);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data as Map<String, dynamic>;
        final List<dynamic> content = (data['content'] as List<dynamic>? ?? []);
        final List<Orcamento> orcamentos = content.map((item) {
          final json = item as Map<String, dynamic>;
          final statusValue = StatusOrcamentoModel.values.firstWhere(
            (s) => s.name == (json['status'] as String? ?? 'PENDENTE'),
            orElse: () => StatusOrcamentoModel.PENDENTE,
          );
          return Orcamento(
            id: json['id'] as int?,
            numeroOrcamento: (json['numeroOrcamento'] as String?) ?? '',
            dataCriacao: DateTime.now(),
            dataValidade: json['dataValidade'] != null
                ? DateTime.tryParse(json['dataValidade'] as String) ?? DateTime.now()
                : DateTime.now(),
            status: statusValue,
            clienteId: 0,
            nomeCliente: json['nomeCliente'] as String?,
            valorTotal: (json['valorTotal'] as num?)?.toDouble(),
          );
        }).toList();

        return {
          'content': orcamentos,
          'totalElements': (data['totalElements'] as num?)?.toInt() ?? 0,
          'hasNext': data['hasNext'] == true,
          'page': (data['page'] as num?)?.toInt() ?? page,
          'size': (data['size'] as num?)?.toInt() ?? size,
        };
      }
      throw ApiException('Falha ao carregar listagem paginada de orçamentos: Status ${response.statusCode}');
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException('Erro de rede ao carregar listagem paginada de orçamentos: ${e.message}');
    } catch (e) {
      throw ApiException('Erro inesperado ao carregar listagem paginada de orçamentos: ${e.toString()}');
    }
  }

  @override
  Future<List<Orcamento>> getOrcamentos({
    int? clienteId,
    StatusOrcamentoModel? status,
    int? ordemServicoOrigemId,
    String? searchTerm,
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
      if (searchTerm != null && searchTerm.isNotEmpty) {
        queryParameters['searchTerm'] = searchTerm;
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

  @override
  Future<Uint8List> downloadOrcamentoPdf(int orcamentoId) async {
    try {
      final response = await apiClient.get(
        '/orcamentos/$orcamentoId/pdf',
        options: Options(responseType: ResponseType.bytes), // Essencial para receber bytes
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

  @override
  Future<Map<String, int>> getDashboardStats() async {
    try {
      final response = await apiClient.get('/orcamentos/dashboard/stats');
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data as Map<String, dynamic>;
        int toInt(dynamic value) => (value is num) ? value.toInt() : 0;
        return {
          'totalOrcamentos': toInt(data['totalOrcamentos']),
          'orcamentosAprovados': toInt(data['orcamentosAprovados']),
          'orcamentosRejeitados': toInt(data['orcamentosRejeitados']),
        };
      }
      throw ApiException('Falha ao carregar estatísticas de orçamentos: Status ${response.statusCode}');
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException('Erro de rede ao carregar estatísticas de orçamentos: ${e.message}');
    } catch (e) {
      throw ApiException('Erro inesperado ao carregar estatísticas de orçamentos: ${e.toString()}');
    }
  }
}