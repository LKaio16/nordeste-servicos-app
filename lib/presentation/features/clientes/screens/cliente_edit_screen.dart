import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

import 'package:nordeste_servicos_app/data/models/tipo_cliente.dart';
import 'package:nordeste_servicos_app/domain/entities/cliente.dart';
import 'package:nordeste_servicos_app/presentation/shared/styles/app_colors.dart';
import 'package:nordeste_servicos_app/core/services/cep_service.dart';
import '../providers/cliente_detail_provider.dart';
import '../providers/cliente_edit_provider.dart';
import '../providers/cliente_list_provider.dart';

class ClienteEditScreen extends ConsumerStatefulWidget {
  final int clienteId;
  const ClienteEditScreen({Key? key, required this.clienteId}) : super(key: key);

  @override
  ConsumerState<ClienteEditScreen> createState() => _ClienteEditScreenState();
}

class _ClienteEditScreenState extends ConsumerState<ClienteEditScreen> {
  final _formKey = GlobalKey<FormState>();
  // Controllers
  final _nomeController = TextEditingController();
  final _cpfCnpjController = TextEditingController();
  final _emailController = TextEditingController();
  final _telPrincipalController = TextEditingController();
  final _telAdicionalController = TextEditingController();
  final _cepController = TextEditingController();
  final _ruaController = TextEditingController();
  final _numeroController = TextEditingController();
  final _complementoController = TextEditingController();
  final _bairroController = TextEditingController();
  final _cidadeController = TextEditingController();

  // State variables
  TipoCliente? _tipoClienteSelecionado;
  String? _estadoSelecionado;
  bool _isLoadingCEP = false;

  final List<String> _estados = ['AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA', 'MT', 'MS', 'MG', 'PA', 'PB', 'PR', 'PE', 'PI', 'RJ', 'RN', 'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO'];
  
  // Máscara manual para CEP
  String _formatCEP(String value) {
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.length <= 5) {
      return digitsOnly;
    }
    return '${digitsOnly.substring(0, 5)}-${digitsOnly.substring(5, digitsOnly.length > 8 ? 8 : digitsOnly.length)}';
  }
  
  String _getUnmaskedCEP(String value) {
    return value.replaceAll(RegExp(r'[^\d]'), '');
  }

  @override
  void initState() {
    super.initState();
    // Apenas dispara o carregamento dos dados iniciais
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(clienteEditProvider(widget.clienteId).notifier).loadCliente(widget.clienteId);
    });
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfCnpjController.dispose();
    _emailController.dispose();
    _telPrincipalController.dispose();
    _telAdicionalController.dispose();
    _cepController.dispose();
    _ruaController.dispose();
    _numeroController.dispose();
    _complementoController.dispose();
    _bairroController.dispose();
    _cidadeController.dispose();
    super.dispose();
  }

  // Este método agora só preenche os controllers, sem flags de controle.
  void _initializeFormFields(Cliente cliente) {
    _nomeController.text = cliente.nomeCompleto;
    _cpfCnpjController.text = cliente.cpfCnpj;
    _emailController.text = cliente.email;
    _telPrincipalController.text = cliente.telefonePrincipal;
    _telAdicionalController.text = cliente.telefoneAdicional ?? '';
    // Aplica máscara no CEP
    _cepController.text = _formatCEP(cliente.cep);
    _ruaController.text = cliente.rua;
    _numeroController.text = cliente.numero;
    _complementoController.text = cliente.complemento ?? '';
    _bairroController.text = cliente.bairro;
    _cidadeController.text = cliente.cidade;
    // Usamos setState aqui para garantir que a UI reflita a mudança nos dropdowns
    setState(() {
      _estadoSelecionado = cliente.estado;
      _tipoClienteSelecionado = cliente.tipoCliente;
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      final success = await ref.read(clienteEditProvider(widget.clienteId).notifier).updateCliente(
        id: widget.clienteId,
        tipoCliente: _tipoClienteSelecionado!,
        nomeCompleto: _nomeController.text,
        cpfCnpj: _cpfCnpjController.text,
        email: _emailController.text,
        telefonePrincipal: _telPrincipalController.text,
        telefoneAdicional: _telAdicionalController.text,
        cep: _getUnmaskedCEP(_cepController.text), // Remove máscara do CEP
        rua: _ruaController.text,
        numero: _numeroController.text,
        complemento: _complementoController.text,
        bairro: _bairroController.text,
        cidade: _cidadeController.text,
        estado: _estadoSelecionado!,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cliente atualizado com sucesso!'), backgroundColor: AppColors.successGreen));
        ref.invalidate(clienteListProvider);
        ref.invalidate(clienteDetailProvider(widget.clienteId));
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(clienteEditProvider(widget.clienteId));

    // <<< AJUSTE NA LÓGICA DO LISTENER >>>
    ref.listen<ClienteEditState>(clienteEditProvider(widget.clienteId), (previous, next) {
      // Se os dados do cliente mudarem (seja no carregamento inicial ou num refresh), atualiza o form.
      if (next.originalCliente != previous?.originalCliente && next.originalCliente != null) {
        _initializeFormFields(next.originalCliente!);
      }
      // Se houver um erro de submissão, mostra o snackbar.
      if (next.submissionError != null && next.submissionError != previous?.submissionError) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.submissionError!), backgroundColor: AppColors.errorRed));
      }
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        title: Text(state.originalCliente?.nomeCompleto ?? 'Editar Cliente', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white)),
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppColors.primaryBlue, AppColors.secondaryBlue]))),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.of(context).pop()),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ElevatedButton.icon(
              onPressed: state.isLoading || state.isSubmitting ? null : _submitForm,
              icon: state.isSubmitting ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save, size: 18),
              label: Text('Salvar', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, foregroundColor: AppColors.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
            ),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.errorMessage != null
          ? Center(child: Text(state.errorMessage!))
          : _buildFormContent(),
    );
  }

  Widget _buildFormContent() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        physics: const BouncingScrollPhysics(),
        children: [
          _buildSectionCard(
            title: 'Informações de Cadastro',
            icon: Icons.person_outline,
            children: [
              _buildTextFormField(controller: _nomeController, label: 'Nome Completo*', icon: Icons.badge_outlined),
              const SizedBox(height: 20),
              _buildTextFormField(controller: _cpfCnpjController, label: 'CPF/CNPJ*', icon: Icons.badge_outlined),
              const SizedBox(height: 20),
              _buildTextFormField(controller: _emailController, label: 'E-mail*', icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
            ],
          ),
          const SizedBox(height: 24),
          _buildSectionCard(
            title: 'Contato e Endereço',
            icon: Icons.contact_page_outlined,
            children: [
              _buildTextFormField(controller: _telPrincipalController, label: 'Telefone Principal*', icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
              const SizedBox(height: 20),
              _buildTextFormField(controller: _telAdicionalController, label: 'Telefone Adicional', icon: Icons.phone_android_outlined, keyboardType: TextInputType.phone, isOptional: true),
              const SizedBox(height: 20),
              _buildTextFormField(
                controller: _cepController,
                label: 'CEP*',
                icon: Icons.pin_outlined,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(9),
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    if (newValue.text.isEmpty) {
                      return newValue;
                    }
                    final formatted = _formatCEP(newValue.text);
                    return TextEditingValue(
                      text: formatted,
                      selection: TextSelection.collapsed(offset: formatted.length),
                    );
                  }),
                ],
                onChanged: (value) async {
                  // Busca endereço quando CEP estiver completo (8 dígitos)
                  final cepLimpo = _getUnmaskedCEP(value);
                  if (cepLimpo.length == 8) {
                    setState(() => _isLoadingCEP = true);
                    try {
                      final endereco = await CepService.buscarEnderecoPorCEP(cepLimpo);
                      _ruaController.text = endereco['rua'] ?? '';
                      _bairroController.text = endereco['bairro'] ?? '';
                      _cidadeController.text = endereco['cidade'] ?? '';
                      setState(() {
                        _estadoSelecionado = endereco['estado'];
                      });
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Endereço encontrado!', style: GoogleFonts.poppins()),
                            backgroundColor: AppColors.successGreen,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            margin: EdgeInsets.all(12),
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('CEP não encontrado. Preencha o endereço manualmente.', style: GoogleFonts.poppins()),
                            backgroundColor: AppColors.warningOrange,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            margin: EdgeInsets.all(12),
                          ),
                        );
                      }
                    } finally {
                      setState(() => _isLoadingCEP = false);
                    }
                  }
                },
                suffixIcon: _isLoadingCEP ? Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                    ),
                  ),
                ) : null,
              ),
              const SizedBox(height: 20),
              _buildTextFormField(controller: _ruaController, label: 'Rua*', icon: Icons.signpost_outlined),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildTextFormField(controller: _numeroController, label: 'Número*', icon: Icons.tag_outlined, keyboardType: TextInputType.number)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextFormField(controller: _complementoController, label: 'Complemento', icon: Icons.apartment_outlined, isOptional: true)),
                ],
              ),
              const SizedBox(height: 20),
              _buildTextFormField(controller: _bairroController, label: 'Bairro*', icon: Icons.domain_outlined),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildTextFormField(controller: _cidadeController, label: 'Cidade*', icon: Icons.location_city_outlined)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildEstadoDropdown()),
                ],
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

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    bool isOptional = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    Function(String)? onChanged,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textDark)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: GoogleFonts.poppins(color: AppColors.textDark, fontSize: 15),
          onChanged: onChanged,
          decoration: InputDecoration(
            prefixIcon: icon != null ? Icon(icon, color: AppColors.primaryBlue) : null,
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.errorRed, width: 1.5)),
            focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.errorRed, width: 2)),
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

  Widget _buildEstadoDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Estado*', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textDark)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _estadoSelecionado,
          hint: Text('Selecione', style: GoogleFonts.poppins(color: AppColors.textLight.withOpacity(0.7))),
          style: GoogleFonts.poppins(color: AppColors.textDark, fontSize: 15),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.map_outlined, color: AppColors.primaryBlue),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2)),
          ),
          items: _estados.map((String estado) {
            return DropdownMenuItem<String>(value: estado, child: Text(estado, style: GoogleFonts.poppins()));
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _estadoSelecionado = newValue;
            });
          },
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.primaryBlue),
          dropdownColor: Colors.white,
          validator: (value) => value == null ? 'Campo obrigatório' : null,
        ),
      ],
    );
  }
}
