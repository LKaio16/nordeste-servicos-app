// lib/presentation/features/auth/providers/auth_state.dart

import '../../../../domain/entities/usuario.dart';

// Classe simples para representar o estado da autenticação
class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final bool isAuthenticated;
  final Usuario? authenticatedUser; // Novo campo para o usuário logado

  AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.isAuthenticated = false,
    this.authenticatedUser, // Inclua no construtor
  });

  // Método helper para criar uma nova instância do estado com valores modificados
  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isAuthenticated,
    Usuario? authenticatedUser, // Inclua no copyWith
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage, // Permite definir como null
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      authenticatedUser: authenticatedUser ?? this.authenticatedUser, // Permite definir como null para logout
    );
  }
}