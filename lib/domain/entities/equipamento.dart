// lib/domain/entities/equipamento.dart

class Equipamento {
  final int? id;
  final String tipo;
  final String marcaModelo;
  final String numeroSerieChassi;
  final double? horimetro;
  final int clienteId; // Referência ao ID do cliente

  // Poderia ter o objeto Cliente aqui se a lógica de negócio precisar dele diretamente na entidade
  // final Cliente cliente;

  Equipamento({
    this.id,
    required this.tipo,
    required this.marcaModelo,
    required this.numeroSerieChassi,
    this.horimetro,
    required this.clienteId,
  });
}