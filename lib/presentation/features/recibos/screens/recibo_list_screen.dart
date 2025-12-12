import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:open_filex/open_filex.dart';

import '../../../../domain/entities/recibo.dart';
import '../../../shared/styles/app_colors.dart';
import '../../../shared/providers/repository_providers.dart';
import '../providers/recibo_list_provider.dart';
import 'novo_recibo_screen.dart';
import 'recibo_detail_screen.dart';

class RecibosListScreen extends ConsumerStatefulWidget {
  const RecibosListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RecibosListScreen> createState() => _RecibosListScreenState();
}

class _RecibosListScreenState extends ConsumerState<RecibosListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reciboListProvider.notifier).refreshRecibos();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime? date) => date != null ? DateFormat('dd/MM/yyyy').format(date) : '--/--/----';
  String _formatCurrency(double? value) => value != null ? NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(value) : 'R\$ --,--';

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

  Future<void> _deleteRecibo(BuildContext context, WidgetRef ref, Recibo recibo) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.errorRed),
            const SizedBox(width: 10),
            Text('Confirmar Exclusão', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ],
        ),
        content: Text('Deseja realmente excluir o recibo ${recibo.numeroRecibo}?', style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancelar', style: GoogleFonts.poppins(color: AppColors.textLight)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Excluir', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(reciboListProvider.notifier).deleteRecibo(recibo.id!);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Recibo excluído com sucesso!', style: GoogleFonts.poppins()),
              backgroundColor: AppColors.successGreen,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir recibo: ${e.toString()}', style: GoogleFonts.poppins()),
              backgroundColor: AppColors.errorRed,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reciboListProvider);
    final notifier = ref.read(reciboListProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        title: Text(
          'Recibos',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primaryBlue,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryBlue,
                AppColors.secondaryBlue,
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildPageHeader(context, notifier),
          Expanded(
            child: _buildBodyContent(context, state, notifier),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'reciboListFAB',
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const NovoReciboScreen()),
          );
          ref.read(reciboListProvider.notifier).refreshRecibos();
        },
        backgroundColor: AppColors.primaryBlue,
        shape: const CircleBorder(),
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildPageHeader(BuildContext context, ReciboListNotifier notifier) {
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
                  onChanged: (value) {
                    // Implementar busca se necessário
                  },
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(color: AppColors.primaryBlue, borderRadius: BorderRadius.circular(12)),
                child: IconButton(
                  onPressed: () {
                    notifier.refreshRecibos();
                  },
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  tooltip: 'Atualizar',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBodyContent(BuildContext context, ReciboListState state, ReciboListNotifier notifier) {
    if (state.isLoading && state.recibos.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue));
    }

    if (state.errorMessage != null && state.recibos.isEmpty) {
      return _buildErrorState(state.errorMessage!, () => notifier.refreshRecibos());
    }

    if (state.recibos.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => notifier.refreshRecibos(),
      color: AppColors.primaryBlue,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        physics: const BouncingScrollPhysics(),
        itemCount: state.recibos.length,
        itemBuilder: (context, index) => _buildReciboCard(context, ref, state.recibos[index]),
      ),
    );
  }

  Widget _buildReciboCard(BuildContext context, WidgetRef ref, Recibo recibo) {
    return Card(
      elevation: 3,
      shadowColor: AppColors.primaryBlue.withOpacity(0.1),
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => ReciboDetailScreen(reciboId: recibo.id!)),
          );
          ref.read(reciboListProvider.notifier).refreshRecibos();
        },
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
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
                          recibo.numeroRecibo,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          recibo.cliente,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppColors.textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.download, size: 22),
                          color: AppColors.primaryBlue,
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                          onPressed: () => _downloadPdf(context, ref, recibo),
                          tooltip: 'Baixar PDF',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.errorRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.delete, size: 22),
                          color: AppColors.errorRed,
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                          onPressed: () => _deleteRecibo(context, ref, recibo),
                          tooltip: 'Excluir',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(color: AppColors.dividerColor, height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.attach_money_outlined, size: 16, color: AppColors.textDark),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            _formatCurrency(recibo.valor),
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.textDark),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            _formatDate(recibo.dataCriacao),
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

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

  Widget _buildErrorState(String errorMessage, VoidCallback onRetry) {
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
            Text(errorMessage, style: GoogleFonts.poppins(color: AppColors.textLight, fontSize: 14), textAlign: TextAlign.center),
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 60, color: AppColors.textLight),
            const SizedBox(height: 20),
            Text(
              'Nenhum Recibo Encontrado',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Crie um novo recibo para que ele apareça aqui.',
              style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textLight),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
