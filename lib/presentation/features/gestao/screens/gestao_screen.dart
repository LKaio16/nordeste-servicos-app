import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Página Orçamentos (Placeholder)
class GestaoScreen extends StatelessWidget {
  const GestaoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestao', style: GoogleFonts.poppins()),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Text(
          "Conteúdo da Gestão",
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

