import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../domain/entities/usuario.dart';
import '../../../../domain/repositories/usuario_repository.dart';
import '../../../../domain/entities/auth_result.dart';
import 'auth_state.dart';
import '../../../shared/providers/repository_providers.dart';
import '../../../../data/models/perfil_usuario_model.dart';

final authProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  final usuarioRepository = ref.read(usuarioRepositoryProvider);
  final secureStorageService = ref.read(secureStorageServiceProvider);
  return AuthStateNotifier(usuarioRepository, secureStorageService);
});

class AuthStateNotifier extends StateNotifier<AuthState> {
  final UsuarioRepository _usuarioRepository;
  final SecureStorageService _secureStorageService;

  AuthStateNotifier(this._usuarioRepository, this._secureStorageService) : super(AuthState()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final storedData = await _secureStorageService.getLoginData();
      final String? token = storedData['token'];
      final String? userIdStr = storedData['id'];
      final String? userName = storedData['name'];
      final String? userEmail = storedData['email'];
      final String? userCracha = storedData['cracha'];
      final String? userPerfilStr = storedData['perfil'];
      final String? userFoto = storedData['foto'];

      if (token != null && userIdStr != null && userName != null && userEmail != null && userCracha != null && userPerfilStr != null) {
        final Usuario restoredUser = Usuario(
          id: int.tryParse(userIdStr),
          nome: userName,
          email: userEmail,
          cracha: userCracha,
          perfil: PerfilUsuarioModel.values.firstWhere(
                  (e) => e.toString().split('.').last == userPerfilStr,
              orElse: () => PerfilUsuarioModel.TECNICO),
          fotoPerfil: userFoto, // <-- LINHA ADICIONADA
        );
        state = state.copyWith(
          isAuthenticated: true,
          authenticatedUser: restoredUser,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isAuthenticated: false, isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isAuthenticated: false, isLoading: false, errorMessage: 'Falha ao restaurar sessão: ${e.toString()}');
      await _secureStorageService.deleteLoginData();
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final AuthResult authResult = await _usuarioRepository.login(email, password);
      await _secureStorageService.saveLoginData(
        token: authResult.token,
        user: authResult.user,
      );
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        errorMessage: null,
        authenticatedUser: authResult.user,
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, isAuthenticated: false, errorMessage: e.message, authenticatedUser: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, isAuthenticated: false, errorMessage: 'Ocorreu um erro inesperado durante o login.', authenticatedUser: null);
    }
  }

  void logout() async {
    await _secureStorageService.deleteLoginData();
    state = AuthState(isAuthenticated: false, isLoading: false, authenticatedUser: null, errorMessage: null);
  }
}