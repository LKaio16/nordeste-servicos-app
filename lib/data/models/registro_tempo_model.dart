// lib/data/models/registro_tempo_model.dart

import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/registro_tempo.dart';

// Importar entidades relacionadas se usar a camada domain
// import 'package:nordeste_servicos/domain/entities/registro_tempo.dart';

part 'registro_tempo_model.g.dart';

@JsonSerializable()
class RegistroTempoModel {
  final int? id;
  final int ordemServicoId;
  final int tecnicoId;
  final String? nomeTecnico;

  final DateTime horaInicio;
  final DateTime? horaTermino;
  final double? horasTrabalhadas;

  RegistroTempoModel({
    this.id,
    required this.ordemServicoId,
    required this.tecnicoId,
    this.nomeTecnico,
    required this.horaInicio,
    this.horaTermino,
    this.horasTrabalhadas,
  });

  factory RegistroTempoModel.fromJson(Map<String, dynamic> json) =>
      _$RegistroTempoModelFromJson(json);

  Map<String, dynamic> toJson() => _$RegistroTempoModelToJson(this);

  RegistroTempo toEntity() {
    return RegistroTempo(
      id: id,
      ordemServicoId: ordemServicoId,
      tecnicoId: tecnicoId,
      nomeTecnico: nomeTecnico,
      horaInicio: horaInicio,
      horaTermino: horaTermino,
      horasTrabalhadas: horasTrabalhadas,
    );
  }
}
