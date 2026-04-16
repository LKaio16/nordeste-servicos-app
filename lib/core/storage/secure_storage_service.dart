import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nordeste_servicos_app/domain/entities/usuario.dart';

class SecureStorageService {
  final _storage = const FlutterSecureStorage();

  static const _tokenKey = 'auth_token';
  static const _refreshTokenKey = 'auth_refresh_token';
  static const _userIdKey = 'user_id';
  static const _userNameKey = 'user_name';
  static const _userEmailKey = 'user_email';
  static const _userCrachaKey = 'user_cracha';
  static const _userPerfilKey = 'user_perfil';
  static const _userFotoKey = 'user_foto';

  Future<void> saveLoginData({
    required String accessToken,
    required String refreshToken,
    required Usuario user,
  }) async {
    await _storage.write(key: _tokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
    await _storage.write(key: _userIdKey, value: user.id?.toString());
    await _storage.write(key: _userNameKey, value: user.nome);
    await _storage.write(key: _userEmailKey, value: user.email);
    await _storage.write(key: _userCrachaKey, value: user.cracha);
    await _storage.write(key: _userPerfilKey, value: user.perfil.name);
    await _storage.write(key: _userFotoKey, value: user.fotoPerfil);
  }

  Future<void> updateTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _tokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<Map<String, String?>> getLoginData() async {
    final token = await _storage.read(key: _tokenKey);
    final refreshToken = await _storage.read(key: _refreshTokenKey);
    final id = await _storage.read(key: _userIdKey);
    final name = await _storage.read(key: _userNameKey);
    final email = await _storage.read(key: _userEmailKey);
    final cracha = await _storage.read(key: _userCrachaKey);
    final perfil = await _storage.read(key: _userPerfilKey);
    final foto = await _storage.read(key: _userFotoKey);

    return {
      'token': token,
      'refreshToken': refreshToken,
      'id': id,
      'name': name,
      'email': email,
      'cracha': cracha,
      'perfil': perfil,
      'foto': foto,
    };
  }

  Future<void> deleteLoginData() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _userNameKey);
    await _storage.delete(key: _userEmailKey);
    await _storage.delete(key: _userCrachaKey);
    await _storage.delete(key: _userPerfilKey);
    await _storage.delete(key: _userFotoKey);
  }
}

final secureStorageServiceProvider = Provider((ref) => SecureStorageService());
