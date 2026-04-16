import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../domain/entities/nota_fiscal.dart';
import '../../../shared/styles/app_colors.dart';
import '../providers/nota_fiscal_list_provider.dart';
import 'nova_nota_fiscal_screen.dart';

class NotaFiscalListScreen extends ConsumerStatefulWidget {
  const NotaFiscalListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<NotaFiscalListScreen> createState() => _NotaFiscalListScreenState();
}

class _NotaFiscalListScreenState extends ConsumerState<NotaFiscalListScreen> {
  final ScrollController _scrollController = ScrollController();

  String _formatDate(DateTime? d) => d != null ? DateFormat('dd/MM/yyyy').format(d) : '--';
  String _formatCurrency(double? v) => v != null ? NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(v) : 'R\$ --';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notaFiscalListProvider.notifier).refreshNotasFiscais();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (currentScroll >= (maxScroll - 200)) {
      ref.read(notaFiscalListProvider.notifier).loadMoreNotasFiscais();
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, NotaFiscal n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.errorRed),
            const SizedBox(width: 10),
            Text('Excluir nota fiscal', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ],
        ),
        content: Text('Deseja realmente excluir a nota ${n.numeroNota ?? "?"}?', style: GoogleFonts.poppins()),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text('Cancelar', style: GoogleFonts.poppins(color: AppColors.textLight))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Excluir', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true && n.id != null) {
      await ref.read(notaFiscalListProvider.notifier).deleteNotaFiscal(n.id!);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Nota fiscal excluída.', style: GoogleFonts.poppins()), backgroundColor: AppColors.successGreen));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notaFiscalListProvider);
    final notifier = ref.read(notaFiscalListProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        title: Text('Notas Fiscais', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white)),
        backgroundColor: AppColors.primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.primaryBlue, AppColors.secondaryBlue]),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            decoration: BoxDecoration(color: AppColors.cardBackground, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
            child: Row(
              children: [
                const Expanded(child: SizedBox()),
                Container(
                  decoration: BoxDecoration(color: AppColors.primaryBlue, borderRadius: BorderRadius.circular(12)),
                  child: IconButton(onPressed: () => notifier.refreshNotasFiscais(), icon: const Icon(Icons.refresh, color: Colors.white), tooltip: 'Atualizar'),
                ),
              ],
            ),
          ),
          Expanded(child: _buildBody(context, state, notifier)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'notaFiscalFAB',
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (context) => const NovaNotaFiscalScreen()));
          notifier.refreshNotasFiscais();
        },
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBody(BuildContext context, NotaFiscalListState state, NotaFiscalListNotifier notifier) {
    if (state.isLoading && state.notasFiscais.isEmpty) return const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue));
    if (state.errorMessage != null && state.notasFiscais.isEmpty) return _buildError(state.errorMessage!, () => notifier.refreshNotasFiscais());
    if (state.notasFiscais.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.description_outlined, size: 60, color: AppColors.textLight),
              const SizedBox(height: 20),
              Text('Nenhuma nota fiscal', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textDark)),
              const SizedBox(height: 8),
              Text('As notas fiscais cadastradas aparecerão aqui.', style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textLight), textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => notifier.refreshNotasFiscais(),
      color: AppColors.primaryBlue,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        physics: const BouncingScrollPhysics(),
        itemCount: state.notasFiscais.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.notasFiscais.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator(color: AppColors.primaryBlue)),
            );
          }
          return _buildCard(context, ref, state.notasFiscais[index]);
        },
      ),
    );
  }

  Widget _buildCard(BuildContext context, WidgetRef ref, NotaFiscal n) {
    return Card(
      elevation: 3,
      shadowColor: AppColors.primaryBlue.withOpacity(0.1),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.darkBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.description_outlined, color: AppColors.darkBlue, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(n.numeroNota ?? 'Sem número', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16, color: AppColors.textDark)),
                  Text(n.fornecedorNome ?? n.clienteNome ?? n.nomeEmitente ?? '--', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textLight)),
                  Text(_formatDate(n.dataEmissao), style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textLight)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(_formatCurrency(n.valorTotal), style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.textDark)),
                if (n.tipo != null) Text(n.tipo!, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textLight)),
              ],
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 22),
              color: AppColors.errorRed,
              onPressed: () => _confirmDelete(context, ref, n),
              tooltip: 'Excluir',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String msg, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_rounded, color: AppColors.errorRed.withOpacity(0.7), size: 60),
            const SizedBox(height: 20),
            Text('Erro ao carregar', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(msg, style: GoogleFonts.poppins(color: AppColors.textLight, fontSize: 14), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: Text('Tentar novamente', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
            ),
          ],
        ),
      ),
    );
  }
}
