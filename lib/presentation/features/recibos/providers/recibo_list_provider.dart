import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../domain/entities/recibo.dart';
import '../../../../domain/repositories/recibo_repository.dart';
import '../../../shared/providers/repository_providers.dart';

// 1. O Estado da tela de lista
class ReciboListState extends Equatable {
  final List<Recibo> recibos;
  final bool isLoading;
  final String? errorMessage;

  const ReciboListState({
    this.recibos = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  ReciboListState copyWith({
    List<Recibo>? recibos,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ReciboListState(
      recibos: recibos ?? this.recibos,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [recibos, isLoading, errorMessage];
}

// 2. O Notifier que gerencia o estado
class ReciboListNotifier extends StateNotifier<ReciboListState> {
  final ReciboRepository _repository;

  ReciboListNotifier(this._repository) : super(const ReciboListState()) {
    loadRecibos();
  }

  Future<void> loadRecibos({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(isLoading: true, clearError: true);
    } else {
      state = state.copyWith(isLoading: true);
    }

    try {
      final recibos = await _repository.getRecibos();
      state = state.copyWith(
        recibos: recibos,
        isLoading: false,
        clearError: true,
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro inesperado: ${e.toString()}',
      );
    }
  }

  Future<void> refreshRecibos() async {
    await loadRecibos(refresh: true);
  }

  Future<void> deleteRecibo(int id) async {
    try {
      await _repository.deleteRecibo(id);
      await loadRecibos(refresh: true);
    } on ApiException catch (e) {
      state = state.copyWith(errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erro ao deletar recibo: ${e.toString()}');
    }
  }
}

// 3. O Provider que expõe o Notifier
final reciboListProvider = StateNotifierProvider<ReciboListNotifier, ReciboListState>((ref) {
  final repository = ref.read(reciboRepositoryProvider);
  return ReciboListNotifier(repository);
});


