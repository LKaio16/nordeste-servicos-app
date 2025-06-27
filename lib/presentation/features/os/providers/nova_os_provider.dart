import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nordeste_servicos_app/data/models/prioridade_os_model.dart';
import 'package:nordeste_servicos_app/data/models/status_os_model.dart';

import 'package:nordeste_servicos_app/domain/entities/cliente.dart';
import 'package:nordeste_servicos_app/domain/entities/equipamento.dart';
import 'package:nordeste_servicos_app/domain/entities/usuario.dart';
import 'package:nordeste_servicos_app/domain/repositories/cliente_repository.dart';
import 'package:nordeste_servicos_app/domain/repositories/equipamento_repository.dart';
import 'package:nordeste_servicos_app/domain/repositories/usuario_repository.dart';
import 'package:nordeste_servicos_app/domain/repositories/os_repository.dart';
import 'package:nordeste_servicos_app/presentation/shared/providers/repository_providers.dart';
import 'nova_os_state.dart';

import 'package:nordeste_servicos_app/domain/entities/ordem_servico.dart';

final novaOsProvider = StateNotifierProvider.autoDispose<NovaOsNotifier, NovaOsState>((ref) {
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
        _usuarioRepository.getUsuarios(),
        _osRepository.getNextOsNumber(),
      ]);

      final clientes = results[0] as List<Cliente>;
      final tecnicos = (results[1] as List<Usuario>)
          .where((u) => u.perfil.name.toLowerCase() == 'tecnico')
          .toList();
      final nextOsNumber = results[2] as String?;

      state = state.copyWith(
        isLoading: false,
        clientes: clientes,
        tecnicos: tecnicos,
        nextOsNumber: nextOsNumber,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Erro ao carregar dados: ${e.toString()}');
    }
  }

  // <<< NOVO MÉTODO PARA CARREGAR EQUIPAMENTOS DO CLIENTE >>>
  Future<void> loadEquipamentosDoCliente(int clienteId) async {
    state = state.copyWith(isEquipamentoLoading: true, equipamentosDoCliente: []);
    try {
      final equipamentos = await _equipamentoRepository.getEquipamentos(clienteId: clienteId);
      state = state.copyWith(isEquipamentoLoading: false, equipamentosDoCliente: equipamentos);
    } catch (e) {
      state = state.copyWith(isEquipamentoLoading: false, errorMessage: 'Erro ao carregar equipamentos: ${e.toString()}');
    }
  }

  // <<< MÉTODO DE CRIAÇÃO ATUALIZADO E MAIS ROBUSTO >>>
  Future<bool> createOrdemServico({
    required String clienteId,
    String? equipamentoExistenteId,
    Map<String, dynamic>? novoEquipamentoData,
    required String descricaoProblema,
    required String tecnicoId,
    required String prioridade,
    required DateTime dataAbertura,
    DateTime? dataAgendamento,
  }) async {
    state = state.copyWith(isSubmitting: true, clearSubmissionError: true);

    try {
      if (equipamentoExistenteId == null && novoEquipamentoData == null) {
        throw Exception('É necessário selecionar ou cadastrar um equipamento.');
      }

      final PrioridadeOSModel prioridadeEnum = PrioridadeOSModel.values.firstWhere(
            (p) => p.name == prioridade.toUpperCase(),
        orElse: () => PrioridadeOSModel.MEDIA,
      );

      final int clienteIdInt = int.parse(clienteId);
      final int tecnicoIdInt = int.parse(tecnicoId);

      final Cliente clienteSelecionado = state.clientes.firstWhere((c) => c.id == clienteIdInt);
      final Usuario? tecnicoSelecionado = state.tecnicos.firstWhere((t) => t.id == tecnicoIdInt);

      late Equipamento equipamentoParaOS;

      if (novoEquipamentoData != null) {
        final equipamentoACriar = Equipamento(
          tipo: novoEquipamentoData['tipo'],
          marcaModelo: novoEquipamentoData['marcaModelo'],
          numeroSerieChassi: novoEquipamentoData['numeroSerieChassi'],
          horimetro: novoEquipamentoData['horimetro'],
          clienteId: clienteIdInt,
        );
        equipamentoParaOS = await _equipamentoRepository.createEquipamento(equipamentoACriar);
      } else {
        final int equipamentoId = int.parse(equipamentoExistenteId!);
        equipamentoParaOS = await _equipamentoRepository.getEquipamentoById(equipamentoId);
      }

      final novaOS = OrdemServico(
        numeroOS: state.nextOsNumber ?? '',
        status: StatusOSModel.EM_ABERTO,
        dataAbertura: dataAbertura,
        dataAgendamento: dataAgendamento,
        cliente: clienteSelecionado,
        equipamento: equipamentoParaOS,
        tecnicoAtribuido: tecnicoSelecionado,
        problemaRelatado: descricaoProblema,
        prioridade: prioridadeEnum,
      );

      await _osRepository.createOrdemServico(novaOS);

      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, submissionError: 'Erro ao criar OS: ${e.toString()}');
      return false;
    }
  }
}
