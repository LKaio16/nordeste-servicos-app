import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../data/models/perfil_usuario_model.dart';
import '../../../../domain/entities/usuario.dart';
import '../../../shared/styles/app_colors.dart';
import '../providers/funcionario_list_provider.dart';
import 'funcionario_detail_screen.dart'; // Placeholder
import 'novo_tecnico_screen.dart'; // Reutilizando a tela de novo técnico

class FuncionarioListScreen extends ConsumerWidget {
  const FuncionarioListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(funcionarioListProvider);
    final notifier = ref.read(funcionarioListProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        title: Text('Funcionários', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.textDark)),
        backgroundColor: AppColors.cardBackground,
        foregroundColor: AppColors.textDark,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            color: AppColors.cardBackground,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por nome, e-mail ou crachá...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: AppColors.backgroundGray,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              onSubmitted: (term) => notifier.loadFuncionarios(searchTerm: term, refresh: true),
            ),
          ),
          Expanded(
            child: _buildBodyContent(context, state, notifier),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Reutilizando a tela que você já tem para criar técnicos
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const NovoTecnicoScreen()),
          );
        },
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBodyContent(BuildContext context, FuncionarioListState state, FuncionarioListNotifier notifier) {
    if (state.isLoading && state.funcionarios.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.errorMessage != null && state.funcionarios.isEmpty) {
      return Center(child: Text(state.errorMessage!));
    }
    if (state.funcionarios.isEmpty) {
      return const Center(child: Text('Nenhum funcionário encontrado.'));
    }

    return RefreshIndicator(
      onRefresh: () => notifier.loadFuncionarios(refresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: state.funcionarios.length,
        itemBuilder: (context, index) {
          final funcionario = state.funcionarios[index];
          return _buildFuncionarioCard(context, funcionario);
        },
      ),
    );
  }

  Widget _buildFuncionarioCard(BuildContext context, Usuario funcionario) {
    // Usando os campos da sua entidade Usuario
    final perfilText = funcionario.perfil.name == 'ADMIN' ? 'Administrador' : 'Técnico';
    final perfilColor = funcionario.perfil == PerfilUsuarioModel.ADMIN ? AppColors.errorRed : AppColors.secondaryBlue;

    return Card(
      elevation: 2,
      shadowColor: AppColors.primaryBlue.withOpacity(0.08),
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => FuncionarioDetailScreen(funcionarioId: funcionario.id!)),
          );
        },
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: perfilColor.withOpacity(0.1),
                child: Icon(
                  funcionario.perfil == PerfilUsuarioModel.ADMIN ? Icons.admin_panel_settings_outlined : Icons.engineering_outlined,
                  color: perfilColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      funcionario.nome,
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      funcionario.email ?? 'E-mail não cadastrado',
                      style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textLight),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    perfilText,
                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: perfilColor),
                  ),
                  const SizedBox(height: 4),
                  if (funcionario.cracha != null)
                    Text(
                      'Crachá: ${funcionario.cracha}',
                      style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textLight),
                    )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}