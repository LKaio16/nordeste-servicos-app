// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ordem_servico_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrdemServicoModel _$OrdemServicoModelFromJson(Map<String, dynamic> json) =>
    OrdemServicoModel(
      id: (json['id'] as num?)?.toInt(),
      numeroOS: json['numeroOS'] as String,
      status: const StatusOSModelConverter().fromJson(json['status'] as String),
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
      tecnicoAtribuidoId: (json['tecnicoAtribuidoId'] as num?)?.toInt(),
      nomeTecnicoAtribuido: json['nomeTecnicoAtribuido'] as String?,
      problemaRelatado: json['problemaRelatado'] as String?,
      analiseFalha: json['analiseFalha'] as String?,
      solucaoAplicada: json['solucaoAplicada'] as String?,
      prioridade: const PrioridadeOSModelConverter()
          .fromJson(json['prioridade'] as String?),
    );

Map<String, dynamic> _$OrdemServicoModelToJson(OrdemServicoModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'numeroOS': instance.numeroOS,
      'status': const StatusOSModelConverter().toJson(instance.status),
      'dataAbertura': instance.dataAbertura?.toIso8601String(),
      'dataAgendamento': instance.dataAgendamento?.toIso8601String(),
      'dataFechamento': instance.dataFechamento?.toIso8601String(),
      'dataHoraEmissao': instance.dataHoraEmissao?.toIso8601String(),
      'clienteId': instance.clienteId,
      'nomeCliente': instance.nomeCliente,
      'equipamentoId': instance.equipamentoId,
      'descricaoEquipamento': instance.descricaoEquipamento,
      'tecnicoAtribuidoId': instance.tecnicoAtribuidoId,
      'nomeTecnicoAtribuido': instance.nomeTecnicoAtribuido,
      'problemaRelatado': instance.problemaRelatado,
      'analiseFalha': instance.analiseFalha,
      'solucaoAplicada': instance.solucaoAplicada,
      'prioridade':
          const PrioridadeOSModelConverter().toJson(instance.prioridade),
    };
