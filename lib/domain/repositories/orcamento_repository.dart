// lib/domain/repositories/orcamento_repository.dart


import 'dart:typed_data';

import '../../data/models/status_orcamento_model.dart';
import '../entities/orcamento.dart';
import '/core/error/exceptions.dart';

abstract class OrcamentoRepository {
  /// Obtém a lista de orçamentos, com opções de filtro.
  Future<List<Orcamento>> getOrcamentos({
    int? clienteId,
    StatusOrcamentoModel? status,
    int? ordemServicoOrigemId,
  });

  /// Obtém um orçamento pelo seu ID.
  Future<Orcamento> getOrcamentoById(int id);

  /// Cria um novo orçamento.
  Future<Orcamento> createOrcamento(Orcamento orcamento); // Pode precisar de um DTO de criação

  /// Atualiza um orçamento existente.
  Future<Orcamento> updateOrcamento(Orcamento orcamento); // Pode precisar de um DTO de atualização

  /// Deleta um orçamento pelo seu ID.
  Future<void> deleteOrcamento(int id);

  Future<Uint8List> downloadOrcamentoPdf(int orcamentoId);

  // Métodos para gerenciar itens do orçamento (alternativa a repositório separado para itens)
  // Future<List<ItemOrcamento>> getItemOrcamentosByOrcamentoId(int orcamentoId);
  // Future<ItemOrcamento> createItemOrcamento(ItemOrcamento item); // Pode precisar de DTO
  // Future<void> deleteItemOrcamento(int id);
}