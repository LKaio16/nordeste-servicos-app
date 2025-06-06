import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart'; // Para kDebugMode

// Importações locais (ajuste os caminhos conforme sua estrutura de projeto)

// *** Entidades e Enums do Domínio (usados pela Tela e Notifier) ***
import '../../../../domain/entities/cliente.dart';
import '../../../../domain/entities/equipamento.dart';
import '../../../../domain/entities/ordem_servico.dart'; // Contém OrdemServico, StatusOS, PrioridadeOS
import '../../../../domain/entities/usuario.dart';

// Importações de Repositórios e Estado
import '../../../../domain/repositories/os_repository.dart';
import '../../../../domain/repositories/cliente_repository.dart';
import '../../../../domain/repositories/equipamento_repository.dart';
import '../../../../domain/repositories/usuario_repository.dart';
import '../../../shared/providers/repository_providers.dart'; // Assumindo que seus providers de repo estão aqui
import 'os_edit_state.dart';

// *** NOVAS IMPORTAÇÕES NECESSÁRIAS (mantidas) ***
// Certifique-se de que estes caminhos estão corretos
import 'os_detail_provider.dart'; // Para invalidar o provedor de detalhes
import 'os_list_provider.dart';   // Para invalidar o provedor da lista

// Provider para a edição da OS, usando .family para passar o ID
final osEditProvider = StateNotifierProvider.family<OsEditNotifier, OsEditState, int>((ref, osId) {
  // Injete as dependências dos repositórios
  return OsEditNotifier(
    ref.read(osRepositoryProvider), // Certifique-se que este provider existe
    ref.read(clienteRepositoryProvider), // Certifique-se que este provider existe
    ref.read(equipamentoRepositoryProvider), // Certifique-se que este provider existe
    ref.read(usuarioRepositoryProvider), // Certifique-se que este provider existe
    osId,
    ref, // Passe o 'ref' para o notifier
  );
});

class OsEditNotifier extends StateNotifier<OsEditState> {
  final OsRepository _osRepository;
  final ClienteRepository _clienteRepository;
  final EquipamentoRepository _equipamentoRepository;
  final UsuarioRepository _usuarioRepository;
  final int _osId;
  final Ref _ref; // Declare a referência ao Ref

  OsEditNotifier(
      this._osRepository,
      this._clienteRepository,
      this._equipamentoRepository,
      this._usuarioRepository,
      this._osId,
      this._ref, // Inicialize o Ref no construtor
      ) : super(const OsEditState());

  // Carrega os dados iniciais: OS a ser editada e listas para dropdowns
  Future<void> loadInitialData() async {
    state = state.copyWith(isLoadingInitialData: true, clearInitialError: true);
    try {
      final List<dynamic> results = await Future.wait([
        _osRepository.getOrdemServicoById(_osId),
        _clienteRepository.getClientes(),
        _usuarioRepository.getUsuarios(),
        _equipamentoRepository.getEquipamentos(),
      ]);

      // Casts mais seguros
      final originalOs = results[0] as OrdemServico;
      final clientes = (results[1] as List).cast<Cliente>();
      final tecnicos = (results[2] as List)
          .cast<Usuario>()
          .where((u) => u.perfil.toString().toLowerCase() == 'tecnico')
          .toList();
      final equipamentos = (results[3] as List).cast<Equipamento>();

      if (!mounted) return;

      state = state.copyWith(
        isLoadingInitialData: false,
        originalOs: originalOs,
        clientes: clientes,
        tecnicos: tecnicos,
        equipamentos: equipamentos,
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('*******************************************');
        print('*** ERRO em loadInitialData (OsEditNotifier) para OS ID: $_osId ***');
        print('Erro: ${e.toString()}');
        print('Stack Trace:');
        print(stackTrace);
        print('*******************************************');
      }
      if (!mounted) return;
      state = state.copyWith(
        isLoadingInitialData: false,
        initialDataError: 'Erro ao carregar dados para edição: ${e.toString()}',
      );
    }
  }

  // Atualiza a Ordem de Serviço
  Future<bool> updateOrdemServico(OrdemServico updatedOsEntity) async { // Recebe a ENTIDADE da tela
    state = state.copyWith(isSubmitting: true, clearSubmissionError: true, submissionSuccess: false);

    try {
      if (kDebugMode) {
        print('--- updateOrdemServico (Provider): Iniciando atualização para OS ID: ${updatedOsEntity.id} ---');
        print('  Dados da ENTIDADE recebidos da tela (e enviados ao repositório):');
        print('    Problema: ${updatedOsEntity.problemaRelatado}');
        print('    Data Agend.: ${updatedOsEntity.dataAgendamento}');
        print('    Status (Entity): ${updatedOsEntity.status}'); // Enum StatusOS
        print('    Prioridade (Entity): ${updatedOsEntity.prioridade}'); // Enum PrioridadeOS?
        print('----------------------------------------------------');
      }

      if (updatedOsEntity.id != _osId) {
        throw Exception('Tentativa de atualizar OS com ID incorreto.');
      }

      // *** CHAMAR O REPOSITÓRIO COM A ENTIDADE ***
      await _osRepository.updateOrdemServico(updatedOsEntity); // Passa a ENTIDADE

      if (kDebugMode) {
        print('--- updateOrdemServico (Provider): Chamada ao repositório concluída com sucesso para OS ID: $_osId ---\n');
      }

      if (!mounted) return false;

      // --- NOVO: INVALIDAR PROVEDORES APÓS O SUCESSO ---

      // 1. Invalida o provedor de detalhes da OS específica
      // Se osDetailProvider é um FutureProvider, simplesmente o invalidamos.
      // NÃO USE .notifier.loadOsDetails() em um FutureProvider.
      _ref.invalidate(osDetailProvider(updatedOsEntity.id!)); // <--- CORRIGIDO AQUI!
      if (kDebugMode) {
        print('OsDetailProvider para OS ID ${updatedOsEntity.id} invalidado.');
      }

      // 2. Invalida o provedor da lista de OSs
      // Se osListProvider for um FutureProvider, invalidate() o fará recarregar.
      _ref.invalidate(osListProvider);
      if (kDebugMode) {
        print('OsListProvider invalidado.');
      }

      // ----------------------------------------------------

      state = state.copyWith(isSubmitting: false, submissionSuccess: true);
      return true; // Indica sucesso

    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('*******************************************');
        print('*** ERRO em updateOrdemServico (OsEditNotifier) para OS ID: $_osId ***');
        print('Erro: ${e.toString()}');
        print('Stack Trace:');
        print(stackTrace);
        print('*******************************************');
      }

      if (!mounted) return false;

      state = state.copyWith(
        isSubmitting: false,
        submissionError: 'Erro ao salvar alterações: ${e.toString()}',
        submissionSuccess: false,
      );
      return false; // Indica falha
    }
  }
}