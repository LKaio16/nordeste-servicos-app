import 'package:equatable/equatable.dart';

import 'package:nordeste_servicos_app/domain/entities/cliente.dart';
// REMOVED: import '../../../../domain/entities/equipamento.dart'; // No longer storing list
import '../../../../domain/entities/usuario.dart';



class NovaOsState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  final List<Cliente> clientes;
  // REMOVED: final List<Equipamento> equipamentos; // No longer needed
  final List<Usuario> tecnicos;
  final bool isSubmitting;
  final String? submissionError;
  final String? nextOsNumber; // Para exibir o número da próxima OS

  const NovaOsState({
    this.isLoading = false,
    this.errorMessage,
    this.clientes = const [],
    // REMOVED: this.equipamentos = const [],
    this.tecnicos = const [],
    this.isSubmitting = false,
    this.submissionError,
    this.nextOsNumber,
  });

  NovaOsState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<Cliente>? clientes,
    // REMOVED: List<Equipamento>? equipamentos,
    List<Usuario>? tecnicos,
    bool? isSubmitting,
    String? submissionError,
    String? nextOsNumber,
    bool clearError = false, // Flag para limpar erros específicos
    bool clearSubmissionError = false,
  }) {
    return NovaOsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      clientes: clientes ?? this.clientes,
      // REMOVED: equipamentos: equipments ?? this.equipamentos,
      tecnicos: tecnicos ?? this.tecnicos,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submissionError: clearSubmissionError ? null : submissionError ?? this.submissionError,
      nextOsNumber: nextOsNumber ?? this.nextOsNumber,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    errorMessage,
    clientes,
    // REMOVED: equipamentos,
    tecnicos,
    isSubmitting,
    submissionError,
    nextOsNumber,
  ];
}