// lib/domain/entities/ordem_servico.dart

import 'package:equatable/equatable.dart';
// Importe as ENTIDADES aqui
import 'package:nordeste_servicos_app/domain/entities/assinatura_os.dart';
import 'package:nordeste_servicos_app/domain/entities/foto_os.dart';
import 'package:nordeste_servicos_app/domain/entities/item_os_utilizado.dart';
import 'package:nordeste_servicos_app/domain/entities/registro_tempo.dart';
import 'package:nordeste_servicos_app/domain/entities/registro_deslocamento.dart';
import 'package:nordeste_servicos_app/domain/entities/usuario.dart'; // <<< A ENTIDADE Usuario

// Se StatusOS e PrioridadeOS são enums que você criou na camada de domínio, importe-os.
// Se eles são apenas os enums da camada de dados que você está usando diretamente nas entidades
// (uma decisão de design que pode ser aceitável para enums simples), então mantenha como está.
import 'package:nordeste_servicos_app/data/models/prioridade_os_model.dart';
import 'package:nordeste_servicos_app/data/models/status_os_model.dart';


class OrdemServico extends Equatable {
  final int? id;
  final String numeroOS;
  final StatusOSModel status;
  final PrioridadeOSModel? prioridade;
  final DateTime? dataAbertura;
  final DateTime? dataAgendamento;
  final DateTime? dataFechamento;
  final DateTime? dataHoraEmissao;

  final int clienteId;
  final String? nomeCliente;
  final int equipamentoId;
  final String? descricaoEquipamento;

  final Usuario? tecnicoAtribuido; // <<< A ENTIDADE Usuario!

  final String? problemaRelatado;
  final String? analiseFalha;
  final String? solucaoAplicada;

  final List<RegistroTempo>? registrosTempo;
  final List<RegistroDeslocamento>? registrosDeslocamento;
  final List<ItemOSUtilizado>? itensUtilizados;
  final List<FotoOS>? fotos;
  final AssinaturaOS? assinatura;

  const OrdemServico({
    this.id,
    required this.numeroOS,
    required this.status,
    this.prioridade,
    this.dataAbertura,
    this.dataAgendamento,
    this.dataFechamento,
    this.dataHoraEmissao,
    required this.clienteId,
    this.nomeCliente,
    required this.equipamentoId,
    this.descricaoEquipamento,
    this.tecnicoAtribuido,
    this.problemaRelatado,
    this.analiseFalha,
    this.solucaoAplicada,
    this.registrosTempo,
    this.registrosDeslocamento,
    this.itensUtilizados,
    this.fotos,
    this.assinatura,
  });

  // REMOVA OS MÉTODOS fromJson, toJson e copyWith DAQUI!
  // Eles pertencem ao OrdemServicoModel.

  @override
  List<Object?> get props => [
    id,
    numeroOS,
    status,
    prioridade,
    dataAbertura,
    dataAgendamento,
    dataFechamento,
    dataHoraEmissao,
    clienteId,
    nomeCliente,
    equipamentoId,
    descricaoEquipamento,
    tecnicoAtribuido,
    problemaRelatado,
    analiseFalha,
    solucaoAplicada,
    registrosTempo,
    registrosDeslocamento,
    itensUtilizados,
    fotos,
    assinatura,
  ];
}