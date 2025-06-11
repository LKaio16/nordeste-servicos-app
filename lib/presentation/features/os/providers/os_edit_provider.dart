import 'package:flutter/foundation.dart'; // Import for kDebugMode
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nordeste_servicos_app/data/models/prioridade_os_model.dart';
import 'package:nordeste_servicos_app/data/models/status_os_model.dart';
import 'package:nordeste_servicos_app/domain/entities/cliente.dart';
import 'package:nordeste_servicos_app/domain/entities/equipamento.dart';
import 'package:nordeste_servicos_app/domain/entities/ordem_servico.dart'; // Mantenha para carregar a OS original
import 'package:nordeste_servicos_app/domain/entities/usuario.dart';
import 'package:nordeste_servicos_app/domain/repositories/cliente_repository.dart';
import 'package:nordeste_servicos_app/domain/repositories/equipamento_repository.dart';
import 'package:nordeste_servicos_app/domain/repositories/os_repository.dart';
import 'package:nordeste_servicos_app/domain/repositories/usuario_repository.dart';
import 'package:nordeste_servicos_app/presentation/shared/providers/repository_providers.dart';
import '../../../../data/models/perfil_usuario_model.dart';
import 'os_edit_state.dart';

final osEditProvider = StateNotifierProvider.family<OsEditNotifier, OsEditState, int>((ref, osId) {
  return OsEditNotifier(
    osId,
    ref.read(osRepositoryProvider),
    ref.read(clienteRepositoryProvider),
    ref.read(equipamentoRepositoryProvider),
    ref.read(usuarioRepositoryProvider),
  );
});

class OsEditNotifier extends StateNotifier<OsEditState> {
  final int _osId;
  final OsRepository _osRepository;
  final ClienteRepository _clienteRepository;
  final EquipamentoRepository _equipamentoRepository;
  final UsuarioRepository _usuarioRepository;

  OsEditNotifier(
      this._osId,
      this._osRepository,
      this._clienteRepository,
      this._equipamentoRepository,
      this._usuarioRepository,
      ) : super(const OsEditState());

  Future<void> loadInitialData() async {
    state = state.copyWith(isLoadingInitialData: true, clearInitialError: true);
    try {
      final results = await Future.wait([
        _osRepository.getOrdemServicoById(_osId), // Busca a OS específica
        _clienteRepository.getClientes(),
        _equipamentoRepository.getEquipamentos(),
        _usuarioRepository.getUsuarios(),
      ]);

      final OrdemServico originalOs = results[0] as OrdemServico;
      final List<Cliente> clientes = results[1] as List<Cliente>;
      final List<Equipamento> equipamentos = results[2] as List<Equipamento>;
      final List<Usuario> tecnicos = (results[3] as List<Usuario>)
          .where((u) => u.perfil == PerfilUsuarioModel.TECNICO) // Certifique-se que o perfil é uma string ou enum comparável
          .toList();

      state = state.copyWith(
        isLoadingInitialData: false,
        originalOs: originalOs,
        clientes: clientes,
        equipamentos: equipamentos,
        tecnicos: tecnicos,
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('*******************************************');
        print('*** ERRO em OsEditNotifier.loadInitialData ***');
        print('Erro: ${e.toString()}');
        print('Stack Trace:');
        print(stackTrace);
        print('*******************************************');
      }
      state = state.copyWith(
        isLoadingInitialData: false,
        initialDataError: 'Erro ao carregar dados da OS: ${e.toString()}',
      );
    }
  }

  // *** ALTERAÇÃO AQUI: O método updateOrdemServico agora aceita os parâmetros individualmente ***
  Future<bool> updateOrdemServico({
    required int osId, // Precisa do ID da OS para saber qual atualizar
    required int clienteId,
    required int equipamentoId,
    int? tecnicoAtribuidoId,
    required String problemaRelatado,
    String? analiseFalha,
    String? solucaoAplicada,
    required StatusOSModel status,
    PrioridadeOSModel? prioridade,
    DateTime? dataAgendamento,
  }) async {
    state = state.copyWith(isSubmitting: true, clearSubmissionError: true);

    if (kDebugMode) {
      print("--- updateOrdemServico (Notifier) ---");
      print("OS ID: $osId");
      print("Cliente ID: $clienteId");
      print("Equipamento ID: $equipamentoId");
      print("Tecnico ID: $tecnicoAtribuidoId");
      print("Problema: $problemaRelatado");
      print("Status: $status");
      print("Prioridade: $prioridade");
      print("----------------------------------");
    }

    try {
      // Cria a entidade OrdemServico para passar para o repositório.
      // Note que o repositório (implementação) será responsável por converter
      // esta entidade para o DTO de requisição (OrdemServicoRequestDTO) se necessário.
      // Ou, alternativamente, o repositório pode aceitar os mesmos parâmetros que o notifier.
      // Para consistência, vamos passar os mesmos parâmetros brutos para o repositório.

      await _osRepository.updateOrdemServico(
        osId: osId,
        clienteId: clienteId,
        equipamentoId: equipamentoId,
        tecnicoAtribuidoId: tecnicoAtribuidoId,
        problemaRelatado: problemaRelatado,
        analiseFalha: analiseFalha,
        solucaoAplicada: solucaoAplicada,
        status: status,
        prioridade: prioridade,
        dataAgendamento: dataAgendamento,
      );

      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('*******************************************');
        print('*** ERRO em OsEditNotifier.updateOrdemServico ***');
        print('Erro: ${e.toString()}');
        print('Stack Trace:');
        print(stackTrace);
        print('*******************************************');
      }
      state = state.copyWith(
        isSubmitting: false,
        submissionError: 'Erro ao atualizar OS: ${e.toString()}',
      );
      return false;
    }
  }
}