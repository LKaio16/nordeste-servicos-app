import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/entities/tipo_servico.dart';
import '../../../../domain/repositories/tipo_servico_repository.dart';
import '../../../shared/providers/repository_providers.dart';

class ServicoEditState extends Equatable {
  final bool isSubmitting;
  final String? submissionError;
  const ServicoEditState({this.isSubmitting = false, this.submissionError});

  ServicoEditState copyWith({bool? isSubmitting, String? submissionError}) {
    return ServicoEditState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submissionError: submissionError ?? this.submissionError,
    );
  }
  @override
  List<Object?> get props => [isSubmitting, submissionError];
}

class ServicoEditNotifier extends StateNotifier<ServicoEditState> {
  final TipoServicoRepository _repository;
  ServicoEditNotifier(this._repository) : super(const ServicoEditState());

  Future<bool> updateServico(TipoServico servico) async {
    state = state.copyWith(isSubmitting: true);
    try {
      await _repository.updateTipoServico(servico);
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, submissionError: e.toString());
      return false;
    }
  }
}

final servicoEditProvider = StateNotifierProvider.autoDispose<ServicoEditNotifier, ServicoEditState>((ref) {
  return ServicoEditNotifier(ref.watch(tipoServicoRepositoryProvider));
});
