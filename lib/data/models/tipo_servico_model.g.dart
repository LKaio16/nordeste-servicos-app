// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tipo_servico_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TipoServicoModel _$TipoServicoModelFromJson(Map<String, dynamic> json) =>
    TipoServicoModel(
      id: (json['id'] as num?)?.toInt(),
      descricao: json['descricao'] as String,
    );

Map<String, dynamic> _$TipoServicoModelToJson(TipoServicoModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'descricao': instance.descricao,
    };
