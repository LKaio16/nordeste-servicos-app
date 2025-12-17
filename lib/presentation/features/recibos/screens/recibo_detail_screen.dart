import 'dart:typed_data';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';

import '../../../../domain/entities/recibo.dart';
import '../../../shared/providers/repository_providers.dart';
import '../../../shared/styles/app_colors.dart';
import '../providers/recibo_detail_provider.dart';
import '../providers/recibo_list_provider.dart';

class ReciboDetailScreen extends ConsumerWidget {
  final int reciboId;

  const ReciboDetailScreen({required this.reciboId, Key? key}) : super(key: key);

  String _formatDate(DateTime? date) {
    if (date == null) return '--/--/----';
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  String _formatCurrency(double? value) {
    if (value == null) return 'R\$ --,--';
    return NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(value);
  }

  Future<void> _deleteRecibo(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Confirmar Exclusão', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text('Tem certeza que deseja excluir este recibo? Esta ação não pode ser desfeita.', style: GoogleFonts.poppins()),
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
        await ref.read(reciboRepositoryProvider).deleteRecibo(reciboId);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Recibo excluído com sucesso!'), backgroundColor: AppColors.successGreen),
          );
          ref.invalidate(reciboListProvider);
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao excluir recibo: ${e.toString()}'), backgroundColor: AppColors.errorRed),
          );
        }
      }
    }
  }

  Future<void> _downloadPdf(BuildContext context, WidgetRef ref, Recibo recibo) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text('Baixando PDF do Recibo ${recibo.numeroRecibo}...'),
        backgroundColor: AppColors.primaryBlue,
      ),
    );

    try {
      final repository = ref.read(reciboRepositoryProvider);
      final Uint8List pdfBytes = await repository.downloadReciboPdf(recibo.id!);

      final String fileName = 'recibo_${recibo.numeroRecibo}.pdf';
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
    final reciboAsyncValue = ref.watch(reciboDetailProvider(reciboId));

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        title: Text(
          reciboAsyncValue.when(
            data: (recibo) => recibo.numeroRecibo,
            loading: () => 'Carregando...',
            error: (err, stack) => 'Detalhes do Recibo',
          ),
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primaryBlue, AppColors.secondaryBlue],
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          reciboAsyncValue.when(
            data: (recibo) => IconButton(
              icon: const Icon(Icons.download, color: Colors.white),
              onPressed: () => _downloadPdf(context, ref, recibo),
              tooltip: 'Baixar PDF',
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          reciboAsyncValue.when(
            data: (recibo) => IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: () => _deleteRecibo(context, ref),
              tooltip: 'Excluir',
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: reciboAsyncValue.when(
        data: (recibo) => SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildInfoCard(
                title: 'Informações do Recibo',
                icon: Icons.receipt_long_outlined,
                children: [
                  _buildInfoRow('Número', recibo.numeroRecibo, Icons.numbers),
                  const SizedBox(height: 16),
                  _buildInfoRow('Cliente', recibo.cliente, Icons.person),
                  const SizedBox(height: 16),
                  _buildInfoRow('Valor', _formatCurrency(recibo.valor), Icons.attach_money),
                  const SizedBox(height: 16),
                  _buildInfoRow('Data de Criação', _formatDate(recibo.dataCriacao), Icons.calendar_today),
                ],
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                title: 'Referente a',
                icon: Icons.description_outlined,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundGray,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      recibo.referenteA,
                      style: GoogleFonts.poppins(fontSize: 15, color: AppColors.textDark, height: 1.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue)),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: AppColors.errorRed, size: 64),
                const SizedBox(height: 16),
                Text(
                  'Erro ao carregar recibo',
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textDark),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textLight),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => ref.invalidate(reciboDetailProvider(reciboId)),
                  icon: const Icon(Icons.refresh),
                  label: Text('Tentar Novamente', style: GoogleFonts.poppins()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(color: AppColors.primaryBlue.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, size: 24, color: AppColors.primaryBlue),
                ),
                const SizedBox(width: 16),
                Text(title, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textDark)),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(color: AppColors.dividerColor, height: 1),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primaryBlue),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textLight)),
              const SizedBox(height: 4),
              Text(value, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark)),
            ],
          ),
        ),
      ],
    );
  }
}


