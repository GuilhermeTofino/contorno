import 'package:flutter/material.dart';

class MetricsOverviewCard extends StatelessWidget {
  final String receitaMensal;
  final String totalPacientes;

  const MetricsOverviewCard({
    super.key,
    this.receitaMensal = 'R\$ 4.500,00',
    this.totalPacientes = '18',
  });

  Widget _buildSingleCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C2448),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildSingleCard(
          title: 'Receita Mensal',
          value: receitaMensal,
          icon: Icons.account_balance_wallet_outlined,
          color: const Color(0xFF3A345C),
        ),
        const SizedBox(width: 14),
        _buildSingleCard(
          title: 'Pacientes Ativos',
          value: totalPacientes,
          icon: Icons.people_outline_rounded,
          color: const Color(0xFFE4B363),
        ),
      ],
    );
  }
}
