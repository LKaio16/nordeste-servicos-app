// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'foto_os_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FotoOSModel _$FotoOSModelFromJson(Map<String, dynamic> json) => FotoOSModel(
      id: (json['id'] as num?)?.toInt(),
      ordemServicoId: _ordemServicoIdFromJson(json['ordemServicoId']),
      fotoBase64: json['fotoBase64'] as String?,
      fotoUrl: json['fotoUrl'] as String?,
      descricao: json['descricao'] as String?,
      nomeArquivoOriginal: json['nomeArquivoOriginal'] as String?,
      tipoConteudo: json['tipoConteudo'] as String?,
      tamanhoArquivo: (json['tamanhoArquivo'] as num?)?.toInt(),
      dataUpload: _parseDataUpload(json['dataUpload']),
    );

Map<String, dynamic> _$FotoOSModelToJson(FotoOSModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ordemServicoId': instance.ordemServicoId,
      'fotoBase64': instance.fotoBase64,
      'fotoUrl': instance.fotoUrl,
      'descricao': instance.descricao,
      'nomeArquivoOriginal': instance.nomeArquivoOriginal,
      'tipoConteudo': instance.tipoConteudo,
      'tamanhoArquivo': instance.tamanhoArquivo,
      'dataUpload': instance.dataUpload.toIso8601String(),
    };
