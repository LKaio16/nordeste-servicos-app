// lib/data/repositories/item_os_utilizado_repository_impl.dart

import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/error/exceptions.dart';
import '../models/item_os_utilizado_model.dart';
import '../../domain/entities/item_os_utilizado.dart';
import '../../domain/repositories/item_os_utilizado_repository.dart';

class ItemOSUtilizadoRepositoryImpl implements ItemOSUtilizadoRepository {
  final ApiClient apiClient;

  ItemOSUtilizadoRepositoryImpl(this.apiClient);

  @override
  Future<List<ItemOSUtilizado>> getItensUtilizadosByOsId(int osId) async {
      try {
      final response = await apiClient.get('/ordens-servico/$osId/itens-utilizados'); // Endpoint da sua API

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data;
        final List<ItemOSUtilizadoModel> itemOsUtilizadoModels = jsonList.map((json) => ItemOSUtilizadoModel.fromJson(json)).toList();
        final List<ItemOSUtilizado> itensUtilizados = itemOsUtilizadoModels.map((model) => model.toEntity()).toList();
        return itensUtilizados;
      } else {
         throw ApiException('Falha ao carregar itens utilizados da OS ${osId}: Status ${response.statusCode}');
      }
    } on ApiException {
       rethrow;
    } on DioException catch (e) {
        throw ApiException('Erro de rede ao carregar itens utilizados da OS ${osId}: ${e.message}');
    } catch (e) {
       throw ApiException('Erro inesperado ao carregar itens utilizados da OS ${osId}: ${e.toString()}');
    }
  }

  @override
  Future<ItemOSUtilizado> getItemOSUtilizadoById(int id) async {
       try {
      // Assumindo um endpoint direto: /itens-os-utilizados/{id} ou aninhado /ordens-servico/{osId}/itens-utilizados/{id}
      final response = await apiClient.get('/itens-os-utilizados/$id');

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = response.data;
        final ItemOSUtilizadoModel itemOsUtilizadoModel = ItemOSUtilizadoModel.fromJson(json);
        return itemOsUtilizadoModel.toEntity();
      } else {
         throw ApiException('Falha ao carregar item utilizado ${id}: Status ${response.statusCode}');
      }
    } on ApiException {
       rethrow;
    } on DioException catch (e) {
        throw ApiException('Erro de rede ao carregar item utilizado ${id}: ${e.message}');
    } catch (e) {
       throw ApiException('Erro inesperado ao carregar item utilizado ${id}: ${e.toString()}');
    }
  }

  @override
  Future<ItemOSUtilizado> createItemOSUtilizado(ItemOSUtilizado item) async {
      try {
        // Pode ser necessário criar um DTO/Model específico para criação
         final ItemOSUtilizadoModel itemOsUtilizadoModel = ItemOSUtilizadoModel(
            // ID não enviado
            ordemServicoId: item.ordemServicoId,
            pecaMaterialId: item.pecaMaterialId,
            quantidadeRequisitada: item.quantidadeRequisitada,
            quantidadeUtilizada: item.quantidadeUtilizada,
            quantidadeDevolvida: item.quantidadeDevolvida,
         );

      final response = await apiClient.post('/ordens-servico/${item.ordemServicoId}/itens-utilizados', data: itemOsUtilizadoModel.toJson());

      if (response.statusCode == 201) {
        final Map<String, dynamic> json = response.data;
        final ItemOSUtilizadoModel createdItemOsUtilizadoModel = ItemOSUtilizadoModel.fromJson(json);
        return createdItemOsUtilizadoModel.toEntity();
      } else {
         throw ApiException('Falha ao adicionar item utilizado à OS ${item.ordemServicoId}: Status ${response.statusCode}');
      }
    } on ApiException {
       rethrow;
    } on DioException catch (e) {
        throw ApiException('Erro de rede ao adicionar item utilizado à OS ${item.ordemServicoId}: ${e.message}');
    } catch (e) {
       throw ApiException('Erro inesperado ao adicionar item utilizado à OS ${item.ordemServicoId}: ${e.toString()}');
    }
  }

  @override
  Future<ItemOSUtilizado> updateItemOSUtilizado(ItemOSUtilizado item) async {
       try {
         final ItemOSUtilizadoModel itemOsUtilizadoModel = ItemOSUtilizadoModel(
            id: item.id, // Incluir ID
            ordemServicoId: item.ordemServicoId,
            pecaMaterialId: item.pecaMaterialId,
            quantidadeRequisitada: item.quantidadeRequisitada,
            quantidadeUtilizada: item.quantidadeUtilizada,
            quantidadeDevolvida: item.quantidadeDevolvida,
         );

      // Assumindo um endpoint direto: /itens-os-utilizados/{id} ou aninhado /ordens-servico/{osId}/itens-utilizados/{id}
      final response = await apiClient.put('/itens-os-utilizados/${item.id}', data: itemOsUtilizadoModel.toJson());

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = response.data;
        final ItemOSUtilizadoModel updatedItemOsUtilizadoModel = ItemOSUtilizadoModel.fromJson(json);
        return updatedItemOsUtilizadoModel.toEntity();
      } else {
         throw ApiException('Falha ao atualizar item utilizado ${item.id}: Status ${response.statusCode}');
      }
    } on ApiException {
       rethrow;
    } on DioException catch (e) {
        throw ApiException('Erro de rede ao atualizar item utilizado ${item.id}: ${e.message}');
    } catch (e) {
       throw ApiException('Erro inesperado ao atualizar item utilizado ${item.id}: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteItemOSUtilizado(int id) async {
      try {
      // Assumindo um endpoint direto: /itens-os-utilizados/{id} ou aninhado /ordens-servico/{osId}/itens-utilizados/{id}
      final response = await apiClient.delete('/itens-os-utilizados/$id');

      if (response.statusCode == 204) {
        return;
      } else {
         throw ApiException('Falha ao deletar item utilizado ${id}: Status ${response.statusCode}');
      }
    } on ApiException {
       rethrow;
    } on DioException catch (e) {
        throw ApiException('Erro de rede ao deletar item utilizado ${id}: ${e.message}');
    } catch (e) {
       throw ApiException('Erro inesperado ao deletar item utilizado ${id}: ${e.toString()}');
    }
  }
}