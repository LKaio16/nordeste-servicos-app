// lib/presentation/features/orcamentos/providers/orcamento_edit_provider.dart

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nordeste_servicos_app/core/error/exceptions.dart';
import 'package:nordeste_servicos_app/domain/entities/cliente.dart';
import 'package:nordeste_servicos_app/domain/entities/item_orcamento.dart';
import 'package:nordeste_servicos_app/domain/entities/ordem_servico.dart';
import 'package:nordeste_servicos_app/domain/entities/orcamento.dart';
import 'package:nordeste_servicos_app/domain/entities/peca_material.dart';
import 'package:nordeste_servicos_app/domain/entities/tipo_servico.dart';
import 'package:nordeste_servicos_app/domain/repositories/cliente_repository.dart';
import 'package:nordeste_servicos_app/domain/repositories/item_orcamento_repository.dart';
import 'package:nordeste_servicos_app/domain/repositories/os_repository.dart';
import 'package:nordeste_servicos_app/domain/repositories/orcamento_repository.dart';
import 'package:nordeste_servicos_app/domain/repositories/peca_material_repository.dart';
import 'package:nordeste_servicos_app/domain/repositories/tipo_servico_repository.dart';
import 'package:nordeste_servicos_app/presentation/shared/providers/repository_providers.dart';

// O Estado permanece o mesmo da versão anterior
class OrcamentoEditState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  final Orcamento? originalOrcamento;
  final List<Cliente> clientes;
  final bool isLoadingOs;
  final List<OrdemServico> ordensDeServico;
  final bool isSubmitting;
  final String? submissionError;
  final bool isLoadingItens;
  final List<ItemOrcamento> itens;
  final List<PecaMaterial> pecas;
  final List<TipoServico> servicos;

  const OrcamentoEditState({
    this.isLoading = true,
    this.errorMessage,
    this.originalOrcamento,
    this.clientes = const [],
    this.isLoadingOs = false,
    this.ordensDeServico = const [],
    this.isSubmitting = false,
    this.submissionError,
    this.isLoadingItens = false,
    this.itens = const [],
    this.pecas = const [],
    this.servicos = const [],
  });

  OrcamentoEditState copyWith({
    bool? isLoading,
    String? errorMessage,
    Orcamento? originalOrcamento,
    List<Cliente>? clientes,
    bool? isLoadingOs,
    List<OrdemServico>? ordensDeServico,
    bool? isSubmitting,
    String? submissionError,
    bool? isLoadingItens,
    List<ItemOrcamento>? itens,
    List<PecaMaterial>? pecas,
    List<TipoServico>? servicos,
    bool clearErrors = false,
  }) {
    return OrcamentoEditState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrors ? null : errorMessage ?? this.errorMessage,
      originalOrcamento: originalOrcamento ?? this.originalOrcamento,
      clientes: clientes ?? this.clientes,
      isLoadingOs: isLoadingOs ?? this.isLoadingOs,
      ordensDeServico: ordensDeServico ?? this.ordensDeServico,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submissionError: clearErrors ? null : submissionError ?? this.submissionError,
      isLoadingItens: isLoadingItens ?? this.isLoadingItens,
      itens: itens ?? this.itens,
      pecas: pecas ?? this.pecas,
      servicos: servicos ?? this.servicos,
    );
  }

  @override
  List<Object?> get props => [
    isLoading, errorMessage, originalOrcamento, clientes, isLoadingOs,
    ordensDeServico, isSubmitting, submissionError, isLoadingItens,
    itens, pecas, servicos
  ];
}

class OrcamentoEditNotifier extends StateNotifier<OrcamentoEditState> {
  final int orcamentoId; // <<< ADICIONADO
  final OrcamentoRepository _orcamentoRepository;
  final ClienteRepository _clienteRepository;
  final OsRepository _osRepository;
  final ItemOrcamentoRepository _itemOrcamentoRepository;
  final PecaMaterialRepository _pecaMaterialRepository;
  final TipoServicoRepository _tipoServicoRepository;

  // <<< CORREÇÃO APLICADA AQUI >>>
  // O Notifier agora recebe o orcamentoId e chama o loadInitialData no seu próprio construtor.
  OrcamentoEditNotifier(
      this.orcamentoId,
      this._orcamentoRepository,
      this._clienteRepository,
      this._osRepository,
      this._itemOrcamentoRepository,
      this._pecaMaterialRepository,
      this._tipoServicoRepository,
      ) : super(const OrcamentoEditState()) {
    loadInitialData();
  }

  // O parâmetro orcamentoId foi removido daqui pois já temos na classe
  Future<void> loadInitialData() async {
    state = state.copyWith(isLoading: true, clearErrors: true);
    try {
      final results = await Future.wait([
        _orcamentoRepository.getOrcamentoById(orcamentoId),
        _clienteRepository.getClientes(),
        _itemOrcamentoRepository.getItemOrcamentosByOrcamentoId(orcamentoId),
        _pecaMaterialRepository.getPecasMateriais(),
        _tipoServicoRepository.getTiposServico(),
      ]);

      final orcamento = results[0] as Orcamento;
      final clientes = results[1] as List<Cliente>;
      final itens = results[2] as List<ItemOrcamento>;
      final pecas = results[3] as List<PecaMaterial>;
      final servicos = results[4] as List<TipoServico>;

      state = state.copyWith(
        isLoading: false,
        originalOrcamento: orcamento,
        clientes: clientes,
        itens: itens,
        pecas: pecas,
        servicos: servicos,
      );

      if(state.originalOrcamento != null) {
        await fetchOrdensDeServico(state.originalOrcamento!.clienteId);
      }

    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: "Erro ao carregar dados: ${e.toString()}");
    }
  }

  Future<void> fetchOrdensDeServico(int clienteId) async {
    state = state.copyWith(isLoadingOs: true, ordensDeServico: []);
    try {
      final ordens = await _osRepository.getOrdensServico(clienteId: clienteId);
      state = state.copyWith(isLoadingOs: false, ordensDeServico: ordens);
    } catch (e) {
      state = state.copyWith(isLoadingOs: false);
    }
  }

  Future<bool> updateOrcamento(Orcamento orcamento) async {
    state = state.copyWith(isSubmitting: true, clearErrors: true);
    try {
      await _orcamentoRepository.updateOrcamento(orcamento);
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, submissionError: "Erro ao atualizar: ${e.toString()}");
      return false;
    }
  }

  Future<void> addItem(ItemOrcamento item) async {
    state = state.copyWith(isLoadingItens: true);
    try {
      await _itemOrcamentoRepository.createItemOrcamento(item);
      await loadInitialData(); // Recarrega tudo para garantir consistência
    } catch (e) {
      state = state.copyWith(submissionError: "Erro ao adicionar item: ${e.toString()}");
    } finally {
      state = state.copyWith(isLoadingItens: false);
    }
  }

  Future<void> deleteItem(int itemId) async {
    state = state.copyWith(isLoadingItens: true);
    try {
      await _itemOrcamentoRepository.deleteItemOrcamento(orcamentoId, itemId);
      await loadInitialData();
    } catch (e) {
      state = state.copyWith(submissionError: "Erro ao remover item: ${e.toString()}");
    } finally {
      state = state.copyWith(isLoadingItens: false);
    }
  }
}

// O provider agora passa o orcamentoId para o construtor do Notifier
final orcamentoEditProvider = StateNotifierProvider.family.autoDispose<OrcamentoEditNotifier, OrcamentoEditState, int>((ref, orcamentoId) {
  return OrcamentoEditNotifier(
    orcamentoId,
    ref.watch(orcamentoRepositoryProvider),
    ref.watch(clienteRepositoryProvider),
    ref.watch(osRepositoryProvider),
    ref.watch(itemOrcamentoRepositoryProvider),
    ref.watch(pecaMaterialRepositoryProvider),
    ref.watch(tipoServicoRepositoryProvider),
  );
});