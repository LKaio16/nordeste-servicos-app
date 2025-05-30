// lib/data/models/login_response_model.dart
import 'package:json_annotation/json_annotation.dart';
import 'package:nordeste_servicos_app/data/models/perfil_usuario_model.dart'; // Importe o enum de perfil
import 'package:nordeste_servicos_app/domain/entities/usuario.dart'; // Importe a entidade Usuario

part 'login_response_model.g.dart';

@JsonSerializable()
class LoginResponseModel {
  final int? id;
  final String nome;
  final String cracha;
  final String email;
  final PerfilUsuarioModel perfil;
  final String token; // O token JWT

  LoginResponseModel({
    this.id,
    required this.nome,
    required this.cracha,
    required this.email,
    required this.perfil,
    required this.token,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseModelToJson(this);

  // Método para converter o modelo para a entidade Usuario
  Usuario toUsuarioEntity() {
    return Usuario(
      id: id,
      nome: nome,
      cracha: cracha,
      email: email,
      perfil: perfil,
    );
  }
}