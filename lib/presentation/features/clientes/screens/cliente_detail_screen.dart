import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nordeste_servicos_app/data/models/tipo_cliente.dart';

import '../../../../domain/entities/cliente.dart';
import '../../../shared/providers/repository_providers.dart';
import '../../../shared/styles/app_colors.dart';
import '../providers/cliente_detail_provider.dart';
import '../providers/cliente_list_provider.dart';
import 'cliente_edit_screen.dart'; // Placeholder para a tela de edição

class ClienteDetailScreen extends ConsumerWidget {
  final int clienteId;

  const ClienteDetailScreen({required this.clienteId, Key? key}) : super(key: key);

  // Método para deletar o cliente (adaptado de _deleteOs)
  Future<void> _deleteCliente(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Confirmar Exclusão', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text('Tem certeza que deseja excluir este cliente e todos os seus dados associados?', style: GoogleFonts.poppins()),
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
        final clienteRepository = ref.read(clienteRepositoryProvider);
        await clienteRepository.deleteCliente(clienteId);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cliente excluído com sucesso!'), backgroundColor: AppColors.successGreen));
          ref.invalidate(clienteListProvider); // Invalida a lista para recarregar
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao excluir cliente: ${e.toString()}'), backgroundColor: AppColors.errorRed));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clienteAsyncValue = ref.watch(clienteDetailProvider(clienteId));

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        title: Text(
          clienteAsyncValue.when(
            data: (cliente) => cliente.nomeCompleto,
            loading: () => 'Carregando...',
            error: (err, stack) => 'Detalhes do Cliente',
          ),
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primaryBlue, AppColors.secondaryBlue],
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => ref.invalidate(clienteDetailProvider(clienteId)),
            tooltip: 'Atualizar',
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: clienteAsyncValue.maybeWhen(
              data: (cliente) => () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => ClienteEditScreen(clienteId: cliente.id!)),
                );
                ref.invalidate(clienteDetailProvider(clienteId));
                ref.invalidate(clienteListProvider);
              },
              orElse: () => null,
            ),
            tooltip: 'Editar Cliente',
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.white),
            onPressed: clienteAsyncValue.maybeWhen(
              data: (_) => () => _deleteCliente(context, ref),
              orElse: () => null,
            ),
            tooltip: 'Excluir Cliente',
          ),
        ],
      ),
      body: clienteAsyncValue.when(
        data: (cliente) {
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(clienteDetailProvider(clienteId)),
            color: AppColors.primaryBlue,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildClienteHeaderCard(cliente),
                const SizedBox(height: 20),
                _buildInfoCard(
                  title: 'Informações de Contato',
                  icon: Icons.contact_mail_outlined,
                  children: [
                    _buildDetailRow(label: 'E-mail', value: cliente.email, icon: Icons.email_outlined),
                    _buildDetailRow(label: 'Telefone Principal', value: cliente.telefonePrincipal, icon: Icons.phone_outlined),
                    _buildDetailRow(label: 'Telefone Adicional', value: cliente.telefoneAdicional, icon: Icons.phone_android_outlined),
                  ],
                ),
                const SizedBox(height: 20),
                _buildInfoCard(
                  title: 'Endereço',
                  icon: Icons.location_on_outlined,
                  children: [
                    _buildDetailRow(label: 'CEP', value: cliente.cep, icon: Icons.pin_outlined),
                    _buildDetailRow(label: 'Rua', value: '${cliente.rua}, ${cliente.numero}', icon: Icons.signpost_outlined),
                    _buildDetailRow(label: 'Complemento', value: cliente.complemento, icon: Icons.apartment_outlined),
                    _buildDetailRow(label: 'Bairro', value: cliente.bairro, icon: Icons.domain_outlined),
                    _buildDetailRow(label: 'Cidade/UF', value: '${cliente.cidade} - ${cliente.estado}', icon: Icons.location_city_outlined),
                  ],
                ),
                // Você pode adicionar mais cards aqui, como "Histórico de OS" ou "Equipamentos do Cliente"
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue)),
        error: (err, stack) => Center(child: Text('Erro ao carregar cliente: $err')),
      ),
    );
  }

  // Card de cabeçalho específico para o cliente
  Widget _buildClienteHeaderCard(Cliente cliente) {
    final tipoClienteText = cliente.tipoCliente == TipoCliente.PESSOA_FISICA ? 'Pessoa Física' : 'Pessoa Jurídica';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        color: AppColors.cardBackground,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                  child: const Icon(Icons.person, size: 30, color: AppColors.primaryBlue),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cliente.nomeCompleto,
                        style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        cliente.cpfCnpj,
                        style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textLight),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.dividerColor, height: 1),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Chip(
                avatar: Icon(cliente.tipoCliente == TipoCliente.PESSOA_FISICA ? Icons.person : Icons.business, size: 18, color: AppColors.primaryBlue),
                label: Text(tipoClienteText, style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: AppColors.primaryBlue)),
                backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
  // Card genérico para seções de informação aprimorado
  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    size: 20,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.dividerColor,
                    AppColors.dividerColor.withOpacity(0.1),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  // Linha de detalhe aprimorada
  Widget _buildDetailRow({
    required String label,
    String? value,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 18,
              color: AppColors.textLight,
            ),
            const SizedBox(width: 8),
          ],
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value ?? '--',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Seção de detalhe para textos mais longos aprimorada
  Widget _buildDetailSection({
    required String label,
    required String value,
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 18,
                color: AppColors.primaryBlue,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              '$label:',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: AppColors.backgroundGray,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: AppColors.dividerColor,
              width: 1,
            ),
          ),
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textDark,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }
}
