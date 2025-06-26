import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../domain/entities/peca_material.dart';
import '../../../shared/providers/repository_providers.dart';
import '../../../shared/styles/app_colors.dart';
import '../providers/peca_material_detail_provider.dart';
import '../providers/peca_material_list_provider.dart';
import 'peca_material_edit_screen.dart';

class PecaMaterialDetailScreen extends ConsumerWidget {
  final int pecaId;

  const PecaMaterialDetailScreen({required this.pecaId, Key? key}) : super(key: key);

  // Método para deletar a peça/material
  Future<void> _deletePeca(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Confirmar Exclusão', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text('Tem certeza que deseja excluir este item?', style: GoogleFonts.poppins()),
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
        await ref.read(pecaMaterialRepositoryProvider).deletePecaMaterial(pecaId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item excluído com sucesso!'), backgroundColor: AppColors.successGreen));
          ref.invalidate(pecaMaterialListProvider);
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao excluir item: ${e.toString()}'), backgroundColor: AppColors.errorRed));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pecaAsyncValue = ref.watch(pecaMaterialDetailProvider(pecaId));

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        title: Text(
          pecaAsyncValue.when(
            data: (peca) => peca.descricao,
            loading: () => 'Carregando...',
            error: (err, stack) => 'Detalhes do Item',
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
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => ref.invalidate(pecaMaterialDetailProvider(pecaId)),
            tooltip: 'Atualizar',
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: pecaAsyncValue.maybeWhen(
              data: (peca) => () async {
                await Navigator.of(context).push(
                  // Navega para a nova tela de edição
                  MaterialPageRoute(builder: (context) => PecaMaterialEditScreen(pecaId: peca.id!)),
                );
                // Invalida os providers para recarregar os dados ao voltar
                ref.invalidate(pecaMaterialDetailProvider(pecaId));
                ref.invalidate(pecaMaterialListProvider);
              },
              orElse: () => null,
            ),
            tooltip: 'Editar Item',
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.white),
            onPressed: pecaAsyncValue.maybeWhen(
              data: (_) => () => _deletePeca(context, ref),
              orElse: () => null,
            ),
            tooltip: 'Excluir Item',
          ),
        ],
      ),
      body: pecaAsyncValue.when(
        data: (peca) {
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(pecaMaterialDetailProvider(pecaId)),
            color: AppColors.primaryBlue,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildPecaHeaderCard(peca),
                const SizedBox(height: 20),
                _buildInfoCard(
                  title: 'Detalhes do Item',
                  icon: Icons.inventory_2_outlined,
                  children: [
                    _buildDetailRow(label: 'Código', value: peca.codigo, icon: Icons.qr_code_2_outlined),
                    _buildDetailRow(label: 'Descrição', value: peca.descricao, icon: Icons.description_outlined),
                    _buildDetailRow(label: 'Preço', value: NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(peca.preco ?? 0), icon: Icons.price_change_outlined),
                    _buildDetailRow(label: 'Estoque', value: '${peca.estoque ?? 0} unidades', icon: Icons.warehouse_outlined),
                  ],
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue)),
        error: (err, stack) => Center(child: Text('Erro ao carregar item: $err')),
      ),
    );
  }

  // Card de cabeçalho específico para a peça/material
  Widget _buildPecaHeaderCard(PecaMaterial peca) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        color: AppColors.cardBackground,
        boxShadow: [
          BoxShadow(color: AppColors.primaryBlue.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
              child: const Icon(Icons.construction, size: 30, color: AppColors.primaryBlue),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    peca.descricao, // cite: uploaded:lib/domain/entities/peca_material.dart
                    style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Código: ${peca.codigo}', // cite: uploaded:lib/domain/entities/peca_material.dart
                    style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textLight),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widgets de UI genéricos reutilizados
  Widget _buildInfoCard({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
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
                  decoration: BoxDecoration(color: AppColors.primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Icon(icon, size: 20, color: AppColors.primaryBlue),
                ),
                const SizedBox(width: 12),
                Text(title, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textDark)),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, color: AppColors.dividerColor),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({required String label, String? value, IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: AppColors.textLight),
            const SizedBox(width: 8),
          ],
          SizedBox(
            width: 100, // Largura ajustada para Peças
            child: Text('$label:', style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textLight, fontWeight: FontWeight.w500)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(value ?? '--', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
          ),
        ],
      ),
    );
  }
}