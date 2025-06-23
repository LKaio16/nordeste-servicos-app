import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../domain/entities/equipamento.dart';
import '../../../shared/providers/repository_providers.dart';
import '../../../shared/styles/app_colors.dart';
import '../providers/equipamento_detail_provider.dart';
import '../providers/equipamento_list_provider.dart';
import 'equipamento_edit_screen.dart'; // Placeholder

class EquipamentoDetailScreen extends ConsumerWidget {
  final int equipamentoId;

  const EquipamentoDetailScreen({required this.equipamentoId, Key? key}) : super(key: key);

  // Método para deletar o equipamento
  Future<void> _deleteEquipamento(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Confirmar Exclusão', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text('Tem certeza que deseja excluir este equipamento?', style: GoogleFonts.poppins()),
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
        final equipamentoRepository = ref.read(equipamentoRepositoryProvider);
        await equipamentoRepository.deleteEquipamento(equipamentoId);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Equipamento excluído com sucesso!'), backgroundColor: AppColors.successGreen));
          ref.invalidate(equipamentoListProvider); // Invalida a lista para recarregar
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao excluir equipamento: ${e.toString()}'), backgroundColor: AppColors.errorRed));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final equipamentoAsyncValue = ref.watch(equipamentoDetailProvider(equipamentoId));

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        title: Text(
          equipamentoAsyncValue.when(
            data: (equipamento) => equipamento.marcaModelo,
            loading: () => 'Carregando...',
            error: (err, stack) => 'Detalhes do Equipamento',
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
            onPressed: () => ref.invalidate(equipamentoDetailProvider(equipamentoId)),
            tooltip: 'Atualizar',
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: equipamentoAsyncValue.maybeWhen(
              data: (equipamento) => () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => EquipamentoEditScreen(equipamento: equipamento)),
                );
                ref.invalidate(equipamentoDetailProvider(equipamentoId));
                ref.invalidate(equipamentoListProvider);
              },
              orElse: () => null,
            ),
            tooltip: 'Editar Equipamento',
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.white),
            onPressed: equipamentoAsyncValue.maybeWhen(
              data: (_) => () => _deleteEquipamento(context, ref),
              orElse: () => null,
            ),
            tooltip: 'Excluir Equipamento',
          ),
        ],
      ),
      body: equipamentoAsyncValue.when(
        data: (equipamento) {
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(equipamentoDetailProvider(equipamentoId)),
            color: AppColors.primaryBlue,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildEquipamentoHeaderCard(equipamento),
                const SizedBox(height: 20),
                _buildInfoCard(
                  title: 'Detalhes Técnicos',
                  icon: Icons.settings_outlined,
                  children: [
                    _buildDetailRow(label: 'Tipo', value: equipamento.tipo, icon: Icons.category_outlined),
                    _buildDetailRow(label: 'Marca/Modelo', value: equipamento.marcaModelo, icon: Icons.branding_watermark_outlined),
                    _buildDetailRow(label: 'Nº de Série/Chassi', value: equipamento.numeroSerieChassi, icon: Icons.confirmation_number_outlined),
                    _buildDetailRow(label: 'Horímetro', value: equipamento.horimetro?.toString() ?? '--', icon: Icons.timer_outlined),
                  ],
                ),
                const SizedBox(height: 20),
                _buildInfoCard(
                  title: 'Proprietário',
                  icon: Icons.person_search_outlined,
                  children: [
                    // A entidade Equipamento possui clienteId, que é o que temos aqui.
                    // Para exibir o nome, seria necessário um novo `FutureProvider` ou enriquecer o dado no backend.
                    _buildDetailRow(label: 'ID do Cliente', value: equipamento.clienteId.toString(), icon: Icons.badge_outlined),
                  ],
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue)),
        error: (err, stack) => Center(child: Text('Erro ao carregar equipamento: $err')),
      ),
    );
  }

  // Card de cabeçalho específico para o equipamento
  Widget _buildEquipamentoHeaderCard(Equipamento equipamento) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        color: AppColors.cardBackground,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
              child: const Icon(Icons.build_circle_outlined, size: 30, color: AppColors.primaryBlue),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    equipamento.marcaModelo, // cite: uploaded:lib/domain/entities/equipamento.dart
                    style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    equipamento.tipo, // cite: uploaded:lib/domain/entities/equipamento.dart
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

  // Os widgets de UI abaixo são genéricos e podem ser copiados da sua OsDetailScreen
  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
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
                  child: Icon(
                    icon,
                    size: 20,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.dividerColor,
                    AppColors.dividerColor.withOpacity(0.1),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  // Linha de detalhe aprimorada
  Widget _buildDetailRow({
    required String label,
    String? value,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 18,
              color: AppColors.textLight,
            ),
            const SizedBox(width: 8),
          ],
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value ?? '--',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Seção de detalhe para textos mais longos aprimorada
  Widget _buildDetailSection({
    required String label,
    required String value,
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 18,
                color: AppColors.primaryBlue,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              '$label:',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: AppColors.backgroundGray,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: AppColors.dividerColor,
              width: 1,
            ),
          ),
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textDark,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }
}