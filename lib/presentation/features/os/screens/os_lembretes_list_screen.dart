import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:nordeste_servicos_app/core/error/exceptions.dart';
import 'package:nordeste_servicos_app/domain/entities/ordem_servico.dart';
import 'package:nordeste_servicos_app/presentation/features/dashboard/providers/os_dashboard_data_provider.dart';
import 'package:nordeste_servicos_app/presentation/shared/providers/repository_providers.dart';
import 'package:nordeste_servicos_app/presentation/shared/styles/app_colors.dart';

import 'os_detail_screen.dart';

final osLembretesListProvider = FutureProvider.autoDispose((ref) async {
  return ref.read(osRepositoryProvider).listarLembretesAtivos();
});

class OsLembretesListScreen extends ConsumerStatefulWidget {
  const OsLembretesListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OsLembretesListScreen> createState() => _OsLembretesListScreenState();
}

class _OsLembretesListScreenState extends ConsumerState<OsLembretesListScreen> {
  int? _busyOsId;

  Future<void> _desativarLembrete(OrdemServico os) async {
    final id = os.id;
    if (id == null) return;

    setState(() => _busyOsId = id);
    try {
      await ref.read(osRepositoryProvider).updateOrdemServicoLembrete(
            osId: id,
            ativo: false,
          );
      if (!mounted) return;
      ref.invalidate(osLembretesListProvider);
      ref.read(osDashboardProvider.notifier).fetchOsDashboardData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Lembrete da OS #$id desativado.',
            style: GoogleFonts.poppins(),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message, style: GoogleFonts.poppins()),
          backgroundColor: AppColors.errorRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: $e', style: GoogleFonts.poppins()),
          backgroundColor: AppColors.errorRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _busyOsId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(osLembretesListProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        title: Text(
          'Lembretes de OS',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
      ),
      body: async.when(
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Text(
                'Nenhum lembrete ativo.',
                style: GoogleFonts.poppins(color: AppColors.textLight, fontSize: 16),
              ),
            );
          }
          final now = DateTime.now();
          final hoje = DateTime(now.year, now.month, now.day);
          return RefreshIndicator(
            color: AppColors.primaryBlue,
            onRefresh: () async => ref.invalidate(osLembretesListProvider),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: list.length,
              itemBuilder: (context, i) {
                final os = list[i];
                final alvo = os.lembreteDataAlvo;
                final dAlvo = alvo != null
                    ? DateTime(alvo.year, alvo.month, alvo.day)
                    : null;
                final atrasado = dAlvo != null && dAlvo.isBefore(hoje);
                final id = os.id;
                final busy = id != null && _busyOsId == id;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    title: Text(
                      'OS #${os.id}',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${os.cliente.nomeCompleto}\n'
                      '${alvo != null ? 'Data alvo: ${DateFormat('dd/MM/yyyy').format(alvo)}' : ''}'
                      '${os.lembreteDiasAposFechamento != null ? ' · ${os.lembreteDiasAposFechamento} dias após fechamento' : ''}',
                      style: GoogleFonts.poppins(fontSize: 13),
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          atrasado ? Icons.warning_amber_rounded : Icons.schedule_outlined,
                          color: atrasado ? AppColors.errorRed : AppColors.warningOrange,
                        ),
                        const SizedBox(width: 4),
                        Tooltip(
                          message: 'Desativar lembrete',
                          child: IconButton(
                            onPressed: busy || id == null
                                ? null
                                : () => _desativarLembrete(os),
                            icon: busy
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : Icon(
                                    Icons.task_alt_rounded,
                                    color: AppColors.successGreen,
                                  ),
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      if (id != null) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => OsDetailScreen(osId: id),
                          ),
                        );
                      }
                    },
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue)),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Erro ao carregar lembretes',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  e.toString(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(color: AppColors.textLight, fontSize: 13),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => ref.invalidate(osLembretesListProvider),
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
