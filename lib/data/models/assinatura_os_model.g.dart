// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assinatura_os_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssinaturaOSModel _$AssinaturaOSModelFromJson(Map<String, dynamic> json) =>
    AssinaturaOSModel(
      id: (json['id'] as num?)?.toInt(),
      ordemServicoId: (json['ordemServicoId'] as num).toInt(),
      urlAcesso: json['urlAcesso'] as String,
      tipoConteudo: json['tipoConteudo'] as String,
      tamanhoArquivo: (json['tamanhoArquivo'] as num?)?.toInt(),
      dataHoraColeta: DateTime.parse(json['dataHoraColeta'] as String),
    );

Map<String, dynamic> _$AssinaturaOSModelToJson(AssinaturaOSModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ordemServicoId': instance.ordemServicoId,
      'urlAcesso': instance.urlAcesso,
      'tipoConteudo': instance.tipoConteudo,
      'tamanhoArquivo': instance.tamanhoArquivo,
      'dataHoraColeta': instance.dataHoraColeta.toIso8601String(),
    };
