import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../domain/entities/tipo_servico.dart';
import '../providers/tipo_servico_edit_provider.dart';
import '../providers/tipo_servico_list_provider.dart';

class TipoServicoEditScreen extends ConsumerStatefulWidget {
  final TipoServico servico;
  const TipoServicoEditScreen({required this.servico, Key? key}) : super(key: key);

  @override
  ConsumerState<TipoServicoEditScreen> createState() => _TipoServicoEditScreenState();
}

class _TipoServicoEditScreenState extends ConsumerState<TipoServicoEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descricaoController;

  @override
  void initState() {
    super.initState();
    _descricaoController = TextEditingController(text: widget.servico.descricao);
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    super.dispose();
  }

  void _salvarAlteracoes() async {
    if (_formKey.currentState!.validate()) {
      final servicoAtualizado = TipoServico(
        id: widget.servico.id,
        descricao: _descricaoController.text,
      );
      final success = await ref.read(servicoEditProvider.notifier).updateServico(servicoAtualizado);
      if (success && mounted) {
        ref.invalidate(tipoServicoListProvider);
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(servicoEditProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Tipo de Serviço', style: GoogleFonts.poppins()),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _descricaoController,
              decoration: const InputDecoration(labelText: 'Descrição*'),
              validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: state.isSubmitting ? null : _salvarAlteracoes,
              child: state.isSubmitting ? const CircularProgressIndicator() : const Text('Salvar Alterações'),
            ),
          ],
        ),
      ),
    );
  }
}
