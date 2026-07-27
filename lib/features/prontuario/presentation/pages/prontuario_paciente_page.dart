import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:contorno/features/paciente/domain/entities/paciente_entity.dart';
import 'package:contorno/features/prontuario/domain/entities/evolucao_entity.dart';
import 'package:contorno/features/prontuario/presentation/cubit/evolucao_cubit.dart';
import 'package:contorno/features/prontuario/presentation/cubit/evolucao_state.dart';

class ProntuarioPacientePage extends StatefulWidget {
  final PacienteEntity paciente;

  const ProntuarioPacientePage({
    super.key,
    required this.paciente,
  });

  @override
  State<ProntuarioPacientePage> createState() => _ProntuarioPacientePageState();
}

class _ProntuarioPacientePageState extends State<ProntuarioPacientePage> {
  @override
  void initState() {
    super.initState();
    context.read<EvolucaoCubit>().carregarEvolucoes(widget.paciente.id);
  }

  void _abrirModalNovaEvolucao(BuildContext context) {
    final evolucaoCubit = context.read<EvolucaoCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return BlocProvider<EvolucaoCubit>.value(
          value: evolucaoCubit,
          child: _NovaEvolucaoModal(paciente: widget.paciente),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Prontuário - ${widget.paciente.nome}'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header Card Paciente
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.paciente.nome,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Telefone: ${widget.paciente.telefone} • Tipo: ${widget.paciente.tipoAtendimento.name.toUpperCase()}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),

          // Seção de Evoluções
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              children: [
                Text(
                  'Evoluções Clínicas',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: BlocBuilder<EvolucaoCubit, EvolucaoState>(
              builder: (context, state) {
                if (state is EvolucaoLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is EvolucaoError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  );
                }

                if (state is EvolucaoLoaded) {
                  final evolucoes = state.evolucoes;

                  if (evolucoes.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.note_alt_outlined,
                            size: 64,
                            color: theme.colorScheme.primary.withValues(alpha: 0.4),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhuma evolução registrada',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Clique no botão + para adicionar a primeira anotação.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: evolucoes.length,
                    itemBuilder: (context, index) {
                      final item = evolucoes[index];
                      final dataStr = DateFormat("dd/MM/yyyy 'às' HH:mm", 'pt_BR').format(item.dataHora);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        size: 14,
                                        color: theme.colorScheme.primary,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        dataStr,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const Divider(height: 16),
                              Text(
                                item.texto,
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.4,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirModalNovaEvolucao(context),
        backgroundColor: theme.colorScheme.tertiary,
        foregroundColor: Colors.black87,
        icon: const Icon(Icons.add_comment),
        label: const Text(
          'Nova Evolução',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _NovaEvolucaoModal extends StatefulWidget {
  final PacienteEntity paciente;

  const _NovaEvolucaoModal({required this.paciente});

  @override
  State<_NovaEvolucaoModal> createState() => _NovaEvolucaoModalState();
}

class _NovaEvolucaoModalState extends State<_NovaEvolucaoModal> {
  final _formKey = GlobalKey<FormState>();
  final _textoController = TextEditingController();
  final DateTime _dataHora = DateTime.now();

  @override
  void dispose() {
    _textoController.dispose();
    super.dispose();
  }

  void _submeter() {
    final isFormValid = _formKey.currentState?.validate() ?? false;
    if (isFormValid) {
      final psicologoId = Supabase.instance.client.auth.currentUser?.id ?? '';

      final evolucao = EvolucaoEntity(
        id: const Uuid().v4(),
        psicologoId: psicologoId,
        pacienteId: widget.paciente.id,
        dataHora: _dataHora,
        texto: _textoController.text.trim(),
      );

      context.read<EvolucaoCubit>().cadastrarEvolucao(evolucao);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Nova Anotação Clínica / Evolução',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _textoController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Descrição da Sessão / Observações *',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Digite o relato da evolução clínica';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _submeter,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.tertiary,
                    foregroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Salvar no Prontuário',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
