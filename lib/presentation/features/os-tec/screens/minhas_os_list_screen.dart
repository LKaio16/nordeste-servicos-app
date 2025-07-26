import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:nordeste_servicos_app/data/models/status_os_model.dart';
import '../../../../domain/entities/ordem_servico.dart';
import '../../../shared/styles/app_colors.dart';
import '../../os/screens/os_detail_screen.dart';
import '../providers/minhas_os_list_provider.dart';

class MinhasOsListScreen extends ConsumerStatefulWidget {
  const MinhasOsListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MinhasOsListScreen> createState() => _MinhasOsListScreenState();
}

class _MinhasOsListScreenState extends ConsumerState<MinhasOsListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentSearchTerm = ref.read(minhasOsListProvider).searchTerm;
      _searchController.text = currentSearchTerm;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getStatusBackgroundColor(StatusOSModel status) {
    switch (status) {
      case StatusOSModel.CONCLUIDA:
        return AppColors.successGreen.withOpacity(0.1);
      case StatusOSModel.EM_ANDAMENTO:
        return AppColors.warningOrange.withOpacity(0.1);
      default:
        return AppColors.primaryBlue.withOpacity(0.1);
    }
  }

  Color _getStatusTextColor(StatusOSModel status) {
    switch (status) {
      case StatusOSModel.CONCLUIDA:
        return AppColors.successGreen;
      case StatusOSModel.EM_ANDAMENTO:
        return AppColors.warningOrange;
      default:
        return AppColors.primaryBlue;
    }
  }

  String _getStatusText(StatusOSModel status) {
    if (status == StatusOSModel.EM_ANDAMENTO) {
      return 'EM ATENDIMENTO';
    }
    return status.name.replaceAll('_', ' ');
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '--/--/----';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(minhasOsListProvider);
    final notifier = ref.read(minhasOsListProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      body: Column(
        children: [
          _buildPageHeader(context, notifier, state.searchTerm),
          Expanded(
            child: _buildBodyContent(context, state, notifier),
          ),
        ],
      ),
    );
  }

  Widget _buildPageHeader(BuildContext context, MinhasOsListNotifier notifier, String currentSearchTerm) {
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
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textDark),
              decoration: InputDecoration(
                hintText: 'Buscar por nº da OS ou cliente...',
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
              onChanged: notifier.updateSearchTerm,
              onSubmitted: notifier.searchOrdensServico,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () => notifier.searchOrdensServico(_searchController.text),
              icon: const Icon(Icons.search, color: Colors.white),
              tooltip: 'Pesquisar',
            ),
          ),
          if (currentSearchTerm.isNotEmpty) ...[
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.textLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: () {
                  _searchController.clear();
                  notifier.clearSearch();
                },
                icon: const Icon(Icons.clear, color: Colors.white),
                tooltip: 'Limpar pesquisa',
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildBodyContent(BuildContext context, MinhasOsListState state, MinhasOsListNotifier notifier) {
    if (state.isLoading && state.ordensServico.isEmpty) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primaryBlue));
    }
    if (state.errorMessage != null) {
      return Center(child: Text(state.errorMessage!)); // TODO: Melhorar tela de erro
    }
    if (state.ordensServico.isEmpty) {
      return _buildEmptyState(state.searchTerm.isNotEmpty, notifier);
    }
    
    // Mostra indicador de loading se estiver buscando
    if (state.isLoading && state.ordensServico.isNotEmpty) {
      return Stack(
        children: [
          _buildOsList(state, notifier),
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return _buildOsList(state, notifier);
  }

  Widget _buildOsList(MinhasOsListState state, MinhasOsListNotifier notifier) {
    // A ordenação agora é feita na UI para garantir que OS em atendimento fiquem no topo
    final sortedList = List<OrdemServico>.from(state.ordensServico)
      ..sort((a, b) {
        if (a.status == StatusOSModel.EM_ANDAMENTO && b.status != StatusOSModel.EM_ANDAMENTO) {
          return -1;
        }
        if (a.status != StatusOSModel.EM_ANDAMENTO && b.status == StatusOSModel.EM_ANDAMENTO) {
          return 1;
        }
        return 0;
      });

    return RefreshIndicator(
      onRefresh: () => notifier.refreshOrdensServico(),
      color: AppColors.primaryBlue,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: sortedList.length,
        itemBuilder: (context, index) {
          final os = sortedList[index];
          return _buildOsCard(context, os, os.status == StatusOSModel.EM_ANDAMENTO);
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isSearching, MinhasOsListNotifier notifier) {
    final state = ref.watch(minhasOsListProvider);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
              isSearching ? Icons.search_off : Icons.list_alt_outlined,
              size: 60,
              color: Colors.grey.shade400
          ),
          const SizedBox(height: 16),
          Text(
            isSearching ? 'Nenhum resultado encontrado' : 'Nenhuma OS atribuída',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
          const SizedBox(height: 8),
          Text(
            isSearching
                ? 'Nenhuma OS encontrada para "${state.searchTerm}".\nTente ajustar os termos da sua busca.'
                : 'Quando novas OS forem atribuídas a você, elas aparecerão aqui.',
            style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textLight),
            textAlign: TextAlign.center,
          ),
          if (isSearching) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                _searchController.clear();
                notifier.clearSearch();
              },
              icon: const Icon(Icons.clear),
              label: const Text('Limpar Pesquisa'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOsCard(BuildContext context, OrdemServico os, bool isEmAtendimento) {
    final cardBorder = isEmAtendimento
        ? RoundedRectangleBorder(
      side: BorderSide(color: AppColors.warningOrange, width: 2),
      borderRadius: BorderRadius.circular(12.0),
    )
        : RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0));

    final cardShadowColor = isEmAtendimento
        ? AppColors.warningOrange.withOpacity(0.3)
        : AppColors.primaryBlue.withOpacity(0.1);

    return Card(
      elevation: isEmAtendimento ? 5 : 3,
      shadowColor: cardShadowColor,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: cardBorder,
      child: InkWell(
        onTap: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => OsDetailScreen(osId: os.id!)),
          );
          ref.invalidate(minhasOsListProvider);
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
                  Text(
                    '#OS-${os.id}',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppColors.primaryBlue),
                  ),
                  Chip(
                    label: Text(_getStatusText(os.status),
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getStatusTextColor(os.status))),
                    backgroundColor: _getStatusBackgroundColor(os.status),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                os.cliente.nomeCompleto,
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: AppColors.textDark),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                os.problemaRelatado ?? 'Sem descrição do problema.',
                style:
                GoogleFonts.poppins(fontSize: 14, color: AppColors.textLight),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Divider(height: 32),
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 16, color: AppColors.textLight),
                  const SizedBox(width: 6),
                  Text(
                    'Agendado para: ${_formatDate(os.dataAgendamento ?? os.dataAbertura)}',
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.textLight,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}