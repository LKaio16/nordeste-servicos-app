import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../domain/entities/cliente.dart';
import '../../../shared/styles/app_colors.dart';
import '../providers/novo_equipamento_provider.dart';

class NovoEquipamentoScreen extends ConsumerStatefulWidget {
  const NovoEquipamentoScreen({super.key});

  @override
  ConsumerState<NovoEquipamentoScreen> createState() => _NovoEquipamentoScreenState();
}

class _NovoEquipamentoScreenState extends ConsumerState<NovoEquipamentoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tipoController = TextEditingController();
  final _marcaModeloController = TextEditingController();
  final _serieChassiController = TextEditingController();
  final _horimetroController = TextEditingController();
  String? _selectedClienteId;

  @override
  void initState() {
    super.initState();
    // Atraso para garantir que o contexto está disponível
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(novoEquipamentoProvider.notifier).loadInitialData();
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

  void _salvarEquipamento() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      final success = await ref.read(novoEquipamentoProvider.notifier).createEquipamento(
        tipo: _tipoController.text,
        marcaModelo: _marcaModeloController.text,
        numeroSerieChassi: _serieChassiController.text,
        horimetro: _horimetroController.text.isNotEmpty ? double.tryParse(_horimetroController.text.replaceAll(',', '.')) : null,
        clienteId: int.parse(_selectedClienteId!),
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Equipamento salvo com sucesso!'), backgroundColor: AppColors.successGreen));
        // Opcional: invalidar a lista de equipamentos se você tiver uma
        // ref.invalidate(equipamentoListProvider);
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(novoEquipamentoProvider);

    ref.listen<NovoEquipamentoState>(novoEquipamentoProvider, (previous, next) {
      if (next.submissionError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.submissionError!), backgroundColor: AppColors.errorRed),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('Novo Equipamento', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white)),
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
          : SingleChildScrollView(
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
                  _buildSectionTitle('Proprietário', Icons.person_search_outlined),
                  _buildDropdownFormField(
                      value: _selectedClienteId,
                      items: state.clientes.map((Cliente cliente) {
                        return DropdownMenuItem<String>(
                          value: cliente.id.toString(),
                          child: Text(cliente.nomeCompleto, style: GoogleFonts.poppins(), overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _selectedClienteId = value),
                      label: 'Cliente Proprietário*',
                      icon: Icons.person_outline,
                      hint: 'Selecione o cliente'
                  ),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Detalhes do Equipamento', Icons.build_outlined),
                  _buildTextFormField(controller: _tipoController, label: 'Tipo*', icon: Icons.category_outlined, hint: 'Ex: Gerador, Compressor'),
                  _buildTextFormField(controller: _marcaModeloController, label: 'Marca/Modelo*', icon: Icons.branding_watermark_outlined, hint: 'Ex: Cummins C220D5'),
                  _buildTextFormField(controller: _serieChassiController, label: 'Nº de Série/Chassi*', icon: Icons.confirmation_number_outlined, hint: 'Ex: ABC123XYZ789'),
                  _buildTextFormField(controller: _horimetroController, label: 'Horímetro', icon: Icons.timer_outlined, keyboardType: const TextInputType.numberWithOptions(decimal: true), hint: 'Ex: 1500.5', isOptional: true),
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

  // --- WIDGETS AUXILIARES REUTILIZADOS ---

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: AppColors.primaryBlue, size: 20),
          ),
          const SizedBox(width: 12),
          Text(title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
        ],
      ),
    );
  }

  Widget _buildDropdownFormField({required String? value, required List<DropdownMenuItem<String>> items, required ValueChanged<String?> onChanged, required String label, required IconData icon, required String hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textDark)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: AppColors.primaryBlue.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: DropdownButtonFormField<String>(
              value: value,
              items: items,
              onChanged: onChanged,
              validator: (val) => (val == null || val.isEmpty) ? 'Campo obrigatório' : null,
              style: GoogleFonts.poppins(color: AppColors.textDark, fontSize: 15),
              decoration: InputDecoration(
                prefixIcon: Icon(icon, color: AppColors.primaryBlue),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5)),
                contentPadding: const EdgeInsets.all(16),
                hintText: hint,
                hintStyle: GoogleFonts.poppins(color: AppColors.textLight.withOpacity(0.7)),
              ),
              icon: const Icon(Icons.arrow_drop_down, color: AppColors.primaryBlue),
              dropdownColor: Colors.white,
              isExpanded: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFormField({required TextEditingController controller, required String label, required String hint, required IconData icon, TextInputType? keyboardType, bool isOptional = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label + (isOptional ? '' : ''), style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textDark)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: AppColors.primaryBlue.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              style: GoogleFonts.poppins(color: AppColors.textDark, fontSize: 15),
              decoration: InputDecoration(
                prefixIcon: Icon(icon, color: AppColors.primaryBlue),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5)),
                errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.errorRed, width: 1.5)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                hintText: hint,
                hintStyle: GoogleFonts.poppins(color: AppColors.textLight.withOpacity(0.7)),
              ),
              validator: (value) {
                if (!isOptional && (value == null || value.isEmpty)) {
                  return 'Campo obrigatório';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(bool isSubmitting) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        gradient: isSubmitting ? null : const LinearGradient(colors: [AppColors.primaryBlue, AppColors.secondaryBlue], begin: Alignment.centerLeft, end: Alignment.centerRight),
        borderRadius: BorderRadius.circular(12),
        boxShadow: isSubmitting ? null : [BoxShadow(color: AppColors.primaryBlue.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: ElevatedButton.icon(
        onPressed: isSubmitting ? null : _salvarEquipamento,
        icon: isSubmitting
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
            : const Icon(Icons.check_circle_outline, color: Colors.white),
        label: Text(
          isSubmitting ? 'Salvando...' : 'Salvar Equipamento',
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSubmitting ? Colors.grey : Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}