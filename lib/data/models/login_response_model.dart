import 'package:json_annotation/json_annotation.dart';
import 'package:nordeste_servicos_app/data/models/perfil_usuario_model.dart';
import 'package:nordeste_servicos_app/domain/entities/usuario.dart';

part 'login_response_model.g.dart';

@JsonSerializable()
class LoginResponseModel {
  final int? id;
  final String nome;
  final String cracha;
  final String email;
  final PerfilUsuarioModel perfil;
  final String token;
  final String? fotoPerfil;

  LoginResponseModel({
    this.id,
    required this.nome,
    required this.cracha,
    required this.email,
    required this.perfil,
    required this.token,
    this.fotoPerfil,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseModelToJson(this);

  // Converte o modelo para a entidade Usuario
  Usuario toUsuarioEntity() {
    return Usuario(
      id: id,
      nome: nome,
      cracha: cracha,
      email: email,
      perfil: perfil,
      fotoPerfil: fotoPerfil,
    );
  }
}