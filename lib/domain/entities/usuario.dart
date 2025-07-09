// lib/domain/entities/usuario.dart

import 'package:equatable/equatable.dart';
import 'package:nordeste_servicos_app/data/models/perfil_usuario_model.dart';

class Usuario extends Equatable {
  final int? id;
  final String nome;
  final String? cracha;
  final String? email;
  final PerfilUsuarioModel perfil;
  final String? fotoPerfil;

  const Usuario({
    this.id,
    required this.nome,
    this.cracha,
    this.email,
    required this.perfil,
    this.fotoPerfil,
  });

  @override
  List<Object?> get props => [id, nome, cracha, email, perfil, fotoPerfil];
}