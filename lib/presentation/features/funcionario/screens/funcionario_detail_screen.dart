import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../data/models/perfil_usuario_model.dart';
import '../../../../domain/entities/usuario.dart';
import '../../../shared/providers/repository_providers.dart';
import '../../../shared/styles/app_colors.dart';
import '../providers/funcionario_detail_provider.dart';
import '../providers/funcionario_list_provider.dart';

class FuncionarioDetailScreen extends ConsumerWidget {
  final int funcionarioId;

  const FuncionarioDetailScreen({required this.funcionarioId, Key? key}) : super(key: key);

  // Adaptação da sua lógica de exclusão
  Future<void> _deleteFuncionario(BuildContext context, WidgetRef ref) async {
    // Implemente a lógica de confirmação e exclusão aqui, similar à tela de detalhes de OS/Cliente
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final funcionarioAsyncValue = ref.watch(funcionarioDetailProvider(funcionarioId));

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        title: Text(
          funcionarioAsyncValue.when(
            data: (func) => func.nome,
            loading: () => 'Carregando...',
            error: (e, s) => 'Detalhes do Funcionário',
          ),
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: () {}, tooltip: 'Editar Funcionário'),
          IconButton(icon: const Icon(Icons.delete_forever), onPressed: () => _deleteFuncionario(context, ref), tooltip: 'Excluir Funcionário'),
        ],
      ),
      body: funcionarioAsyncValue.when(
        data: (funcionario) {
          final perfilText = funcionario.perfil.name == 'ADMIN' ? 'Administrador' : 'Técnico';
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                        child: const Icon(Icons.person, size: 40, color: AppColors.primaryBlue),
                      ),
                      const SizedBox(height: 16),
                      Text(funcionario.nome, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(funcionario.email ?? 'E-mail não informado', style: GoogleFonts.poppins(fontSize: 16, color: AppColors.textLight)),
                      const SizedBox(height: 16),
                      Chip(
                        label: Text(perfilText, style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: AppColors.primaryBlue)),
                        backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Informações Adicionais', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
                      const Divider(height: 24),
                      _buildDetailRow('ID do Usuário', funcionario.id.toString()),
                      _buildDetailRow('Crachá', funcionario.cracha ?? 'Não informado'),
                    ],
                  ),
                ),
              )
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erro: $err')),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$label:', style: GoogleFonts.poppins(color: AppColors.textLight, fontSize: 15)),
          Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15)),
        ],
      ),
    );
  }
}