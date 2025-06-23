import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../domain/entities/equipamento.dart';
import '../../../shared/styles/app_colors.dart';
import '../../gestao/screens/gestao_screen.dart';
import '../providers/equipamento_list_provider.dart';
import 'equipamento_detail_screen.dart'; // Placeholder
import 'novo_equipamento_screen.dart';   // Placeholder

class EquipamentoListScreen extends ConsumerWidget {
  const EquipamentoListScreen({Key? key}) : super(key: key);

  void _exportToExcel(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exportar para Excel em desenvolvimento.')),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(equipamentoListProvider);
    final notifier = ref.read(equipamentoListProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        title: Text('Equipamentos', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.textDark)),
        backgroundColor: AppColors.cardBackground,
        foregroundColor: AppColors.textDark,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        actions: [
          IconButton(
            icon: const Icon(Icons.grid_on_outlined),
            onPressed: () => _exportToExcel(context),
            tooltip: 'Exportar para Excel',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildFilterAndSearchSection(context, notifier),
          Expanded(
            child: _buildBodyContent(context, state, notifier),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const NovoEquipamentoScreen()),
          );
        },
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterAndSearchSection(BuildContext context, EquipamentoListNotifier notifier) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      color: AppColors.cardBackground,
      child: Column(
        children: [
          TextField(
            style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textDark),
            decoration: InputDecoration(
              hintText: 'Buscar por tipo, marca, modelo ou série...',
              hintStyle: GoogleFonts.poppins(color: AppColors.textLight),
              prefixIcon: const Icon(Icons.search, color: AppColors.textLight),
              filled: true,
              fillColor: AppColors.backgroundGray,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            onSubmitted: (searchTerm) => notifier.loadEquipamentos(searchTerm: searchTerm, refresh: true),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: [
                _buildFilterChip('Filtros', icon: Icons.filter_list, isPrimary: true, onPressed: () {}),
                const SizedBox(width: 8),
                _buildFilterChip('Tipo', onPressed: () {}),
                const SizedBox(width: 8),
                _buildFilterChip('Cliente', onPressed: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyContent(BuildContext context, EquipamentoListState state, EquipamentoListNotifier notifier) {
    if (state.isLoading && state.equipamentos.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue));
    }
    if (state.errorMessage != null && state.equipamentos.isEmpty) {
      return Center(child: Text(state.errorMessage!)); // Adapte para seu widget de erro
    }
    if (state.equipamentos.isEmpty) {
      return const Center(child: Text('Nenhum equipamento encontrado.')); // Adapte para seu widget de estado vazio
    }

    return RefreshIndicator(
      onRefresh: () => notifier.loadEquipamentos(refresh: true),
      color: AppColors.primaryBlue,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: state.equipamentos.length,
        itemBuilder: (context, index) {
          final equipamento = state.equipamentos[index];
          return _buildEquipamentoCard(context, equipamento);
        },
      ),
    );
  }

  Widget _buildEquipamentoCard(BuildContext context, Equipamento equipamento) {
    return Card(
      elevation: 2,
      shadowColor: AppColors.primaryBlue.withOpacity(0.08),
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => EquipamentoDetailScreen(equipamentoId: equipamento.id!)),
          );
        },
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      equipamento.marcaModelo, // Exibe a marca/modelo do equipamento
                      style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textDark),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.build_circle_outlined, color: AppColors.primaryBlue.withOpacity(0.7)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Série/Chassi: ${equipamento.numeroSerieChassi}', // Exibe o número de série
                style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textLight),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              const Divider(color: AppColors.dividerColor, height: 1),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Chip(
                    label: Text(equipamento.tipo, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.primaryBlue)), // Exibe o tipo do equipamento
                    backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  if (equipamento.horimetro != null)
                    Row(
                      children: [
                        const Icon(Icons.timer_outlined, size: 16, color: AppColors.textLight),
                        const SizedBox(width: 4),
                        Text(
                          '${equipamento.horimetro} h',
                          style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textLight, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, {required VoidCallback onPressed, IconData? icon, bool isPrimary = false}) {
    return ActionChip(
      onPressed: onPressed,
      backgroundColor: isPrimary ? AppColors.primaryBlue : AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
        side: BorderSide(color: isPrimary ? Colors.transparent : AppColors.dividerColor, width: 1.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      label: Row(
        children: [
          if (icon != null) Icon(icon, size: 18, color: isPrimary ? Colors.white : AppColors.primaryBlue),
          if (icon != null) const SizedBox(width: 6),
          Text(label, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: isPrimary ? Colors.white : AppColors.textDark)),
        ],
      ),
    );
  }
}