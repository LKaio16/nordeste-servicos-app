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
  final String searchTerm;

  const OrcamentoListState({
    this.orcamentos = const [],
    this.isLoading = false,
    this.errorMessage,
    this.searchTerm = '',
  });

  OrcamentoListState copyWith({
    List<Orcamento>? orcamentos,
    bool? isLoading,
    String? errorMessage,
    String? searchTerm,
    bool clearError = false,
  }) {
    return OrcamentoListState(
      orcamentos: orcamentos ?? this.orcamentos,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      searchTerm: searchTerm ?? this.searchTerm,
    );
  }

  @override
  List<Object?> get props => [orcamentos, isLoading, errorMessage, searchTerm];
}

// 2. O Notifier que gerencia o estado
class OrcamentoListNotifier extends StateNotifier<OrcamentoListState> {
  final OrcamentoRepository _repository;

  OrcamentoListNotifier(this._repository) : super(const OrcamentoListState()) {
    loadOrcamentos();
  }

  Future<void> loadOrcamentos({bool refresh = false}) async {
    if (state.isLoading && !refresh) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final orcamentos = await _repository.getOrcamentos(searchTerm: state.searchTerm);
      state = state.copyWith(orcamentos: orcamentos, isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(errorMessage: e.message, isLoading: false);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erro inesperado: ${e.toString()}', isLoading: false);
    }
  }

  void updateSearchTerm(String searchTerm) {
    state = state.copyWith(searchTerm: searchTerm);
  }

  Future<void> searchOrcamentos(String searchTerm) async {
    state = state.copyWith(searchTerm: searchTerm);
    await loadOrcamentos();
  }

  Future<void> clearSearch() async {
    state = state.copyWith(searchTerm: '');
    await loadOrcamentos();
  }

  Future<void> refreshOrcamentos() async {
    await loadOrcamentos(refresh: true);
  }
}

// 3. O Provider que a UI irá consumir
final orcamentoListProvider = StateNotifierProvider.autoDispose<OrcamentoListNotifier, OrcamentoListState>((ref) {
  return OrcamentoListNotifier(ref.watch(orcamentoRepositoryProvider));
});
