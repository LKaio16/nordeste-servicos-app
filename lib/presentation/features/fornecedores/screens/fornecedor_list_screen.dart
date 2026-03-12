import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../domain/entities/fornecedor.dart';
import '../../../shared/styles/app_colors.dart';
import '../providers/fornecedor_list_provider.dart';
import 'novo_fornecedor_screen.dart';

class FornecedorListScreen extends ConsumerStatefulWidget {
  const FornecedorListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<FornecedorListScreen> createState() => _FornecedorListScreenState();
}

class _FornecedorListScreenState extends ConsumerState<FornecedorListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(fornecedorListProvider.notifier).refreshFornecedores();
    });
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, Fornecedor f) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.errorRed),
            const SizedBox(width: 10),
            Text('Excluir fornecedor', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ],
        ),
        content: Text(
          'Deseja realmente excluir "${f.nome}"?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancelar', style: GoogleFonts.poppins(color: AppColors.textLight)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Excluir', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true && f.id != null) {
      await ref.read(fornecedorListProvider.notifier).deleteFornecedor(f.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fornecedor excluído.', style: GoogleFonts.poppins()), backgroundColor: AppColors.successGreen),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(fornecedorListProvider);
    final notifier = ref.read(fornecedorListProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        title: Text('Fornecedores', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white)),
        backgroundColor: AppColors.primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
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
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Row(
              children: [
                Expanded(child: const SizedBox()),
                Container(
                  decoration: BoxDecoration(color: AppColors.primaryBlue, borderRadius: BorderRadius.circular(12)),
                  child: IconButton(
                    onPressed: () => notifier.refreshFornecedores(),
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    tooltip: 'Atualizar',
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildBody(context, state, notifier),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fornecedorFAB',
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (context) => const NovoFornecedorScreen()));
          notifier.refreshFornecedores();
        },
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBody(BuildContext context, FornecedorListState state, FornecedorListNotifier notifier) {
    if (state.isLoading && state.fornecedores.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue));
    }
    if (state.errorMessage != null && state.fornecedores.isEmpty) {
      return _buildError(state.errorMessage!, () => notifier.refreshFornecedores());
    }
    if (state.fornecedores.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.business_outlined, size: 60, color: AppColors.textLight),
              const SizedBox(height: 20),
              Text('Nenhum fornecedor', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textDark)),
              const SizedBox(height: 8),
              Text('Os fornecedores cadastrados aparecerão aqui.', style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textLight), textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => notifier.refreshFornecedores(),
      color: AppColors.primaryBlue,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        physics: const BouncingScrollPhysics(),
        itemCount: state.fornecedores.length,
        itemBuilder: (context, index) => _buildCard(context, ref, state.fornecedores[index]),
      ),
    );
  }

  Widget _buildCard(BuildContext context, WidgetRef ref, Fornecedor f) {
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
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.business_outlined, color: AppColors.primaryBlue, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(f.nome, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16, color: AppColors.textDark)),
                  if (f.cnpj != null && f.cnpj!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text('CNPJ: ${f.cnpj}', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textLight)),
                  ],
                  if (f.telefone != null && f.telefone!.isNotEmpty)
                    Text(f.telefone!, style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textLight)),
                ],
              ),
            ),
            if (f.status != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: f.status == 'ATIVO' ? AppColors.successGreen.withOpacity(0.15) : AppColors.textLight.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(f.status!, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500)),
              ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 22),
              color: AppColors.errorRed,
              onPressed: () => _confirmDelete(context, ref, f),
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
}
