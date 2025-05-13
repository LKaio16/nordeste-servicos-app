// lib/data/models/item_os_utilizado_model.dart

import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/item_os_utilizado.dart';
// Importar entidade se usar a camada domain
// import 'package:nordeste_servicos/domain/entities/item_os_utilizado.dart';

part 'item_os_utilizado_model.g.dart';

@JsonSerializable()
class ItemOSUtilizadoModel {
  final int? id;
  final int ordemServicoId;
  final int pecaMaterialId;
  final String? codigoPecaMaterial;
  final String? descricaoPecaMaterial;
  final double? precoUnitarioPecaMaterial;

  final int? quantidadeRequisitada;
  final int quantidadeUtilizada;
  final int? quantidadeDevolvida;

  ItemOSUtilizadoModel({
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

  factory ItemOSUtilizadoModel.fromJson(Map<String, dynamic> json) => _$ItemOSUtilizadoModelFromJson(json);
  Map<String, dynamic> toJson() => _$ItemOSUtilizadoModelToJson(this);

// Método para converter para Entity (se usar camada domain) - COMENTADO
  ItemOSUtilizado toEntity() {
    return ItemOSUtilizado(
      id: id,
      ordemServicoId: ordemServicoId,
      pecaMaterialId: pecaMaterialId,
      codigoPecaMaterial: codigoPecaMaterial,
      descricaoPecaMaterial: descricaoPecaMaterial,
      precoUnitarioPecaMaterial: precoUnitarioPecaMaterial,
      quantidadeRequisitada: quantidadeRequisitada,
      quantidadeUtilizada: quantidadeUtilizada,
      quantidadeDevolvida: quantidadeDevolvida,
    );
  }
}