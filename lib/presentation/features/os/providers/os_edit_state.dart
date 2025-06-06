import 'package:equatable/equatable.dart';

// Importações de entidades (ajuste os caminhos conforme seu projeto)
// Ex: import 'package:nordeste_servicos_app/domain/entities/cliente.dart';
// Ex: import 'package:nordeste_servicos_app/domain/entities/equipamento.dart';
// Ex: import 'package:nordeste_servicos_app/domain/entities/usuario.dart';
// Ex: import 'package:nordeste_servicos_app/domain/entities/ordem_servico.dart';
import '../../../../domain/entities/cliente.dart';
import '../../../../domain/entities/equipamento.dart';
import '../../../../domain/entities/ordem_servico.dart';
import '../../../../domain/entities/usuario.dart';



class OsEditState extends Equatable {
  // Estado de carregamento inicial da OS e dados relacionados (clientes, tecnicos, etc.)
  final bool isLoadingInitialData;
  final String? initialDataError;

  // Dados necessários para os dropdowns do formulário
  final List<Cliente> clientes;
  final List<Equipamento> equipamentos; // Pode precisar ser filtrada pelo cliente
  final List<Usuario> tecnicos;

  // A Ordem de Serviço original que está sendo editada
  final OrdemServico? originalOs;

  // Estado do processo de submissão (salvar alterações)
  final bool isSubmitting;
  final String? submissionError;
  final bool submissionSuccess;

  const OsEditState({
    this.isLoadingInitialData = false,
    this.initialDataError,
    this.clientes = const [],
    this.equipamentos = const [],
    this.tecnicos = const [],
    this.originalOs,
    this.isSubmitting = false,
    this.submissionError,
    this.submissionSuccess = false,
  });

  OsEditState copyWith({
    bool? isLoadingInitialData,
    String? initialDataError,
    List<Cliente>? clientes,
    List<Equipamento>? equipamentos,
    List<Usuario>? tecnicos,
    OrdemServico? originalOs,
    bool? isSubmitting,
    String? submissionError,
    bool? submissionSuccess,
    bool clearInitialError = false,
    bool clearSubmissionError = false,
  }) {
    return OsEditState(
      isLoadingInitialData: isLoadingInitialData ?? this.isLoadingInitialData,
      initialDataError: clearInitialError ? null : initialDataError ?? this.initialDataError,
      clientes: clientes ?? this.clientes,
      equipamentos: equipamentos ?? this.equipamentos,
      tecnicos: tecnicos ?? this.tecnicos,
      originalOs: originalOs ?? this.originalOs,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submissionError: clearSubmissionError ? null : submissionError ?? this.submissionError,
      submissionSuccess: submissionSuccess ?? this.submissionSuccess,
    );
  }

  @override
  List<Object?> get props => [
    isLoadingInitialData,
    initialDataError,
    clientes,
    equipamentos,
    tecnicos,
    originalOs,
    isSubmitting,
    submissionError,
    submissionSuccess,
  ];
}

