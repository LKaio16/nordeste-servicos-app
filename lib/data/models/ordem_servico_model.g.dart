// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ordem_servico_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrdemServicoModel _$OrdemServicoModelFromJson(Map<String, dynamic> json) =>
    OrdemServicoModel(
      id: (json['id'] as num?)?.toInt(),
      numeroOS: json['numeroOS'] as String,
      status: $enumDecode(_$StatusOSModelEnumMap, json['status']),
      dataAbertura: json['dataAbertura'] == null
          ? null
          : DateTime.parse(json['dataAbertura'] as String),
      dataAgendamento: json['dataAgendamento'] == null
          ? null
          : DateTime.parse(json['dataAgendamento'] as String),
      dataFechamento: json['dataFechamento'] == null
          ? null
          : DateTime.parse(json['dataFechamento'] as String),
      dataHoraEmissao: json['dataHoraEmissao'] == null
          ? null
          : DateTime.parse(json['dataHoraEmissao'] as String),
      clienteId: (json['clienteId'] as num).toInt(),
      nomeCliente: json['nomeCliente'] as String?,
      equipamentoId: (json['equipamentoId'] as num).toInt(),
      descricaoEquipamento: json['descricaoEquipamento'] as String?,
      tecnicoAtribuidoModel: json['tecnicoAtribuido'] == null
          ? null
          : UsuarioModel.fromJson(
              json['tecnicoAtribuido'] as Map<String, dynamic>),
      problemaRelatado: json['problemaRelatado'] as String?,
      analiseFalha: json['analiseFalha'] as String?,
      solucaoAplicada: json['solucaoAplicada'] as String?,
      prioridade:
          $enumDecodeNullable(_$PrioridadeOSModelEnumMap, json['prioridade']),
    );

Map<String, dynamic> _$OrdemServicoModelToJson(OrdemServicoModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'numeroOS': instance.numeroOS,
      'status': _$StatusOSModelEnumMap[instance.status]!,
      'dataAbertura': instance.dataAbertura?.toIso8601String(),
      'dataAgendamento': instance.dataAgendamento?.toIso8601String(),
      'dataFechamento': instance.dataFechamento?.toIso8601String(),
      'dataHoraEmissao': instance.dataHoraEmissao?.toIso8601String(),
      'clienteId': instance.clienteId,
      'nomeCliente': instance.nomeCliente,
      'equipamentoId': instance.equipamentoId,
      'descricaoEquipamento': instance.descricaoEquipamento,
      'tecnicoAtribuido': instance.tecnicoAtribuidoModel?.toJson(),
      'problemaRelatado': instance.problemaRelatado,
      'analiseFalha': instance.analiseFalha,
      'solucaoAplicada': instance.solucaoAplicada,
      'prioridade': _$PrioridadeOSModelEnumMap[instance.prioridade],
    };

const _$StatusOSModelEnumMap = {
  StatusOSModel.EM_ABERTO: 'EM_ABERTO',
  StatusOSModel.ATRIBUIDA: 'ATRIBUIDA',
  StatusOSModel.EM_ANDAMENTO: 'EM_ANDAMENTO',
  StatusOSModel.PENDENTE_PECAS: 'PENDENTE_PECAS',
  StatusOSModel.AGUARDANDO_APROVACAO: 'AGUARDANDO_APROVACAO',
  StatusOSModel.CONCLUIDA: 'CONCLUIDA',
  StatusOSModel.ENCERRADA: 'ENCERRADA',
  StatusOSModel.CANCELADA: 'CANCELADA',
};

const _$PrioridadeOSModelEnumMap = {
  PrioridadeOSModel.BAIXA: 'BAIXA',
  PrioridadeOSModel.MEDIA: 'MEDIA',
  PrioridadeOSModel.ALTA: 'ALTA',
  PrioridadeOSModel.URGENTE: 'URGENTE',
};
