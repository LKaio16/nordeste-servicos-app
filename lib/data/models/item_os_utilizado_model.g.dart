// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_os_utilizado_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ItemOSUtilizadoModel _$ItemOSUtilizadoModelFromJson(
        Map<String, dynamic> json) =>
    ItemOSUtilizadoModel(
      id: (json['id'] as num?)?.toInt(),
      ordemServicoId: (json['ordemServicoId'] as num).toInt(),
      pecaMaterialId: (json['pecaMaterialId'] as num).toInt(),
      codigoPecaMaterial: json['codigoPecaMaterial'] as String?,
      descricaoPecaMaterial: json['descricaoPecaMaterial'] as String?,
      precoUnitarioPecaMaterial:
          (json['precoUnitarioPecaMaterial'] as num?)?.toDouble(),
      quantidadeRequisitada: (json['quantidadeRequisitada'] as num?)?.toInt(),
      quantidadeUtilizada: (json['quantidadeUtilizada'] as num).toInt(),
      quantidadeDevolvida: (json['quantidadeDevolvida'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ItemOSUtilizadoModelToJson(
        ItemOSUtilizadoModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ordemServicoId': instance.ordemServicoId,
      'pecaMaterialId': instance.pecaMaterialId,
      'codigoPecaMaterial': instance.codigoPecaMaterial,
      'descricaoPecaMaterial': instance.descricaoPecaMaterial,
      'precoUnitarioPecaMaterial': instance.precoUnitarioPecaMaterial,
      'quantidadeRequisitada': instance.quantidadeRequisitada,
      'quantidadeUtilizada': instance.quantidadeUtilizada,
      'quantidadeDevolvida': instance.quantidadeDevolvida,
    };
