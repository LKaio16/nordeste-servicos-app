import 'package:freezed_annotation/freezed_annotation.dart';

part 'novo_tecnico_state.freezed.dart'; // Necessário gerar com build_runner

@freezed
class NovoTecnicoState with _$NovoTecnicoState {
  const factory NovoTecnicoState({
    @Default(false) bool isSubmitting,
    String? submissionError,
  }) = _NovoTecnicoState;
}

