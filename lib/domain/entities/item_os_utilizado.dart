// lib/domain/entities/item_os_utilizado.dart

// Importar PecaMaterial se quiser o objeto completo na entidade ItemOSUtilizado
// import 'peca_material.dart';

class ItemOSUtilizado {
  final int? id;
  final int ordemServicoId; // Referência ao ID da OS pai
  final int pecaMaterialId; // Referência ao ID da peça/material

  final String? codigoPecaMaterial; // Mantido se o Model já o traz
  final String? descricaoPecaMaterial; // Mantido se o Model já o traz
  final double? precoUnitarioPecaMaterial; // Mantido se o Model já o traz

  final int? quantidadeRequisitada;
  final int quantidadeUtilizada;
  final int? quantidadeDevolvida;

  ItemOSUtilizado({
    this.id,
    required this.ordemServicoId,
    required this.pecaMaterialId,
    this.codigoPecaMaterial,
    this.descricaoPecaMaterial,
    this.precoUnitarioPecaMaterial,
    this.quantidadeRequisitada,
    required this.quantidadeUtilizada,
    this.quantidadeDevolvida,
  });
}