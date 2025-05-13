// lib/domain/entities/peca_material.dart

class PecaMaterial {
  final int? id;
  final String codigo;
  final String descricao;
  final double? preco;
  final int? estoque;

  PecaMaterial({
    this.id,
    required this.codigo,
    required this.descricao,
    this.preco,
    this.estoque,
  });
}