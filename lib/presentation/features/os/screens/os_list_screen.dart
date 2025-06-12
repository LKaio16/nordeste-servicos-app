// lib/features/ordem_servico/presentation/screens/os_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // Para formatação de data
import 'package:nordeste_servicos_app/data/models/status_os_model.dart';

// Importações locais (ajuste os caminhos conforme sua estrutura de projeto)
import '../../../../domain/entities/ordem_servico.dart';
import '../providers/os_list_provider.dart';
import 'os_detail_screen.dart'; // Importe o seu osListProvider (este já deve conter OsListState)
// REMOVIDO: import '../providers/os_list_state.dart'; // Removido para evitar conflito

// Página Lista OS integrada com Riverpod
class OsListScreen extends ConsumerStatefulWidget {
  const OsListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OsListScreen> createState() => _OsListScreenState();
}

class _OsListScreenState extends ConsumerState<OsListScreen> {

  @override
  void initState() {
    super.initState();
    // *** IMPORTANTE: REMOVIDA A LÓGICA DE CARREGAMENTO INICIAL DO INITSTATE. ***
    // O carregamento agora é feito no construtor do OsListNotifier,
    // que é disparado quando o provedor é criado ou invalidado.
  }

  // Função auxiliar para obter a cor do fundo do status
  Color _getStatusBackgroundColor(StatusOSModel status) {
    switch (status) {
      case StatusOSModel.CONCLUIDA:
      case StatusOSModel.ENCERRADA:
        return Colors.green.shade100;
      case StatusOSModel.EM_ANDAMENTO:
        return Colors.orange.shade100;
      case StatusOSModel.EM_ABERTO:
      case StatusOSModel.PENDENTE_PECAS:
        return Colors.blue.shade100;
      case StatusOSModel.CANCELADA:
        return Colors.red.shade100;
      default: // UNKNOWN ou outros
        return Colors.grey.shade200;
    }
  }

  // Função auxiliar para obter a cor do texto do status
  Color _getStatusTextColor(StatusOSModel status) {
    switch (status) {
      case StatusOSModel.CONCLUIDA:
      case StatusOSModel.ENCERRADA:
        return Colors.green.shade800;
      case StatusOSModel.EM_ANDAMENTO:
        return Colors.orange.shade800;
      case StatusOSModel.EM_ABERTO:
      case StatusOSModel.PENDENTE_PECAS:
        return Colors.blue.shade800;
      case StatusOSModel.CANCELADA:
        return Colors.red.shade800;
      default: // UNKNOWN ou outros
        return Colors.grey.shade700;
    }
  }

  // Função auxiliar para obter o texto do status (mais completo)
  String _getStatusText(StatusOSModel status) {
    switch (status) {
      case StatusOSModel.CONCLUIDA:
        return 'Concluída';
      case StatusOSModel.EM_ANDAMENTO:
        return 'Em Andamento';
      case StatusOSModel.EM_ABERTO:
        return 'Em Aberto';
      case StatusOSModel.ENCERRADA:
        return 'Encerrada';
      case StatusOSModel.CANCELADA:
        return 'Cancelada';
      case StatusOSModel.PENDENTE_PECAS:
        return 'Pendente';
      default:
        return 'Desconhecido';
    }
  }

  // Função para formatar data (exemplo)
  String _formatDate(DateTime? date) {
    if (date == null) return '--/--/----';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    // Observar o estado do provider.
    // Quando o provedor é invalidado e uma nova instância do Notifier é criada,
    // o construtor do Notifier chamará loadOrdensServico, e esta tela será reconstruída.
    final state = ref.watch(osListProvider);
    final notifier = ref.read(osListProvider.notifier);

    final Color primaryColor = Colors.indigo.shade700;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: TextField(
          style: GoogleFonts.poppins(fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Buscar OS, cliente ou técnico...',
            hintStyle: GoogleFonts.poppins(color: Colors.grey.shade600),
            prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
          ),
          onSubmitted: (searchTerm) {
            // TODO: Implementar busca chamando o notifier
            notifier.loadOrdensServico(searchTerm: searchTerm, refresh: true);
          },
        ),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Seção de Filtros
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () { /* TODO: Implementar ação de abrir filtros avançados */ },
                    icon: const Icon(Icons.filter_list, size: 18, color: Colors.white),
                    label: Text('Filtros', style: GoogleFonts.poppins(color: Colors.white, fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip('Status'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Data'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Técnico'),
                  // TODO: Adicionar mais filtros se necessário
                ],
              ),
            ),
          ),
          const Divider(height: 1, thickness: 1),
          // Conteúdo Principal (Lista, Loading, Erro)
          Expanded(
            child: _buildBodyContent(state, notifier, primaryColor),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navegar para a tela de Nova OS
          // Navigator.of(context).pushNamed('/nova-os');
        },
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Constrói o conteúdo principal baseado no estado
  Widget _buildBodyContent(OsListState state, OsListNotifier notifier, Color primaryColor) {
    if (state.isLoading && state.ordensServico.isEmpty) {
      // Mostra loading apenas na carga inicial ou quando não há dados prévios
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else if (state.errorMessage != null && state.ordensServico.isEmpty) {
      // Mostra erro apenas se não houver dados antigos para exibir
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red.shade400, size: 50),
              const SizedBox(height: 16),
              Text(
                'Erro ao carregar Ordens de Serviço',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                state.errorMessage!,
                style: GoogleFonts.poppins(color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => notifier.loadOrdensServico(refresh: true), // Tenta novamente
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar Novamente'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white
                ),
              ),
            ],
          ),
        ),
      );
    } else if (state.ordensServico.isEmpty && !state.isLoading) {
      // Mostra mensagem de lista vazia
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.list_alt_outlined, size: 60, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Nenhuma Ordem de Serviço encontrada',
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 8),
            Text(
              'Crie uma nova OS ou ajuste os filtros.',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    } else {
      // Mostra a lista (com RefreshIndicator)
      return RefreshIndicator(
        onRefresh: () => notifier.loadOrdensServico(refresh: true), // Puxar para atualizar
        child: ListView.builder(
          padding: const EdgeInsets.all(12.0),
          itemCount: state.ordensServico.length,
          itemBuilder: (context, index) {
            final os = state.ordensServico[index];
            return _buildOsCard(os, primaryColor);
          },
        ),
      );
    }
  }

  // Widget para construir os chips de filtro
  Widget _buildFilterChip(String label) {
    // TODO: Conectar este chip ao estado/provider para aplicar filtros
    return ActionChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade800)),
          const SizedBox(width: 4),
          Icon(Icons.arrow_drop_down, size: 18, color: Colors.grey.shade600),
        ],
      ),
      onPressed: () {
        // TODO: Implementar ação de abrir o filtro específico (ex: mostrar BottomSheet)
      },
      backgroundColor: Colors.grey.shade100,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: BorderSide(color: Colors.grey.shade300, width: 0.5)
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    );
  }

  // Widget para construir o card da Ordem de Serviço
  Widget _buildOsCard(OrdemServico os, Color primaryColor) {
    print('OS ID: ${os.id}');
    print('Nome do Cliente: ${os.cliente.nomeCompleto}');
    print('Tecnico Atribuido: ${os.tecnicoAtribuido}');
    if (os.tecnicoAtribuido != null) {
      print('Nome do Técnico: ${os.tecnicoAtribuido!.nome}');
      print('ID do Técnico: ${os.tecnicoAtribuido!.id}');
    } else {
      print('Técnico atribuído é NULL');
    }
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: InkWell( // Adiciona InkWell para feedback de toque
        onTap: () {
          // Simplesmente navega para a tela de detalhes.
          // A tela de detalhes cuidará da invalidação do osListProvider ao retornar.
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => OsDetailScreen(osId: os.id!),
            ),
          );
        },
        borderRadius: BorderRadius.circular(8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        '#${os.numeroOS}',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        label: Text(
                          _getStatusText(os.status),
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: _getStatusTextColor(os.status),
                          ),
                        ),
                        backgroundColor: _getStatusBackgroundColor(os.status),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                        labelPadding: EdgeInsets.zero,
                        side: BorderSide.none,
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () { /* TODO: Implementar menu de opções (ex: editar, excluir) */ },
                    child: Icon(Icons.more_vert, color: Colors.grey.shade500, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                os.cliente.nomeCompleto.toString(),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                os.problemaRelatado.toString(),
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, thickness: 0.5),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.person_outline, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        os.tecnicoAtribuido?.nome ?? 'Não atribuído',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(os.dataAgendamento ?? os.dataAbertura),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}