import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../domain/entities/nota_fiscal.dart';
import '../../../../domain/repositories/nota_fiscal_repository.dart';
import '../../../shared/providers/repository_providers.dart';

class NotaFiscalListState extends Equatable {
  final List<NotaFiscal> notasFiscais;
  final bool isLoading;
  final String? errorMessage;

  const NotaFiscalListState({
    this.notasFiscais = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  NotaFiscalListState copyWith({
    List<NotaFiscal>? notasFiscais,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return NotaFiscalListState(
      notasFiscais: notasFiscais ?? this.notasFiscais,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [notasFiscais, isLoading, errorMessage];
}

class NotaFiscalListNotifier extends StateNotifier<NotaFiscalListState> {
  final NotaFiscalRepository _repository;

  NotaFiscalListNotifier(this._repository) : super(const NotaFiscalListState()) {
    loadNotasFiscais();
  }

  Future<void> loadNotasFiscais({
    bool refresh = false,
    int? fornecedorId,
    int? clienteId,
    String? tipo,
  }) async {
    if (refresh) {
      state = state.copyWith(isLoading: true, clearError: true);
    } else {
      state = state.copyWith(isLoading: true);
    }
    try {
      final list = await _repository.getNotasFiscais(
        fornecedorId: fornecedorId,
        clienteId: clienteId,
        tipo: tipo,
      );
      state = state.copyWith(notasFiscais: list, isLoading: false, clearError: true);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Erro: ${e.toString()}');
    }
  }

  Future<void> refreshNotasFiscais() => loadNotasFiscais(refresh: true);

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
