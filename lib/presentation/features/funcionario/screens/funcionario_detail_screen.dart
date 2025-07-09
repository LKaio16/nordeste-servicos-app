import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../shared/providers/repository_providers.dart';
import '../../../shared/styles/app_colors.dart';
import '../providers/funcionario_detail_provider.dart';
import '../providers/funcionario_list_provider.dart';
import 'funcionario_edit_screen.dart';

class FuncionarioDetailScreen extends ConsumerWidget {
  final int funcionarioId;

  const FuncionarioDetailScreen({required this.funcionarioId, Key? key}) : super(key: key);

  // Adaptação da sua lógica de exclusão
  Future<void> _deleteFuncionario(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Confirmar Exclusão', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text('Tem certeza que deseja excluir este funcionário? Esta ação não pode ser desfeita.', style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancelar', style: GoogleFonts.poppins(color: AppColors.textLight)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: Text('Excluir', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(usuarioRepositoryProvider).deleteUser(funcionarioId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Funcionário excluído com sucesso!'), backgroundColor: AppColors.successGreen));
          ref.invalidate(funcionarioListProvider);
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao excluir funcionário: ${e.toString()}'), backgroundColor: AppColors.errorRed));
        }
      }
    }
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
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: funcionarioAsyncValue.maybeWhen(
              data: (funcionario) => () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => FuncionarioEditScreen(funcionarioId: funcionario.id!)),
                );
                // Invalida os providers para recarregar os dados
                ref.invalidate(funcionarioDetailProvider(funcionario.id!));
                ref.invalidate(funcionarioListProvider);
              },
              orElse: () => null,
            ),
            tooltip: 'Editar Funcionário',
          ),
          IconButton(icon: const Icon(Icons.delete_forever), onPressed: () => _deleteFuncionario(context, ref), tooltip: 'Excluir Funcionário'),
        ],
      ),
      body: funcionarioAsyncValue.when(
        data: (funcionario) {
          final perfilText = funcionario.perfil.name == 'ADMIN' ? 'Administrador' : 'Técnico';

          // Lógica para decodificar a imagem Base64
          Uint8List? imageBytes;
          if(funcionario.fotoPerfil != null && funcionario.fotoPerfil!.isNotEmpty){
            try {
              imageBytes = base64Decode(funcionario.fotoPerfil!);
            } catch(e) {
              // Log do erro caso a string Base64 seja inválida
              print("Erro ao decodificar imagem Base64 do funcionário ${funcionario.id}: $e");
              imageBytes = null;
            }
          }

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
                        radius: 50, // Aumentado para melhor visualização
                        backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                        backgroundImage: imageBytes != null ? MemoryImage(imageBytes) : null,
                        child: imageBytes == null
                            ? const Icon(Icons.person, size: 50, color: AppColors.primaryBlue)
                            : null,
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