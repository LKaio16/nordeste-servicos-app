// lib/data/models/ordem_servico_model.dart

import 'package:json_annotation/json_annotation.dart';
import 'package:nordeste_servicos_app/data/models/prioridade_os_model.dart';
import 'package:nordeste_servicos_app/data/models/status_os_model.dart';

import '../../domain/entities/ordem_servico.dart'; // Importe a entidade OrdemServico


part 'ordem_servico_model.g.dart';

@JsonSerializable()
class OrdemServicoModel {
  final int? id;
  final String numeroOS;
  final StatusOSModel status;
  final DateTime? dataAbertura;
  final DateTime? dataAgendamento;
  final DateTime? dataFechamento;
  final DateTime? dataHoraEmissao;

  final int clienteId;
  final String? nomeCliente;
  final int equipamentoId;
  final String? descricaoEquipamento;
  final int? tecnicoAtribuidoId;
  final String? nomeTecnicoAtribuido;

  final String? problemaRelatado;
  final String? analiseFalha;
  final String? solucaoAplicada;

  final PrioridadeOSModel? prioridade; // Tipo correto

  OrdemServicoModel({
    this.id,
    required this.numeroOS,
    required this.status,
    this.dataAbertura,
    this.dataAgendamento,
    this.dataFechamento,
    this.dataHoraEmissao,
    required this.clienteId,
    this.nomeCliente,
    required this.equipamentoId,
    this.descricaoEquipamento,
    this.tecnicoAtribuidoId,
    this.nomeTecnicoAtribuido,
    this.problemaRelatado,
    this.analiseFalha,
    this.solucaoAplicada,
    this.prioridade,
  });

  factory OrdemServicoModel.fromJson(Map<String, dynamic> json) =>
      _$OrdemServicoModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrdemServicoModelToJson(this);

  // Método para converter para Entity - CORRIGIDO
  OrdemServico toEntity() {
    // Mapeia do enum do Model para o enum da Entity
    StatusOSModel statusEntity = StatusOSModel.values.firstWhere(
          (e) => e.name == status.name,
      orElse: () => StatusOSModel.EM_ABERTO, // Fallback
    );
    PrioridadeOSModel? prioridadeEntity = prioridade != null ? PrioridadeOSModel.values.firstWhere(
          (e) => e.name == prioridade!.name,
      orElse: () => PrioridadeOSModel.MEDIA, // Fallback
    ) : null;

    return OrdemServico(
      id: id,
      numeroOS: numeroOS,
      status: statusEntity,
      dataAbertura: dataAbertura,
      dataAgendamento: dataAgendamento,
      dataFechamento: dataFechamento,
      dataHoraEmissao: dataHoraEmissao,
      clienteId: clienteId,
      nomeCliente: nomeCliente,
      equipamentoId: equipamentoId,
      descricaoEquipamento: descricaoEquipamento,
      tecnicoAtribuidoId: tecnicoAtribuidoId,
      nomeTecnicoAtribuido: nomeTecnicoAtribuido,
      problemaRelatado: problemaRelatado,
      analiseFalha: analiseFalha,
      solucaoAplicada: solucaoAplicada,
      prioridade: prioridadeEntity,
    );
  }

  // *** NOVO MÉTODO fromEntity ***
  factory OrdemServicoModel.fromEntity(OrdemServico entity) {
    // Mapeia do enum da Entity para o enum do Model
    StatusOSModel statusModel = StatusOSModel.values.firstWhere(
          (m) => m.name == entity.status.name,
      orElse: () => StatusOSModel.EM_ABERTO, // Fallback
    );
    PrioridadeOSModel? prioridadeModel = entity.prioridade != null ? PrioridadeOSModel.values.firstWhere(
          (m) => m.name == entity.prioridade!.name,
      orElse: () => PrioridadeOSModel.MEDIA, // Fallback
    ) : null;

    return OrdemServicoModel(
      id: entity.id,
      numeroOS: entity.numeroOS,
      status: statusModel,
      dataAbertura: entity.dataAbertura,
      dataAgendamento: entity.dataAgendamento,
      dataFechamento: entity.dataFechamento,
      dataHoraEmissao: entity.dataHoraEmissao,
      clienteId: entity.clienteId,
      // Campos de nome/descrição não são enviados na criação/atualização geralmente
      // nomeCliente: entity.nomeCliente,
      equipamentoId: entity.equipamentoId,
      // descricaoEquipamento: entity.descricaoEquipamento,
      tecnicoAtribuidoId: entity.tecnicoAtribuidoId,
      // nomeTecnicoAtribuido: entity.nomeTecnicoAtribuido,
      problemaRelatado: entity.problemaRelatado,
      analiseFalha: entity.analiseFalha,
      solucaoAplicada: entity.solucaoAplicada,
      prioridade: prioridadeModel,
    );
  }
}

