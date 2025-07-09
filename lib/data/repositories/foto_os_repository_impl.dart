// lib/data/repositories/foto_os_repository_impl.dart

import 'dart:io'; // Para File
import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/error/exceptions.dart';
import '../models/foto_os_model.dart';
import '../../domain/entities/foto_os.dart';
import '../../domain/repositories/foto_os_repository.dart';

class FotoOsRepositoryImpl implements FotoOsRepository {
  final ApiClient apiClient;

  FotoOsRepositoryImpl(this.apiClient);

  @override
  Future<List<FotoOS>> getFotosByOsId(int osId) async {
       try {
      final response = await apiClient.get('/ordens-servico/$osId/fotos'); // Endpoint da sua API

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data;
        final List<FotoOSModel> fotoOsModels = jsonList.map((json) => FotoOSModel.fromJson(json)).toList();
        final List<FotoOS> fotos = fotoOsModels.map((model) => model.toEntity()).toList();
        return fotos;
      } else {
         throw ApiException('Falha ao carregar fotos da OS ${osId}: Status ${response.statusCode}');
      }
    } on ApiException {
       rethrow;
    } on DioException catch (e) {
        throw ApiException('Erro de rede ao carregar fotos da OS ${osId}: ${e.message}');
    } catch (e) {
       throw ApiException('Erro inesperado ao carregar fotos da OS ${osId}: ${e.toString()}');
    }
  }

  @override
  Future<FotoOS> getFotoById(int id) async {
      try {
      // Assumindo um endpoint direto: /fotos/{id} ou aninhado /ordens-servico/{osId}/fotos/{id}
      final response = await apiClient.get('/fotos/$id');

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = response.data;
        final FotoOSModel fotoOsModel = FotoOSModel.fromJson(json);
        return fotoOsModel.toEntity();
      } else {
         throw ApiException('Falha ao carregar foto ${id}: Status ${response.statusCode}');
      }
    } on ApiException {
       rethrow;
    } on DioException catch (e) {
        throw ApiException('Erro de rede ao carregar foto ${id}: ${e.message}');
    } catch (e) {
       throw ApiException('Erro inesperado ao carregar foto ${id}: ${e.toString()}');
    }
  }


  @override
  Future<FotoOS> uploadFoto(int osId, {
    required String base64,
    required String? description,
    required String? fileName,
    required String? mimeType,
    required int? fileSize,
  }) async {
    try {
      final requestData = {
        'fotoBase64': base64,
        'descricao': description,
        'nomeArquivoOriginal': fileName,
        'tipoConteudo': mimeType,
        'tamanhoArquivo': fileSize,
      };

      final response = await apiClient.post('/ordens-servico/$osId/fotos', data: requestData);

      if (response.statusCode == 201) {
        return FotoOSModel.fromJson(response.data).toEntity();
      } else {
        throw ApiException('Falha ao fazer upload da foto: Status ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw ApiException('Erro de rede ao fazer upload da foto: ${e.message}');
    } catch (e) {
      throw ApiException('Erro inesperado ao fazer upload da foto: ${e.toString()}');
    }
  }

  @override
  @override
  Future<void> deleteFoto(int osId, int fotoId) async {
    try {
      // **CORREÇÃO APLICADA AQUI**
      // Monta a URL correta conforme definido no seu Controller da API.
      final response = await apiClient.delete('/ordens-servico/$osId/fotos/$fotoId');

      if (response.statusCode == 204) {
        return;
      } else {
        throw ApiException('Falha ao deletar foto $fotoId: Status ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw ApiException('Erro de rede ao deletar foto $fotoId: ${e.message}');
    } catch (e) {
      throw ApiException('Erro inesperado ao deletar foto $fotoId: ${e.toString()}');
    }
  }
}