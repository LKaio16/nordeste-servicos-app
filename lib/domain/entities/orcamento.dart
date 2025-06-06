// lib/domain/entities/orcamento.dart


import '../../data/models/status_orcamento_model.dart'; // Reutilizando o enum model

class Orcamento {
  final int? id;
  final String numeroOrcamento;
  final DateTime dataCriacao;
  final DateTime dataValidade;
  final StatusOrcamentoModel status;

  final int clienteId;
  final String? nomeCliente; // Mantido aqui se o Model já o traz
  final int? ordemServicoOrigemId; // Referência ao ID da OS de origem

  final String? observacoesCondicoes;
  final double? valorTotal;

  // Lista de itens (se quiser na entidade principal)
  // final List<ItemOrcamento>? itensOrcamento;

  Orcamento({
    this.id,
    required this.numeroOrcamento,
    required this.dataCriacao,
    required this.dataValidade,
    required this.status,
    required this.clienteId,
    this.nomeCliente,
    this.ordemServicoOrigemId,
    this.observacoesCondicoes,
    this.valorTotal,
  });
}