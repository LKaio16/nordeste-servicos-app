import 'package:equatable/equatable.dart';

import 'package:nordeste_servicos_app/domain/entities/cliente.dart';
import 'package:nordeste_servicos_app/domain/entities/equipamento.dart';
import 'package:nordeste_servicos_app/domain/entities/usuario.dart';

class NovaOsState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  final List<Cliente> clientes;
  final List<Usuario> tecnicos;
  final bool isSubmitting;
  final String? submissionError;
  final String? nextOsNumber;
  final bool isEquipamentoLoading;
  final List<Equipamento> equipamentosDoCliente;

  const NovaOsState({
    this.isLoading = false,
    this.errorMessage,
    this.clientes = const [],
    this.tecnicos = const [],
    this.isSubmitting = false,
    this.submissionError,
    this.nextOsNumber,
    this.isEquipamentoLoading = false,
    this.equipamentosDoCliente = const [],
  });

  NovaOsState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<Cliente>? clientes,
    List<Usuario>? tecnicos,
    bool? isSubmitting,
    String? submissionError,
    String? nextOsNumber,
    bool? isEquipamentoLoading,
    List<Equipamento>? equipamentosDoCliente,
    bool clearError = false,
    bool clearSubmissionError = false,
  }) {
    return NovaOsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      clientes: clientes ?? this.clientes,
      tecnicos: tecnicos ?? this.tecnicos,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submissionError: clearSubmissionError ? null : submissionError ?? this.submissionError,
      nextOsNumber: nextOsNumber ?? this.nextOsNumber,
      isEquipamentoLoading: isEquipamentoLoading ?? this.isEquipamentoLoading,
      equipamentosDoCliente: equipamentosDoCliente ?? this.equipamentosDoCliente,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    errorMessage,
    clientes,
    tecnicos,
    isSubmitting,
    submissionError,
    nextOsNumber,
    isEquipamentoLoading,
    equipamentosDoCliente,
  ];
}
