import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';
import '../../../../domain/entities/registro_tempo.dart';
import '../../../../domain/repositories/registro_tempo_repository.dart';
import '../../../shared/providers/repository_providers.dart';
import '../../auth/providers/auth_provider.dart';

// 1. Estado do Provider
class RegistroTempoState extends Equatable {
  final List<RegistroTempo> registros;
  final bool isLoading;
  final String? errorMessage;
  final RegistroTempo? activeRegistro;
  final Duration elapsed;
  final Duration totalDuration;

  const RegistroTempoState({
    this.registros = const [],
    this.isLoading = false,
    this.errorMessage,
    this.activeRegistro,
    this.elapsed = Duration.zero,
    this.totalDuration = Duration.zero,
  });

  RegistroTempoState copyWith({
    List<RegistroTempo>? registros,
    bool? isLoading,
    String? errorMessage,
    RegistroTempo? activeRegistro,
    bool clearActiveRegistro = false,
    Duration? elapsed,
    Duration? totalDuration,
  }) {
    return RegistroTempoState(
      registros: registros ?? this.registros,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      activeRegistro: clearActiveRegistro ? null : activeRegistro ?? this.activeRegistro,
      elapsed: elapsed ?? this.elapsed,
      totalDuration: totalDuration ?? this.totalDuration,
    );
  }

  @override
  List<Object?> get props => [registros, isLoading, errorMessage, activeRegistro, elapsed, totalDuration];
}

// 2. Notifier
class RegistroTempoNotifier extends StateNotifier<RegistroTempoState> {
  final RegistroTempoRepository _repository;
  final int _osId;
  final int? _tecnicoId;
  Timer? _timer;

  RegistroTempoNotifier(this._repository, this._osId, this._tecnicoId) : super(const RegistroTempoState()) {
    fetchRegistros(); // Chamada adicionada aqui
  }

  Future<void> fetchRegistros() async {
    state = state.copyWith(isLoading: true, errorMessage: null, elapsed: Duration.zero, totalDuration: Duration.zero); // Resetar ao carregar
    _timer?.cancel(); // Cancelar qualquer timer existente

    try {
      final registros = await _repository.getRegistrosTempoByOsId(_osId);

      RegistroTempo? activeRegistro;
      Duration calculatedTotalDuration = Duration.zero;

      for (var reg in registros) {
        if (reg.horaTermino == null) {
          activeRegistro = reg;
        } else {
          calculatedTotalDuration += reg.horaTermino!.difference(reg.horaInicio);
        }
      }

      state = state.copyWith(
        isLoading: false,
        registros: registros,
        activeRegistro: activeRegistro,
        clearActiveRegistro: activeRegistro == null,
        totalDuration: calculatedTotalDuration,
      );

      if (activeRegistro != null) {
        _startTimer(activeRegistro.horaInicio);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void _startTimer(DateTime startTime) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final now = DateTime.now();
      final currentElapsed = now.difference(startTime);
      state = state.copyWith(elapsed: currentElapsed);
    });
  }

  Future<void> iniciarRegistro() async {
    if (_tecnicoId == null) {
      state = state.copyWith(errorMessage: "Técnico não identificado.");
      return;
    }
    try {
      final novoRegistro = RegistroTempo(
        ordemServicoId: _osId,
        tecnicoId: _tecnicoId!,
        horaInicio: DateTime.now(),
      );
      await _repository.createRegistroTempo(novoRegistro);
      await fetchRegistros();
    } catch (e) {
      state = state.copyWith(errorMessage: "Erro ao iniciar registro: ${e.toString()}");
    }
  }

  Future<void> finalizarRegistroTempo() async {
    if (state.activeRegistro?.id == null) return;
    final registroId = state.activeRegistro!.id!;

    _timer?.cancel();
    try {
      await _repository.finalizarRegistroTempo(_osId, registroId);
      await fetchRegistros();
    } catch (e) {
      state = state.copyWith(errorMessage: "Erro ao finalizar registro: ${e.toString()}");
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

// 3. Provider
final registroTempoProvider = StateNotifierProvider.family.autoDispose<RegistroTempoNotifier, RegistroTempoState, int>((ref, osId) {
  final repository = ref.watch(registroTempoRepositoryProvider);
  final tecnicoId = ref.watch(authProvider).authenticatedUser?.id;
  final notifier = RegistroTempoNotifier(repository, osId, tecnicoId);

  // Garante que o método dispose do notifier (e consequentemente, o timer.cancel())
  // seja chamado quando o provider for destruído.
  ref.onDispose(() {
    notifier.dispose();
  });

  return notifier;
});


