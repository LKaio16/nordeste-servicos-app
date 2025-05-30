// lib/presentation/features/cliente/presentation/screens/novo_cliente_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Importar o enum TipoCliente (ajuste o caminho se necessário)
import '../../../../data/models/tipo_cliente.dart';

// Importar o provider e o estado
import '../providers/novo_cliente_provider.dart';
import '../providers/novo_cliente_state.dart';

class NovoClienteScreen extends ConsumerStatefulWidget {
  const NovoClienteScreen({super.key});

  @override
  ConsumerState<NovoClienteScreen> createState() => _NovoClienteScreenState();
}

class _NovoClienteScreenState extends ConsumerState<NovoClienteScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para os campos de texto
  final _nomeController = TextEditingController();
  final _cpfCnpjController = TextEditingController();
  final _emailController = TextEditingController();
  final _telPrincipalController = TextEditingController();
  final _telAdicionalController = TextEditingController();
  final _cepController = TextEditingController();
  final _ruaController = TextEditingController();
  final _numeroController = TextEditingController();
  final _complementoController = TextEditingController();
  final _bairroController = TextEditingController();
  final _cidadeController = TextEditingController();

  // Estado para o tipo de cliente selecionado
  TipoCliente _tipoClienteSelecionado = TipoCliente.PESSOA_FISICA;

  // Estado para o estado selecionado (exemplo, precisa de uma lista real)
  String? _estadoSelecionado;
  final List<String> _estados = [
    'AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA', 'MT', 'MS',
    'MG', 'PA', 'PB', 'PR', 'PE', 'PI', 'RJ', 'RN', 'RS', 'RO', 'RR', 'SC',
    'SP', 'SE', 'TO'
  ]; // Exemplo de lista de estados

  @override
  void dispose() {
    // Limpar os controladores
    _nomeController.dispose();
    _cpfCnpjController.dispose();
    _emailController.dispose();
    _telPrincipalController.dispose();
    _telAdicionalController.dispose();
    _cepController.dispose();
    _ruaController.dispose();
    _numeroController.dispose();
    _complementoController.dispose();
    _bairroController.dispose();
    _cidadeController.dispose();
    super.dispose();
  }

  void _salvarCliente() {
    // Limpa o foco para esconder o teclado
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      ref.read(novoClienteProvider.notifier).salvarCliente(
        tipoCliente: _tipoClienteSelecionado,
        nomeCompleto: _nomeController.text,
        cpfCnpj: _cpfCnpjController.text,
        email: _emailController.text,
        telefonePrincipal: _telPrincipalController.text,
        telefoneAdicional: _telAdicionalController.text.isNotEmpty ? _telAdicionalController.text : null,
        cep: _cepController.text,
        rua: _ruaController.text,
        numero: _numeroController.text,
        complemento: _complementoController.text.isNotEmpty ? _complementoController.text : null,
        bairro: _bairroController.text,
        cidade: _cidadeController.text,
        estado: _estadoSelecionado!, // Já validado pelo form
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Observar o estado do provider
    final state = ref.watch(novoClienteProvider);

    // Escutar mudanças no estado para feedback (Snackbar/Navegação)
    ref.listen<NovoClienteState>(novoClienteProvider, (previous, next) {
      // Mostrar erro se houver
      if (next.submissionError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.submissionError!), backgroundColor: Colors.red),
        );
      }

      // Verificar se o envio foi concluído com sucesso (sem erro e não está mais enviando)
      if (previous?.isSubmitting == true && next.isSubmitting == false && next.submissionError == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cliente salvo com sucesso!'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Cliente'),
        actions: [
          // Mostrar indicador de carregamento ou botão de salvar
          if (state.isSubmitting)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.0))),
            )
          else
            TextButton(
              // Desabilitar o botão durante o envio
              onPressed: state.isSubmitting ? null : _salvarCliente,
              child: const Text('Salvar', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTipoClienteSelector(),
              const SizedBox(height: 24),
              _buildSectionTitle('Informações Pessoais'),
              _buildTextFormField(_nomeController, 'Nome Completo'),
              _buildTextFormField(_cpfCnpjController, 'CPF/CNPJ'), // TODO: Adicionar máscara
              _buildTextFormField(_emailController, 'Email', keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 24),
              _buildSectionTitle('Contato'),
              _buildTextFormField(_telPrincipalController, 'Telefone Principal', keyboardType: TextInputType.phone), // TODO: Adicionar máscara
              _buildTextFormField(_telAdicionalController, 'Telefone Adicional (Opcional)', isOptional: true, keyboardType: TextInputType.phone), // TODO: Adicionar máscara
              const SizedBox(height: 24),
              _buildSectionTitle('Endereço'),
              _buildTextFormField(_cepController, 'CEP', keyboardType: TextInputType.number), // TODO: Adicionar máscara e busca de endereço
              _buildTextFormField(_ruaController, 'Rua'),
              Row(
                children: [
                  Expanded(child: _buildTextFormField(_numeroController, 'Número', keyboardType: TextInputType.number)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextFormField(_complementoController, 'Complemento', isOptional: true)),
                ],
              ),
              _buildTextFormField(_bairroController, 'Bairro'),
              Row(
                children: [
                  Expanded(child: _buildTextFormField(_cidadeController, 'Cidade')),
                  const SizedBox(width: 16),
                  Expanded(child: _buildEstadoDropdown()),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
      ),
    );
  }

  Widget _buildTipoClienteSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tipo de Cliente', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        ToggleButtons(
          isSelected: [
            _tipoClienteSelecionado == TipoCliente.PESSOA_FISICA,
            _tipoClienteSelecionado == TipoCliente.PESSOA_JURIDICA,
          ],
          onPressed: (index) {
            setState(() {
              _tipoClienteSelecionado = index == 0 ? TipoCliente.PESSOA_FISICA : TipoCliente.PESSOA_JURIDICA;
            });
          },
          borderRadius: BorderRadius.circular(8.0),
          selectedBorderColor: Colors.blue,
          selectedColor: Colors.white,
          fillColor: Colors.blue,
          color: Colors.blue,
          constraints: BoxConstraints(minWidth: (MediaQuery.of(context).size.width - 48) / 2, minHeight: 40.0),
          children: const [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.person), SizedBox(width: 8), Text('Pessoa Física')]),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.business), SizedBox(width: 8), Text('Pessoa Jurídica')]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextFormField(TextEditingController controller, String label, {bool isOptional = false, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        ),
        validator: (value) {
          if (!isOptional && (value == null || value.isEmpty)) {
            return 'Campo obrigatório';
          }
          // TODO: Adicionar validações específicas (email, CPF/CNPJ, CEP)
          return null;
        },
      ),
    );
  }

  Widget _buildEstadoDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: _estadoSelecionado,
        hint: const Text('Selecione'),
        decoration: InputDecoration(
          labelText: 'Estado',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        ),
        items: _estados.map((String estado) {
          return DropdownMenuItem<String>(
            value: estado,
            child: Text(estado),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _estadoSelecionado = newValue;
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Campo obrigatório';
          }
          return null;
        },
      ),
    );
  }
}

