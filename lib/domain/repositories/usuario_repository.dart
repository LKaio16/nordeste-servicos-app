// lib/domain/repositories/usuario_repository.dart

import '../entities/usuario.dart';
import '../../core/error/exceptions.dart';

abstract class UsuarioRepository {
  /// Obtém a lista de todos os usuários.
  Future<List<Usuario>> getUsers();

  /// Obtém um usuário pelo seu ID.
  Future<Usuario> getUserById(int id);

  /// Cria um novo usuário.
  Future<Usuario> createUser(Usuario usuario);

  /// Atualiza um usuário existente.
  Future<Usuario> updateUser(Usuario usuario);

  /// Deleta um usuário pelo seu ID.
  Future<void> deleteUser(int id);

  /// Realiza a autenticação do usuário.
  /// Recebe email/usuário e senha.
  /// Retorna o usuário autenticado em caso de sucesso.
  /// Lança [ApiException], [UnauthorizedException] (se tratar 401), ou outras exceções em caso de falha.
  Future<Usuario> login(String email, String password); // Adicionado este método
}