import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_constants.dart';
import '../services/auth_service.dart';

/// Cliente HTTP para comunicação com a API
/// Suporta refresh automático de token quando recebe 401
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final String baseUrl = AppConstants.apiBaseUrl;
  final AuthService _authService = AuthService();

  /// Headers padrão para requisições
  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final token = _authService.accessToken;
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// Requisição GET
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? queryParams,
    T Function(dynamic json)? fromJson,
    bool requiresAuth = true,
  }) async {
    return _executeWithRetry(() async {
      var uri = Uri.parse('$baseUrl$endpoint');
      if (queryParams != null) {
        uri = uri.replace(queryParameters: queryParams);
      }
      return await http.get(uri, headers: _headers);
    }, fromJson, requiresAuth);
  }

  /// Requisição POST
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(dynamic json)? fromJson,
    bool requiresAuth = true,
  }) async {
    return _executeWithRetry(() async {
      final uri = Uri.parse('$baseUrl$endpoint');
      return await http.post(
        uri,
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      );
    }, fromJson, requiresAuth);
  }

  /// Requisição PUT
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(dynamic json)? fromJson,
    bool requiresAuth = true,
  }) async {
    return _executeWithRetry(() async {
      final uri = Uri.parse('$baseUrl$endpoint');
      return await http.put(
        uri,
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      );
    }, fromJson, requiresAuth);
  }

  /// Requisição DELETE
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    T Function(dynamic json)? fromJson,
    bool requiresAuth = true,
  }) async {
    return _executeWithRetry(() async {
      final uri = Uri.parse('$baseUrl$endpoint');
      return await http.delete(uri, headers: _headers);
    }, fromJson, requiresAuth);
  }

  /// Executa requisição com retry automático em caso de 401
  Future<ApiResponse<T>> _executeWithRetry<T>(
    Future<http.Response> Function() request,
    T Function(dynamic json)? fromJson,
    bool requiresAuth,
  ) async {
    try {
      var response = await request();

      // Se receber 401 e requer auth, tenta refresh do token
      if (response.statusCode == 401 && requiresAuth) {
        final refreshResult = await _authService.refreshAccessToken();
        if (refreshResult.isSuccess) {
          // Retry da requisição original com novo token
          response = await request();
        } else {
          return ApiResponse.error(
            'Sessão expirada. Faça login novamente.',
            statusCode: 401,
          );
        }
      }

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return ApiResponse.error('Erro de conexão: $e');
    }
  }

  /// Processa a resposta da API
  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(dynamic json)? fromJson,
  ) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return ApiResponse.success(null);
      }
      final json = jsonDecode(response.body);
      if (fromJson != null) {
        return ApiResponse.success(fromJson(json));
      }
      return ApiResponse.success(json as T?);
    } else {
      String message = 'Erro desconhecido';
      try {
        final json = jsonDecode(response.body);
        message = json['message'] ?? json['error'] ?? message;
      } catch (_) {}
      return ApiResponse.error(message, statusCode: response.statusCode);
    }
  }
}

/// Classe wrapper para respostas da API
class ApiResponse<T> {
  final T? data;
  final String? error;
  final int? statusCode;
  final bool isSuccess;

  ApiResponse._({
    this.data,
    this.error,
    this.statusCode,
    required this.isSuccess,
  });

  factory ApiResponse.success(T? data) {
    return ApiResponse._(data: data, isSuccess: true);
  }

  factory ApiResponse.error(String message, {int? statusCode}) {
    return ApiResponse._(
      error: message,
      statusCode: statusCode,
      isSuccess: false,
    );
  }
}
