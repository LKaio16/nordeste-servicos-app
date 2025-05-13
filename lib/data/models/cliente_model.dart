// lib/data/models/cliente_model.dart

import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/cliente.dart';
//import 'package:nordeste_servicos/domain/entities/cliente.dart'; // Importe a entidade (se usar camada domain)

// Esta linha é necessária para o gerador de código JSON
part 'cliente_model.g.dart'; // O gerador criará este arquivo

// Anotação para indicar que esta classe deve ter código de serialização/desserialização gerado
@JsonSerializable()
class ClienteModel {
  final int? id; // Use int ou String dependendo do tipo do ID no seu banco/API
  final String nomeRazaoSocial;
  final String endereco;
  final String telefone;
  final String email;
  final String cnpjCpf;

  // Construtor
  ClienteModel({
    this.id, // ID pode ser opcional na criação (vem da API na resposta)
    required this.nomeRazaoSocial,
    required this.endereco,
    required this.telefone,
    required this.email,
    required this.cnpjCpf,
  });

// Métodos gerados pelo json_serializable:
factory ClienteModel.fromJson(Map<String, dynamic> json) => _$ClienteModelFromJson(json);
Map<String, dynamic> toJson() => _$ClienteModelToJson(this);

// Opcional: Método para converter Model para Entity (se usar camada Domain)
  Cliente toEntity() {
    return Cliente(
      id: id,
      nomeRazaoSocial: nomeRazaoSocial,
      endereco: endereco,
      telefone: telefone,
      email: email,
      cnpjCpf: cnpjCpf,
    );
  }
}
