// lib/core/network/api_client.dart

import 'package:dio/dio.dart';
import '../../config/app_config.dart';
import '../error/exceptions.dart';
import '../storage/secure_storage_service.dart'; // Importe o SecureStorageService

class ApiClient {
  final Dio _dio;
  final SecureStorageService _secureStorageService; // Injete o serviço de storage

  // Construtor: Agora recebe o Dio e o SecureStorageService
  ApiClient(this._dio, this._secureStorageService) {
    _dio.options.baseUrl = AppConfig.apiBaseUrl;
    _dio.options.connectTimeout = const Duration(seconds: AppConfig.apiTimeoutSeconds);
    _dio.options.receiveTimeout = const Duration(seconds: AppConfig.apiTimeoutSeconds);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'ngrok-skip-browser-warning': 'true', // <--- ADICIONE ESTA LINHA
    };

    // Adiciona Interceptors para logging e autenticação
    _dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));

    // Interceptor para adicionar o token JWT
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Não adiciona o token para a requisição de login (ou registro, se houver)
        if (!options.path.contains('/auth/login') && !options.path.contains('/auth/register')) {
          final storedData = await _secureStorageService.getLoginData();
          final String? token = storedData['token'];
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
            print('Token JWT adicionado ao header: $token'); // Para depuração
          } else {
            print('Nenhum token JWT encontrado ou token vazio.'); // Para depuração
          }
        }
        // Se você quiser garantir que o ngrok-skip-browser-warning seja ADICIONADO A TODAS as requisições,
        // incluindo login, ele já estará nas options.headers definidas acima.
        // Não precisa adicionar novamente aqui, a menos que haja uma lógica específica
        // para removê-lo em algum lugar.
        return handler.next(options);
      },
      onError: (DioException error, handler) async {
        // Tratamento para 401 Unauthorized (token expirado ou inválido)
        if (error.response?.statusCode == 401) {
          print('Erro 401: Token inválido ou expirado. Forçando logout e limpando storage.');
          await _secureStorageService.deleteLoginData(); // Limpa os dados persistentes
          // TODO: Você precisará de um mecanismo para notificar a UI para navegar para a tela de login.
          // Isso geralmente não é feito diretamente no interceptor para evitar dependências de UI.
          // Uma abordagem é usar um EventEmitter, um stream global, ou um listener no authProvider
          // para reagir a essa situação e redirecionar a navegação.
          // Por exemplo, seu authProvider pode ter um método `forceLogout()` que o interceptor chama.
        }
        return handler.next(error);
      },
    ));
  }

  // Métodos genéricos para requisição GET, POST, PUT, DELETE

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

  Future<Response> post(String path, {dynamic data}) async {
    try {
      final response = await _dio.post(path, data: data);
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

  // Método para tratar erros específicos do Dio (permanece o mesmo)
  ApiException _handleError(DioException error) {
    String message;
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = "Tempo limite excedido ao conectar com o servidor.";
        break;
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final responseData = error.response?.data;
        message = "Erro na resposta do servidor: Status $statusCode";
        if (responseData is Map && responseData.containsKey('message')) {
          message += " - ${responseData['message']}";
        }
        if (statusCode == 404) {
          throw NotFoundException("Recurso não encontrado.");
        }
        // Nota: O tratamento de 401 para token expirado/inválido já está no interceptor onError.
        // Se você tiver 401 por credenciais inválidas no login, o DioException.badResponse
        // ainda será capturado e você pode adicionar uma exceção mais específica aqui se quiser.
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
      default: // Para garantir que todos os casos são tratados, embora 'unknown' já cubra muitos.
        message = "Erro desconhecido: ${error.message}";
        break;
    }
    return ApiException(message);
  }
}