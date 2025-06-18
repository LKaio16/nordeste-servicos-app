// lib/features/os/presentation/screens/os_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:nordeste_servicos_app/data/models/status_os_model.dart';

// Importações locais
import '../../../../domain/entities/ordem_servico.dart';
import '../../../shared/styles/app_colors.dart';
import '../providers/os_list_provider.dart';
import 'os_detail_screen.dart';

class OsListScreen extends ConsumerWidget {
  const OsListScreen({Key? key}) : super(key: key);

  // --- Funções Auxiliares de Estilo (Helpers) ---

  Color _getStatusBackgroundColor(StatusOSModel status) {
    switch (status) {
      case StatusOSModel.CONCLUIDA:
      case StatusOSModel.ENCERRADA:
        return AppColors.successGreen.withOpacity(0.1);
      case StatusOSModel.EM_ANDAMENTO:
        return AppColors.warningOrange.withOpacity(0.1);
      case StatusOSModel.EM_ABERTO:
      case StatusOSModel.PENDENTE_PECAS:
        return AppColors.primaryBlue.withOpacity(0.1);
      case StatusOSModel.CANCELADA:
        return AppColors.errorRed.withOpacity(0.1);
      default:
        return Colors.grey.shade200;
    }
  }

  Color _getStatusTextColor(StatusOSModel status) {
    switch (status) {
      case StatusOSModel.CONCLUIDA:
      case StatusOSModel.ENCERRADA:
        return AppColors.successGreen;
      case StatusOSModel.EM_ANDAMENTO:
        return AppColors.warningOrange;
      case StatusOSModel.EM_ABERTO:
      case StatusOSModel.PENDENTE_PECAS:
        return AppColors.primaryBlue;
      case StatusOSModel.CANCELADA:
        return AppColors.errorRed;
      default:
        return AppColors.textLight;
    }
  }

  String _getStatusText(StatusOSModel status) {
    switch (status) {
      case StatusOSModel.CONCLUIDA: return 'Concluída';
      case StatusOSModel.EM_ANDAMENTO: return 'Em Andamento';
      case StatusOSModel.EM_ABERTO: return 'Em Aberto';
      case StatusOSModel.ENCERRADA: return 'Encerrada';
      case StatusOSModel.CANCELADA: return 'Cancelada';
      case StatusOSModel.PENDENTE_PECAS: return 'Pendente';
      default: return 'Desconhecido';
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '--/--/----';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(osListProvider);
    final notifier = ref.read(osListProvider.notifier);

    return Scaffold(
      // A AppBar foi removida para dar lugar a um cabeçalho customizado no body
      backgroundColor: AppColors.backgroundGray,
      body: Column(
        children: [
          // NOVO: Cabeçalho da página com busca e filtros
          _buildPageHeader(context, notifier),

          // Conteúdo Principal
          Expanded(
            child: _buildBodyContent(context, state, notifier),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/nova-os');
        },
        backgroundColor: AppColors.primaryBlue,
        shape: const CircleBorder(),
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // NOVO: Widget para o cabeçalho da página
  Widget _buildPageHeader(BuildContext context, OsListNotifier notifier) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título da Página
          Text(
            'Ordens de Serviço',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          // Campo de Busca
          TextField(
            style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textDark),
            decoration: InputDecoration(
              hintText: 'Buscar OS, cliente ou técnico...',
              hintStyle: GoogleFonts.poppins(color: AppColors.textLight),
              prefixIcon: const Icon(Icons.search, color: AppColors.textLight),
              filled: true,
              fillColor: AppColors.backgroundGray,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
            ),
            onSubmitted: (searchTerm) {
              notifier.loadOrdensServico(searchTerm: searchTerm, refresh: true);
            },
          ),
          const SizedBox(height: 12),
          // Seção de Filtros com novo design
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: [
                _buildFilterChip(
                  'Filtros',
                  icon: Icons.filter_list,
                  isPrimary: true,
                  onPressed: () { /* TODO: Abrir filtros avançados */ },
                ),
                const SizedBox(width: 8),
                _buildFilterChip('Status', onPressed: () {}),
                const SizedBox(width: 8),
                _buildFilterChip('Data', onPressed: () {}),
                const SizedBox(width: 8),
                _buildFilterChip('Técnico', onPressed: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Conteúdo principal baseado no estado
  Widget _buildBodyContent(BuildContext context, OsListState state, OsListNotifier notifier) {
    if (state.isLoading && state.ordensServico.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue));
    }

    if (state.errorMessage != null && state.ordensServico.isEmpty) {
      return _buildErrorState(state.errorMessage!, () => notifier.loadOrdensServico(refresh: true));
    }

    if (state.ordensServico.isEmpty) {
      return _buildEmptyState();
    }

    // Lista com RefreshIndicator
    return RefreshIndicator(
      onRefresh: () => notifier.loadOrdensServico(refresh: true),
      color: AppColors.primaryBlue,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        physics: const BouncingScrollPhysics(),
        itemCount: state.ordensServico.length,
        itemBuilder: (context, index) {
          final os = state.ordensServico[index];
          return _buildOsCard(context, os);
        },
      ),
    );
  }

  // Chip de filtro com novo design
  Widget _buildFilterChip(String label, {required VoidCallback onPressed, IconData? icon, bool isPrimary = false}) {
    return ActionChip(
      onPressed: onPressed,
      backgroundColor: isPrimary ? AppColors.primaryBlue : AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
        side: BorderSide(color: isPrimary ? Colors.transparent : AppColors.dividerColor, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      label: Row(
        children: [
          if (icon != null)
            Icon(icon, size: 18, color: isPrimary ? Colors.white : AppColors.primaryBlue),
          if (icon != null) const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isPrimary ? Colors.white : AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  // Card da OS com o novo design inspirado no dashboard
  Widget _buildOsCard(BuildContext context, OrdemServico os) {
    return Card(
      elevation: 3,
      shadowColor: AppColors.primaryBlue.withOpacity(0.1),
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => OsDetailScreen(osId: os.id!)),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '#${os.numeroOS}',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          os.cliente.nomeCompleto,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: AppColors.textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Chip(
                    label: Text(
                      _getStatusText(os.status),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getStatusTextColor(os.status),
                      ),
                    ),
                    backgroundColor: _getStatusBackgroundColor(os.status),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                os.problemaRelatado.toString(),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textLight,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              const Divider(color: AppColors.dividerColor, height: 1),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCardInfoItem(
                    icon: Icons.person_outline,
                    text: os.tecnicoAtribuido?.nome ?? 'Não atribuído',
                  ),
                  _buildCardInfoItem(
                    icon: Icons.calendar_today_outlined,
                    text: _formatDate(os.dataAgendamento ?? os.dataAbertura),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget auxiliar para os ícones de informação no card
  Widget _buildCardInfoItem({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textLight),
        const SizedBox(width: 6),
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: AppColors.textLight,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Widget para o estado de erro
  Widget _buildErrorState(String message, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_rounded, color: AppColors.errorRed.withOpacity(0.7), size: 60),
            const SizedBox(height: 20),
            Text(
              'Erro ao Carregar',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: GoogleFonts.poppins(color: AppColors.textLight, fontSize: 14),
              textAlign: TextAlign.center,
            ),
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

  // Widget para o estado de lista vazia
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.list_alt_outlined, size: 60, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Nenhuma OS encontrada',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
          const SizedBox(height: 8),
          Text(
            'Crie uma nova Ordem de Serviço ou ajuste os filtros.',
            style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textLight),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}