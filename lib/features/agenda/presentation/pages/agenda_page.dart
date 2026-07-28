import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:contorno/core/inject/inject.dart';
import 'package:contorno/features/agenda/domain/entities/agendamento_entity.dart';
import 'package:contorno/features/agenda/domain/enums/agenda_enums.dart';
import 'package:contorno/features/agenda/presentation/cubit/agenda_cubit.dart';
import 'package:contorno/features/agenda/presentation/cubit/agenda_state.dart';
import 'package:contorno/features/paciente/domain/repositories/paciente_repository.dart';
import 'package:contorno/features/paciente/presentation/cubit/paciente_cubit.dart';
import 'package:contorno/features/splash/presentation/widgets/brand_backdrop.dart';

import '../widgets/agenda_header.dart';
import '../widgets/agenda_calendar_widget.dart';
import '../widgets/session_timer_bar.dart';
import '../widgets/session_card_item.dart';
import '../widgets/novo_agendamento_modal.dart';

class AgendaPage extends StatefulWidget {
  const AgendaPage({super.key});

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.week;

  // Lógica de Timer para Sessão em Andamento
  String? _sessaoEmAndamentoId;
  Timer? _sessaoTimer;
  int _tempoRestanteSegundos = 0;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    context.read<AgendaCubit>().carregarAgendamentos(_selectedDay);
  }

  @override
  void dispose() {
    _sessaoTimer?.cancel();
    super.dispose();
  }

  void _iniciarCronometroSessao(AgendamentoEntity sessao, int duracaoMinutos) {
    _sessaoTimer?.cancel();
    setState(() {
      _sessaoEmAndamentoId = sessao.id;
      _tempoRestanteSegundos = duracaoMinutos * 60;
    });

    _sessaoTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_tempoRestanteSegundos > 0) {
        setState(() {
          _tempoRestanteSegundos--;
        });
      } else {
        timer.cancel();
        _finalizarSessaoAutomatica(sessao);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Sessão com ${sessao.pacienteNome ?? "Paciente"} iniciada! Duração: $duracaoMinutos min.',
        ),
        backgroundColor: const Color(0xFF3A345C),
      ),
    );
  }

  Future<void> _finalizarSessaoAutomatica(AgendamentoEntity sessao) async {
    final sessaoAtualizada = AgendamentoEntity(
      id: sessao.id,
      psicologoId: sessao.psicologoId,
      pacienteId: sessao.pacienteId,
      pacienteNome: sessao.pacienteNome,
      dataHora: sessao.dataHora,
      valorSessao: sessao.valorSessao,
      status: StatusAgendamento.realizada,
      statusPagamento: sessao.statusPagamento,
      observacoes: sessao.observacoes,
      isRecorrente: sessao.isRecorrente,
      frequencia: sessao.frequencia,
      grupoRecorrenciaId: sessao.grupoRecorrenciaId,
    );

    await context.read<AgendaCubit>().atualizarAgendamento(sessaoAtualizada);
    setState(() {
      _sessaoEmAndamentoId = null;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Sessão com ${sessao.pacienteNome ?? "Paciente"} concluída e registrada como Realizada!',
          ),
          backgroundColor: Colors.green.shade700,
        ),
      );
    }
  }

  Future<void> _alterarStatusSessao(
    AgendamentoEntity sessao,
    StatusAgendamento novoStatus,
  ) async {
    final sessaoAtualizada = AgendamentoEntity(
      id: sessao.id,
      psicologoId: sessao.psicologoId,
      pacienteId: sessao.pacienteId,
      pacienteNome: sessao.pacienteNome,
      dataHora: sessao.dataHora,
      valorSessao: sessao.valorSessao,
      status: novoStatus,
      statusPagamento: sessao.statusPagamento,
      observacoes: sessao.observacoes,
      isRecorrente: sessao.isRecorrente,
      frequencia: sessao.frequencia,
      grupoRecorrenciaId: sessao.grupoRecorrenciaId,
    );

    await context.read<AgendaCubit>().atualizarAgendamento(sessaoAtualizada);
  }

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
    final mensagem =
        "Olá, ${paciente.nome}! Passando para lembrar da nossa sessão hoje às $horaStr. Te aguardo!";

    final url = Uri.parse(
      'https://wa.me/55$telefoneLimpo?text=${Uri.encodeComponent(mensagem)}',
    );

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

  Future<void> _reagendarSessaoModal(AgendamentoEntity sessao) async {
    DateTime dataSelecionada = sessao.dataHora;
    TimeOfDay horaSelecionada = TimeOfDay.fromDateTime(sessao.dataHora);

    final novaData = await showDatePicker(
      context: context,
      initialDate: dataSelecionada,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3A345C),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF2C2448),
              secondary: Color(0xFFE4B363),
            ),
          ),
          child: child!,
        );
      },
    );

    if (novaData != null && mounted) {
      final novaHora = await showTimePicker(
        context: context,
        initialTime: horaSelecionada,
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF3A345C),
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Color(0xFF2C2448),
                secondary: Color(0xFFE4B363),
              ),
            ),
            child: child!,
          );
        },
      );

      if (novaHora != null && mounted) {
        final novaDataHora = DateTime(
          novaData.year,
          novaData.month,
          novaData.day,
          novaHora.hour,
          novaHora.minute,
        );

        final sessaoReagendada = AgendamentoEntity(
          id: sessao.id,
          psicologoId: sessao.psicologoId,
          pacienteId: sessao.pacienteId,
          pacienteNome: sessao.pacienteNome,
          dataHora: novaDataHora,
          valorSessao: sessao.valorSessao,
          status: StatusAgendamento.agendada,
          statusPagamento: sessao.statusPagamento,
          observacoes: sessao.observacoes,
          isRecorrente: sessao.isRecorrente,
          frequencia: sessao.frequencia,
          grupoRecorrenciaId: sessao.grupoRecorrenciaId,
        );

        await context
            .read<AgendaCubit>()
            .atualizarAgendamento(sessaoReagendada);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sessão reagendada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    }
  }

  Future<void> _adicionarNotaRapidaModal(AgendamentoEntity sessao) async {
    final noteController = TextEditingController(text: sessao.observacoes ?? '');

    final nota = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nota Rápida / Prontuário'),
        content: TextField(
          controller: noteController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Digite anotações rápidas sobre esta sessão...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(noteController.text.trim()),
            child: const Text('Salvar Nota'),
          ),
        ],
      ),
    );

    if (nota != null && mounted) {
      final sessaoComNota = AgendamentoEntity(
        id: sessao.id,
        psicologoId: sessao.psicologoId,
        pacienteId: sessao.pacienteId,
        pacienteNome: sessao.pacienteNome,
        dataHora: sessao.dataHora,
        valorSessao: sessao.valorSessao,
        status: sessao.status,
        statusPagamento: sessao.statusPagamento,
        observacoes: nota,
        isRecorrente: sessao.isRecorrente,
        frequencia: sessao.frequencia,
        grupoRecorrenciaId: sessao.grupoRecorrenciaId,
      );

      await context.read<AgendaCubit>().atualizarAgendamento(sessaoComNota);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nota salva com sucesso no prontuário!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
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
          child: NovoAgendamentoModal(dataInicial: _selectedDay),
        );
      },
    ).then((_) {
      agendaCubit.carregarAgendamentos(_selectedDay);
    });
  }

  String _formatarTempoRestante() {
    final min = (_tempoRestanteSegundos ~/ 60).toString().padLeft(2, '0');
    final sec = (_tempoRestanteSegundos % 60).toString().padLeft(2, '0');
    return '$min:$sec';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 70),
        child: FloatingActionButton.extended(
          onPressed: () => _abrirModalNovoAgendamento(context),
          backgroundColor: const Color(0xFF3A345C),
          foregroundColor: const Color(0xFFE4B363),
          elevation: 4,
          icon: const Icon(Icons.add_rounded),
          label: const Text(
            'Novo Agendamento',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: BrandBackdrop(
        child: SafeArea(
          child: Column(
            children: [
              // 1. CABEÇALHO DO MÊS E BUSCA
              AgendaHeader(
                focusedDay: _focusedDay,
                isWeekFormat: _calendarFormat == CalendarFormat.week,
                onToggleFormat: () {
                  setState(() {
                    _calendarFormat = _calendarFormat == CalendarFormat.week
                        ? CalendarFormat.month
                        : CalendarFormat.week;
                  });
                },
                onSearchPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Busca na agenda em breve!'),
                    ),
                  );
                },
              ),

              // 2. SELETOR DE DIAS DA SEMANA / MÊS
              BlocBuilder<AgendaCubit, AgendaState>(
                builder: (context, state) {
                  Map<DateTime, List<AgendamentoEntity>> agendamentosPorData = {};
                  if (state is AgendaLoaded) {
                    agendamentosPorData = state.agendamentosPorData;
                  }

                  return AgendaCalendarWidget(
                    focusedDay: _focusedDay,
                    selectedDay: _selectedDay,
                    calendarFormat: _calendarFormat,
                    agendamentosPorData: agendamentosPorData,
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                      context
                          .read<AgendaCubit>()
                          .carregarAgendamentos(selectedDay);
                    },
                    onFormatChanged: (format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    },
                    onPageChanged: (focusedDay) {
                      setState(() {
                        _focusedDay = focusedDay;
                      });
                    },
                  );
                },
              ),

              const SizedBox(height: 14),

              // BARRA DE CRONÔMETRO DE SESSÃO EM ANDAMENTO (SE HOUVER)
              if (_sessaoEmAndamentoId != null)
                SessionTimerBar(
                  tempoRestanteSegundos: _tempoRestanteSegundos,
                  onStopTimer: () {
                    _sessaoTimer?.cancel();
                    setState(() {
                      _sessaoEmAndamentoId = null;
                    });
                  },
                ),

              // 3. TIMELINE E LISTA DE CARDS DE SESSÃO
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
                                Icons.calendar_month_outlined,
                                size: 56,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Sem atendimentos agendados',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2C2448),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Toque em Novo Agendamento para marcar.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: 8,
                          bottom: 100,
                        ),
                        itemCount: agendamentos.length,
                        itemBuilder: (context, index) {
                          final item = agendamentos[index];
                          final isEmAndamento = _sessaoEmAndamentoId == item.id;
                          final progressoTimer = isEmAndamento
                              ? (_tempoRestanteSegundos / (50 * 60))
                              : 0.0;

                          return SessionCardItem(
                            sessao: item,
                            isEmAndamento: isEmAndamento,
                            tempoRestanteFormatado: _formatarTempoRestante(),
                            progressoTimer: progressoTimer,
                            onAlterarStatus: _alterarStatusSessao,
                            onReagendar: _reagendarSessaoModal,
                            onAdicionarNota: _adicionarNotaRapidaModal,
                            onEnviarLembrete: _enviarLembrete,
                            onIniciarSessao: _iniciarCronometroSessao,
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
        ),
      ),
    );
  }
}
