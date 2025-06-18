import 'dart:typed_data';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:nordeste_servicos_app/data/models/prioridade_os_model.dart';
import 'package:nordeste_servicos_app/data/models/status_os_model.dart';
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../domain/entities/ordem_servico.dart';
import '../../../shared/providers/repository_providers.dart';
import '../../../shared/styles/app_colors.dart';
import '../providers/os_detail_provider.dart';
import '../providers/os_list_provider.dart';
import 'os_edit_screen.dart';

class OsDetailScreen extends ConsumerWidget {
  final int osId;

  const OsDetailScreen({required this.osId, Key? key}) : super(key: key);

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '--/--/---- --:--';
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  String _getStatusText(StatusOSModel status) {
    return status.name;
  }

  String _getPrioridadeText(PrioridadeOSModel? prioridade) {
    return prioridade?.name ?? 'Não definida';
  }

  Future<void> _deleteOs(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Confirmar Exclusão',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Tem certeza que deseja excluir esta OS? Esta ação não pode ser desfeita.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancelar',
              style: GoogleFonts.poppins(color: AppColors.textLight),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              'Excluir',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final osRepository = ref.read(osRepositoryProvider);
        await osRepository.deleteOrdemServico(osId);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('OS excluída com sucesso!'),
              backgroundColor: AppColors.successGreen,
            ),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir OS: ${e.toString()}'),
              backgroundColor: AppColors.errorRed,
            ),
          );
        }
      }
    }
  }

  Future<void> _downloadPdf(BuildContext context, WidgetRef ref, OrdemServico os) async {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Baixando PDF da OS #${os.numeroOS}...'),
          backgroundColor: AppColors.primaryBlue,
          duration: const Duration(seconds: 3),
        ),
      );
    }

    try {
      final osRepository = ref.read(osRepositoryProvider);
      final Uint8List pdfBytes = await osRepository.downloadOsPdf(os.id!);

      final String fileName = 'relatorio_os_${os.numeroOS}.pdf';
      String? filePath;

      if (!kIsWeb) {
        // Tenta salvar o arquivo diretamente usando FileSaver
        filePath = await FileSaver.instance.saveFile(
          name: fileName,
          bytes: pdfBytes,
          ext: 'pdf',
          mimeType: MimeType.pdf,
        );

        // Se filePath for nulo, indica que houve um problema ao salvar
        // mas em Android 10+, não necessariamente por falta de permissão explícita.
        // Aqui você pode adicionar um log ou uma mensagem de erro mais específica.
        if (filePath == null) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erro: Não foi possível salvar o arquivo PDF. Verifique as permissões do aplicativo nas configurações do sistema ou tente novamente.'),
                backgroundColor: AppColors.errorRed,
              ),
            );
          }
          return; // Sai da função se não conseguiu salvar
        }
      } else {
        // Web platform (handled by FileSaver for browser download)
        filePath = await FileSaver.instance.saveFile(
          name: fileName,
          bytes: pdfBytes,
          ext: 'pdf',
          mimeType: MimeType.pdf,
        );
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download concluído! Arquivo salvo em: ${filePath ?? 'local desconhecido'}'),
            backgroundColor: AppColors.successGreen,
            action: (!kIsWeb && filePath != null && filePath.isNotEmpty)
                ? SnackBarAction(
              label: 'ABRIR',
              textColor: Colors.white,
              onPressed: () {
                OpenFilex.open(filePath!);
              },
            )
                : null,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao baixar PDF: ${e.toString()}'),
            backgroundColor: AppColors.errorRed,
          ),
        );
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
        elevation: 0,
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            ref.invalidate(osListProvider);
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => ref.invalidate(osDetailProvider(osId)),
            tooltip: 'Atualizar',
          ),
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
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
            onPressed: osAsyncValue.maybeWhen(
              data: (ordemServico) => () => _downloadPdf(context, ref, ordemServico),
              orElse: () => null,
            ),
            tooltip: 'Baixar Relatório PDF',
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.white),
            onPressed: osAsyncValue.maybeWhen(
              data: (ordemServico) => () => _deleteOs(context, ref),
              orElse: () => null,
            ),
            tooltip: 'Excluir OS',
          ),
        ],
      ),
      body: osAsyncValue.when(
        data: (ordemServico) {
          return Stack(
            children: [
              // Elementos decorativos de fundo - inspirados no admin home screen
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
                top: MediaQuery.of(context).size.height * 0.3,
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
              RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(osDetailProvider(osId));
                },
                color: AppColors.primaryBlue,
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    _buildHeaderCard(ordemServico),
                    const SizedBox(height: 20),
                    _buildInfoCard(
                      title: 'Informações Gerais',
                      icon: Icons.info_outline,
                      children: [
                        _buildDetailRow(
                          label: 'Cliente',
                          value: ordemServico.cliente.nomeCompleto,
                          icon: Icons.person_outline,
                        ),
                        _buildDetailRow(
                          label: 'Equipamento',
                          value: "${ordemServico.equipamento.marcaModelo} - ${ordemServico.equipamento.numeroSerieChassi}",
                          icon: Icons.build_outlined,
                        ),
                        _buildDetailRow(
                          label: 'Técnico Atribuído',
                          value: ordemServico.tecnicoAtribuido?.nome ?? 'Não atribuído',
                          icon: Icons.engineering_outlined,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildInfoCard(
                      title: 'Datas e Prazos',
                      icon: Icons.calendar_today_outlined,
                      children: [
                        _buildDetailRow(
                          label: 'Abertura',
                          value: _formatDateTime(ordemServico.dataAbertura),
                          icon: Icons.schedule_outlined,
                        ),
                        _buildDetailRow(
                          label: 'Agendamento',
                          value: _formatDateTime(ordemServico.dataAgendamento),
                          icon: Icons.event_outlined,
                        ),
                        _buildDetailRow(
                          label: 'Fechamento',
                          value: _formatDateTime(ordemServico.dataFechamento),
                          icon: Icons.check_circle_outline,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildInfoCard(
                      title: 'Problema Relatado',
                      icon: Icons.report_problem_outlined,
                      children: [
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
                            ordemServico.problemaRelatado ?? 'Nenhuma descrição fornecida.',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppColors.textDark,
                              height: 1.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (ordemServico.analiseFalha != null || ordemServico.solucaoAplicada != null)
                      _buildInfoCard(
                        title: 'Diagnóstico e Solução',
                        icon: Icons.build_circle_outlined,
                        children: [
                          if (ordemServico.analiseFalha != null)
                            _buildDetailSection(
                              label: 'Análise da Falha',
                              value: ordemServico.analiseFalha!,
                              icon: Icons.search_outlined,
                            ),
                          if (ordemServico.analiseFalha != null && ordemServico.solucaoAplicada != null)
                            const SizedBox(height: 16),
                          if (ordemServico.solucaoAplicada != null)
                            _buildDetailSection(
                              label: 'Solução Aplicada',
                              value: ordemServico.solucaoAplicada!,
                              icon: Icons.check_circle_outlined,
                            ),
                        ],
                      ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => Container(
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
                ),
                const SizedBox(height: 16),
                Text(
                  'Carregando detalhes da OS...',
                  style: GoogleFonts.poppins(
                    color: AppColors.textLight,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.errorRed,
              ),
              const SizedBox(height: 16),
              Text(
                'Erro ao carregar OS',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                err.toString(),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textLight,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => ref.invalidate(osDetailProvider(osId)),
                icon: const Icon(Icons.refresh),
                label: Text('Tentar Novamente'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Card do Cabeçalho aprimorado
  Widget _buildHeaderCard(OrdemServico os) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.cardBackground,
            AppColors.cardBackground.withOpacity(0.95),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ordem de Serviço',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.textLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '#${os.numeroOS}',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.getStatusBackgroundColor(os.status),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.getStatusTextColor(os.status).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _getStatusText(os.status),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.getStatusTextColor(os.status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.backgroundGray.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.getPrioridadeColor(os.prioridade).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.priority_high,
                      size: 20,
                      color: AppColors.getPrioridadeColor(os.prioridade),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Prioridade',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textLight,
                        ),
                      ),
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
          ],
        ),
      ),
    );
  }

  // Card genérico para seções de informação aprimorado
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

