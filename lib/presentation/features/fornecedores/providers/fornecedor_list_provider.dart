import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../domain/entities/fornecedor.dart';
import '../../../../domain/repositories/fornecedor_repository.dart';
import '../../../shared/providers/repository_providers.dart';

class FornecedorListState extends Equatable {
  final List<Fornecedor> fornecedores;
  final bool isLoading;
  final String? errorMessage;

  const FornecedorListState({
    this.fornecedores = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  FornecedorListState copyWith({
    List<Fornecedor>? fornecedores,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return FornecedorListState(
      fornecedores: fornecedores ?? this.fornecedores,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [fornecedores, isLoading, errorMessage];
}

class FornecedorListNotifier extends StateNotifier<FornecedorListState> {
  final FornecedorRepository _repository;

  FornecedorListNotifier(this._repository) : super(const FornecedorListState()) {
    loadFornecedores();
  }

  Future<void> loadFornecedores({bool refresh = false, String? searchTerm, String? status}) async {
    if (refresh) {
      state = state.copyWith(isLoading: true, clearError: true);
    } else {
      state = state.copyWith(isLoading: true);
    }
    try {
      final list = await _repository.getFornecedores(searchTerm: searchTerm, status: status);
      state = state.copyWith(fornecedores: list, isLoading: false, clearError: true);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Erro: ${e.toString()}');
    }
  }

  Future<void> refreshFornecedores() => loadFornecedores(refresh: true);

  Future<void> deleteFornecedor(int id) async {
    try {
      await _repository.deleteFornecedor(id);
      await loadFornecedores(refresh: true);
    } on ApiException catch (e) {
      state = state.copyWith(errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erro ao excluir: ${e.toString()}');
    }
  }
}

final fornecedorListProvider = StateNotifierProvider<FornecedorListNotifier, FornecedorListState>((ref) {
  return FornecedorListNotifier(ref.read(fornecedorRepositoryProvider));
});
