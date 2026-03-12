// lib/data/repositories/conta_repository_impl.dart

import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/error/exceptions.dart';
import '../models/conta_model.dart';
import '../../domain/entities/conta.dart';
import '../../domain/repositories/conta_repository.dart';

class ContaRepositoryImpl implements ContaRepository {
  final ApiClient apiClient;

  ContaRepositoryImpl(this.apiClient);

  @override
  Future<List<Conta>> getContas({
    int? clienteId,
    int? fornecedorId,
    String? tipo,
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (clienteId != null) queryParams['clienteId'] = clienteId;
      if (fornecedorId != null) queryParams['fornecedorId'] = fornecedorId;
      if (tipo != null && tipo.isNotEmpty) queryParams['tipo'] = tipo;
      if (status != null && status.isNotEmpty) queryParams['status'] = status;

      final response = await apiClient.get(
        '/contas',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data;
        return jsonList.map((json) => ContaModel.fromJson(json).toEntity()).toList();
      } else {
        throw ApiException('Falha ao carregar contas: Status ${response.statusCode}');
      }
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException('Erro de rede ao carregar contas: ${e.message}');
    } catch (e) {
      throw ApiException('Erro inesperado ao carregar contas: ${e.toString()}');
    }
  }

  @override
  Future<Conta> getContaById(int id) async {
    try {
      final response = await apiClient.get('/contas/$id');
      if (response.statusCode == 200) {
        return ContaModel.fromJson(response.data).toEntity();
      } else {
        throw ApiException('Falha ao carregar conta $id: Status ${response.statusCode}');
      }
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException('Erro de rede ao carregar conta: ${e.message}');
    } catch (e) {
      throw ApiException('Erro inesperado ao carregar conta: ${e.toString()}');
    }
  }

  @override
  Future<Conta> createConta(Conta conta) async {
    try {
      final data = <String, dynamic>{
        'tipo': conta.tipo ?? 'PAGAR',
        'descricao': conta.descricao ?? '',
        'valor': conta.valor,
        'dataVencimento': conta.dataVencimento?.toIso8601String().split('T').first ?? DateTime.now().toIso8601String().split('T').first,
        'status': conta.status ?? 'PENDENTE',
      };
      if (conta.clienteId != null) data['clienteId'] = conta.clienteId;
      if (conta.fornecedorId != null) data['fornecedorId'] = conta.fornecedorId;
      if (conta.valorPago != null) data['valorPago'] = conta.valorPago;
      if (conta.dataPagamento != null) data['dataPagamento'] = conta.dataPagamento!.toIso8601String().split('T').first;
      if (conta.categoria != null && conta.categoria!.isNotEmpty) data['categoria'] = conta.categoria;
      if (conta.categoriaFinanceira != null && conta.categoriaFinanceira!.isNotEmpty) data['categoriaFinanceira'] = conta.categoriaFinanceira;
      if (conta.subcategoria != null && conta.subcategoria!.isNotEmpty) data['subcategoria'] = conta.subcategoria;
      if (conta.formaPagamento != null && conta.formaPagamento!.isNotEmpty) data['formaPagamento'] = conta.formaPagamento;
      if (conta.observacoes != null && conta.observacoes!.isNotEmpty) data['observacoes'] = conta.observacoes;

      final response = await apiClient.post('/contas', data: data);
      if (response.statusCode == 201) {
        return ContaModel.fromJson(response.data).toEntity();
      } else {
        throw ApiException('Falha ao criar conta: Status ${response.statusCode}');
      }
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException('Erro de rede ao criar conta: ${e.message}');
    } catch (e) {
      throw ApiException('Erro inesperado ao criar conta: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteConta(int id) async {
    try {
      final response = await apiClient.delete('/contas/$id');
      if (response.statusCode != 204) {
        throw ApiException('Falha ao excluir conta: Status ${response.statusCode}');
      }
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException('Erro de rede ao excluir conta: ${e.message}');
    } catch (e) {
      throw ApiException('Erro inesperado ao excluir conta: ${e.toString()}');
    }
  }

  @override
  Future<Conta> marcarComoPaga(int id, {DateTime? dataPagamento, String? formaPagamento}) async {
    try {
      final body = <String, dynamic>{};
      if (dataPagamento != null) body['dataPagamento'] = dataPagamento.toIso8601String().split('T').first;
      if (formaPagamento != null) body['formaPagamento'] = formaPagamento;

      final response = await apiClient.put('/contas/$id/pagar', data: body.isNotEmpty ? body : null);
      if (response.statusCode == 200) {
        return ContaModel.fromJson(response.data).toEntity();
      } else {
        throw ApiException('Falha ao marcar conta como paga: Status ${response.statusCode}');
      }
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException('Erro de rede ao marcar conta como paga: ${e.message}');
    } catch (e) {
      throw ApiException('Erro inesperado: ${e.toString()}');
    }
  }
}
