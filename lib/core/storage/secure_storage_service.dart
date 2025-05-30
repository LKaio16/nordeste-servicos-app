// lib/core/storage/secure_storage_service.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Importe para usar Provider
import 'package:nordeste_servicos_app/domain/entities/usuario.dart'; // Importe seu Usuario
import 'package:nordeste_servicos_app/data/models/perfil_usuario_model.dart'; // Para converter a string do perfil

class SecureStorageService {
  final _storage = const FlutterSecureStorage();

  static const _tokenKey = 'auth_token';
  static const _userIdKey = 'user_id';
  static const _userNameKey = 'user_name';
  static const _userEmailKey = 'user_email';
  static const _userCrachaKey = 'user_cracha';
  static const _userPerfilKey = 'user_perfil';

  // Salva o token e os dados básicos do usuário
  Future<void> saveLoginData({
    required String token, // Token agora é obrigatório
    required Usuario user,
  }) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _userIdKey, value: user.id?.toString());
    await _storage.write(key: _userNameKey, value: user.nome);
    await _storage.write(key: _userEmailKey, value: user.email);
    await _storage.write(key: _userCrachaKey, value: user.cracha);
    await _storage.write(key: _userPerfilKey, value: user.perfil.name); // Salva APENAS o nome do enum
  }

  // Lê os dados básicos do usuário e o token
  Future<Map<String, String?>> getLoginData() async {
    final token = await _storage.read(key: _tokenKey);
    final id = await _storage.read(key: _userIdKey);
    final name = await _storage.read(key: _userNameKey);
    final email = await _storage.read(key: _userEmailKey);
    final cracha = await _storage.read(key: _userCrachaKey);
    final perfil = await _storage.read(key: _userPerfilKey);

    return {
      'token': token,
      'id': id,
      'name': name,
      'email': email,
      'cracha': cracha,
      'perfil': perfil,
    };
  }

  // Remove todos os dados de login
  Future<void> deleteLoginData() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _userNameKey);
    await _storage.delete(key: _userEmailKey);
    await _storage.delete(key: _userCrachaKey);
    await _storage.delete(key: _userPerfilKey);
  }
}

// Provider para o serviço de armazenamento
final secureStorageServiceProvider = Provider((ref) => SecureStorageService());