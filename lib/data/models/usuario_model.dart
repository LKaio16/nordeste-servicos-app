import 'package:json_annotation/json_annotation.dart';
import 'package:nordeste_servicos_app/data/models/perfil_usuario_model.dart';
import '../../domain/entities/usuario.dart';

part 'usuario_model.g.dart';

@JsonSerializable()
class UsuarioModel {
  final int? id;
  final String nome;
  final String? cracha;
  final String? email;
  final PerfilUsuarioModel perfil;
  final String? fotoPerfil;

  UsuarioModel({
    this.id,
    required this.nome,
    this.cracha,
    this.email,
    required this.perfil,
    this.fotoPerfil,
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) =>
      _$UsuarioModelFromJson(json);

  Map<String, dynamic> toJson() => _$UsuarioModelToJson(this);

  Usuario toEntity() {
    return Usuario(
      id: id,
      nome: nome,
      cracha: cracha,
      email: email,
      perfil: perfil,
      fotoPerfil: fotoPerfil,
    );
  }

  factory UsuarioModel.fromEntity(Usuario entity) {
    return UsuarioModel(
      id: entity.id,
      nome: entity.nome,
      cracha: entity.cracha,
      email: entity.email,
      perfil: entity.perfil,
      fotoPerfil: entity.fotoPerfil,
    );
  }
}