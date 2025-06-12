import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart'; // Para kDebugMode

// Importações locais (ajuste os caminhos conforme sua estrutura de projeto)

// *** CORREÇÃO: Importar a ENTIDADE e seus ENUMS para usar na TELA ***
import '../../../../data/models/prioridade_os_model.dart';
import '../../../../data/models/status_os_model.dart';
import '../../../../domain/entities/ordem_servico.dart'; // Contém StatusOSModel, PrioridadeOSModel
import '../../../../domain/entities/cliente.dart';
import '../../../../domain/entities/equipamento.dart';
import '../../../../domain/entities/usuario.dart'; // Importe Usuario

// Importar os providers
import '../providers/os_detail_provider.dart';
import '../providers/os_edit_provider.dart';
import '../providers/os_edit_state.dart';


// Reutilizando AppColors (ou importe de um arquivo central)
class AppColors {
  static const Color primaryBlue = Color(0xFF1A73E8);
  static const Color textDark = Color(0xFF202124);
  static const Color textLight = Color(0xFF5F6368);
  static const Color backgroundGray = Color(0xFFF8F9FA);
  static const Color dividerColor = Color(0xFFEEEEEE);
  static const Color successGreen = Color(0xFF34A853);
  static const Color errorRed = Color(0xFFEA4335);
}

// Tela de Edição de OS
class OsEditScreen extends ConsumerStatefulWidget {
  final int osId;

  const OsEditScreen({required this.osId, Key? key}) : super(key: key);

  @override
  ConsumerState<OsEditScreen> createState() => _OsEditScreenState();
}

class _OsEditScreenState extends ConsumerState<OsEditScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers para campos de texto
  final _problemaController = TextEditingController();
  final _analiseController = TextEditingController();
  final _solucaoController = TextEditingController();

  // Variáveis para armazenar seleções de dropdowns e datas
  String? _selectedClienteId;
  String? _selectedEquipamentoId;
  String? _selectedTecnicoId; // Este ainda armazena o ID como String
  // *** CORREÇÃO: Usar os ENUMS da ENTIDADE (StatusOSModel, PrioridadeOSModel) na tela ***
  StatusOSModel? _selectedStatus;
  PrioridadeOSModel? _selectedPrioridade;
  DateTime? _selectedDataAgendamento;

  bool _initialDataLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(osEditProvider(widget.osId).notifier).loadInitialData();
    });
  }

  @override
  void dispose() {
    _problemaController.dispose();
    _analiseController.dispose();
    _solucaoController.dispose();
    super.dispose();
  }


  // Função para inicializar os controllers e variáveis com dados da OS original (Entidade)
  void _initializeFormFields(OrdemServico os) {
    if (!_initialDataLoaded) {
      _problemaController.text = os.problemaRelatado ?? '';
      _analiseController.text = os.analiseFalha ?? '';
      _solucaoController.text = os.solucaoAplicada ?? '';

      _selectedClienteId = os.cliente.id.toString();
      _selectedEquipamentoId = os.equipamento.id.toString();
      // *** ALTERAÇÃO AQUI: Acessar o ID do técnico através do objeto aninhado ***
      _selectedTecnicoId = os.tecnicoAtribuido?.id?.toString();
      // *** CORREÇÃO: Atribui os enums da ENTIDADE ***
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
      if (originalOs == null) return false; // Adicionado retorno para evitar null

      // *** DEBUG PRINT ***: Verifica os valores ANTES de criar a entidade atualizada
      if (kDebugMode) {
        print("--- Submitting OS Edit (Tela) ---");
        print("Problema Relatado (Controller): ${_problemaController.text}");
        print("Data Agendamento (State Var): $_selectedDataAgendamento");
        print("Status (State Var - Entity Enum): $_selectedStatus");
        print("Prioridade (State Var - Entity Enum): $_selectedPrioridade");
        print("Cliente ID: $_selectedClienteId");
        print("Equipamento ID: $_selectedEquipamentoId");
        print("Tecnico ID: $_selectedTecnicoId");
        print("Analise Falha: ${_analiseController.text}");
        print("Solucao Aplicada: ${_solucaoController.text}");
        print("---------------------------------");
      }

      // Prepara os dados para o repositório.
      // O repositório irá mapear isso para um DTO de requisição (OrdemServicoRequestDTO)
      // que ainda espera o ID do técnico (tecnicoAtribuidoId).
      final int clienteIdParsed = int.parse(_selectedClienteId!);
      final int equipamentoIdParsed = int.parse(_selectedEquipamentoId!);
      final int? tecnicoAtribuidoIdParsed = _selectedTecnicoId != null ? int.parse(_selectedTecnicoId!) : null;

      final success = await ref.read(osEditProvider(widget.osId).notifier).updateOrdemServico(
        // Passa os dados brutos para o notifier/repositório
        osId: widget.osId, // Id da OS que está sendo editada
        clienteId: clienteIdParsed,
        equipamentoId: equipamentoIdParsed,
        tecnicoAtribuidoId: tecnicoAtribuidoIdParsed,
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
            content: Text('OS #${originalOs.numeroOS} atualizada com sucesso!', style: GoogleFonts.poppins()),
            backgroundColor: AppColors.successGreen,
          ),
        );
        ref.invalidate(osDetailProvider(widget.osId));
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) {
          Navigator.of(context).pop();
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ref.read(osEditProvider(widget.osId)).submissionError ?? 'Erro ao salvar alterações.', style: GoogleFonts.poppins()),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
      return success; // Retorna o status de sucesso
    }
    return false; // Retorna falso se a validação do formulário falhar
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
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton(
              onPressed: state.isLoadingInitialData || state.isSubmitting ? null : _submitForm,
              child: state.isSubmitting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(
                'Salvar',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
      body: (state.isLoadingInitialData || !_initialDataLoaded) && state.initialDataError == null
          ? const Center(child: CircularProgressIndicator())
          : _buildBodyContent(state, notifier),
    );
  }

  Widget _buildBodyContent(OsEditState state, OsEditNotifier notifier) {
    if (state.initialDataError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppColors.errorRed, size: 50),
              const SizedBox(height: 16),
              Text('Erro ao Carregar Dados', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(state.initialDataError!, style: GoogleFonts.poppins(color: Colors.grey.shade600), textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() { _initialDataLoaded = false; });
                  notifier.loadInitialData();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar Novamente'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, foregroundColor: Colors.white),
              ),
            ],
          ),
        ),
      );
    } else if (state.originalOs == null && !state.isLoadingInitialData) {
      return Center(child: Text('Ordem de Serviço não encontrada.', style: GoogleFonts.poppins(fontSize: 16, color: AppColors.textLight)));
    } else if (state.originalOs != null) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Informações Principais'),
              _buildDropdownFormField<String>(
                label: 'Cliente*',
                value: _selectedClienteId,
                items: state.clientes.map((c) => DropdownMenuItem(value: c.id.toString(), child: Text(c.nomeCompleto, style: GoogleFonts.poppins()))).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedClienteId = value;
                    _selectedEquipamentoId = null;
                  });
                },
                validator: (value) => value == null ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              _buildDropdownFormField<String>(
                label: 'Equipamento*',
                value: _selectedEquipamentoId,
                items: state.equipamentos
                    .map((e) => DropdownMenuItem(value: e.id.toString(), child: Text('${e.marcaModelo} (${e.numeroSerieChassi})', style: GoogleFonts.poppins())))
                    .toList(),
                onChanged: _selectedClienteId == null ? null : (value) => setState(() => _selectedEquipamentoId = value),
                validator: (value) => value == null ? 'Campo obrigatório' : null,
                hint: _selectedClienteId == null ? 'Selecione um cliente primeiro' : 'Selecione o equipamento',
              ),
              const SizedBox(height: 16),
              _buildDropdownFormField<String>(
                label: 'Técnico Atribuído',
                value: _selectedTecnicoId,
                items: state.tecnicos.map((t) => DropdownMenuItem(value: t.id.toString(), child: Text(t.nome, style: GoogleFonts.poppins()))).toList(),
                onChanged: (value) => setState(() => _selectedTecnicoId = value),
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _problemaController,
                label: 'Problema Relatado*',
                maxLines: 4,
                validator: (value) => (value == null || value.isEmpty) ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 24),

              _buildSectionTitle('Status e Agendamento'),
              // *** CORREÇÃO: Dropdown usa StatusOSModel (Enum da Entidade) ***
              _buildDropdownFormField<StatusOSModel>(
                label: 'Status*',
                value: _selectedStatus,
                items: StatusOSModel.values.map((s) => DropdownMenuItem(value: s, child: Text(_getStatusText(s), style: GoogleFonts.poppins()))).toList(),
                onChanged: (value) => setState(() => _selectedStatus = value),
                validator: (value) => value == null ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              // *** CORREÇÃO: Dropdown usa PrioridadeOSModel (Enum da Entidade) ***
              _buildDropdownFormField<PrioridadeOSModel>(
                label: 'Prioridade',
                value: _selectedPrioridade,
                items: PrioridadeOSModel.values.map((p) => DropdownMenuItem(value: p, child: Text(_getPrioridadeText(p), style: GoogleFonts.poppins()))).toList(),
                onChanged: (value) => setState(() => _selectedPrioridade = value),
              ),
              const SizedBox(height: 16),
              _buildDateField(label: 'Data de Agendamento'),
              const SizedBox(height: 24),

              _buildSectionTitle('Diagnóstico e Solução'),
              _buildTextFormField(
                controller: _analiseController,
                label: 'Análise da Falha',
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _solucaoController,
                label: 'Solução Aplicada',
                maxLines: 4,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      );
    } else {
      return const Center(child: Text("Erro inesperado ao carregar dados da OS."));
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.primaryBlue),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: AppColors.textLight),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      style: GoogleFonts.poppins(color: AppColors.textDark),
      maxLines: maxLines,
      validator: validator,
      keyboardType: keyboardType,
    );
  }

  Widget _buildDropdownFormField<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?)? onChanged,
    String? Function(T?)? validator,
    String hint = 'Selecione',
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: AppColors.textLight),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      hint: Text(hint, style: GoogleFonts.poppins(color: Colors.grey.shade400)),
      isExpanded: true,
      style: GoogleFonts.poppins(color: AppColors.textDark, fontSize: 14),
    );
  }

  Widget _buildDateField({required String label}) {
    return InkWell(
      onTap: () => _selectDate(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(color: AppColors.textLight),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          suffixIcon: const Icon(Icons.calendar_today_outlined, color: AppColors.textLight),
        ),
        child: Text(
          _selectedDataAgendamento == null
              ? 'Selecione uma data'
              : DateFormat('dd/MM/yyyy').format(_selectedDataAgendamento!),
          style: GoogleFonts.poppins(
            color: _selectedDataAgendamento == null ? Colors.grey.shade500 : AppColors.textDark,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // *** CORREÇÃO: Funções de texto usam os ENUMS da ENTIDADE e cobrem todos os casos ***
  String _getStatusText(StatusOSModel status) {
    switch (status) {
      case StatusOSModel.CONCLUIDA:
        return 'Concluída';
      case StatusOSModel.EM_ANDAMENTO:
        return 'Em Andamento';
      case StatusOSModel.EM_ABERTO:
        return 'Em Aberto';
      case StatusOSModel.ENCERRADA:
        return 'Encerrada';
      case StatusOSModel.CANCELADA:
        return 'Cancelada';
      case StatusOSModel.PENDENTE_PECAS:
        return 'Pendente';
      case StatusOSModel.ATRIBUIDA: // Adicionado
        return 'Atribuída';
      case StatusOSModel.AGUARDANDO_APROVACAO: // Adicionado
        return 'Aguardando Aprovação';
      default: // Adicionado um default para segurança
        return 'Desconhecido';
    }
  }

  String _getPrioridadeText(PrioridadeOSModel? prioridade) {
    if (prioridade == null) return 'Não definida';
    switch (prioridade) {
      case PrioridadeOSModel.BAIXA:
        return 'Baixa';
      case PrioridadeOSModel.MEDIA:
        return 'Média';
      case PrioridadeOSModel.ALTA:
        return 'Alta';
      case PrioridadeOSModel.URGENTE:
        return 'Urgente';
      default: // Adicionado um default para segurança
        return 'Desconhecida';
    }
  }
}