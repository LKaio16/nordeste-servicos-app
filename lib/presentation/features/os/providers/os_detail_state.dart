import 'package:equatable/equatable.dart';
// Importa a entidade OrdemServico (ajuste o caminho conforme seu projeto)
// Ex: import 'package:nordeste_servicos_app/domain/entities/ordem_servico.dart';
import '../../../../domain/entities/ordem_servico.dart';

class OsDetailState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  final OrdemServico? ordemServico; // Armazena a OS carregada ou null

  const OsDetailState({
    this.isLoading = false,
    this.errorMessage,
    this.ordemServico,
  });

  OsDetailState copyWith({
    bool? isLoading,
    String? errorMessage,
    OrdemServico? ordemServico,
    bool clearError = false,
    bool clearData = false, // Para limpar os dados ao recarregar
  }) {
    return OsDetailState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      ordemServico: clearData ? null : ordemServico ?? this.ordemServico,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    errorMessage,
    ordemServico,
  ];
}

