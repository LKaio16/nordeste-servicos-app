import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:connectivity_plus/connectivity_plus.dart';
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
import '../../../../domain/entities/cliente.dart';
import '../../../../domain/entities/equipamento.dart';
import '../../../../domain/entities/foto_os.dart';
import '../../../../domain/entities/ordem_servico.dart';
import '../../../../domain/entities/usuario.dart';
import '../../../shared/providers/repository_providers.dart';
import '../../../shared/styles/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/assinatura_os_provider.dart';
import '../providers/foto_os_provider.dart';
import '../providers/os_detail_provider.dart';
import '../providers/os_list_provider.dart';
import '../providers/registro_tempo_provider.dart';
import 'os_edit_screen.dart';
import '../../clientes/screens/cliente_detail_screen.dart';
import '../../equipamentos/screens/equipamento_detail_screen.dart';

extension OrdemServicoCopyWith on OrdemServico {
  OrdemServico copyWith({
    int? id,
    String? numeroOS,
    StatusOSModel? status,
    PrioridadeOSModel? prioridade,
    DateTime? dataAbertura,
    DateTime? dataAgendamento,
    DateTime? dataFechamento,
    DateTime? dataHoraEmissao,
    Cliente? cliente,
    Equipamento? equipamento,
    Usuario? tecnicoAtribuido,
    String? problemaRelatado,
    String? analiseFalha,
    String? solucaoAplicada,
  }) {
    return OrdemServico(
      id: id ?? this.id,
      numeroOS: numeroOS ?? this.numeroOS,
      status: status ?? this.status,
      prioridade: prioridade ?? this.prioridade,
      dataAbertura: dataAbertura ?? this.dataAbertura,
      dataAgendamento: dataAgendamento ?? this.dataAgendamento,
      dataFechamento: dataFechamento ?? this.dataFechamento,
      dataHoraEmissao: dataHoraEmissao ?? this.dataHoraEmissao,
      cliente: cliente ?? this.cliente,
      equipamento: equipamento ?? this.equipamento,
      tecnicoAtribuido: tecnicoAtribuido ?? this.tecnicoAtribuido,
      problemaRelatado: problemaRelatado ?? this.problemaRelatado,
      analiseFalha: analiseFalha ?? this.analiseFalha,
      solucaoAplicada: solucaoAplicada ?? this.solucaoAplicada,
    );
  }
}

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
  bool _isUpdatingStatus = false;
  bool _isOffline = false;
  bool _isTecnico = false;

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
    _analiseController.dispose();
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
          ref.invalidate(osListProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('OS excluída com sucesso!'),
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
          content: Text('Baixando PDF da OS #${os.id}...'),
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

      final String fileName = 'relatorio_os_${os.id}.pdf';
      String? filePath;

      filePath = await FileSaver.instance.saveFile(
        name: fileName,
        bytes: pdfBytes,
        ext: 'pdf',
        mimeType: MimeType.pdf,
      );

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

  void _showImageFullScreen(List<FotoOS> fotos, int initialIndex) {
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
    if (_analiseController.text.isNotEmpty) {
      final updatedOs = os.copyWith(
        analiseFalha: _analiseController.text,
      );
      try {
        await ref.read(osRepositoryProvider).updateOrdemServico(
              osId: updatedOs.id!,
              clienteId: updatedOs.cliente.id!,
              equipamentoId: updatedOs.equipamento.id!,
              problemaRelatado: updatedOs.problemaRelatado ?? '',
              analiseFalha: updatedOs.analiseFalha,
              solucaoAplicada: updatedOs.solucaoAplicada,
              status: updatedOs.status,
              prioridade: updatedOs.prioridade,
              tecnicoAtribuidoId: updatedOs.tecnicoAtribuido?.id,
              dataAgendamento: updatedOs.dataAgendamento,
            );
        ref.invalidate(osDetailProvider(os.id!));

        setState(() => _isEditingAnalise = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Análise de falha atualizada com sucesso!'),
              backgroundColor: AppColors.successGreen,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao atualizar: ${e.toString()}'),
              backgroundColor: AppColors.errorRed,
            ),
          );
        }
      }
    }
  }

  Future<void> _saveSolucaoAplicada(OrdemServico os) async {
    if (_solucaoAplicadaController.text.isNotEmpty) {
      final updatedOs = os.copyWith(
        solucaoAplicada: _solucaoAplicadaController.text,
      );
      try {
        await ref.read(osRepositoryProvider).updateOrdemServico(
              osId: updatedOs.id!,
              clienteId: updatedOs.cliente.id!,
              equipamentoId: updatedOs.equipamento.id!,
              problemaRelatado: updatedOs.problemaRelatado ?? '',
              analiseFalha: updatedOs.analiseFalha,
              solucaoAplicada: updatedOs.solucaoAplicada,
              status: updatedOs.status,
              prioridade: updatedOs.prioridade,
              tecnicoAtribuidoId: updatedOs.tecnicoAtribuido?.id,
              dataAgendamento: updatedOs.dataAgendamento,
            );
        ref.invalidate(osDetailProvider(os.id!));
        setState(() => _isEditingSolucao = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Solução aplicada atualizada com sucesso!'),
              backgroundColor: AppColors.successGreen,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao atualizar: ${e.toString()}'),
              backgroundColor: AppColors.errorRed,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final osAsyncValue = ref.watch(osDetailProvider(widget.osId));
    final authState = ref.watch(authProvider);
    _isTecnico =
        authState.authenticatedUser?.perfil == PerfilUsuarioModel.TECNICO;
    final isAdmin =
        authState.authenticatedUser?.perfil == PerfilUsuarioModel.ADMIN;
    final connectivity = ref.watch(connectivityProvider);
    _isOffline = connectivity.when(
      data: (status) => status == ConnectivityResult.none,
      loading: () => false, // Default to online to avoid showing offline message on load
      error: (e, s) => true, // If connectivity check fails, assume offline
    );
    final bool shouldHideActions = _isOffline && _isTecnico;

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        title: Text(
          osAsyncValue.when(
            data: (ordemServico) => "OS #${ordemServico.id.toString()}",
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
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.white),
              onPressed: shouldHideActions
                  ? null
                  : () {
                      osAsyncValue.whenData((os) async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => OsEditScreen(osId: os.id!),
                          ),
                        );
                        ref.invalidate(osDetailProvider(widget.osId));
                        ref.invalidate(osListProvider);
                      });
                    },
              tooltip: 'Editar OS',
            ),
          if (osAsyncValue.hasValue && !shouldHideActions)
            IconButton(
              icon: const Icon(Icons.picture_as_pdf_outlined,
                  color: Colors.white),
              onPressed: () => _downloadPdf(context, ref, osAsyncValue.value!),
              tooltip: 'Baixar Relatório PDF',
            ),
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white),
              onPressed:
                  shouldHideActions ? null : () => _deleteOs(context, ref),
              tooltip: 'Excluir OS',
            ),
        ],
      ),
      body: osAsyncValue.when(
        data: (ordemServico) {
          if (!_isEditingSolucao) {
            _solucaoAplicadaController.text =
                ordemServico.solucaoAplicada ?? '';
          }
          if (!_isEditingAnalise) {
            _analiseController.text = ordemServico.analiseFalha ?? '';
          }

          if (_isTecnico && ordemServico.status == StatusOSModel.EM_ABERTO) {
            return _buildSimplifiedView(context, ref, ordemServico,
                (val) => setState(() => _isUpdatingStatus = val));
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(osDetailProvider(widget.osId));
            },
            color: AppColors.primaryBlue,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildHeaderCard(ordemServico),
                const SizedBox(height: 16),
                _buildInfoCard(
                  title: 'Informações Gerais',
                  icon: Icons.info_outline,
                  children: [
                    _buildDetailRow(
                      label: 'Cliente',
                      value: ordemServico.cliente.nomeCompleto,
                      icon: Icons.person_outline,
                      onTap: shouldHideActions ? null : () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ClienteDetailScreen(
                                clienteId: ordemServico.cliente.id!),
                          ),
                        );
                      },
                    ),
                    _buildDetailRow(
                      label: 'Equipamento',
                      value:
                          "${ordemServico.equipamento.marcaModelo} - ${ordemServico.equipamento.numeroSerieChassi}",
                      icon: Icons.build_outlined,
                      onTap: shouldHideActions ? null : () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => EquipamentoDetailScreen(
                                equipamentoId: ordemServico.equipamento.id!),
                          ),
                        );
                      },
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
                _buildTimeRecordsCard(context, ref, ordemServico.id!),

                if (shouldHideActions)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.wifi_off_rounded,
                            size: 48,
                            color: AppColors.textLight.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Você está offline',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'As ações de edição e outras seções estão ocultas. Conecte-se à internet para ter acesso a todas as funcionalidades.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else ...[
                  if (ordemServico.tecnicoAtribuido?.id != null) ...[
                    const SizedBox(height: 16),
                    _buildTimerControls(context, ref, ordemServico.id!,
                        ordemServico.tecnicoAtribuido!.id!),
                  ],
                  const SizedBox(height: 16),
                  _buildAnaliseFalhaCard(ordemServico),
                  const SizedBox(height: 16),
                  _buildSolucaoAplicadaCard(ordemServico),
                  const SizedBox(height: 16),
                  _buildFotosCard(context, ref, widget.osId),
                  const SizedBox(height: 16),
                  _buildAssinaturaCard(context, ref, widget.osId),
                  const SizedBox(height: 16),
                  if (_isTecnico &&
                      ordemServico.status == StatusOSModel.EM_ANDAMENTO)
                    _buildEnviarAprovacaoButton(
                        context, ref, ordemServico,
                        (val) => setState(() => _isUpdatingStatus = val)),
                  if (isAdmin &&
                      ordemServico.status ==
                          StatusOSModel.AGUARDANDO_APROVACAO)
                    _buildAprovarConcluirButton(
                        context, ref, ordemServico,
                        (val) => setState(() => _isUpdatingStatus = val)),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Erro ao carregar OS: ${err.toString()}'),
                ElevatedButton(
                  onPressed: () => ref.invalidate(osDetailProvider(widget.osId)),
                  child: const Text('Tentar Novamente'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String content,
    required String confirmText,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text(content, style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancelar',
                style: GoogleFonts.poppins(color: AppColors.textLight)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              confirmText,
              style: GoogleFonts.poppins(
                  color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Widget _buildAprovarConcluirButton(
      BuildContext context, WidgetRef ref, OrdemServico ordemServico, Function(bool) setUpdating) {
    if (ordemServico.status == StatusOSModel.AGUARDANDO_APROVACAO ||
        ordemServico.status == StatusOSModel.CONCLUIDA) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: ElevatedButton.icon(
          onPressed: _isUpdatingStatus
              ? null
              : () async {
                  final confirmed = await _showConfirmationDialog(
                    context: context,
                    title: 'Confirmar Conclusão',
                    content: 'Deseja realmente aprovar e concluir esta OS?',
                    confirmText: 'Confirmar',
                  );
                  if (!confirmed) return;

                  setUpdating(true);
                  try {
                    final osRepository = ref.read(osRepositoryProvider);
                    await osRepository.updateOrdemServicoStatus(
                        ordemServico.id!, StatusOSModel.CONCLUIDA);
                    ref.invalidate(osDetailProvider(widget.osId));
                    if(mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('OS Aprovada e Concluída!'),
                          backgroundColor: AppColors.successGreen,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Erro ao aprovar a OS: $e'),
                          backgroundColor: AppColors.errorRed,
                        ),
                      );
                    }
                  } finally {
                    if (mounted) {
                      setUpdating(false);
                    }
                  }
                },
          icon: _isUpdatingStatus
              ? Container(
                  width: 24,
                  height: 24,
                  padding: const EdgeInsets.all(2.0),
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                )
              : const Icon(Icons.check_circle_outline, color: Colors.white),
          label: Text(
            _isUpdatingStatus ? 'Processando...' : 'Aprovar e Concluir',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.successGreen,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildEnviarAprovacaoButton(
      BuildContext context, WidgetRef ref, OrdemServico ordemServico, Function(bool) setUpdating) {

    if (ordemServico.status == StatusOSModel.EM_ANDAMENTO) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: ElevatedButton.icon(
          onPressed: _isUpdatingStatus
              ? null
              : () async {
                  final confirmed = await _showConfirmationDialog(
                    context: context,
                    title: 'Confirmar Envio',
                    content: 'Deseja realmente enviar esta OS para aprovação?',
                    confirmText: 'Enviar',
                  );
                  if (!confirmed) return;

                  setUpdating(true);
                  try {
                    final osRepository = ref.read(osRepositoryProvider);
                    await osRepository.updateOrdemServicoStatus(
                        ordemServico.id!, StatusOSModel.AGUARDANDO_APROVACAO);
                    ref.invalidate(osDetailProvider(widget.osId));
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('OS enviada para aprovação!'),
                          backgroundColor: AppColors.successGreen,
                        ),
                      );
                    }
                  } catch (e) {
                     if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Erro ao enviar para aprovação: $e'),
                          backgroundColor: AppColors.errorRed,
                        ),
                      );
                    }
                  } finally {
                    if (mounted) {
                      setUpdating(false);
                    }
                  }
                },
          icon: _isUpdatingStatus
              ? Container(
                  width: 24,
                  height: 24,
                  padding: const EdgeInsets.all(2.0),
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                )
              : const Icon(Icons.send_outlined, color: Colors.white),
          label: Text(
            _isUpdatingStatus ? 'Enviando...' : 'Enviar para Aprovação',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.warningOrange,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildSimplifiedView(
      BuildContext context, WidgetRef ref, OrdemServico ordemServico, Function(bool) setUpdating) {
    
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildHeaderCard(ordemServico),
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
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton.icon(
              onPressed: (_isUpdatingStatus || _isOffline)
                  ? null
                  : () async {
                      setUpdating(true);
                      try {
                        final osRepository = ref.read(osRepositoryProvider);
                        await osRepository.updateOrdemServicoStatus(
                          ordemServico.id!, StatusOSModel.EM_ANDAMENTO);
                        ref.invalidate(osDetailProvider(widget.osId));
                        ref.read(osListProvider.notifier).refreshOrdensServico();
                        
                        if(mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Atendimento iniciado!'),
                              backgroundColor: AppColors.successGreen,
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Erro ao iniciar atendimento: $e'),
                              backgroundColor: AppColors.errorRed,
                            ),
                          );
                        }
                      } finally {
                        if (mounted) {
                          setUpdating(false);
                        }
                      }
                    },
              icon: _isUpdatingStatus
                  ? Container(
                      width: 24,
                      height: 24,
                      padding: const EdgeInsets.all(2.0),
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                  : const Icon(Icons.play_circle_outline, color: Colors.white),
              label: Text(
                _isUpdatingStatus ? 'Iniciando...' : 'Iniciar Atendimento',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.successGreen,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
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

    final displayDuration = registroTempoState.totalDuration + registroTempoState.elapsed;

    return _buildInfoCard(
      title: 'Controle de Tempo',
      icon: Icons.timer_outlined,
      children: [
        if (registroTempoState.isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          )
        else if (registroTempoState.errorMessage != null)
           Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                registroTempoState.errorMessage!,
                style: GoogleFonts.poppins(color: AppColors.errorRed),
                textAlign: TextAlign.center,
              ),
            ),
          )
        else ...[
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
        ]
      ],
    );
  }

  Widget _buildTimerButtons(RegistroTempoState state, RegistroTempoNotifier notifier) {
      
      bool isRunning = state.activeRegistro != null;
      
      List<Widget> buttons = [];

      if (!isRunning && state.registros.isEmpty) { // Initial state
        buttons.add(
          Expanded(
            child: _buildTimerButton(
              onPressed: () => notifier.iniciarRegistro(),
              icon: Icons.play_arrow_rounded,
              label: 'Iniciar',
              color: AppColors.successGreen,
            ),
          ),
        );
      } else if (isRunning) { // Running state
        buttons.add(
          Expanded(
            child: _buildTimerButton(
              onPressed: () => notifier.finalizarRegistroTempo(),
              icon: Icons.pause_rounded,
              label: 'Pausar',
              color: AppColors.warningOrange,
            ),
          ),
        );
        buttons.add(const SizedBox(width: 12));
        buttons.add(
          Expanded(
            child: _buildTimerButton(
              onPressed: () => notifier.finalizarRegistroTempo(),
              icon: Icons.stop_rounded,
              label: 'Finalizar',
              color: AppColors.errorRed,
            ),
          ),
        );
      } else { // Paused state
        buttons.add(
          Expanded(
            child: _buildTimerButton(
              onPressed: () => notifier.iniciarRegistro(),
              icon: Icons.play_arrow_rounded,
              label: 'Retomar',
              color: AppColors.primaryBlue,
            ),
          ),
        );
         buttons.add(const SizedBox(width: 12));
         buttons.add(
          Expanded(
            child: _buildTimerButton(
              onPressed: () => notifier.finalizarRegistroTempo(),
              icon: Icons.stop_rounded,
              label: 'Finalizar',
              color: AppColors.errorRed,
            ),
          ),
        );
      }
      
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: buttons
      );
  }

  Widget _buildTimerButton({
    required VoidCallback? onPressed,
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
                        '#${os.id}',
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
            if (children.isNotEmpty) ...[
              const SizedBox(height: 16),
              Divider(
                color: AppColors.dividerColor.withOpacity(0.3),
                thickness: 1,
              ),
              const SizedBox(height: 16),
              ...children,
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    String? value,
    IconData? icon,
    VoidCallback? onTap,
  }) {
    Widget content = Padding(
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
          if (onTap != null)
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppColors.textLight,
            ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.0),
        child: content,
      );
    }

    return content;
  }

  Widget _buildFotosCard(BuildContext context, WidgetRef ref, int osId) {
    final fotosState = ref.watch(fotoOsProvider(osId));
    final fotosNotifier = ref.read(fotoOsProvider(osId).notifier);

    Future<void> _pickAndUploadImage(ImageSource source) async {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
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
          )
        else if (fotosState.errorMessage != null)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                fotosState.errorMessage!,
                style: GoogleFonts.poppins(color: AppColors.errorRed),
                textAlign: TextAlign.center,
              ),
            ),
          )
        else if (fotosState.fotos.isEmpty)
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
          )
        else ...[
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
                              child: const Icon(
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
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: fotosState.isUploading ? null : () => _pickAndUploadImage(ImageSource.camera),
                icon: const Icon( Icons.camera_alt_outlined, size: 18, color: Colors.white),
                label: Text('Câmera', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: fotosState.isUploading ? null : () => _pickAndUploadImage(ImageSource.gallery),
                icon: fotosState.isUploading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon( Icons.photo_library_outlined, size: 18, color: Colors.white),
                label: Text(fotosState.isUploading ? 'Enviando...' : 'Galeria', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
              ),
            ),
          ],
        )
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
                'Cliente',
                state.assinatura?.nomeClienteResponsavel,
                state.assinatura?.assinaturaClienteBase64,
              ),
              const SizedBox(width: 12),
              buildSignatureDisplay(
                'Técnico',
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
            _buildEditableField(
              controller: _solucaoAplicadaController,
              hint: 'Descreva a solução aplicada...',
              onSave: () => _saveSolucaoAplicada(os),
              onCancel: () {
                setState(() {
                  _isEditingSolucao = false;
                  _solucaoAplicadaController.text = os.solucaoAplicada ?? '';
                });
              },
            )
          else
            _buildReadOnlyField(
              content: os.solucaoAplicada,
              emptyText: 'Nenhuma solução aplicada informada.',
              onEdit: () => setState(() => _isEditingSolucao = true),
              editButtonLabel: 'Editar Solução',
            ),
        ]);
  }

  Widget _buildAnaliseFalhaCard(OrdemServico os) {
    return _buildInfoCard(
      title: 'Análise da Falha',
      icon: Icons.search_outlined,
      children: [
        if (_isEditingAnalise)
          _buildEditableField(
            controller: _analiseController,
            hint: 'Descreva a análise técnica da falha...',
            onSave: () => _saveAnaliseFalha(os),
            onCancel: () {
              setState(() {
                _isEditingAnalise = false;
                _analiseController.text = os.analiseFalha ?? '';
              });
            },
          )
        else
          _buildReadOnlyField(
            content: os.analiseFalha,
            emptyText: 'Nenhuma análise da falha informada.',
            onEdit: () => setState(() => _isEditingAnalise = true),
            editButtonLabel: 'Editar Análise',
          ),
      ],
    );
  }

  Widget _buildReadOnlyField({
    required String? content,
    required String emptyText,
    required VoidCallback onEdit,
    required String editButtonLabel,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          child: Text(
            content?.isNotEmpty == true ? content! : emptyText,
            style: GoogleFonts.poppins(
                fontSize: 14, color: AppColors.textDark, height: 1.6),
          ),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: onEdit,
            icon: const Icon(
              Icons.edit_outlined,
              size: 18,
              color: Colors.white,
            ),
            label: Text(editButtonLabel,
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
    );
  }

  Widget _buildEditableField({
    required TextEditingController controller,
    required String hint,
    required VoidCallback onSave,
    required VoidCallback onCancel,
  }) {
    return Column(
      children: [
        TextFormField(
          controller: controller,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: AppColors.backgroundGray.withOpacity(0.5),
          ),
          style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textDark),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: onCancel,
              child: Text('Cancelar',
                  style: GoogleFonts.poppins(color: AppColors.textLight)),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: onSave,
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
    );
  }
}

class _ImageFullScreenViewer extends StatefulWidget {
  final List<FotoOS> fotos;
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
