import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Importe o Riverpod

// NOVO: Importar o auth_provider
import 'package:nordeste_servicos_app/presentation/features/auth/providers/auth_provider.dart';


// Arquivo: home_screen_tecnico.dart

// Modelos de Dados (PODOs)
class UsuarioInfo {
  final String avatarUrl;
  final String nomeUsuario;
  final String idTecnico;
  final int numeroNotificacoes;

  UsuarioInfo({
    required this.avatarUrl,
    required this.nomeUsuario,
    required this.idTecnico,
    required this.numeroNotificacoes,
  });
}

class OrdemServico {
  final String id;
  final String numeroOS;
  final String nomeCliente;
  final String descricaoServico;
  final String dataHoraAgendamento;
  final String statusOS;
  final String? prioridade; // Opcional, usado no card de destaque
  final IconData tipoServicoIcone;
  final IconData agendamentoIcone;

  OrdemServico({
    required this.id,
    required this.numeroOS,
    required this.nomeCliente,
    required this.descricaoServico,
    required this.dataHoraAgendamento,
    required this.statusOS,
    this.prioridade,
    this.tipoServicoIcone = Icons.build_outlined, // Ícone padrão
    this.agendamentoIcone = Icons.schedule_outlined, // Ícone padrão
  });
}

// Dados Mocado
final UsuarioInfo mockUsuario = UsuarioInfo(
  avatarUrl: "https://i.pravatar.cc/150?img=12", // Placeholder avatar
  nomeUsuario: "Carlos Silva",
  idTecnico: "#4523",
  numeroNotificacoes: 3,
);

final OrdemServico mockOsDestaque = OrdemServico(
  id: "2547",
  numeroOS: "OS #2547 - Manutenção Preventiva",
  nomeCliente: "Supermercado Extra",
  descricaoServico: "Manutenção Preventiva Completa",
  dataHoraAgendamento: "Hoje, 14:30",
  statusOS: "Em Andamento",
  prioridade: "Urgente",
);

final List<OrdemServico> mockListaMinhasOS = [
  OrdemServico(
    id: "2547",
    numeroOS: "OS #2547",
    nomeCliente: "Supermercado Extra",
    descricaoServico: "Manutenção Preventiva",
    dataHoraAgendamento: "Hoje, 14:30",
    statusOS: "Em Andamento",
  ),
  OrdemServico(
    id: "2548",
    numeroOS: "OS #2548",
    nomeCliente: "Farmácia São João",
    descricaoServico: "Instalação de Equipamento",
    dataHoraAgendamento: "Amanhã, 09:00",
    statusOS: "Em Aberto",
  ),
  OrdemServico(
    id: "2549",
    numeroOS: "OS #2549",
    nomeCliente: "Padaria Pão Quente",
    descricaoServico: "Reparo Urgente em Forno",
    dataHoraAgendamento: "Hoje, 18:00",
    statusOS: "Em Aberto",
    prioridade: "Urgente",
  ),
];

// Cores (conforme análise visual)
const Color corPrimariaAzul = Color(0xFF1976D2); // Azul escuro (ex: AppBar, botões)
const Color corLaranja = Color(0xFFFFA000); // Laranja (ex: botão Continuar OS, tag Urgente)
const Color corTagEmAndamento = Color(0xFFFFF3E0); // Bege/amarelo claro
const Color corTextoTagEmAndamento = Color(0xFFE65100);
const Color corTagEmAberto = Color(0xFFE3F2FD); // Azul claro
const Color corTextoTagEmAberto = Color(0xFF0D47A1);


// Altere esta classe para ConsumerWidget se você quiser que ela acesse o Riverpod diretamente
// OU, passe o ref para o _buildAppBar se mantiver como StatefulWidget e _buildAppBar for uma função separada
class TecnicoHomeScreen extends ConsumerStatefulWidget { // Renomeado de HomeScreenExample
  const TecnicoHomeScreen({super.key});

  @override
  ConsumerState<TecnicoHomeScreen> createState() => _TecnicoHomeScreenState(); // Alterado para ConsumerState
}

class _TecnicoHomeScreenState extends ConsumerState<TecnicoHomeScreen> { // Alterado para ConsumerState
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // TODO: Adicionar lógica de navegação real aqui
    // if (index == 0) Navigator.pushNamed(context, '/inicio');
    // etc.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Agora _buildAppBar precisa do ref para acessar o provider de logout
      appBar: _buildAppBar(context, mockUsuario, ref), // Passando o ref
      body: _buildBody(context, mockOsDestaque, mockListaMinhasOS),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: corPrimariaAzul,
        unselectedItemColor: Colors.grey[600],
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            label: 'Minhas OS',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

// Alterado para receber WidgetRef ref
PreferredSizeWidget _buildAppBar(BuildContext context, UsuarioInfo usuario, WidgetRef ref) {
  return AppBar(
    backgroundColor: corPrimariaAzul,
    elevation: 0,
    title: UserHeaderWidget(usuario: usuario),
    actions: [
      // Botão de Notificações
      Stack(
        alignment: Alignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined, color: Colors.white, size: 28),
            onPressed: () { /* TODO: Ação de notificações */ },
          ),
          if (usuario.numeroNotificacoes > 0)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  '${usuario.numeroNotificacoes}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      // Botão de Sair/Logout
      IconButton(
        icon: const Icon(Icons.logout, color: Colors.white, size: 28),
        onPressed: () {
          // Exibir um diálogo de confirmação antes de deslogar
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Confirmar Saída"),
                content: const Text("Tem certeza que deseja sair?"),
                actions: <Widget>[
                  TextButton(
                    child: const Text("Cancelar"),
                    onPressed: () {
                      Navigator.of(context).pop(); // Fecha o diálogo
                    },
                  ),
                  TextButton(
                    child: const Text("Sair"),
                    onPressed: () {
                      Navigator.of(context).pop(); // Fecha o diálogo
                      ref.read(authProvider.notifier).logout(); // Chama o método logout do authProvider
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
      const SizedBox(width: 8),
    ],
  );
}

Widget _buildBody(BuildContext context, OrdemServico osDestaque, List<OrdemServico> listaOS) {
  return SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OngoingOsCardWidget(os: osDestaque),
          const SizedBox(height: 24.0),
          MyOsListSectionWidget(listaOS: listaOS),
        ],
      ),
    ),
  );
}

// Widgets Customizados (permanecem os mesmos)

class UserHeaderWidget extends StatelessWidget {
  final UsuarioInfo usuario;
  const UserHeaderWidget({super.key, required this.usuario});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage(usuario.avatarUrl),
          backgroundColor: Colors.white24,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              usuario.nomeUsuario,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              "Técnico ID: ${usuario.idTecnico}",
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }
}

class OngoingOsCardWidget extends StatelessWidget {
  final OrdemServico os;
  const OngoingOsCardWidget({super.key, required this.os});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Em Andamento",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: corLaranja),
                ),
                if (os.prioridade == "Urgente")
                  Chip(
                    label: Text(os.prioridade!),
                    backgroundColor: corLaranja,
                    labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              os.numeroOS, // No design original, parece ser o título completo
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              "Cliente: ${os.nomeCliente}",
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () { /* TODO: Ação Continuar OS */ },
                style: ElevatedButton.styleFrom(
                  backgroundColor: corLaranja,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                ),
                child: const Text("Continuar OS", style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyOsListSectionWidget extends StatelessWidget {
  final List<OrdemServico> listaOS;
  const MyOsListSectionWidget({super.key, required this.listaOS});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Minhas OS",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.filter_list, color: Colors.grey[700]),
                  onPressed: () { /* TODO: Ação de filtro */ },
                ),
                IconButton(
                  icon: Icon(Icons.sort, color: Colors.grey[700]), // Ou Icons.swap_vert
                  onPressed: () { /* TODO: Ação de ordenação */ },
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (listaOS.isEmpty)
          const Center(child: Text("Nenhuma Ordem de Serviço encontrada."))
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(), // Para não ter scroll dentro do SingleChildScrollView
            itemCount: listaOS.length,
            itemBuilder: (context, index) {
              return OsListItemCardWidget(os: listaOS[index]);
            },
            separatorBuilder: (context, index) => const SizedBox(height: 12),
          ),
      ],
    );
  }
}

class OsListItemCardWidget extends StatelessWidget {
  final OrdemServico os;
  const OsListItemCardWidget({super.key, required this.os});

  Color _getStatusColorBg(String status) {
    if (status == "Em Andamento") return corTagEmAndamento;
    if (status == "Em Aberto") return corTagEmAberto;
    return Colors.grey[200]!;
  }

  Color _getStatusColorText(String status) {
    if (status == "Em Andamento") return corTextoTagEmAndamento;
    if (status == "Em Aberto") return corTextoTagEmAberto;
    return Colors.grey[700]!;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  os.numeroOS,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Chip(
                  label: Text(os.statusOS),
                  backgroundColor: _getStatusColorBg(os.statusOS),
                  labelStyle: TextStyle(color: _getStatusColorText(os.statusOS), fontWeight: FontWeight.w500, fontSize: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              os.nomeCliente,
              style: TextStyle(fontSize: 14, color: Colors.grey[800]),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(os.tipoServicoIcone, size: 16, color: Colors.grey[700]),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    os.descricaoServico,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(os.agendamentoIcone, size: 16, color: Colors.grey[700]),
                const SizedBox(width: 6),
                Text(
                  os.dataHoraAgendamento,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () { /* TODO: Ação Ver Detalhes */ },
                style: ElevatedButton.styleFrom(
                  backgroundColor: corPrimariaAzul,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                ),
                child: const Text("Ver Detalhes", style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}