// lib/data/models/orcamento_model.dart

import 'package:json_annotation/json_annotation.dart';
import 'package:nordeste_servicos_app/data/models/status_orcamento_model.dart';

import '../../domain/entities/orcamento.dart'; // Importe a entidade Orcamento


part 'orcamento_model.g.dart';

@JsonSerializable()
class OrcamentoModel {
  final int? id;
  final String numeroOrcamento;
  final DateTime dataCriacao;
  final DateTime dataValidade;
  final StatusOrcamentoModel status; // Tipo correto

  final int clienteId;
  final String? nomeCliente;
  final int? ordemServicoOrigemId;

  final String? observacoesCondicoes;
  final double? valorTotal;

  OrcamentoModel({
    this.id,
    required this.numeroOrcamento,
    required this.dataCriacao,
    required this.dataValidade,
    required this.status,
    required this.clienteId,
    this.nomeCliente,
    this.ordemServicoOrigemId,
    this.observacoesCondicoes,
    this.valorTotal,
  });

  factory OrcamentoModel.fromJson(Map<String, dynamic> json) => _$OrcamentoModelFromJson(json);
  Map<String, dynamic> toJson() => _$OrcamentoModelToJson(this);

// Método para converter para Entity - CORRIGIDO
  Orcamento toEntity() {
    return Orcamento(
      id: id,
      numeroOrcamento: numeroOrcamento,
      dataCriacao: dataCriacao,
      dataValidade: dataValidade,
      status: status,
      clienteId: clienteId,
      nomeCliente: nomeCliente,
      ordemServicoOrigemId: ordemServicoOrigemId,
      observacoesCondicoes: observacoesCondicoes,
      valorTotal: valorTotal,
    );
  }
}