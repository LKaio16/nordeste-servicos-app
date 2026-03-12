// lib/data/repositories/nota_fiscal_repository_impl.dart

import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/error/exceptions.dart';
import '../models/nota_fiscal_model.dart';
import '../../domain/entities/nota_fiscal.dart';
import '../../domain/repositories/nota_fiscal_repository.dart';

class NotaFiscalRepositoryImpl implements NotaFiscalRepository {
  final ApiClient apiClient;

  NotaFiscalRepositoryImpl(this.apiClient);

  @override
  Future<List<NotaFiscal>> getNotasFiscais({
    int? fornecedorId,
    int? clienteId,
    String? tipo,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (fornecedorId != null) queryParams['fornecedorId'] = fornecedorId;
      if (clienteId != null) queryParams['clienteId'] = clienteId;
      if (tipo != null && tipo.isNotEmpty) queryParams['tipo'] = tipo;

      final response = await apiClient.get(
        '/notas-fiscais',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data;
        return jsonList.map((json) => NotaFiscalModel.fromJson(json).toEntity()).toList();
      } else {
        throw ApiException('Falha ao carregar notas fiscais: Status ${response.statusCode}');
      }
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException('Erro de rede ao carregar notas fiscais: ${e.message}');
    } catch (e) {
      throw ApiException('Erro inesperado ao carregar notas fiscais: ${e.toString()}');
    }
  }

  @override
  Future<NotaFiscal> getNotaFiscalById(int id) async {
    try {
      final response = await apiClient.get('/notas-fiscais/$id');
      if (response.statusCode == 200) {
        return NotaFiscalModel.fromJson(response.data).toEntity();
      } else {
        throw ApiException('Falha ao carregar nota fiscal $id: Status ${response.statusCode}');
      }
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException('Erro de rede ao carregar nota fiscal: ${e.message}');
    } catch (e) {
      throw ApiException('Erro inesperado ao carregar nota fiscal: ${e.toString()}');
    }
  }

  @override
  Future<NotaFiscal> createNotaFiscal(NotaFiscal notaFiscal) async {
    try {
      final data = <String, dynamic>{
        'tipo': notaFiscal.tipo ?? 'ENTRADA',
        'dataEmissao': notaFiscal.dataEmissao?.toIso8601String().split('T').first ?? DateTime.now().toIso8601String().split('T').first,
        'numeroNota': notaFiscal.numeroNota ?? '',
        'valorTotal': notaFiscal.valorTotal ?? 0.0,
      };
      if (notaFiscal.fornecedorId != null) data['fornecedorId'] = notaFiscal.fornecedorId;
      if (notaFiscal.clienteId != null) data['clienteId'] = notaFiscal.clienteId;
      if (notaFiscal.nomeEmitente != null && notaFiscal.nomeEmitente!.isNotEmpty) data['nomeEmitente'] = notaFiscal.nomeEmitente;
      if (notaFiscal.cnpjEmitente != null && notaFiscal.cnpjEmitente!.isNotEmpty) data['cnpjEmitente'] = notaFiscal.cnpjEmitente;
      if (notaFiscal.formaPagamento != null && notaFiscal.formaPagamento!.isNotEmpty) data['formaPagamento'] = notaFiscal.formaPagamento;
      if (notaFiscal.descricao != null && notaFiscal.descricao!.isNotEmpty) data['descricao'] = notaFiscal.descricao;
      if (notaFiscal.observacoes != null && notaFiscal.observacoes!.isNotEmpty) data['observacoes'] = notaFiscal.observacoes;

      final response = await apiClient.post('/notas-fiscais', data: data);
      if (response.statusCode == 201) {
        return NotaFiscalModel.fromJson(response.data).toEntity();
      } else {
        throw ApiException('Falha ao criar nota fiscal: Status ${response.statusCode}');
      }
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException('Erro de rede ao criar nota fiscal: ${e.message}');
    } catch (e) {
      throw ApiException('Erro inesperado ao criar nota fiscal: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteNotaFiscal(int id) async {
    try {
      final response = await apiClient.delete('/notas-fiscais/$id');
      if (response.statusCode != 204) {
        throw ApiException('Falha ao excluir nota fiscal: Status ${response.statusCode}');
      }
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException('Erro de rede ao excluir nota fiscal: ${e.message}');
    } catch (e) {
      throw ApiException('Erro inesperado ao excluir nota fiscal: ${e.toString()}');
    }
  }
}
