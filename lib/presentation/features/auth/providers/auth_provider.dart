// lib/presentation/features/auth/providers/auth_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../domain/repositories/usuario_repository.dart';
import 'auth_state.dart'; // Importe a classe de estado

import '../../../shared/providers/repository_providers.dart'; // Importe os providers de repositório


// Define o StateNotifierProvider para o estado de autenticação
final authProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  // Obtém a instância do UsuarioRepository através do provider
  final usuarioRepository = ref.read(usuarioRepositoryProvider);
  return AuthStateNotifier(usuarioRepository);
});

// StateNotifier que gerencia o estado AuthState
class AuthStateNotifier extends StateNotifier<AuthState> {
  final UsuarioRepository _usuarioRepository;

  AuthStateNotifier(this._usuarioRepository) : super(AuthState()); // Estado inicial é AuthState()

  // Método para realizar o login real
  Future<void> login(String email, String password) async {
    // 1. Atualiza o estado para isLoading = true e limpa erros anteriores
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // CHAMA O MÉTODO DE LOGIN REAL NO REPOSITÓRIO
      final usuarioLogado = await _usuarioRepository.login(email, password);

      // Se a chamada acima não lançou exceção, o login foi bem-sucedido
      // 2. Atualiza o estado para indicar sucesso no login e armazena o usuário
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        errorMessage: null,
        authenticatedUser: usuarioLogado, // Armazena o usuário retornado
      );
      print("Login bem-sucedido! Usuário: ${usuarioLogado.nome}"); // Para debug

      // TODO: Armazenar token de autenticação e dados do usuário logado de forma persistente
      // (SharedPreferences, SecureStorage). Isso é crucial para manter o usuário logado
      // entre as sessões ou reaberturas do app.

      // TODO: Redirecionar para a tela principal (Dashboard)
      // A navegação geralmente é feita na UI, mas pode ser triggered por um listener no provider.

    } on ApiException catch (e) {
      // Captura exceções customizadas da API/rede lançadas pelo repositório
      state = state.copyWith(isLoading: false, isAuthenticated: false, errorMessage: e.message, authenticatedUser: null);
      print("Erro na API durante o login: ${e.message}"); // Para debug
    }
    // TODO: Se você definiu UnauthorizedException, pode capturá-la especificamente:
    /*
    on UnauthorizedException catch (e) {
       state = state.copyWith(isLoading: false, isAuthenticated: false, errorMessage: 'Credenciais inválidas.', authenticatedUser: null);
       print("Login falhou: Credenciais inválidas."); // Para debug
    }
    */
    catch (e) {
      // Captura outros erros inesperados que não são DioException ou ApiException
      state = state.copyWith(isLoading: false, isAuthenticated: false, errorMessage: 'Ocorreu um erro inesperado durante o login.', authenticatedUser: null);
      print("Erro inesperado durante o login: ${e.toString()}"); // Para debug
    }
  }

  // Método para realizar o logout (simples)
  void logout() {
    // TODO: Chamar endpoint de logout na API (se houver), limpar token/dados armazenados
    state = AuthState(); // Reseta o estado para o padrão (não autenticado)
    print("Logout realizado."); // Para debug
    // TODO: Redirecionar para a tela de Login
  }

// TODO: Adicionar método para verificar status de login inicial ao abrir o app
/*
  Future<void> checkAuthStatus() async {
      // Verifica se há token ou credenciais armazenadas
      // Se sim, tenta obter dados do usuário ou validar token
      // state = state.copyWith(isAuthenticated: true, authenticatedUser: dadosDoUsuario);
      // Se não, state = AuthState(); (já é o padrão)
  }
  */
}