import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nordeste_servicos_app/presentation/features/auth/providers/auth_provider.dart';
import 'package:nordeste_servicos_app/presentation/shared/styles/app_colors.dart';

import '../../../../domain/entities/usuario.dart';

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
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
        children: [
          // 1. Cabeçalho do Perfil
          _buildProfileHeader(user),
          const SizedBox(height: 24),

          // 2. Card de Informações Detalhadas
          _buildInfoCard(user),
          const SizedBox(height: 24),

          // 3. Botão de Logout
          _buildLogoutButton(context, ref),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(Usuario user) {
    Uint8List? imageBytes;
    if (user.fotoPerfil != null && user.fotoPerfil!.isNotEmpty) {
      try {
        imageBytes = base64Decode(user.fotoPerfil!);
      } catch (e) {
        imageBytes = null;
      }
    }

    return Column(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: AppColors.primaryBlue.withOpacity(0.2),
          backgroundImage: imageBytes != null ? MemoryImage(imageBytes) : null,
          child: imageBytes == null
              ? const Icon(
            Icons.person,
            size: 60,
            color: AppColors.primaryBlue,
          )
              : null,
        ),
        const SizedBox(height: 16),
        Text(
          user.nome,
          style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark),
        ),
        const SizedBox(height: 4),
        Text(
          user.email ?? 'E-mail não informado',
          style: GoogleFonts.poppins(fontSize: 16, color: AppColors.textLight),
        ),
      ],
    );
  }

  Widget _buildInfoCard(Usuario user) {
    return Card(
      elevation: 4,
      shadowColor: AppColors.primaryBlue.withOpacity(0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informações do Usuário',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const Divider(height: 24),
            _buildInfoRow(Icons.badge_outlined, 'Nome Completo', user.nome),
            _buildInfoRow(Icons.email_outlined, 'Email', user.email ?? 'Não informado'),
            _buildInfoRow(Icons.credit_card_outlined, 'Crachá', user.cracha ?? 'Não informado'),
            _buildInfoRow(
                Icons.security_outlined,
                'Perfil',
                user.perfil.name == 'ADMIN'
                    ? 'Administrador'
                    : 'Técnico'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryBlue, size: 20),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textLight,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return ElevatedButton.icon(
      onPressed: () {
        ref.read(authProvider.notifier).logout();
      },
      icon: const Icon(Icons.logout, color: Colors.white),
      label: Text(
        'Sair',
        style:
        GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.errorRed,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
    );
  }
}