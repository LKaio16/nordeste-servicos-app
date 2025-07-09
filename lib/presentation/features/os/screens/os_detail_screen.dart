import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:nordeste_servicos_app/data/models/prioridade_os_model.dart';
import 'package:nordeste_servicos_app/data/models/status_os_model.dart';
import 'package:nordeste_servicos_app/presentation/features/os/screens/signature_screen.dart';
import 'package:open_filex/open_filex.dart';

import '../../../../data/models/perfil_usuario_model.dart';
import '../../../../domain/entities/ordem_servico.dart';
import '../../../shared/providers/repository_providers.dart';
import '../../../shared/styles/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/assinatura_os_provider.dart';
import '../providers/foto_os_provider.dart';
import '../providers/os_detail_provider.dart';
import '../providers/os_list_provider.dart';
import '../providers/registro_tempo_provider.dart';
import 'os_edit_screen.dart';

class OsDetailScreen extends ConsumerStatefulWidget {
  final int osId;

  const OsDetailScreen({required this.osId, Key? key}) : super(key: key);

  @override
  ConsumerState<OsDetailScreen> createState() => _OsDetailScreenState();
}

class _OsDetailScreenState extends ConsumerState<OsDetailScreen> {
  final PageController _imagePageController = PageController();
  int _currentImageIndex = 0;
  final TextEditingController _solucaoAplicadaController =
      TextEditingController();
  final TextEditingController _analiseController = TextEditingController();
  bool _isEditingSolucao = false;
  bool _isEditingAnalise = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(osDetailProvider(widget.osId));
      ref.read(registroTempoProvider(widget.osId).notifier).fetchRegistros();
      ref.read(fotoOsProvider(widget.osId).notifier);
    });
  }

  @override
  void dispose() {
    _imagePageController.dispose();
    _solucaoAplicadaController.dispose();
    super.dispose();
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '--/--/---- --:--';
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  String _getStatusText(StatusOSModel status) {
    return status.name.replaceAll('_', ' ');
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'Excluir',
              style: GoogleFonts.poppins(
                  color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final osRepository = ref.read(osRepositoryProvider);
        await osRepository.deleteOrdemServico(widget.osId);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('OS excluída com sucesso!'),
              backgroundColor: AppColors.successGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
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
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    }
  }

  Future<void> _downloadPdf(
      BuildContext context, WidgetRef ref, OrdemServico os) async {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Baixando PDF da OS #${os.numeroOS}...'),
          backgroundColor: AppColors.primaryBlue,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }

    try {
      final osRepository = ref.read(osRepositoryProvider);
      final Uint8List pdfBytes = await osRepository.downloadOsPdf(os.id!);

      final String fileName = 'relatorio_os_${os.numeroOS}.pdf';
      String? filePath;

      if (!kIsWeb) {
        filePath = await FileSaver.instance.saveFile(
          name: fileName,
          bytes: pdfBytes,
          ext: 'pdf',
          mimeType: MimeType.pdf,
        );

        if (filePath == null) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Erro: Não foi possível salvar o arquivo PDF. Verifique as permissões do aplicativo ou tente novamente.'),
                backgroundColor: AppColors.errorRed,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
          return;
        }
      } else {
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
            content: Text(
                'Download concluído! Arquivo salvo em: ${filePath ?? 'local desconhecido'}'),
            backgroundColor: AppColors.successGreen,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  void _showImageFullScreen(List<dynamic> fotos, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _ImageFullScreenViewer(
          fotos: fotos,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  Future<void> _saveAnaliseFalha(OrdemServico os) async {
    final newAnalise = _analiseController.text;
    if (newAnalise == os.analiseFalha) {
      setState(() => _isEditingAnalise = false);
      return;
    }

    try {
      final osRepository = ref.read(osRepositoryProvider);
      await osRepository.updateOrdemServico(
        osId: os.id!,
        clienteId: os.cliente.id!,
        equipamentoId: os.equipamento.id!,
        problemaRelatado: os.problemaRelatado ?? '',
        analiseFalha: newAnalise,
        // Atualiza o campo
        solucaoAplicada: os.solucaoAplicada,
        status: os.status,
        prioridade: os.prioridade,
        tecnicoAtribuidoId: os.tecnicoAtribuido?.id,
        dataAgendamento: os.dataAgendamento,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Análise da Falha atualizada com sucesso!'),
              backgroundColor: AppColors.successGreen),
        );
        ref.invalidate(osDetailProvider(widget.osId));
        setState(() => _isEditingAnalise = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Erro ao atualizar Análise da Falha: ${e.toString()}'),
              backgroundColor: AppColors.errorRed),
        );
      }
    }
  }

  Future<void> _saveSolucaoAplicada(OrdemServico os) async {
    final newSolucao = _solucaoAplicadaController.text;
    if (newSolucao == os.solucaoAplicada) {
      setState(() {
        _isEditingSolucao = false;
      });
      return;
    }

    try {
      final osRepository = ref.read(osRepositoryProvider);

      await osRepository.updateOrdemServico(
        osId: os.id!,
        clienteId: os.cliente.id!,
        equipamentoId: os.equipamento.id!,
        tecnicoAtribuidoId: os.tecnicoAtribuido?.id,
        problemaRelatado: os.problemaRelatado ?? '',
        analiseFalha: os.analiseFalha,
        solucaoAplicada: newSolucao,
        status: os.status,
        prioridade: os.prioridade,
        dataAgendamento: os.dataAgendamento,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Solução Aplicada atualizada com sucesso!'),
            backgroundColor: AppColors.successGreen,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        ref.invalidate(osDetailProvider(widget.osId));
        setState(() {
          _isEditingSolucao = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Erro ao atualizar Solução Aplicada: ${e.toString()}'),
            backgroundColor: AppColors.errorRed,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final osAsyncValue = ref.watch(osDetailProvider(widget.osId));
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        title: Text(
          osAsyncValue.when(
            data: (ordemServico) => ordemServico.numeroOS,
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
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            ref.invalidate(osListProvider);
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: () => ref.invalidate(osDetailProvider(widget.osId)),
            tooltip: 'Atualizar',
          ),
          if (authState.authenticatedUser?.perfil == PerfilUsuarioModel.ADMIN)
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.white),
              onPressed: osAsyncValue.maybeWhen(
                data: (ordemServico) => () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => OsEditScreen(osId: widget.osId),
                    ),
                  );
                  ref.invalidate(osDetailProvider(widget.osId));
                  ref.invalidate(osListProvider);
                },
                orElse: () => null,
              ),
              tooltip: 'Editar OS',
            ),
          IconButton(
            icon:
                const Icon(Icons.picture_as_pdf_outlined, color: Colors.white),
            onPressed: osAsyncValue.maybeWhen(
              data: (ordemServico) =>
                  () => _downloadPdf(context, ref, ordemServico),
              orElse: () => null,
            ),
            tooltip: 'Baixar Relatório PDF',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
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
          // Initialize controller with current solution text when data is loaded
          if (!_isEditingSolucao) {
            _solucaoAplicadaController.text =
                ordemServico.solucaoAplicada ?? '';
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(osDetailProvider(widget.osId));
              ref.invalidate(fotoOsProvider(widget.osId));
              ref
                  .read(registroTempoProvider(widget.osId).notifier)
                  .fetchRegistros();
            },
            color: AppColors.primaryBlue,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildHeaderCard(ordemServico),
                const SizedBox(height: 16),
                if (ordemServico.tecnicoAtribuido?.id != null)
                  _buildTimerControls(context, ref, ordemServico.id!,
                      ordemServico.tecnicoAtribuido!.id!),
                const SizedBox(height: 16),
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
                      value:
                          "${ordemServico.equipamento.marcaModelo} - ${ordemServico.equipamento.numeroSerieChassi}",
                      icon: Icons.build_outlined,
                    ),
                    _buildDetailRow(
                      label: 'Técnico Atribuído',
                      value: ordemServico.tecnicoAtribuido?.nome ??
                          'Não atribuído',
                      icon: Icons.engineering_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
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
                const SizedBox(height: 16),
                _buildInfoCard(
                  title: 'Problema Relatado',
                  icon: Icons.report_problem_outlined,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundGray.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                          color: AppColors.dividerColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        ordemServico.problemaRelatado ??
                            'Nenhuma descrição fornecida.',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.textDark,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSolucaoAplicadaCard(ordemServico),
                const SizedBox(height: 16),
                _buildAnaliseFalhaCard(ordemServico),
                const SizedBox(height: 16),
                _buildTimeRecordsCard(context, ref, ordemServico.id!),
                const SizedBox(height: 16),
                _buildFotosCard(context, ref, widget.osId),
                const SizedBox(height: 16),
                _buildAssinaturaCard(context, ref, widget.osId),
                const SizedBox(height: 16),
              ],
            ),
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
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
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
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.errorRed.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.errorRed,
                  ),
                ),
                const SizedBox(height: 24),
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
                  onPressed: () =>
                      ref.invalidate(osDetailProvider(widget.osId)),
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text('Tentar Novamente'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimerControls(
      BuildContext context, WidgetRef ref, int osId, int tecnicoId) {
    final registroTempoState = ref.watch(registroTempoProvider(osId));
    final registroTempoNotifier =
        ref.read(registroTempoProvider(osId).notifier);

    String formatDuration(Duration d) {
      String twoDigits(int n) => n.toString().padLeft(2, '0');
      String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
      String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
      return "${twoDigits(d.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    }

    if (registroTempoState.isLoading) {
      return _buildInfoCard(
        title: 'Controle de Tempo',
        icon: Icons.timer_outlined,
        children: [
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          ),
        ],
      );
    }

    if (registroTempoState.errorMessage != null) {
      return _buildInfoCard(
        title: 'Controle de Tempo',
        icon: Icons.timer_off_outlined,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                registroTempoState.errorMessage!,
                style: GoogleFonts.poppins(color: AppColors.errorRed),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      );
    }

    Duration displayDuration = registroTempoState.totalDuration;
    if (registroTempoState.activeRegistro != null) {
      displayDuration += registroTempoState.elapsed;
    }

    return _buildInfoCard(
      title: 'Controle de Tempo',
      icon: Icons.timer_outlined,
      children: [
        Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primaryBlue.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              formatDuration(displayDuration),
              style: GoogleFonts.robotoMono(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        _buildTimerButtons(registroTempoState, registroTempoNotifier),
      ],
    );
  }

  Widget _buildTimerButtons(registroTempoState, registroTempoNotifier) {
    List<Widget> buttons = [];

    if (registroTempoState.activeRegistro == null &&
        registroTempoState.registros.isEmpty) {
      buttons.add(
        Expanded(
          child: _buildTimerButton(
            onPressed: () => registroTempoNotifier.iniciarRegistro(1),
            icon: Icons.play_arrow_rounded,
            label: 'Iniciar',
            color: AppColors.successGreen,
          ),
        ),
      );
    } else {
      if (registroTempoState.activeRegistro != null) {
        buttons.add(
          Expanded(
            child: _buildTimerButton(
              onPressed: () => registroTempoNotifier.finalizarRegistroTempo(),
              icon: Icons.pause_rounded,
              label: 'Pausar',
              color: AppColors.warningOrange,
            ),
          ),
        );
      } else if (registroTempoState.registros.isNotEmpty) {
        buttons.add(
          Expanded(
            child: _buildTimerButton(
              onPressed: () => registroTempoNotifier.iniciarRegistro(1),
              icon: Icons.play_arrow_rounded,
              label: 'Retomar',
              color: AppColors.primaryBlue,
            ),
          ),
        );
      }

      if (buttons.isNotEmpty) {
        buttons.add(const SizedBox(width: 12));
      }

      buttons.add(
        Expanded(
          child: _buildTimerButton(
            onPressed: () => registroTempoNotifier.finalizarRegistroTempo(),
            icon: Icons.stop_rounded,
            label: 'Parar',
            color: AppColors.errorRed,
          ),
        ),
      );
    }

    return Row(children: buttons);
  }

  Widget _buildTimerButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20, color: Colors.white),
      label: Text(
        label,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        shadowColor: color.withOpacity(0.3),
      ),
    );
  }

  Widget _buildTimeRecordsCard(BuildContext context, WidgetRef ref, int osId) {
    final registroTempoState = ref.watch(registroTempoProvider(osId));

    String formatDuration(Duration d) {
      String twoDigits(int n) => n.toString().padLeft(2, '0');
      String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
      String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
      return "${twoDigits(d.inHours)}h ${twoDigitMinutes}m ${twoDigitSeconds}s";
    }

    String _formatDate(DateTime? dateTime) {
      if (dateTime == null) return '--/--/----';
      return DateFormat('dd/MM/yyyy').format(dateTime);
    }

    String _formatTime(DateTime? dateTime) {
      if (dateTime == null) return '--:--';
      return DateFormat('HH:mm:ss').format(dateTime);
    }

    if (registroTempoState.registros.isEmpty &&
        registroTempoState.activeRegistro == null) {
      return const SizedBox.shrink();
    }

    return _buildInfoCard(
      title: 'Registros de Tempo',
      icon: Icons.history_outlined,
      children: [
        ...registroTempoState.registros.map((registro) {
          final duration =
              registro.horaTermino?.difference(registro.horaInicio) ??
                  Duration.zero;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.backgroundGray.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.dividerColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Início: ${_formatDate(registro.horaInicio)} ${_formatTime(registro.horaInicio)}',
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: AppColors.textLight),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Fim: ${_formatDate(registro.horaTermino)} ${_formatTime(registro.horaTermino)}',
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: AppColors.textLight),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    formatDuration(duration),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        if (registroTempoState.activeRegistro != null)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.successGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.successGreen.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.radio_button_checked,
                            size: 12,
                            color: AppColors.successGreen,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'ATIVO',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.successGreen,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Início: ${_formatDate(registroTempoState.activeRegistro!.horaInicio)} ${_formatTime(registroTempoState.activeRegistro!.horaInicio)}',
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: AppColors.textLight),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Em andamento...',
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: AppColors.textLight),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.successGreen.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    formatDuration(registroTempoState.elapsed),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.successGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.getStatusBackgroundColor(os.status),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.getStatusTextColor(os.status)
                          .withOpacity(0.3),
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
                      color: AppColors.getPrioridadeColor(os.prioridade)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.priority_high_rounded,
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
            Divider(
              color: AppColors.dividerColor.withOpacity(0.3),
              thickness: 1,
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

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
          Expanded(
            flex: 2,
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
            flex: 3,
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
            color: AppColors.backgroundGray.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: AppColors.dividerColor.withOpacity(0.3),
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

  Widget _buildFotosCard(BuildContext context, WidgetRef ref, int osId) {
    final fotosState = ref.watch(fotoOsProvider(osId));
    final fotosNotifier = ref.read(fotoOsProvider(osId).notifier);

    Future<void> _pickAndUploadImage() async {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 1024,
      );

      if (image == null || !context.mounted) return;

      final description = await showDialog<String>(
        context: context,
        builder: (context) {
          final controller = TextEditingController();
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(
              'Descrição da Foto',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Digite uma descrição...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              autofocus: true,
            ),
            actions: [
              TextButton(
                child: Text(
                  'Cancelar',
                  style: GoogleFonts.poppins(color: AppColors.textLight),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  'Salvar',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(controller.text),
              ),
            ],
          );
        },
      );

      if (description != null) {
        await fotosNotifier.uploadFoto(image, description);
      }
    }

    return _buildInfoCard(
      title: 'Fotos da OS',
      icon: Icons.photo_library_outlined,
      children: [
        if (fotosState.isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          ),
        if (!fotosState.isLoading && fotosState.errorMessage != null)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                fotosState.errorMessage!,
                style: GoogleFonts.poppins(color: AppColors.errorRed),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        if (!fotosState.isLoading && fotosState.fotos.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Icon(
                    Icons.photo_outlined,
                    size: 48,
                    color: AppColors.textLight,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Nenhuma foto adicionada",
                    style: GoogleFonts.poppins(
                      color: AppColors.textLight,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (fotosState.fotos.isNotEmpty) ...[
          SizedBox(
            height: 220,
            child: PageView.builder(
              controller: _imagePageController,
              onPageChanged: (index) {
                setState(() {
                  _currentImageIndex = index;
                });
              },
              itemCount: fotosState.fotos.length,
              itemBuilder: (context, index) {
                final foto = fotosState.fotos[index];
                final imageBytes = base64Decode(foto.fotoBase64);

                return GestureDetector(
                  onTap: () => _showImageFullScreen(fotosState.fotos, index),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.memory(
                            imageBytes,
                            fit: BoxFit.cover,
                          ),
                          if (foto.descricao != null &&
                              foto.descricao!.isNotEmpty)
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.7),
                                    ],
                                  ),
                                ),
                                child: Text(
                                  foto.descricao!,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.zoom_in,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          if (fotosState.fotos.length > 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                fotosState.fotos.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentImageIndex == index
                        ? AppColors.primaryBlue
                        : AppColors.textLight.withOpacity(0.3),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),
        ],
        ElevatedButton.icon(
          onPressed: fotosState.isUploading ? null : _pickAndUploadImage,
          icon: fotosState.isUploading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Icon(
                  Icons.add_a_photo_outlined,
                  size: 18,
                  color: Colors.white,
                ),
          label: Text(
            fotosState.isUploading ? 'Enviando...' : 'Adicionar Foto',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildAssinaturaCard(BuildContext context, WidgetRef ref, int osId) {
    final state = ref.watch(assinaturaProvider(osId));

    Widget buildSignatureDisplay(
        String title, String? name, String? base64String) {
      if (base64String == null || base64String.isEmpty) {
        return Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.backgroundGray.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.dividerColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.draw_outlined,
                  size: 32,
                  color: AppColors.textLight,
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Não coletada",
                  style: GoogleFonts.poppins(
                    fontStyle: FontStyle.italic,
                    color: AppColors.textLight,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      final bytes = base64Decode(base64String);
      return Expanded(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.successGreen.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.successGreen.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.dividerColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    bytes,
                    fit: BoxFit.contain,
                    width: double.infinity,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                name ?? "Nome não informado",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textLight,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return _buildInfoCard(
      title: "Assinaturas",
      icon: Icons.draw_outlined,
      children: [
        if (state.isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          )
        else ...[
          Row(
            children: [
              buildSignatureDisplay(
                "Cliente",
                state.assinatura?.nomeClienteResponsavel,
                state.assinatura?.assinaturaClienteBase64,
              ),
              const SizedBox(width: 12),
              buildSignatureDisplay(
                "Técnico",
                state.assinatura?.nomeTecnicoResponsavel,
                state.assinatura?.assinaturaTecnicoBase64,
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SignatureScreen(osId: osId),
                ),
              );
            },
            icon: Icon(
              state.assinatura != null
                  ? Icons.edit_outlined
                  : Icons.add_rounded,
              size: 18,
              color: Colors.white,
            ),
            label: Text(
              state.assinatura != null
                  ? 'Alterar Assinaturas'
                  : 'Coletar Assinaturas',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSolucaoAplicadaCard(OrdemServico os) {
    return _buildInfoCard(
      title: 'Solução Aplicada',
      icon: Icons.check_circle_outline,
      children: [
        if (_isEditingSolucao)
          Column(
            children: [
              TextFormField(
                controller: _solucaoAplicadaController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Descreva a solução aplicada...',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: AppColors.backgroundGray.withOpacity(0.5),
                ),
                style: GoogleFonts.poppins(
                    fontSize: 14, color: AppColors.textDark),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isEditingSolucao = false;
                        _solucaoAplicadaController.text =
                            os.solucaoAplicada ?? '';
                      });
                    },
                    child: Text('Cancelar',
                        style: GoogleFonts.poppins(color: AppColors.textLight)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _saveSolucaoAplicada(os),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Salvar',
                        style: GoogleFonts.poppins(
                            color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ],
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  os.solucaoAplicada?.isNotEmpty == true
                      ? os.solucaoAplicada!
                      : 'Nenhuma solução aplicada informada.',
                  style: GoogleFonts.poppins(
                      fontSize: 14, color: AppColors.textDark, height: 1.6),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () => setState(() => _isEditingSolucao = true),
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: Colors.white,
                  ),
                  label: Text('Editar Solução',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildAnaliseFalhaCard(OrdemServico os) {
    return _buildInfoCard(
      title: 'Análise da Falha',
      icon: Icons.search_outlined,
      children: [
        if (_isEditingAnalise)
          Column(
            children: [
              TextFormField(
                controller: _analiseController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Descreva a análise técnica da falha...',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: AppColors.backgroundGray.withOpacity(0.5),
                ),
                style: GoogleFonts.poppins(
                    fontSize: 14, color: AppColors.textDark),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isEditingAnalise = false;
                        _analiseController.text = os.analiseFalha ?? '';
                      });
                    },
                    child: Text('Cancelar',
                        style: GoogleFonts.poppins(color: AppColors.textLight)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _saveAnaliseFalha(os),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Salvar',
                        style: GoogleFonts.poppins(
                            color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ],
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  os.analiseFalha?.isNotEmpty == true
                      ? os.analiseFalha!
                      : 'Nenhuma análise da falha informada.',
                  style: GoogleFonts.poppins(
                      fontSize: 14, color: AppColors.textDark, height: 1.6),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () => setState(() => _isEditingAnalise = true),
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: Colors.white,
                  ),
                  label: Text('Editar Análise',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _ImageFullScreenViewer extends StatefulWidget {
  final List<dynamic> fotos;
  final int initialIndex;

  const _ImageFullScreenViewer({
    required this.fotos,
    required this.initialIndex,
  });

  @override
  State<_ImageFullScreenViewer> createState() => _ImageFullScreenViewerState();
}

class _ImageFullScreenViewerState extends State<_ImageFullScreenViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '${_currentIndex + 1} de ${widget.fotos.length}',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemCount: widget.fotos.length,
        itemBuilder: (context, index) {
          final foto = widget.fotos[index];
          final imageBytes = base64Decode(foto.fotoBase64);

          return InteractiveViewer(
            panEnabled: true,
            boundaryMargin: const EdgeInsets.all(20),
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(
              child: Image.memory(
                imageBytes,
                fit: BoxFit.contain,
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: widget.fotos[_currentIndex].descricao != null &&
              widget.fotos[_currentIndex].descricao!.isNotEmpty
          ? Container(
              color: Colors.black.withOpacity(0.8),
              padding: const EdgeInsets.all(16),
              child: Text(
                widget.fotos[_currentIndex].descricao!,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            )
          : null,
    );
  }
}
