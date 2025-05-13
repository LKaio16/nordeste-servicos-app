// lib/data/models/equipamento_model.dart

import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/equipamento.dart';
// Importar a entidade Equipamento se usar a camada domain
// import 'package:nordeste_servicos/domain/entities/equipamento.dart';

part 'equipamento_model.g.dart';

@JsonSerializable()
class EquipamentoModel {
  final int? id;
  final String tipo;
  final String marcaModelo;
  final String numeroSerieChassi;
  final double? horimetro;
  final int clienteId;

  EquipamentoModel({
    this.id,
    required this.tipo,
    required this.marcaModelo,
    required this.numeroSerieChassi,
    this.horimetro,
    required this.clienteId,
  });

  factory EquipamentoModel.fromJson(Map<String, dynamic> json) => _$EquipamentoModelFromJson(json);
  Map<String, dynamic> toJson() => _$EquipamentoModelToJson(this);

// Método para converter para Entity (se usar camada domain) - COMENTADO
  Equipamento toEntity() {
    return Equipamento(
      id: id,
      tipo: tipo,
      marcaModelo: marcaModelo,
      numeroSerieChassi: numeroSerieChassi,
      horimetro: horimetro,
      clienteId: clienteId,
    );
  }
}