// lib/data/models/equipamento_model.dart

import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/equipamento.dart';
// Importar a entidade Equipamento se usar a camada domain
// import 'package:nordeste_servicos/domain/entities/equipamento.dart';

part 'equipamento_model.g.dart';

@JsonSerializable()
class EquipamentoModel {
  final int? id;
  @JsonKey(includeIfNull: true)
  final String? tipo;
  @JsonKey(includeIfNull: true)
  final String? marcaModelo;
  @JsonKey(includeIfNull: true)
  final String? numeroSerieChassi;
  final double? horimetro;
  final int? clienteId;

  EquipamentoModel({
    this.id,
    this.tipo,
    this.marcaModelo,
    this.numeroSerieChassi,
    this.horimetro,
    this.clienteId,
  });

  factory EquipamentoModel.fromJson(Map<String, dynamic> json) {
    return EquipamentoModel(
      id: (json['id'] as num?)?.toInt(),
      tipo: json['tipo'] as String?,
      marcaModelo: json['marcaModelo'] as String?,
      numeroSerieChassi: json['numeroSerieChassi'] as String?,
      horimetro: (json['horimetro'] as num?)?.toDouble(),
      clienteId: (json['clienteId'] as num?)?.toInt(),
    );
  }
  
  Map<String, dynamic> toJson() => _$EquipamentoModelToJson(this);

// Método para converter para Entity (se usar camada domain) - COMENTADO
  Equipamento toEntity() {
    return Equipamento(
      id: id,
      tipo: tipo ?? '',
      marcaModelo: marcaModelo ?? '',
      numeroSerieChassi: numeroSerieChassi ?? '',
      horimetro: horimetro,
      clienteId: clienteId ?? 0,
    );
  }

  factory EquipamentoModel.fromEntity(Equipamento entity) {
    return EquipamentoModel(
      id: entity.id,
      tipo: entity.tipo,
      marcaModelo: entity.marcaModelo,
      numeroSerieChassi: entity.numeroSerieChassi,
      horimetro: entity.horimetro,
      clienteId: entity.clienteId,
    );
  }
}