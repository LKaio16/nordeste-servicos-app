// lib/data/models/item_orcamento_model.dart

import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/item_orcamento.dart';
// Importar entidades relacionadas se usar a camada domain
// import 'package:nordeste_servicos/domain/entities/item_orcamento.dart';

part 'item_orcamento_model.g.dart';

@JsonSerializable()
class ItemOrcamentoModel {
  final int? id;
  final int orcamentoId;

  final int? pecaMaterialId;
  final String? codigoPecaMaterial;
  final String? descricaoPecaMaterial;

  final int? tipoServicoId;
  final String? descricaoTipoServico;

  final String descricao;
  final double quantidade;
  final double valorUnitario;
  final double? subtotal;

  ItemOrcamentoModel({
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

  factory ItemOrcamentoModel.fromJson(Map<String, dynamic> json) => _$ItemOrcamentoModelFromJson(json);
  Map<String, dynamic> toJson() => _$ItemOrcamentoModelToJson(this);

// Método para converter para Entity (se usar camada domain) - COMENTADO
  ItemOrcamento toEntity() {
    return ItemOrcamento(
      id: id,
      orcamentoId: orcamentoId,
      pecaMaterialId: pecaMaterialId,
      codigoPecaMaterial: codigoPecaMaterial,
      descricaoPecaMaterial: descricaoPecaMaterial,
      tipoServicoId: tipoServicoId,
      descricaoTipoServico: descricaoTipoServico,
      descricao: descricao,
      quantidade: quantidade,
      valorUnitario: valorUnitario,
      subtotal: subtotal,
    );
  }
}