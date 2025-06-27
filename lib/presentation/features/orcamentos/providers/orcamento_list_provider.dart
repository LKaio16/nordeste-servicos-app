import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../domain/entities/orcamento.dart';
import '../../../../domain/repositories/orcamento_repository.dart';
import '../../../shared/providers/repository_providers.dart';

// 1. O Estado da tela de lista
class OrcamentoListState extends Equatable {
  final List<Orcamento> orcamentos;
  final bool isLoading;
  final String? errorMessage;

  const OrcamentoListState({
    this.orcamentos = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  OrcamentoListState copyWith({
    List<Orcamento>? orcamentos,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return OrcamentoListState(
      orcamentos: orcamentos ?? this.orcamentos,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [orcamentos, isLoading, errorMessage];
}

// 2. O Notifier que gerencia o estado
class OrcamentoListNotifier extends StateNotifier<OrcamentoListState> {
  final OrcamentoRepository _repository;

  OrcamentoListNotifier(this._repository) : super(const OrcamentoListState()) {
    loadOrcamentos();
  }

  Future<void> loadOrcamentos({String? searchTerm, bool refresh = false}) async {
    if (state.isLoading && !refresh) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      // Usando o método que você já tem no seu repositório
      final orcamentos = await _repository.getOrcamentos();
      // Futuramente, você pode adicionar a lógica de busca aqui
      state = state.copyWith(orcamentos: orcamentos, isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(errorMessage: e.message, isLoading: false);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erro inesperado: ${e.toString()}', isLoading: false);
    }
  }
}

// 3. O Provider que a UI irá consumir
final orcamentoListProvider = StateNotifierProvider.autoDispose<OrcamentoListNotifier, OrcamentoListState>((ref) {
  return OrcamentoListNotifier(ref.watch(orcamentoRepositoryProvider));
});
