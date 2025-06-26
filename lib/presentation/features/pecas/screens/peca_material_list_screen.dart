import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../domain/entities/peca_material.dart';
import '../../../shared/styles/app_colors.dart';
import '../providers/peca_material_list_provider.dart';
import 'nova_peca_material_screen.dart'; // Placeholder
import 'peca_material_detail_screen.dart'; // Placeholder

class PecasListScreen extends ConsumerWidget {
  const PecasListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pecaMaterialListProvider);
    final notifier = ref.read(pecaMaterialListProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        title: Text('Peças e Materiais', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.textDark)),
        backgroundColor: AppColors.cardBackground,
        foregroundColor: AppColors.textDark,
        elevation: 2,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            color: AppColors.cardBackground,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por código ou descrição...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                filled: true,
                fillColor: AppColors.backgroundGray,
              ),
              onSubmitted: (term) => notifier.loadPecas(searchTerm: term, refresh: true),
            ),
          ),
          Expanded(
            child: _buildBodyContent(state, notifier),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const NovaPecaScreen()),
          );
        },
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBodyContent(PecaMaterialListState state, PecaMaterialListNotifier notifier) {
    if (state.isLoading && state.pecas.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.errorMessage != null && state.pecas.isEmpty) {
      return Center(child: Text(state.errorMessage!));
    }
    if (state.pecas.isEmpty) {
      return const Center(child: Text('Nenhuma peça ou material encontrado.'));
    }

    return RefreshIndicator(
      onRefresh: () => notifier.loadPecas(refresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: state.pecas.length,
        itemBuilder: (context, index) {
          final peca = state.pecas[index];
          return _buildPecaCard(context, peca);
        },
      ),
    );
  }

  Widget _buildPecaCard(BuildContext context, PecaMaterial peca) {
    final formatadorPreco = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final preco = peca.preco != null ? formatadorPreco.format(peca.preco) : 'Não informado';
    final estoque = peca.estoque?.toString() ?? 'N/A';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => PecaMaterialDetailScreen(pecaId: peca.id!)),
          );
        },
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.construction_outlined, color: AppColors.primaryBlue, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      peca.descricao,
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text('Código: ${peca.codigo}', style: GoogleFonts.poppins(color: AppColors.textLight)),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Preço: $preco', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                  Text('Estoque: $estoque un.', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}