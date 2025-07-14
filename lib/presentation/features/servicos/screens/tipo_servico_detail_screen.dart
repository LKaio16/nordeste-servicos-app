import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../shared/providers/repository_providers.dart';
import '../../../shared/styles/app_colors.dart';
import '../providers/tipo_servico_detail_provider.dart';
import '../providers/tipo_servico_list_provider.dart';
import 'tipo_servico_edit_screen.dart';

class TipoServicoDetailScreen extends ConsumerWidget {
  final int servicoId;
  const TipoServicoDetailScreen({required this.servicoId, Key? key}) : super(key: key);

  // Método para deletar o tipo de serviço
  Future<void> _deleteServico(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Confirmar Exclusão', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text('Tem certeza que deseja excluir este tipo de serviço?', style: GoogleFonts.poppins()),
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
        // Chama o repositório para deletar o serviço
        await ref.read(tipoServicoRepositoryProvider).deleteTipoServico(servicoId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Serviço excluído com sucesso!'), backgroundColor: AppColors.successGreen));
          // Invalida o provider da lista para forçar a atualização na tela anterior
          ref.invalidate(tipoServicoListProvider);
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao excluir serviço: ${e.toString()}'), backgroundColor: AppColors.errorRed));
        }
      }
    }
  }


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicoAsyncValue = ref.watch(tipoServicoDetailProvider(servicoId));

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        title: servicoAsyncValue.when(
          data: (servico) => Text(servico.descricao, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white)),
          loading: () => Text('Carregando...', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white)),
          error: (e,s) => Text('Detalhes do Serviço', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white)),
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
            icon: const Icon(Icons.edit, color: Colors.white),
            tooltip: 'Editar Serviço',
            onPressed: servicoAsyncValue.whenOrNull(
              data: (servico) => () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => TipoServicoEditScreen(servico: servico)),
                );
                ref.invalidate(tipoServicoDetailProvider(servicoId));
                ref.invalidate(tipoServicoListProvider);
              },
            ),
          ),
          // Botão de deletar adicionado
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.white),
            tooltip: 'Excluir Serviço',
            onPressed: servicoAsyncValue.whenOrNull(
              data: (_) => () => _deleteServico(context, ref),
            ),
          )
        ],
      ),
      body: servicoAsyncValue.when(
        data: (servico) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(tipoServicoDetailProvider(servicoId)),
          color: AppColors.primaryBlue,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildInfoCard(
                title: 'Detalhes do Tipo de Serviço',
                icon: Icons.miscellaneous_services_outlined,
                children: [
                  _buildDetailRow(label: 'ID do Serviço', value: servico.id.toString(), icon: Icons.tag),
                  _buildDetailRow(label: 'Descrição', value: servico.descricao, icon: Icons.description_outlined),
                ],
              )
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue)),
        error: (err, stack) => Center(child: Text('Erro: $err')),
      ),
    );
  }

  // Widgets de UI genéricos para consistência visual
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
            const SizedBox(width: 12),
          ],
          SizedBox(
            width: 100,
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
