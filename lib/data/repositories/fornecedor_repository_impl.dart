// lib/data/repositories/fornecedor_repository_impl.dart

import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/error/exceptions.dart';
import '../models/fornecedor_model.dart';
import '../../domain/entities/fornecedor.dart';
import '../../domain/repositories/fornecedor_repository.dart';

class FornecedorRepositoryImpl implements FornecedorRepository {
  final ApiClient apiClient;

  FornecedorRepositoryImpl(this.apiClient);

  @override
  Future<List<Fornecedor>> getFornecedores({String? searchTerm, String? status}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (searchTerm != null && searchTerm.trim().isNotEmpty) queryParams['searchTerm'] = searchTerm.trim();
      if (status != null && status.isNotEmpty) queryParams['status'] = status;

      final response = await apiClient.get(
        '/fornecedores',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data;
        return jsonList.map((json) => FornecedorModel.fromJson(json).toEntity()).toList();
      } else {
        throw ApiException('Falha ao carregar fornecedores: Status ${response.statusCode}');
      }
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException('Erro de rede ao carregar fornecedores: ${e.message}');
    } catch (e) {
      throw ApiException('Erro inesperado ao carregar fornecedores: ${e.toString()}');
    }
  }

  @override
  Future<Fornecedor> getFornecedorById(int id) async {
    try {
      final response = await apiClient.get('/fornecedores/$id');
      if (response.statusCode == 200) {
        return FornecedorModel.fromJson(response.data).toEntity();
      } else {
        throw ApiException('Falha ao carregar fornecedor $id: Status ${response.statusCode}');
      }
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException('Erro de rede ao carregar fornecedor: ${e.message}');
    } catch (e) {
      throw ApiException('Erro inesperado ao carregar fornecedor: ${e.toString()}');
    }
  }

  @override
  Future<Fornecedor> createFornecedor(Fornecedor fornecedor) async {
    try {
      final data = <String, dynamic>{
        'nome': fornecedor.nome,
        'cnpj': fornecedor.cnpj ?? '',
        'endereco': fornecedor.endereco ?? '',
        'cidade': fornecedor.cidade ?? '',
        'estado': fornecedor.estado ?? '',
        'status': fornecedor.status ?? 'ATIVO',
      };
      if (fornecedor.email != null && fornecedor.email!.isNotEmpty) data['email'] = fornecedor.email;
      if (fornecedor.telefone != null && fornecedor.telefone!.isNotEmpty) data['telefone'] = fornecedor.telefone;
      if (fornecedor.observacoes != null && fornecedor.observacoes!.isNotEmpty) data['observacoes'] = fornecedor.observacoes;

      final response = await apiClient.post('/fornecedores', data: data);
      if (response.statusCode == 201) {
        return FornecedorModel.fromJson(response.data).toEntity();
      } else {
        throw ApiException('Falha ao criar fornecedor: Status ${response.statusCode}');
      }
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException('Erro de rede ao criar fornecedor: ${e.message}');
    } catch (e) {
      throw ApiException('Erro inesperado ao criar fornecedor: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteFornecedor(int id) async {
    try {
      final response = await apiClient.delete('/fornecedores/$id');
      if (response.statusCode != 204) {
        throw ApiException('Falha ao excluir fornecedor: Status ${response.statusCode}');
      }
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException('Erro de rede ao excluir fornecedor: ${e.message}');
    } catch (e) {
      throw ApiException('Erro inesperado ao excluir fornecedor: ${e.toString()}');
    }
  }
}
