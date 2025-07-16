import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:nordeste_servicos_app/presentation/features/os/providers/nova_os_provider.dart';
import 'package:nordeste_servicos_app/presentation/features/os/providers/os_list_provider.dart';
import 'package:nordeste_servicos_app/presentation/features/os/providers/nova_os_state.dart';
import 'package:nordeste_servicos_app/domain/entities/cliente.dart';
import 'package:nordeste_servicos_app/domain/entities/equipamento.dart';
import 'package:nordeste_servicos_app/domain/entities/usuario.dart';
import 'package:nordeste_servicos_app/data/models/prioridade_os_model.dart';
import 'package:nordeste_servicos_app/data/models/status_os_model.dart';

import '../../../shared/styles/app_colors.dart';

enum EquipamentoMode { selecionar, cadastrar }

class NovaOsScreen extends ConsumerStatefulWidget {
  const NovaOsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<NovaOsScreen> createState() => _NovaOsScreenState();
}

class _NovaOsScreenState extends ConsumerState<NovaOsScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _descricaoController = TextEditingController();
  final _tipoEquipamentoController = TextEditingController();
  final _marcaModeloEquipamentoController = TextEditingController();
  final _numeroSerieChassiEquipamentoController = TextEditingController();
  final _horimetroEquipamentoController = TextEditingController();

  // State
  String? _selectedClienteId;
  String? _selectedEquipamentoId;
  String? _selectedTecnicoId;
  String _selectedPrioridade = 'MEDIA';
  final DateTime _selectedDataAbertura = DateTime.now();
  DateTime? _selectedDataAgendamento;
  EquipamentoMode _equipamentoMode = EquipamentoMode.selecionar;

  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeInAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(novaOsProvider.notifier).loadInitialData().then((_) {
        if (mounted) _animationController.forward();
      });
    });
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    _tipoEquipamentoController.dispose();
    _marcaModeloEquipamentoController.dispose();
    _numeroSerieChassiEquipamentoController.dispose();
    _horimetroEquipamentoController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onClienteChanged(String? clienteId) {
    if (clienteId != null && clienteId != _selectedClienteId) {
      setState(() {
        _selectedClienteId = clienteId;
        _selectedEquipamentoId = null;
        _equipamentoMode = EquipamentoMode.selecionar;
        _tipoEquipamentoController.clear();
        _marcaModeloEquipamentoController.clear();
        _numeroSerieChassiEquipamentoController.clear();
        _horimetroEquipamentoController.clear();
      });
      ref
          .read(novaOsProvider.notifier)
          .loadEquipamentosDoCliente(int.parse(clienteId));
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDataAgendamento ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.primaryBlue,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: AppColors.textDark,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedDataAgendamento = picked);
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();

      Map<String, dynamic>? novoEquipamentoData;
      if (_equipamentoMode == EquipamentoMode.cadastrar) {
        novoEquipamentoData = {
          'tipo': _tipoEquipamentoController.text,
          'marcaModelo': _marcaModeloEquipamentoController.text,
          'numeroSerieChassi': _numeroSerieChassiEquipamentoController.text,
          'horimetro': _horimetroEquipamentoController.text.isNotEmpty
              ? double.tryParse(
                  _horimetroEquipamentoController.text.replaceAll(',', '.'))
              : null,
        };
      }

      final success =
          await ref.read(novaOsProvider.notifier).createOrdemServico(
                clienteId: _selectedClienteId!,
                equipamentoExistenteId:
                    _equipamentoMode == EquipamentoMode.selecionar
                        ? _selectedEquipamentoId
                        : null,
                novoEquipamentoData: novoEquipamentoData,
                descricaoProblema: _descricaoController.text,
                tecnicoId: _selectedTecnicoId!,
                prioridade: _selectedPrioridade,
                dataAbertura: _selectedDataAbertura,
                dataAgendamento: _selectedDataAgendamento,
              );

      if (success && mounted) {
        ref.invalidate(osListProvider);
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Ordem de Serviço criada com sucesso!'),
              ],
            ),
            backgroundColor: AppColors.successGreen,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(novaOsProvider);

    ref.listen<NovaOsState>(novaOsProvider, (previous, next) {
      if (next.submissionError != null &&
          previous?.submissionError != next.submissionError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Expanded(child: Text(next.submissionError!)),
              ],
            ),
            backgroundColor: AppColors.errorRed,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    });

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
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryBlue,
                AppColors.secondaryBlue,
              ],
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            child: ElevatedButton.icon(
              onPressed: state.isSubmitting ? null : _submitForm,
              icon: state.isSubmitting
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: AppColors.primaryBlue,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(Icons.add, size: 18),
              label: Text(
                'Criar',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600, fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
      body: state.isLoading
          ? _buildLoadingState()
          : state.errorMessage != null
              ? _buildErrorState(state.errorMessage!)
              : _buildFormContent(state),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.backgroundGray,
            AppColors.backgroundGray.withOpacity(0.8),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
              strokeWidth: 3,
            ),
            const SizedBox(height: 24),
            Text(
              'Carregando dados...',
              style: GoogleFonts.poppins(
                color: AppColors.textLight,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String errorMessage) {
    return Stack(
      children: [
        Positioned(
          top: -50,
          right: -50,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: AppColors.errorRed.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.errorRed.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline,
                    color: AppColors.errorRed,
                    size: 64,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Erro ao Carregar Dados',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  errorMessage,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textLight,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.read(novaOsProvider.notifier).loadInitialData();
                  },
                  icon: const Icon(Icons.refresh),
                  label: Text(
                    'Tentar Novamente',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    elevation: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormContent(NovaOsState state) {
    return Stack(
      children: [
        // Elementos decorativos de fundo - inspirados no dashboard
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
        Positioned(
          top: MediaQuery.of(context).size.height * 0.4,
          right: -30,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.successGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
          ),
        ),

        // Conteúdo principal
        FadeTransition(
          opacity: _fadeInAnimation,
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildSectionCard(
                  title: 'Cliente e Equipamento',
                  icon: Icons.business_center_outlined,
                  children: [
                    _buildDropdownFormField(
                      label: 'Cliente',
                      hint: 'Selecione o cliente',
                      value: _selectedClienteId,
                      items: state.clientes
                          .map((Cliente c) => DropdownMenuItem(
                                value: c.id.toString(),
                                child: Text(c.nomeCompleto),
                              ))
                          .toList(),
                      onChanged: _onClienteChanged,
                      icon: Icons.person_search_outlined,
                    ),
                    const SizedBox(height: 24),
                    if (_selectedClienteId != null)
                      Column(
                        children: [
                          _buildEquipamentoModeSelector(),
                          const SizedBox(height: 24),
                          _buildEquipamentoSection(state),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSectionCard(
                  title: 'Detalhes do Serviço',
                  icon: Icons.description_outlined,
                  children: [
                    _buildTextFormField(
                      controller: _descricaoController,
                      label: 'Descrição do Problema',
                      hint: 'Descreva o problema detalhadamente...',
                      maxLines: 4,
                      icon: Icons.comment_outlined,
                    ),
                    const SizedBox(height: 24),
                    _buildDropdownFormField(
                      label: 'Técnico Responsável',
                      hint: 'Selecione o técnico',
                      value: _selectedTecnicoId,
                      items: state.tecnicos
                          .map((Usuario t) => DropdownMenuItem(
                                value: t.id.toString(),
                                child: Text(t.nome),
                              ))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedTecnicoId = value),
                      icon: Icons.engineering_outlined,
                    ),
                    const SizedBox(height: 24),
                    _buildDateField(
                      label: 'Data de Agendamento (Opcional)',
                      selectedDate: _selectedDataAgendamento,
                      onTap: () => _selectDate(context),
                    ),
                    const SizedBox(height: 24),
                    _buildPrioridadeSelector(),
                  ],
                ),
                const SizedBox(height: 32),
                _buildActionButtons(isSubmitting: state.isSubmitting),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 24,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.dividerColor,
                    AppColors.dividerColor.withOpacity(0.1),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    bool isOptional = false,
    TextInputType? keyboardType,
    IconData? icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: GoogleFonts.poppins(
          fontSize: 16,
          color: AppColors.textDark,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: GoogleFonts.poppins(
            color: AppColors.textLight,
            fontSize: 14,
          ),
          hintStyle: GoogleFonts.poppins(
            color: AppColors.textLight.withOpacity(0.7),
            fontSize: 14,
          ),
          prefixIcon: icon != null
              ? Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: AppColors.primaryBlue,
                  ),
                )
              : null,
          filled: true,
          fillColor: AppColors.cardBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.dividerColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.dividerColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.errorRed),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: icon != null ? 16 : 16,
            vertical: 16,
          ),
        ),
        validator: (value) {
          if (!isOptional && (value == null || value.isEmpty)) {
            return 'Campo obrigatório';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdownFormField({
    required String label,
    required String? hint,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?)? onChanged,
    IconData? icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items,
        onChanged: onChanged,
        validator: (val) => val == null ? 'Campo obrigatório' : null,
        style: GoogleFonts.poppins(
          color: AppColors.textDark,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: GoogleFonts.poppins(
            color: AppColors.textLight,
            fontSize: 14,
          ),
          hintStyle: GoogleFonts.poppins(
            color: AppColors.textLight.withOpacity(0.7),
            fontSize: 14,
          ),
          prefixIcon: icon != null
              ? Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: AppColors.primaryBlue,
                  ),
                )
              : null,
          filled: true,
          fillColor: AppColors.cardBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.dividerColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.dividerColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.errorRed),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: icon != null ? 16 : 16,
            vertical: 16,
          ),
        ),
        dropdownColor: AppColors.cardBackground,
        icon: Icon(
          Icons.keyboard_arrow_down,
          color: AppColors.primaryBlue,
        ),
        isExpanded: true,
      ),
    );
  }

  Widget _buildEquipamentoModeSelector() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.backgroundGray.withOpacity(0.5),
      ),
      padding: const EdgeInsets.all(4),
      child: SegmentedButton<EquipamentoMode>(
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: AppColors.primaryBlue,
          selectedForegroundColor: Colors.white,
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.textDark,
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        segments: const [
          ButtonSegment(
            value: EquipamentoMode.selecionar,
            label: Text('Selecionar'),
            icon: Icon(Icons.list_alt, size: 18),
          ),
          ButtonSegment(
            value: EquipamentoMode.cadastrar,
            label: Text('Cadastrar Novo'),
            icon: Icon(Icons.add, size: 18),
          ),
        ],
        selected: {_equipamentoMode},
        onSelectionChanged: (Set<EquipamentoMode> newSelection) {
          setState(() => _equipamentoMode = newSelection.first);
        },
      ),
    );
  }

  Widget _buildEquipamentoSection(NovaOsState state) {
    if (state.isEquipamentoLoading) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Column(
            children: [
              CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
              ),
              const SizedBox(height: 16),
              Text(
                'Carregando equipamentos...',
                style: GoogleFonts.poppins(
                  color: AppColors.textLight,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_equipamentoMode == EquipamentoMode.selecionar) {
      if (state.equipamentosDoCliente.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.warningOrange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.warningOrange.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.warningOrange,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Nenhum equipamento cadastrado para este cliente. Mude para "Cadastrar Novo" para adicionar um.',
                  style: GoogleFonts.poppins(
                    color: AppColors.warningOrange,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      }
      return _buildDropdownFormField(
        label: 'Equipamento Existente',
        hint: 'Selecione o equipamento',
        value: _selectedEquipamentoId,
        items: state.equipamentosDoCliente
            .map((Equipamento e) => DropdownMenuItem(
                  value: e.id.toString(),
                  child: Text(
                    '${e.marcaModelo} (${e.numeroSerieChassi})',
                    overflow: TextOverflow.ellipsis,
                  ),
                ))
            .toList(),
        onChanged: (value) => setState(() => _selectedEquipamentoId = value),
        icon: Icons.build_circle_outlined,
      );
    } else {
      // Cadastrar novo equipamento
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.successGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.successGreen.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.add_circle_outline,
                  color: AppColors.successGreen,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Cadastrar Novo Equipamento',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.successGreen,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildTextFormField(
            controller: _tipoEquipamentoController,
            label: 'Tipo de Equipamento',
            hint: 'Ex: Gerador',
            icon: Icons.category_outlined,
          ),
          const SizedBox(height: 20),
          _buildTextFormField(
            controller: _marcaModeloEquipamentoController,
            label: 'Marca/Modelo',
            hint: 'Ex: Cummins C220D5',
            icon: Icons.branding_watermark_outlined,
          ),
          const SizedBox(height: 20),
          _buildTextFormField(
            controller: _numeroSerieChassiEquipamentoController,
            label: 'Nº de Série/Chassi',
            icon: Icons.confirmation_number_outlined,
          ),
          const SizedBox(height: 20),
          _buildTextFormField(
            controller: _horimetroEquipamentoController,
            label: 'Horímetro (Opcional)',
            keyboardType: TextInputType.number,
            isOptional: true,
            icon: Icons.timer_outlined,
          ),
        ],
      );
    }
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
            Color selectedColor =
                prioridadeColors[prioridade] ?? AppColors.primaryBlue;

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
                            color:
                                isSelected ? Colors.white : AppColors.textDark,
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.w500,
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
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.dividerColor),
          ),
          child: Row(
            children: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.calendar_today_outlined,
                  size: 20,
                  color: AppColors.primaryBlue,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.poppins(
                        color: AppColors.textLight,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      selectedDate != null
                          ? DateFormat('dd/MM/yyyy').format(selectedDate)
                          : 'Selecionar data',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: selectedDate != null
                            ? AppColors.textDark
                            : AppColors.textLight,
                        fontWeight: selectedDate != null
                            ? FontWeight.w500
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.keyboard_arrow_right,
                color: AppColors.primaryBlue,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons({required bool isSubmitting}) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: isSubmitting ? null : () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textLight,
              side: BorderSide(color: AppColors.dividerColor, width: 2),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              'Cancelar',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryBlue,
                  AppColors.secondaryBlue,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlue.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: isSubmitting ? null : _submitForm,
              icon: isSubmitting
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(
                      Icons.add_task,
                      size: 20,
                      color: Colors.white,
                    ),
              label: Text(
                isSubmitting ? 'Criando...' : 'Criar Ordem de Serviço',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
