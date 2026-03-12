// lib/data/models/nota_fiscal_model.dart

import '../../domain/entities/nota_fiscal.dart';

class NotaFiscalModel {
  final int? id;
  final String? tipo;
  final int? fornecedorId;
  final String? fornecedorNome;
  final int? clienteId;
  final String? clienteNome;
  final String? nomeEmitente;
  final String? cnpjEmitente;
  final DateTime? dataEmissao;
  final String? numeroNota;
  final double? valorTotal;
  final String? formaPagamento;
  final String? descricao;
  final String? observacoes;

  NotaFiscalModel({
    this.id,
    this.tipo,
    this.fornecedorId,
    this.fornecedorNome,
    this.clienteId,
    this.clienteNome,
    this.nomeEmitente,
    this.cnpjEmitente,
    this.dataEmissao,
    this.numeroNota,
    this.valorTotal,
    this.formaPagamento,
    this.descricao,
    this.observacoes,
  });

  factory NotaFiscalModel.fromJson(Map<String, dynamic> json) {
    return NotaFiscalModel(
      id: (json['id'] as num?)?.toInt(),
      tipo: json['tipo'] as String?,
      fornecedorId: (json['fornecedorId'] as num?)?.toInt(),
      fornecedorNome: json['fornecedorNome'] as String?,
      clienteId: (json['clienteId'] as num?)?.toInt(),
      clienteNome: json['clienteNome'] as String?,
      nomeEmitente: json['nomeEmitente'] as String?,
      cnpjEmitente: json['cnpjEmitente'] as String?,
      dataEmissao: json['dataEmissao'] != null ? DateTime.tryParse(json['dataEmissao'].toString()) : null,
      numeroNota: json['numeroNota'] as String?,
      valorTotal: (json['valorTotal'] as num?)?.toDouble(),
      formaPagamento: json['formaPagamento'] as String?,
      descricao: json['descricao'] as String?,
      observacoes: json['observacoes'] as String?,
    );
  }

  NotaFiscal toEntity() {
    return NotaFiscal(
      id: id,
      tipo: tipo,
      fornecedorId: fornecedorId,
      fornecedorNome: fornecedorNome,
      clienteId: clienteId,
      clienteNome: clienteNome,
      nomeEmitente: nomeEmitente,
      cnpjEmitente: cnpjEmitente,
      dataEmissao: dataEmissao,
      numeroNota: numeroNota,
      valorTotal: valorTotal,
      formaPagamento: formaPagamento,
      descricao: descricao,
      observacoes: observacoes,
    );
  }
}
