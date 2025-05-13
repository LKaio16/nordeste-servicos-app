// lib/domain/entities/cliente.dart

class Cliente {
  final int? id;
  final String nomeRazaoSocial;
  final String endereco;
  final String telefone;
  final String email;
  final String cnpjCpf;

  Cliente({
    this.id,
    required this.nomeRazaoSocial,
    required this.endereco,
    required this.telefone,
    required this.email,
    required this.cnpjCpf,
  });
}