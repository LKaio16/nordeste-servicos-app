import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/entities/tipo_servico.dart';
import '../../../../domain/repositories/tipo_servico_repository.dart';
import '../../../shared/providers/repository_providers.dart';

class NovoServicoState extends Equatable {
  final bool isSubmitting;
  final String? submissionError;
  const NovoServicoState({this.isSubmitting = false, this.submissionError});

  NovoServicoState copyWith({bool? isSubmitting, String? submissionError}) {
    return NovoServicoState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submissionError: submissionError ?? this.submissionError,
    );
  }
  @override
  List<Object?> get props => [isSubmitting, submissionError];
}

class NovoServicoNotifier extends StateNotifier<NovoServicoState> {
  final TipoServicoRepository _repository;
  NovoServicoNotifier(this._repository) : super(const NovoServicoState());

  Future<bool> createServico(String descricao) async {
    state = state.copyWith(isSubmitting: true);
    try {
      final servico = TipoServico(descricao: descricao);
      await _repository.createTipoServico(servico);
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, submissionError: e.toString());
      return false;
    }
  }
}

final novoServicoProvider = StateNotifierProvider<NovoServicoNotifier, NovoServicoState>((ref) {
  return NovoServicoNotifier(ref.watch(tipoServicoRepositoryProvider));
});
