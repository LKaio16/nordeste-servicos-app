// lib/data/repositories/assinatura_os_repository_impl.dart

import 'dart:io'; // Para File
import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/error/exceptions.dart';
import '../models/assinatura_os_model.dart';
import '../../domain/entities/assinatura_os.dart';
import '../../domain/repositories/assinatura_os_repository.dart';

class AssinaturaOsRepositoryImpl implements AssinaturaOsRepository {
  final ApiClient apiClient;

  AssinaturaOsRepositoryImpl(this.apiClient);

  @override
  Future<AssinaturaOS?> getAssinaturaByOsId(int osId) async {
    try {
      // Endpoint da sua API para obter a assinatura de uma OS
      final response = await apiClient.get('/ordens-servico/$osId/assinatura');

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = response.data;
        final AssinaturaOSModel assinaturaOsModel = AssinaturaOSModel.fromJson(json);
        return assinaturaOsModel.toEntity();
      } else if (response.statusCode == 404) {
        // Se a API retornar 404 quando a assinatura não existe, trate aqui
        return null;
      } else {
        throw ApiException('Falha ao carregar assinatura da OS ${osId}: Status ${response.statusCode}');
      }
    } on ApiException catch(e) {
      // Se o ApiClient lançou NotFoundException para 404, você pode retornar null
      if (e is NotFoundException) {
        return null;
      }
      rethrow; // Relança outras ApiExceptions
    } on DioException catch (e) {
      throw ApiException('Erro de rede ao carregar assinatura da OS ${osId}: ${e.message}');
    } catch (e) {
      throw ApiException('Erro inesperado ao carregar assinatura da OS ${osId}: ${e.toString()}');
    }
  }

  @override
  Future<AssinaturaOS> getAssinaturaById(int id) async {
    try {
      // Assumindo um endpoint direto: /assinaturas/{id} ou aninhado /ordens-servico/{osId}/assinatura/{id}
      final response = await apiClient.get('/assinaturas/$id');

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = response.data;
        final AssinaturaOSModel assinaturaOsModel = AssinaturaOSModel.fromJson(json);
        return assinaturaOsModel.toEntity();
      } else {
        throw ApiException('Falha ao carregar assinatura ${id}: Status ${response.statusCode}');
      }
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException('Erro de rede ao carregar assinatura ${id}: ${e.message}');
    } catch (e) {
      throw ApiException('Erro inesperado ao carregar assinatura ${id}: ${e.toString()}');
    }
  }


  @override
  Future<AssinaturaOS> uploadAssinatura(int osId, AssinaturaOS assinatura) async {
    try {
      final requestData = {
        'assinaturaClienteBase64': assinatura.assinaturaClienteBase64,
        'nomeClienteResponsavel': assinatura.nomeClienteResponsavel,
        'documentoClienteResponsavel': assinatura.documentoClienteResponsavel,
        'assinaturaTecnicoBase64': assinatura.assinaturaTecnicoBase64,
        'nomeTecnicoResponsavel': assinatura.nomeTecnicoResponsavel,
      };

      final response = await apiClient.put('/ordens-servico/$osId/assinatura', data: requestData);

      if (response.statusCode == 200) {
        return AssinaturaOSModel.fromJson(response.data).toEntity();
      } else {
        throw ApiException('Falha ao fazer upload da assinatura: Status ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw ApiException('Erro de rede ao fazer upload da assinatura: ${e.message}');
    } catch (e) {
      throw ApiException('Erro inesperado ao fazer upload da assinatura: ${e.toString()}');
    }
  }
  
  @override
  Future<void> deleteAssinatura(int id) async {
    try {
      // Endpoint para deletar assinatura por ID (se a API suportar)
      final response = await apiClient.delete('/assinaturas/$id');

      if (response.statusCode == 204) {
        return;
      } else {
        throw ApiException('Falha ao deletar assinatura ${id}: Status ${response.statusCode}');
      }
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException('Erro de rede ao deletar assinatura ${id}: ${e.message}');
    } catch (e) {
      throw ApiException('Erro inesperado ao deletar assinatura ${id}: ${e.toString()}');
    }
  }

  // IMPLEMENTAÇÃO DO MÉTODO QUE FALTAVA: DELETAR POR ID DA OS
  @override
  Future<void> deleteAssinaturaByOsId(int osId) async {
    try {
      // Endpoint da sua API para deletar a assinatura usando o ID da OS
      final response = await apiClient.delete('/ordens-servico/$osId/assinatura');

      if (response.statusCode == 204) {
        return;
      } else {
        throw ApiException('Falha ao deletar assinatura da OS ${osId}: Status ${response.statusCode}');
      }
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException('Erro de rede ao deletar assinatura da OS ${osId}: ${e.message}');
    } catch (e) {
      throw ApiException('Erro inesperado ao deletar assinatura da OS ${osId}: ${e.toString()}');
    }
  }
}