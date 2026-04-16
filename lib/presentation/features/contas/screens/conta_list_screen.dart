import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../domain/entities/conta.dart';
import '../../../shared/styles/app_colors.dart';
import '../providers/conta_list_provider.dart';
import 'nova_conta_screen.dart';

class ContaListScreen extends ConsumerStatefulWidget {
  const ContaListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ContaListScreen> createState() => _ContaListScreenState();
}

class _ContaListScreenState extends ConsumerState<ContaListScreen> {
  final ScrollController _scrollController = ScrollController();

  String _formatDate(DateTime? d) => d != null ? DateFormat('dd/MM/yyyy').format(d) : '--';
  String _formatCurrency(double? v) => v != null ? NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(v) : 'R\$ --';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(contaListProvider.notifier).refreshContas();
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
      ref.read(contaListProvider.notifier).loadMoreContas();
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, Conta c) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.errorRed),
            const SizedBox(width: 10),
            Text('Excluir conta', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ],
        ),
        content: Text('Deseja realmente excluir esta conta?', style: GoogleFonts.poppins()),
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
    if (confirmed == true && c.id != null) {
      await ref.read(contaListProvider.notifier).deleteConta(c.id!);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Conta excluída.', style: GoogleFonts.poppins()), backgroundColor: AppColors.successGreen));
    }
  }

  Future<void> _marcarComoPaga(BuildContext context, WidgetRef ref, Conta c) async {
    if (c.status == 'PAGO') return;
    final notifier = ref.read(contaListProvider.notifier);
    await notifier.marcarComoPaga(c.id!);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Conta marcada como paga.', style: GoogleFonts.poppins()), backgroundColor: AppColors.successGreen));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(contaListProvider);
    final notifier = ref.read(contaListProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        title: Text('Contas a pagar / receber', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white)),
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
                  child: IconButton(onPressed: () => notifier.refreshContas(), icon: const Icon(Icons.refresh, color: Colors.white), tooltip: 'Atualizar'),
                ),
              ],
            ),
          ),
          Expanded(child: _buildBody(context, state, notifier)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'contaFAB',
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (context) => const NovaContaScreen()));
          notifier.refreshContas();
        },
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ContaListState state, ContaListNotifier notifier) {
    if (state.isLoading && state.contas.isEmpty) return const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue));
    if (state.errorMessage != null && state.contas.isEmpty) return _buildError(state.errorMessage!, () => notifier.refreshContas());
    if (state.contas.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.account_balance_wallet_outlined, size: 60, color: AppColors.textLight),
              const SizedBox(height: 20),
              Text('Nenhuma conta', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textDark)),
              const SizedBox(height: 8),
              Text('Contas a pagar e a receber aparecerão aqui.', style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textLight), textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => notifier.refreshContas(),
      color: AppColors.primaryBlue,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        physics: const BouncingScrollPhysics(),
        itemCount: state.contas.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.contas.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator(color: AppColors.primaryBlue)),
            );
          }
          return _buildCard(context, ref, state.contas[index]);
        },
      ),
    );
  }

  Widget _buildCard(BuildContext context, WidgetRef ref, Conta c) {
    final isPago = c.status == 'PAGO';
    final isPagar = c.tipo == 'PAGAR';
    return Card(
      elevation: 3,
      shadowColor: AppColors.primaryBlue.withOpacity(0.1),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (isPagar ? AppColors.warningOrange : AppColors.successGreen).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.account_balance_wallet_outlined, color: isPagar ? AppColors.warningOrange : AppColors.successGreen, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.descricao ?? 'Conta', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16, color: AppColors.textDark)),
                      Text(c.fornecedorNome ?? c.clienteNome ?? '--', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textLight)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(_formatCurrency(c.valor), style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.textDark)),
                    Text(_formatDate(c.dataVencimento), style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textLight)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPago ? AppColors.successGreen.withOpacity(0.15) : AppColors.warningOrange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(c.status ?? '--', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500)),
                ),
                Row(
                  children: [
                    if (!isPago)
                      TextButton.icon(
                        onPressed: () => _marcarComoPaga(context, ref, c),
                        icon: const Icon(Icons.check_circle_outline, size: 18),
                        label: Text('Marcar paga', style: GoogleFonts.poppins(fontSize: 12)),
                      ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 22),
                      color: AppColors.errorRed,
                      onPressed: () => _confirmDelete(context, ref, c),
                      tooltip: 'Excluir',
                    ),
                  ],
                ),
              ],
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
