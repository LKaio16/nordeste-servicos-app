// lib/presentation/features/os/providers/nova_os_provider.dart

import 'package:flutter/foundation.dart'; // Import for kDebugMode
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nordeste_servicos_app/data/models/prioridade_os_model.dart';
import 'package:nordeste_servicos_app/data/models/status_os_model.dart';

// Use package imports for robustness
import 'package:nordeste_servicos_app/domain/entities/cliente.dart';
import 'package:nordeste_servicos_app/domain/entities/equipamento.dart';
import 'package:nordeste_servicos_app/domain/entities/usuario.dart';
import 'package:nordeste_servicos_app/domain/repositories/cliente_repository.dart';
import 'package:nordeste_servicos_app/domain/repositories/equipamento_repository.dart';
import 'package:nordeste_servicos_app/domain/repositories/usuario_repository.dart';
import 'package:nordeste_servicos_app/domain/repositories/os_repository.dart'; // Para criar a OS
import 'package:nordeste_servicos_app/presentation/shared/providers/repository_providers.dart';
import 'nova_os_state.dart';

// *** IMPORTAÇÕES ADICIONAIS PARA CRIAÇÃO DA OS ***
import 'package:nordeste_servicos_app/domain/entities/ordem_servico.dart';

// Provider principal para a tela Nova OS
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
  final OsRepository _osRepository; // Repositório para criar a OS

  NovaOsNotifier(
      this._clienteRepository,
      this._equipamentoRepository,
      this._usuarioRepository,
      this._osRepository,
      ) : super(const NovaOsState());

  // Carrega os dados iniciais necessários para o formulário
  Future<void> loadInitialData() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      // Busca clientes, técnicos, próximo número e equipamentos em paralelo
      final results = await Future.wait([
        _clienteRepository.getClientes(), // Assumindo que existe este método
        _usuarioRepository.getUsuarios(), // Agora usa o nome correto
        _osRepository.getNextOsNumber(), // Busca o próximo número da OS
        _equipamentoRepository.getEquipamentos(), // *** CORREÇÃO: Busca os equipamentos ***
      ]);

      final clientes = results[0] as List<Cliente>;
      // Filtra apenas usuários com perfil de técnico (ajuste conforme seu modelo)
      final tecnicos = (results[1] as List<Usuario>)
          .where((u) => u.perfil.name.toLowerCase() == 'tecnico') // Ajuste o nome do perfil se necessário
          .toList();
      final nextOsNumber = results[2] as String?;
      final equipamentos = results[3] as List<Equipamento>; // *** CORREÇÃO: Atribui os equipamentos buscados ***

      state = state.copyWith(
        isLoading: false,
        clientes: clientes,
        tecnicos: tecnicos,
        equipamentos: equipamentos, // *** CORREÇÃO: Atualiza o estado com os equipamentos ***
        nextOsNumber: nextOsNumber,
      );
    } catch (e, stackTrace) { // Adicionado stackTrace
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

  // TODO: Implementar método para carregar equipamentos por cliente, se necessário
  // Future<void> loadEquipamentosPorCliente(String clienteId) async { ... }

  // Cria uma nova Ordem de Serviço
  Future<bool> createOrdemServico({
    required String clienteId,
    required String equipamentoId,
    required String descricaoProblema,
    required String tecnicoId,
    required String prioridade, // Recebe 'Baixa', 'Média', 'Alta'
    required DateTime dataAbertura,
    DateTime? dataAgendamento,
  }) async {
    state = state.copyWith(isSubmitting: true, clearSubmissionError: true);

    // *** LOG: Imprime os valores recebidos do formulário ***
    if (kDebugMode) {
      print('--- createOrdemServico: Iniciando ---');
      print('Cliente ID (String): $clienteId');
      print('Equipamento ID (String): $equipamentoId');
      print('Tecnico ID (String): $tecnicoId');
      print('Prioridade (String): $prioridade');
      print('Descrição: $descricaoProblema');
      print('Data Abertura: $dataAbertura');
      print('Data Agendamento: $dataAgendamento');
      print('Próximo Número OS (do estado): ${state.nextOsNumber}');
    }

    try {
      // *** LOG: Tentando mapear prioridade ***
      if (kDebugMode) print('Tentando mapear prioridade...');
      final PrioridadeOSModel prioridadeEnum = PrioridadeOSModel.values.firstWhere(
            (p) => p.name.toLowerCase() == prioridade.toLowerCase(),
        orElse: () => PrioridadeOSModel.MEDIA, // Valor padrão caso não encontre
      );
      if (kDebugMode) print('Prioridade mapeada para: $prioridadeEnum');

      // *** LOG: Tentando converter IDs ***
      if (kDebugMode) print('Tentando converter IDs para int...');
      final int clienteIdInt = int.parse(clienteId);
      if (kDebugMode) print('Cliente ID (int): $clienteIdInt');
      final int equipamentoIdInt = int.parse(equipamentoId);
      if (kDebugMode) print('Equipamento ID (int): $equipamentoIdInt');
      final int tecnicoIdInt = int.parse(tecnicoId);
      if (kDebugMode) print('Tecnico ID (int): $tecnicoIdInt');

      // Cria o objeto OrdemServico com os dados do formulário
      final novaOS = OrdemServico(
        numeroOS: state.nextOsNumber ?? '',
        status: StatusOSModel.EM_ABERTO,
        dataAbertura: dataAbertura,
        dataAgendamento: dataAgendamento,
        clienteId: clienteIdInt,
        equipamentoId: equipamentoIdInt,
        tecnicoAtribuidoId: tecnicoIdInt,
        problemaRelatado: descricaoProblema,
        prioridade: prioridadeEnum,
      );

      // *** LOG: Objeto OrdemServico criado ***
      if (kDebugMode) {
        print('Objeto OrdemServico criado: ${novaOS.toString()}'); // Adicione um método toString() na entidade se necessário
        print('Chamando _osRepository.createOrdemServico...');
      }

      // Chama o repositório para criar a OS na API
      await _osRepository.createOrdemServico(novaOS);

      if (kDebugMode) print('Criação da OS no repositório concluída com sucesso.');

      state = state.copyWith(isSubmitting: false);
      return true; // Indica sucesso

    } catch (e, stackTrace) { // Adicionado stackTrace
      // *** LOG: Erro capturado dentro do createOrdemServico do Notifier ***
      if (kDebugMode) {
        print('*******************************************');
        print('*** ERRO em createOrdemServico (Notifier) ***');
        print('Erro: ${e.toString()}');
        // Verifica se é FormatException para dar mais detalhes
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
        submissionError: 'Erro ao criar OS: ${e.toString()}', // Exibe o erro na UI
      );
      return false; // Indica falha
    }
  }
}

