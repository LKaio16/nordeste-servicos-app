// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_orcamento_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ItemOrcamentoModel _$ItemOrcamentoModelFromJson(Map<String, dynamic> json) =>
    ItemOrcamentoModel(
      id: (json['id'] as num?)?.toInt(),
      orcamentoId: (json['orcamentoId'] as num).toInt(),
      pecaMaterialId: (json['pecaMaterialId'] as num?)?.toInt(),
      codigoPecaMaterial: json['codigoPecaMaterial'] as String?,
      descricaoPecaMaterial: json['descricaoPecaMaterial'] as String?,
      tipoServicoId: (json['tipoServicoId'] as num?)?.toInt(),
      descricaoTipoServico: json['descricaoTipoServico'] as String?,
      descricao: json['descricao'] as String,
      quantidade: (json['quantidade'] as num).toDouble(),
      valorUnitario: (json['valorUnitario'] as num).toDouble(),
      subtotal: (json['subtotal'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ItemOrcamentoModelToJson(ItemOrcamentoModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orcamentoId': instance.orcamentoId,
      'pecaMaterialId': instance.pecaMaterialId,
      'codigoPecaMaterial': instance.codigoPecaMaterial,
      'descricaoPecaMaterial': instance.descricaoPecaMaterial,
      'tipoServicoId': instance.tipoServicoId,
      'descricaoTipoServico': instance.descricaoTipoServico,
      'descricao': instance.descricao,
      'quantidade': instance.quantidade,
      'valorUnitario': instance.valorUnitario,
      'subtotal': instance.subtotal,
    };
