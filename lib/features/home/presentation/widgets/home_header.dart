import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:contorno/features/auth/presentation/cubit/auth_state.dart';

class HomeHeader extends StatelessWidget {
  final AuthState authState;

  const HomeHeader({super.key, required this.authState});

  @override
  Widget build(BuildContext context) {
    String nomePsicologo = 'Profissional';
    if (authState is AuthAuthenticated) {
      nomePsicologo = (authState as AuthAuthenticated).user.nome
          .split(' ')
          .first;
    }

    final dataHojeFormatada = DateFormat(
      "EEEE, d 'de' MMMM",
      'pt_BR',
    ).format(DateTime.now());
    final dataHojeCapitalizada =
        dataHojeFormatada[0].toUpperCase() + dataHojeFormatada.substring(1);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFF3A345C),
              child: Text(
                nomePsicologo.isNotEmpty ? nomePsicologo[0].toUpperCase() : 'P',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Olá, Dr(a). $nomePsicologo',
                  style: const TextStyle(
                    fontFamily: 'Serif',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C2448),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dataHojeCapitalizada,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            IconButton.filledTonal(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nenhuma nova notificação.')),
                );
              },
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF3A345C),
              ),
              icon: const Icon(Icons.notifications_outlined, size: 20),
              tooltip: 'Notificações',
            ),
          ],
        ),
      ],
    );
  }
}
