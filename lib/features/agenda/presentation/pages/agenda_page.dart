import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:uuid/uuid.dart';
import 'package:contorno/core/inject/inject.dart';
import 'package:contorno/features/agenda/domain/entities/agendamento_entity.dart';
import 'package:contorno/features/agenda/domain/enums/agenda_enums.dart';
import 'package:contorno/features/agenda/presentation/cubit/agenda_cubit.dart';
import 'package:contorno/features/agenda/presentation/cubit/agenda_state.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:contorno/features/paciente/domain/entities/paciente_entity.dart';
import 'package:contorno/features/paciente/domain/repositories/paciente_repository.dart';
import 'package:contorno/features/paciente/presentation/cubit/paciente_cubit.dart';
import 'package:contorno/features/paciente/presentation/cubit/paciente_state.dart';
import 'package:contorno/features/paciente/presentation/pages/paciente_detalhes_page.dart';

class AgendaPage extends StatefulWidget {
  const AgendaPage({super.key});

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  Future<void> _enviarLembrete(AgendamentoEntity sessao) async {
    final pacienteRepo = getIt<IPacienteRepository>();
    final paciente = await pacienteRepo.buscarPacientePorId(sessao.pacienteId);

    if (paciente == null || paciente.telefone.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Paciente não possui telefone cadastrado.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final telefoneLimpo = paciente.telefone.replaceAll(RegExp(r'\D'), '');
    final horaStr = DateFormat('HH:mm').format(sessao.dataHora);
    final mensagem = "Olá, ${paciente.nome}! Passando para lembrar da nossa sessão hoje às $horaStr. Te aguardo!";

    final url = Uri.parse('https://wa.me/55$telefoneLimpo?text=${Uri.encodeComponent(mensagem)}');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível abrir o WhatsApp.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    context.read<AgendaCubit>().carregarAgendamentos(_selectedDay);
  }

  void _abrirModalNovoAgendamento(BuildContext context) {
    final agendaCubit = context.read<AgendaCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<AgendaCubit>.value(value: agendaCubit),
            BlocProvider<PacienteCubit>(
              create: (_) => getIt<PacienteCubit>()..carregarPacientes(),
            ),
          ],
          child: _NovoAgendamentoModal(dataInicial: _selectedDay),
        );
      },
    ).then((_) {
      agendaCubit.carregarAgendamentos(_selectedDay);
    });
  }

  String _formatarFrequencia(FrequenciaRecorrencia freq) {
    switch (freq) {
      case FrequenciaRecorrencia.semanal:
        return 'Semanal';
      case FrequenciaRecorrencia.quinzenal:
        return 'Quinzenal';
      case FrequenciaRecorrencia.duasVezesSemana:
        return '2x na semana';
      case FrequenciaRecorrencia.nenhuma:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          // Calendário Mensal Interativo Refinado
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 4.0,
              ),
              child: BlocBuilder<AgendaCubit, AgendaState>(
                builder: (context, state) {
                  Map<DateTime, List<AgendamentoEntity>> agendamentosPorData =
                      {};
                  if (state is AgendaLoaded) {
                    agendamentosPorData = state.agendamentosPorData;
                  }

                  return TableCalendar<AgendamentoEntity>(
                    locale: 'pt_BR',
                    firstDay: DateTime(2020),
                    lastDay: DateTime(2030),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    eventLoader: (day) {
                      final key = DateTime(day.year, day.month, day.day);
                      return agendamentosPorData[key] ?? [];
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                      context.read<AgendaCubit>().carregarAgendamentos(
                        selectedDay,
                      );
                    },
                    onFormatChanged: (format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: theme.colorScheme.secondary,
                        shape: BoxShape.circle,
                      ),
                      todayTextStyle: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      selectedTextStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, date, events) {
                        if (events.isNotEmpty) {
                          return Positioned(
                            bottom: 2,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.tertiary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          );
                        }
                        return null;
                      },
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Cabeçalho da Seção de Sessões do Dia
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sessões do Dia',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  '${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // Lista de Agendamentos do Dia Selecionado
          Expanded(
            child: BlocBuilder<AgendaCubit, AgendaState>(
              builder: (context, state) {
                if (state is AgendaLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is AgendaError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  );
                }

                if (state is AgendaLoaded) {
                  final agendamentos = state.agendamentos;

                  if (agendamentos.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_available,
                            size: 64,
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.4,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhum atendimento agendado para este dia',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Clique no botão + para agendar um horário.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: agendamentos.length,
                    itemBuilder: (context, index) {
                      final item = agendamentos[index];
                      final hora =
                          '${item.dataHora.hour.toString().padLeft(2, '0')}:${item.dataHora.minute.toString().padLeft(2, '0')}';
                      final bool isPassada = item.dataHora.isBefore(
                        DateTime.now(),
                      );

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: isPassada ? Colors.grey.shade100 : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: isPassada
                              ? BorderSide(color: Colors.grey.shade300)
                              : BorderSide.none,
                        ),
                        elevation: isPassada ? 0 : 1,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () async {
                            final pacienteRepo = getIt<IPacienteRepository>();
                            final paciente = await pacienteRepo
                                .buscarPacientePorId(item.pacienteId);
                            if (paciente != null && context.mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      PacienteDetalhesPage(paciente: paciente),
                                ),
                              );
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                // Horário em Destaque à Esquerda
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isPassada
                                        ? Colors.grey.shade300
                                        : theme.colorScheme.primary.withValues(
                                            alpha: 0.1,
                                          ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    hora,
                                    style: TextStyle(
                                      color: isPassada
                                          ? Colors.grey.shade700
                                          : theme.colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Detalhes do Agendamento à Direita
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Linha 1: Nome do Paciente (sem quebras indesejadas)
                                      Text(
                                        item.pacienteNome ?? 'Paciente',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: isPassada
                                              ? Colors.grey.shade700
                                              : Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      // Linha 2: Valor da Sessão
                                      Text(
                                        'Valor: R\$ ${item.valorSessao.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: isPassada
                                              ? Colors.grey.shade500
                                              : Colors.grey.shade700,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      // Linha 3: Badges de Status e Recorrência
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 4,
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isPassada
                                                  ? Colors.grey.shade300
                                                  : Colors.green.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              isPassada &&
                                                      item.status ==
                                                          StatusAgendamento
                                                              .agendada
                                                  ? 'REALIZADA'
                                                  : item.status.name
                                                        .toUpperCase(),
                                              style: TextStyle(
                                                color: isPassada
                                                    ? Colors.grey.shade800
                                                    : Colors.green.shade800,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          if (item.isRecorrente)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: isPassada
                                                    ? Colors.grey.shade200
                                                    : theme.colorScheme.primary
                                                          .withValues(
                                                            alpha: 0.15,
                                                          ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.repeat,
                                                    size: 12,
                                                    color: isPassada
                                                        ? Colors.grey.shade600
                                                        : theme
                                                              .colorScheme
                                                              .primary,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    _formatarFrequencia(
                                                      item.frequencia,
                                                    ),
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: isPassada
                                                          ? Colors.grey.shade600
                                                          : theme
                                                                .colorScheme
                                                                .primary,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                if (!isPassada && item.status == StatusAgendamento.agendada) ...[
                                  IconButton(
                                    onPressed: () => _enviarLembrete(item),
                                    icon: const Icon(
                                      Icons.notifications_active_outlined,
                                      color: Colors.green,
                                      size: 22,
                                    ),
                                    tooltip: 'Enviar Lembrete pré-sessão',
                                  ),
                                ],
                              ],
                            ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirModalNovoAgendamento(context),
        backgroundColor: theme.colorScheme.tertiary,
        foregroundColor: Colors.black87,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _NovoAgendamentoModal extends StatefulWidget {
  final DateTime dataInicial;

  const _NovoAgendamentoModal({required this.dataInicial});

  @override
  State<_NovoAgendamentoModal> createState() => _NovoAgendamentoModalState();
}

class _NovoAgendamentoModalState extends State<_NovoAgendamentoModal> {
  final _formKey = GlobalKey<FormState>();

  PacienteEntity? _pacienteSelecionado;
  TimeOfDay _horarioSelecionado = const TimeOfDay(hour: 09, minute: 00);
  final _valorController = TextEditingController();
  final _obsController = TextEditingController();

  bool _isRecorrente = false;
  FrequenciaRecorrencia _frequencia = FrequenciaRecorrencia.semanal;
  int _quantidadeSemanas = 4;

  @override
  void dispose() {
    _valorController.dispose();
    _obsController.dispose();
    super.dispose();
  }

  void _submeter() {
    final isFormValid = _formKey.currentState?.validate() ?? false;
    if (isFormValid && _pacienteSelecionado != null) {
      final psicologoId = Supabase.instance.client.auth.currentUser?.id ?? '';
      final dataHora = DateTime(
        widget.dataInicial.year,
        widget.dataInicial.month,
        widget.dataInicial.day,
        _horarioSelecionado.hour,
        _horarioSelecionado.minute,
      );

      final agendamento = AgendamentoEntity(
        id: const Uuid().v4(),
        psicologoId: psicologoId,
        pacienteId: _pacienteSelecionado!.id,
        pacienteNome: _pacienteSelecionado!.nome,
        dataHora: dataHora,
        valorSessao:
            double.tryParse(_valorController.text.replaceAll(',', '.')) ?? 0.0,
        observacoes: _obsController.text.trim().isEmpty
            ? null
            : _obsController.text.trim(),
        isRecorrente: _isRecorrente,
        frequencia: _isRecorrente ? _frequencia : FrequenciaRecorrencia.nenhuma,
      );

      context.read<AgendaCubit>().cadastrarAgendamento(
        agendamento,
        repeticoes: _isRecorrente ? _quantidadeSemanas : 1,
      );
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
                'Agendar Nova Sessão',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 20),

              // Dropdown de Pacientes
              BlocBuilder<PacienteCubit, PacienteState>(
                builder: (context, state) {
                  if (state is PacienteLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is PacienteLoaded) {
                    final pacientes = state.pacientes;

                    return DropdownButtonFormField<PacienteEntity>(
                      initialValue: _pacienteSelecionado,
                      decoration: InputDecoration(
                        labelText: 'Selecione o Paciente *',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: pacientes.map((p) {
                        return DropdownMenuItem(value: p, child: Text(p.nome));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _pacienteSelecionado = val;
                            _valorController.text = val.valorSessaoPadrao
                                .toStringAsFixed(2);
                          });
                        }
                      },
                      validator: (val) =>
                          val == null ? 'Selecione um paciente' : null,
                    );
                  }

                  return const Text('Erro ao carregar lista de pacientes.');
                },
              ),

              const SizedBox(height: 16),

              // Seletor de Horário
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade400),
                ),
                leading: const Icon(Icons.access_time),
                title: Text('Horário: ${_horarioSelecionado.format(context)}'),
                trailing: const Icon(Icons.edit_calendar),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: _horarioSelecionado,
                  );
                  if (picked != null) {
                    setState(() {
                      _horarioSelecionado = picked;
                    });
                  }
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _valorController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Valor da Sessão (R\$) *',
                  prefixIcon: const Icon(Icons.attach_money),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Informe o valor';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Switch Recorrência
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Sessão Recorrente'),
                subtitle: const Text(
                  'Repete automaticamente com base no padrão selecionado',
                ),
                value: _isRecorrente,
                onChanged: (val) {
                  setState(() {
                    _isRecorrente = val;
                  });
                },
              ),

              if (_isRecorrente) ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<FrequenciaRecorrencia>(
                  initialValue: _frequencia,
                  decoration: InputDecoration(
                    labelText: 'Frequência de Repetição',
                    prefixIcon: const Icon(Icons.repeat),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: FrequenciaRecorrencia.semanal,
                      child: Text('Semanal (1x por semana)'),
                    ),
                    DropdownMenuItem(
                      value: FrequenciaRecorrencia.quinzenal,
                      child: Text('Quinzenal (A cada 2 semanas)'),
                    ),
                    DropdownMenuItem(
                      value: FrequenciaRecorrencia.duasVezesSemana,
                      child: Text('2x na semana (Alternado)'),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _frequencia = val;
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: _quantidadeSemanas,
                  decoration: InputDecoration(
                    labelText: 'Duração da Recorrência',
                    prefixIcon: const Icon(Icons.date_range),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 4,
                      child: Text('4 Semanas (1 Mês)'),
                    ),
                    DropdownMenuItem(
                      value: 8,
                      child: Text('8 Semanas (2 Meses)'),
                    ),
                    DropdownMenuItem(
                      value: 12,
                      child: Text('12 Semanas (3 Meses)'),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _quantidadeSemanas = val;
                      });
                    }
                  },
                ),
              ],

              const SizedBox(height: 16),

              TextFormField(
                controller: _obsController,
                decoration: InputDecoration(
                  labelText: 'Observações (Opcional)',
                  prefixIcon: const Icon(Icons.note_alt_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
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
                    'Confirmar Agendamento',
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
