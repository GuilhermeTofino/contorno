import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:contorno/core/inject/inject.dart';
import 'package:contorno/features/agenda/domain/entities/agendamento_entity.dart';
import 'package:contorno/features/paciente/domain/repositories/paciente_repository.dart';
import 'package:contorno/features/paciente/presentation/pages/paciente_detalhes_page.dart';

class NextSessionCard extends StatelessWidget {
  final AgendamentoEntity sessao;
  final Future<void> Function(AgendamentoEntity) onEnviarLembrete;

  const NextSessionCard({
    super.key,
    required this.sessao,
    required this.onEnviarLembrete,
  });

  @override
  Widget build(BuildContext context) {
    final nomePaciente = sessao.pacienteNome ?? 'Paciente';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Próxima Sessão',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C2448),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3A345C), Color(0xFF2C2448)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3A345C).withValues(alpha: 0.3),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: const Color(0xFFE4B363),
                    child: Text(
                      nomePaciente.isNotEmpty
                          ? nomePaciente[0].toUpperCase()
                          : 'P',
                      style: const TextStyle(
                        color: Color(0xFF3A345C),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nomePaciente,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Sessão Individual • 50 min',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.75),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      DateFormat('HH:mm').format(sessao.dataHora),
                      style: const TextStyle(
                        color: Color(0xFFE4B363),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => onEnviarLembrete(sessao),
                      icon: const Icon(
                        Icons.notifications_active_outlined,
                        size: 16,
                        color: Color(0xFFE4B363),
                      ),
                      label: const Text(
                        'Lembrete WhatsApp',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () async {
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE4B363),
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Iniciar',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
