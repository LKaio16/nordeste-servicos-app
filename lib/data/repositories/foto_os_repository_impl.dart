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
  Future<FotoOS> uploadFoto(int osId, File photoFile) async {
    try {
      // Para upload de arquivo, usamos FormData
      String fileName = photoFile.path.split('/').last;
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(photoFile.path, filename: fileName),
        // Se sua API esperar outros campos no corpo (ex: descrição), adicione aqui:
        // "descricao": "Descrição da foto",
      });

      final response = await apiClient.post('/ordens-servico/$osId/fotos', data: formData); // Endpoint de upload da API

      if (response.statusCode == 201) {
        final Map<String, dynamic> json = response.data;
        final FotoOSModel createdFotoOsModel = FotoOSModel.fromJson(json);
        return createdFotoOsModel.toEntity();
      } else {
         throw ApiException('Falha ao fazer upload da foto para OS ${osId}: Status ${response.statusCode}');
      }
    } on ApiException {
       rethrow;
    } on DioException catch (e) {
        throw ApiException('Erro de rede ao fazer upload da foto para OS ${osId}: ${e.message}');
    } catch (e) {
       throw ApiException('Erro inesperado ao fazer upload da foto para OS ${osId}: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteFoto(int id) async {
       try {
      // Assumindo endpoint direto: /fotos/{id} ou aninhado /ordens-servico/{osId}/fotos/{id}
      final response = await apiClient.delete('/fotos/$id');

      if (response.statusCode == 204) {
        return;
      } else {
         throw ApiException('Falha ao deletar foto ${id}: Status ${response.statusCode}');
      }
    } on ApiException {
       rethrow;
    } on DioException catch (e) {
        throw ApiException('Erro de rede ao deletar foto ${id}: ${e.message}');
    } catch (e) {
       throw ApiException('Erro inesperado ao deletar foto ${id}: ${e.toString()}');
    }
  }
}