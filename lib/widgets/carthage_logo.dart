import 'package:flutter/material.dart';

class CarthageLogo extends StatelessWidget {
  final double fontSize;
  final bool showIcon;

  const CarthageLogo({
    super.key,
    this.fontSize = 28,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Custom Carthage Transfer Logo
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // CARTHAGE with stylized A
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  fontFamily: 'Roboto',
                ),
                children: [
                  TextSpan(
                    text: 'C',
                    style: const TextStyle(color: Color(0xFFE4B454)),
                  ),
                  TextSpan(
                    text: 'ARTHAGE',
                    style: const TextStyle(color: Color(0xFFE4B454)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // TRANSFER
            Text(
              'TRANSFER',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                fontFamily: 'Roboto',
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        if (showIcon) ...[
          const SizedBox(height: 8),
          // Stylized A with arrow (more sophisticated version)
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Triangle shape for A
                CustomPaint(
                  size: const Size(20, 20),
                  painter: TrianglePainter(),
                ),
                // Arrow
                Positioned(
                  bottom: 2,
                  child: Container(
                    width: 12,
                    height: 2,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 