import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_constants.dart';
import '../models/auth_response.dart';

/// Serviço de autenticação responsável por obter e gerenciar tokens
/// O login é feito automaticamente em background com credenciais padrão
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Credenciais padrão para obter token (API não tem usuários reais)
  static const String _defaultUsername = 'joaosilva';
  static const String _defaultPassword = 'senha123';

  // Keys para SharedPreferences
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenTypeKey = 'token_type';

  // Tokens em memória para acesso rápido
  String? _accessToken;
  String? _refreshToken;
  String? _tokenType;
  bool _isInitialized = false;

  // Getters
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  String? get tokenType => _tokenType;
  bool get hasToken => _accessToken != null && _accessToken!.isNotEmpty;
  bool get isInitialized => _isInitialized;

  /// Inicializa o serviço - carrega tokens salvos ou faz login automático
  Future<void> init() async {
    if (_isInitialized) return;
    
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString(_accessTokenKey);
    _refreshToken = prefs.getString(_refreshTokenKey);
    _tokenType = prefs.getString(_tokenTypeKey);
    
    debugPrint('AuthService: Token carregado: ${hasToken ? "sim" : "não"}');
    
    // Se não tem token, faz login automático
    if (!hasToken) {
      debugPrint('AuthService: Sem token, fazendo login automático...');
      await _autoLogin();
    } else {
      // Verifica se o token ainda é válido tentando uma requisição
      // Se falhar, limpa e faz login novamente
      debugPrint('AuthService: Token encontrado, verificando validade...');
      final isValid = await _verifyToken();
      if (!isValid) {
        debugPrint('AuthService: Token inválido/expirado, limpando e fazendo novo login...');
        await clearTokens();
        await _autoLogin();
      }
    }
    
    _isInitialized = true;
  }
  
  /// Verifica se o token atual é válido
  Future<bool> _verifyToken() async {
    try {
      // Tenta fazer uma requisição simples para verificar o token
      final uri = Uri.parse('${AppConstants.apiBaseUrl}/api/dicas');
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
      );
      debugPrint('AuthService: Verificação de token - Status: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('AuthService: Erro ao verificar token - $e');
      return false;
    }
  }
  
  /// Faz login automático com credenciais padrão
  Future<void> _autoLogin() async {
    final result = await login(_defaultUsername, _defaultPassword);
    if (!result.isSuccess) {
      // Se falhar, tenta novamente depois (pode ser problema de conexão)
      debugPrint('AuthService: Auto-login falhou - ${result.error}');
    }
  }
  
  /// Garante que temos um token válido antes de fazer requisições
  Future<void> ensureAuthenticated() async {
    if (!_isInitialized) {
      await init();
    }
    if (!hasToken) {
      await _autoLogin();
    }
  }

  /// Realiza login e salva os tokens
  Future<AuthResult> login(String username, String senha) async {
    try {
      final uri = Uri.parse('${AppConstants.apiBaseUrl}/api/auth/login');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'senha': senha,
        }),
      );

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(jsonDecode(response.body));
        await _saveTokens(authResponse);
        return AuthResult.success(authResponse);
      } else {
        String message = 'Erro ao fazer login';
        try {
          final json = jsonDecode(response.body);
          message = json['message'] ?? json['error'] ?? message;
        } catch (_) {}
        return AuthResult.error(message, statusCode: response.statusCode);
      }
    } catch (e) {
      return AuthResult.error('Erro de conexão: $e');
    }
  }

  /// Atualiza o access token usando o refresh token
  Future<AuthResult> refreshAccessToken() async {
    if (_refreshToken == null) {
      // Se não tem refresh token, faz login novamente
      await _autoLogin();
      return hasToken 
          ? AuthResult.success(AuthResponse(
              accessToken: _accessToken!,
              refreshToken: _refreshToken!,
              tokenType: _tokenType ?? 'Bearer',
            ))
          : AuthResult.error('Não foi possível obter token');
    }

    try {
      final uri = Uri.parse('${AppConstants.apiBaseUrl}/api/auth/refresh');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': _refreshToken}),
      );

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(jsonDecode(response.body));
        await _saveTokens(authResponse);
        return AuthResult.success(authResponse);
      } else {
        // Token inválido ou expirado - faz login novamente
        debugPrint('AuthService: Refresh falhou, fazendo auto-login');
        await _autoLogin();
        return hasToken 
            ? AuthResult.success(AuthResponse(
                accessToken: _accessToken!,
                refreshToken: _refreshToken!,
                tokenType: _tokenType ?? 'Bearer',
              ))
            : AuthResult.error('Sessão expirada');
      }
    } catch (e) {
      debugPrint('AuthService: Erro no refresh - $e');
      // Em caso de erro, tenta login novamente
      await _autoLogin();
      return hasToken 
          ? AuthResult.success(AuthResponse(
              accessToken: _accessToken!,
              refreshToken: _refreshToken!,
              tokenType: _tokenType ?? 'Bearer',
            ))
          : AuthResult.error('Erro de conexão');
    }
  }

  /// Salva tokens no SharedPreferences e em memória
  Future<void> _saveTokens(AuthResponse authResponse) async {
    _accessToken = authResponse.accessToken;
    _refreshToken = authResponse.refreshToken;
    _tokenType = authResponse.tokenType;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, authResponse.accessToken);
    await prefs.setString(_refreshTokenKey, authResponse.refreshToken);
    await prefs.setString(_tokenTypeKey, authResponse.tokenType);
  }

  /// Limpa todos os tokens salvos (usado para forçar novo login)
  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    _tokenType = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_tokenTypeKey);
  }
}

/// Resultado de operações de autenticação
class AuthResult {
  final AuthResponse? data;
  final String? error;
  final int? statusCode;
  final bool isSuccess;

  AuthResult._({
    this.data,
    this.error,
    this.statusCode,
    required this.isSuccess,
  });

  factory AuthResult.success(AuthResponse data) {
    return AuthResult._(data: data, isSuccess: true);
  }

  factory AuthResult.error(String message, {int? statusCode}) {
    return AuthResult._(
      error: message,
      statusCode: statusCode,
      isSuccess: false,
    );
  }
}

