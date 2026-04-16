import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../domain/entities/nota_fiscal.dart';
import '../../../../domain/repositories/nota_fiscal_repository.dart';
import '../../../shared/providers/repository_providers.dart';

class NotaFiscalListState extends Equatable {
  final List<NotaFiscal> notasFiscais;
  final bool isLoading;
  final bool isLoadingMore;
  final int currentPage;
  final bool hasMore;
  final int total;
  final int pageSize;
  final String? errorMessage;

  const NotaFiscalListState({
    this.notasFiscais = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.currentPage = 0,
    this.hasMore = true,
    this.total = 0,
    this.pageSize = 20,
    this.errorMessage,
  });

  NotaFiscalListState copyWith({
    List<NotaFiscal>? notasFiscais,
    bool? isLoading,
    bool? isLoadingMore,
    int? currentPage,
    bool? hasMore,
    int? total,
    int? pageSize,
    String? errorMessage,
    bool clearError = false,
  }) {
    return NotaFiscalListState(
      notasFiscais: notasFiscais ?? this.notasFiscais,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      total: total ?? this.total,
      pageSize: pageSize ?? this.pageSize,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [notasFiscais, isLoading, isLoadingMore, currentPage, hasMore, total, pageSize, errorMessage];
}

class NotaFiscalListNotifier extends StateNotifier<NotaFiscalListState> {
  final NotaFiscalRepository _repository;

  NotaFiscalListNotifier(this._repository) : super(const NotaFiscalListState()) {
    loadNotasFiscais();
  }

  Future<void> loadNotasFiscais({
    bool refresh = false,
    bool loadMore = false,
    int? fornecedorId,
    int? clienteId,
    String? tipo,
    String? searchTerm,
  }) async {
    if (loadMore) {
      if (!state.hasMore || state.isLoading || state.isLoadingMore) return;
      state = state.copyWith(isLoadingMore: true, clearError: true);
    } else if (refresh) {
      state = state.copyWith(isLoading: true, clearError: true);
    } else {
      state = state.copyWith(isLoading: true);
    }
    try {
      final targetPage = refresh ? 0 : (loadMore ? state.currentPage + 1 : 0);
      final result = await _repository.getNotasFiscaisListagem(
        fornecedorId: fornecedorId,
        clienteId: clienteId,
        tipo: tipo,
        searchTerm: searchTerm,
        page: targetPage,
        size: state.pageSize,
      );
      final List<NotaFiscal> list = (result['content'] as List<NotaFiscal>? ?? []);
      final bool hasNext = result['hasNext'] == true;
      final int total = (result['totalElements'] as num?)?.toInt() ?? list.length;
      state = state.copyWith(
        notasFiscais: loadMore ? [...state.notasFiscais, ...list] : list,
        isLoading: false,
        isLoadingMore: false,
        currentPage: targetPage,
        hasMore: hasNext,
        total: total,
        clearError: true,
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, isLoadingMore: false, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, isLoadingMore: false, errorMessage: 'Erro: ${e.toString()}');
    }
  }

  Future<void> refreshNotasFiscais() => loadNotasFiscais(refresh: true);
  Future<void> loadMoreNotasFiscais() => loadNotasFiscais(loadMore: true);

  Future<void> deleteNotaFiscal(int id) async {
    try {
      await _repository.deleteNotaFiscal(id);
      await loadNotasFiscais(refresh: true);
    } on ApiException catch (e) {
      state = state.copyWith(errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erro ao excluir: ${e.toString()}');
    }
  }
}

final notaFiscalListProvider = StateNotifierProvider<NotaFiscalListNotifier, NotaFiscalListState>((ref) {
  return NotaFiscalListNotifier(ref.read(notaFiscalRepositoryProvider));
});
