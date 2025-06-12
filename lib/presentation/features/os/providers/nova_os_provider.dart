// lib/presentation/features/os/providers/nova_os_provider.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nordeste_servicos_app/data/models/prioridade_os_model.dart';
import 'package:nordeste_servicos_app/data/models/status_os_model.dart';

import 'package:nordeste_servicos_app/domain/entities/cliente.dart';
import 'package:nordeste_servicos_app/domain/entities/equipamento.dart';
import 'package:nordeste_servicos_app/domain/entities/usuario.dart'; // <<< Importar a ENTIDADE Usuario
import 'package:nordeste_servicos_app/domain/repositories/cliente_repository.dart';
import 'package:nordeste_servicos_app/domain/repositories/equipamento_repository.dart';
import 'package:nordeste_servicos_app/domain/repositories/usuario_repository.dart';
import 'package:nordeste_servicos_app/domain/repositories/os_repository.dart';
import 'package:nordeste_servicos_app/presentation/shared/providers/repository_providers.dart';
// REMOVA ESTE IMPORT se UsuarioModel não for usado diretamente em NovaOsNotifier
// import '../../../../data/models/usuario_model.dart'; // <<< REMOVA ESTE IMPORT (ou comente)
import 'nova_os_state.dart';

import 'package:nordeste_servicos_app/domain/entities/ordem_servico.dart';

final novaOsProvider = StateNotifierProvider<NovaOsNotifier, NovaOsState>((ref) {
  return NovaOsNotifier(
    ref.read(clienteRepositoryProvider),
    ref.read(equipamentoRepositoryProvider),
    ref.read(usuarioRepositoryProvider),
    ref.read(osRepositoryProvider),
  );
});

class NovaOsNotifier extends StateNotifier<NovaOsState> {
  final ClienteRepository _clienteRepository;
  final EquipamentoRepository _equipamentoRepository;
  final UsuarioRepository _usuarioRepository;
  final OsRepository _osRepository;

  NovaOsNotifier(
      this._clienteRepository,
      this._equipamentoRepository,
      this._usuarioRepository,
      this._osRepository,
      ) : super(const NovaOsState());

  Future<void> loadInitialData() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final results = await Future.wait([
        _clienteRepository.getClientes(),
        _usuarioRepository.getUsuarios(), // Retorna List<Usuario>
        _osRepository.getNextOsNumber(),
        _equipamentoRepository.getEquipamentos(),
      ]);

      final clientes = results[0] as List<Cliente>;
      final tecnicos = (results[1] as List<Usuario>) // Já é List<Usuario>
          .where((u) => u.perfil.name.toLowerCase() == 'tecnico')
          .toList();
      final nextOsNumber = results[2] as String?;
      final equipamentos = results[3] as List<Equipamento>;

      state = state.copyWith(
        isLoading: false,
        clientes: clientes,
        tecnicos: tecnicos, // tecnicos é List<Usuario>
        equipamentos: equipamentos,
        nextOsNumber: nextOsNumber,
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('*******************************************');
        print('*** ERRO em loadInitialData ***');
        print('Erro: ${e.toString()}');
        print('Stack Trace:');
        print(stackTrace);
        print('*******************************************');
      }
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar dados: ${e.toString()}',
      );
    }
  }

  Future<bool> createOrdemServico({
    required String clienteId, // Recebe o ID do cliente como String (vindo da UI)
    required String equipamentoId,
    required String descricaoProblema,
    required String tecnicoId,
    required String prioridade,
    required DateTime dataAbertura,
    DateTime? dataAgendamento,
  }) async {
    state = state.copyWith(isSubmitting: true, clearSubmissionError: true);

    if (kDebugMode) {
      print('--- createOrdemServico: Iniciando ---');
      // ... (outros prints de debug)
    }

    try {
      // Mapeamento de prioridade (já está correto)
      final PrioridadeOSModel prioridadeEnum = PrioridadeOSModel.values.firstWhere(
            (p) => p.name.toLowerCase() == prioridade.toLowerCase(),
        orElse: () => PrioridadeOSModel.MEDIA,
      );

      // Conversão de IDs para int (já está correto)
      final int clienteIdInt = int.parse(clienteId);
      final int equipamentoIdInt = int.parse(equipamentoId);
      final int tecnicoIdInt = int.parse(tecnicoId);

      // --- 1. AJUSTE PRINCIPAL: BUSCAR O OBJETO CLIENTE COMPLETO ---
      // Usando o clienteIdInt, encontre o Cliente na lista do estado.
      final Cliente clienteSelecionado = state.clientes.firstWhere(
            (c) => c.id == clienteIdInt,
        orElse: () {
          // Lança um erro se, por algum motivo, o cliente não for encontrado.
          throw Exception('Cliente com ID $clienteIdInt não encontrado.');
        },
      );

      final Equipamento equipamentoSelecionado = state.equipamentos.firstWhere(
            (e) => e.id == equipamentoIdInt,
        orElse: () => throw Exception('Equipamento com ID $equipamentoIdInt não encontrado.'),
      );

      // Busca pelo técnico (já está correto)
      final Usuario? tecnicoSelecionado = state.tecnicos.firstWhere(
            (t) => t.id == tecnicoIdInt,
        orElse: () {
          throw Exception('Técnico com ID $tecnicoIdInt não encontrado.');
        },
      );

      if (kDebugMode) {
        print('Cliente selecionado (Entidade Cliente): ${clienteSelecionado.nomeCompleto} (ID: ${clienteSelecionado.id})');
        print('Técnico selecionado (Entidade Usuario): ${tecnicoSelecionado?.nome} (ID: ${tecnicoSelecionado?.id})');
      }

      // --- 2. AJUSTE NA CRIAÇÃO DA ENTIDADE OrdemServico ---
      // Agora passamos o objeto `clienteSelecionado` em vez do `clienteIdInt`.
      final novaOS = OrdemServico(
        numeroOS: state.nextOsNumber ?? '',
        status: StatusOSModel.EM_ABERTO,
        dataAbertura: dataAbertura,
        dataAgendamento: dataAgendamento,

        cliente: clienteSelecionado, // <<< CAMPO ATUALIZADO

        equipamento: equipamentoSelecionado,
        tecnicoAtribuido: tecnicoSelecionado,
        problemaRelatado: descricaoProblema,
        prioridade: prioridadeEnum,
      );

      if (kDebugMode) {
        print('Objeto OrdemServico criado: ${novaOS.toString()}');
        print('Chamando _osRepository.createOrdemServico...');
      }

      await _osRepository.createOrdemServico(novaOS);

      if (kDebugMode) print('Criação da OS no repositório concluída com sucesso.');

      state = state.copyWith(isSubmitting: false);
      return true;

    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('*******************************************');
        print('*** ERRO em createOrdemServico (Notifier) ***');
        print('Erro: ${e.toString()}');
        if (e is FormatException) {
          print('Input que causou FormatException: ${e.source}');
        }
        print('Tipo do Erro: ${e.runtimeType}');
        print('Stack Trace:');
        print(stackTrace);
        print('*******************************************');
      }
      state = state.copyWith(
        isSubmitting: false,
        submissionError: 'Erro ao criar OS: ${e.toString()}',
      );
      return false;
    }
  }
}