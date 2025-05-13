// lib/core/error/exceptions.dart

// Exceção genérica para erros da API
class ApiException implements Exception {
  final String message;

  ApiException(this.message);

  @override
  String toString() {
    return 'ApiException: $message';
  }
}

// Exceção para recursos não encontrados (Status 404)
class NotFoundException extends ApiException {
  NotFoundException(String message) : super(message);
}

// TODO: Adicionar outras exceções customizadas para erros específicos da API, se necessário
// Ex: UnauthorizedException para Status 401
// Ex: ForbiddenException para Status 403
// Ex: BadRequestException para Status 400 (para BusinessException da API)