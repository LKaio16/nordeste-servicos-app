// lib/data/repositories/item_orcamento_repository_impl.dart

import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/error/exceptions.dart';
import '../models/item_orcamento_model.dart';
import '../../domain/entities/item_orcamento.dart';
import '../../domain/repositories/item_orcamento_repository.dart';

class ItemOrcamentoRepositoryImpl implements ItemOrcamentoRepository {
  final ApiClient apiClient;

  ItemOrcamentoRepositoryImpl(this.apiClient);

  @override
  Future<List<ItemOrcamento>> getItemOrcamentosByOrcamentoId(int orcamentoId) async {
     try {
      final response = await apiClient.get('/orcamentos/$orcamentoId/itens'); // Endpoint da sua API

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data;
        final List<ItemOrcamentoModel> itemOrcamentoModels = jsonList.map((json) => ItemOrcamentoModel.fromJson(json)).toList();
        final List<ItemOrcamento> itensOrcamento = itemOrcamentoModels.map((model) => model.toEntity()).toList();
        return itensOrcamento;
      } else {
         throw ApiException('Falha ao carregar itens do orçamento ${orcamentoId}: Status ${response.statusCode}');
      }
    } on ApiException {
       rethrow;
    } on DioException catch (e) {
        throw ApiException('Erro de rede ao carregar itens do orçamento ${orcamentoId}: ${e.message}');
    } catch (e) {
       throw ApiException('Erro inesperado ao carregar itens do orçamento ${orcamentoId}: ${e.toString()}');
    }
  }

  @override
  Future<ItemOrcamento> getItemOrcamentoById(int id) async {
      try {
      // Assumindo que sua API tem um endpoint para buscar item por ID direto: /itens-orcamento/{id}
      // Ou se for aninhado: /orcamentos/{orcamentoId}/itens/{id} - ajuste conforme sua API
      final response = await apiClient.get('/itens-orcamento/$id');

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = response.data;
        final ItemOrcamentoModel itemOrcamentoModel = ItemOrcamentoModel.fromJson(json);
        return itemOrcamentoModel.toEntity();
      } else {
         throw ApiException('Falha ao carregar item do orçamento ${id}: Status ${response.statusCode}');
      }
    } on ApiException {
       rethrow;
    } on DioException catch (e) {
        throw ApiException('Erro de rede ao carregar item do orçamento ${id}: ${e.message}');
    } catch (e) {
       throw ApiException('Erro inesperado ao carregar item do orçamento ${id}: ${e.toString()}');
    }
  }

  @override
  Future<ItemOrcamento> createItemOrcamento(ItemOrcamento item) async {
       try {
        // Pode ser necessário criar um DTO/Model específico para criação
         final ItemOrcamentoModel itemOrcamentoModel = ItemOrcamentoModel(
            // ID não enviado
            orcamentoId: item.orcamentoId,
            pecaMaterialId: item.pecaMaterialId,
            tipoServicoId: item.tipoServicoId,
            descricao: item.descricao,
            quantidade: item.quantidade,
            valorUnitario: item.valorUnitario,
            // Subtotal não é enviado na criação, é calculado na API
         );

      final response = await apiClient.post('/orcamentos/${item.orcamentoId}/itens', data: itemOrcamentoModel.toJson()); // Endpoint da sua API

      if (response.statusCode == 201) {
        final Map<String, dynamic> json = response.data;
        final ItemOrcamentoModel createdItemOrcamentoModel = ItemOrcamentoModel.fromJson(json);
        return createdItemOrcamentoModel.toEntity();
      } else {
         throw ApiException('Falha ao adicionar item ao orçamento ${item.orcamentoId}: Status ${response.statusCode}');
      }
    } on ApiException {
       rethrow;
    } on DioException catch (e) {
        throw ApiException('Erro de rede ao adicionar item ao orçamento ${item.orcamentoId}: ${e.message}');
    } catch (e) {
       throw ApiException('Erro inesperado ao adicionar item ao orçamento ${item.orcamentoId}: ${e.toString()}');
    }
  }

  @override
  Future<ItemOrcamento> updateItemOrcamento(ItemOrcamento item) async {
       try {
         final ItemOrcamentoModel itemOrcamentoModel = ItemOrcamentoModel(
            id: item.id, // Incluir ID
            orcamentoId: item.orcamentoId,
            pecaMaterialId: item.pecaMaterialId,
            tipoServicoId: item.tipoServicoId,
            descricao: item.descricao,
            quantidade: item.quantidade,
            valorUnitario: item.valorUnitario,
            // Subtotal não é enviado na atualização, é calculado na API
         );

      // Assumindo que sua API tem um endpoint para atualizar item por ID direto: /itens-orcamento/{id}
      // Ou se for aninhado: /orcamentos/{orcamentoId}/itens/{id} - ajuste conforme sua API
      final response = await apiClient.put('/itens-orcamento/${item.id}', data: itemOrcamentoModel.toJson());

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = response.data;
        final ItemOrcamentoModel updatedItemOrcamentoModel = ItemOrcamentoModel.fromJson(json);
        return updatedItemOrcamentoModel.toEntity();
      } else {
         throw ApiException('Falha ao atualizar item do orçamento ${item.orcamentoId} (ID ${item.id}): Status ${response.statusCode}');
      }
    } on ApiException {
       rethrow;
    } on DioException catch (e) {
        throw ApiException('Erro de rede ao atualizar item do orçamento ${item.orcamentoId} (ID ${item.id}): ${e.message}');
    } catch (e) {
       throw ApiException('Erro inesperado ao atualizar item do orçamento ${item.orcamentoId} (ID ${item.id}): ${e.toString()}');
    }
  }

  @override
  Future<void> deleteItemOrcamento(int id) async {
       try {
      // Assumindo que sua API tem um endpoint para deletar item por ID direto: /itens-orcamento/{id}
      // Ou se for aninhado: /orcamentos/{orcamentoId}/itens/{id} - ajuste conforme sua API
      final response = await apiClient.delete('/itens-orcamento/$id');

      if (response.statusCode == 204) {
        return;
      } else {
         throw ApiException('Falha ao deletar item do orçamento ${id}: Status ${response.statusCode}');
      }
    } on ApiException {
       rethrow;
    } on DioException catch (e) {
        throw ApiException('Erro de rede ao deletar item do orçamento ${id}: ${e.message}');
    } catch (e) {
       throw ApiException('Erro inesperado ao deletar item do orçamento ${id}: ${e.toString()}');
    }
  }
}