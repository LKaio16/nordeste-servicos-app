import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/entities/peca_material.dart';
import '../../../../domain/repositories/peca_material_repository.dart';
import '../../../shared/providers/repository_providers.dart';

// 1. Estado
class PecaMaterialListState extends Equatable {
  final List<PecaMaterial> pecas;
  final bool isLoading;
  final String? errorMessage;

  const PecaMaterialListState({
    this.pecas = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  PecaMaterialListState copyWith({
    List<PecaMaterial>? pecas,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PecaMaterialListState(
      pecas: pecas ?? this.pecas,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [pecas, isLoading, errorMessage];
}

// 2. Notifier
class PecaMaterialListNotifier extends StateNotifier<PecaMaterialListState> {
  final PecaMaterialRepository _repository;

  PecaMaterialListNotifier(this._repository) : super(const PecaMaterialListState()) {
    loadPecas();
  }

  Future<void> loadPecas({String? searchTerm, bool refresh = false}) async {
    if (state.isLoading && !refresh) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final pecas = await _repository.getPecasMateriais();
      state = state.copyWith(pecas: pecas, isLoading: false);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
    }
  }
}

// 3. Provider
final pecaMaterialListProvider = StateNotifierProvider<PecaMaterialListNotifier, PecaMaterialListState>((ref) {
  return PecaMaterialListNotifier(ref.watch(pecaMaterialRepositoryProvider));
});