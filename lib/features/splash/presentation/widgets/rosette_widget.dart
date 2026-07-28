import 'dart:math' as math;
import 'package:flutter/material.dart';

class RosetteWidget extends StatelessWidget {
  final double size;
  final Color color;
  final double strokeWidth;
  final bool showGlow;

  const RosetteWidget({
    super.key,
    this.size = 100,
    this.color = const Color(0xFFE4B363),
    this.strokeWidth = 2.0,
    this.showGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (showGlow)
          Container(
            width: size * 1.3,
            height: size * 1.3,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.32),
                  blurRadius: 55,
                  spreadRadius: 25,
                ),
              ],
            ),
          ),
        CustomPaint(
          size: Size(size, size),
          painter: RosettePainter(
            color: color,
            strokeWidth: strokeWidth,
          ),
        ),
      ],
    );
  }
}

class RosettePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  RosettePainter({
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.32;

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..isAntiAlias = true;

    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    // Círculo base central
    canvas.drawCircle(center, radius, strokePaint);
    canvas.drawCircle(center, radius, fillPaint);

    // 6 Círculos sobrepostos para formar a roseta perfeita de 6 pétalas
    const count = 6;
    for (int i = 0; i < count; i++) {
      final angle = (i * 2 * math.pi) / count;
      final petalCenter = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      canvas.drawCircle(petalCenter, radius, strokePaint);
      canvas.drawCircle(petalCenter, radius, fillPaint);
    }

    // Círculo delimitador externo
    canvas.drawCircle(center, radius * 1.7, strokePaint);

    // Ponto central
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 3.5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant RosettePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
  }
}
