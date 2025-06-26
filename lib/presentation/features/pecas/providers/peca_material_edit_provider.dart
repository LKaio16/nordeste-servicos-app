import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../domain/entities/peca_material.dart';
import '../../../../domain/repositories/peca_material_repository.dart';
import '../../../shared/providers/repository_providers.dart';

// 1. Estado
class PecaMaterialEditState extends Equatable {
  final bool isLoadingInitialData;
  final String? initialDataError;
  final PecaMaterial? originalPeca;
  final bool isSubmitting;
  final String? submissionError;

  const PecaMaterialEditState({
    this.isLoadingInitialData = false,
    this.initialDataError,
    this.originalPeca,
    this.isSubmitting = false,
    this.submissionError,
  });

  PecaMaterialEditState copyWith({
    bool? isLoadingInitialData,
    String? initialDataError,
    PecaMaterial? originalPeca,
    bool? isSubmitting,
    String? submissionError,
    bool clearErrors = false,
  }) {
    return PecaMaterialEditState(
      isLoadingInitialData: isLoadingInitialData ?? this.isLoadingInitialData,
      initialDataError: clearErrors ? null : initialDataError ?? this.initialDataError,
      originalPeca: originalPeca ?? this.originalPeca,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submissionError: clearErrors ? null : submissionError ?? this.submissionError,
    );
  }

  @override
  List<Object?> get props => [isLoadingInitialData, initialDataError, originalPeca, isSubmitting, submissionError];
}

// 2. Notifier
class PecaMaterialEditNotifier extends StateNotifier<PecaMaterialEditState> {
  final PecaMaterialRepository _repository;

  PecaMaterialEditNotifier(this._repository) : super(const PecaMaterialEditState());

  Future<void> loadInitialData(int pecaId) async {
    state = state.copyWith(isLoadingInitialData: true, clearErrors: true);
    try {
      final peca = await _repository.getPecaMaterialById(pecaId);
      state = state.copyWith(isLoadingInitialData: false, originalPeca: peca);
    } catch (e) {
      state = state.copyWith(isLoadingInitialData: false, initialDataError: "Erro ao carregar dados do item: ${e.toString()}");
    }
  }

  Future<bool> updatePeca(PecaMaterial peca) async {
    state = state.copyWith(isSubmitting: true, clearErrors: true);
    try {
      await _repository.updatePecaMaterial(peca);
      state = state.copyWith(isSubmitting: false);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isSubmitting: false, submissionError: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, submissionError: "Erro inesperado: ${e.toString()}");
      return false;
    }
  }
}

// 3. Provider de Família
final pecaMaterialEditProvider = StateNotifierProvider.family<PecaMaterialEditNotifier, PecaMaterialEditState, int>((ref, pecaId) {
  return PecaMaterialEditNotifier(ref.watch(pecaMaterialRepositoryProvider));
});