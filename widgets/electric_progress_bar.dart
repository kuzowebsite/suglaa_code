import 'dart:math';
import 'package:flutter/material.dart';

class ElectricProgressBar extends StatefulWidget {
  final double value; // 0.0 -аас 1.0 хооронд (Дүүргэлт)
  const ElectricProgressBar({super.key, required this.value});

  @override
  State<ElectricProgressBar> createState() => _ElectricProgressBarState();
}

class _ElectricProgressBarState extends State<ElectricProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Цахилгаан хурдан цахилах эффект үзүүлэхийн тулд хурдан давтамжтай (100ms)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 14,
        width: double.infinity,
        color: Colors.black, // Арын дэвсгэр тас хар (Цахилгаан тод харагдана)
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              // Painter руу дүүргэлтийн хувь болон цагийг дамжуулна
              painter: LightningPainter(
                progress: widget.value,
                time: _controller.value,
              ),
              size: Size.infinite,
            );
          },
        ),
      ),
    );
  }
}

// Цахилгааныг зурдаг класс
class LightningPainter extends CustomPainter {
  final double progress;
  final double time;
  final Random _random = Random();

  LightningPainter({required this.progress, required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    // Хэрэв дүүргэлт 0 бол юу ч зурахгүй
    if (progress <= 0) return;

    // Зөвхөн дүүргэлтийн хэмжээгээр зурна
    final double activeWidth = size.width * progress;
    final double centerY = size.height / 2;

    // 1. Цэнхэр Гэрэлтэлт (Glow) - Гадна талын бүдэг хэсэг
    final Paint glowPaint = Paint()
      ..color = Colors.blueAccent.withOpacity(0.8) // Цэнхэр туяа
      ..strokeWidth = 6 // Өргөн зураас
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8); // Blur эффект

    // 2. Цагаан Цөм (Core) - Дотор талын хурц хэсэг
    final Paint corePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2 // Нарийн зураас
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Цахилгааны замыг үүсгэх
    final Path lightningPath = _generateLightningPath(activeWidth, centerY);

    // ЗУРАХ: Эхлээд гэрлээ, дараа нь цөмөө зурна
    canvas.drawPath(lightningPath, glowPaint);
    canvas.drawPath(lightningPath, corePaint);
    
    // Төгсгөлд нь жижиг гэрэл (Spark) нэмэх
    canvas.drawCircle(Offset(activeWidth, centerY), 3, corePaint..style = PaintingStyle.fill);
    canvas.drawCircle(Offset(activeWidth, centerY), 6, glowPaint..style = PaintingStyle.fill);
  }

  // Санамсаргүй тахиралдсан зам үүсгэх функц
  Path _generateLightningPath(double width, double centerY) {
    final Path path = Path();
    path.moveTo(0, centerY);

    // Хэр олон хугарал байх вэ (Өргөнөөс хамаарч тооцно)
    int segments = (width / 10).round(); 
    if (segments < 2) segments = 2;

    final double segmentWidth = width / segments;

    for (int i = 1; i <= segments; i++) {
      final double x = i * segmentWidth;
      
      // Санамсаргүйгээр дээш доош хазайна (-1-ээс 1 хооронд)
      // time-ийг ашиглахгүйгээр шууд random.nextDouble() ашиглах нь 
      // frame бүрт өөрчлөгдөж "шарчигнах" хөдөлгөөн оруулна.
      final double jitter = (_random.nextDouble() - 0.5) * 6; // 6px хазайлт

      // Эхлэл болон төгсгөлийг арай шулуун байлгах
      double currentY = centerY + jitter;
      if (i == segments) currentY = centerY; // Төгсгөл нь голдоо байна

      path.lineTo(x, currentY);
    }

    return path;
  }

  @override
  bool shouldRepaint(covariant LightningPainter oldDelegate) {
    // Цаг өөрчлөгдөх бүрт дахин зурна (Animation)
    return oldDelegate.time != time || oldDelegate.progress != progress;
  }
}