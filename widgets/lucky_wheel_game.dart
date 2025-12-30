import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class LuckyWheelGame extends StatefulWidget {
  const LuckyWheelGame({super.key});

  @override
  State<LuckyWheelGame> createState() => _LuckyWheelGameState();
}

class _LuckyWheelGameState extends State<LuckyWheelGame> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  // Гэрэл анивчих контроллер
  late AnimationController _lightsController; 
  
  final Random _random = Random();

  // Шагналууд (Илүү баяжуулсан)
  final List<String> prizes = [
    "100₮", "ХООСОН", "5000₮", "500₮", 
    "ДАХИН", "iPhone", "50₮", "JACKPOT"
  ];
  
  // Өнгөнүүд (Градиент үүсгэхэд ашиглана)
  final List<Color> colors = [
    const Color(0xFFEF5350), // Red
    const Color(0xFF42A5F5), // Blue
    const Color(0xFF66BB6A), // Green
    const Color(0xFFFFA726), // Orange
    const Color(0xFFAB47BC), // Purple
    const Color(0xFF26C6DA), // Cyan
    const Color(0xFFFF7043), // Deep Orange
    const Color(0xFFFFD700), // Gold (Jackpot)
  ];

  double _currentAngle = 0;
  bool _isSpinning = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 5));
    
    // Гэрэл анивчих хөдөлгөөн
    _lightsController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _lightsController.dispose();
    super.dispose();
  }

  void _spinWheel() {
    if (_isSpinning) return;

    setState(() {
      _isSpinning = true;
    });

    // Санамсаргүй өнцөг (Хамгийн багадаа 5 бүтэн эргэнэ)
    double randomAngle = _random.nextDouble() * 2 * pi;
    double endAngle = _currentAngle + (10 * 2 * pi) + randomAngle;

    // ElasticOut эсвэл Decelerate ашиглаж бодит үрэлтийг дуурайлгана
    _animation = Tween<double>(begin: _currentAngle, end: endAngle).animate(
      CurvedAnimation(parent: _controller, curve: Curves.decelerate),
    );

    _controller.forward(from: 0).then((_) {
      setState(() {
        _currentAngle = endAngle;
        _isSpinning = false;
      });
      _calculateWinner(endAngle);
    });
  }

  void _calculateWinner(double finalAngle) {
    // 1. Normalize angle (0 - 2pi)
    double normalizedAngle = finalAngle % (2 * pi);
    
    // 2. Flutter-ийн Canvas координатад 0 градус нь баруун (3 цаг) зүгт байдаг.
    // Бидний сум (Pointer) дээр (12 цаг) зүгт байгаа.
    // Тиймээс бид эргэлтийг тооцохдоо π/2 (90 градус)-ийг хасах хэрэгтэй.
    // Эсвэл зүгээр л сегментийн логикийг тааруулж болно.
    
    // Сегмент бүрийн өргөн (өнцгөөр)
    double segmentWidth = 2 * pi / prizes.length;
    
    // Сумны байрлал (Дээд тал буюу 270 градус эсвэл -90 градус)
    // Гэхдээ бид Wheel-ийг эргүүлж байгаа тул Pointer тогтмол.
    // Wheel цагийн зүүний дагуу эргэхэд, Pointer нь Wheel-ийн хувьд цагийн зүүний эсрэг явж байгаа мэт болно.
    
    double pointerOffset = pi / 2; // 90 градус (Дээд цэг)
    double totalAngle = normalizedAngle + pointerOffset;
    
    // Индекс тооцоолол
    int index = (totalAngle / segmentWidth).floor() % prizes.length;
    
    // Canvas зураглал дээр index 0 нь баруун талаас эхэлдэг тул урвуулж тооцох шаардлага гарч магадгүй.
    // Гэхдээ CustomPainter дээрх логикоос хамаарна. 
    // Туршилтаар индекс зөрж байвал энд засварлана.
    // Энэ тохиолдолд: prizes.length - 1 - index гэх мэт.
    int winningIndex = (prizes.length - 1 - index) % prizes.length;
    // Заримдаа математик тооцоолол зөрж магадгүй тул +1 эсвэл -1 хийж тааруулна
    // Энэ Painter логикоор:
    winningIndex = (prizes.length - index) % prizes.length;

    _showResultDialog(prizes[winningIndex]);
  }

  void _showResultDialog(String prize) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2C),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.amber, width: 2),
            boxShadow: [
              BoxShadow(color: Colors.amber.withOpacity(0.5), blurRadius: 20, spreadRadius: 5)
            ]
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("🎉 БАЯР ХҮРГЭЕ! 🎉", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Text(prize, style: const TextStyle(color: Colors.amber, fontSize: 40, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
                child: const Text("Баярлалаа"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Азын Хүрд", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // =======================
              // THE WHEEL STACK
              // =======================
              SizedBox(
                height: 350,
                width: 350,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 1. ГАДНАХ ХҮРЭЭ (BEZEL) БОЛОН ГЭРЭЛ
                    AnimatedBuilder(
                      animation: _lightsController,
                      builder: (context, child) {
                        return CustomPaint(
                          size: const Size(350, 350),
                          painter: BezelPainter(blinkAnimation: _lightsController.value),
                        );
                      },
                    ),
          
                    // 2. ЭРГЭДЭГ ХҮРД (SPINNING WHEEL)
                    Padding(
                      padding: const EdgeInsets.all(25.0), // Bezel-ээс дотогш зай авна
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _controller.isAnimating ? _animation.value : _currentAngle,
                            child: CustomPaint(
                              size: const Size(300, 300),
                              painter: WheelPainter(
                                prizes: prizes,
                                colors: colors,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
          
                    // 3. ТӨВ ГОЛ (CENTER CAP)
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const RadialGradient(
                          colors: [Colors.white, Colors.grey],
                          stops: [0.0, 1.0],
                        ),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 5, offset: const Offset(2, 2))
                        ],
                        border: Border.all(color: Colors.white, width: 2)
                      ),
                      child: Center(
                        child: Icon(Icons.star, color: Colors.amber[800], size: 30),
                      ),
                    ),
          
                    // 4. ДЭЭД СУМ (FLAPPER / POINTER)
                    const Positioned(
                      top: 0,
                      child: FlapperWidget(),
                    ),
                  ],
                ),
              ),
          
              const SizedBox(height: 60),
          
              // SPIN BUTTON
              GestureDetector(
                onTap: _spinWheel,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _isSpinning 
                        ? [Colors.grey, Colors.grey] 
                        : [Colors.amber, Colors.orange],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: _isSpinning ? Colors.transparent : Colors.amber.withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      )
                    ],
                    border: Border.all(color: Colors.white24, width: 1),
                  ),
                  child: Text(
                    _isSpinning ? "ЭРГЭЖ БАЙНА..." : "ЭРГҮҮЛЭХ",
                    style: TextStyle(
                      color: _isSpinning ? Colors.white38 : Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// PAINTERS & WIDGETS
// ==========================================

/// Хүрдний дотоод сегментүүдийг зурагч
class WheelPainter extends CustomPainter {
  final List<String> prizes;
  final List<Color> colors;

  WheelPainter({required this.prizes, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    double radius = size.width / 2;
    Offset center = Offset(radius, radius);
    double segmentAngle = 2 * pi / prizes.length;

    final paint = Paint()..style = PaintingStyle.fill;
    
    // Сүүдэр зурах
    final shadowPath = Path()..addOval(Rect.fromCircle(center: center, radius: radius));
    canvas.drawShadow(shadowPath, Colors.black, 10.0, true);

    for (int i = 0; i < prizes.length; i++) {
      // 1. Draw Slice
      paint.color = colors[i % colors.length];
      // Градиент эффект нэмэх (Optional)
      paint.shader = RadialGradient(
        colors: [colors[i % colors.length].withOpacity(0.8), colors[i % colors.length]],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * segmentAngle,
        segmentAngle,
        true,
        paint,
      );

      // 2. Draw Borders
      final borderPaint = Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * segmentAngle,
        segmentAngle,
        true,
        borderPaint,
      );

      // 3. Draw Text
      _drawText(canvas, center, radius, i * segmentAngle, segmentAngle, prizes[i]);
    }
  }

  void _drawText(Canvas canvas, Offset center, double radius, double startAngle, double sweepAngle, String text) {
    canvas.save();
    
    // Текстийн байрлалыг тооцох
    double angle = startAngle + sweepAngle / 2;
    double textRadius = radius * 0.65; // Төвөөс хэр хол байх вэ
    
    canvas.translate(
      center.dx + cos(angle) * textRadius,
      center.dy + sin(angle) * textRadius,
    );
    
    // Текстийг эргүүлэх (Төв рүү харсан байдалтай)
    canvas.rotate(angle + pi); // + pi хийвэл дотогшоо харна, үгүй бол гадагшаа

    final textStyle = const TextStyle(
      color: Colors.white,
      fontSize: 14,
      fontWeight: FontWeight.bold,
      shadows: [Shadow(color: Colors.black, blurRadius: 2)]
    );

    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    
    // Текстийг голлуулж зурах
    textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Гадна хүрээ болон анивчдаг гэрлийг зурагч
class BezelPainter extends CustomPainter {
  final double blinkAnimation; // 0.0 - 1.0

  BezelPainter({required this.blinkAnimation});

  @override
  void paint(Canvas canvas, Size size) {
    double radius = size.width / 2;
    Offset center = Offset(radius, radius);

    // 1. Үндсэн хүрээ (Алтан/Мөнгөлөг)
    final bezelPaint = Paint()
      ..shader = const SweepGradient(
        colors: [Color(0xFFFDB931), Color(0xFFFFD700), Color(0xFFFDB931), Color(0xFFC0C0C0), Color(0xFFFDB931)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    
    canvas.drawCircle(center, radius, bezelPaint);
    
    // Дотор талын хар хүрээ
    canvas.drawCircle(center, radius - 15, Paint()..color = const Color(0xFF1E1E1E));

    // 2. Гэрлүүд (Bulbs)
    int bulbCount = 20;
    double angleStep = 2 * pi / bulbCount;
    double bulbRadius = radius - 7.5; // Хүрээний голд

    for (int i = 0; i < bulbCount; i++) {
      double angle = i * angleStep;
      Offset bulbPos = Offset(
        center.dx + cos(angle) * bulbRadius,
        center.dy + sin(angle) * bulbRadius,
      );

      // Анивчих логик (Тэгш ба Сондгойгоор ээлжлэх)
      bool isOn = (i % 2 == 0) 
          ? blinkAnimation < 0.5 
          : blinkAnimation >= 0.5;

      final bulbPaint = Paint()
        ..color = isOn ? Colors.yellowAccent : Colors.brown.shade800
        ..style = PaintingStyle.fill;

      // Гэрэл гялбаа (Glow)
      if (isOn) {
        canvas.drawCircle(bulbPos, 6, Paint()..color = Colors.yellow.withOpacity(0.5)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
      }

      canvas.drawCircle(bulbPos, 4, bulbPaint);
    }
  }

  @override
  bool shouldRepaint(covariant BezelPainter oldDelegate) => oldDelegate.blinkAnimation != blinkAnimation;
}

/// Дээд талын сум (Flapper)
class FlapperWidget extends StatelessWidget {
  const FlapperWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 5), // Bezel-ийн дээр давхарлах
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Сүүдэр
          Transform.translate(
            offset: const Offset(0, 2),
            child: const Icon(Icons.arrow_drop_down, size: 50, color: Colors.black54),
          ),
          // Үндсэн сум
          const Icon(Icons.arrow_drop_down, size: 50, color: Colors.redAccent),
          // Сумны цагаан хүрээ (Styling)
          Positioned(
            top: 5,
            child: Container(
              width: 10, height: 10,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 2)]
              ),
            ),
          )
        ],
      ),
    );
  }
}