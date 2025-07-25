// lib/domain/repositories/usuario_repository.dart

import '../entities/auth_result.dart';
import '../entities/desempenho_tecnico.dart';
import '../entities/usuario.dart';
import '../../core/error/exceptions.dart';

abstract class UsuarioRepository {
  /// Obtém a lista de todos os usuários.
  Future<List<Usuario>> getUsuarios();

  /// Obtém um usuário pelo seu ID.
  Future<Usuario> getUserById(int id);

  /// Cria um novo usuário.
  Future<Usuario> createUser(Usuario usuario);

  /// Atualiza um usuário existente.
  Future<Usuario> updateUser(Usuario usuario);

  /// Deleta um usuário pelo seu ID.
  Future<void> deleteUser(int id);

  Future<void> updatePassword(int userId, String newPassword);

  /// Retorna o usuário autenticado em caso de sucesso.
  /// Lança [ApiException], [UnauthorizedException] (se tratar 401), ou outras exceções em caso de falha.
  Future<AuthResult> login(String email, String password); // Altere o tipo de retorno

  Future<List<DesempenhoTecnico>> getDesempenhoTecnicos();
}