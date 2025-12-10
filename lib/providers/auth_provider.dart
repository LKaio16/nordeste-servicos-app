import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

/// Provider para gerenciar estado de autenticação no app
/// O login é feito automaticamente em background
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _error;

  // Getters
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  bool get hasToken => _authService.hasToken;
  String? get error => _error;

  /// Inicializa o provider - faz login automático se necessário
  Future<void> init() async {
    if (_isInitialized) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.init();
      _error = null;
    } catch (e) {
      _error = 'Erro ao inicializar autenticação';
      debugPrint('AuthProvider: Erro na inicialização - $e');
    }
    
    _isLoading = false;
    _isInitialized = true;
    notifyListeners();
  }

  /// Garante que temos autenticação antes de fazer requisições
  Future<void> ensureAuthenticated() async {
    await _authService.ensureAuthenticated();
  }

  /// Força renovação do token
  Future<bool> refreshToken() async {
    final result = await _authService.refreshAccessToken();
    if (!result.isSuccess) {
      _error = result.error;
      notifyListeners();
    }
    return result.isSuccess;
  }

  /// Limpa erro
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
