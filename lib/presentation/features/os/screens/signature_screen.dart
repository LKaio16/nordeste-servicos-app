import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nordeste_servicos_app/domain/entities/assinatura_os.dart';
import 'package:signature/signature.dart';

import '../../../shared/styles/app_colors.dart';
import '../providers/assinatura_os_provider.dart';

class SignatureScreen extends ConsumerStatefulWidget {
  final int osId;
  const SignatureScreen({required this.osId, Key? key}) : super(key: key);

  @override
  ConsumerState<SignatureScreen> createState() => _SignatureScreenState();
}

class _SignatureScreenState extends ConsumerState<SignatureScreen>
    with TickerProviderStateMixin {
  late final SignatureController _clienteController;
  late final SignatureController _tecnicoController;
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  final _clienteNomeController = TextEditingController();
  final _clienteDocController = TextEditingController();
  final _tecnicoNomeController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _clienteSignatureEmpty = true;
  bool _tecnicoSignatureEmpty = true;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _clienteController = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );

    _tecnicoController = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );

    // Listeners para detectar mudanças nas assinaturas
    _clienteController.addListener(() {
      setState(() {
        _clienteSignatureEmpty = _clienteController.isEmpty;
      });
    });

    _tecnicoController.addListener(() {
      setState(() {
        _tecnicoSignatureEmpty = _tecnicoController.isEmpty;
      });
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _clienteController.dispose();
    _tecnicoController.dispose();
    _clienteNomeController.dispose();
    _clienteDocController.dispose();
    _tecnicoNomeController.dispose();
    super.dispose();
  }

  void _clearSignature(SignatureController controller) {
    controller.clear();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nome é obrigatório';
    }
    if (value.trim().length < 2) {
      return 'Nome deve ter pelo menos 2 caracteres';
    }
    return null;
  }

  String? _validateDocument(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Documento é obrigatório';
    }
    // Remove caracteres não numéricos
    final cleanValue = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanValue.length < 10) {
      return 'Documento deve ter pelo menos 10 dígitos';
    }
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      _showErrorSnackBar('Por favor, preencha todos os campos obrigatórios.');
      return;
    }

    if (_clienteSignatureEmpty) {
      _showErrorSnackBar('A assinatura do cliente é obrigatória.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      Uint8List? clienteSignatureBytes;
      Uint8List? tecnicoSignatureBytes;

      if (!_clienteController.isEmpty) {
        clienteSignatureBytes = await _clienteController.toPngBytes();
      }
      if (!_tecnicoController.isEmpty) {
        tecnicoSignatureBytes = await _tecnicoController.toPngBytes();
      }

      final assinatura = AssinaturaOS(
        ordemServicoId: widget.osId,
        assinaturaClienteBase64: clienteSignatureBytes != null
            ? base64Encode(clienteSignatureBytes)
            : null,
        nomeClienteResponsavel: _clienteNomeController.text.trim(),
        documentoClienteResponsavel: _clienteDocController.text.trim(),
        assinaturaTecnicoBase64: tecnicoSignatureBytes != null
            ? base64Encode(tecnicoSignatureBytes)
            : null,
        nomeTecnicoResponsavel: _tecnicoNomeController.text.trim(),
      );

      final success = await ref
          .read(assinaturaProvider(widget.osId).notifier)
          .saveAssinatura(assinatura);

      if (success && mounted) {
        _showSuccessSnackBar('Assinaturas salvas com sucesso!');
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      _showErrorSnackBar('Erro ao salvar assinaturas: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.errorRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        title: Text(
          "Coletar Assinaturas",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryBlue,
                AppColors.secondaryBlue,
              ],
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderSection(),
                const SizedBox(height: 24),
                _buildSignatureCard(
                  title: "Assinatura do Cliente",
                  subtitle: "Responsável pela solicitação do serviço",
                  icon: Icons.person_outline,
                  controller: _clienteController,
                  nameController: _clienteNomeController,
                  docController: _clienteDocController,
                  isEmpty: _clienteSignatureEmpty,
                  isRequired: true,
                ),
                const SizedBox(height: 24),
                _buildSignatureCard(
                  title: "Assinatura do Técnico",
                  subtitle: "Responsável pela execução do serviço",
                  icon: Icons.engineering_outlined,
                  controller: _tecnicoController,
                  nameController: _tecnicoNomeController,
                  docController: null,
                  isEmpty: _tecnicoSignatureEmpty,
                  isRequired: false,
                ),
                const SizedBox(height: 32),
                _buildActionButtons(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
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
                child: Icon(
                  Icons.draw_outlined,
                  color: AppColors.primaryBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Coleta de Assinaturas",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "OS #${widget.osId}",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.primaryBlue.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.primaryBlue,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "A assinatura do cliente é obrigatória para finalizar o atendimento.",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignatureCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required SignatureController controller,
    required TextEditingController nameController,
    required TextEditingController? docController,
    required bool isEmpty,
    required bool isRequired,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header da seção
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
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
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                          if (isRequired) ...[
                            const SizedBox(width: 4),
                            Text(
                              "*",
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.errorRed,
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Campos de texto
            _buildTextField(
              controller: nameController,
              label: "Nome do Responsável",
              icon: Icons.person_outline,
              validator: _validateName,
              isRequired: true,
            ),

            if (docController != null) ...[
              const SizedBox(height: 16),
              _buildTextField(
                controller: docController,
                label: "Documento (RG/CPF)",
                icon: Icons.badge_outlined,
                validator: _validateDocument,
                isRequired: true,
                keyboardType: TextInputType.number,
              ),
            ],

            const SizedBox(height: 20),

            // Área de assinatura
            _buildSignatureArea(controller, isEmpty),

            const SizedBox(height: 16),

            // Botão limpar
            _buildClearButton(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    required bool isRequired,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(
        fontSize: 14,
        color: AppColors.textDark,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(
          color: AppColors.textLight,
        ),
        prefixIcon: Icon(
          icon,
          color: AppColors.primaryBlue,
          size: 20,
        ),
        suffixIcon: isRequired
            ? Icon(
          Icons.star,
          color: AppColors.errorRed,
          size: 12,
        )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.dividerColor,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.dividerColor.withOpacity(0.5),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.primaryBlue,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.errorRed,
            width: 1,
          ),
        ),
        filled: true,
        fillColor: AppColors.backgroundGray.withOpacity(0.3),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  Widget _buildSignatureArea(SignatureController controller, bool isEmpty) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: isEmpty
            ? AppColors.backgroundGray.withOpacity(0.3)
            : AppColors.successGreen.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isEmpty
              ? AppColors.dividerColor.withOpacity(0.5)
              : AppColors.successGreen.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            Signature(
              controller: controller,
              height: 200,
              backgroundColor: Colors.transparent,
            ),
            if (isEmpty)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.draw_outlined,
                      size: 32,
                      color: AppColors.textLight.withOpacity(0.5),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Toque aqui para assinar",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.textLight.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            if (!isEmpty)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.successGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildClearButton(SignatureController controller) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _clearSignature(controller),
        icon: Icon(
          Icons.clear_outlined,
          size: 18,
          color: AppColors.primaryBlue,
        ),
        label: Text(
          "Limpar Assinatura",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppColors.primaryBlue,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: AppColors.primaryBlue,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _save,
            icon: _isLoading
                ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
                : Icon(
              Icons.save_outlined,
              size: 20,
              color: Colors.white,
            ),
            label: Text(
              _isLoading ? "Salvando..." : "Salvar Assinaturas",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 3,
              shadowColor: AppColors.primaryBlue.withOpacity(0.3),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: TextButton.icon(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.close_outlined,
              size: 18,
              color: AppColors.textLight,
            ),
            label: Text(
              "Cancelar",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                color: AppColors.textLight,
              ),
            ),
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

