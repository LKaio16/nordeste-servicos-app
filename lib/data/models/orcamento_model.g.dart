// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'orcamento_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrcamentoModel _$OrcamentoModelFromJson(Map<String, dynamic> json) =>
    OrcamentoModel(
      id: (json['id'] as num?)?.toInt(),
      numeroOrcamento: json['numeroOrcamento'] as String,
      dataCriacao: DateTime.parse(json['dataCriacao'] as String),
      dataValidade: DateTime.parse(json['dataValidade'] as String),
      status: $enumDecode(_$StatusOrcamentoModelEnumMap, json['status']),
      clienteId: (json['clienteId'] as num).toInt(),
      nomeCliente: json['nomeCliente'] as String?,
      ordemServicoOrigemId: (json['ordemServicoOrigemId'] as num?)?.toInt(),
      observacoesCondicoes: json['observacoesCondicoes'] as String?,
      valorTotal: (json['valorTotal'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$OrcamentoModelToJson(OrcamentoModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'numeroOrcamento': instance.numeroOrcamento,
      'dataCriacao': instance.dataCriacao.toIso8601String(),
      'dataValidade': instance.dataValidade.toIso8601String(),
      'status': _$StatusOrcamentoModelEnumMap[instance.status]!,
      'clienteId': instance.clienteId,
      'nomeCliente': instance.nomeCliente,
      'ordemServicoOrigemId': instance.ordemServicoOrigemId,
      'observacoesCondicoes': instance.observacoesCondicoes,
      'valorTotal': instance.valorTotal,
    };

const _$StatusOrcamentoModelEnumMap = {
  StatusOrcamentoModel.PENDENTE: 'PENDENTE',
  StatusOrcamentoModel.APROVADO: 'APROVADO',
  StatusOrcamentoModel.REJEITADO: 'REJEITADO',
  StatusOrcamentoModel.CANCELADO: 'CANCELADO',
};
