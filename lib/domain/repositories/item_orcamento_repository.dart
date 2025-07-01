// lib/domain/repositories/item_orcamento_repository.dart


import '../entities/item_orcamento.dart';
import '/core/error/exceptions.dart';

abstract class ItemOrcamentoRepository {
  /// Obtém a lista de itens para um orçamento específico.
  Future<List<ItemOrcamento>> getItemOrcamentosByOrcamentoId(int orcamentoId);

  /// Obtém um item de orçamento pelo seu ID.
  Future<ItemOrcamento> getItemOrcamentoById(int id);

  /// Adiciona um novo item a um orçamento.
  Future<ItemOrcamento> createItemOrcamento(ItemOrcamento item); // Pode precisar de DTO

  /// Atualiza um item de orçamento existente.
  Future<ItemOrcamento> updateItemOrcamento(ItemOrcamento item); // Pode precisar de DTO

  /// Deleta um item de orçamento pelo seu ID.
  Future<void> deleteItemOrcamento(int orcamentoId, int itemId);
}