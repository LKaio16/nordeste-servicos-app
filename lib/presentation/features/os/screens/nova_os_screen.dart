// lib/presentation/features/os/presentation/screens/nova_os_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // Para formatação de data
import 'package:google_fonts/google_fonts.dart'; // Importando Google Fonts para fontes modernas

// Use package imports for robustness
import 'package:nordeste_servicos_app/presentation/features/os/providers/nova_os_provider.dart';
import 'package:nordeste_servicos_app/presentation/features/os/providers/nova_os_state.dart';
import 'package:nordeste_servicos_app/domain/entities/cliente.dart';
import 'package:nordeste_servicos_app/domain/entities/equipamento.dart';
import 'package:nordeste_servicos_app/domain/entities/usuario.dart'; // Assumindo que Tecnico é um Usuario

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
}

class NovaOsScreen extends ConsumerStatefulWidget {
  const NovaOsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<NovaOsScreen> createState() => _NovaOsScreenState();
}

class _NovaOsScreenState extends ConsumerState<NovaOsScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _descricaoController = TextEditingController();

  String? _selectedClienteId;
  String? _selectedEquipamentoId;
  String? _selectedTecnicoId;
  String _selectedPrioridade = 'Média'; // Valor inicial
  DateTime _selectedDataAbertura = DateTime.now();
  DateTime? _selectedDataAgendamento;

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

    // Chama a função do provider para carregar os dados iniciais
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(novaOsProvider.notifier).loadInitialData();
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDataAgendamento ?? DateTime.now(),
      firstDate: DateTime.now(), // Não permitir agendar para o passado
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: Colors.white,
              onSurface: AppColors.textDark,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryBlue,
                textStyle: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          child: child!,
        );
      },
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
          SnackBar(
            content: Text(
              'Ordem de Serviço criada com sucesso!',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: AppColors.successGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: EdgeInsets.all(12),
          ),
        );
      } else if (mounted) {
        // Erro já é tratado pelo estado do provider, mas podemos mostrar um SnackBar aqui também
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ref.read(novaOsProvider).submissionError ?? 'Erro ao criar OS.',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: AppColors.errorRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: EdgeInsets.all(12),
          ),
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
        child: Text(
          cliente.nomeCompleto,
          style: GoogleFonts.poppins(),
        ),
      );
    }).toList();

    // TODO: Filtrar equipamentos baseado no cliente selecionado, se necessário
    final equipamentoItems = state.equipamentos.map((Equipamento equipamento) {
      return DropdownMenuItem<String>(
        value: equipamento.id.toString(),
        child: Text(
          '${equipamento.marcaModelo} (${equipamento.numeroSerieChassi})',
          style: GoogleFonts.poppins(),
        ),
      );
    }).toList();

    final tecnicoItems = state.tecnicos.map((Usuario tecnico) {
      return DropdownMenuItem<String>(
        value: tecnico.id.toString(),
        child: Text(
          tecnico.nome,
          style: GoogleFonts.poppins(),
        ),
      );
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        title: Text(
          'Nova Ordem de Serviço',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
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

          if (state.isLoading)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                      strokeWidth: 3,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Carregando dados...',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            )
          else if (state.errorMessage != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Card(
                  elevation: 4,
                  shadowColor: AppColors.errorRed.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.errorRed.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.error_outline,
                            color: AppColors.errorRed,
                            size: 48,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Erro ao carregar dados',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.errorMessage!,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppColors.textLight,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => ref.read(novaOsProvider.notifier).loadInitialData(),
                          icon: Icon(Icons.refresh, color: Colors.white),
                          label: Text(
                            'Tentar Novamente',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          else
            SafeArea(
              child: FadeTransition(
                opacity: _fadeInAnimation,
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 4,
                    shadowColor: AppColors.primaryBlue.withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFormHeader(state.nextOsNumber),
                            const SizedBox(height: 24),
                            _buildDropdownFormField(
                              label: 'Cliente*',
                              hint: 'Selecione o cliente',
                              value: _selectedClienteId,
                              items: clienteItems,
                              icon: Icons.business_outlined,
                              onChanged: (value) {
                                setState(() {
                                  _selectedClienteId = value;
                                  _selectedEquipamentoId = null; // Limpa equipamento ao trocar cliente
                                  // TODO: Chamar ref.read(novaOsProvider.notifier).loadEquipamentosPorCliente(value!);
                                });
                              },
                              validator: (value) => value == null ? 'Campo obrigatório' : null,
                            ),
                            const SizedBox(height: 20),
                            _buildDropdownFormField(
                              label: 'Equipamento*',
                              hint: _selectedClienteId == null ? 'Selecione um cliente primeiro' : 'Selecione o equipamento',
                              value: _selectedEquipamentoId,
                              items: equipamentoItems, // Idealmente filtrados pelo cliente
                              icon: Icons.build_outlined,
                              onChanged: _selectedClienteId == null ? null : (value) {
                                setState(() {
                                  _selectedEquipamentoId = value;
                                });
                              },
                              validator: (value) => value == null ? 'Campo obrigatório' : null,
                            ),
                            const SizedBox(height: 20),
                            _buildTextFormField(
                              controller: _descricaoController,
                              label: 'Descrição do Problema*',
                              hint: 'Descreva o problema relatado',
                              icon: Icons.description_outlined,
                              maxLines: 4,
                              validator: (value) => (value == null || value.isEmpty) ? 'Campo obrigatório' : null,
                            ),
                            const SizedBox(height: 20),
                            _buildDropdownFormField(
                              label: 'Técnico Responsável*',
                              hint: 'Selecione o técnico',
                              value: _selectedTecnicoId,
                              items: tecnicoItems,
                              icon: Icons.engineering_outlined,
                              onChanged: (value) {
                                setState(() {
                                  _selectedTecnicoId = value;
                                });
                              },
                              validator: (value) => value == null ? 'Campo obrigatório' : null,
                            ),
                            const SizedBox(height: 20),
                            _buildPrioridadeSelector(),
                            const SizedBox(height: 20),
                            _buildDateField(
                              label: 'Data de Abertura',
                              selectedDate: _selectedDataAbertura,
                              isEditable: false,
                              icon: Icons.event_note_outlined,
                            ),
                            const SizedBox(height: 20),
                            _buildDateField(
                              label: 'Data de Agendamento',
                              selectedDate: _selectedDataAgendamento,
                              isEditable: true,
                              icon: Icons.calendar_month_outlined,
                              onTap: () => _selectDate(context),
                            ),
                            const SizedBox(height: 32),
                            if (state.submissionError != null)
                              Container(
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: AppColors.errorRed.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColors.errorRed.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: AppColors.errorRed,
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Erro ao criar OS: ${state.submissionError}',
                                        style: GoogleFonts.poppins(
                                          color: AppColors.errorRed,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            _buildActionButtons(isSubmitting: state.isSubmitting),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          // Overlay de loading durante o submit
          if (state.isSubmitting)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 50,
                          height: 50,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Criando Ordem de Serviço...',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFormHeader(String? nextOsNumber) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.add_circle_outline,
                color: AppColors.primaryBlue,
                size: 24,
              ),
            ),
            SizedBox(width: 12),
            Text(
              'Nova Ordem de Serviço',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Divider(color: AppColors.dividerColor),
        SizedBox(height: 16),
        Row(
          children: [
            Icon(
              Icons.tag_outlined,
              color: AppColors.primaryBlue,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              'Número da OS:',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textLight,
              ),
            ),
            SizedBox(width: 8),
            Text(
              nextOsNumber ?? '#----',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
          ],
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
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            items: items,
            onChanged: onChanged,
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.poppins(
                color: AppColors.textLight.withOpacity(0.7),
              ),
              prefixIcon: Icon(
                icon,
                color: AppColors.primaryBlue,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.grey.shade200,
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.primaryBlue,
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.errorRed,
                  width: 1.5,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.errorRed,
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              filled: onChanged == null,
              fillColor: onChanged == null ? Colors.grey.shade100 : null,
            ),
            style: GoogleFonts.poppins(
              color: AppColors.textDark,
              fontSize: 15,
            ),
            icon: Icon(
              Icons.arrow_drop_down,
              color: AppColors.primaryBlue,
            ),
            dropdownColor: Colors.white,
            isExpanded: true,
          ),
        ),
      ],
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    FormFieldValidator<String>? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            validator: validator,
            style: GoogleFonts.poppins(
              color: AppColors.textDark,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.poppins(
                color: AppColors.textLight.withOpacity(0.7),
              ),
              prefixIcon: Icon(
                icon,
                color: AppColors.primaryBlue,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.grey.shade200,
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.primaryBlue,
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.errorRed,
                  width: 1.5,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.errorRed,
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrioridadeSelector() {
    // Cores baseadas na imagem de referência
    const Map<String, Color> prioridadeColors = {
      'Baixa': AppColors.successGreen,
      'Média': AppColors.warningOrange,
      'Alta': AppColors.errorRed,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Prioridade',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: ['Baixa', 'Média', 'Alta'].map((prioridade) {
            bool isSelected = _selectedPrioridade == prioridade;
            Color selectedColor = prioridadeColors[prioridade] ?? AppColors.primaryBlue;

            // Ícones para cada prioridade
            IconData priorityIcon;
            if (prioridade == 'Baixa') {
              priorityIcon = Icons.arrow_downward;
            } else if (prioridade == 'Média') {
              priorityIcon = Icons.remove;
            } else {
              priorityIcon = Icons.arrow_upward;
            }

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedPrioridade = prioridade;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                        colors: [
                          selectedColor,
                          selectedColor.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                          : null,
                      color: isSelected ? null : AppColors.backgroundGray,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: isSelected
                          ? [
                        BoxShadow(
                          color: selectedColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ]
                          : null,
                      border: isSelected
                          ? null
                          : Border.all(
                        color: Colors.grey.shade300,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          priorityIcon,
                          color: isSelected ? Colors.white : selectedColor,
                          size: 20,
                        ),
                        SizedBox(height: 4),
                        Text(
                          prioridade,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: isSelected ? Colors.white : AppColors.textDark,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
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
    required IconData icon,
    VoidCallback? onTap,
  }) {
    String formattedDate = selectedDate != null
        ? (label == 'Data de Agendamento' ? DateFormat('dd/MM/yyyy').format(selectedDate) : DateFormat('dd/MM/yyyy').format(selectedDate))
        : (label == 'Data de Agendamento' ? 'Selecione uma data' : '');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: isEditable ? onTap : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
              border: Border.all(
                color: isEditable ? Colors.grey.shade200 : Colors.grey.shade300,
                width: 1.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: AppColors.primaryBlue,
                    size: 20,
                  ),
                  SizedBox(width: 12),
                  Text(
                    formattedDate,
                    style: GoogleFonts.poppins(
                      color: selectedDate != null ? AppColors.textDark : AppColors.textLight.withOpacity(0.7),
                      fontSize: 15,
                    ),
                  ),
                  Spacer(),
                  if (isEditable)
                    Icon(
                      Icons.calendar_today,
                      color: AppColors.primaryBlue,
                      size: 20,
                    ),
                ],
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
          child: OutlinedButton.icon(
            onPressed: isSubmitting ? null : () {
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.cancel_outlined,
              color: isSubmitting ? Colors.grey : AppColors.textLight,
            ),
            label: Text(
              'Cancelar',
              style: GoogleFonts.poppins(
                color: isSubmitting ? Colors.grey : AppColors.textLight,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: isSubmitting ? Colors.grey.shade300 : Colors.grey.shade400,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              gradient: isSubmitting
                  ? null
                  : LinearGradient(
                colors: [AppColors.primaryBlue, AppColors.secondaryBlue],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: isSubmitting
                  ? null
                  : [
                BoxShadow(
                  color: AppColors.primaryBlue.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: isSubmitting ? null : _submitForm,
              icon: isSubmitting
                  ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : Icon(Icons.check_circle_outline, color: Colors.white),
              label: Text(
                'Criar OS',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isSubmitting ? Colors.grey : Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
