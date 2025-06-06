import 'package:equatable/equatable.dart';
import '../../../../domain/entities/ordem_servico.dart';


class OsListState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  final List<OrdemServico> ordensServico;
  // Adicione aqui outros estados necessários, como filtros aplicados
  // final Map<String, dynamic>? activeFilters;

  const OsListState({
    this.isLoading = false,
    this.errorMessage,
    this.ordensServico = const [],
    // this.activeFilters,
  });

  OsListState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<OrdemServico>? ordensServico,
    // Map<String, dynamic>? activeFilters,
    bool clearError = false,
  }) {
    return OsListState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      ordensServico: ordensServico ?? this.ordensServico,
      // activeFilters: activeFilters ?? this.activeFilters,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    errorMessage,
    ordensServico,
    // activeFilters,
  ];
}

