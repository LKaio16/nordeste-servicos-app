import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../domain/entities/cliente.dart';
import '../../../../domain/entities/fornecedor.dart';
import '../../../../domain/entities/nota_fiscal.dart';
import '../../../shared/styles/app_colors.dart';
import '../../../shared/providers/repository_providers.dart';
import '../providers/nota_fiscal_list_provider.dart';

class NovaNotaFiscalScreen extends ConsumerStatefulWidget {
  const NovaNotaFiscalScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<NovaNotaFiscalScreen> createState() => _NovaNotaFiscalScreenState();
}

class _NovaNotaFiscalScreenState extends ConsumerState<NovaNotaFiscalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _numeroNotaController = TextEditingController();
  final _valorTotalController = TextEditingController();
  final _nomeEmitenteController = TextEditingController();
  final _cnpjEmitenteController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _observacoesController = TextEditingController();

  String _tipoSelecionado = 'ENTRADA';
  DateTime _dataEmissao = DateTime.now();
  int? _fornecedorId;
  int? _clienteId;
  String? _formaPagamento;
  bool _isLoading = false;
  List<Fornecedor> _fornecedores = [];
  List<Cliente> _clientes = [];
  bool _carregandoListas = true;

  @override
  void initState() {
    super.initState();
    _carregarListas();
  }

  Future<void> _carregarListas() async {
    try {
      final fornecedores = await ref.read(fornecedorRepositoryProvider).getFornecedores();
      final clientes = await ref.read(clienteRepositoryProvider).getClientes();
      if (mounted) setState(() {
        _fornecedores = fornecedores;
        _clientes = clientes;
        _carregandoListas = false;
      });
    } catch (_) {
      if (mounted) setState(() => _carregandoListas = false);
    }
  }

  @override
  void dispose() {
    _numeroNotaController.dispose();
    _valorTotalController.dispose();
    _nomeEmitenteController.dispose();
    _cnpjEmitenteController.dispose();
    _descricaoController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  Future<void> _escolherData() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dataEmissao,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _dataEmissao = picked);
  }

  Future<void> _salvar() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final valor = double.tryParse(_valorTotalController.text.replaceFirst(',', '.'));
    if (valor == null || valor < 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Valor inválido', style: GoogleFonts.poppins()), backgroundColor: AppColors.errorRed));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(notaFiscalRepositoryProvider);
      await repo.createNotaFiscal(NotaFiscal(
        tipo: _tipoSelecionado,
        fornecedorId: _fornecedorId,
        clienteId: _clienteId,
        nomeEmitente: _nomeEmitenteController.text.trim().isEmpty ? null : _nomeEmitenteController.text.trim(),
        cnpjEmitente: _cnpjEmitenteController.text.trim().isEmpty ? null : _cnpjEmitenteController.text.trim(),
        dataEmissao: _dataEmissao,
        numeroNota: _numeroNotaController.text.trim(),
        valorTotal: valor,
        formaPagamento: _formaPagamento,
        descricao: _descricaoController.text.trim().isEmpty ? null : _descricaoController.text.trim(),
        observacoes: _observacoesController.text.trim().isEmpty ? null : _observacoesController.text.trim(),
      ));
      ref.read(notaFiscalListProvider.notifier).refreshNotasFiscais();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Nota fiscal cadastrada com sucesso!', style: GoogleFonts.poppins()), backgroundColor: AppColors.successGreen),
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
        title: Text('Nova Nota Fiscal', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white)),
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
      body: _carregandoListas
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
          : SingleChildScrollView(
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
                        DropdownButtonFormField<String>(
                          value: _tipoSelecionado,
                          decoration: _dec('Tipo *', Icons.description),
                          items: const [
                            DropdownMenuItem(value: 'ENTRADA', child: Text('Entrada')),
                            DropdownMenuItem(value: 'SAIDA', child: Text('Saída')),
                          ],
                          onChanged: (v) => setState(() => _tipoSelecionado = v ?? 'ENTRADA'),
                        ),
                        const SizedBox(height: 16),
                        if (_fornecedores.isNotEmpty)
                          DropdownButtonFormField<int?>(
                            value: _fornecedorId,
                            decoration: _dec('Fornecedor', Icons.business),
                            items: [const DropdownMenuItem<int?>(value: null, child: Text('Nenhum'))] +
                                _fornecedores.map((f) => DropdownMenuItem<int?>(value: f.id, child: Text(f.nome))).toList(),
                            onChanged: (v) => setState(() => _fornecedorId = v),
                          ),
                        if (_clientes.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          DropdownButtonFormField<int?>(
                            value: _clienteId,
                            decoration: _dec('Cliente', Icons.person),
                            items: [const DropdownMenuItem<int?>(value: null, child: Text('Nenhum'))] +
                                _clientes.map((c) => DropdownMenuItem<int?>(value: c.id, child: Text(c.nomeCompleto))).toList(),
                            onChanged: (v) => setState(() => _clienteId = v),
                          ),
                        ],
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nomeEmitenteController,
                          decoration: _dec('Nome emitente', Icons.badge),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _cnpjEmitenteController,
                          decoration: _dec('CNPJ emitente', Icons.numbers),
                        ),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: _escolherData,
                          child: InputDecorator(
                            decoration: _dec('Data de emissão *', Icons.calendar_today),
                            child: Text(DateFormat('dd/MM/yyyy').format(_dataEmissao)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _numeroNotaController,
                          decoration: _dec('Número da nota *', Icons.tag),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Obrigatório' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _valorTotalController,
                          decoration: _dec('Valor total (R\$) *', Icons.attach_money),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Obrigatório';
                            final n = double.tryParse(v.replaceFirst(',', '.'));
                            if (n == null || n < 0) return 'Valor inválido';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String?>(
                          value: _formaPagamento,
                          decoration: _dec('Forma de pagamento', Icons.payment),
                          items: const [
                            DropdownMenuItem<String?>(value: null, child: Text('Não informado')),
                            DropdownMenuItem(value: 'BOLETO', child: Text('Boleto')),
                            DropdownMenuItem(value: 'CARTAO', child: Text('Cartão')),
                            DropdownMenuItem(value: 'PIX', child: Text('PIX')),
                            DropdownMenuItem(value: 'TRANSFERENCIA', child: Text('Transferência')),
                          ],
                          onChanged: (v) => setState(() => _formaPagamento = v),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descricaoController,
                          decoration: _dec('Descrição', Icons.notes),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _observacoesController,
                          decoration: _dec('Observações', Icons.notes),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _salvar,
                            icon: _isLoading ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.save),
                            label: Text(_isLoading ? 'Salvando...' : 'Salvar', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
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

  InputDecoration _dec(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.primaryBlue, size: 22),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }
}
