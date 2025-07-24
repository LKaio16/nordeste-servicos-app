import 'package:dio/dio.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nordeste_servicos_app/data/models/tipo_cliente.dart';
import 'package:nordeste_servicos_app/core/network/api_client.dart';
import 'package:nordeste_servicos_app/presentation/shared/providers/repository_providers.dart';
import 'package:open_filex/open_filex.dart';
import 'package:intl/intl.dart';

import '../../../../domain/entities/cliente.dart';
import '../../../shared/styles/app_colors.dart';
import '../providers/cliente_list_provider.dart';
import 'cliente_detail_screen.dart';
import 'novo_cliente_screen.dart';

class ClienteListScreen extends ConsumerStatefulWidget {
  const ClienteListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ClienteListScreen> createState() => _ClienteListScreenState();
}

class _ClienteListScreenState extends ConsumerState<ClienteListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final searchTerm = ref.read(clienteListProvider).searchTerm;
    _searchController.text = searchTerm;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _exportToExcel(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text('Iniciando download do arquivo Excel...'),
        backgroundColor: AppColors.primaryBlue,
      ),
    );

    try {
      final ApiClient apiClient = ref.read(apiClientProvider);
      final response = await apiClient.get(
        '/clientes/download',
        options: Options(
          responseType: ResponseType.bytes, // Receber como bytes
        ),
      );

      if (response.statusCode == 200) {
        final Uint8List bytes = Uint8List.fromList(response.data);
        final String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
        final String fileName = 'clientes_$formattedDate.xlsx';
        
        final path = await FileSaver.instance.saveFile(
          name: fileName,
          bytes: bytes,
          ext: 'xlsx',
          mimeType: MimeType.microsoftExcel,
        );

        scaffoldMessenger.removeCurrentSnackBar();
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Download concluído! Salvo em: $path'),
            backgroundColor: AppColors.successGreen,
            action: SnackBarAction(
              label: 'ABRIR',
              textColor: Colors.white,
              onPressed: () {
                if (path != null) {
                  OpenFilex.open(path);
                }
              },
            ),
          ),
        );
      } else {
        throw 'Erro no servidor: ${response.statusCode}';
      }
    } catch (e) {
      scaffoldMessenger.removeCurrentSnackBar();
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Erro ao exportar para Excel: $e'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(clienteListProvider);
    final notifier = ref.read(clienteListProvider.notifier);
    
    // Listener para limpar o controller se os filtros forem limpos por outra ação
    ref.listen<ClienteListState>(clienteListProvider, (previous, next) {
      if (previous?.searchTerm != '' && next.searchTerm == '') {
        _searchController.clear();
      }
    });

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
              _buildFilterAndSearchSection(context, notifier, state),
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
          onPressed: () async {
            final result = await Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const NovoClienteScreen()),
            );
            // Invalida para recarregar a lista quando voltar
            if(result == true) {
              ref.invalidate(clienteListProvider);
            }
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _buildFilterAndSearchSection(BuildContext context, ClienteListNotifier notifier, ClienteListState state) {
    bool hasActiveFilter = state.searchTerm.isNotEmpty || state.tipoClienteFiltro != null;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Campo de Busca
            TextField(
              controller: _searchController,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: AppColors.textDark,
              ),
              decoration: InputDecoration(
                hintText: 'Buscar por nome, CPF/CNPJ...',
                hintStyle: GoogleFonts.poppins(
                  color: AppColors.textLight.withOpacity(0.8),
                ),
                prefixIcon: Icon(Icons.search, color: AppColors.textLight.withOpacity(0.8)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.textLight),
                        onPressed: () {
                          _searchController.clear();
                          notifier.search('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.backgroundGray.withOpacity(0.8),
                contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => notifier.search(value),
            ),
            const SizedBox(height: 16),

            // Chips de Filtro
            Column(
              children: [
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: [
                    _buildFilterChip(
                      context: context,
                      label: 'Pessoa Física',
                      onPressed: () => notifier.filterByTipo(TipoCliente.PESSOA_FISICA),
                      isSelected: state.tipoClienteFiltro == TipoCliente.PESSOA_FISICA,
                    ),
                    _buildFilterChip(
                      context: context,
                      label: 'Pessoa Jurídica',
                      onPressed: () => notifier.filterByTipo(TipoCliente.PESSOA_JURIDICA),
                      isSelected: state.tipoClienteFiltro == TipoCliente.PESSOA_JURIDICA,
                    ),
                  ],
                ),
                if (hasActiveFilter)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: () {
                          _searchController.clear();
                          notifier.clearFilters();
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.clear_all, color: AppColors.textLight, size: 20),
                              const SizedBox(width: 4),
                              Text(
                                'Limpar',
                                style: GoogleFonts.poppins(
                                  color: AppColors.textLight,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required BuildContext context,
    required String label,
    required VoidCallback onPressed,
    required bool isSelected,
  }) {
    return ActionChip(
      onPressed: onPressed,
      label: Text(
        label,
        style: GoogleFonts.poppins(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isSelected ? Colors.white : AppColors.primaryBlue,
        ),
      ),
      backgroundColor: isSelected ? AppColors.primaryBlue : AppColors.primaryBlue.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppColors.primaryBlue : AppColors.primaryBlue.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  Widget _buildBodyContent(BuildContext context, ClienteListState state, ClienteListNotifier notifier) {
    if (state.isLoading && state.clientes.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue));
    }

    if (state.errorMessage != null && state.clientes.isEmpty) {
      return _buildErrorState(state.errorMessage!, () => notifier.refresh());
    }

    if (state.clientes.isEmpty) {
      return _buildEmptyState(state.searchTerm.isNotEmpty || state.tipoClienteFiltro != null);
    }

    return RefreshIndicator(
      onRefresh: () => notifier.refresh(),
      color: AppColors.primaryBlue,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80), // Padding para não cobrir com o FAB
        physics: const BouncingScrollPhysics(),
        itemCount: state.clientes.length,
        itemBuilder: (context, index) {
          final cliente = state.clientes[index];
          return _buildClienteCard(context, cliente, ref);
        },
      ),
    );
  }

  Widget _buildClienteCard(BuildContext context, Cliente cliente, WidgetRef ref) {
    return Card(
      elevation: 4,
      shadowColor: AppColors.primaryBlue.withOpacity(0.1),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => ClienteDetailScreen(clienteId: cliente.id!)),
          );
          // Atualiza a lista caso haja deleção na tela de detalhes
          if (result == true) {
            ref.read(clienteListProvider.notifier).refresh();
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                    child: Icon(
                      cliente.tipoCliente == TipoCliente.PESSOA_JURIDICA ? Icons.business_center_outlined : Icons.person_outline,
                      color: AppColors.primaryBlue,
                      size: 28,
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
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppColors.textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.textLight),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: AppColors.dividerColor, height: 1),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoItem(
                    icon: Icons.phone_outlined,
                    text: cliente.telefonePrincipal.isNotEmpty ? cliente.telefonePrincipal : 'Não informado',
                  ),
                  _buildInfoItem(
                    icon: Icons.location_on_outlined,
                    text: cliente.cidade.isNotEmpty ? '${cliente.cidade} - ${cliente.estado}' : 'Não informado',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem({required IconData icon, required String text}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textLight),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            style: GoogleFonts.poppins(color: AppColors.textLight),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String message, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_rounded, color: AppColors.errorRed.withOpacity(0.7), size: 60),
            const SizedBox(height: 20),
            Text('Erro ao Carregar', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(message, style: GoogleFonts.poppins(color: AppColors.textLight, fontSize: 14), textAlign: TextAlign.center),
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

  Widget _buildEmptyState(bool isSearching) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSearching ? Icons.search_off_rounded : Icons.people_outline_rounded,
              size: 60,
              color: AppColors.textLight.withOpacity(0.7),
            ),
            const SizedBox(height: 20),
            Text(
              isSearching ? 'Nenhum Cliente Encontrado' : 'Nenhum Cliente Cadastrado',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            const SizedBox(height: 8),
            Text(
              isSearching
                  ? 'Tente uma busca diferente ou limpe os filtros.'
                  : 'Adicione um novo cliente para começar a gerenciar.',
              style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textLight),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

