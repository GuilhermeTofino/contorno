import 'package:flutter/material.dart';

class RevenueTrendChart extends StatelessWidget {
  const RevenueTrendChart({super.key});

  Widget _buildBarChartItem(String month, double pct, {bool isCurrent = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          width: 24,
          height: 80 * pct,
          decoration: BoxDecoration(
            color: isCurrent ? const Color(0xFFE4B363) : const Color(0xFF3A345C),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          month,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            color: isCurrent ? const Color(0xFF3A345C) : Colors.grey,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tendência de Receita',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C2448),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(20),
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
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Faturamento Semestral',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3A345C),
                    ),
                  ),
                  Text(
                    'Média: R\$ 4.100',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 120,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildBarChartItem('JAN', 0.5),
                    _buildBarChartItem('FEV', 0.65),
                    _buildBarChartItem('MAR', 0.8),
                    _buildBarChartItem('ABR', 0.75),
                    _buildBarChartItem('MAI', 0.9),
                    _buildBarChartItem('JUN', 1.0, isCurrent: true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
