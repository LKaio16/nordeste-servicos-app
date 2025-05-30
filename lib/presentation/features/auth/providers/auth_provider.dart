// lib/presentation/features/auth/providers/auth_provider.dart

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
    print("AuthProvider: Initializing and checking auth status...");
    _checkAuthStatus(); // Chame no construtor
  }

  Future<void> _checkAuthStatus() async {
    // Garanta que o estado de carregamento seja definido ao iniciar
    state = state.copyWith(isLoading: true, errorMessage: null);
    print("AuthProvider: _checkAuthStatus started, isLoading = true.");

    try {
      final storedData = await _secureStorageService.getLoginData();
      final String? token = storedData['token'];
      final String? userIdStr = storedData['id'];
      final String? userName = storedData['name'];
      final String? userEmail = storedData['email'];
      final String? userCracha = storedData['cracha'];
      final String? userPerfilStr = storedData['perfil'];

      print("AuthProvider: Fetched stored data: $storedData");

      if (token != null && userIdStr != null && userName != null && userEmail != null && userCracha != null && userPerfilStr != null) {
        final Usuario restoredUser = Usuario(
          id: int.tryParse(userIdStr),
          nome: userName,
          email: userEmail,
          cracha: userCracha,
          perfil: PerfilUsuarioModel.values.firstWhere(
                  (e) => e.toString().split('.').last == userPerfilStr,
              orElse: () {
                print('Aviso: Perfil de usuário restaurado inválido "$userPerfilStr". Revertendo para TECNICO.');
                return PerfilUsuarioModel.TECNICO;
              }),
        );

        state = state.copyWith(
          isAuthenticated: true,
          authenticatedUser: restoredUser,
          isLoading: false, // Importante: define isLoading como false
        );
        print("AuthProvider: Session restored for: ${restoredUser.nome}. Token: $token. isLoading = false.");
      } else {
        // Se alguma informação vital estiver faltando, não autentica
        state = state.copyWith(isAuthenticated: false, isLoading: false); // Importante: define isLoading como false
        print("AuthProvider: No persistent session found or incomplete data. isLoading = false.");
      }
    } catch (e) {
      // Captura qualquer erro durante a restauração da sessão e define isLoading como false
      state = state.copyWith(isAuthenticated: false, isLoading: false, errorMessage: 'Falha ao restaurar sessão: ${e.toString()}');
      print("AuthProvider: Error restoring session: ${e.toString()}. isLoading = false.");
      await _secureStorageService.deleteLoginData(); // Limpa dados potencialmente corrompidos
    }
  }

  @override
  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    print("AuthProvider: Login started, isLoading = true.");

    try {
      final AuthResult authResult = await _usuarioRepository.login(email, password);

      await _secureStorageService.saveLoginData(
        token: authResult.token,
        user: authResult.user,
      );

      state = state.copyWith(
        isLoading: false, // Importante: define isLoading como false
        isAuthenticated: true,
        errorMessage: null,
        authenticatedUser: authResult.user,
      );
      print("AuthProvider: Login successful! User: ${authResult.user.nome}. isLoading = false.");

    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, isAuthenticated: false, errorMessage: e.message, authenticatedUser: null); // Define isLoading como false
      print("AuthProvider: API error during login: ${e.message}. isLoading = false.");
    } catch (e) {
      state = state.copyWith(isLoading: false, isAuthenticated: false, errorMessage: 'Ocorreu um erro inesperado durante o login.', authenticatedUser: null); // Define isLoading como false
      print("AuthProvider: Unexpected error during login: ${e.toString()}. isLoading = false.");
    }
  }

  @override
  void logout() async {
    print("AuthProvider: Logout initiated.");
    await _secureStorageService.deleteLoginData();
    // Ao fazer logout, resetamos o estado e definimos isAuthenticated como false
    // e também isLoading como false (pois não estamos mais "carregando" um login)
    state = AuthState(isAuthenticated: false, isLoading: false, authenticatedUser: null, errorMessage: null);
    print("AuthProvider: Logout completed. Persistent data cleared. isLoading = false.");
  }
}