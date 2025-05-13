// lib/domain/entities/usuario.dart

import '../../data/models/perfil_usuario_model.dart'; // Reutilizando o enum model

class Usuario {
  final int? id;
  final String nome;
  final String cracha;
  final String email;
  final PerfilUsuarioModel perfil;

  Usuario({
    this.id,
    required this.nome,
    required this.cracha,
    required this.email,
    required this.perfil,
  });
}