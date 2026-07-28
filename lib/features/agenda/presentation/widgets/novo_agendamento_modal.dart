import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:contorno/features/agenda/domain/entities/agendamento_entity.dart';
import 'package:contorno/features/agenda/domain/enums/agenda_enums.dart';
import 'package:contorno/features/agenda/presentation/cubit/agenda_cubit.dart';
import 'package:contorno/features/paciente/domain/entities/paciente_entity.dart';
import 'package:contorno/features/paciente/presentation/cubit/paciente_cubit.dart';
import 'package:contorno/features/paciente/presentation/cubit/paciente_state.dart';

class NovoAgendamentoModal extends StatefulWidget {
  final DateTime dataInicial;

  const NovoAgendamentoModal({
    super.key,
    required this.dataInicial,
  });

  @override
  State<NovoAgendamentoModal> createState() => _NovoAgendamentoModalState();
}

class _NovoAgendamentoModalState extends State<NovoAgendamentoModal> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _dataSelecionada;
  late TimeOfDay _horaSelecionada;
  final _valorController = TextEditingController(text: '150.00');
  final _obsController = TextEditingController();

  PacienteEntity? _pacienteSelecionado;
  final bool _isRecorrente = false;
  final FrequenciaRecorrencia _frequencia = FrequenciaRecorrencia.semanal;

  @override
  void initState() {
    super.initState();
    _dataSelecionada = widget.dataInicial;
    _horaSelecionada = const TimeOfDay(hour: 14, minute: 0);
  }

  @override
  void dispose() {
    _valorController.dispose();
    _obsController.dispose();
    super.dispose();
  }

  void _salvarAgendamento() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_pacienteSelecionado == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selecione um paciente para o agendamento.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final dataHoraFinal = DateTime(
        _dataSelecionada.year,
        _dataSelecionada.month,
        _dataSelecionada.day,
        _horaSelecionada.hour,
        _horaSelecionada.minute,
      );

      final novoAgendamento = AgendamentoEntity(
        id: const Uuid().v4(),
        psicologoId:
            Supabase.instance.client.auth.currentUser?.id ?? 'psicologo_1',
        pacienteId: _pacienteSelecionado!.id,
        pacienteNome: _pacienteSelecionado!.nome,
        dataHora: dataHoraFinal,
        valorSessao: double.tryParse(_valorController.text) ?? 150.0,
        status: StatusAgendamento.agendada,
        statusPagamento: StatusPagamento.pendente,
        observacoes: _obsController.text.trim(),
        isRecorrente: _isRecorrente,
        frequencia: _frequencia,
      );

      context.read<AgendaCubit>().cadastrarAgendamento(novoAgendamento);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 20,
        left: 20,
        right: 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Novo Agendamento',
                    style: TextStyle(
                      fontFamily: 'Serif',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C2448),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              BlocBuilder<PacienteCubit, PacienteState>(
                builder: (context, state) {
                  if (state is PacienteLoading) {
                    return const CircularProgressIndicator();
                  }

                  List<PacienteEntity> pacientes = [];
                  if (state is PacienteLoaded) {
                    pacientes = state.pacientes;
                  }

                  return DropdownButtonFormField<PacienteEntity>(
                    decoration: InputDecoration(
                      labelText: 'Paciente',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    initialValue: _pacienteSelecionado,
                    items: pacientes.map((p) {
                      return DropdownMenuItem<PacienteEntity>(
                        value: p,
                        child: Text(p.nome),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _pacienteSelecionado = val;
                      });
                    },
                    validator: (val) =>
                        val == null ? 'Selecione um paciente' : null,
                  );
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.calendar_today, size: 18),
                      label: Text(
                        DateFormat('dd/MM/yyyy').format(_dataSelecionada),
                      ),
                      onPressed: () async {
                        final data = await showDatePicker(
                          context: context,
                          initialDate: _dataSelecionada,
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
                        if (data != null) {
                          setState(() => _dataSelecionada = data);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.access_time, size: 18),
                      label: Text(_horaSelecionada.format(context)),
                      onPressed: () async {
                        final hora = await showTimePicker(
                          context: context,
                          initialTime: _horaSelecionada,
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
                        if (hora != null) {
                          setState(() => _horaSelecionada = hora);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _valorController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Valor da Sessão (R\$)',
                  prefixIcon: const Icon(Icons.attach_money),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _salvarAgendamento,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3A345C),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Confirmar Agendamento',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
