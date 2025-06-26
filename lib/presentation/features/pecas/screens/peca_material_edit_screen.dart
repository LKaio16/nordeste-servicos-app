import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../domain/entities/peca_material.dart';
import '../../../shared/styles/app_colors.dart';
import '../providers/peca_material_detail_provider.dart';
import '../providers/peca_material_edit_provider.dart';
import '../providers/peca_material_list_provider.dart';
import 'peca_material_detail_screen.dart';


class PecaMaterialEditScreen extends ConsumerStatefulWidget {
  final int pecaId;
  const PecaMaterialEditScreen({Key? key, required this.pecaId}) : super(key: key);

  @override
  ConsumerState<PecaMaterialEditScreen> createState() => _PecaMaterialEditScreenState();
}

class _PecaMaterialEditScreenState extends ConsumerState<PecaMaterialEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codigoController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _precoController = TextEditingController();
  final _estoqueController = TextEditingController();
  bool _initialDataLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(pecaMaterialEditProvider(widget.pecaId).notifier).loadInitialData(widget.pecaId);
    });
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _descricaoController.dispose();
    _precoController.dispose();
    _estoqueController.dispose();
    super.dispose();
  }

  void _initializeFormFields(PecaMaterial peca) {
    if (!_initialDataLoaded) {
      _codigoController.text = peca.codigo;
      _descricaoController.text = peca.descricao;
      _precoController.text = peca.preco?.toString() ?? '';
      _estoqueController.text = peca.estoque?.toString() ?? '';
      _initialDataLoaded = true;
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final pecaAtualizada = PecaMaterial(
        id: widget.pecaId,
        codigo: _codigoController.text,
        descricao: _descricaoController.text,
        preco: double.tryParse(_precoController.text.replaceAll(',', '.')),
        estoque: int.tryParse(_estoqueController.text),
      );

      final success = await ref.read(pecaMaterialEditProvider(widget.pecaId).notifier).updatePeca(pecaAtualizada);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Item atualizado com sucesso!'), backgroundColor: AppColors.successGreen),
        );
        ref.invalidate(pecaMaterialListProvider);
        ref.invalidate(pecaMaterialDetailProvider(widget.pecaId));
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pecaMaterialEditProvider(widget.pecaId));

    ref.listen<PecaMaterialEditState>(pecaMaterialEditProvider(widget.pecaId), (previous, next) {
      if (next.originalPeca != null && !_initialDataLoaded) {
        _initializeFormFields(next.originalPeca!);
      }
      if (next.submissionError != null && next.submissionError != previous?.submissionError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.submissionError!), backgroundColor: AppColors.errorRed),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        title: Text(
          state.originalPeca != null ? 'Editar: ${state.originalPeca!.codigo}' : 'Editar Item',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [AppColors.primaryBlue, AppColors.secondaryBlue]),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ElevatedButton.icon(
              onPressed: state.isLoadingInitialData || state.isSubmitting ? null : _submitForm,
              icon: state.isSubmitting
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: AppColors.primaryBlue, strokeWidth: 2))
                  : const Icon(Icons.save, size: 18),
              label: Text('Salvar', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, foregroundColor: AppColors.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
            ),
          ),
        ],
      ),
      body: state.isLoadingInitialData
          ? _buildLoadingState()
          : (state.initialDataError != null
          ? _buildErrorState(state.initialDataError!)
          : _buildFormContent()),
    );
  }

  // -- Widgets Auxiliares de UI (copiados e adaptados de OsEditScreen) --

  Widget _buildFormContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      physics: const BouncingScrollPhysics(),
      child: Form(
        key: _formKey,
        child: _buildSectionCard(
          title: 'Informações da Peça/Material',
          icon: Icons.inventory_2_outlined,
          children: [
            _buildTextFormField(controller: _codigoController, label: 'Código', icon: Icons.qr_code_2_outlined),
            const SizedBox(height: 20),
            _buildTextFormField(controller: _descricaoController, label: 'Descrição', icon: Icons.description_outlined, maxLines: 3),
            const SizedBox(height: 20),
            _buildTextFormField(controller: _precoController, label: 'Preço (R\$)', icon: Icons.price_change_outlined, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
            const SizedBox(height: 20),
            _buildTextFormField(controller: _estoqueController, label: 'Estoque (unidades)', icon: Icons.warehouse_outlined, keyboardType: TextInputType.number),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
            strokeWidth: 3,
          ),
          const SizedBox(height: 24),
          Text(
            'Carregando dados do item...',
            style: GoogleFonts.poppins(
              color: AppColors.textLight,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // 2. Widget para o estado de erro no carregamento inicial
  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.errorRed.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                color: AppColors.errorRed,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Erro ao Carregar Dados',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              error,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // Lógica para tentar novamente
                ref.read(pecaMaterialEditProvider(widget.pecaId).notifier).loadInitialData(widget.pecaId);
              },
              icon: const Icon(Icons.refresh),
              label: Text(
                'Tentar Novamente',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 3. Widget para criar os cards de seção
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 24, color: AppColors.primaryBlue),
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textDark),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(color: AppColors.dividerColor, height: 1),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  // 4. Widget para os campos de texto do formulário
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(fontSize: 16, color: AppColors.textDark),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: AppColors.textLight, fontSize: 14),
        prefixIcon: icon != null
            ? Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: AppColors.primaryBlue),
        )
            : null,
        filled: true,
        fillColor: AppColors.cardBackground,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.dividerColor)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.dividerColor)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.errorRed)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: (value) {
        // Validação simples, pode ser aprimorada conforme a necessidade
        if (value == null || value.isEmpty) {
          return 'Campo obrigatório';
        }
        return null;
      },
    );
  }
}