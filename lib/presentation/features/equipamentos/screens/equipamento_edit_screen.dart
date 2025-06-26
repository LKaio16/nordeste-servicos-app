import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../domain/entities/cliente.dart';
import '../../../../domain/entities/equipamento.dart';
import '../../../shared/styles/app_colors.dart';
import '../providers/equipamento_detail_provider.dart';
import '../providers/equipamento_edit_provider.dart';
import '../providers/equipamento_list_provider.dart';

class EquipamentoEditScreen extends ConsumerStatefulWidget {
  final int equipamentoId;
  const EquipamentoEditScreen({Key? key, required this.equipamentoId}) : super(key: key);

  @override
  ConsumerState<EquipamentoEditScreen> createState() => _EquipamentoEditScreenState();
}

class _EquipamentoEditScreenState extends ConsumerState<EquipamentoEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tipoController = TextEditingController();
  final _marcaModeloController = TextEditingController();
  final _serieChassiController = TextEditingController();
  final _horimetroController = TextEditingController();
  String? _selectedClienteId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(equipamentoEditProvider(widget.equipamentoId).notifier).loadInitialData(widget.equipamentoId);
    });
  }

  @override
  void dispose() {
    _tipoController.dispose();
    _marcaModeloController.dispose();
    _serieChassiController.dispose();
    _horimetroController.dispose();
    super.dispose();
  }

  void _initializeFormFields(Equipamento equipamento) {
    _tipoController.text = equipamento.tipo;
    _marcaModeloController.text = equipamento.marcaModelo;
    _serieChassiController.text = equipamento.numeroSerieChassi;
    _horimetroController.text = equipamento.horimetro?.toString() ?? '';
    setState(() {
      _selectedClienteId = equipamento.clienteId.toString();
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      final equipamentoAtualizado = Equipamento(
        id: widget.equipamentoId,
        tipo: _tipoController.text,
        marcaModelo: _marcaModeloController.text,
        numeroSerieChassi: _serieChassiController.text,
        horimetro: _horimetroController.text.isNotEmpty ? double.tryParse(_horimetroController.text.replaceAll(',', '.')) : null,
        clienteId: int.parse(_selectedClienteId!),
      );

      final success = await ref.read(equipamentoEditProvider(widget.equipamentoId).notifier).updateEquipamento(equipamentoAtualizado);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Equipamento atualizado!'), backgroundColor: AppColors.successGreen));
        ref.invalidate(equipamentoListProvider);
        ref.invalidate(equipamentoDetailProvider(widget.equipamentoId));
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(equipamentoEditProvider(widget.equipamentoId));

    ref.listen<EquipamentoEditState>(equipamentoEditProvider(widget.equipamentoId), (previous, next) {
      if (next.originalEquipamento != previous?.originalEquipamento && next.originalEquipamento != null) {
        _initializeFormFields(next.originalEquipamento!);
      }
      if (next.submissionError != null && next.submissionError != previous?.submissionError) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.submissionError!), backgroundColor: AppColors.errorRed));
      }
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        title: Text(state.originalEquipamento?.marcaModelo ?? 'Editar Equipamento', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white)),
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppColors.primaryBlue, AppColors.secondaryBlue]))),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.of(context).pop()),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ElevatedButton.icon(
              onPressed: state.isLoading || state.isSubmitting ? null : _submitForm,
              icon: state.isSubmitting ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryBlue)) : const Icon(Icons.save, size: 18),
              label: Text('Salvar', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
            ),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.errorMessage != null
          ? Center(child: Text(state.errorMessage!))
          : _buildFormContent(state),
    );
  }

  Widget _buildFormContent(EquipamentoEditState state) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        physics: const BouncingScrollPhysics(),
        children: [
          _buildSectionCard(
            title: 'Detalhes do Equipamento',
            icon: Icons.build_outlined,
            children: [
              _buildDropdownFormField(
                value: _selectedClienteId,
                // <<< CORREÇÃO AQUI >>>
                items: state.clientes.map((cliente) {
                  return DropdownMenuItem<String>(
                    value: cliente.id.toString(),
                    child: Text(cliente.nomeCompleto),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedClienteId = value),
                label: 'Cliente Proprietário*',
                icon: Icons.person_search_outlined,
              ),
              const SizedBox(height: 20),
              _buildTextFormField(controller: _tipoController, label: 'Tipo*', icon: Icons.category_outlined),
              const SizedBox(height: 20),
              _buildTextFormField(controller: _marcaModeloController, label: 'Marca/Modelo*', icon: Icons.branding_watermark_outlined),
              const SizedBox(height: 20),
              _buildTextFormField(controller: _serieChassiController, label: 'Nº de Série/Chassi*', icon: Icons.confirmation_number_outlined),
              const SizedBox(height: 20),
              _buildTextFormField(
                controller: _horimetroController,
                label: 'Horímetro',
                icon: Icons.timer_outlined,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                isOptional: true, // <<< CORREÇÃO AQUI >>>
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- WIDGETS AUXILIARES PARA CONSTRUÇÃO DO FORMULÁRIO ---

  Widget _buildSectionCard({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(color: AppColors.primaryBlue.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 8)),
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
                  decoration: BoxDecoration(color: AppColors.primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, size: 24, color: AppColors.primaryBlue),
                ),
                const SizedBox(width: 16),
                Text(title, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textDark)),
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

  Widget _buildTextFormField({required TextEditingController controller, required String label, IconData? icon, bool isOptional = false, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label + (isOptional ? ' (Opcional)' : ''), style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textDark)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
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

  Widget _buildDropdownFormField({required String? value, required List<DropdownMenuItem<String>> items, required ValueChanged<String?> onChanged, required String label, IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textDark)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items,
          onChanged: onChanged,
          validator: (val) => (val == null || val.isEmpty) ? 'Campo obrigatório' : null,
          style: GoogleFonts.poppins(color: AppColors.textDark, fontSize: 15),
          decoration: InputDecoration(
            prefixIcon: icon != null ? Icon(icon, color: AppColors.primaryBlue) : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2)),
            hintText: 'Selecione',
            hintStyle: GoogleFonts.poppins(color: AppColors.textLight.withOpacity(0.7)),
          ),
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.primaryBlue),
          dropdownColor: Colors.white,
          isExpanded: true,
        ),
      ],
    );
  }
}
