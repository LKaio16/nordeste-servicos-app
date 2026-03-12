// lib/domain/entities/nota_fiscal.dart

class NotaFiscal {
  final int? id;
  final String? tipo; // ENTRADA, SAIDA
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

  NotaFiscal({
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
}
