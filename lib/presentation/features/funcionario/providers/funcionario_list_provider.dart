import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';
import '../../../../domain/entities/usuario.dart';
import '../../../../domain/repositories/usuario_repository.dart';
import '../../../shared/providers/repository_providers.dart';

// 1. O Estado
class FuncionarioListState extends Equatable {
  final List<Usuario> funcionarios;
  final bool isLoading;
  final String? errorMessage;

  const FuncionarioListState({
    this.funcionarios = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  FuncionarioListState copyWith({
    List<Usuario>? funcionarios,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return FuncionarioListState(
      funcionarios: funcionarios ?? this.funcionarios,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [funcionarios, isLoading, errorMessage];
}

// 2. O Notifier
class FuncionarioListNotifier extends StateNotifier<FuncionarioListState> {
  final UsuarioRepository _usuarioRepository;

  FuncionarioListNotifier(this._usuarioRepository) : super(const FuncionarioListState()) {
    loadFuncionarios();
  }

  Future<void> loadFuncionarios({String? searchTerm, bool refresh = false}) async {
    if (state.isLoading && !refresh) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      // Usando o método que você já tem no repositório
      final funcionarios = await _usuarioRepository.getUsuarios();
      // Opcional: Filtrar por nome aqui se o searchTerm for usado
      state = state.copyWith(funcionarios: funcionarios, isLoading: false);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
    }
  }
}

// 3. O Provider
final funcionarioListProvider = StateNotifierProvider<FuncionarioListNotifier, FuncionarioListState>((ref) {
  final usuarioRepository = ref.watch(usuarioRepositoryProvider);
  return FuncionarioListNotifier(usuarioRepository);
});