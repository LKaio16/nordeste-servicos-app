// lib/presentation/features/tecnicos/presentation/screens/novo_tecnico_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart'; // Importando Google Fonts para fontes modernas

// Importar o provider e o estado
import '../providers/novo_tecnico_provider.dart';

import '../providers/novo_tecnico_state.dart'; // Ajuste o caminho se necessário

// Definição de cores modernizadas (Mantida da versão anterior)
class AppColors {
  static const Color primaryBlue = Color(0xFF1A73E8);
  static const Color secondaryBlue = Color(0xFF4285F4);
  static const Color accentBlue = Color(0xFF8AB4F8);
  static const Color darkBlue = Color(0xFF0D47A1);
  static const Color successGreen = Color(0xFF34A853);
  static const Color warningOrange = Color(0xFFFFA000);
  static const Color errorRed = Color(0xFFEA4335);
  static const Color backgroundGray = Color(0xFFF8F9FA);
  static const Color cardBackground = Colors.white;
  static const Color textDark = Color(0xFF202124);
  static const Color textLight = Color(0xFF5F6368);
  static const Color dividerColor = Color(0xFFEEEEEE);
}

class NovoTecnicoScreen extends ConsumerStatefulWidget {
  const NovoTecnicoScreen({super.key});

  @override
  ConsumerState<NovoTecnicoScreen> createState() => _NovoTecnicoScreenState();
}

class _NovoTecnicoScreenState extends ConsumerState<NovoTecnicoScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Controladores para os campos de texto - AJUSTADOS AO MODELO USUARIO
  final _nomeController = TextEditingController();
  final _crachaController = TextEditingController(); // NOVO
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController(); // NOVO

  // Adicionando animação (Mantida da versão anterior)
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  // Estado para visibilidade da senha
  bool _isSenhaObscured = true;

  @override
  void initState() {
    super.initState();
    // Configuração da animação (Mantida da versão anterior)
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
    // Limpar os controladores - AJUSTADOS
    _nomeController.dispose();
    _crachaController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _salvarTecnico() {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      // Chamar o provider com os campos corretos - AJUSTADO
      // Assumindo que o perfil 'TECNICO' é definido no provider/backend
      ref.read(novoTecnicoProvider.notifier).createUsuario(
        nome: _nomeController.text,
        cracha: _crachaController.text,
        email: _emailController.text,
        senha: _senhaController.text,
        // perfil: 'TECNICO', // O perfil deve ser tratado no provider ou backend
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(novoTecnicoProvider);

    // Listener para feedback (Mantido, mas precisa que o provider/state sejam ajustados)
    ref.listen<NovoTecnicoState>(novoTecnicoProvider, (previous, next) {
      if (next.submissionError != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.submissionError!, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
              backgroundColor: AppColors.errorRed,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              margin: EdgeInsets.all(12),
            ),
          );
        }
      }

      if (previous?.isSubmitting == true && next.isSubmitting == false && next.submissionError == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Técnico salvo com sucesso!', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
              backgroundColor: AppColors.successGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              margin: EdgeInsets.all(12),
            ),
          );
          Navigator.of(context).pop();
        }
      }
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        title: Text('Novo Técnico', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white)),
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        actions: [
          if (state.isSubmitting)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.0))),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: TextButton.icon(
                onPressed: state.isSubmitting ? null : _salvarTecnico,
                icon: Icon(Icons.check_circle_outline, color: Colors.white),
                label: Text('Salvar', style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          // Elementos decorativos (Mantidos)
          Positioned(top: -50, right: -50, child: Container(width: 150, height: 150, decoration: BoxDecoration(color: AppColors.accentBlue.withOpacity(0.2), shape: BoxShape.circle))),
          Positioned(bottom: -80, left: -80, child: Container(width: 200, height: 200, decoration: BoxDecoration(color: AppColors.primaryBlue.withOpacity(0.15), shape: BoxShape.circle))),

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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFormHeader("Cadastro de Técnico"),
                          const SizedBox(height: 24),

                          // --- CAMPOS AJUSTADOS AO MODELO USUARIO ---
                          _buildSectionTitle('Informações do Técnico', Icons.person_outline),
                          _buildTextFormField(
                            controller: _nomeController,
                            label: 'Nome Completo',
                            icon: Icons.person_outline,
                          ),
                          _buildTextFormField(
                            controller: _crachaController,
                            label: 'Crachá',
                            icon: Icons.badge_outlined, // Ícone para crachá
                          ),
                          _buildTextFormField(
                            controller: _emailController,
                            label: 'Email',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          _buildTextFormField(
                            controller: _senhaController,
                            label: 'Senha',
                            icon: Icons.lock_outline,
                            obscureText: _isSenhaObscured,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isSenhaObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: AppColors.textLight,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isSenhaObscured = !_isSenhaObscured;
                                });
                              },
                            ),
                          ),
                          // --- FIM DOS CAMPOS AJUSTADOS ---

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

          // Overlay de loading (Mantido)
          if (state.isSubmitting)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(width: 50, height: 50, child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue))),
                        SizedBox(height: 16),
                        Text('Salvando técnico...', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500)),
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

  // --- WIDGETS AUXILIARES (Mantidos e _buildTextFormField ajustado) ---

  Widget _buildFormHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.person_add_alt_1, color: AppColors.primaryBlue, size: 24),
            ),
            SizedBox(width: 12),
            Text(title, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          ],
        ),
        SizedBox(height: 8),
        Text('Preencha os dados do novo técnico', style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textLight)),
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
            decoration: BoxDecoration(color: AppColors.primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: AppColors.primaryBlue, size: 20),
          ),
          SizedBox(width: 12),
          Text(title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isOptional = false,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon, // NOVO para botão de visibilidade da senha
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label + (isOptional ? '' : '*'),
            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textDark),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: AppColors.primaryBlue.withOpacity(0.1), blurRadius: 8, offset: Offset(0, 2))],
            ),
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              obscureText: obscureText,
              style: GoogleFonts.poppins(color: AppColors.textDark, fontSize: 15),
              decoration: InputDecoration(
                prefixIcon: Icon(icon, color: AppColors.primaryBlue),
                suffixIcon: suffixIcon, // Adicionado
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primaryBlue, width: 1.5)),
                errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.errorRed, width: 1.5)),
                focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.errorRed, width: 1.5)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                hintText: 'Digite ${label.toLowerCase()}',
                hintStyle: GoogleFonts.poppins(color: AppColors.textLight.withOpacity(0.7)),
              ),
              validator: (value) {
                if (!isOptional && (value == null || value.isEmpty)) {
                  return 'Campo obrigatório';
                }
                if (label == 'Email' && value != null && value.isNotEmpty) {
                  final emailRegex = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
                  if (!emailRegex.hasMatch(value)) {
                    return 'Email inválido';
                  }
                }
                // Adicionar validação de senha se necessário (ex: comprimento mínimo)
                if (label == 'Senha' && value != null && value.length < 6) { // Exemplo: mínimo 6 caracteres
                  // return 'Senha deve ter no mínimo 6 caracteres';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  // REMOVIDO _buildEstadoDropdown()

  Widget _buildSaveButton(bool isSubmitting) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        gradient: isSubmitting ? null : LinearGradient(colors: [AppColors.primaryBlue, AppColors.secondaryBlue], begin: Alignment.centerLeft, end: Alignment.centerRight),
        borderRadius: BorderRadius.circular(12),
        boxShadow: isSubmitting ? null : [BoxShadow(color: AppColors.primaryBlue.withOpacity(0.3), blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: ElevatedButton.icon(
        onPressed: isSubmitting ? null : _salvarTecnico,
        icon: isSubmitting ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white))) : Icon(Icons.check_circle_outline, color: Colors.white),
        label: Text(isSubmitting ? 'Salvando...' : 'Salvar Técnico', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSubmitting ? Colors.grey.shade600 : Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white.withOpacity(0.8),
          disabledBackgroundColor: Colors.grey.shade600,
        ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0)),
      ),
    );
  }
}

