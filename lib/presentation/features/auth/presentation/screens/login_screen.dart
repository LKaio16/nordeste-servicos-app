// lib/presentation/features/auth/presentation/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Importe o Riverpod

import '../../providers/auth_provider.dart';
import '../../providers/auth_state.dart'; // Importe o provider de autenticação

class LoginScreen extends ConsumerWidget {
  // Controllers para pegar o texto dos campos de entrada
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  LoginScreen({super.key}); // Construtor com key opcional

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observa o estado do authProvider. A UI será reconstruída quando o estado mudar.
    final authState = ref.watch(authProvider);

    // Obtém a instância do notifier para chamar métodos (login, logout)
    final authNotifier = ref.read(authProvider.notifier);

    // Adicionar um Listener para navegar após o login bem-sucedido
    // ref.listen<AuthState>(authProvider, (previousState, newState) {
    //   // Verifica se o usuário acabou de se autenticar com sucesso
    //   if (newState.isAuthenticated && previousState?.isAuthenticated == false) {
    //     // Navegar para a tela principal (sua HomeScreenExample)
    //     Navigator.of(context).pushReplacementNamed('/home'); // Use o nome da sua rota para a tela Home
    //   }
    //   // Adiciona um listener para mostrar mensagens de erro
    //   if (newState.errorMessage != null && previousState?.errorMessage == null) {
    //     // Mostrar um SnackBar com a mensagem de erro
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: Text(newState.errorMessage!)),
    //     );
    //   }
    // });

    // Mantenha apenas o listener para exibir o SnackBar de erro.
// Assim, a LoginScreen só se preocupa em mostrar erros.
    ref.listen<AuthState>(authProvider, (previousState, newState) {
      if (newState.errorMessage != null &&
          previousState?.errorMessage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(newState.errorMessage!)),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true, // Centraliza o título
      ),
      body: Center(
        // Centraliza o conteúdo
        child: SingleChildScrollView(
          // Permite scrollar se o conteúdo for maior que a tela
          padding: const EdgeInsets.all(24.0), // Padding ao redor do formulário
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            // Centraliza na coluna
            crossAxisAlignment: CrossAxisAlignment.stretch,
            // Estica os widgets horizontalmente
            children: <Widget>[
              // Campo de E-mail/Usuário
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-mail ou Usuário',
                  border: OutlineInputBorder(), // Borda arredondada
                  prefixIcon: Icon(Icons.person_outline), // Ícone
                ),
                keyboardType: TextInputType.emailAddress, // Teclado para e-mail
              ),
              const SizedBox(height: 16.0),
              // Espaço entre os campos

              // Campo de Senha
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true, // Esconde a senha
              ),
              const SizedBox(height: 24.0),
              // Espaço antes do botão

              // Botão de Login
              ElevatedButton(
                onPressed: authState
                        .isLoading // Desabilita o botão enquanto estiver carregando
                    ? null
                    : () {
                        // Chamar o método login do provider quando o botão for pressionado
                        authNotifier.login(
                          _emailController.text,
                          _passwordController.text,
                        );
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  // Padding no botão
                  shape: RoundedRectangleBorder(
                    // Borda arredondada
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: authState
                        .isLoading // Mostra um indicador de loading ou o texto do botão
                    ? const SizedBox(
                        height: 20.0,
                        width: 20.0,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          // Cor branca para o loading
                          strokeWidth: 3.0,
                        ),
                      )
                    : const Text(
                        'Entrar',
                        style: TextStyle(fontSize: 18.0), // Tamanho do texto
                      ),
              ),
              const SizedBox(height: 12.0),
              // Espaço para a mensagem de erro

              // Exibe a mensagem de erro, se houver
              if (authState.errorMessage != null)
                Text(
                  authState.errorMessage!,
                  // Usa o '!' pois verificamos que não é nulo
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 14.0,
                  ),
                  textAlign: TextAlign.center, // Centraliza o texto de erro
                ),

              // TODO: Adicionar link para "Esqueci minha senha" ou "Criar conta" se aplicável
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Lembre-se de liberar os controladores quando o widget não for mais necessário
    _emailController.dispose();
    _passwordController.dispose();
    // dispose() só é chamado em StatefulWidgets. Em ConsumerWidget,
    // você pode usar `ref.onDispose` no provider se a lógica de dispose
    // for mais acoplada ao provider do que ao widget.
  }
}
