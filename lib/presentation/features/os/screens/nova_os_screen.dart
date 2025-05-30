// lib/presentation/features/os/presentation/screens/nova_os_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // Para formatação de data

// Use package imports for robustness
import 'package:nordeste_servicos_app/presentation/features/os/providers/nova_os_provider.dart';
import 'package:nordeste_servicos_app/presentation/features/os/providers/nova_os_state.dart';
import 'package:nordeste_servicos_app/domain/entities/cliente.dart';
import 'package:nordeste_servicos_app/domain/entities/equipamento.dart';
import 'package:nordeste_servicos_app/domain/entities/usuario.dart'; // Assumindo que Tecnico é um Usuario

// Definição de cores (reutilizando do admin_home_screen ou definindo novas se necessário)
class AppColors {
  static const Color primaryBlue = Color(0xFF0D47A1);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color darkGrey = Color(0xFF757575);
  static const Color mediumOrange = Color(0xFFFF9800); // Cor do botão Média
  static const Color errorRed = Color(0xFFE53935);
  static const Color successGreen = Color(0xFF4CAF50);
}

class NovaOsScreen extends ConsumerStatefulWidget {
  const NovaOsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<NovaOsScreen> createState() => _NovaOsScreenState();
}

class _NovaOsScreenState extends ConsumerState<NovaOsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descricaoController = TextEditingController();

  String? _selectedClienteId;
  String? _selectedEquipamentoId;
  String? _selectedTecnicoId;
  String _selectedPrioridade = 'Média'; // Valor inicial
  DateTime _selectedDataAbertura = DateTime.now();
  DateTime? _selectedDataAgendamento;

  @override
  void initState() {
    super.initState();
    // Chama a função do provider para carregar os dados iniciais
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(novaOsProvider.notifier).loadInitialData();
    });
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDataAgendamento ?? DateTime.now(),
      firstDate: DateTime.now(), // Não permitir agendar para o passado
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDataAgendamento) {
      setState(() {
        _selectedDataAgendamento = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final success = await ref.read(novaOsProvider.notifier).createOrdemServico(
        clienteId: _selectedClienteId!,
        equipamentoId: _selectedEquipamentoId!,
        descricaoProblema: _descricaoController.text,
        tecnicoId: _selectedTecnicoId!,
        prioridade: _selectedPrioridade,
        dataAbertura: _selectedDataAbertura,
        dataAgendamento: _selectedDataAgendamento,
      );

      if (success && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ordem de Serviço criada com sucesso!'), backgroundColor: AppColors.successGreen),
        );
      } else if (mounted) {
        // Erro já é tratado pelo estado do provider, mas podemos mostrar um SnackBar aqui também
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ref.read(novaOsProvider).submissionError ?? 'Erro ao criar OS.'), backgroundColor: AppColors.errorRed),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Observar o estado do provider
    final state = ref.watch(novaOsProvider);

    // Constrói as listas de DropdownMenuItem a partir do estado
    final clienteItems = state.clientes.map((Cliente cliente) {
      return DropdownMenuItem<String>(
        value: cliente.id.toString(), // Usar ID como valor
        child: Text(cliente.nomeRazaoSocial),
      );
    }).toList();

    // TODO: Filtrar equipamentos baseado no cliente selecionado, se necessário
    final equipamentoItems = state.equipamentos.map((Equipamento equipamento) {
      return DropdownMenuItem<String>(
        value: equipamento.id.toString(),
        child: Text('${equipamento.marcaModelo} (${equipamento.numeroSerieChassi})'),
      );
    }).toList();

    final tecnicoItems = state.tecnicos.map((Usuario tecnico) {
      return DropdownMenuItem<String>(
        value: tecnico.id.toString(),
        child: Text(tecnico.nome),
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Ordem de Serviço'),
        backgroundColor: AppColors.primaryBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          if (state.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (state.errorMessage != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.errorRed, size: 48),
                      const SizedBox(height: 16),
                      Text('Erro ao carregar dados: ${state.errorMessage}', textAlign: TextAlign.center, style: const TextStyle(color: AppColors.errorRed)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.read(novaOsProvider.notifier).loadInitialData(),
                        child: const Text('Tentar Novamente'),
                      )
                    ]),
              ),
            )
          else
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOsNumberDisplay(state.nextOsNumber), // Número da OS
                    const SizedBox(height: 16),
                    _buildDropdownFormField(
                      label: 'Cliente*',
                      hint: 'Selecione o cliente',
                      value: _selectedClienteId,
                      items: clienteItems,
                      onChanged: (value) {
                        setState(() {
                          _selectedClienteId = value;
                          _selectedEquipamentoId = null; // Limpa equipamento ao trocar cliente
                          // TODO: Chamar ref.read(novaOsProvider.notifier).loadEquipamentosPorCliente(value!);
                        });
                      },
                      validator: (value) => value == null ? 'Campo obrigatório' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildDropdownFormField(
                      label: 'Equipamento*',
                      hint: _selectedClienteId == null ? 'Selecione um cliente primeiro' : 'Selecione o equipamento',
                      value: _selectedEquipamentoId,
                      items: equipamentoItems, // Idealmente filtrados pelo cliente
                      onChanged: _selectedClienteId == null ? null : (value) {
                        setState(() {
                          _selectedEquipamentoId = value;
                        });
                      },
                      validator: (value) => value == null ? 'Campo obrigatório' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextFormField(
                      controller: _descricaoController,
                      label: 'Descrição do Problema*',
                      hint: 'Descreva o problema relatado',
                      maxLines: 4,
                      validator: (value) => (value == null || value.isEmpty) ? 'Campo obrigatório' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildDropdownFormField(
                      label: 'Técnico Responsável*',
                      hint: 'Selecione o técnico',
                      value: _selectedTecnicoId,
                      items: tecnicoItems,
                      onChanged: (value) {
                        setState(() {
                          _selectedTecnicoId = value;
                        });
                      },
                      validator: (value) => value == null ? 'Campo obrigatório' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildPrioridadeSelector(),
                    const SizedBox(height: 16),
                    _buildDateField(
                      label: 'Data de Abertura',
                      selectedDate: _selectedDataAbertura,
                      isEditable: false,
                    ),
                    const SizedBox(height: 16),
                    _buildDateField(
                      label: 'Data de Agendamento',
                      selectedDate: _selectedDataAgendamento,
                      isEditable: true,
                      onTap: () => _selectDate(context),
                    ),
                    const SizedBox(height: 24),
                    if (state.submissionError != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          'Erro ao criar OS: ${state.submissionError}',
                          style: const TextStyle(color: AppColors.errorRed),
                        ),
                      ),
                    _buildActionButtons(isSubmitting: state.isSubmitting),
                  ],
                ),
              ),
            ),
          // Overlay de loading durante o submit
          if (state.isSubmitting)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOsNumberDisplay(String? nextOsNumber) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Número da OS',
          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
        ),
        const SizedBox(height: 4),
        Text(
          nextOsNumber ?? '#----', // Mostra o número ou placeholder
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownFormField({
    required String label,
    required String hint,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?>? onChanged,
    required FormFieldValidator<String>? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[800]),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items,
          onChanged: onChanged,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Colors.grey[400]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Colors.grey[400]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            filled: onChanged == null, // Desabilita visualmente se onChanged for null
            fillColor: onChanged == null ? Colors.grey[200] : null,
          ),
          isExpanded: true,
        ),
      ],
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    FormFieldValidator<String>? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[800]),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[500]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Colors.grey[400]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Colors.grey[400]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
          ),
        ),
      ],
    );
  }

  Widget _buildPrioridadeSelector() {
    // Cores baseadas na imagem de referência
    const Map<String, Color> prioridadeColors = {
      'Baixa': AppColors.successGreen, // Ajustar se necessário
      'Média': AppColors.mediumOrange,
      'Alta': AppColors.errorRed,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Prioridade',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[800]),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: ['Baixa', 'Média', 'Alta'].map((prioridade) {
            bool isSelected = _selectedPrioridade == prioridade;
            Color selectedColor = prioridadeColors[prioridade] ?? AppColors.primaryBlue;

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: ChoiceChip(
                  label: SizedBox(
                    width: double.infinity, // Faz o label ocupar todo o espaço
                    child: Text(
                      prioridade,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedPrioridade = prioridade;
                      });
                    }
                  },
                  selectedColor: selectedColor,
                  backgroundColor: AppColors.lightGrey,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey[400]!)
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? selectedDate,
    required bool isEditable,
    VoidCallback? onTap,
  }) {
    String formattedDate = selectedDate != null
        ? (label == 'Data de Agendamento' ? DateFormat('dd/MM/yyyy').format(selectedDate) : DateFormat('yyyy-MM-dd').format(selectedDate))
        : (label == 'Data de Agendamento' ? 'dd/mm/aaaa' : '');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[800]),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: isEditable ? onTap : null,
          child: InputDecorator(
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(color: Colors.grey[400]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(color: Colors.grey[400]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0), // Ajuste padding vertical
              suffixIcon: isEditable ? const Icon(Icons.calendar_today, color: AppColors.darkGrey) : null,
              filled: !isEditable, // Preenche se não for editável
              fillColor: !isEditable ? Colors.grey[200] : null,
            ),
            child: Text(
              formattedDate,
              style: TextStyle(
                color: selectedDate != null ? Colors.black87 : Colors.grey[500],
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons({required bool isSubmitting}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: isSubmitting ? null : () {
              Navigator.of(context).pop();
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: isSubmitting ? Colors.grey : AppColors.primaryBlue),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: Text('Cancelar', style: TextStyle(color: isSubmitting ? Colors.grey : AppColors.primaryBlue)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: isSubmitting ? null : _submitForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: isSubmitting ? Colors.grey : AppColors.primaryBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: isSubmitting
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                : const Text('Criar OS', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }
}

