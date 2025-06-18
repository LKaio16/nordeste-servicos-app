import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nordeste_servicos_app/data/models/tipo_cliente.dart';

import '../../../../domain/entities/cliente.dart';
import '../../../shared/styles/app_colors.dart';
import '../providers/cliente_list_provider.dart';
import 'cliente_detail_screen.dart';
import 'novo_cliente_screen.dart';

class ClienteListScreen extends ConsumerWidget {
  const ClienteListScreen({Key? key}) : super(key: key);

  // <<< NOVO MÉTODO PARA EXPORTAÇÃO (PLACEHOLDER) >>>
  void _exportToExcel(BuildContext context) {
    // Lógica futura para gerar e baixar o arquivo Excel.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidade de exportação para Excel em desenvolvimento.'),
        backgroundColor: AppColors.primaryBlue,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(clienteListProvider);
    final notifier = ref.read(clienteListProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      // <<< 1. APPBAR ADICIONADA >>>
      appBar: AppBar(
        title: Text('Clientes', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.textDark)),
        backgroundColor: AppColors.cardBackground,
        foregroundColor: AppColors.textDark, // Cor dos ícones e texto padrão
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        actions: [
          IconButton(
            icon: const Icon(Icons.grid_on_outlined), // Ícone sugestivo para Excel/Planilha
            onPressed: () => _exportToExcel(context),
            tooltip: 'Exportar para Excel',
          ),
          const SizedBox(width: 8),
        ],
      ),
      // <<< 2. O BODY FOI REESTRUTURADO >>>
      body: Column(
        children: [
          // <<< 3. NOVA SEÇÃO DE BUSCA E FILTROS >>>
          _buildFilterAndSearchSection(context, notifier),
          Expanded(
            child: _buildBodyContent(context, state, notifier),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const NovoClienteScreen()),
          );
        },
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // <<< MÉTODO _buildPageHeader FOI REMOVIDO E SUBSTITUÍDO POR ESTE >>>
  Widget _buildFilterAndSearchSection(BuildContext context, ClienteListNotifier notifier) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      color: AppColors.cardBackground,
      child: Column(
        children: [
          // Campo de Busca
          TextField(
            style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textDark),
            decoration: InputDecoration(
              hintText: 'Buscar por nome, CPF/CNPJ ou e-mail...',
              hintStyle: GoogleFonts.poppins(color: AppColors.textLight),
              prefixIcon: const Icon(Icons.search, color: AppColors.textLight),
              filled: true,
              fillColor: AppColors.backgroundGray,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
            ),
            onSubmitted: (searchTerm) => notifier.loadClientes(searchTerm: searchTerm, refresh: true),
          ),
          const SizedBox(height: 12),
          // Seção de Filtros (similar à tela de OS)
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: [
                _buildFilterChip(
                  'Filtros',
                  icon: Icons.filter_list,
                  isPrimary: true,
                  onPressed: () { /* TODO: Abrir modal de filtros avançados */ },
                ),
                const SizedBox(width: 8),
                _buildFilterChip('Tipo', onPressed: () { /* TODO: Filtrar por tipo de cliente */ }),
                const SizedBox(width: 8),
                _buildFilterChip('Cidade', onPressed: () { /* TODO: Filtrar por cidade */ }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // <<< NOVO WIDGET AUXILIAR PARA OS CHIPS DE FILTRO (COPIADO DA TELA DE OS) >>>
  Widget _buildFilterChip(String label, {required VoidCallback onPressed, IconData? icon, bool isPrimary = false}) {
    return ActionChip(
      onPressed: onPressed,
      backgroundColor: isPrimary ? AppColors.primaryBlue : AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
        side: BorderSide(color: isPrimary ? Colors.transparent : AppColors.dividerColor, width: 1.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      label: Row(
        children: [
          if (icon != null)
            Icon(icon, size: 18, color: isPrimary ? Colors.white : AppColors.primaryBlue),
          if (icon != null) const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isPrimary ? Colors.white : AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  // O restante do seu código (_buildBodyContent, _buildClienteCard, etc.)
  // permanece exatamente o mesmo e não precisa de alterações.
  Widget _buildBodyContent(BuildContext context, ClienteListState state, ClienteListNotifier notifier) {
    if (state.isLoading && state.clientes.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue));
    }
    if (state.errorMessage != null && state.clientes.isEmpty) {
      return _buildErrorState(state.errorMessage!, () => notifier.loadClientes(refresh: true));
    }
    if (state.clientes.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => notifier.loadClientes(refresh: true),
      color: AppColors.primaryBlue,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: state.clientes.length,
        itemBuilder: (context, index) {
          final cliente = state.clientes[index];
          return _buildClienteCard(context, cliente);
        },
      ),
    );
  }

  Widget _buildClienteCard(BuildContext context, Cliente cliente) {
    final tipoClienteText = cliente.tipoCliente == TipoCliente.PESSOA_FISICA ? 'Pessoa Física' : 'Pessoa Jurídica';

    return Card(
      elevation: 2,
      shadowColor: AppColors.primaryBlue.withOpacity(0.08),
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => ClienteDetailScreen(clienteId: cliente.id!)),
          );
        },
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      cliente.nomeCompleto,
                      style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textDark),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.person_pin, color: AppColors.primaryBlue.withOpacity(0.7)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                cliente.email ?? 'E-mail não cadastrado',
                style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textLight),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              const Divider(color: AppColors.dividerColor, height: 1),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Chip(
                    label: Text(tipoClienteText, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.primaryBlue)),
                    backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  Text(
                    cliente.cpfCnpj,
                    style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textLight, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget para o estado de erro
  Widget _buildErrorState(String message, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_rounded, color: AppColors.errorRed.withOpacity(0.7), size: 60),
            const SizedBox(height: 20),
            Text(
              'Erro ao Carregar',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: GoogleFonts.poppins(color: AppColors.textLight, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: Text('Tentar Novamente', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para o estado de lista vazia
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.list_alt_outlined, size: 60, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Nenhum cliente encontrado',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
          const SizedBox(height: 8),
          Text(
            'Crie um novo cliente ou ajuste os filtros.',
            style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textLight),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}