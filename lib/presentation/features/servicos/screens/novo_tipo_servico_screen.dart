import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../shared/styles/app_colors.dart';
import '../providers/novo_tipo_servico_provider.dart';
import '../providers/tipo_servico_list_provider.dart';

class NovoTipoServicoScreen extends ConsumerStatefulWidget {
  const NovoTipoServicoScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<NovoTipoServicoScreen> createState() => _NovoTipoServicoScreenState();
}

class _NovoTipoServicoScreenState extends ConsumerState<NovoTipoServicoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descricaoController = TextEditingController();

  @override
  void dispose() {
    _descricaoController.dispose();
    super.dispose();
  }

  void _salvarServico() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      final success = await ref.read(novoServicoProvider.notifier).createServico(_descricaoController.text);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Serviço salvo com sucesso!'),
            backgroundColor: AppColors.successGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
        ref.invalidate(tipoServicoListProvider);
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<NovoServicoState>(novoServicoProvider, (_, state) {
      if (state.submissionError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.submissionError!),
            backgroundColor: AppColors.errorRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    final state = ref.watch(novoServicoProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('Novo Tipo de Serviço', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white)),
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ElevatedButton.icon(
              onPressed: state.isSubmitting ? null : _salvarServico,
              icon: state.isSubmitting
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryBlue))
                  : const Icon(Icons.save, size: 18),
              label: Text('Salvar', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        physics: const BouncingScrollPhysics(),
        child: Card(
          elevation: 4,
          shadowColor: AppColors.primaryBlue.withOpacity(0.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormHeader(),
                  const SizedBox(height: 24),
                  _buildTextFormField(
                    controller: _descricaoController,
                    label: 'Descrição do Serviço*',
                    icon: Icons.miscellaneous_services_outlined,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 32),
                  _buildSaveButton(state.isSubmitting),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES DE UI ---

  Widget _buildFormHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.add_circle_outline, color: AppColors.primaryBlue, size: 24),
            ),
            const SizedBox(width: 12),
            Text('Cadastro de Serviço', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          ],
        ),
        const SizedBox(height: 8),
        Text('Insira a descrição do novo tipo de serviço', style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textLight)),
        const SizedBox(height: 16),
        const Divider(color: AppColors.dividerColor),
      ],
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    bool isOptional = false,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textDark)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: GoogleFonts.poppins(color: AppColors.textDark, fontSize: 15),
          decoration: InputDecoration(
            prefixIcon: icon != null ? Icon(icon, color: AppColors.primaryBlue) : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2)),
          ),
          validator: (value) {
            if (!isOptional && (value == null || value.isEmpty)) {
              return 'Campo obrigatório';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSaveButton(bool isSubmitting) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: isSubmitting ? null : _salvarServico,
        icon: isSubmitting
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
            : const Icon(Icons.check_circle_outline, color: Colors.white),
        label: Text(
          isSubmitting ? 'Salvando...' : 'Salvar Serviço',
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
