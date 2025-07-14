import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../domain/entities/tipo_servico.dart';
import '../../../shared/styles/app_colors.dart';
import '../providers/tipo_servico_detail_provider.dart';
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
      FocusScope.of(context).unfocus();

      final servicoAtualizado = TipoServico(
        id: widget.servico.id,
        descricao: _descricaoController.text,
      );

      final success = await ref.read(servicoEditProvider.notifier).updateServico(servicoAtualizado);

      if (success && mounted) {
        // Invalida os providers para garantir que a lista e os detalhes sejam atualizados
        ref.invalidate(tipoServicoListProvider);
        ref.invalidate(tipoServicoDetailProvider(widget.servico.id!));

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Serviço atualizado com sucesso!', style: GoogleFonts.poppins()),
            backgroundColor: AppColors.successGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Volta para a tela anterior (detalhes do serviço)
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(servicoEditProvider);

    // Listener para mostrar erros de submissão
    ref.listen<ServicoEditState>(servicoEditProvider, (_, state) {
      if (state.submissionError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.submissionError!, style: GoogleFonts.poppins()),
            backgroundColor: AppColors.errorRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });


    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        title: Text(
          'Editar Tipo de Serviço',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primaryBlue, AppColors.secondaryBlue],
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
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

  Widget _buildFormHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.edit_note, color: AppColors.primaryBlue, size: 24),
            ),
            const SizedBox(width: 12),
            Text('Alterar Serviço', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          ],
        ),
        const SizedBox(height: 8),
        Text('Modifique a descrição do tipo de serviço', style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textLight)),
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
        onPressed: isSubmitting ? null : _salvarAlteracoes,
        icon: isSubmitting
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
            : const Icon(Icons.save_as_outlined, color: Colors.white),
        label: Text(
          isSubmitting ? 'Salvando...' : 'Salvar Alterações',
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
