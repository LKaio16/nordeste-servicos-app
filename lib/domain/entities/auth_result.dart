import 'package:nordeste_servicos_app/domain/entities/usuario.dart';

class AuthResult {
  final Usuario user;
  final String accessToken;
  final String refreshToken;

  AuthResult({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });
}
