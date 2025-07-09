// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assinatura_os_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssinaturaOSModel _$AssinaturaOSModelFromJson(Map<String, dynamic> json) =>
    AssinaturaOSModel(
      id: (json['id'] as num?)?.toInt(),
      ordemServicoId: (json['ordemServicoId'] as num).toInt(),
      assinaturaClienteBase64: json['assinaturaClienteBase64'] as String?,
      nomeClienteResponsavel: json['nomeClienteResponsavel'] as String?,
      documentoClienteResponsavel:
          json['documentoClienteResponsavel'] as String?,
      assinaturaTecnicoBase64: json['assinaturaTecnicoBase64'] as String?,
      nomeTecnicoResponsavel: json['nomeTecnicoResponsavel'] as String?,
      dataHoraColeta: json['dataHoraColeta'] == null
          ? null
          : DateTime.parse(json['dataHoraColeta'] as String),
    );

Map<String, dynamic> _$AssinaturaOSModelToJson(AssinaturaOSModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ordemServicoId': instance.ordemServicoId,
      'assinaturaClienteBase64': instance.assinaturaClienteBase64,
      'nomeClienteResponsavel': instance.nomeClienteResponsavel,
      'documentoClienteResponsavel': instance.documentoClienteResponsavel,
      'assinaturaTecnicoBase64': instance.assinaturaTecnicoBase64,
      'nomeTecnicoResponsavel': instance.nomeTecnicoResponsavel,
      'dataHoraColeta': instance.dataHoraColeta?.toIso8601String(),
    };
