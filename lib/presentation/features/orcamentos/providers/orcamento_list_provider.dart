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
  final bool isLoadingMore;
  final String? errorMessage;
  final String searchTerm;
  final int currentPage;
  final bool hasMore;
  final int pageSize;
  final int total;

  const OrcamentoListState({
    this.orcamentos = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.searchTerm = '',
    this.currentPage = 0,
    this.hasMore = true,
    this.pageSize = 20,
    this.total = 0,
  });

  OrcamentoListState copyWith({
    List<Orcamento>? orcamentos,
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
    String? searchTerm,
    int? currentPage,
    bool? hasMore,
    int? pageSize,
    int? total,
    bool clearError = false,
    bool append = false,
  }) {
    return OrcamentoListState(
      orcamentos: append && orcamentos != null
          ? [...this.orcamentos, ...orcamentos]
          : (orcamentos ?? this.orcamentos),
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      searchTerm: searchTerm ?? this.searchTerm,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      pageSize: pageSize ?? this.pageSize,
      total: total ?? this.total,
    );
  }

  @override
  List<Object?> get props => [orcamentos, isLoading, isLoadingMore, errorMessage, searchTerm, currentPage, hasMore, pageSize, total];
}

// 2. O Notifier que gerencia o estado
class OrcamentoListNotifier extends StateNotifier<OrcamentoListState> {
  final OrcamentoRepository _repository;

  OrcamentoListNotifier(this._repository) : super(const OrcamentoListState()) {
    loadOrcamentos();
  }

  Future<void> loadOrcamentos({bool refresh = false, bool loadMore = false}) async {
    if (state.isLoading && !refresh && !loadMore) return;
    if (loadMore && (state.isLoadingMore || !state.hasMore)) return;
    final page = loadMore ? state.currentPage + 1 : 0;

    if (loadMore) {
      state = state.copyWith(isLoadingMore: true);
    } else {
      state = state.copyWith(
        isLoading: true,
        clearError: true,
        currentPage: 0,
        hasMore: true,
      );
    }
    try {
      final result = await _repository.getOrcamentosListagem(
        searchTerm: state.searchTerm.isNotEmpty ? state.searchTerm : null,
        page: page,
        size: state.pageSize,
      );
      final List<Orcamento> orcamentos = (result['content'] as List<Orcamento>? ?? []);
      final bool hasMore = result['hasNext'] == true;
      final int total = (result['totalElements'] as int?) ?? 0;

      if (loadMore) {
        state = state.copyWith(
          isLoadingMore: false,
          orcamentos: orcamentos,
          currentPage: page,
          hasMore: hasMore,
          total: total,
          append: true,
        );
      } else {
        state = state.copyWith(
          orcamentos: orcamentos,
          isLoading: false,
          currentPage: page,
          hasMore: hasMore,
          total: total,
        );
      }
    } on ApiException catch (e) {
      state = state.copyWith(errorMessage: e.message, isLoading: false, isLoadingMore: false);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erro inesperado: ${e.toString()}', isLoading: false, isLoadingMore: false);
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

  Future<void> loadMoreOrcamentos() async {
    await loadOrcamentos(loadMore: true);
  }
}

// 3. O Provider que a UI irá consumir
final orcamentoListProvider = StateNotifierProvider.autoDispose<OrcamentoListNotifier, OrcamentoListState>((ref) {
  return OrcamentoListNotifier(ref.watch(orcamentoRepositoryProvider));
});
