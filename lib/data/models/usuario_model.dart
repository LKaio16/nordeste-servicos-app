// lib/data/models/usuario_model.dart

import 'package:json_annotation/json_annotation.dart';
import 'package:nordeste_servicos_app/data/models/perfil_usuario_model.dart';

import '../../domain/entities/usuario.dart'; // Importe a entidade (se usar camada domain)

// Esta linha é necessária para o gerador de código JSON
part 'usuario_model.g.dart'; // O gerador criará este arquivo

@JsonSerializable()
class UsuarioModel {
  final int? id;
  final String nome;
  final String cracha;
  final String email;

  // Não inclua a senha aqui no Model, ela não deve vir na ResponseDTO da API por segurança

  final PerfilUsuarioModel perfil; // Use o enum model

  // Construtor
  UsuarioModel({
    this.id,
    required this.nome,
    required this.cracha,
    required this.email,
    required this.perfil,
  });

// Métodos gerados pelo json_serializable:
  factory UsuarioModel.fromJson(Map<String, dynamic> json) =>
      _$UsuarioModelFromJson(json);

  Map<String, dynamic> toJson() => _$UsuarioModelToJson(this);

// Método para converter Model para Entity (se usar camada Domain) - CORRIGIDO
  Usuario toEntity() {
    return Usuario(
      id: id,
      nome: nome,
      cracha: cracha,
      email: email,
      perfil: perfil, // Atribuição direta, pois o tipo já é o mesmo (PerfilUsuarioModel)
    );
  }
}