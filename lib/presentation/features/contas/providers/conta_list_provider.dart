import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../domain/entities/conta.dart';
import '../../../../domain/repositories/conta_repository.dart';
import '../../../shared/providers/repository_providers.dart';

class ContaListState extends Equatable {
  final List<Conta> contas;
  final bool isLoading;
  final String? errorMessage;

  const ContaListState({
    this.contas = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  ContaListState copyWith({
    List<Conta>? contas,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ContaListState(
      contas: contas ?? this.contas,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [contas, isLoading, errorMessage];
}

class ContaListNotifier extends StateNotifier<ContaListState> {
  final ContaRepository _repository;

  ContaListNotifier(this._repository) : super(const ContaListState()) {
    loadContas();
  }

  Future<void> loadContas({
    bool refresh = false,
    int? clienteId,
    int? fornecedorId,
    String? tipo,
    String? status,
  }) async {
    if (refresh) {
      state = state.copyWith(isLoading: true, clearError: true);
    } else {
      state = state.copyWith(isLoading: true);
    }
    try {
      final list = await _repository.getContas(
        clienteId: clienteId,
        fornecedorId: fornecedorId,
        tipo: tipo,
        status: status,
      );
      state = state.copyWith(contas: list, isLoading: false, clearError: true);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Erro: ${e.toString()}');
    }
  }

  Future<void> refreshContas() => loadContas(refresh: true);

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
