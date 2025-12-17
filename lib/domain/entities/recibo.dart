// lib/domain/entities/recibo.dart

class Recibo {
  final int? id;
  final double valor;
  final String cliente;
  final String referenteA;
  final DateTime dataCriacao;
  final String numeroRecibo;

  Recibo({
    this.id,
    required this.valor,
    required this.cliente,
    required this.referenteA,
    required this.dataCriacao,
    required this.numeroRecibo,
  });
}


