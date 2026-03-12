import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../domain/entities/fornecedor.dart';
import '../../../shared/styles/app_colors.dart';
import '../../../shared/providers/repository_providers.dart';
import '../providers/fornecedor_list_provider.dart';

class NovoFornecedorScreen extends ConsumerStatefulWidget {
  const NovoFornecedorScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<NovoFornecedorScreen> createState() => _NovoFornecedorScreenState();
}

class _NovoFornecedorScreenState extends ConsumerState<NovoFornecedorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _observacoesController = TextEditingController();

  String _estadoSelecionado = 'PE';
  String _statusSelecionado = 'ATIVO';
  bool _isLoading = false;

  static const _estados = [
    'AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA', 'MT', 'MS',
    'MG', 'PA', 'PB', 'PR', 'PE', 'PI', 'RJ', 'RN', 'RS', 'RO', 'RR', 'SC',
    'SP', 'SE', 'TO'
  ];

  @override
  void dispose() {
    _nomeController.dispose();
    _cnpjController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _enderecoController.dispose();
    _cidadeController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(fornecedorRepositoryProvider);
      await repo.createFornecedor(Fornecedor(
        nome: _nomeController.text.trim(),
        cnpj: _cnpjController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        telefone: _telefoneController.text.trim().isEmpty ? null : _telefoneController.text.trim(),
        endereco: _enderecoController.text.trim(),
        cidade: _cidadeController.text.trim(),
        estado: _estadoSelecionado,
        status: _statusSelecionado,
        observacoes: _observacoesController.text.trim().isEmpty ? null : _observacoesController.text.trim(),
      ));
      ref.read(fornecedorListProvider.notifier).refreshFornecedores();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fornecedor cadastrado com sucesso!', style: GoogleFonts.poppins()), backgroundColor: AppColors.successGreen),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: ${e.toString()}', style: GoogleFonts.poppins()), backgroundColor: AppColors.errorRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        title: Text('Novo Fornecedor', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white)),
        backgroundColor: AppColors.primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.primaryBlue, AppColors.secondaryBlue]),
          ),
        ),
        actions: [
          if (_isLoading)
            const Padding(padding: EdgeInsets.only(right: 16), child: Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))))
          else
            TextButton.icon(
              onPressed: _salvar,
              icon: const Icon(Icons.check_circle_outline, color: Colors.white),
              label: Text('Salvar', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _campo('Nome *', Icons.business, _nomeController, validator: (v) => (v == null || v.trim().isEmpty) ? 'Obrigatório' : null),
                  _campo('CNPJ *', Icons.badge, _cnpjController, validator: (v) => (v == null || v.trim().isEmpty) ? 'Obrigatório' : null),
                  _campo('Email', Icons.email_outlined, _emailController, keyboardType: TextInputType.emailAddress),
                  _campo('Telefone', Icons.phone_outlined, _telefoneController, keyboardType: TextInputType.phone),
                  _campo('Endereço *', Icons.location_on_outlined, _enderecoController, validator: (v) => (v == null || v.trim().isEmpty) ? 'Obrigatório' : null),
                  _campo('Cidade *', Icons.location_city_outlined, _cidadeController, validator: (v) => (v == null || v.trim().isEmpty) ? 'Obrigatório' : null),
                  DropdownButtonFormField<String>(
                    value: _estadoSelecionado,
                    decoration: _inputDecoration('Estado *', Icons.map_outlined),
                    items: _estados.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) => setState(() => _estadoSelecionado = v ?? 'PE'),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _statusSelecionado,
                    decoration: _inputDecoration('Status *', Icons.toggle_on_outlined),
                    items: const [
                      DropdownMenuItem(value: 'ATIVO', child: Text('Ativo')),
                      DropdownMenuItem(value: 'INATIVO', child: Text('Inativo')),
                    ],
                    onChanged: (v) => setState(() => _statusSelecionado = v ?? 'ATIVO'),
                  ),
                  _campo('Observações', Icons.notes, _observacoesController, maxLines: 3),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _salvar,
                      icon: _isLoading ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.save),
                      label: Text(_isLoading ? 'Salvando...' : 'Salvar', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _campo(String label, IconData icon, TextEditingController controller, {String? Function(String?)? validator, TextInputType? keyboardType, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: _inputDecoration(label, icon),
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.primaryBlue, size: 22),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }
}
