// lib/domain/entities/auth_result.dart
import 'package:nordeste_servicos_app/domain/entities/usuario.dart';

class AuthResult {
  final Usuario user;
  final String token;

  AuthResult({required this.user, required this.token});
}