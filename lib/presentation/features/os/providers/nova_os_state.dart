// lib/presentation/features/os/providers/nova_os_state.dart

import 'package:equatable/equatable.dart';

import '../../../../domain/entities/cliente.dart';
import '../../../../domain/entities/equipamento.dart';
import '../../../../domain/entities/usuario.dart';



class NovaOsState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  final List<Cliente> clientes;
  final List<Equipamento> equipamentos; // Pode ser filtrado por cliente
  final List<Usuario> tecnicos;
  final bool isSubmitting;
  final String? submissionError;
  final String? nextOsNumber; // Para exibir o número da próxima OS

  const NovaOsState({
    this.isLoading = false,
    this.errorMessage,
    this.clientes = const [],
    this.equipamentos = const [],
    this.tecnicos = const [],
    this.isSubmitting = false,
    this.submissionError,
    this.nextOsNumber,
  });

  NovaOsState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<Cliente>? clientes,
    List<Equipamento>? equipamentos,
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
      equipamentos: equipamentos ?? this.equipamentos,
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
    equipamentos,
    tecnicos,
    isSubmitting,
    submissionError,
    nextOsNumber,
  ];
}

