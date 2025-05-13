// lib/domain/entities/item_orcamento.dart

// Importar PecaMaterial e TipoServico se quiser os objetos completos na entidade ItemOrcamento
// import 'peca_material.dart';
// import 'tipo_servico.dart';

class ItemOrcamento {
  final int? id;
  final int orcamentoId; // Referência ao ID do orçamento pai

  final int? pecaMaterialId; // Referência ao ID da peça/material (opcional)
  final String? codigoPecaMaterial; // Mantido se o Model já o traz
  final String? descricaoPecaMaterial; // Mantido se o Model já o traz

  final int? tipoServicoId; // Referência ao ID do tipo de serviço (opcional)
  final String? descricaoTipoServico; // Mantido se o Model já o traz

  final String descricao;
  final double quantidade;
  final double valorUnitario;
  final double? subtotal;

  ItemOrcamento({
    this.id,
    required this.orcamentoId,
    this.pecaMaterialId,
    this.codigoPecaMaterial,
    this.descricaoPecaMaterial,
    this.tipoServicoId,
    this.descricaoTipoServico,
    required this.descricao,
    required this.quantidade,
    required this.valorUnitario,
    this.subtotal,
  });
}