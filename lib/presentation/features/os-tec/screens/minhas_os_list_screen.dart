import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:nordeste_servicos_app/data/models/status_os_model.dart';
import '../../../../domain/entities/ordem_servico.dart';
import '../../../shared/styles/app_colors.dart';
import '../../os/screens/os_detail_screen.dart';
import '../providers/minhas_os_list_provider.dart';

class MinhasOsListScreen extends ConsumerWidget {
  const MinhasOsListScreen({Key? key}) : super(key: key);

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
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(minhasOsListProvider);
    final notifier = ref.read(minhasOsListProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      body: Column(
        children: [
          _buildPageHeader(context, notifier),
          Expanded(
            // **CORREÇÃO AQUI: Passando o 'ref' para o método filho**
            child: _buildBodyContent(context, ref, state, notifier),
          ),
        ],
      ),
    );
  }

  Widget _buildPageHeader(BuildContext context, MinhasOsListNotifier notifier) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      color: AppColors.cardBackground,
      child: TextField(
        style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textDark),
        decoration: InputDecoration(
          hintText: 'Buscar por nº da OS ou cliente...',
          prefixIcon: const Icon(Icons.search, color: AppColors.textLight),
          filled: true,
          fillColor: AppColors.backgroundGray,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
        ),
        onSubmitted: (searchTerm) =>
            notifier.loadMinhasOrdensServico(searchTerm: searchTerm, refresh: true),
      ),
    );
  }

  // **CORREÇÃO AQUI: Recebendo o 'WidgetRef ref' como parâmetro**
  Widget _buildBodyContent(BuildContext context, WidgetRef ref, MinhasOsListState state, MinhasOsListNotifier notifier) {
    if (state.isLoading && state.ordensServico.isEmpty) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primaryBlue));
    }
    if (state.errorMessage != null) {
      return Center(child: Text(state.errorMessage!));
    }
    if (state.ordensServico.isEmpty) {
      return const Center(
          child: Text('Nenhuma Ordem de Serviço atribuída a você.'));
    }

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
      onRefresh: () => notifier.loadMinhasOrdensServico(refresh: true),
      color: AppColors.primaryBlue,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: sortedList.length,
        itemBuilder: (context, index) {
          final os = sortedList[index];
          // **CORREÇÃO AQUI: Passando o 'ref' para o método do card**
          return _buildOsCard(context, ref, os, os.status == StatusOSModel.EM_ANDAMENTO);
        },
      ),
    );
  }

  // **CORREÇÃO AQUI: Recebendo o 'WidgetRef ref' como parâmetro**
  Widget _buildOsCard(BuildContext context, WidgetRef ref, OrdemServico os, bool isEmAtendimento) {
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
                    '#${os.numeroOS}',
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