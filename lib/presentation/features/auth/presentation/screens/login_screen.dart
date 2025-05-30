// lib/presentation/features/auth/presentation/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart'; // Importando Google Fonts para fontes modernas

import '../../providers/auth_provider.dart';
import '../../providers/auth_state.dart';

// Definindo paleta de cores personalizada
class AppColors {
  static const Color primaryBlue = Color(0xFF1A73E8); // Azul principal mais vibrante
  static const Color secondaryBlue = Color(0xFF4285F4); // Azul secundário
  static const Color accentBlue = Color(0xFF8AB4F8); // Azul claro para acentos
  static const Color darkBlue = Color(0xFF0D47A1); // Azul escuro para detalhes
  static const Color backgroundGray = Color(0xFFF8F9FA); // Fundo cinza claro
  static const Color textDark = Color(0xFF202124); // Texto escuro
  static const Color textLight = Color(0xFF5F6368); // Texto cinza
  static const Color errorRed = Color(0xFFD93025); // Vermelho para erros
}

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  // Adicionando animação para melhorar a experiência do usuário
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
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
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);
    final size = MediaQuery.of(context).size;

    ref.listen<AuthState>(authProvider, (previousState, newState) {
      if (newState.errorMessage != null && previousState?.errorMessage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(newState.errorMessage!),
            backgroundColor: AppColors.errorRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: EdgeInsets.all(12),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      body: SafeArea(
        child: Stack(
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
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 450),
                  child: FadeTransition(
                    opacity: _fadeInAnimation,
                    child: Card(
                      elevation: 8,
                      shadowColor: AppColors.primaryBlue.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            // Logo centralizada com fundo azul para contraste
                            Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Image.asset(
                                '../assets/images/logo.png',
                                height: 100,
                                fit: BoxFit.contain,
                              ),
                            ),

                            SizedBox(height: 32),

                            // Título da tela
                            Text(
                              'Bem-vindo',
                              style: GoogleFonts.poppins(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            Text(
                              'Sistema de Gestão de Ordens de Serviço',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: AppColors.textLight,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            SizedBox(height: 32),

                            // Campo de E-mail/Usuário redesenhado
                            _buildTextField(
                              controller: _emailController,
                              label: 'E-mail ou Usuário',
                              hint: 'Digite seu e-mail ou nome de usuário',
                              icon: Icons.person_outline,
                              keyboardType: TextInputType.emailAddress,
                            ),

                            SizedBox(height: 20),

                            // Campo de Senha redesenhado
                            _buildTextField(
                              controller: _passwordController,
                              label: 'Senha',
                              hint: 'Digite sua senha',
                              icon: Icons.lock_outline,
                              isPassword: true,
                              obscureText: !_isPasswordVisible,
                              onToggleVisibility: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),

                            SizedBox(height: 12),

                            // Link "Esqueci minha senha" alinhado à direita
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Funcionalidade "Esqueci minha senha" não implementada.'),
                                      backgroundColor: AppColors.textLight,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.primaryBlue,
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size(0, 0),
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'Esqueci minha senha',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: 32),

                            // Botão de Login redesenhado
                            _buildLoginButton(
                              onPressed: authState.isLoading
                                  ? null
                                  : () {
                                FocusScope.of(context).unfocus();
                                authNotifier.login(
                                  _emailController.text.trim(),
                                  _passwordController.text.trim(),
                                );
                              },
                              isLoading: authState.isLoading,
                            ),

                            SizedBox(height: 24),

                            // Rodapé com informações da empresa
                            Text(
                              '© 2025 CODAGIS - Todos os direitos reservados',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppColors.textLight,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget personalizado para campos de texto
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textDark,
          ),
        ),
        SizedBox(height: 8),
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
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: AppColors.textDark,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.poppins(
                fontSize: 15,
                color: AppColors.textLight.withOpacity(0.7),
              ),
              prefixIcon: Icon(
                icon,
                color: AppColors.primaryBlue,
                size: 22,
              ),
              suffixIcon: isPassword
                  ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: AppColors.primaryBlue,
                  size: 22,
                ),
                onPressed: onToggleVisibility,
              )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              filled: true,
              fillColor: Colors.white,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primaryBlue, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Widget personalizado para botão de login
  Widget _buildLoginButton({
    required VoidCallback? onPressed,
    required bool isLoading,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [AppColors.primaryBlue, AppColors.secondaryBlue],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.zero,
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: 3.0,
          ),
        )
            : Text(
          'Entrar',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
