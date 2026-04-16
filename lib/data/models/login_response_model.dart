import 'package:nordeste_servicos_app/data/models/perfil_usuario_model.dart';
import 'package:nordeste_servicos_app/domain/entities/usuario.dart';

class LoginResponseModel {
  final int? id;
  final String nome;
  final String cracha;
  final String email;
  final PerfilUsuarioModel perfil;
  final String accessToken;
  final String refreshToken;
  final String? fotoPerfil;
  final String? fotoUrl;

  LoginResponseModel({
    this.id,
    required this.nome,
    required this.cracha,
    required this.email,
    required this.perfil,
    required this.accessToken,
    required this.refreshToken,
    this.fotoPerfil,
    this.fotoUrl,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    final access = json['accessToken'] as String? ?? json['token'] as String?;
    if (access == null) {
      throw const FormatException('Resposta de login sem accessToken');
    }
    final refresh = json['refreshToken'] as String? ?? '';
    final perfilRaw = json['perfil'] as String?;
    final perfil = PerfilUsuarioModel.values.firstWhere(
      (e) => e.name == perfilRaw,
      orElse: () => PerfilUsuarioModel.TECNICO,
    );
    return LoginResponseModel(
      id: (json['id'] as num?)?.toInt(),
      nome: json['nome'] as String,
      cracha: json['cracha'] as String,
      email: json['email'] as String,
      perfil: perfil,
      accessToken: access,
      refreshToken: refresh,
      fotoPerfil: json['fotoPerfil'] as String?,
      fotoUrl: json['fotoUrl'] as String?,
    );
  }

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
