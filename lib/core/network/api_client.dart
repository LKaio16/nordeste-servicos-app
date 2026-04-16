// lib/core/network/api_client.dart

import 'package:dio/dio.dart';
import '../../config/app_config.dart';
import '../auth/session_bus.dart';
import '../error/exceptions.dart';
import '../storage/secure_storage_service.dart';

const String _kSkipAuth = 'skipAuth';

class ApiClient {
  final Dio _dio;
  final SecureStorageService _secureStorageService;

  Future<bool>? _refreshInFlight;

  ApiClient(this._dio, this._secureStorageService) {
    _dio.options.baseUrl = AppConfig.apiBaseUrl;
    _dio.options.connectTimeout = const Duration(seconds: AppConfig.apiTimeoutSeconds);
    _dio.options.receiveTimeout = const Duration(seconds: AppConfig.apiTimeoutSeconds);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'ngrok-skip-browser-warning': 'true',
    };

    _dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (options.extra[_kSkipAuth] == true) {
          options.headers.remove('Authorization');
          return handler.next(options);
        }
        if (!options.path.contains('/auth/login') && !options.path.contains('/auth/register')) {
          final storedData = await _secureStorageService.getLoginData();
          final String? token = storedData['token'];
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        }
        return handler.next(options);
      },
      onError: (DioException error, handler) async {
        final status = error.response?.statusCode;
        final path = error.requestOptions.path;

        if (status == 401 &&
            !path.contains('/auth/login') &&
            !path.contains('/auth/register') &&
            !path.contains('/auth/refresh')) {
          final ok = await _refreshTokensLocked();
          if (ok) {
            final opts = error.requestOptions;
            final data = await _secureStorageService.getLoginData();
            final token = data['token'];
            if (token != null && token.isNotEmpty) {
              opts.headers['Authorization'] = 'Bearer $token';
            }
            try {
              final response = await _dio.fetch(opts);
              return handler.resolve(response);
            } on DioException catch (e) {
              return handler.next(e);
            }
          }
          await _secureStorageService.deleteLoginData();
          SessionBus.instance.emitExpired();
        }
        return handler.next(error);
      },
    ));
  }

  Future<bool> _performTokenRefresh() async {
    final stored = await _secureStorageService.getLoginData();
    final refresh = stored['refreshToken'];
    if (refresh == null || refresh.isEmpty) {
      return false;
    }
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refreshToken': refresh},
        options: Options(extra: {_kSkipAuth: true}),
      );
      if (res.statusCode == 200 && res.data != null) {
        final access = res.data!['accessToken'] as String?;
        final newRefresh = res.data!['refreshToken'] as String?;
        if (access == null || newRefresh == null) {
          return false;
        }
        await _secureStorageService.updateTokens(accessToken: access, refreshToken: newRefresh);
        return true;
      }
    } on DioException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
    return false;
  }

  Future<bool> _refreshTokensLocked() {
    _refreshInFlight ??= _performTokenRefresh().whenComplete(() {
      _refreshInFlight = null;
    });
    return _refreshInFlight!;
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw ApiException("Ocorreu um erro inesperado: ${e.toString()}");
    }
  }

  Future<Response> post(String path, {dynamic data, Options? options}) async {
    try {
      final response = await _dio.post(path, data: data, options: options);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw ApiException("Ocorreu um erro inesperado: ${e.toString()}");
    }
  }

  Future<Response> put(String path, {dynamic data}) async {
    try {
      final response = await _dio.put(path, data: data);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw ApiException("Ocorreu um erro inesperado: ${e.toString()}");
    }
  }

  Future<Response> patch(String path, {dynamic data}) async {
    try {
      final response = await _dio.patch(path, data: data);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw ApiException("Ocorreu um erro inesperado: ${e.toString()}");
    }
  }

  Future<Response> delete(String path, {dynamic data}) async {
    try {
      final response = await _dio.delete(path, data: data);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw ApiException("Ocorreu um erro inesperado: ${e.toString()}");
    }
  }

  ApiException _handleError(DioException error) {
    String message;
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = "Tempo limite excedido ao conectar com o servidor.";
        break;
      case DioExceptionType.badResponse:
        final responseData = error.response?.data;
        if (responseData is Map && responseData['message'] is String) {
          message = responseData['message'];
        } else {
          message = "Erro na resposta do servidor: Status ${error.response?.statusCode}.";
        }
        if (error.response?.statusCode == 404) {
          throw NotFoundException("Recurso não encontrado.");
        }
        break;
      case DioExceptionType.cancel:
        message = "Requisição cancelada.";
        break;
      case DioExceptionType.connectionError:
        message = "Falha na conexão com o servidor. Verifique sua internet ou a URL da API.";
        break;
      case DioExceptionType.badCertificate:
        message = "Erro de certificado SSL.";
        break;
      case DioExceptionType.unknown:
        message = "Ocorreu um erro inesperado: ${error.message}";
        break;
    }
    return ApiException(message);
  }
}
