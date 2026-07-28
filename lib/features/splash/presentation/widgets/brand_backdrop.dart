import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

class BrandBackdrop extends StatelessWidget {
  final Widget child;

  const BrandBackdrop({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFF7F5FB),
            Color(0xFFECE6F6),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          // Blobs Orgânicos com GaussianBlur
          Positioned(
            top: -50,
            right: -40,
            child: _ImageFilterBlob(
              width: 240,
              height: 240,
              color: const Color(0xFFDCD2F0).withValues(alpha: 0.5),
              blur: 60,
            ),
          ),
          Positioned(
            bottom: 120,
            left: -60,
            child: _ImageFilterBlob(
              width: 220,
              height: 220,
              color: const Color(0xFFE4B363).withValues(alpha: 0.22),
              blur: 70,
            ),
          ),
          Positioned(
            top: screenSize.height * 0.35,
            left: screenSize.width * 0.2,
            child: _ImageFilterBlob(
              width: 260,
              height: 260,
              color: const Color(0xFFE8E2F4).withValues(alpha: 0.45),
              blur: 80,
            ),
          ),

          // Grid de Rosetas em Marca d'Água
          Positioned.fill(
            child: CustomPaint(
              painter: _RosetteGridPatternPainter(),
            ),
          ),

          // Curvas Fluidas (Linhas no topo e rodapé)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CustomPaint(
              size: Size(screenSize.width, 140),
              painter: _TopCurvedLinePainter(),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomPaint(
              size: Size(screenSize.width, 120),
              painter: _BottomCurvedLinePainter(),
            ),
          ),

          // Conteúdo Interno Passado
          child,
        ],
      ),
    );
  }
}

class _ImageFilterBlob extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final double blur;

  const _ImageFilterBlob({
    required this.width,
    required this.height,
    required this.color,
    required this.blur,
  });

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _RosetteGridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = const Color(0xFF3A345C).withValues(alpha: 0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..isAntiAlias = true;

    const spacing = 110.0;
    const rosetteRadius = 26.0;

    for (double x = 0; x < size.width + spacing; x += spacing) {
      for (double y = 0; y < size.height + spacing; y += spacing) {
        final center = Offset(x, y);

        canvas.drawCircle(center, rosetteRadius, strokePaint);
        for (int i = 0; i < 6; i++) {
          final angle = (i * 2 * math.pi) / 6;
          final petalCenter = Offset(
            center.dx + rosetteRadius * 0.7 * math.cos(angle),
            center.dy + rosetteRadius * 0.7 * math.sin(angle),
          );
          canvas.drawCircle(petalCenter, rosetteRadius * 0.7, strokePaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TopCurvedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF3A345C).withValues(alpha: 0.07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..isAntiAlias = true;

    final path = Path();
    path.moveTo(0, size.height * 0.3);
    path.cubicTo(
      size.width * 0.35,
      size.height * 0.9,
      size.width * 0.7,
      size.height * 0.1,
      size.width,
      size.height * 0.6,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BottomCurvedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF3A345C).withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..isAntiAlias = true;

    final path = Path();
    path.moveTo(0, size.height * 0.7);
    path.quadraticBezierTo(
      size.width * 0.45,
      size.height * 0.2,
      size.width,
      size.height * 0.5,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
