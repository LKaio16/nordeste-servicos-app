// lib/domain/entities/fornecedor.dart

class Fornecedor {
  final int? id;
  final String nome;
  final String? cnpj;
  final String? email;
  final String? telefone;
  final String? endereco;
  final String? cidade;
  final String? estado;
  final String? status; // ATIVO, INATIVO
  final String? observacoes;

  Fornecedor({
    this.id,
    required this.nome,
    this.cnpj,
    this.email,
    this.telefone,
    this.endereco,
    this.cidade,
    this.estado,
    this.status,
    this.observacoes,
  });
}
