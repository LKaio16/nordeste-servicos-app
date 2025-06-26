import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nordeste_servicos_app/presentation/features/equipamentos/screens/equipamento_list_screen.dart';
import 'package:nordeste_servicos_app/presentation/features/funcionario/screens/funcionario_list_screen.dart';
import 'package:nordeste_servicos_app/presentation/features/funcionario/screens/novo_tecnico_screen.dart';
import '../../clientes/screens/cliente_list_screen.dart';
import '../../clientes/screens/novo_cliente_screen.dart';
import '../../equipamentos/screens/novo_equipamento_screen.dart';
import '../../pecas/screens/nova_peca_material_screen.dart';
import '../../pecas/screens/peca_material_list_screen.dart';


// TELA PRINCIPAL DE GESTÃO
class GestaoScreen extends StatelessWidget {
  const GestaoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Helper para navegação, para evitar repetição de código
    void navigateTo(Widget screen) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => screen),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Gestão', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false, // Remove a seta de "voltar" se não for necessária
      ),
      backgroundColor: const Color(0xFFF8F9FA), // Um cinza bem claro para o fundo
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        children: [
          ManagementCard(
            icon: Icons.people_outline,
            title: 'Clientes',
            subtitle: 'Gerenciar cadastros de clientes',
            // <<< 2. NAVEGAÇÃO AJUSTADA PARA AS TELAS REAIS >>>
            onCardTap: () => navigateTo(const ClienteListScreen()),
            onAddButtonTap: () => navigateTo(const NovoClienteScreen()),
          ),
          const SizedBox(height: 16),
          ManagementCard(
            icon: Icons.build_outlined,
            title: 'Equipamentos',
            subtitle: 'Gerenciar cadastros de equipamentos',
            onCardTap: () => navigateTo(const EquipamentoListScreen()),
            onAddButtonTap: () => navigateTo(const NovoEquipamentoScreen()),
          ),
          const SizedBox(height: 16),
          ManagementCard(
            icon: Icons.person_outline,
            title: 'Funcionários',
            subtitle: 'Gerenciar cadastros de técnicos',
            onCardTap: () => navigateTo(const FuncionarioListScreen()),
            onAddButtonTap: () => navigateTo(const NovoTecnicoScreen()),
          ),
          const SizedBox(height: 16),
          ManagementCard(
            icon: Icons.construction_outlined,
            title: 'Peças/Materiais',
            subtitle: 'Gerenciar estoque de peças',
            onCardTap: () => navigateTo(const PecasListScreen()),
            onAddButtonTap: () => navigateTo(const NovaPecaScreen()),
          ),
          const SizedBox(height: 16),
          ManagementCard(
            icon: Icons.miscellaneous_services_outlined,
            title: 'Serviços',
            subtitle: 'Gerenciar tipos de serviços',
            onCardTap: () => navigateTo(const ServicosListScreen()),
            onAddButtonTap: () => navigateTo(const NovoServicoScreen()),
          ),
        ],
      ),
    );
  }
}

// WIDGET REUTILIZÁVEL PARA O CARD (sem alterações)
class ManagementCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onCardTap;
  final VoidCallback onAddButtonTap;

  const ManagementCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onCardTap,
    required this.onAddButtonTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: onCardTap,
        borderRadius: BorderRadius.circular(12.0),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          leading: Icon(
            icon,
            size: 40.0,
            color: const Color(0xFF3A5A98),
          ),
          title: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF202124),
            ),
          ),
          subtitle: Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF5F6368),
            ),
          ),
          trailing: InkWell(
            onTap: onAddButtonTap,
            borderRadius: BorderRadius.circular(50),
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: const BoxDecoration(
                color: Color(0xFF3A5A98),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }
}


// TELAS DE DESTINO (EXEMPLOS / PLACEHOLDERS PARA AS OUTRAS SEÇÕES)
// Estas são as telas para as quais os outros cards irão navegar.
// Você pode substituí-las por suas telas reais quando as criar.

// --- TELAS DE LISTAGEM ---



class ServicosListScreen extends StatelessWidget {
  const ServicosListScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lista de Serviços', style: GoogleFonts.poppins())),
      body: Center(child: Text('Aqui ficará a sua lista de serviços.', style: GoogleFonts.poppins())),
    );
  }
}

// --- TELAS DE CRIAÇÃO ---


class NovoServicoScreen extends StatelessWidget {
  const NovoServicoScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Novo Serviço', style: GoogleFonts.poppins())),
      body: Center(child: Text('Formulário de criação de serviço.', style: GoogleFonts.poppins())),
    );
  }
}