import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:nordeste_servicos_app/data/models/status_orcamento_model.dart';
import 'package:nordeste_servicos_app/domain/entities/item_orcamento.dart';
import 'package:nordeste_servicos_app/domain/entities/orcamento.dart';
import 'package:nordeste_servicos_app/presentation/features/orcamentos/providers/orcamento_detail_provider.dart';
import 'package:nordeste_servicos_app/presentation/features/orcamentos/providers/orcamento_list_provider.dart';
import 'package:nordeste_servicos_app/presentation/shared/styles/app_colors.dart';

import 'orcamento_edit_screen.dart';

class OrcamentoDetailScreen extends ConsumerWidget {
  final int orcamentoId;

  const OrcamentoDetailScreen({required this.orcamentoId, Key? key}) : super(key: key);

  // --- Funções Auxiliares de Estilo ---
  String _formatDate(DateTime? date) {
    if (date == null) return '--/--/----';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _formatCurrency(double? value) {
    if (value == null) return 'R\$ --,--';
    return NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(value);
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

  Color _getStatusColor(StatusOrcamentoModel status) {
    switch (status) {
      case StatusOrcamentoModel.APROVADO: return AppColors.successGreen;
      case StatusOrcamentoModel.PENDENTE: return AppColors.warningOrange;
      case StatusOrcamentoModel.REJEITADO:
      case StatusOrcamentoModel.CANCELADO: return AppColors.errorRed;
      default: return AppColors.textLight;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orcamentoAsync = ref.watch(orcamentoDetailProvider(orcamentoId));

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        title: orcamentoAsync.when(
          data: (orcamento) => Text(
            'Orçamento #${orcamento.numeroOrcamento}',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white),
          ),
          loading: () => Text('Carregando...', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white)),
          error: (_, __) => Text('Detalhes do Orçamento', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white)),
        ),
        backgroundColor: AppColors.primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () { Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => OrcamentoEditScreen(orcamentoId: orcamentoId)),
            ); },
            tooltip: 'Editar Orçamento',
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: () { /* TODO: Lógica para gerar PDF */ },
            tooltip: 'Gerar PDF',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () { /* TODO: Lógica para deletar */ },
            tooltip: 'Excluir Orçamento',
          ),
        ],
      ),
      body: orcamentoAsync.when(
        data: (orcamento) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(orcamentoDetailProvider(orcamentoId)),
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildHeaderCard(orcamento),
              const SizedBox(height: 20),
              _buildInfoGeraisCard(orcamento),
              const SizedBox(height: 20),
              _buildItensCard(context, ref),
              const SizedBox(height: 20),
              _buildObservacoesCard(orcamento),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erro ao carregar orçamento: $err')),
      ),
    );
  }

  Widget _buildHeaderCard(Orcamento orcamento) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    orcamento.nomeCliente ?? 'Cliente não informado',
                    style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Chip(
                  label: Text(_getStatusText(orcamento.status), style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                  backgroundColor: _getStatusColor(orcamento.status),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (orcamento.ordemServicoOrigemId != null)
              Text(
                'Origem: OS #${orcamento.ordemServicoOrigemId}',
                style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textLight),
              ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildHeaderInfoItem('Criação', _formatDate(orcamento.dataCriacao)),
                _buildHeaderInfoItem('Validade', _formatDate(orcamento.dataValidade)),
                _buildHeaderInfoItem('Valor Total', _formatCurrency(orcamento.valorTotal), isTotal: true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderInfoItem(String label, String value, {bool isTotal = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(color: AppColors.textLight, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: isTotal ? 18 : 15,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: isTotal ? AppColors.primaryBlue : AppColors.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoGeraisCard(Orcamento orcamento) {
    // Este card pode conter mais informações se necessário
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Informações Gerais', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
            const Divider(height: 24),
            // Adicione mais detalhes se precisar, por exemplo, dados do cliente.
            // Por enquanto, o cabeçalho já tem as informações principais.
            Text('Este orçamento é válido até a data indicada e sujeito às condições comerciais descritas.', style: GoogleFonts.poppins(color: AppColors.textLight)),
          ],
        ),
      ),
    );
  }

  Widget _buildItensCard(BuildContext context, WidgetRef ref) {
    final itensAsync = ref.watch(itemOrcamentoListProvider(orcamentoId));
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Itens do Orçamento', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
            const Divider(height: 24),
            itensAsync.when(
              data: (itens) {
                if (itens.isEmpty) {
                  return const Center(child: Text('Nenhum item adicionado a este orçamento.'));
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: itens.length,
                  itemBuilder: (context, index) {
                    final item = itens[index];
                    return _buildItemTile(item);
                  },
                  separatorBuilder: (context, index) => const Divider(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Erro ao carregar itens: $err')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemTile(ItemOrcamento item) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
        child: Icon(item.pecaMaterialId != null ? Icons.construction : Icons.design_services, color: AppColors.primaryBlue, size: 20),
      ),
      title: Text(item.descricao, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      subtitle: Text(
        '${item.quantidade} x ${_formatCurrency(item.valorUnitario)}',
        style: GoogleFonts.poppins(color: AppColors.textLight),
      ),
      trailing: Text(
        _formatCurrency(item.subtotal),
        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15),
      ),
    );
  }

  Widget _buildObservacoesCard(Orcamento orcamento) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Observações', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
            const Divider(height: 24),
            Text(
              orcamento.observacoesCondicoes ?? 'Nenhuma observação.',
              style: GoogleFonts.poppins(color: AppColors.textLight, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}