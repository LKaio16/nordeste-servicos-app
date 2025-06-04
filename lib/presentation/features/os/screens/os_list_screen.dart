import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Página Lista OS (Placeholder)
class OsListScreen extends StatelessWidget {
  const OsListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Ordens de Serviço', style: GoogleFonts.poppins()),
        automaticallyImplyLeading: false, // Remover botão de voltar se esta for uma página principal da aba
      ),
      body: Center(
        child: Text(
          "Conteúdo da Lista de OS",
          style: GoogleFonts.poppins(fontSize: 20),
        ),
      ),
      // Adicione um FloatingActionButton para criar nova OS, se aplicável
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => Navigator.of(context).pushNamed('/nova-os'),
      //   child: Icon(Icons.add),
      // ),
    );
  }
}

