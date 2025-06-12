// lib/domain/entities/ordem_servico.dart

import 'package:equatable/equatable.dart';
import 'package:nordeste_servicos_app/domain/entities/assinatura_os.dart';
import 'package:nordeste_servicos_app/domain/entities/cliente.dart';
import 'package:nordeste_servicos_app/domain/entities/equipamento.dart'; // <<< 1. IMPORTAR
import 'package:nordeste_servicos_app/domain/entities/foto_os.dart';
import 'package:nordeste_servicos_app/domain/entities/item_os_utilizado.dart';
import 'package:nordeste_servicos_app/domain/entities/registro_deslocamento.dart';
import 'package:nordeste_servicos_app/domain/entities/registro_tempo.dart';
import 'package:nordeste_servicos_app/domain/entities/usuario.dart';
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

  final Cliente cliente;

  final Equipamento equipamento;

  final Usuario? tecnicoAtribuido;
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
    required this.cliente,
    required this.equipamento, // <<< 3. ATUALIZAR CONSTRUTOR
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
    cliente,
    equipamento,
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