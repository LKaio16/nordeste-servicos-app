// lib/data/models/peca_material_model.dart

import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/peca_material.dart';
// Importar a entidade PecaMaterial se usar a camada domain
// import 'package:nordeste_servicos/domain/entities/peca_material.dart';

part 'peca_material_model.g.dart';

@JsonSerializable()
class PecaMaterialModel {
  final int? id;
  final String codigo;
  final String descricao;
  final double? preco; // Pode ser nulo
  final int? estoque; // Pode ser nulo

  PecaMaterialModel({
    this.id,
    required this.codigo,
    required this.descricao,
    this.preco,
    this.estoque,
  });

  factory PecaMaterialModel.fromJson(Map<String, dynamic> json) => _$PecaMaterialModelFromJson(json);
  Map<String, dynamic> toJson() => _$PecaMaterialModelToJson(this);

// Método para converter para Entity (se usar camada domain) - COMENTADO
  PecaMaterial toEntity() {
    return PecaMaterial(
      id: id,
      codigo: codigo,
      descricao: descricao,
      preco: preco,
      estoque: estoque,
    );
  }
}