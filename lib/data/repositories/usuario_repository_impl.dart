// lib/data/repositories/usuario_repository_impl.dart

import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/error/exceptions.dart'; // Incluindo UnauthorizedException se definida
import '../models/usuario_model.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/repositories/usuario_repository.dart';

class UsuarioRepositoryImpl implements UsuarioRepository {
  final ApiClient apiClient;

  UsuarioRepositoryImpl(this.apiClient);

  @override
  Future<List<Usuario>> getUsers() async {
    try {
      final response = await apiClient.get('/usuarios'); // Endpoint da sua API para listar usuários

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data;
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
      final response = await apiClient.get('/usuarios/$id'); // Endpoint da sua API para buscar usuário por ID

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = response.data;
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
      // Converte a Entidade para o Modelo para poder usar o toJson()
      final UsuarioModel usuarioModel = UsuarioModel(
        // ID não é enviado na criação
        nome: usuario.nome,
        cracha: usuario.cracha,
        email: usuario.email,
        perfil: usuario.perfil,
        // TODO: Se a API de criação de usuário espera SENHA, o UsuarioModel não tem esse campo.
        // Você precisaria de um DTO/Model de requisição específico para a criação.
        // Para a Opção A, estamos assumindo que a API aceita o UsuarioModel sem senha na criação
        // ou que a senha é tratada em outro endpoint/fluxo (ex: convite, reset de senha).
        // SE SUA API PRECISA DA SENHA NO POST DE CRIAÇÃO, esta Opção A pode não funcionar diretamente.
      );

      // Usa o toJson() do Modelo para enviar o corpo da requisição
      final response = await apiClient.post('/usuarios', data: usuarioModel.toJson()); // Endpoint da sua API para criar usuário

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
      // Converte a Entidade para o Modelo para poder usar o toJson()
      final UsuarioModel usuarioModel = UsuarioModel(
        id: usuario.id, // Incluir ID na atualização
        nome: usuario.nome,
        cracha: usuario.cracha,
        email: usuario.email,
        perfil: usuario.perfil,
        // TODO: Se a API de atualização de usuário espera campos específicos ou senha, adapte.
      );

      // Usa o toJson() do Modelo para enviar o corpo da requisição
      final response = await apiClient.put('/usuarios/${usuario.id}', data: usuarioModel.toJson()); // Endpoint da sua API para atualizar usuário

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
      final response = await apiClient.delete('/usuarios/$id'); // Endpoint da sua API para deletar usuário

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
  Future<Usuario> login(String email, String password) async {
    try {
      final Map<String, dynamic> loginData = {
        'email': email,
        'senha': password,
      };

      final response = await apiClient.post('/auth/login', data: loginData);

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = response.data;
        final UsuarioModel usuarioModel = UsuarioModel.fromJson(json);
        // TODO: Se a API retornar um token, você precisa armazená-lo e possivelmente retornar o usuário junto.

        return usuarioModel.toEntity();

      } else {
        throw ApiException('Falha no login: Status ${response.statusCode}');
      }

    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw ApiException('Credenciais inválidas.');
      }
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Erro inesperado durante o login: ${e.toString()}');
    }
  }
}