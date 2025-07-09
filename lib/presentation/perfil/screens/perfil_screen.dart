import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nordeste_servicos_app/presentation/features/auth/providers/auth_provider.dart';
import 'package:nordeste_servicos_app/presentation/shared/styles/app_colors.dart';

class PerfilScreen extends ConsumerWidget {
  const PerfilScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.authenticatedUser;

    if (user == null) {
      // Caso o usuário não esteja logado, mostra uma mensagem.
      return const Center(child: Text('Nenhum usuário autenticado.'));
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      // A AppBar é controlada pela TecnicoHomeScreen, então não adicionamos uma aqui.
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        children: [
          // 1. Cabeçalho do Perfil
          _buildProfileHeader(user),
          const SizedBox(height: 24),

          // 2. Cards de Estatísticas
          _buildStatsRow(),
          const SizedBox(height: 24),

          // 3. Lista de Opções
          _buildOptionsList(context, ref),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(dynamic user) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: AppColors.primaryBlue.withOpacity(0.2),
          child: CircleAvatar(
            radius: 46,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=${user.id}'),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          user.nome,
          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark),
        ),
        const SizedBox(height: 4),
        Text(
          user.email ?? 'E-mail não informado',
          style: GoogleFonts.poppins(fontSize: 16, color: AppColors.textLight),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    // Dados mocados para as estatísticas. No futuro, podem vir de um provider.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(child: _buildStatCard('OS Concluídas', '128', Icons.check_circle, AppColors.successGreen)),
          const SizedBox(width: 16),
          Expanded(child: _buildStatCard('Média Mensal', '15', Icons.calendar_today, AppColors.warningOrange)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.poppins(fontSize: 12, color: color, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsList(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          _buildOptionItem(
            icon: Icons.edit_outlined,
            title: 'Editar Perfil',
            onTap: () {
              // TODO: Navegar para a tela de edição de perfil
            },
          ),
          _buildOptionItem(
            icon: Icons.lock_outline,
            title: 'Alterar Senha',
            onTap: () {
              // TODO: Navegar para a tela de alteração de senha
            },
          ),
          _buildOptionItem(
            icon: Icons.notifications_outlined,
            title: 'Notificações',
            onTap: () {
              // TODO: Navegar para a tela de configurações de notificação
            },
          ),
          _buildOptionItem(
            icon: Icons.settings_outlined,
            title: 'Configurações',
            onTap: () {
              // TODO: Navegar para a tela de configurações gerais
            },
          ),
          const Divider(height: 32),
          _buildOptionItem(
            icon: Icons.logout,
            title: 'Sair',
            color: AppColors.errorRed,
            onTap: () {
              // Lógica de logout que você já tem
              ref.read(authProvider.notifier).logout();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOptionItem({required IconData icon, required String title, required VoidCallback onTap, Color? color}) {
    final itemColor = color ?? AppColors.textDark;
    return Card(
      elevation: 0,
      color: AppColors.cardBackground,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: itemColor),
        title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: itemColor)),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: itemColor.withOpacity(0.7)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
