import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AgendaHeader extends StatelessWidget {
  final DateTime focusedDay;
  final bool isWeekFormat;
  final VoidCallback onToggleFormat;
  final VoidCallback onSearchPressed;

  const AgendaHeader({
    super.key,
    required this.focusedDay,
    required this.isWeekFormat,
    required this.onToggleFormat,
    required this.onSearchPressed,
  });

  @override
  Widget build(BuildContext context) {
    final mesAnoStr = DateFormat("MMMM 'de' yyyy", 'pt_BR').format(focusedDay);
    final mesAnoCapitalizado = mesAnoStr[0].toUpperCase() + mesAnoStr.substring(1);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            mesAnoCapitalizado,
            style: const TextStyle(
              fontFamily: 'Serif',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C2448),
            ),
          ),
          Row(
            children: [
              TextButton.icon(
                onPressed: onToggleFormat,
                icon: Icon(
                  isWeekFormat
                      ? Icons.calendar_month_outlined
                      : Icons.view_week_outlined,
                  size: 18,
                  color: const Color(0xFF3A345C),
                ),
                label: Text(
                  isWeekFormat ? 'Ver Mês' : 'Ver Semana',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3A345C),
                  ),
                ),
              ),
              IconButton(
                onPressed: onSearchPressed,
                icon: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF3A345C),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
