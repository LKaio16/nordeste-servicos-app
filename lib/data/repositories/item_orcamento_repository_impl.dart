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
      final response = await apiClient.get('/orcamentos/$orcamentoId/itens');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data;
        return jsonList.map((json) => ItemOrcamentoModel.fromJson(json).toEntity()).toList();
      } else {
        throw ApiException('Falha ao carregar itens do orçamento $orcamentoId: Status ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw ApiException('Erro de rede ao carregar itens do orçamento $orcamentoId: ${e.message}');
    } catch (e) {
      throw ApiException('Erro inesperado ao carregar itens do orçamento $orcamentoId: ${e.toString()}');
    }
  }

  @override
  Future<ItemOrcamento> getItemOrcamentoById(int id) async {
    try {
      // Este endpoint pode não existir na sua API, mas mantemos por consistência.
      final response = await apiClient.get('/itens-orcamento/$id');

      if (response.statusCode == 200) {
        return ItemOrcamentoModel.fromJson(response.data).toEntity();
      } else {
        throw ApiException('Falha ao carregar item do orçamento $id: Status ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw ApiException('Erro de rede ao carregar item do orçamento $id: ${e.message}');
    } catch (e) {
      throw ApiException('Erro inesperado ao carregar item do orçamento $id: ${e.toString()}');
    }
  }

  @override
  Future<ItemOrcamento> createItemOrcamento(ItemOrcamento item) async {
    try {
      final itemOrcamentoModel = ItemOrcamentoModel(
        orcamentoId: item.orcamentoId,
        pecaMaterialId: item.pecaMaterialId,
        tipoServicoId: item.tipoServicoId,
        descricao: item.descricao,
        quantidade: item.quantidade,
        valorUnitario: item.valorUnitario,
      );

      final response = await apiClient.post('/orcamentos/${item.orcamentoId}/itens', data: itemOrcamentoModel.toJson());

      if (response.statusCode == 201) {
        return ItemOrcamentoModel.fromJson(response.data).toEntity();
      } else {
        throw ApiException('Falha ao adicionar item ao orçamento ${item.orcamentoId}: Status ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw ApiException('Erro de rede ao adicionar item ao orçamento ${item.orcamentoId}: ${e.message}');
    } catch (e) {
      throw ApiException('Erro inesperado ao adicionar item ao orçamento ${item.orcamentoId}: ${e.toString()}');
    }
  }

  @override
  Future<ItemOrcamento> updateItemOrcamento(ItemOrcamento item) async {
    try {
      final itemOrcamentoModel = ItemOrcamentoModel(
        id: item.id,
        orcamentoId: item.orcamentoId,
        pecaMaterialId: item.pecaMaterialId,
        tipoServicoId: item.tipoServicoId,
        descricao: item.descricao,
        quantidade: item.quantidade,
        valorUnitario: item.valorUnitario,
      );

      // <<< CORREÇÃO DA URL DE ATUALIZAÇÃO >>>
      final response = await apiClient.put('/orcamentos/${item.orcamentoId}/itens/${item.id}', data: itemOrcamentoModel.toJson());

      if (response.statusCode == 200) {
        return ItemOrcamentoModel.fromJson(response.data).toEntity();
      } else {
        throw ApiException('Falha ao atualizar item do orçamento ${item.id}: Status ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw ApiException('Erro de rede ao atualizar item do orçamento ${item.id}: ${e.message}');
    } catch (e) {
      throw ApiException('Erro inesperado ao atualizar item do orçamento ${item.id}: ${e.toString()}');
    }
  }

  // <<< CORREÇÃO DO MÉTODO DE DELEÇÃO >>>
  @override
  Future<void> deleteItemOrcamento(int orcamentoId, int itemId) async {
    try {
      // Usando a URL aninhada correta, conforme definido no seu ItemOrcamentoController
      final response = await apiClient.delete('/orcamentos/$orcamentoId/itens/$itemId');

      if (response.statusCode == 204) { // 204 No Content
        return;
      } else {
        throw ApiException('Falha ao deletar item do orçamento $itemId: Status ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw ApiException('Erro de rede ao deletar item do orçamento $itemId: ${e.message}');
    } catch (e) {
      throw ApiException('Erro inesperado ao deletar item do orçamento $itemId: ${e.toString()}');
    }
  }
}