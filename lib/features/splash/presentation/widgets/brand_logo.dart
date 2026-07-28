import 'package:flutter/material.dart';
import 'rosette_widget.dart';

class BrandLogo extends StatelessWidget {
  final double rosetteSize;
  final String title;
  final String tagline;
  final bool showTagline;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;

  const BrandLogo({
    super.key,
    this.rosetteSize = 100,
    this.title = 'Enquadre',
    this.tagline = 'GESTÃO PARA PSICÓLOGOS',
    this.showTagline = true,
    this.primaryColor = const Color(0xFF2C2448),
    this.secondaryColor = const Color(0xFF7A7393),
    this.accentColor = const Color(0xFFE4B363),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RosetteWidget(
          size: rosetteSize,
          color: accentColor,
        ),
        const SizedBox(height: 32),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Serif',
            fontSize: 44,
            fontWeight: FontWeight.w600,
            color: primaryColor,
            letterSpacing: 0.9,
          ),
        ),
        if (showTagline) ...[
          const SizedBox(height: 10),
          Text(
            tagline,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: secondaryColor,
              letterSpacing: 3.5,
            ),
          ),
        ],
      ],
    );
  }
}
