import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:nordeste_servicos_app/data/models/prioridade_os_model.dart';
import 'package:nordeste_servicos_app/data/models/status_os_model.dart';

// Importações locais (ajuste os caminhos conforme sua estrutura de projeto)
import '../../../../domain/entities/ordem_servico.dart';
// Certifique-se de que este provedor seja um FutureProvider.family<OrdemServico, int>
import '../providers/os_detail_provider.dart';
// IMPORTANTE: Adicione o import do osListProvider
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
class OsDetailScreen extends ConsumerWidget { // Alterado de ConsumerStatefulWidget para ConsumerWidget
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

  @override
  Widget build(BuildContext context, WidgetRef ref) { // Removido o 'State' e adicionado 'ref'
    // Observa o provedor de detalhes da OS. Isso automaticamente carrega os dados.
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
            // Invalida o provedor da lista de OS para forçar uma nova requisição na OsListScreen
            // quando ela for exibida novamente.
            ref.invalidate(osListProvider);
            Navigator.of(context).pop();
          },
        ),
        actions: [
          // Botão de Refresh
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              // Invalida o provedor para forçar uma nova requisição
              ref.invalidate(osDetailProvider(osId));
            },
            tooltip: 'Atualizar',
          ),
          // Botão de Editar
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: osAsyncValue.maybeWhen( // Use maybeWhen para acessar o dado se presente
              data: (ordemServico) => () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => OsEditScreen(osId: osId),
                  ),
                );
                // Após retornar da OsEditScreen, invalida o provedor de detalhes
                ref.invalidate(osDetailProvider(osId));
                // E também invalida o provedor da lista para garantir atualização
                ref.invalidate(osListProvider);
              },
              orElse: () => null, // Desabilita o botão se não houver dados (loading/error)
            ),
            tooltip: 'Editar OS',
          ),
        ],
      ),
      body: osAsyncValue.when(
        data: (ordemServico) {
          // Exibe os detalhes da OS
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(osDetailProvider(osId)); // Invalida para recarregar
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
                    _buildDetailRow(label: 'Cliente', value: ordemServico.nomeCliente),
                    _buildDetailRow(label: 'Equipamento', value: ordemServico.descricaoEquipamento),
                    _buildDetailRow(label: 'Técnico Atribuído', value: ordemServico.nomeTecnicoAtribuido ?? 'Não atribuído'),
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
                  err.toString(), // Exibe o erro
                  style: GoogleFonts.poppins(color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => ref.invalidate(osDetailProvider(osId)), // Invalida para tentar novamente
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

  // Card do Cabeçalho
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

  // Card genérico para seções de informação
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

  // Linha de detalhe (Label: Value)
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

  // Seção de detalhe para textos mais longos
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