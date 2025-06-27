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

  void _exportToExcel(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.white),
            SizedBox(width: 8),
            Text('Exportação para Excel em desenvolvimento.'),
          ],
        ),
        backgroundColor: AppColors.primaryBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(clienteListProvider);
    final notifier = ref.read(clienteListProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        title: Text(
          'Clientes',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primaryBlue,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
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
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            child: ElevatedButton.icon(
              onPressed: () => _exportToExcel(context),
              icon: Icon(Icons.grid_on_outlined, size: 18),
              label: Text(
                'Excel',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Elementos decorativos de fundo - inspirados no dashboard
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
          Positioned(
            top: MediaQuery.of(context).size.height * 0.4,
            right: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.successGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Conteúdo principal
          Column(
            children: [
              _buildFilterAndSearchSection(context, notifier),
              Expanded(
                child: _buildBodyContent(context, state, notifier),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              AppColors.primaryBlue,
              AppColors.secondaryBlue,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const NovoClienteScreen()),
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _buildFilterAndSearchSection(BuildContext context, ClienteListNotifier notifier) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Título da seção
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.search,
                    size: 20,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Buscar e Filtrar',
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

            // Campo de Busca
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: AppColors.textDark,
                ),
                decoration: InputDecoration(
                  hintText: 'Buscar por nome, CPF/CNPJ ou e-mail...',
                  hintStyle: GoogleFonts.poppins(
                    color: AppColors.textLight.withOpacity(0.7),
                    fontSize: 14,
                  ),
                  prefixIcon: Container(
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.search,
                      size: 20,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  filled: true,
                  fillColor: AppColors.backgroundGray.withOpacity(0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                onSubmitted: (searchTerm) => notifier.loadClientes(searchTerm: searchTerm, refresh: true),
              ),
            ),
            const SizedBox(height: 16),

            // Seção de Filtros
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildFilterChip(
                    'Filtros',
                    icon: Icons.filter_list,
                    isPrimary: true,
                    onPressed: () {
                      // TODO: Abrir modal de filtros avançados
                    },
                  ),
                  const SizedBox(width: 12),
                  _buildFilterChip(
                    'Tipo',
                    icon: Icons.category_outlined,
                    onPressed: () {
                      // TODO: Filtrar por tipo de cliente
                    },
                  ),
                  const SizedBox(width: 12),
                  _buildFilterChip(
                    'Cidade',
                    icon: Icons.location_city_outlined,
                    onPressed: () {
                      // TODO: Filtrar por cidade
                    },
                  ),
                  const SizedBox(width: 12),
                  _buildFilterChip(
                    'Status',
                    icon: Icons.flag_outlined,
                    onPressed: () {
                      // TODO: Filtrar por status
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, {required VoidCallback onPressed, IconData? icon, bool isPrimary = false}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: isPrimary
            ? [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ]
            : [],
      ),
      child: ActionChip(
        onPressed: onPressed,
        backgroundColor: isPrimary ? AppColors.primaryBlue : AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: BorderSide(
            color: isPrimary ? Colors.transparent : AppColors.dividerColor,
            width: 1.5,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null)
              Icon(
                icon,
                size: 18,
                color: isPrimary ? Colors.white : AppColors.primaryBlue,
              ),
            if (icon != null) const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isPrimary ? Colors.white : AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyContent(BuildContext context, ClienteListState state, ClienteListNotifier notifier) {
    if (state.isLoading && state.clientes.isEmpty) {
      return _buildLoadingState();
    }
    if (state.errorMessage != null && state.clientes.isEmpty) {
      return _buildErrorState(state.errorMessage!, () => notifier.loadClientes(refresh: true));
    }
    if (state.clientes.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () => notifier.loadClientes(refresh: true),
      color: AppColors.primaryBlue,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        physics: const BouncingScrollPhysics(),
        itemCount: state.clientes.length,
        itemBuilder: (context, index) {
          final cliente = state.clientes[index];
          return _buildClienteCard(context, cliente);
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.backgroundGray,
            AppColors.backgroundGray.withOpacity(0.8),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
              strokeWidth: 3,
            ),
            const SizedBox(height: 24),
            Text(
              'Carregando clientes...',
              style: GoogleFonts.poppins(
                color: AppColors.textLight,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClienteCard(BuildContext context, Cliente cliente) {
    final tipoClienteText = cliente.tipoCliente == TipoCliente.PESSOA_FISICA ? 'Pessoa Física' : 'Pessoa Jurídica';
    final tipoClienteColor = cliente.tipoCliente == TipoCliente.PESSOA_FISICA ? AppColors.successGreen : AppColors.primaryBlue;

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => ClienteDetailScreen(clienteId: cliente.id!)),
          );
        },
        borderRadius: BorderRadius.circular(16.0),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: tipoClienteColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      cliente.tipoCliente == TipoCliente.PESSOA_FISICA
                          ? Icons.person_outline
                          : Icons.business_outlined,
                      size: 24,
                      color: tipoClienteColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cliente.nomeCompleto,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          cliente.email ?? 'E-mail não cadastrado',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppColors.textLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.textLight,
                  ),
                ],
              ),
              const SizedBox(height: 20),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: tipoClienteColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: tipoClienteColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      tipoClienteText,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: tipoClienteColor,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundGray,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      cliente.cpfCnpj,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String message, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.errorRed.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_off_rounded,
                color: AppColors.errorRed,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Erro ao Carregar',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: GoogleFonts.poppins(
                color: AppColors.textLight,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryBlue,
                    AppColors.secondaryBlue,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: Text(
                  'Tentar Novamente',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.textLight.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.people_outline,
                size: 64,
                color: AppColors.textLight,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Nenhum cliente encontrado',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Crie um novo cliente ou ajuste os filtros de busca.',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryBlue,
                    AppColors.secondaryBlue,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const NovoClienteScreen()),
                  );
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: Text(
                  'Adicionar Cliente',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

