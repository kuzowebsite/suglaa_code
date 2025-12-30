import 'package:flutter/material.dart';
import 'dart:math';

class StarNumberWidget extends StatelessWidget {
  final String text;
  final double size;

  const StarNumberWidget({super.key, required this.text, required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: StarPainter(),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: size * 0.4,
              fontWeight: FontWeight.bold
            ),
          ),
        ),
      ),
    );
  }
}

class StarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint fillPaint = Paint()..color = Colors.black..style = PaintingStyle.fill;
    final Paint borderPaint = Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 1.5;

    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double outerRadius = size.width / 2 - 2;
    final double innerRadius = outerRadius / 2.0;

    final Path path = Path();
    double angle = -pi / 2;
    final double step = pi / 5;

    for (int i = 0; i < 10; i++) {
      double r = (i % 2 == 0) ? outerRadius : innerRadius;
      double x = cx + cos(angle) * r;
      double y = cy + sin(angle) * r;
      if (i == 0) path.moveTo(x, y);
      else path.lineTo(x, y);
      angle += step;
    }
    path.close();
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}