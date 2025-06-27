import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../shared/styles/app_colors.dart';
import '../providers/tipo_servico_detail_provider.dart';
import 'tipo_servico_edit_screen.dart';

class TipoServicoDetailScreen extends ConsumerWidget {
  final int servicoId;
  const TipoServicoDetailScreen({required this.servicoId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicoAsyncValue = ref.watch(tipoServicoDetailProvider(servicoId));

    return Scaffold(
      appBar: AppBar(
        title: servicoAsyncValue.when(
          data: (servico) => Text(servico.descricao, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          loading: () => Text('Carregando...', style: GoogleFonts.poppins()),
          error: (e,s) => Text('Detalhes', style: GoogleFonts.poppins()),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: servicoAsyncValue.whenOrNull(
              data: (servico) => () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => TipoServicoEditScreen(servico: servico)),
                );
              },
            ),
          )
        ],
      ),
      body: servicoAsyncValue.when(
        data: (servico) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: ListTile(
                title: const Text('ID do Serviço'),
                subtitle: Text(servico.id.toString()),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text('Descrição'),
                subtitle: Text(servico.descricao),
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erro: $err')),
      ),
    );
  }
}
