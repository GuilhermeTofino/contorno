import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:contorno/core/inject/inject.dart';
import 'package:contorno/features/agenda/domain/entities/agendamento_entity.dart';
import 'package:contorno/features/agenda/domain/enums/agenda_enums.dart';
import 'package:contorno/features/paciente/domain/repositories/paciente_repository.dart';
import 'package:contorno/features/paciente/presentation/pages/paciente_detalhes_page.dart';

class TodaySessionsList extends StatelessWidget {
  final List<AgendamentoEntity> agendamentos;
  final ValueChanged<int> onVerAgenda;

  const TodaySessionsList({
    super.key,
    required this.agendamentos,
    required this.onVerAgenda,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Sessões de Hoje',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C2448),
              ),
            ),
            TextButton(
              onPressed: () => onVerAgenda(1),
              child: const Text(
                'Ver agenda',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3A345C),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (agendamentos.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text(
                'Nenhum agendamento para hoje.',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: agendamentos.length,
              separatorBuilder: (_, _) => Divider(
                height: 1,
                color: Colors.grey.shade200,
              ),
              itemBuilder: (ctx, idx) {
                final sessao = agendamentos[idx];
                final hora = DateFormat('HH:mm').format(sessao.dataHora);

                return ListTile(
                  leading: Text(
                    hora,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3A345C),
                      fontSize: 14,
                    ),
                  ),
                  title: Text(
                    sessao.pacienteNome ?? 'Paciente',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    sessao.statusPagamento == StatusPagamento.pago
                        ? 'Pago'
                        : 'Agendado',
                    style: TextStyle(
                      fontSize: 12,
                      color: sessao.statusPagamento == StatusPagamento.pago
                          ? Colors.green.shade700
                          : Colors.grey.shade600,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: Colors.grey,
                  ),
                  onTap: () async {
                    final pacienteRepo = getIt<IPacienteRepository>();
                    final paciente = await pacienteRepo
                        .buscarPacientePorId(sessao.pacienteId);
                    if (paciente != null && context.mounted) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PacienteDetalhesPage(
                            paciente: paciente,
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}
