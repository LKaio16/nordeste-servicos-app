import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:nordeste_servicos_app/data/models/prioridade_os_model.dart';
import 'package:nordeste_servicos_app/data/models/status_os_model.dart';

// Importações locais (ajuste os caminhos conforme sua estrutura de projeto)
import '../../../../domain/entities/ordem_servico.dart';
import '../../../shared/providers/repository_providers.dart';
import '../providers/os_detail_provider.dart';
import '../providers/os_list_provider.dart';

import 'os_edit_screen.dart';

// Cores (pode centralizar em um arquivo de temas/cores)
class AppColors {
  static const Color primaryBlue = Color(0xFF1A73E8);
  static const Color textDark = Color(0xFF202124);
  static const Color textLight = Color(0xFF5F6368);
  static const Color backgroundGray = Color(0xFFF8F9FA);
  static const Color dividerColor = Color(0xFFEEEEEE);

  // Cores de status (reutilizadas da OsListScreen)
  static Color getStatusBackgroundColor(StatusOSModel status) {
    switch (status) {
      case StatusOSModel.CONCLUIDA:
      case StatusOSModel.ENCERRADA:
        return Colors.green.shade100;
      case StatusOSModel.EM_ANDAMENTO:
        return Colors.orange.shade100;
      case StatusOSModel.EM_ABERTO:
      case StatusOSModel.PENDENTE_PECAS:
        return Colors.blue.shade100;
      case StatusOSModel.CANCELADA:
        return Colors.red.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  static Color getStatusTextColor(StatusOSModel status) {
    switch (status) {
      case StatusOSModel.CONCLUIDA:
      case StatusOSModel.ENCERRADA:
        return Colors.green.shade800;
      case StatusOSModel.EM_ANDAMENTO:
        return Colors.orange.shade800;
      case StatusOSModel.EM_ABERTO:
      case StatusOSModel.PENDENTE_PECAS:
        return Colors.blue.shade800;
      case StatusOSModel.CANCELADA:
        return Colors.red.shade800;
      default:
        return Colors.grey.shade700;
    }
  }

  // Cores de prioridade
  static Color getPrioridadeColor(PrioridadeOSModel? prioridade) {
    switch (prioridade) {
      case PrioridadeOSModel.URGENTE:
        return Colors.red.shade700;
      case PrioridadeOSModel.ALTA:
        return Colors.orange.shade700;
      case PrioridadeOSModel.MEDIA:
        return Colors.blue.shade700;
      case PrioridadeOSModel.BAIXA:
        return Colors.green.shade700;
      default:
        return AppColors.textLight;
    }
  }
}

// Tela de Visualização de OS - Agora um ConsumerWidget (stateless)
class OsDetailScreen extends ConsumerWidget {
  final int osId;

  const OsDetailScreen({required this.osId, Key? key}) : super(key: key);

  // Função auxiliar para formatar data e hora
  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '--/--/---- --:--';
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  // Função auxiliar para texto de status
  String _getStatusText(StatusOSModel status) {
    switch (status) {
      case StatusOSModel.CONCLUIDA:
        return 'Concluída';
      case StatusOSModel.EM_ANDAMENTO:
        return 'Em Andamento';
      case StatusOSModel.EM_ABERTO:
        return 'Em Aberto';
      case StatusOSModel.ENCERRADA:
        return 'Encerrada';
      case StatusOSModel.CANCELADA:
        return 'Cancelada';
      case StatusOSModel.PENDENTE_PECAS:
        return 'Pendente';
      default:
        return 'Desconhecido';
    }
  }

  // Função auxiliar para texto de prioridade
  String _getPrioridadeText(PrioridadeOSModel? prioridade) {
    if (prioridade == null) return 'Não definida';
    switch (prioridade) {
      case PrioridadeOSModel.BAIXA:
        return 'Baixa';
      case PrioridadeOSModel.MEDIA:
        return 'Média';
      case PrioridadeOSModel.ALTA:
        return 'Alta';
      case PrioridadeOSModel.URGENTE:
        return 'Urgente';
      default:
        return 'Desconhecida';
    }
  }

  // >>> NOVO MÉTODO PARA EXCLUIR OS
  Future<void> _deleteOs(BuildContext context, WidgetRef ref) async {
    // 1. Confirmação
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: Text('Tem certeza de que deseja excluir a Ordem de Serviço #${osId}? Esta ação é irreversível.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false), // Não confirmar
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true), // Confirmar
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Excluir', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      // 2. Chamar o repositório
      try {
        final osRepository = ref.read(osRepositoryProvider);
        await osRepository.deleteOrdemServico(osId);

        // 3. Sucesso: Mostrar SnackBar e navegar de volta
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ordem de Serviço #${osId} excluída com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          // Invalida a lista de OS para que seja recarregada ao voltar para a tela anterior
          ref.invalidate(osListProvider);
          Navigator.of(context).pop(); // Volta para a tela anterior (lista de OS)
        }
      } catch (e) {
        // 4. Erro: Mostrar SnackBar
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir Ordem de Serviço: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final osAsyncValue = ref.watch(osDetailProvider(osId));

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        title: Text(
          osAsyncValue.when(
            data: (ordemServico) => 'OS #${ordemServico.numeroOS}',
            loading: () => 'Carregando...',
            error: (err, stack) => 'Detalhes da OS',
          ),
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primaryBlue,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            ref.invalidate(osListProvider);
            Navigator.of(context).pop();
          },
        ),
        actions: [
          // Botão de Refresh
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              ref.invalidate(osDetailProvider(osId));
            },
            tooltip: 'Atualizar',
          ),
          // Botão de Editar
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: osAsyncValue.maybeWhen(
              data: (ordemServico) => () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => OsEditScreen(osId: osId),
                  ),
                );
                ref.invalidate(osDetailProvider(osId));
                ref.invalidate(osListProvider);
              },
              orElse: () => null,
            ),
            tooltip: 'Editar OS',
          ),
          // >>> NOVO BOTÃO DE DELETAR
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.red), // Ícone de lixeira, cor vermelha
            onPressed: osAsyncValue.maybeWhen(
              data: (ordemServico) => () => _deleteOs(context, ref), // Chama a função de exclusão
              orElse: () => null, // Desabilita se não houver dados
            ),
            tooltip: 'Excluir OS',
          ),
        ],
      ),
      body: osAsyncValue.when(
        data: (ordemServico) {
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(osDetailProvider(osId));
            },
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildHeaderCard(ordemServico),
                const SizedBox(height: 16),
                _buildInfoCard(
                  title: 'Informações Gerais',
                  icon: Icons.info_outline,
                  children: [
                    _buildDetailRow(label: 'Cliente', value: ordemServico.cliente.nomeCompleto),
                    _buildDetailRow(label: 'Equipamento', value: ordemServico.equipamento.marcaModelo + " - " + ordemServico.equipamento.numeroSerieChassi),
                    _buildDetailRow(label: 'Técnico Atribuído', value: ordemServico.tecnicoAtribuido?.nome ?? 'Não atribuído'),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInfoCard(
                  title: 'Datas e Prazos',
                  icon: Icons.calendar_today_outlined,
                  children: [
                    _buildDetailRow(label: 'Abertura', value: _formatDateTime(ordemServico.dataAbertura)),
                    _buildDetailRow(label: 'Agendamento', value: _formatDateTime(ordemServico.dataAgendamento)),
                    _buildDetailRow(label: 'Fechamento', value: _formatDateTime(ordemServico.dataFechamento)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInfoCard(
                  title: 'Problema Relatado',
                  icon: Icons.report_problem_outlined,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        ordemServico.problemaRelatado ?? 'Nenhuma descrição fornecida.',
                        style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textDark, height: 1.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (ordemServico.analiseFalha != null || ordemServico.solucaoAplicada != null)
                  _buildInfoCard(
                    title: 'Diagnóstico e Solução',
                    icon: Icons.build_circle_outlined,
                    children: [
                      if (ordemServico.analiseFalha != null)
                        _buildDetailSection(label: 'Análise da Falha', value: ordemServico.analiseFalha!),
                      if (ordemServico.analiseFalha != null && ordemServico.solucaoAplicada != null)
                        const SizedBox(height: 12),
                      if (ordemServico.solucaoAplicada != null)
                        _buildDetailSection(label: 'Solução Aplicada', value: ordemServico.solucaoAplicada!),
                    ],
                  ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade400, size: 50),
                const SizedBox(height: 16),
                Text(
                  'Erro ao carregar Detalhes',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  err.toString(),
                  style: GoogleFonts.poppins(color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => ref.invalidate(osDetailProvider(osId)),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tentar Novamente'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Card do Cabeçalho (mantido)
  Widget _buildHeaderCard(OrdemServico os) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'OS #${os.numeroOS}',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
                Chip(
                  label: Text(
                    _getStatusText(os.status),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.getStatusTextColor(os.status),
                    ),
                  ),
                  backgroundColor:
                  AppColors.getStatusBackgroundColor(os.status),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.priority_high,
                    size: 18,
                    color: AppColors.getPrioridadeColor(os.prioridade)),
                const SizedBox(width: 8),
                Text(
                  'Prioridade:',
                  style: GoogleFonts.poppins(
                      fontSize: 14, color: AppColors.textLight),
                ),
                const SizedBox(width: 4),
                Text(
                  _getPrioridadeText(os.prioridade),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.getPrioridadeColor(os.prioridade),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Card genérico para seções de informação (mantido)
  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: AppColors.primaryBlue),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
            const Divider(
                height: 20, thickness: 1, color: AppColors.dividerColor),
            ...children,
          ],
        ),
      ),
    );
  }

  // Linha de detalhe (Label: Value) (mantido)
  Widget _buildDetailRow({required String label, String? value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130, // Largura fixa para o label
            child: Text(
              '$label:',
              style:
              GoogleFonts.poppins(fontSize: 14, color: AppColors.textLight),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value ?? '--',
              style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark),
            ),
          ),
        ],
      ),
    );
  }

  // Seção de detalhe para textos mais longos (mantido)
  Widget _buildDetailSection({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label:',
          style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textLight,
              fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.poppins(
              fontSize: 14, color: AppColors.textDark, height: 1.5),
        ),
      ],
    );
  }
}