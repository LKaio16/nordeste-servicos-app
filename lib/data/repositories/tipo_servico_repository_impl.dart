// lib/data/repositories/tipo_servico_repository_impl.dart

import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/error/exceptions.dart';
import '../models/tipo_servico_model.dart';
import '../../domain/entities/tipo_servico.dart';
import '../../domain/repositories/tipo_servico_repository.dart';

class TipoServicoRepositoryImpl implements TipoServicoRepository {
  final ApiClient apiClient;

  TipoServicoRepositoryImpl(this.apiClient);

  @override
  Future<List<TipoServico>> getTiposServico() async {
     try {
      final response = await apiClient.get('/tipos-servico'); // Endpoint da sua API

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data;
        final List<TipoServicoModel> tipoServicoModels = jsonList.map((json) => TipoServicoModel.fromJson(json)).toList();
        final List<TipoServico> tiposServico = tipoServicoModels.map((model) => model.toEntity()).toList();
        return tiposServico;
      } else {
         throw ApiException('Falha ao carregar tipos de serviço: Status ${response.statusCode}');
      }
    } on ApiException {
       rethrow;
    } on DioException catch (e) {
        throw ApiException('Erro de rede ao carregar tipos de serviço: ${e.message}');
    } catch (e) {
       throw ApiException('Erro inesperado ao carregar tipos de serviço: ${e.toString()}');
    }
  }

  @override
  Future<TipoServico> getTipoServicoById(int id) async {
     try {
      final response = await apiClient.get('/tipos-servico/$id'); // Endpoint da sua API

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = response.data;
        final TipoServicoModel tipoServicoModel = TipoServicoModel.fromJson(json);
        return tipoServicoModel.toEntity();
      } else {
         throw ApiException('Falha ao carregar tipo de serviço ${id}: Status ${response.statusCode}');
      }
    } on ApiException {
       rethrow;
    } on DioException catch (e) {
        throw ApiException('Erro de rede ao carregar tipo de serviço ${id}: ${e.message}');
    } catch (e) {
       throw ApiException('Erro inesperado ao carregar tipo de serviço ${id}: ${e.toString()}');
    }
  }

  @override
  Future<TipoServico> createTipoServico(TipoServico tipoServico) async {
       try {
        final TipoServicoModel tipoServicoModel = TipoServicoModel(
           // ID não enviado
           descricao: tipoServico.descricao,
        );

      final response = await apiClient.post('/tipos-servico', data: tipoServicoModel.toJson());

      if (response.statusCode == 201) {
        final Map<String, dynamic> json = response.data;
        final TipoServicoModel createdTipoServicoModel = TipoServicoModel.fromJson(json);
        return createdTipoServicoModel.toEntity();
      } else {
         throw ApiException('Falha ao criar tipo de serviço: Status ${response.statusCode}');
      }
    } on ApiException {
       rethrow;
    } on DioException catch (e) {
        throw ApiException('Erro de rede ao criar tipo de serviço: ${e.message}');
    } catch (e) {
       throw ApiException('Erro inesperado ao criar tipo de serviço: ${e.toString()}');
    }
  }

  @override
  Future<TipoServico> updateTipoServico(TipoServico tipoServico) async {
       try {
         final TipoServicoModel tipoServicoModel = TipoServicoModel(
            id: tipoServico.id, // Incluir ID
           descricao: tipoServico.descricao,
        );

      final response = await apiClient.put('/tipos-servico/${tipoServico.id}', data: tipoServicoModel.toJson());

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = response.data;
        final TipoServicoModel updatedTipoServicoModel = TipoServicoModel.fromJson(json);
        return updatedTipoServicoModel.toEntity();
      } else {
         throw ApiException('Falha ao atualizar tipo de serviço ${tipoServico.id}: Status ${response.statusCode}');
      }
    } on ApiException {
       rethrow;
    } on DioException catch (e) {
        throw ApiException('Erro de rede ao atualizar tipo de serviço ${tipoServico.id}: ${e.message}');
    } catch (e) {
       throw ApiException('Erro inesperado ao atualizar tipo de serviço ${tipoServico.id}: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteTipoServico(int id) async {
       try {
      final response = await apiClient.delete('/tipos-servico/$id');

      if (response.statusCode == 204) {
        return;
      } else {
         throw ApiException('Falha ao deletar tipo de serviço ${id}: Status ${response.statusCode}');
      }
    } on ApiException {
       rethrow;
    } on DioException catch (e) {
        throw ApiException('Erro de rede ao deletar tipo de serviço ${id}: ${e.message}');
    } catch (e) {
       throw ApiException('Erro inesperado ao deletar tipo de serviço ${id}: ${e.toString()}');
    }
  }
}