// lib/presentation/features/os/providers/os_edit_provider.dart

import 'package:flutter/foundation.dart'; // Import for kDebugMode
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nordeste_servicos_app/data/models/prioridade_os_model.dart';
import 'package:nordeste_servicos_app/data/models/status_os_model.dart';
import 'package:nordeste_servicos_app/domain/entities/cliente.dart';
import 'package:nordeste_servicos_app/domain/entities/equipamento.dart'; // Mantenha para carregar a OS original
import 'package:nordeste_servicos_app/domain/entities/ordem_servico.dart'; // Mantenha para carregar a OS original
import 'package:nordeste_servicos_app/domain/entities/usuario.dart';
import 'package:nordeste_servicos_app/domain/repositories/cliente_repository.dart';
import 'package:nordeste_servicos_app/domain/repositories/equipamento_repository.dart'; // Importe EquipamentoRepository
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
    ref.read(equipamentoRepositoryProvider), // Certifique-se de que está sendo injetado
    ref.read(usuarioRepositoryProvider),
  );
});

class OsEditNotifier extends StateNotifier<OsEditState> {
  final int _osId;
  final OsRepository _osRepository;
  final ClienteRepository _clienteRepository;
  final EquipamentoRepository _equipamentoRepository; // Mantenha esta propriedade
  final UsuarioRepository _usuarioRepository;

  OsEditNotifier(
      this._osId,
      this._osRepository,
      this._clienteRepository,
      this._equipamentoRepository, // Adicione aqui no construtor
      this._usuarioRepository,
      ) : super(const OsEditState());

  Future<void> loadInitialData() async {
    state = state.copyWith(isLoadingInitialData: true, clearInitialError: true);
    try {
      final results = await Future.wait([
        _osRepository.getOrdemServicoById(_osId), // Busca a OS específica
        _clienteRepository.getClientes(),
        _equipamentoRepository.getEquipamentos(), // Ainda precisamos para carregar todos para o dropdown, se houver
        _usuarioRepository.getUsuarios(),
      ]);

      final OrdemServico originalOs = results[0] as OrdemServico;
      final List<Cliente> clientes = results[1] as List<Cliente>;
      final List<Equipamento> equipamentos = results[2] as List<Equipamento>;
      final List<Usuario> tecnicos = (results[3] as List<Usuario>)
          .where((u) => u.perfil == PerfilUsuarioModel.TECNICO)
          .toList();

      state = state.copyWith(
        isLoadingInitialData: false,
        originalOs: originalOs,
        clientes: clientes,
        equipamentos: equipamentos, // Mantenha esta linha para compatibilidade com `OsEditState`
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

  // --- ALTERAÇÃO AQUI: O método updateOrdemServico agora aceita um objeto Equipamento ---
  Future<bool> updateOrdemServico({
    required int osId,
    required int clienteId,
    required Equipamento equipamento, // <-- MUDOU AQUI! Recebe o objeto Equipamento completo
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
      print("Equipamento (do Notifier): ID: ${equipamento.id}, Tipo: ${equipamento.tipo}, Marca: ${equipamento.marcaModelo}");
      print("Tecnico ID: $tecnicoAtribuidoId");
      print("Problema: $problemaRelatado");
      print("Status: $status");
      print("Prioridade: $prioridade");
      print("----------------------------------");
    }

    try {
      // Passo 1: Atualizar o equipamento primeiro, se ele tiver um ID
      // (Se o ID for null, significa que é um novo equipamento, o que não é o caso aqui na edição)
      if (equipamento.id != null) {
        await _equipamentoRepository.updateEquipamento(equipamento);
        if (kDebugMode) {
          print("Equipamento ID ${equipamento.id} atualizado com sucesso no backend.");
        }
      } else {
        // Isso não deve acontecer na tela de edição, mas é um bom aviso.
        if (kDebugMode) {
          print("Atenção: Tentativa de atualizar equipamento sem ID na edição. Pulando atualização do equipamento.");
        }
      }

      // Passo 2: Atualizar a Ordem de Serviço, referenciando o ID do equipamento (que foi atualizado no passo 1)
      await _osRepository.updateOrdemServico(
        osId: osId,
        clienteId: clienteId,
        // PASSE O ID DO EQUIPAMENTO AQUI
        equipamentoId: equipamento.id!, // Agora o equipamento.id DEVE ser não-nulo
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