// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'registro_deslocamento_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegistroDeslocamentoModel _$RegistroDeslocamentoModelFromJson(
        Map<String, dynamic> json) =>
    RegistroDeslocamentoModel(
      id: (json['id'] as num?)?.toInt(),
      ordemServicoId: (json['ordemServicoId'] as num).toInt(),
      tecnicoId: (json['tecnicoId'] as num).toInt(),
      nomeTecnico: json['nomeTecnico'] as String?,
      data: DateTime.parse(json['data'] as String),
      placaVeiculo: json['placaVeiculo'] as String,
      kmInicial: (json['kmInicial'] as num?)?.toDouble(),
      kmFinal: (json['kmFinal'] as num?)?.toDouble(),
      totalKm: (json['totalKm'] as num?)?.toDouble(),
      saidaDe: json['saidaDe'] as String?,
      chegadaEm: json['chegadaEm'] as String?,
    );

Map<String, dynamic> _$RegistroDeslocamentoModelToJson(
        RegistroDeslocamentoModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ordemServicoId': instance.ordemServicoId,
      'tecnicoId': instance.tecnicoId,
      'nomeTecnico': instance.nomeTecnico,
      'data': instance.data.toIso8601String(),
      'placaVeiculo': instance.placaVeiculo,
      'kmInicial': instance.kmInicial,
      'kmFinal': instance.kmFinal,
      'totalKm': instance.totalKm,
      'saidaDe': instance.saidaDe,
      'chegadaEm': instance.chegadaEm,
    };
