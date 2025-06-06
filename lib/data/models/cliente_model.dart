// lib/data/models/cliente_model.dart

import 'package:json_annotation/json_annotation.dart';
import 'package:nordeste_servicos_app/data/models/tipo_cliente.dart';

// Importar o enum TipoCliente e a entidade Cliente

import 'package:nordeste_servicos_app/domain/entities/cliente.dart';

part 'cliente_model.g.dart'; // Gerado pelo build_runner

// Modelo para representar os dados do Cliente recebidos da API
@JsonSerializable()
class ClienteModel {
  final int id; // ID geralmente não é nulo ao receber da API

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

  // Construtor
  ClienteModel({
    required this.id,
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

  // Métodos gerados pelo json_serializable:
  factory ClienteModel.fromJson(Map<String, dynamic> json) => _$ClienteModelFromJson(json);
  Map<String, dynamic> toJson() => _$ClienteModelToJson(this);

  // Método para converter Model para Entity (camada Domain)
  Cliente toEntity() {
    return Cliente(
      id: id,
      tipoCliente: tipoCliente,
      nomeCompleto: nomeCompleto,
      cpfCnpj: cpfCnpj,
      email: email,
      telefonePrincipal: telefonePrincipal,
      telefoneAdicional: telefoneAdicional,
      cep: cep,
      rua: rua,
      numero: numero,
      complemento: complemento,
      bairro: bairro,
      cidade: cidade,
      estado: estado,
    );
  }
}

