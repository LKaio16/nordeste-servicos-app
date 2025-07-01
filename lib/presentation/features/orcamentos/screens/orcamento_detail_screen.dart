import 'dart:typed_data';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:nordeste_servicos_app/data/models/status_orcamento_model.dart';
import 'package:nordeste_servicos_app/domain/entities/item_orcamento.dart';
import 'package:nordeste_servicos_app/domain/entities/orcamento.dart';
import 'package:nordeste_servicos_app/presentation/features/orcamentos/providers/orcamento_detail_provider.dart';
import 'package:nordeste_servicos_app/presentation/features/orcamentos/providers/orcamento_list_provider.dart';
import 'package:nordeste_servicos_app/presentation/shared/providers/repository_providers.dart';
import 'package:nordeste_servicos_app/presentation/shared/styles/app_colors.dart';
import 'package:open_filex/open_filex.dart';

import 'orcamento_edit_screen.dart';

class OrcamentoDetailScreen extends ConsumerWidget {
  final int orcamentoId;

  const OrcamentoDetailScreen({required this.orcamentoId, Key? key}) : super(key: key);

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

  Future<void> _deleteOrcamento(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Confirmar Exclusão', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text('Tem certeza que deseja excluir este orçamento? Esta ação não pode ser desfeita.', style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancelar', style: GoogleFonts.poppins(color: AppColors.textLight)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: Text('Excluir', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(orcamentoRepositoryProvider).deleteOrcamento(orcamentoId);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Orçamento excluído com sucesso!'), backgroundColor: AppColors.successGreen),
          );
          ref.invalidate(orcamentoListProvider);
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao excluir orçamento: ${e.toString()}'), backgroundColor: AppColors.errorRed),
          );
        }
      }
    }
  }

  Future<void> _downloadPdf(BuildContext context, WidgetRef ref, Orcamento orcamento) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text('Baixando PDF do Orçamento #${orcamento.numeroOrcamento}...'),
        backgroundColor: AppColors.primaryBlue,
      ),
    );

    try {
      final repository = ref.read(orcamentoRepositoryProvider);
      final Uint8List pdfBytes = await repository.downloadOrcamentoPdf(orcamento.id!);

      final String fileName = 'orcamento_${orcamento.numeroOrcamento}.pdf';
      String? filePath;

      if (!kIsWeb) {
        filePath = await FileSaver.instance.saveFile(
          name: fileName,
          bytes: pdfBytes,
          ext: 'pdf',
          mimeType: MimeType.pdf,
        );
      } else {
        await FileSaver.instance.saveFile(name: fileName, bytes: pdfBytes, ext: 'pdf', mimeType: MimeType.pdf);
      }

      scaffoldMessenger.removeCurrentSnackBar();
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: const Text('Download concluído!'),
          backgroundColor: AppColors.successGreen,
          action: (!kIsWeb && filePath != null)
              ? SnackBarAction(
            label: 'ABRIR',
            textColor: Colors.white,
            onPressed: () => OpenFilex.open(filePath!),
          )
              : null,
        ),
      );
    } catch (e) {
      scaffoldMessenger.removeCurrentSnackBar();
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Erro ao baixar PDF: ${e.toString()}'),
          backgroundColor: AppColors.errorRed,
        ),
      );
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
            tooltip: 'Editar Orçamento',
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => OrcamentoEditScreen(orcamentoId: orcamentoId)),
              );
              ref.invalidate(orcamentoDetailProvider(orcamentoId));
              ref.invalidate(itemOrcamentoListProvider(orcamentoId));
            },
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: orcamentoAsync.whenOrNull(
              data: (orcamento) => () => _downloadPdf(context, ref, orcamento),
            ),
            tooltip: 'Gerar PDF',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _deleteOrcamento(context, ref),
            tooltip: 'Excluir Orçamento',
          ),
        ],
      ),
      body: orcamentoAsync.when(
        data: (orcamento) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(orcamentoDetailProvider(orcamentoId));
            ref.invalidate(itemOrcamentoListProvider(orcamentoId));
          },
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildHeaderCard(orcamento),
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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
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
                      Text(
                        'Cliente',
                        style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textLight, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        orcamento.nomeCliente ?? 'Não informado',
                        style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(orcamento.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusText(orcamento.status),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(orcamento.status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, color: AppColors.dividerColor),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildHeaderInfoItem('Data de Criação', _formatDate(orcamento.dataCriacao), Icons.calendar_today_outlined),
                _buildHeaderInfoItem('Validade', _formatDate(orcamento.dataValidade), Icons.event_available_outlined),
              ],
            ),
            if (orcamento.ordemServicoOrigemId != null) ...[
              const SizedBox(height: 16),
              _buildHeaderInfoItem('OS de Origem', '#${orcamento.ordemServicoOrigemId}', Icons.receipt_long_outlined),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderInfoItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(color: AppColors.textLight, fontSize: 12)),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(icon, color: AppColors.primaryBlue, size: 16),
            const SizedBox(width: 8),
            Text(
              value,
              style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildItensCard(BuildContext context, WidgetRef ref) {
    final itensAsync = ref.watch(itemOrcamentoListProvider(orcamentoId));
    final orcamentoAsync = ref.watch(orcamentoDetailProvider(orcamentoId));

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.shopping_cart_outlined, size: 20, color: AppColors.primaryBlue),
                ),
                const SizedBox(width: 12),
                Text('Itens e Valor Total', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textDark)),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, color: AppColors.dividerColor),
            const SizedBox(height: 8),
            itensAsync.when(
              data: (itens) {
                if (itens.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Center(child: Text('Nenhum item adicionado.')),
                  );
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: itens.length,
                  itemBuilder: (context, index) => _buildItemTile(itens[index]),
                  separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Erro ao carregar itens: $err')),
            ),
            const Divider(height: 24, thickness: 1.5, color: AppColors.dividerColor),
            orcamentoAsync.when(
              data: (orcamento) => Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('VALOR TOTAL:', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textLight)),
                  const SizedBox(width: 12),
                  Text(
                    _formatCurrency(orcamento.valorTotal),
                    style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                  ),
                ],
              ),
              loading: () => const SizedBox.shrink(),
              error: (_,__) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemTile(ItemOrcamento item) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
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
        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark),
      ),
    );
  }

  Widget _buildObservacoesCard(Orcamento orcamento) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.notes_outlined, size: 20, color: AppColors.primaryBlue),
                ),
                const SizedBox(width: 12),
                Text('Observações e Condições', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textDark)),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, color: AppColors.dividerColor),
            const SizedBox(height: 16),
            Text(
              orcamento.observacoesCondicoes?.isNotEmpty == true ? orcamento.observacoesCondicoes! : 'Nenhuma observação.',
              style: GoogleFonts.poppins(color: AppColors.textLight, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}