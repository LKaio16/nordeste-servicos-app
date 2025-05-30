// lib/presentation/features/cliente/providers/novo_cliente_state.dart

import 'package:equatable/equatable.dart';

// Define o estado para a tela de Novo Cliente
class NovoClienteState extends Equatable {
  final bool isSubmitting; // Indica se o formulário está sendo enviado
  final String? submissionError; // Mensagem de erro ao enviar

  const NovoClienteState({
    this.isSubmitting = false,
    this.submissionError,
  });

  // Cria uma cópia do estado com valores atualizados
  NovoClienteState copyWith({
    bool? isSubmitting,
    String? submissionError,
    bool clearSubmissionError = false, // Flag para limpar o erro
  }) {
    return NovoClienteState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submissionError: clearSubmissionError ? null : submissionError ?? this.submissionError,
    );
  }

  @override
  List<Object?> get props => [isSubmitting, submissionError];
}

