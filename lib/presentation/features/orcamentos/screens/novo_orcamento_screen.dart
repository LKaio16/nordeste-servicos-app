import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../domain/entities/cliente.dart';
import '../../../../domain/entities/ordem_servico.dart';
import '../../../shared/styles/app_colors.dart';
import '../providers/novo_orcamento_provider.dart';
import '../providers/orcamento_list_provider.dart';

class NovoOrcamentoScreen extends ConsumerStatefulWidget {
  const NovoOrcamentoScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<NovoOrcamentoScreen> createState() => _NovoOrcamentoScreenState();
}

class _NovoOrcamentoScreenState extends ConsumerState<NovoOrcamentoScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores
  final _observacoesController = TextEditingController();

  // Variáveis de Estado da UI
  String? _selectedClienteId;
  String? _selectedOsId; // Novo: para guardar o ID da OS selecionada
  DateTime _dataValidade = DateTime.now().add(const Duration(days: 30));

  @override
  void dispose() {
    _observacoesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dataValidade,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _dataValidade) {
      setState(() {
        _dataValidade = picked;
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();

      final success = await ref.read(novoOrcamentoProvider.notifier).createOrcamento(
        clienteId: int.parse(_selectedClienteId!),
        dataValidade: _dataValidade,
        observacoesCondicoes: _observacoesController.text,
        osOrigemId: _selectedOsId != null ? int.parse(_selectedOsId!) : null, // Passando o ID da OS
      );

      if (success && mounted) {
        // Invalida a lista para que ela seja recarregada ao voltar
        ref.invalidate(orcamentoListProvider);
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Orçamento criado com sucesso!', style: GoogleFonts.poppins()),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(novoOrcamentoProvider);
    final notifier = ref.read(novoOrcamentoProvider.notifier);

    // Listener para mostrar erros
    ref.listen<NovoOrcamentoState>(novoOrcamentoProvider, (previous, next) {
      if (next.submissionError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.submissionError!), backgroundColor: AppColors.errorRed),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        title: Text('Novo Orçamento', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white)),
        backgroundColor: AppColors.primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton.icon(
              onPressed: state.isSubmitting ? null : _submitForm,
              icon: state.isSubmitting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.check_circle_outline, color: Colors.white),
              label: Text('Salvar', style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.errorMessage != null
          ? Center(child: Text(state.errorMessage!))
          : Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          physics: const BouncingScrollPhysics(),
          children: [
            _buildSectionCard(
              title: 'Informações Principais',
              icon: Icons.article_outlined,
              children: [
                _buildDropdownFormField(
                  label: 'Cliente*',
                  hint: 'Selecione o cliente',
                  value: _selectedClienteId,
                  items: state.clientes.map((Cliente c) => DropdownMenuItem(
                    value: c.id.toString(),
                    child: Text(c.nomeCompleto, overflow: TextOverflow.ellipsis),
                  )).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedClienteId = value;
                      _selectedOsId = null; // Limpa a OS selecionada ao trocar de cliente
                    });
                    if (value != null) {
                      notifier.fetchOrdensDeServico(int.parse(value));
                    }
                  },
                  icon: Icons.person_search_outlined,
                ),
                const SizedBox(height: 20),

                // --- DROPDOWN DINÂMICO DE ORDENS DE SERVIÇO ---
                if (state.isLoadingOs)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),

                if (!state.isLoadingOs && _selectedClienteId != null)
                  _buildDropdownFormField(
                    label: 'Ordem de Serviço de Origem (Opcional)',
                    hint: state.ordensDeServico.isEmpty ? 'Nenhuma OS encontrada' : 'Selecione a OS',
                    value: _selectedOsId,
                    items: state.ordensDeServico.map((OrdemServico os) {
                      return DropdownMenuItem(
                        value: os.id.toString(),
                        child: Text('#${os.numeroOS} - ${os.problemaRelatado}', overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedOsId = value),
                    icon: Icons.receipt_long_outlined,
                    isOptional: true, // Não será validado se estiver vazio
                  ),

                const SizedBox(height: 20),
                _buildDateField(
                  label: 'Data de Validade*',
                  selectedDate: _dataValidade,
                  onTap: () => _selectDate(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionCard(
              title: 'Observações e Condições',
              icon: Icons.edit_note_outlined,
              children: [
                _buildTextFormField(
                  controller: _observacoesController,
                  label: 'Adicione observações ou condições comerciais',
                  icon: Icons.notes,
                  maxLines: 5,
                  isOptional: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

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

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isOptional = false,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textDark),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: GoogleFonts.poppins(color: AppColors.textDark, fontSize: 15),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.primaryBlue),
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

  Widget _buildDropdownFormField({
    required String? value, required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged, required String label,
    required IconData icon, required String hint, bool isOptional = false
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textDark)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items,
          onChanged: onChanged,
          validator: (val) {
            if (!isOptional && (val == null || val.isEmpty)) {
              return 'Campo obrigatório';
            }
            return null;
          },
          style: GoogleFonts.poppins(color: AppColors.textDark, fontSize: 15),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.primaryBlue),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2)),
            hintText: hint,
            hintStyle: GoogleFonts.poppins(color: AppColors.textLight.withOpacity(0.7)),
          ),
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.primaryBlue),
          dropdownColor: Colors.white,
          isExpanded: true,
        ),
      ],
    );
  }

  Widget _buildDateField({required String label, required DateTime selectedDate, required VoidCallback onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textDark)),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today, color: AppColors.primaryBlue),
                    const SizedBox(width: 12),
                    Text(
                      DateFormat('dd/MM/yyyy').format(selectedDate),
                      style: GoogleFonts.poppins(fontSize: 16, color: AppColors.textDark),
                    ),
                  ],
                ),
                const Icon(Icons.arrow_drop_down, color: AppColors.textLight),
              ],
            ),
          ),
        ),
      ],
    );
  }
}