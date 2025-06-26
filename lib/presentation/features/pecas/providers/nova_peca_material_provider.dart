import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/peca_material.dart';
import '../../../../domain/repositories/peca_material_repository.dart';
import '../../../shared/providers/repository_providers.dart';

class NovaPecaState extends Equatable {
  final bool isSubmitting;
  final String? submissionError;
  const NovaPecaState({this.isSubmitting = false, this.submissionError});

  NovaPecaState copyWith({bool? isSubmitting, String? submissionError}) {
    return NovaPecaState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submissionError: submissionError ?? this.submissionError,
    );
  }
  @override
  List<Object?> get props => [isSubmitting, submissionError];
}

class NovaPecaNotifier extends StateNotifier<NovaPecaState> {
  final PecaMaterialRepository _repository;
  NovaPecaNotifier(this._repository) : super(const NovaPecaState());

  Future<bool> createPeca(PecaMaterial peca) async {
    state = state.copyWith(isSubmitting: true);
    try {
      await _repository.createPecaMaterial(peca);
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, submissionError: e.toString());
      return false;
    }
  }
}

final novaPecaProvider = StateNotifierProvider<NovaPecaNotifier, NovaPecaState>((ref) {
  return NovaPecaNotifier(ref.watch(pecaMaterialRepositoryProvider));
});