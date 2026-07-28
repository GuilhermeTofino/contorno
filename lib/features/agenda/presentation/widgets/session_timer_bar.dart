import 'package:flutter/material.dart';

class SessionTimerBar extends StatelessWidget {
  final int tempoRestanteSegundos;
  final VoidCallback onStopTimer;

  const SessionTimerBar({
    super.key,
    required this.tempoRestanteSegundos,
    required this.onStopTimer,
  });

  String _formatarTempoRestante() {
    final min = (tempoRestanteSegundos ~/ 60).toString().padLeft(2, '0');
    final sec = (tempoRestanteSegundos % 60).toString().padLeft(2, '0');
    return '$min:$sec';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE4B363),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.timer, color: Color(0xFF3A345C)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Sessão em andamento! Tempo restante: ${_formatarTempoRestante()}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF3A345C),
                fontSize: 13,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.stop_circle_outlined,
              color: Color(0xFF3A345C),
            ),
            onPressed: onStopTimer,
          ),
        ],
      ),
    );
  }
}
