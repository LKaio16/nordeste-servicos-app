// lib/presentation/features/cliente/presentation/screens/novo_cliente_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

// Importar o provider e o estado
import '../../../../data/models/tipo_cliente.dart';
import '../../../shared/styles/app_colors.dart';
import '../../../../core/services/cep_service.dart';
import '../providers/cliente_list_provider.dart';
import '../providers/novo_cliente_provider.dart';
import '../providers/novo_cliente_state.dart';


class NovoClienteScreen extends ConsumerStatefulWidget {
  const NovoClienteScreen({super.key});

  @override
  ConsumerState<NovoClienteScreen> createState() => _NovoClienteScreenState();
}

class _NovoClienteScreenState extends ConsumerState<NovoClienteScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Controladores para os campos de texto
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

  // Estado para o tipo de cliente selecionado
  TipoCliente _tipoClienteSelecionado = TipoCliente.PESSOA_FISICA;
  bool _isLoadingCEP = false;

  // Definição das máscaras
  final _cpfMask = MaskTextInputFormatter(mask: '###.###.###-##', filter: {"#": RegExp(r'[0-9]')});
  final _cnpjMask = MaskTextInputFormatter(mask: '##.###.###/####-##', filter: {"#": RegExp(r'[0-9]')});
  final _phoneMask = MaskTextInputFormatter(mask: '(##) #####-####', filter: {"#": RegExp(r'[0-9]')});
  final _cepMask = MaskTextInputFormatter(mask: '#####-###', filter: {"#": RegExp(r'[0-9]')});


  // Estado para o estado selecionado (exemplo, precisa de uma lista real)
  String? _estadoSelecionado;
  final List<String> _estados = [
    'AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA', 'MT', 'MS',
    'MG', 'PA', 'PB', 'PR', 'PE', 'PI', 'RJ', 'RN', 'RS', 'RO', 'RR', 'SC',
    'SP', 'SE', 'TO'
  ]; // Exemplo de lista de estados

  // Adicionando animação para melhorar a experiência do usuário
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();

    // Configuração da animação
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.1, 1.0, curve: Curves.easeOut),
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    // Limpar os controladores
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
    _animationController.dispose();
    super.dispose();
  }

  void _salvarCliente() {
    // Limpa o foco para esconder o teclado
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      ref.read(novoClienteProvider.notifier).salvarCliente(
        tipoCliente: _tipoClienteSelecionado,
        nomeCompleto: _nomeController.text,
        cpfCnpj: _cpfCnpjController.text,
        email: _emailController.text,
        telefonePrincipal: _telPrincipalController.text,
        telefoneAdicional: _telAdicionalController.text.isNotEmpty ? _telAdicionalController.text : null,
        cep: _cepMask.getUnmaskedText(), // Remove máscara do CEP
        rua: _ruaController.text,
        numero: _numeroController.text,
        complemento: _complementoController.text.isNotEmpty ? _complementoController.text : null,
        bairro: _bairroController.text,
        cidade: _cidadeController.text,
        estado: _estadoSelecionado!, // Já validado pelo form
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Observar o estado do provider
    final state = ref.watch(novoClienteProvider);

    // Escutar mudanças no estado para feedback (Snackbar/Navegação)
    ref.listen<NovoClienteState>(novoClienteProvider, (previous, next) {
      // Mostrar erro se houver
      if (next.submissionError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              next.submissionError!,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: AppColors.errorRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: EdgeInsets.all(12),
          ),
        );
      }

      // Verificar se o envio foi concluído com sucesso (sem erro e não está mais enviando)
      if (previous?.isSubmitting == true && next.isSubmitting == false && next.submissionError == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Cliente salvo com sucesso!',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: AppColors.successGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: EdgeInsets.all(12),
          ),
        );
        // Retorna true para indicar sucesso e permitir que a tela anterior recarregue a lista
        Navigator.of(context).pop(true);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white
        ),
        title: Text(
          'Novo Cliente',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        actions: [
          // Mostrar indicador de carregamento ou botão de salvar
          if (state.isSubmitting)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.0,
                  ),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: TextButton.icon(
                // Desabilitar o botão durante o envio
                onPressed: state.isSubmitting ? null : _salvarCliente,
                icon: Icon(
                  Icons.check_circle_outline,
                  color: Colors.white,
                ),
                label: Text(
                  'Salvar',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          // Elementos decorativos de fundo
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: AppColors.accentBlue.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Conteúdo principal
          SafeArea(
            child: FadeTransition(
              opacity: _fadeInAnimation,
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 4,
                  shadowColor: AppColors.primaryBlue.withOpacity(0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFormHeader(),
                          const SizedBox(height: 24),
                          _buildTipoClienteSelector(),
                          const SizedBox(height: 32),
                          _buildSectionTitle('Informações Pessoais', Icons.person_outline),
                          _buildTextFormField(
                            controller: _nomeController,
                            label: 'Nome Completo',
                            icon: Icons.person_outline,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Campo obrigatório';
                              }
                              if (value.length < 3) {
                                return 'O nome deve ter no mínimo 3 caracteres';
                              }
                              // Regex para não permitir números e a maioria dos símbolos, mas permite acentos.
                              if (!RegExp(r"^[a-zA-Z\sà-úÀ-Ú]*$").hasMatch(value)) {
                                return 'Nome não pode conter números ou símbolos';
                              }
                              return null;
                            },
                          ),
                          _buildTextFormField(
                            controller: _cpfCnpjController,
                            label: _tipoClienteSelecionado == TipoCliente.PESSOA_FISICA ? 'CPF' : 'CNPJ',
                            icon: Icons.badge_outlined,
                            keyboardType: TextInputType.number,
                            inputFormatters: [_tipoClienteSelecionado == TipoCliente.PESSOA_FISICA ? _cpfMask : _cnpjMask],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Campo obrigatório';
                              }
                              final unmaskedText = (_tipoClienteSelecionado == TipoCliente.PESSOA_FISICA ? _cpfMask : _cnpjMask).getUnmaskedText();
                              if (_tipoClienteSelecionado == TipoCliente.PESSOA_FISICA && unmaskedText.length != 11) {
                                return 'CPF inválido';
                              }
                              if (_tipoClienteSelecionado == TipoCliente.PESSOA_JURIDICA && unmaskedText.length != 14) {
                                return 'CNPJ inválido';
                              }
                              return null;
                            },
                          ),
                          _buildTextFormField(
                            controller: _emailController,
                            label: 'Email',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                             validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Campo obrigatório';
                              }
                              // Regex para validação de email simples
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                return 'Digite um email válido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 32),
                          _buildSectionTitle('Contato', Icons.phone_outlined),
                          _buildTextFormField(
                            controller: _telPrincipalController,
                            label: 'Telefone Principal',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [_phoneMask],
                          ),
                          _buildTextFormField(
                            controller: _telAdicionalController,
                            label: 'Telefone Adicional (Opcional)',
                            icon: Icons.phone_android_outlined,
                            isOptional: true,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [_phoneMask],
                          ),
                          const SizedBox(height: 32),
                          _buildSectionTitle('Endereço', Icons.location_on_outlined),
                          _buildTextFormField(
                            controller: _cepController,
                            label: 'CEP',
                            icon: Icons.pin_outlined,
                            keyboardType: TextInputType.number,
                            inputFormatters: [_cepMask],
                            onChanged: (value) async {
                              // Busca endereço quando CEP estiver completo (8 dígitos)
                              final cepLimpo = _cepMask.getUnmaskedText();
                              if (cepLimpo.length == 8) {
                                setState(() => _isLoadingCEP = true);
                                try {
                                  final endereco = await CepService.buscarEnderecoPorCEP(cepLimpo);
                                  _ruaController.text = endereco['rua'] ?? '';
                                  _bairroController.text = endereco['bairro'] ?? '';
                                  _cidadeController.text = endereco['cidade'] ?? '';
                                  _estadoSelecionado = endereco['estado'];
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Endereço encontrado!', style: GoogleFonts.poppins()),
                                      backgroundColor: AppColors.successGreen,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      margin: EdgeInsets.all(12),
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('CEP não encontrado. Preencha o endereço manualmente.', style: GoogleFonts.poppins()),
                                      backgroundColor: AppColors.warningOrange,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      margin: EdgeInsets.all(12),
                                    ),
                                  );
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
                          _buildTextFormField(
                            controller: _ruaController,
                            label: 'Rua',
                            icon: Icons.signpost_outlined,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _buildTextFormField(
                                  controller: _numeroController,
                                  label: 'Número',
                                  icon: Icons.tag_outlined,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildTextFormField(
                                  controller: _complementoController,
                                  label: 'Complemento',
                                  icon: Icons.apartment_outlined,
                                  isOptional: true,
                                ),
                              ),
                            ],
                          ),
                          _buildTextFormField(
                            controller: _bairroController,
                            label: 'Bairro',
                            icon: Icons.domain_outlined,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _buildTextFormField(
                                  controller: _cidadeController,
                                  label: 'Cidade',
                                  icon: Icons.location_city_outlined,
                                  validator: (value) => (value == null || value.isEmpty) ? 'Campo obrigatório' : null,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildEstadoDropdown(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          _buildSaveButton(state.isSubmitting),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Overlay de loading durante o submit
          if (state.isSubmitting)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 50,
                          height: 50,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Salvando cliente...',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
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
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.person_add_alt_1,
                color: AppColors.primaryBlue,
                size: 24,
              ),
            ),
            SizedBox(width: 12),
            Text(
              'Cadastro de Cliente',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Text(
          'Preencha os dados do novo cliente',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppColors.textLight,
          ),
        ),
        SizedBox(height: 16),
        Divider(color: AppColors.dividerColor),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.primaryBlue,
              size: 20,
            ),
          ),
          SizedBox(width: 12),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipoClienteSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de Cliente',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _tipoClienteSelecionado = TipoCliente.PESSOA_FISICA;
                    });
                  },
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: _tipoClienteSelecionado == TipoCliente.PESSOA_FISICA
                          ? LinearGradient(
                        colors: [AppColors.primaryBlue, AppColors.secondaryBlue],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                          : null,
                      color: _tipoClienteSelecionado == TipoCliente.PESSOA_FISICA
                          ? null
                          : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.person,
                          color: _tipoClienteSelecionado == TipoCliente.PESSOA_FISICA
                              ? Colors.white
                              : AppColors.textLight,
                          size: 24,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Pessoa Física',
                          style: GoogleFonts.poppins(
                            color: _tipoClienteSelecionado == TipoCliente.PESSOA_FISICA
                                ? Colors.white
                                : AppColors.textDark,
                            fontWeight: _tipoClienteSelecionado == TipoCliente.PESSOA_FISICA
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _tipoClienteSelecionado = TipoCliente.PESSOA_JURIDICA;
                    });
                  },
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: _tipoClienteSelecionado == TipoCliente.PESSOA_JURIDICA
                          ? LinearGradient(
                        colors: [AppColors.primaryBlue, AppColors.secondaryBlue],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                          : null,
                      color: _tipoClienteSelecionado == TipoCliente.PESSOA_JURIDICA
                          ? null
                          : Colors.white,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.business,
                          color: _tipoClienteSelecionado == TipoCliente.PESSOA_JURIDICA
                              ? Colors.white
                              : AppColors.textLight,
                          size: 24,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Pessoa Jurídica',
                          style: GoogleFonts.poppins(
                            color: _tipoClienteSelecionado == TipoCliente.PESSOA_JURIDICA
                                ? Colors.white
                                : AppColors.textDark,
                            fontWeight: _tipoClienteSelecionado == TipoCliente.PESSOA_JURIDICA
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isOptional = false,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    Function(String)? onChanged,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label + (isOptional ? '' : '*'),
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              style: GoogleFonts.poppins(
                color: AppColors.textDark,
                fontSize: 15,
              ),
              onChanged: onChanged,
              decoration: InputDecoration(
                prefixIcon: Icon(
                  icon,
                  color: AppColors.primaryBlue,
                ),
                suffixIcon: suffixIcon,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.grey.shade200,
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.primaryBlue,
                    width: 1.5,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.errorRed,
                    width: 1.5,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.errorRed,
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                hintText: 'Digite ${label.toLowerCase()}',
                hintStyle: GoogleFonts.poppins(
                  color: AppColors.textLight.withOpacity(0.7),
                ),
              ),
              validator: validator ?? (value) {
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

  Widget _buildEstadoDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estado*',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: DropdownButtonFormField<String>(
              value: _estadoSelecionado,
              hint: Text(
                'Selecione',
                style: GoogleFonts.poppins(
                  color: AppColors.textLight.withOpacity(0.7),
                ),
              ),
              style: GoogleFonts.poppins(
                color: AppColors.textDark,
                fontSize: 15,
              ),
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.map_outlined,
                  color: AppColors.primaryBlue,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.grey.shade200,
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.primaryBlue,
                    width: 1.5,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.errorRed,
                    width: 1.5,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.errorRed,
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              items: _estados.map((String estado) {
                return DropdownMenuItem<String>(
                  value: estado,
                  child: Text(
                    estado,
                    style: GoogleFonts.poppins(),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _estadoSelecionado = newValue;
                });
              },
              icon: Icon(
                Icons.arrow_drop_down,
                color: AppColors.primaryBlue,
              ),
              dropdownColor: Colors.white,
              validator: (value) {
                if (value == null) {
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
        gradient: isSubmitting
            ? null
            : LinearGradient(
          colors: [AppColors.primaryBlue, AppColors.secondaryBlue],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: isSubmitting
            ? null
            : [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: isSubmitting ? null : _salvarCliente,
        icon: isSubmitting
            ? SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : Icon(Icons.check_circle_outline, color: Colors.white),
        label: Text(
          'Salvar Cliente',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSubmitting ? Colors.grey : Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
