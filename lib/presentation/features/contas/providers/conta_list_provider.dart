import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../domain/entities/conta.dart';
import '../../../../domain/repositories/conta_repository.dart';
import '../../../shared/providers/repository_providers.dart';

class ContaListState extends Equatable {
  final List<Conta> contas;
  final bool isLoading;
  final bool isLoadingMore;
  final int currentPage;
  final bool hasMore;
  final int total;
  final int pageSize;
  final String? errorMessage;

  const ContaListState({
    this.contas = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.currentPage = 0,
    this.hasMore = true,
    this.total = 0,
    this.pageSize = 20,
    this.errorMessage,
  });

  ContaListState copyWith({
    List<Conta>? contas,
    bool? isLoading,
    bool? isLoadingMore,
    int? currentPage,
    bool? hasMore,
    int? total,
    int? pageSize,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ContaListState(
      contas: contas ?? this.contas,
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
  List<Object?> get props => [contas, isLoading, isLoadingMore, currentPage, hasMore, total, pageSize, errorMessage];
}

class ContaListNotifier extends StateNotifier<ContaListState> {
  final ContaRepository _repository;

  ContaListNotifier(this._repository) : super(const ContaListState()) {
    loadContas();
  }

  Future<void> loadContas({
    bool refresh = false,
    bool loadMore = false,
    int? clienteId,
    int? fornecedorId,
    String? tipo,
    String? status,
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
      final result = await _repository.getContasListagem(
        clienteId: clienteId,
        fornecedorId: fornecedorId,
        tipo: tipo,
        status: status,
        page: targetPage,
        size: state.pageSize,
      );
      final List<Conta> list = (result['content'] as List<Conta>? ?? []);
      final bool hasNext = result['hasNext'] == true;
      final int total = (result['totalElements'] as num?)?.toInt() ?? list.length;
      state = state.copyWith(
        contas: loadMore ? [...state.contas, ...list] : list,
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

  Future<void> refreshContas() => loadContas(refresh: true);
  Future<void> loadMoreContas() => loadContas(loadMore: true);

  Future<void> deleteConta(int id) async {
    try {
      await _repository.deleteConta(id);
      await loadContas(refresh: true);
    } on ApiException catch (e) {
      state = state.copyWith(errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erro ao excluir: ${e.toString()}');
    }
  }

  Future<void> marcarComoPaga(int id, {DateTime? dataPagamento, String? formaPagamento}) async {
    try {
      await _repository.marcarComoPaga(id, dataPagamento: dataPagamento, formaPagamento: formaPagamento);
      await loadContas(refresh: true);
    } on ApiException catch (e) {
      state = state.copyWith(errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erro ao marcar como paga: ${e.toString()}');
    }
  }
}

final contaListProvider = StateNotifierProvider<ContaListNotifier, ContaListState>((ref) {
  return ContaListNotifier(ref.read(contaRepositoryProvider));
});
