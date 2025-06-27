import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../domain/entities/peca_material.dart';
import '../../../shared/styles/app_colors.dart';
import '../providers/peca_material_list_provider.dart';
import 'nova_peca_material_screen.dart';
import 'peca_material_detail_screen.dart';

class PecasListScreen extends ConsumerWidget {
  const PecasListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pecaMaterialListProvider);
    final notifier = ref.read(pecaMaterialListProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        title: Text(
          'Peças e Materiais',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
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
      body: Stack(
        children: [
          // Elementos decorativos de fundo
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: AppColors.accentBlue.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.4,
            right: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.successGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Conteúdo principal
          Column(
            children: [
              _buildSearchSection(context, notifier),
              Expanded(
                child: _buildBodyContent(context, state, notifier, ref),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              AppColors.primaryBlue,
              AppColors.secondaryBlue,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const NovaPecaScreen()),
            );
            ref.invalidate(pecaMaterialListProvider);
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _buildSearchSection(BuildContext context, PecaMaterialListNotifier notifier) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Título da seção
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.search,
                    size: 20,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Buscar Peças e Materiais',
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

            // Campo de Busca
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: AppColors.textDark,
                ),
                decoration: InputDecoration(
                  hintText: 'Buscar por código ou descrição...',
                  hintStyle: GoogleFonts.poppins(
                    color: AppColors.textLight.withOpacity(0.7),
                    fontSize: 14,
                  ),
                  prefixIcon: Container(
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.search,
                      size: 20,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  filled: true,
                  fillColor: AppColors.backgroundGray.withOpacity(0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                onSubmitted: (term) => notifier.loadPecas(searchTerm: term, refresh: true),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyContent(BuildContext context, PecaMaterialListState state, PecaMaterialListNotifier notifier, WidgetRef ref) {
    if (state.isLoading && state.pecas.isEmpty) {
      return _buildLoadingState();
    }
    if (state.errorMessage != null && state.pecas.isEmpty) {
      return _buildErrorState(context, state.errorMessage!, () => notifier.loadPecas(refresh: true));
    }
    if (state.pecas.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () => notifier.loadPecas(refresh: true),
      color: AppColors.primaryBlue,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        physics: const BouncingScrollPhysics(),
        itemCount: state.pecas.length,
        itemBuilder: (context, index) {
          final peca = state.pecas[index];
          return _buildPecaCard(context, peca, ref);
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.backgroundGray,
            AppColors.backgroundGray.withOpacity(0.8),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
              strokeWidth: 3,
            ),
            const SizedBox(height: 24),
            Text(
              'Carregando peças e materiais...',
              style: GoogleFonts.poppins(
                color: AppColors.textLight,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPecaCard(BuildContext context, PecaMaterial peca, WidgetRef ref) {
    final formatadorPreco = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final preco = peca.preco != null ? formatadorPreco.format(peca.preco) : 'Não informado';
    final estoque = peca.estoque?.toString() ?? 'N/A';

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => PecaMaterialDetailScreen(pecaId: peca.id!)),
          );
          ref.read(pecaMaterialListProvider.notifier).loadPecas(refresh: true);
        },
        borderRadius: BorderRadius.circular(16.0),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.construction_outlined,
                      size: 24,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          peca.descricao,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Código: ${peca.codigo}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.textLight,
                  ),
                ],
              ),
              const SizedBox(height: 20),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.successGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.successGreen.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.attach_money,
                          size: 16,
                          color: AppColors.successGreen,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          preco,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.successGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundGray,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.inventory_outlined,
                          size: 16,
                          color: AppColors.textLight,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$estoque un.',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w500,
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

  Widget _buildErrorState(BuildContext context, String message, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.errorRed.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_off_rounded,
                color: AppColors.errorRed,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Erro ao Carregar',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: GoogleFonts.poppins(
                color: AppColors.textLight,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryBlue,
                    AppColors.secondaryBlue,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: Text(
                  'Tentar Novamente',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.textLight.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                size: 64,
                color: AppColors.textLight,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Nenhuma peça encontrada',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Cadastre um novo item para começar a gerenciar seu estoque.',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryBlue,
                    AppColors.secondaryBlue,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const NovaPecaScreen()),
                  );
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: Text(
                  'Adicionar Peça/Material',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

