import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nordeste_servicos_app/data/models/prioridade_os_model.dart';
import 'package:nordeste_servicos_app/data/models/status_os_model.dart';

import 'package:nordeste_servicos_app/domain/entities/cliente.dart';
import 'package:nordeste_servicos_app/domain/entities/equipamento.dart'; // Keep this import
import 'package:nordeste_servicos_app/domain/entities/usuario.dart';
import 'package:nordeste_servicos_app/domain/repositories/cliente_repository.dart';
import 'package:nordeste_servicos_app/domain/repositories/equipamento_repository.dart'; // Keep this import
import 'package:nordeste_servicos_app/domain/repositories/usuario_repository.dart';
import 'package:nordeste_servicos_app/domain/repositories/os_repository.dart';
import 'package:nordeste_servicos_app/presentation/shared/providers/repository_providers.dart';
import 'nova_os_state.dart';

import 'package:nordeste_servicos_app/domain/entities/ordem_servico.dart';

final novaOsProvider = StateNotifierProvider<NovaOsNotifier, NovaOsState>((ref) {
  return NovaOsNotifier(
    ref.read(clienteRepositoryProvider),
    ref.read(equipamentoRepositoryProvider), // This must be injected
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


  // This method was indeed missing or misplaced. It's crucial for loading
  // initial data like clients and technicians when the screen loads.
  @override // You might not need @override if it's not implementing an abstract method
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
  required String clienteId,
  required String tipoEquipamento,
  required String marcaModeloEquipamento,
  required String numeroSerieChassiEquipamento,
  double? horimetroEquipamento,
  required String descricaoProblema,
  required String tecnicoId,
  required String prioridade,
  required DateTime dataAbertura,
  DateTime? dataAgendamento,
  }) async {
  state = state.copyWith(isSubmitting: true, clearSubmissionError: true);

  if (kDebugMode) {
  print('--- createOrdemServico: Iniciando ---');
  }

  try {
  final PrioridadeOSModel prioridadeEnum = PrioridadeOSModel.values.firstWhere(
  (p) => p.name.toLowerCase() == prioridade.toLowerCase(),
  orElse: () => PrioridadeOSModel.MEDIA,
  );

  final int clienteIdInt = int.parse(clienteId);
  final int tecnicoIdInt = int.parse(tecnicoId);

  final Cliente clienteSelecionado = state.clientes.firstWhere(
  (c) => c.id == clienteIdInt,
  orElse: () {
  throw Exception('Cliente com ID $clienteIdInt não encontrado.');
  },
  );

  final Usuario? tecnicoSelecionado = state.tecnicos.firstWhere(
  (t) => t.id == tecnicoIdInt,
  orElse: () {
  throw Exception('Técnico com ID $tecnicoIdInt não encontrado.');
  },
  );

  // CRITICAL STEP 1: Create the equipment on the backend FIRST
  final Equipamento newEquipmentData = Equipamento(
  id: null, // ID is null for new equipment, backend will assign one
  tipo: tipoEquipamento,
  marcaModelo: marcaModeloEquipamento,
  numeroSerieChassi: numeroSerieChassiEquipamento,
  horimetro: horimetroEquipamento,
  clienteId: clienteIdInt, // Link to the selected client
  );

  if (kDebugMode) {
  print('Attempting to create new equipment via API...');
  print('Sending equipment data: ${newEquipmentData.tipo}, ${newEquipmentData.marcaModelo}, ${newEquipmentData.numeroSerieChassi}');
  }

  // CALL THE EQUIPMENT REPOSITORY TO CREATE THE EQUIPMENT
  final Equipamento createdEquipamento = await _equipamentoRepository.createEquipamento(newEquipmentData);

  if (kDebugMode) {
  print('New equipment created successfully by backend. Assigned ID: ${createdEquipamento.id}');
  }

  // CRITICAL STEP 2: Now, use the returned `createdEquipamento` (which has an ID) to build the OrdemServico
  final novaOS = OrdemServico(
  numeroOS: state.nextOsNumber ?? '',
  status: StatusOSModel.EM_ABERTO,
  dataAbertura: dataAbertura,
  dataAgendamento: dataAgendamento,
  cliente: clienteSelecionado,
  equipamento: createdEquipamento, // IMPORTANT: Use the equipment WITH the ID!
  tecnicoAtribuido: tecnicoSelecionado,
  problemaRelatado: descricaoProblema,
  prioridade: prioridadeEnum,
  );

  if (kDebugMode) {
  print('Objeto OrdemServico pronto para ser enviado (with equipment ID): ${novaOS.toString()}');
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