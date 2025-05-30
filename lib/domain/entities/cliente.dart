// lib/domain/entities/cliente.dart

import '../../data/models/tipo_cliente.dart';

class Cliente {
  final int? id;

  // Informações Pessoais/Empresariais
  final TipoCliente tipoCliente;
  final String nomeCompleto;
  final String cpfCnpj;
  final String email;

  // Contato
  final String telefonePrincipal;
  final String? telefoneAdicional; // Pode ser nulo

  // Endereço
  final String cep;
  final String rua;
  final String numero;
  final String? complemento; // Pode ser nulo
  final String bairro;
  final String cidade;
  final String estado;

  // Campos antigos removidos
  // final String nomeRazaoSocial;
  // final String endereco;
  // final String telefone;
  // final String cnpjCpf;

  Cliente({
    this.id,
    required this.tipoCliente,
    required this.nomeCompleto,
    required this.cpfCnpj,
    required this.email,
    required this.telefonePrincipal,
    this.telefoneAdicional,
    required this.cep,
    required this.rua,
    required this.numero,
    this.complemento,
    required this.bairro,
    required this.cidade,
    required this.estado,
  });

// Opcional: Adicionar método copyWith ou outros helpers se necessário
}

