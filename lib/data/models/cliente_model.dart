// lib/data/models/cliente_model.dart

import 'package:json_annotation/json_annotation.dart';
import 'package:nordeste_servicos_app/data/models/tipo_cliente.dart';
import 'package:nordeste_servicos_app/domain/entities/cliente.dart';

part 'cliente_model.g.dart'; // Gerado pelo build_runner

// Modelo para representar os dados do Cliente recebidos da API
@JsonSerializable()
class ClienteModel {
  final int id;

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

  /// Converte uma instância da entidade [Cliente] para o modelo [ClienteModel].
  factory ClienteModel.fromEntity(Cliente entity) {
    // O '!' em entity.id! é usado porque o modelo espera um ID não nulo,
    // e assumimos que uma entidade que está sendo convertida para ser enviada (ex: update) já possui um ID.
    // Se você for criar um cliente, o ID é gerado pelo backend, então este método não seria usado para a requisição de criação.
    return ClienteModel(
      id: entity.id!,
      tipoCliente: entity.tipoCliente,
      nomeCompleto: entity.nomeCompleto,
      cpfCnpj: entity.cpfCnpj,
      email: entity.email,
      telefonePrincipal: entity.telefonePrincipal,
      telefoneAdicional: entity.telefoneAdicional,
      cep: entity.cep,
      rua: entity.rua,
      numero: entity.numero,
      complemento: entity.complemento,
      bairro: entity.bairro,
      cidade: entity.cidade,
      estado: entity.estado,
    );
  }
}