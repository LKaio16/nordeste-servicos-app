// lib/data/repositories/peca_material_repository_impl.dart

import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/error/exceptions.dart';
import '../models/peca_material_model.dart';
import '../../domain/entities/peca_material.dart';
import '../../domain/repositories/peca_material_repository.dart';

class PecaMaterialRepositoryImpl implements PecaMaterialRepository {
  final ApiClient apiClient;

  PecaMaterialRepositoryImpl(this.apiClient);

  @override
  Future<List<PecaMaterial>> getPecasMateriais() async {
     try {
      final response = await apiClient.get('/pecas-materiais'); // Endpoint da sua API

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data;
        final List<PecaMaterialModel> pecaMaterialModels = jsonList.map((json) => PecaMaterialModel.fromJson(json)).toList();
        final List<PecaMaterial> pecasMateriais = pecaMaterialModels.map((model) => model.toEntity()).toList();
        return pecasMateriais;
      } else {
         throw ApiException('Falha ao carregar peças/materiais: Status ${response.statusCode}');
      }
    } on ApiException {
       rethrow;
    } on DioException catch (e) {
        throw ApiException('Erro de rede ao carregar peças/materiais: ${e.message}');
    } catch (e) {
       throw ApiException('Erro inesperado ao carregar peças/materiais: ${e.toString()}');
    }
  }

  @override
  Future<PecaMaterial> getPecaMaterialById(int id) async {
     try {
      final response = await apiClient.get('/pecas-materiais/$id'); // Endpoint da sua API

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = response.data;
        final PecaMaterialModel pecaMaterialModel = PecaMaterialModel.fromJson(json);
        return pecaMaterialModel.toEntity();
      } else {
         throw ApiException('Falha ao carregar peça/material ${id}: Status ${response.statusCode}');
      }
    } on ApiException {
       rethrow;
    } on DioException catch (e) {
        throw ApiException('Erro de rede ao carregar peça/material ${id}: ${e.message}');
    } catch (e) {
       throw ApiException('Erro inesperado ao carregar peça/material ${id}: ${e.toString()}');
    }
  }

  @override
  Future<PecaMaterial> createPecaMaterial(PecaMaterial pecaMaterial) async {
       try {
        final PecaMaterialModel pecaMaterialModel = PecaMaterialModel(
           // ID não enviado
           codigo: pecaMaterial.codigo,
           descricao: pecaMaterial.descricao,
           preco: pecaMaterial.preco,
           estoque: pecaMaterial.estoque,
        );

      final response = await apiClient.post('/pecas-materiais', data: pecaMaterialModel.toJson());

      if (response.statusCode == 201) {
        final Map<String, dynamic> json = response.data;
        final PecaMaterialModel createdPecaMaterialModel = PecaMaterialModel.fromJson(json);
        return createdPecaMaterialModel.toEntity();
      } else {
         throw ApiException('Falha ao criar peça/material: Status ${response.statusCode}');
      }
    } on ApiException {
       rethrow;
    } on DioException catch (e) {
        throw ApiException('Erro de rede ao criar peça/material: ${e.message}');
    } catch (e) {
       throw ApiException('Erro inesperado ao criar peça/material: ${e.toString()}');
    }
  }

  @override
  Future<PecaMaterial> updatePecaMaterial(PecaMaterial pecaMaterial) async {
       try {
         final PecaMaterialModel pecaMaterialModel = PecaMaterialModel(
            id: pecaMaterial.id, // Incluir ID
           codigo: pecaMaterial.codigo,
           descricao: pecaMaterial.descricao,
           preco: pecaMaterial.preco,
           estoque: pecaMaterial.estoque,
        );

      final response = await apiClient.put('/pecas-materiais/${pecaMaterial.id}', data: pecaMaterialModel.toJson());

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = response.data;
        final PecaMaterialModel updatedPecaMaterialModel = PecaMaterialModel.fromJson(json);
        return updatedPecaMaterialModel.toEntity();
      } else {
         throw ApiException('Falha ao atualizar peça/material ${pecaMaterial.id}: Status ${response.statusCode}');
      }
    } on ApiException {
       rethrow;
    } on DioException catch (e) {
        throw ApiException('Erro de rede ao atualizar peça/material ${pecaMaterial.id}: ${e.message}');
    } catch (e) {
       throw ApiException('Erro inesperado ao atualizar peça/material ${pecaMaterial.id}: ${e.toString()}');
    }
  }

  @override
  Future<void> deletePecaMaterial(int id) async {
       try {
      final response = await apiClient.delete('/pecas-materiais/$id');

      if (response.statusCode == 204) {
        return;
      } else {
         throw ApiException('Falha ao deletar peça/material ${id}: Status ${response.statusCode}');
      }
    } on ApiException {
       rethrow;
    } on DioException catch (e) {
        throw ApiException('Erro de rede ao deletar peça/material ${id}: ${e.message}');
    } catch (e) {
       throw ApiException('Erro inesperado ao deletar peça/material ${id}: ${e.toString()}');
    }
  }
}