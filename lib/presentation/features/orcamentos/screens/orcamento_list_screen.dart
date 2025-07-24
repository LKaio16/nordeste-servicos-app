import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:nordeste_servicos_app/data/models/status_orcamento_model.dart';
import 'package:nordeste_servicos_app/presentation/features/orcamentos/screens/novo_orcamento_screen.dart';
import 'package:nordeste_servicos_app/presentation/features/orcamentos/screens/orcamento_detail_screen.dart';

import '../../../../domain/entities/orcamento.dart';
import '../../../shared/styles/app_colors.dart';
import '../providers/orcamento_list_provider.dart';

// MUDANÇA 1: Convertido para ConsumerStatefulWidget
class OrcamentosListScreen extends ConsumerStatefulWidget {
  const OrcamentosListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OrcamentosListScreen> createState() => _OrcamentosListScreenState();
}

class _OrcamentosListScreenState extends ConsumerState<OrcamentosListScreen> {
  final TextEditingController _searchController = TextEditingController();

  // MUDANÇA 2: Recarregar dados ao iniciar a tela
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(orcamentoListProvider.notifier).refreshOrcamentos();
      final currentSearchTerm = ref.read(orcamentoListProvider).searchTerm;
      _searchController.text = currentSearchTerm;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- Funções Auxiliares de Estilo (sem alterações) ---
  Color _getStatusBackgroundColor(StatusOrcamentoModel status) {
    switch (status) {
      case StatusOrcamentoModel.APROVADO: return AppColors.successGreen.withOpacity(0.1);
      case StatusOrcamentoModel.PENDENTE: return AppColors.warningOrange.withOpacity(0.1);
      default: return AppColors.errorRed.withOpacity(0.1);
    }
  }

  Color _getStatusTextColor(StatusOrcamentoModel status) {
    switch (status) {
      case StatusOrcamentoModel.APROVADO: return AppColors.successGreen;
      case StatusOrcamentoModel.PENDENTE: return AppColors.warningOrange;
      default: return AppColors.errorRed;
    }
  }

  String _getStatusText(StatusOrcamentoModel status) {
    switch (status) {
      case StatusOrcamentoModel.APROVADO: return 'Aprovado';
      case StatusOrcamentoModel.PENDENTE: return 'Pendente';
      case StatusOrcamentoModel.REJEITADO: return 'Rejeitado';
      case StatusOrcamentoModel.CANCELADO: return 'Cancelado';
      default: return 'Desconhecido';
    }
  }

  String _formatDate(DateTime? date) => date != null ? DateFormat('dd/MM/yyyy').format(date) : '--/--/----';
  String _formatCurrency(double? value) => value != null ? NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(value) : 'R\$ --,--';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(orcamentoListProvider);
    final notifier = ref.read(orcamentoListProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      body: Column(
        children: [
          _buildPageHeader(context, notifier, state.searchTerm),
          Expanded(
            child: _buildBodyContent(context, state, notifier),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        // MUDANÇA 3: Adicionada heroTag para corrigir o erro do console
        heroTag: 'orcamentoListFAB',
        onPressed: () async {
          // Após a tela de novo orçamento ser fechada, recarrega a lista
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const NovoOrcamentoScreen()),
          );
          ref.read(orcamentoListProvider.notifier).refreshOrcamentos();
        },
        backgroundColor: AppColors.primaryBlue,
        shape: const CircleBorder(),
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildPageHeader(BuildContext context, OrcamentoListNotifier notifier, String currentSearchTerm) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Orçamentos', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textDark),
                  decoration: InputDecoration(
                    hintText: 'Buscar por número, cliente...',
                    hintStyle: GoogleFonts.poppins(color: AppColors.textLight),
                    prefixIcon: const Icon(Icons.search, color: AppColors.textLight),
                    filled: true,
                    fillColor: AppColors.backgroundGray,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
                  ),
                  onChanged: notifier.updateSearchTerm,
                  onSubmitted: notifier.searchOrcamentos,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(color: AppColors.primaryBlue, borderRadius: BorderRadius.circular(12)),
                child: IconButton(
                  onPressed: () => notifier.searchOrcamentos(_searchController.text),
                  icon: const Icon(Icons.search, color: Colors.white),
                  tooltip: 'Pesquisar',
                ),
              ),
              if (currentSearchTerm.isNotEmpty) ...[
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(color: AppColors.textLight, borderRadius: BorderRadius.circular(12)),
                  child: IconButton(
                    onPressed: () {
                      _searchController.clear();
                      notifier.clearSearch();
                    },
                    icon: const Icon(Icons.clear, color: Colors.white),
                    tooltip: 'Limpar pesquisa',
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBodyContent(BuildContext context, OrcamentoListState state, OrcamentoListNotifier notifier) {
    if (state.isLoading && state.orcamentos.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue));
    }

    if (state.errorMessage != null && state.orcamentos.isEmpty) {
      return _buildErrorState(state.errorMessage!, () => notifier.refreshOrcamentos());
    }

    if (state.orcamentos.isEmpty) {
      return _buildEmptyState(state.searchTerm.isNotEmpty, notifier);
    }

    return RefreshIndicator(
      onRefresh: () => notifier.refreshOrcamentos(),
      color: AppColors.primaryBlue,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        physics: const BouncingScrollPhysics(),
        itemCount: state.orcamentos.length,
        itemBuilder: (context, index) => _buildOrcamentoCard(context, state.orcamentos[index]),
      ),
    );
  }

  Widget _buildOrcamentoCard(BuildContext context, Orcamento orcamento) {
    return Card(
      elevation: 3,
      shadowColor: AppColors.primaryBlue.withOpacity(0.1),
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        // MUDANÇA 4: Implementado o onTap para navegação
        onTap: () async {
          // Navega para a tela de detalhes
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => OrcamentoDetailScreen(orcamentoId: orcamento.id!)),
          );
          // Ao voltar da tela de detalhes, recarrega a lista para refletir possíveis alterações
          ref.read(orcamentoListProvider.notifier).refreshOrcamentos();
        },
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('#${orcamento.numeroOrcamento}', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primaryBlue)),
                        const SizedBox(height: 8),
                        Text(orcamento.nomeCliente ?? 'Cliente não informado', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16, color: AppColors.textDark), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  Chip(
                    label: Text(_getStatusText(orcamento.status), style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: _getStatusTextColor(orcamento.status))),
                    backgroundColor: _getStatusBackgroundColor(orcamento.status),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: AppColors.dividerColor, height: 1),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCardInfoItem(icon: Icons.calendar_today_outlined, label: 'Validade', value: _formatDate(orcamento.dataValidade)),
                  _buildCardInfoItem(icon: Icons.attach_money_outlined, label: 'Valor Total', value: _formatCurrency(orcamento.valorTotal)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // O resto dos widgets de build (_buildCardInfoItem, _buildErrorState, _buildEmptyState) permanecem os mesmos
  Widget _buildCardInfoItem({required IconData icon, required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textLight)),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(icon, size: 16, color: AppColors.textDark),
            const SizedBox(width: 6),
            Text(value, style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textDark, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorState(String message, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_rounded, color: AppColors.errorRed.withOpacity(0.7), size: 60),
            const SizedBox(height: 20),
            Text('Erro ao Carregar', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(message, style: GoogleFonts.poppins(color: AppColors.textLight, fontSize: 14), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: Text('Tentar Novamente', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isSearching, OrcamentoListNotifier notifier) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isSearching ? Icons.search_off : Icons.receipt_long_outlined, size: 60, color: AppColors.textLight),
            const SizedBox(height: 20),
            Text(
              isSearching ? 'Nenhum resultado encontrado' : 'Nenhum Orçamento Encontrado',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isSearching ? 'Tente ajustar os termos da sua busca.' : 'Crie um novo orçamento para que ele apareça aqui.',
              style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textLight),
              textAlign: TextAlign.center,
            ),
            if (isSearching) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  _searchController.clear();
                  notifier.clearSearch();
                },
                icon: const Icon(Icons.clear, color: Colors.white),
                label: Text('Limpar Pesquisa', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}