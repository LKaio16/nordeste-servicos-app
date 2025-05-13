// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'foto_os_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FotoOSModel _$FotoOSModelFromJson(Map<String, dynamic> json) => FotoOSModel(
      id: (json['id'] as num?)?.toInt(),
      ordemServicoId: (json['ordemServicoId'] as num).toInt(),
      urlAcesso: json['urlAcesso'] as String,
      nomeArquivoOriginal: json['nomeArquivoOriginal'] as String,
      tipoConteudo: json['tipoConteudo'] as String,
      tamanhoArquivo: (json['tamanhoArquivo'] as num?)?.toInt(),
      dataUpload: DateTime.parse(json['dataUpload'] as String),
    );

Map<String, dynamic> _$FotoOSModelToJson(FotoOSModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ordemServicoId': instance.ordemServicoId,
      'urlAcesso': instance.urlAcesso,
      'nomeArquivoOriginal': instance.nomeArquivoOriginal,
      'tipoConteudo': instance.tipoConteudo,
      'tamanhoArquivo': instance.tamanhoArquivo,
      'dataUpload': instance.dataUpload.toIso8601String(),
    };
