// lib/data/models/cliente_request_dto.dart

import 'package:json_annotation/json_annotation.dart';
import 'package:nordeste_servicos_app/data/models/tipo_cliente.dart';



part 'cliente_request_dto.g.dart'; // Gerado pelo build_runner

// DTO para enviar dados de criação/atualização de cliente para a API
@JsonSerializable(includeIfNull: false) // Não inclui campos nulos no JSON enviado
class ClienteRequestDTO {
  final TipoCliente tipoCliente;
  final String nomeCompleto;
  final String cpfCnpj;
  final String email;
  final String telefonePrincipal;
  final String? telefoneAdicional; // Opcional
  final String cep;
  final String rua;
  final String numero;
  final String? complemento; // Opcional
  final String bairro;
  final String cidade;
  final String estado;

  ClienteRequestDTO({
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
  factory ClienteRequestDTO.fromJson(Map<String, dynamic> json) => _$ClienteRequestDTOFromJson(json);
  Map<String, dynamic> toJson() => _$ClienteRequestDTOToJson(this);
}

