// lib/data/models/registro_deslocamento_model.dart

import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/registro_deslocamento.dart';

// Importar entidade se usar a camada domain
// import 'package:nordeste_servicos/domain/entities/registro_deslocamento.dart';

part 'registro_deslocamento_model.g.dart';

@JsonSerializable()
class RegistroDeslocamentoModel {
  final int? id;
  final int ordemServicoId;
  final int tecnicoId;
  final String? nomeTecnico;

  final DateTime data;
  final String placaVeiculo;
  final double? kmInicial;
  final double? kmFinal;
  final double? totalKm;

  final String? saidaDe;
  final String? chegadaEm;

  RegistroDeslocamentoModel({
    this.id,
    required this.ordemServicoId,
    required this.tecnicoId,
    this.nomeTecnico,
    required this.data,
    required this.placaVeiculo,
    this.kmInicial,
    this.kmFinal,
    this.totalKm,
    this.saidaDe,
    this.chegadaEm,
  });

  factory RegistroDeslocamentoModel.fromJson(Map<String, dynamic> json) =>
      _$RegistroDeslocamentoModelFromJson(json);

  Map<String, dynamic> toJson() => _$RegistroDeslocamentoModelToJson(this);

// Método para converter para Entity (se usar camada domain) - COMENTADO
  RegistroDeslocamento toEntity() {
    return RegistroDeslocamento(
      id: id,
      ordemServicoId: ordemServicoId,
      tecnicoId: tecnicoId,
      nomeTecnico: nomeTecnico,
      data: data,
      placaVeiculo: placaVeiculo,
      kmInicial: kmInicial,
      kmFinal: kmFinal,
      totalKm: totalKm,
      saidaDe: saidaDe,
      chegadaEm: chegadaEm,
    );
  }
}
