// lib/domain/entities/usuario.dart

import 'package:equatable/equatable.dart';
import 'package:nordeste_servicos_app/data/models/perfil_usuario_model.dart'; // Importa PerfilUsuarioModel se usado diretamente

class Usuario extends Equatable {
  final int? id;
  final String nome;
  final String? cracha; // <<< TORNADO OPCIONAL (String?)
  final String? email;   // <<< TORNADO OPCIONAL (String?)
  final PerfilUsuarioModel perfil; // Ou o enum de domínio correspondente

  const Usuario({
    this.id,
    required this.nome,
    this.cracha, // <<< REMOVIDO 'required'
    this.email,   // <<< REMOVIDO 'required'
    required this.perfil,
  });

  @override
  List<Object?> get props => [id, nome, cracha, email, perfil];
}