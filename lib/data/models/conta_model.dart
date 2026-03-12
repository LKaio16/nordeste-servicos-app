// lib/data/models/conta_model.dart

import '../../domain/entities/conta.dart';

class ContaModel {
  final int? id;
  final String? tipo;
  final int? clienteId;
  final String? clienteNome;
  final int? fornecedorId;
  final String? fornecedorNome;
  final String? descricao;
  final double valor;
  final double? valorPago;
  final DateTime? dataVencimento;
  final DateTime? dataPagamento;
  final String? status;
  final String? categoria;
  final String? categoriaFinanceira;
  final String? subcategoria;
  final String? formaPagamento;
  final String? observacoes;

  ContaModel({
    this.id,
    this.tipo,
    this.clienteId,
    this.clienteNome,
    this.fornecedorId,
    this.fornecedorNome,
    this.descricao,
    required this.valor,
    this.valorPago,
    this.dataVencimento,
    this.dataPagamento,
    this.status,
    this.categoria,
    this.categoriaFinanceira,
    this.subcategoria,
    this.formaPagamento,
    this.observacoes,
  });

  factory ContaModel.fromJson(Map<String, dynamic> json) {
    return ContaModel(
      id: (json['id'] as num?)?.toInt(),
      tipo: json['tipo'] as String?,
      clienteId: (json['clienteId'] as num?)?.toInt(),
      clienteNome: json['clienteNome'] as String?,
      fornecedorId: (json['fornecedorId'] as num?)?.toInt(),
      fornecedorNome: json['fornecedorNome'] as String?,
      descricao: json['descricao'] as String?,
      valor: (json['valor'] as num?)?.toDouble() ?? 0.0,
      valorPago: (json['valorPago'] as num?)?.toDouble(),
      dataVencimento: json['dataVencimento'] != null ? DateTime.tryParse(json['dataVencimento'].toString()) : null,
      dataPagamento: json['dataPagamento'] != null ? DateTime.tryParse(json['dataPagamento'].toString()) : null,
      status: json['status'] as String?,
      categoria: json['categoria'] as String?,
      categoriaFinanceira: json['categoriaFinanceira'] as String?,
      subcategoria: json['subcategoria'] as String?,
      formaPagamento: json['formaPagamento'] as String?,
      observacoes: json['observacoes'] as String?,
    );
  }

  Conta toEntity() {
    return Conta(
      id: id,
      tipo: tipo,
      clienteId: clienteId,
      clienteNome: clienteNome,
      fornecedorId: fornecedorId,
      fornecedorNome: fornecedorNome,
      descricao: descricao,
      valor: valor,
      valorPago: valorPago,
      dataVencimento: dataVencimento,
      dataPagamento: dataPagamento,
      status: status,
      categoria: categoria,
      categoriaFinanceira: categoriaFinanceira,
      subcategoria: subcategoria,
      formaPagamento: formaPagamento,
      observacoes: observacoes,
    );
  }
}
