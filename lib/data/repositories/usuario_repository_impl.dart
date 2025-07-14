// lib/data/repositories/usuario_repository_impl.dart

import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/error/exceptions.dart';
import '../../domain/entities/auth_result.dart';
import '../../domain/entities/desempenho_tecnico.dart';
import '../models/desempenho_tecnico_model.dart';
import '../models/login_response_model.dart';
import '../models/usuario_model.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/repositories/usuario_repository.dart';

class UsuarioRepositoryImpl implements UsuarioRepository {
  final ApiClient apiClient;

  UsuarioRepositoryImpl(this.apiClient);

  @override
  Future<List<Usuario>> getUsuarios() async {
    try {
      final response = await apiClient.get('/usuarios');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data;
        // Mapeia JSON para UsuarioModel e depois para Usuario Entity
        final List<UsuarioModel> usuarioModels = jsonList.map((json) => UsuarioModel.fromJson(json)).toList();
        final List<Usuario> usuarios = usuarioModels.map((model) => model.toEntity()).toList();
        return usuarios;
      } else {
        throw ApiException('Falha ao carregar usuários: Status ${response.statusCode}');
      }
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException('Erro de rede ao carregar usuários: ${e.message}');
    } catch (e) {
      throw ApiException('Erro inesperado ao carregar usuários: ${e.toString()}');
    }
  }

  @override
  Future<Usuario> getUserById(int id) async {
    try {
      final response = await apiClient.get('/usuarios/$id');

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = response.data;
        // Mapeia JSON para UsuarioModel e depois para Usuario Entity
        final UsuarioModel usuarioModel = UsuarioModel.fromJson(json);
        return usuarioModel.toEntity();
      } else {
        throw ApiException('Falha ao carregar usuário ${id}: Status ${response.statusCode}');
      }
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException('Erro de rede ao carregar usuário ${id}: ${e.message}');
    } catch (e) {
      throw ApiException('Erro inesperado ao carregar usuário ${id}: ${e.toString()}');
    }
  }

  @override
  Future<Usuario> createUser(Usuario usuario) async {
    try {
      // *** CORREÇÃO AQUI: Use UsuarioModel.fromEntity para converter a entidade
      //     para o modelo de forma segura, lidando com a nullability.
      final UsuarioModel usuarioModel = UsuarioModel.fromEntity(usuario);

      // Usa o toJson() do Modelo para enviar o corpo da requisição
      final response = await apiClient.post('/usuarios', data: usuarioModel.toJson());

      if (response.statusCode == 201) {
        final Map<String, dynamic> json = response.data;
        final UsuarioModel createdUsuarioModel = UsuarioModel.fromJson(json);
        return createdUsuarioModel.toEntity();
      } else {
        throw ApiException('Falha ao criar usuário: Status ${response.statusCode}');
      }
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException('Erro de rede ao criar usuário: ${e.message}');
    } catch (e) {
      throw ApiException('Erro inesperado ao criar usuário: ${e.toString()}');
    }
  }

  @override
  Future<Usuario> updateUser(Usuario usuario) async {
    try {
      // *** CORREÇÃO AQUI: Use UsuarioModel.fromEntity para converter a entidade
      //     para o modelo de forma segura, lidando com a nullability.
      final UsuarioModel usuarioModel = UsuarioModel.fromEntity(usuario);

      // Usa o toJson() do Modelo para enviar o corpo da requisição
      final response = await apiClient.put('/usuarios/${usuario.id}', data: usuarioModel.toJson());

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = response.data;
        final UsuarioModel updatedUsuarioModel = UsuarioModel.fromJson(json);
        return updatedUsuarioModel.toEntity();
      } else {
        throw ApiException('Falha ao atualizar usuário ${usuario.id}: Status ${response.statusCode}');
      }
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException('Erro de rede ao atualizar usuário ${usuario.id}: ${e.message}');
    } catch (e) {
      throw ApiException('Erro inesperado ao atualizar usuário ${usuario.id}: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteUser(int id) async {
    try {
      final response = await apiClient.delete('/usuarios/$id');

      if (response.statusCode == 204) {
        return;
      } else {
        throw ApiException('Falha ao deletar usuário ${id}: Status ${response.statusCode}');
      }
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException('Erro de rede ao deletar usuário ${id}: ${e.message}');
    } catch (e) {
      throw ApiException('Erro inesperado ao deletar usuário ${id}: ${e.toString()}');
    }
  }

  @override
  Future<AuthResult> login(String email, String password) async {
    try {
      final Map<String, dynamic> loginData = {
        'email': email,
        'senha': password,
      };

      final response = await apiClient.post('/auth/login', data: loginData);

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = response.data;
        final LoginResponseModel loginResponseModel = LoginResponseModel.fromJson(json);

        return AuthResult(
          user: loginResponseModel.toUsuarioEntity(),
          token: loginResponseModel.token,
        );

      } else {
        throw ApiException('Falha no login: Status ${response.statusCode}');
      }

    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw ApiException('Credenciais inválidas.');
      }
      throw ApiException('Erro de rede durante o login: ${e.message}');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Erro inesperado durante o login: ${e.toString()}');
    }
  }

  @override
  Future<List<DesempenhoTecnico>> getDesempenhoTecnicos() async {
    try {
      final response = await apiClient.get('/usuarios/desempenho');
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data;
        return jsonList
            .map((json) => DesempenhoTecnicoModel.fromJson(json).toEntity())
            .toList();
      } else {
        throw ApiException(
            'Falha ao carregar desempenho dos técnicos: Status ${response.statusCode}');
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Erro inesperado ao carregar desempenho: ${e.toString()}');
    }
  }
}