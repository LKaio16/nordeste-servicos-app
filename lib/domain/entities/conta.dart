// lib/domain/entities/conta.dart

class Conta {
  final int? id;
  final String? tipo; // PAGAR, RECEBER
  final int? clienteId;
  final String? clienteNome;
  final int? fornecedorId;
  final String? fornecedorNome;
  final String? descricao;
  final double valor;
  final double? valorPago;
  final DateTime? dataVencimento;
  final DateTime? dataPagamento;
  final String? status; // PENDENTE, PAGO, VENCIDO
  final String? categoria;
  final String? categoriaFinanceira; // OPERACIONAL, INVESTIMENTO, FINANCIAMENTO
  final String? subcategoria;
  final String? formaPagamento; // BOLETO, CARTAO, PIX, TRANSFERENCIA
  final String? observacoes;

  Conta({
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
}
