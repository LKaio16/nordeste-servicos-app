import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Página Orçamentos (Placeholder)
class OrcamentosListScreen extends StatelessWidget {
  const OrcamentosListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Orçamentos', style: GoogleFonts.poppins()),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Text(
          "Conteúdo da Lista de Orçamentos",
          style: GoogleFonts.poppins(fontSize: 20),
        ),
      ),
      // Adicione um FloatingActionButton para criar novo orçamento, se aplicável
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => Navigator.of(context).pushNamed('/novo-orcamento'),
      //   child: Icon(Icons.add),
      // ),
    );
  }
}

