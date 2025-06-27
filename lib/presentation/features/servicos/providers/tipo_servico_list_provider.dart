import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/entities/tipo_servico.dart';
import '../../../../domain/repositories/tipo_servico_repository.dart';
import '../../../shared/providers/repository_providers.dart';

// 1. O Estado
class TipoServicoListState extends Equatable {
  final List<TipoServico> servicos;
  final bool isLoading;
  final String? errorMessage;

  const TipoServicoListState({
    this.servicos = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  TipoServicoListState copyWith({
    List<TipoServico>? servicos,
    bool? isLoading,
    String? errorMessage,
  }) {
    return TipoServicoListState(
      servicos: servicos ?? this.servicos,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [servicos, isLoading, errorMessage];
}

// 2. O Notifier
class TipoServicoListNotifier extends StateNotifier<TipoServicoListState> {
  final TipoServicoRepository _repository;

  TipoServicoListNotifier(this._repository) : super(const TipoServicoListState()) {
    loadServicos();
  }

  Future<void> loadServicos({bool refresh = false}) async {
    if (state.isLoading && !refresh) return;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final servicos = await _repository.getTiposServico();
      state = state.copyWith(servicos: servicos, isLoading: false);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
    }
  }
}

// 3. O Provider
final tipoServicoListProvider = StateNotifierProvider<TipoServicoListNotifier, TipoServicoListState>((ref) {
  return TipoServicoListNotifier(ref.watch(tipoServicoRepositoryProvider));
});
