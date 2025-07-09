import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nordeste_servicos_app/domain/entities/usuario.dart';
import 'package:nordeste_servicos_app/data/models/perfil_usuario_model.dart';

class SecureStorageService {
  final _storage = const FlutterSecureStorage();

  static const _tokenKey = 'auth_token';
  static const _userIdKey = 'user_id';
  static const _userNameKey = 'user_name';
  static const _userEmailKey = 'user_email';
  static const _userCrachaKey = 'user_cracha';
  static const _userPerfilKey = 'user_perfil';
  static const _userFotoKey = 'user_foto'; // <-- CHAVE ADICIONADA

  // Salva o token e os dados do usuário
  Future<void> saveLoginData({
    required String token,
    required Usuario user,
  }) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _userIdKey, value: user.id?.toString());
    await _storage.write(key: _userNameKey, value: user.nome);
    await _storage.write(key: _userEmailKey, value: user.email);
    await _storage.write(key: _userCrachaKey, value: user.cracha);
    await _storage.write(key: _userPerfilKey, value: user.perfil.name);
    await _storage.write(key: _userFotoKey, value: user.fotoPerfil); // <-- LINHA ADICIONADA
  }

  // Lê os dados do usuário e o token
  Future<Map<String, String?>> getLoginData() async {
    final token = await _storage.read(key: _tokenKey);
    final id = await _storage.read(key: _userIdKey);
    final name = await _storage.read(key: _userNameKey);
    final email = await _storage.read(key: _userEmailKey);
    final cracha = await _storage.read(key: _userCrachaKey);
    final perfil = await _storage.read(key: _userPerfilKey);
    final foto = await _storage.read(key: _userFotoKey);

    return {
      'token': token,
      'id': id,
      'name': name,
      'email': email,
      'cracha': cracha,
      'perfil': perfil,
      'foto': foto,
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
    await _storage.delete(key: _userFotoKey);
  }
}

final secureStorageServiceProvider = Provider((ref) => SecureStorageService());