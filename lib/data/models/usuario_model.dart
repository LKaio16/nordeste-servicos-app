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
  final String? cracha; // <<< TORNADO OPCIONAL
  final String? email;  // <<< TORNADO OPCIONAL

  final PerfilUsuarioModel perfil;

  // Construtor
  UsuarioModel({
    this.id,
    required this.nome,
    this.cracha, // <<< REMOVIDO 'required'
    this.email,  // <<< REMOVIDO 'required'
    required this.perfil,
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) =>
      _$UsuarioModelFromJson(json);

  Map<String, dynamic> toJson() => _$UsuarioModelToJson(this);

  // Método para converter Model para Entity - CORRIGIDO
  Usuario toEntity() {
    return Usuario(
      id: id,
      nome: nome,
      cracha: cracha, // Continua passando o valor, que agora pode ser null
      email: email,   // Continua passando o valor, que agora pode ser null
      perfil: perfil,
    );
  }

  factory UsuarioModel.fromEntity(Usuario entity) {
    return UsuarioModel(
      id: entity.id,
      nome: entity.nome,
      cracha: entity.cracha, // Passa o valor que pode ser null
      email: entity.email,   // Passa o valor que pode ser null
      perfil: entity.perfil, // Atribuição direta
    );
  }
}

