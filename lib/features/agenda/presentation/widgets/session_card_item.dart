import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:contorno/features/agenda/domain/entities/agendamento_entity.dart';
import 'package:contorno/features/agenda/domain/enums/agenda_enums.dart';

class SessionCardItem extends StatelessWidget {
  final AgendamentoEntity sessao;
  final bool isEmAndamento;
  final String tempoRestanteFormatado;
  final double progressoTimer; // 0.0 a 1.0 (onde 1.0 é inicio e 0.0 é fim)
  final Function(AgendamentoEntity, StatusAgendamento) onAlterarStatus;
  final Function(AgendamentoEntity) onReagendar;
  final Function(AgendamentoEntity) onAdicionarNota;
  final Function(AgendamentoEntity) onEnviarLembrete;
  final Function(AgendamentoEntity, int) onIniciarSessao;

  const SessionCardItem({
    super.key,
    required this.sessao,
    required this.isEmAndamento,
    required this.tempoRestanteFormatado,
    this.progressoTimer = 0.0,
    required this.onAlterarStatus,
    required this.onReagendar,
    required this.onAdicionarNota,
    required this.onEnviarLembrete,
    required this.onIniciarSessao,
  });

  String _labelStatus(StatusAgendamento status) {
    switch (status) {
      case StatusAgendamento.agendada:
        return 'AGENDADA';
      case StatusAgendamento.realizada:
        return 'REALIZADA';
      case StatusAgendamento.cancelada:
        return 'CANCELADA';
    }
  }

  Color _colorStatus(StatusAgendamento status) {
    switch (status) {
      case StatusAgendamento.agendada:
        return const Color(0xFF3A345C);
      case StatusAgendamento.realizada:
        return Colors.green.shade700;
      case StatusAgendamento.cancelada:
        return Colors.red.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    final horaStr = DateFormat('HH:mm').format(sessao.dataHora);

    return CustomPaint(
      painter: isEmAndamento
          ? _BorderProgressPainter(
              progress: progressoTimer,
              color: const Color(0xFFE4B363),
              strokeWidth: 3.0,
              borderRadius: 18.0,
            )
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isEmAndamento ? Colors.transparent : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Timeline Horário à Esquerda
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3A345C).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      horaStr,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3A345C),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Detalhes do Agendamento
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sessao.pacienteNome ?? 'Paciente',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C2448),
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Psicoterapia Individual • 50 min',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B6582),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _colorStatus(
                                  sessao.status,
                                ).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _labelStatus(sessao.status),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: _colorStatus(sessao.status),
                                ),
                              ),
                            ),
                            if (sessao.observacoes != null &&
                                sessao.observacoes!.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.note_alt_outlined,
                                size: 14,
                                color: Color(0xFF6B6582),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Menu Opções Avançadas (...)
                  PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.more_vert_rounded,
                      color: Color(0xFF6B6582),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    onSelected: (val) {
                      if (val == 'confirmar') {
                        onAlterarStatus(sessao, StatusAgendamento.agendada);
                      } else if (val == 'cancelar') {
                        onAlterarStatus(sessao, StatusAgendamento.cancelada);
                      } else if (val == 'reagendar') {
                        onReagendar(sessao);
                      } else if (val == 'nota') {
                        onAdicionarNota(sessao);
                      } else if (val == 'whatsapp') {
                        onEnviarLembrete(sessao);
                      } else if (val == 'noshow') {
                        onAlterarStatus(sessao, StatusAgendamento.cancelada);
                      }
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(
                        value: 'confirmar',
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              color: Colors.green,
                              size: 18,
                            ),
                            SizedBox(width: 10),
                            Text('Paciente confirmou presença'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'cancelar',
                        child: Row(
                          children: [
                            Icon(
                              Icons.cancel_outlined,
                              color: Colors.red,
                              size: 18,
                            ),
                            SizedBox(width: 10),
                            Text('Paciente não comparecerá / Cancelar'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'reagendar',
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit_calendar_outlined,
                              color: Color(0xFF3A345C),
                              size: 18,
                            ),
                            SizedBox(width: 10),
                            Text('Reagendar Sessão'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'nota',
                        child: Row(
                          children: [
                            Icon(
                              Icons.note_add_outlined,
                              color: Color(0xFF3A345C),
                              size: 18,
                            ),
                            SizedBox(width: 10),
                            Text('Adicionar Nota Rápida / Prontuário'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'whatsapp',
                        child: Row(
                          children: [
                            Icon(
                              Icons.chat_outlined,
                              color: Colors.green,
                              size: 18,
                            ),
                            SizedBox(width: 10),
                            Text('Enviar Lembrete por WhatsApp'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'noshow',
                        child: Row(
                          children: [
                            Icon(
                              Icons.person_off_outlined,
                              color: Colors.orange,
                              size: 18,
                            ),
                            SizedBox(width: 10),
                            Text('Marcar como Faltou (No-Show)'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Botão Iniciar Sessão (Com Timer)
              SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton.icon(
                  onPressed: () => onIniciarSessao(sessao, 50),
                  icon: const Icon(Icons.play_arrow_rounded, size: 18),
                  label: Text(
                    isEmAndamento
                        ? 'Sessão em Andamento ($tempoRestanteFormatado)'
                        : 'Iniciar Sessão (50 min)',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isEmAndamento
                        ? const Color(0xFFE4B363)
                        : const Color(0xFF3A345C),
                    foregroundColor: isEmAndamento
                        ? const Color(0xFF3A345C)
                        : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
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

/// Painter para animar o progresso do timer na borda do Card de Sessão
class _BorderProgressPainter extends CustomPainter {
  final double progress; // 0.0 a 1.0
  final Color color;
  final double strokeWidth;
  final double borderRadius;

  _BorderProgressPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height - 14);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));
    final path = Path()..addRRect(rrect);

    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      final drawLength = metric.length * progress;
      final extractPath = metric.extractPath(0, drawLength);
      canvas.drawPath(extractPath, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BorderProgressPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
