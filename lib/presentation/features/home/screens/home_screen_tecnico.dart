import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart'; // Importando Google Fonts para fontes modernas

// NOVO: Importar o auth_provider
import 'package:nordeste_servicos_app/presentation/features/auth/providers/auth_provider.dart';

// Arquivo: home_screen_tecnico.dart

// Definição de cores modernizadas
class AppColors {
  // Cores principais
  static const Color primaryBlue = Color(0xFF1A73E8); // Azul principal mais vibrante
  static const Color secondaryBlue = Color(0xFF4285F4); // Azul secundário
  static const Color accentBlue = Color(0xFF8AB4F8); // Azul claro para acentos
  static const Color darkBlue = Color(0xFF0D47A1); // Azul escuro para detalhes

  // Cores de status
  static const Color successGreen = Color(0xFF34A853); // Verde mais moderno
  static const Color warningOrange = Color(0xFFFFA000); // Laranja mais vibrante
  static const Color errorRed = Color(0xFFEA4335); // Vermelho mais moderno

  // Cores de fundo e texto
  static const Color backgroundGray = Color(0xFFF8F9FA); // Fundo cinza claro
  static const Color cardBackground = Colors.white; // Fundo dos cards
  static const Color textDark = Color(0xFF202124); // Texto escuro
  static const Color textLight = Color(0xFF5F6368); // Texto cinza
  static const Color dividerColor = Color(0xFFEEEEEE); // Cor para divisores

  // Cores de status de OS
  static const Color emAndamentoBg = Color(0xFFFFF3E0); // Fundo para status "Em Andamento"
  static const Color emAndamentoText = Color(0xFFE65100); // Texto para status "Em Andamento"
  static const Color emAbertoBg = Color(0xFFE3F2FD); // Fundo para status "Em Aberto"
  static const Color emAbertoText = Color(0xFF0D47A1); // Texto para status "Em Aberto"
}

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

class TecnicoHomeScreen extends ConsumerStatefulWidget {
  const TecnicoHomeScreen({super.key});

  @override
  ConsumerState<TecnicoHomeScreen> createState() => _TecnicoHomeScreenState();
}

class _TecnicoHomeScreenState extends ConsumerState<TecnicoHomeScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;

  // Adicionando animação para melhorar a experiência do usuário
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();

    // Configuração da animação
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.1, 1.0, curve: Curves.easeOut),
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

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
      backgroundColor: AppColors.backgroundGray,
      appBar: _buildAppBar(context, mockUsuario, ref),
      body: _buildBody(context, mockOsDestaque, mockListaMinhasOS),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.textLight,
        selectedLabelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'Minhas OS',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

PreferredSizeWidget _buildAppBar(BuildContext context, UsuarioInfo usuario, WidgetRef ref) {
  return AppBar(
    backgroundColor: AppColors.primaryBlue,
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
                  color: AppColors.errorRed,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                child: Text(
                  '${usuario.numeroNotificacoes}',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      // Botão de Sair/Logout
      IconButton(
        icon: const Icon(Icons.logout_outlined, color: Colors.white, size: 26),
        onPressed: () {
          // Exibir um diálogo de confirmação antes de deslogar
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                  "Confirmar Saída",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                content: Text(
                  "Tem certeza que deseja sair?",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text(
                      "Cancelar",
                      style: GoogleFonts.poppins(
                        color: AppColors.textLight,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(); // Fecha o diálogo
                    },
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: Text(
                      "Sair",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
  return SafeArea(
    child: Stack(
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

        // Conteúdo principal
        SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabeçalho de boas-vindas
                _buildWelcomeHeader(context),
                const SizedBox(height: 24.0),

                // OS em andamento
                OngoingOsCardWidget(os: osDestaque),
                const SizedBox(height: 24.0),

                // Lista de OS
                MyOsListSectionWidget(listaOS: listaOS),

                // Espaço extra no final
                const SizedBox(height: 16.0),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildWelcomeHeader(BuildContext context) {
  final now = DateTime.now();
  final hour = now.hour;

  String greeting;
  if (hour < 12) {
    greeting = "Bom dia";
  } else if (hour < 18) {
    greeting = "Boa tarde";
  } else {
    greeting = "Boa noite";
  }

  return Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [AppColors.primaryBlue, AppColors.secondaryBlue],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: AppColors.primaryBlue.withOpacity(0.3),
          blurRadius: 10,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$greeting, ${mockUsuario.nomeUsuario.split(' ').first}!",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 4),
        Text(
          "Você tem ${mockListaMinhasOS.length} ordens de serviço hoje",
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    ),
  );
}

// Widgets Customizados Redesenhados

class UserHeaderWidget extends StatelessWidget {
  final UsuarioInfo usuario;
  const UserHeaderWidget({super.key, required this.usuario});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.white,
          child: CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage(usuario.avatarUrl),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              usuario.nomeUsuario,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Técnico ID: ${usuario.idTecnico}",
              style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.9),
                fontSize: 12,
              ),
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
      elevation: 4,
      shadowColor: AppColors.primaryBlue.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.warningOrange.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.play_circle_outline,
                        color: AppColors.warningOrange,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Em Andamento",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.warningOrange,
                      ),
                    ),
                  ],
                ),
                if (os.prioridade == "Urgente")
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.warningOrange,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.warningOrange.withOpacity(0.3),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      os.prioridade!,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              os.numeroOS,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.business_outlined,
                  size: 18,
                  color: AppColors.textLight,
                ),
                SizedBox(width: 8),
                Text(
                  "Cliente: ${os.nomeCliente}",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.description_outlined,
                  size: 18,
                  color: AppColors.textLight,
                ),
                SizedBox(width: 8),
                Text(
                  os.descricaoServico,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.schedule_outlined,
                  size: 18,
                  color: AppColors.textLight,
                ),
                SizedBox(width: 8),
                Text(
                  os.dataHoraAgendamento,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.warningOrange, Color(0xFFFF8F00)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.warningOrange.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () { /* TODO: Ação Continuar OS */ },
                icon: Icon(Icons.play_arrow, color: Colors.white),
                label: Text(
                  "Continuar OS",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
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
    return Card(
      elevation: 4,
      shadowColor: AppColors.primaryBlue.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.assignment_outlined,
                        color: AppColors.primaryBlue,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Minhas OS",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.backgroundGray,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.filter_list,
                          color: AppColors.textLight,
                          size: 20,
                        ),
                        onPressed: () { /* TODO: Ação de filtro */ },
                        tooltip: "Filtrar",
                        constraints: BoxConstraints.tightFor(
                          width: 36,
                          height: 36,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.backgroundGray,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.sort,
                          color: AppColors.textLight,
                          size: 20,
                        ),
                        onPressed: () { /* TODO: Ação de ordenação */ },
                        tooltip: "Ordenar",
                        constraints: BoxConstraints.tightFor(
                          width: 36,
                          height: 36,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (listaOS.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.assignment_outlined,
                      size: 48,
                      color: AppColors.textLight.withOpacity(0.5),
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Nenhuma Ordem de Serviço encontrada.",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: AppColors.textLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: listaOS.length,
                itemBuilder: (context, index) {
                  return OsListItemCardWidget(os: listaOS[index]);
                },
                separatorBuilder: (context, index) => const SizedBox(height: 16),
              ),
          ],
        ),
      ),
    );
  }
}

class OsListItemCardWidget extends StatelessWidget {
  final OrdemServico os;
  const OsListItemCardWidget({super.key, required this.os});

  Color _getStatusColorBg(String status) {
    if (status == "Em Andamento") return AppColors.emAndamentoBg;
    if (status == "Em Aberto") return AppColors.emAbertoBg;
    return Colors.grey[200]!;
  }

  Color _getStatusColorText(String status) {
    if (status == "Em Andamento") return AppColors.emAndamentoText;
    if (status == "Em Aberto") return AppColors.emAbertoText;
    return Colors.grey[700]!;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
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
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColorBg(os.statusOS),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    os.statusOS,
                    style: GoogleFonts.poppins(
                      color: _getStatusColorText(os.statusOS),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.business_outlined,
                  size: 18,
                  color: AppColors.textLight,
                ),
                SizedBox(width: 8),
                Text(
                  os.nomeCliente,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  os.tipoServicoIcone,
                  size: 18,
                  color: AppColors.textLight,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    os.descricaoServico,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  os.agendamentoIcone,
                  size: 18,
                  color: AppColors.textLight,
                ),
                SizedBox(width: 8),
                Text(
                  os.dataHoraAgendamento,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 46,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryBlue, AppColors.secondaryBlue],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () { /* TODO: Ação Ver Detalhes */ },
                icon: Icon(Icons.visibility_outlined, color: Colors.white),
                label: Text(
                  "Ver Detalhes",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
