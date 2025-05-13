// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'peca_material_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PecaMaterialModel _$PecaMaterialModelFromJson(Map<String, dynamic> json) =>
    PecaMaterialModel(
      id: (json['id'] as num?)?.toInt(),
      codigo: json['codigo'] as String,
      descricao: json['descricao'] as String,
      preco: (json['preco'] as num?)?.toDouble(),
      estoque: (json['estoque'] as num?)?.toInt(),
    );

Map<String, dynamic> _$PecaMaterialModelToJson(PecaMaterialModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'codigo': instance.codigo,
      'descricao': instance.descricao,
      'preco': instance.preco,
      'estoque': instance.estoque,
    };
