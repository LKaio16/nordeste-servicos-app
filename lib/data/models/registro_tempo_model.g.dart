// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'registro_tempo_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegistroTempoModel _$RegistroTempoModelFromJson(Map<String, dynamic> json) =>
    RegistroTempoModel(
      id: (json['id'] as num?)?.toInt(),
      ordemServicoId: (json['ordemServicoId'] as num).toInt(),
      tecnicoId: (json['tecnicoId'] as num).toInt(),
      nomeTecnico: json['nomeTecnico'] as String?,
      tipoServicoId: (json['tipoServicoId'] as num).toInt(),
      descricaoTipoServico: json['descricaoTipoServico'] as String?,
      horaInicio: DateTime.parse(json['horaInicio'] as String),
      horaTermino: json['horaTermino'] == null
          ? null
          : DateTime.parse(json['horaTermino'] as String),
      horasTrabalhadas: (json['horasTrabalhadas'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$RegistroTempoModelToJson(RegistroTempoModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ordemServicoId': instance.ordemServicoId,
      'tecnicoId': instance.tecnicoId,
      'nomeTecnico': instance.nomeTecnico,
      'tipoServicoId': instance.tipoServicoId,
      'descricaoTipoServico': instance.descricaoTipoServico,
      'horaInicio': instance.horaInicio.toIso8601String(),
      'horaTermino': instance.horaTermino?.toIso8601String(),
      'horasTrabalhadas': instance.horasTrabalhadas,
    };
