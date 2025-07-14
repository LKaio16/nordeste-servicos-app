import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

// Importações locais
import '../../../../data/models/prioridade_os_model.dart';
import '../../../../data/models/status_os_model.dart';
import '../../../../domain/entities/ordem_servico.dart';
import '../../../../domain/entities/cliente.dart';
import '../../../../domain/entities/equipamento.dart';
import '../../../../domain/entities/usuario.dart';
import '../../../../domain/entities/foto_os.dart'; // Importar FotoOS

// Importar os providers
import '../../../shared/styles/app_colors.dart';
import '../providers/os_detail_provider.dart';
import '../providers/os_edit_provider.dart';
import '../providers/os_edit_state.dart';
import '../providers/foto_os_provider.dart'; // Importar foto_os_provider

// Tela de Edição de OS com Design Melhorado
class OsEditScreen extends ConsumerStatefulWidget {
  final int osId;

  const OsEditScreen({required this.osId, Key? key}) : super(key: key);

  @override
  ConsumerState<OsEditScreen> createState() => _OsEditScreenState();
}

class _OsEditScreenState extends ConsumerState<OsEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final PageController _imagePageController = PageController();
  int _currentImageIndex = 0;

  // Controllers para campos de texto da OS
  final _problemaController = TextEditingController();
  final _analiseController = TextEditingController();
  final _solucaoController = TextEditingController();

  // Controllers para campos de texto do Equipamento
  final _tipoEquipamentoController = TextEditingController();
  final _marcaModeloEquipamentoController = TextEditingController();
  final _numeroSerieChassiEquipamentoController = TextEditingController();
  final _horimetroEquipamentoController = TextEditingController();

  // Variáveis para armazenar seleções de dropdowns e datas
  String? _selectedClienteId;
  String? _selectedTecnicoId;
  StatusOSModel? _selectedStatus;
  PrioridadeOSModel? _selectedPrioridade;
  DateTime? _selectedDataAgendamento;

  bool _initialDataLoaded = false;
  int? _originalEquipamentoId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(osEditProvider(widget.osId).notifier).loadInitialData();
      ref.read(fotoOsProvider(widget.osId).notifier); // Carregar fotos
    });
  }

  @override
  void dispose() {
    _problemaController.dispose();
    _analiseController.dispose();
    _solucaoController.dispose();
    _tipoEquipamentoController.dispose();
    _marcaModeloEquipamentoController.dispose();
    _numeroSerieChassiEquipamentoController.dispose();
    _horimetroEquipamentoController.dispose();
    _imagePageController.dispose();
    super.dispose();
  }

  void _initializeFormFields(OrdemServico os) {
    if (!_initialDataLoaded) {
      _problemaController.text = os.problemaRelatado ?? '';
      _analiseController.text = os.analiseFalha ?? '';
      _solucaoController.text = os.solucaoAplicada ?? '';

      _selectedClienteId = os.cliente.id.toString();

      _tipoEquipamentoController.text = os.equipamento?.tipo ?? '';
      _marcaModeloEquipamentoController.text = os.equipamento?.marcaModelo ?? '';
      _numeroSerieChassiEquipamentoController.text = os.equipamento?.numeroSerieChassi ?? '';
      _horimetroEquipamentoController.text = os.equipamento?.horimetro?.toString() ?? '';
      _originalEquipamentoId = os.equipamento?.id;

      _selectedTecnicoId = os.tecnicoAtribuido?.id?.toString();
      _selectedStatus = os.status;
      _selectedPrioridade = os.prioridade;
      _selectedDataAgendamento = os.dataAgendamento;

      _initialDataLoaded = true;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDataAgendamento ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textDark,
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

  Future<bool> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final originalOs = ref.read(osEditProvider(widget.osId)).originalOs;
      if (originalOs == null) return false;

      final String horimetroText = _horimetroEquipamentoController.text;
      double? horimetroValue;
      if (horimetroText.isNotEmpty) {
        horimetroValue = double.tryParse(horimetroText);
        if (horimetroValue == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Horímetro do equipamento deve ser um número válido.',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
              backgroundColor: AppColors.errorRed,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
            ),
          );
          return false;
        }
      }

      final Equipamento equipamentoAtualizado = Equipamento(
        id: _originalEquipamentoId,
        tipo: _tipoEquipamentoController.text,
        marcaModelo: _marcaModeloEquipamentoController.text,
        numeroSerieChassi: _numeroSerieChassiEquipamentoController.text,
        horimetro: horimetroValue,
        clienteId: int.parse(_selectedClienteId!),
      );

      final success = await ref.read(osEditProvider(widget.osId).notifier).updateOrdemServico(
        osId: widget.osId,
        clienteId: int.parse(_selectedClienteId!),
        equipamento: equipamentoAtualizado,
        tecnicoAtribuidoId: _selectedTecnicoId != null ? int.parse(_selectedTecnicoId!) : null,
        problemaRelatado: _problemaController.text,
        analiseFalha: _analiseController.text,
        solucaoAplicada: _solucaoController.text,
        status: _selectedStatus!,
        prioridade: _selectedPrioridade,
        dataAgendamento: _selectedDataAgendamento,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('OS #${originalOs.numeroOS} atualizada com sucesso!', style: GoogleFonts.poppins()),
              ],
            ),
            backgroundColor: AppColors.successGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );

        ref.invalidate(osDetailProvider(widget.osId));
        ref.invalidate(osEditProvider(widget.osId));
        _initialDataLoaded = false;

        await Future.delayed(const Duration(milliseconds: 100));

        if (mounted) {
          Navigator.of(context).pop();
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    ref.read(osEditProvider(widget.osId)).submissionError ?? 'Erro ao salvar alterações.',
                    style: GoogleFonts.poppins(),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.errorRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
      return success;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(osEditProvider(widget.osId));
    final notifier = ref.read(osEditProvider(widget.osId).notifier);

    if (state.originalOs != null && !state.isLoadingInitialData && !_initialDataLoaded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _initializeFormFields(state.originalOs!);
          setState(() {});
        }
      });
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        title: Text(
          state.originalOs != null ? 'Editar OS #${state.originalOs!.numeroOS}' : 'Editar OS',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white),
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
      ),
      body: (state.isLoadingInitialData || !_initialDataLoaded) && state.initialDataError == null
          ? _buildLoadingState()
          : _buildBodyContent(state, notifier),
      bottomNavigationBar: (state.isLoadingInitialData || !_initialDataLoaded) && state.initialDataError == null
          ? null
          : Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton.icon(
            onPressed: state.isLoadingInitialData || state.isSubmitting ? null : _submitForm,
            icon: state.isSubmitting
                ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
                : Icon(Icons.save, size: 20, color: Colors.white),
            label: Text(
              state.isSubmitting ? 'Salvando...' : 'Salvar Alterações',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 3,
              shadowColor: AppColors.primaryBlue.withOpacity(0.3),
            ),
          ),
        ),
      ),
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
              'Carregando dados da OS...',
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

  Widget _buildBodyContent(OsEditState state, OsEditNotifier notifier) {
    if (state.initialDataError != null) {
      return _buildErrorState(state, notifier);
    } else if (state.originalOs == null && !state.isLoadingInitialData) {
      return _buildNotFoundState();
    } else if (state.originalOs != null) {
      return _buildFormContent(state);
    }
    return Container();
  }

  Widget _buildErrorState(OsEditState state, OsEditNotifier notifier) {
    return Stack(
      children: [
        // Elementos decorativos de fundo
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
                  state.initialDataError!,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textLight,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _initialDataLoaded = false;
                    });
                    notifier.loadInitialData();
                  },
                  icon: const Icon(Icons.refresh),
                  label: Text(
                    'Tentar Novamente',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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

  Widget _buildNotFoundState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.textLight,
          ),
          const SizedBox(height: 16),
          Text(
            'Ordem de Serviço não encontrada.',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormContent(OsEditState state) {
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
          top: MediaQuery.of(context).size.height * 0.3,
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
        SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          physics: const BouncingScrollPhysics(),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card de Informações Principais
                _buildSectionCard(
                  title: 'Informações Principais',
                  icon: Icons.info_outline,
                  children: [
                    _buildDropdownFormField<String>(
                      label: 'Cliente',
                      value: _selectedClienteId,
                      items: state.clientes
                          .map((c) => DropdownMenuItem(
                        value: c.id.toString(),
                        child: Text(c.nomeCompleto, style: GoogleFonts.poppins()),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedClienteId = value;
                        });
                      },
                      validator: (value) => value == null ? 'Campo obrigatório' : null,
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 20),
                    _buildDropdownFormField<String>(
                      label: 'Técnico Atribuído',
                      value: _selectedTecnicoId,
                      items: state.tecnicos
                          .map((t) => DropdownMenuItem(
                        value: t.id.toString(),
                        child: Text(t.nome, style: GoogleFonts.poppins()),
                      ))
                          .toList(),
                      onChanged: (value) => setState(() => _selectedTecnicoId = value),
                      icon: Icons.engineering_outlined,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdownFormField<StatusOSModel>(
                            label: 'Status',
                            value: _selectedStatus,
                            items: StatusOSModel.values
                                .map((s) => DropdownMenuItem(
                              value: s,
                              child: Text(_getStatusText(s), style: GoogleFonts.poppins(fontSize: 13)),
                            ))
                                .toList(),
                            onChanged: (value) => setState(() => _selectedStatus = value),
                            validator: (value) => value == null ? 'Campo obrigatório' : null,
                            icon: Icons.flag_outlined,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDropdownFormField<PrioridadeOSModel>(
                            label: 'Prioridade',
                            value: _selectedPrioridade,
                            items: PrioridadeOSModel.values
                                .map((p) => DropdownMenuItem(
                              value: p,
                              child: Text(_getPrioridadeText(p), style: GoogleFonts.poppins(fontSize: 13)),
                            ))
                                .toList(),
                            onChanged: (value) => setState(() => _selectedPrioridade = value),
                            icon: Icons.priority_high_outlined,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Card de Detalhes do Equipamento
                _buildSectionCard(
                  title: 'Detalhes do Equipamento',
                  icon: Icons.build_outlined,
                  children: [
                    _buildTextFormField(
                      controller: _tipoEquipamentoController,
                      label: 'Tipo de Equipamento',
                      validator: (value) => (value == null || value.isEmpty) ? 'Campo obrigatório' : null,
                      icon: Icons.category_outlined,
                    ),
                    const SizedBox(height: 20),
                    _buildTextFormField(
                      controller: _marcaModeloEquipamentoController,
                      label: 'Marca/Modelo',
                      validator: (value) => (value == null || value.isEmpty) ? 'Campo obrigatório' : null,
                      icon: Icons.branding_watermark_outlined,
                    ),
                    const SizedBox(height: 20),
                    _buildTextFormField(
                      controller: _numeroSerieChassiEquipamentoController,
                      label: 'Número de Série/Chassi',
                      validator: (value) => (value == null || value.isEmpty) ? 'Campo obrigatório' : null,
                      icon: Icons.confirmation_number_outlined,
                    ),
                    const SizedBox(height: 20),
                    _buildTextFormField(
                      controller: _horimetroEquipamentoController,
                      label: 'Horímetro (opcional)',
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      icon: Icons.timer_outlined,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Card de Descrições e Análises
                _buildSectionCard(
                  title: 'Descrições e Análises',
                  icon: Icons.description_outlined,
                  children: [
                    _buildTextFormField(
                      controller: _problemaController,
                      label: 'Problema Relatado',
                      maxLines: 3,
                      icon: Icons.report_problem_outlined,
                    ),
                    const SizedBox(height: 20),
                    _buildTextFormField(
                      controller: _analiseController,
                      label: 'Análise da Falha',
                      maxLines: 3,
                      icon: Icons.search_outlined,
                    ),
                    const SizedBox(height: 20),
                    _buildTextFormField(
                      controller: _solucaoController,
                      label: 'Solução Aplicada',
                      maxLines: 3,
                      icon: Icons.check_circle_outline,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Card de Agendamento
                _buildSectionCard(
                  title: 'Agendamento',
                  icon: Icons.calendar_today_outlined,
                  children: [
                    _buildDateField(),
                  ],
                ),

                const SizedBox(height: 24),

                // Card de Fotos da OS
                _buildFotosCard(context, ref, widget.osId),

                const SizedBox(height: 32),
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
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
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
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: GoogleFonts.poppins(
          fontSize: 16,
          color: AppColors.textDark,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(
            color: AppColors.textLight,
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
      ),
    );
  }

  Widget _buildDropdownFormField<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
    String? Function(T?)? validator,
    String? hint,
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
      child: DropdownButtonFormField<T>(
        value: value,
        items: items,
        onChanged: onChanged,
        validator: validator,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: AppColors.textDark,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(
            color: AppColors.textLight,
            fontSize: 14,
          ),
          hintText: hint,
          hintStyle: GoogleFonts.poppins(
            color: AppColors.textLight,
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

  Widget _buildDateField() {
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
        onTap: () => _selectDate(context),
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
                      'Data de Agendamento',
                      style: GoogleFonts.poppins(
                        color: AppColors.textLight,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _selectedDataAgendamento != null
                          ? DateFormat('dd/MM/yyyy').format(_selectedDataAgendamento!)
                          : 'Selecionar data',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: _selectedDataAgendamento != null
                            ? AppColors.textDark
                            : AppColors.textLight,
                        fontWeight: _selectedDataAgendamento != null
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

  String _getStatusText(StatusOSModel status) {
    switch (status) {
      case StatusOSModel.EM_ABERTO:
        return 'Em Aberto';
      case StatusOSModel.EM_ANDAMENTO:
        return 'Em Andamento';
      case StatusOSModel.ATRIBUIDA:
        return 'Atribuida';
      case StatusOSModel.PENDENTE_PECAS:
        return 'Pendente Peças';
      case StatusOSModel.AGUARDANDO_APROVACAO:
        return 'Aguardando Aprovação';
      case StatusOSModel.CONCLUIDA:
        return 'Concluída';
      case StatusOSModel.ENCERRADA:
        return 'Encerrada';
      case StatusOSModel.CANCELADA:
        return 'Cancelada';
      default:
        return status.name;
    }
  }

  String _getPrioridadeText(PrioridadeOSModel prioridade) {
    switch (prioridade) {
      case PrioridadeOSModel.BAIXA:
        return 'Baixa';
      case PrioridadeOSModel.MEDIA:
        return 'Média';
      case PrioridadeOSModel.ALTA:
        return 'Alta';
      case PrioridadeOSModel.URGENTE:
        return 'Urgente';
      default:
        return prioridade.name;
    }
  }

  Widget _buildFotosCard(BuildContext context, WidgetRef ref, int osId) {
    final fotosState = ref.watch(fotoOsProvider(osId));
    final fotosNotifier = ref.read(fotoOsProvider(osId).notifier);

    Future<void> _pickAndUploadImage() async {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 1024,
      );

      if (image == null || !context.mounted) return;

      final description = await showDialog<String>(
        context: context,
        builder: (context) {
          final controller = TextEditingController();
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(
              'Descrição da Foto',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Digite uma descrição...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              autofocus: true,
            ),
            actions: [
              TextButton(
                child: Text(
                  'Cancelar',
                  style: GoogleFonts.poppins(color: AppColors.textLight),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  'Salvar',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(controller.text),
              ),
            ],
          );
        },
      );

      if (description != null) {
        await fotosNotifier.uploadFoto(image, description);
      }
    }

    void _showImageFullScreen(List<FotoOS> fotos, int initialIndex) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => _ImageFullScreenViewer(
            fotos: fotos,
            initialIndex: initialIndex,
            onDelete: (fotoId) async {
              await fotosNotifier.deleteFoto(fotoId);
            },
          ),
        ),
      );
    }

    return _buildSectionCard(
      title: 'Fotos da OS',
      icon: Icons.photo_library_outlined,
      children: [
        if (fotosState.isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          ),
        if (!fotosState.isLoading && fotosState.errorMessage != null)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                fotosState.errorMessage!,
                style: GoogleFonts.poppins(color: AppColors.errorRed),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        if (!fotosState.isLoading && fotosState.fotos.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Icon(
                    Icons.photo_outlined,
                    size: 48,
                    color: AppColors.textLight,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Nenhuma foto adicionada",
                    style: GoogleFonts.poppins(
                      color: AppColors.textLight,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (fotosState.fotos.isNotEmpty) ...[
          SizedBox(
            height: 220,
            child: PageView.builder(
              controller: _imagePageController,
              onPageChanged: (index) {
                setState(() {
                  _currentImageIndex = index;
                });
              },
              itemCount: fotosState.fotos.length,
              itemBuilder: (context, index) {
                final foto = fotosState.fotos[index];
                final imageBytes = base64Decode(foto.fotoBase64);

                return GestureDetector(
                  onTap: () => _showImageFullScreen(fotosState.fotos, index),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.memory(
                            imageBytes,
                            fit: BoxFit.cover,
                          ),
                          if (foto.descricao != null && foto.descricao!.isNotEmpty)
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.7),
                                    ],
                                  ),
                                ),
                                child: Text(
                                  foto.descricao!,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.zoom_in,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                          // Botão de exclusão
                          Positioned(
                            top: 8,
                            left: 8,
                            child: GestureDetector(
                              onTap: () async {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    title: Text(
                                      'Excluir Foto',
                                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                                    ),
                                    content: Text(
                                      'Tem certeza que deseja excluir esta foto?',
                                      style: GoogleFonts.poppins(),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(false),
                                        child: Text(
                                          'Cancelar',
                                          style: GoogleFonts.poppins(color: AppColors.textLight),
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () => Navigator.of(context).pop(true),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.errorRed,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                        child: Text(
                                          'Excluir',
                                          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirmed == true) {
                                  await fotosNotifier.deleteFoto(foto.id!); // Chamar deleteFoto do notifier
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.errorRed.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.delete_outline,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          if (fotosState.fotos.length > 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                fotosState.fotos.length,
                    (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentImageIndex == index
                        ? AppColors.primaryBlue
                        : AppColors.textLight.withOpacity(0.3),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),
        ],
        ElevatedButton.icon(
          onPressed: fotosState.isUploading ? null : _pickAndUploadImage,
          icon: fotosState.isUploading
              ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          )
              : const Icon(Icons.add_a_photo_outlined, size: 18, color: Colors.white,),
          label: Text(
            fotosState.isUploading ? 'Enviando...' : 'Adicionar Foto',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
        ),
      ],
    );
  }
}

class _ImageFullScreenViewer extends StatefulWidget {
  final List<FotoOS> fotos;
  final int initialIndex;
  final Function(int) onDelete;

  const _ImageFullScreenViewer({
    required this.fotos,
    required this.initialIndex,
    required this.onDelete,
  });

  @override
  State<_ImageFullScreenViewer> createState() => _ImageFullScreenViewerState();
}

class _ImageFullScreenViewerState extends State<_ImageFullScreenViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '${_currentIndex + 1} de ${widget.fotos.length}',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: Text(
                    'Excluir Foto',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  content: Text(
                    'Tem certeza que deseja excluir esta foto?',
                    style: GoogleFonts.poppins(),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(
                        'Cancelar',
                        style: GoogleFonts.poppins(color: AppColors.textLight),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.errorRed,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        'Excluir',
                        style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                await widget.onDelete(widget.fotos[_currentIndex].id!); // Chamar onDelete do widget
                if (mounted) {
                  Navigator.of(context).pop();
                }
              }
            },
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemCount: widget.fotos.length,
        itemBuilder: (context, index) {
          final foto = widget.fotos[index];
          final imageBytes = base64Decode(foto.fotoBase64);

          return InteractiveViewer(
            panEnabled: true,
            boundaryMargin: const EdgeInsets.all(20),
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(
              child: Image.memory(
                imageBytes,
                fit: BoxFit.contain,
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: widget.fotos[_currentIndex].descricao != null &&
          widget.fotos[_currentIndex].descricao!.isNotEmpty
          ? Container(
        color: Colors.black.withOpacity(0.8),
        padding: const EdgeInsets.all(16),
        child: Text(
          widget.fotos[_currentIndex].descricao!,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      )
          : null,
    );
  }
}


