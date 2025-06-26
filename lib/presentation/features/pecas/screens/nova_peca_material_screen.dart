import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../domain/entities/peca_material.dart';
import '../../../shared/styles/app_colors.dart';
import '../providers/nova_peca_material_provider.dart';
import '../providers/peca_material_list_provider.dart';

class NovaPecaScreen extends ConsumerStatefulWidget {
  const NovaPecaScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<NovaPecaScreen> createState() => _NovaPecaScreenState();
}

class _NovaPecaScreenState extends ConsumerState<NovaPecaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codigoController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _precoController = TextEditingController();
  final _estoqueController = TextEditingController();

  void _salvarPeca() async {
    if (_formKey.currentState!.validate()) {
      final peca = PecaMaterial(
        codigo: _codigoController.text,
        descricao: _descricaoController.text,
        preco: double.tryParse(_precoController.text.replaceAll(',', '.')),
        estoque: int.tryParse(_estoqueController.text),
      );
      final success = await ref.read(novaPecaProvider.notifier).createPeca(peca);
      if (success && mounted) {
        ref.invalidate(pecaMaterialListProvider);
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _descricaoController.dispose();
    _precoController.dispose();
    _estoqueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<NovaPecaState>(novaPecaProvider, (_, state) {
      if (state.submissionError != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.submissionError!)));
      }
    });

    final isSubmitting = ref.watch(novaPecaProvider).isSubmitting;

    return Scaffold(
      appBar: AppBar(title: Text('Nova Peça/Material', style: GoogleFonts.poppins())),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(controller: _codigoController, decoration: const InputDecoration(labelText: 'Código*'), validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null),
            TextFormField(controller: _descricaoController, decoration: const InputDecoration(labelText: 'Descrição*'), validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null),
            TextFormField(controller: _precoController, decoration: const InputDecoration(labelText: 'Preço (RS)'), keyboardType: TextInputType.number),
            TextFormField(controller: _estoqueController, decoration: const InputDecoration(labelText: 'Estoque inicial'), keyboardType: TextInputType.number),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isSubmitting ? null : _salvarPeca,
              child: isSubmitting ? const CircularProgressIndicator() : const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}