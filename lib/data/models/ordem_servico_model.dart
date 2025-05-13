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
    return OrdemServico(
      id: id,
      numeroOS: numeroOS,
      status: status,
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
      prioridade: prioridade,
    );
  }
}