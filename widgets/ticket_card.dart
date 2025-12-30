import 'package:flutter/material.dart';
// import '../utils/app_colors.dart'; // Хэрвээ танд энэ файл байхгүй бол доорх өнгийг шууд ашиглаарай

class TicketCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String price;
  final VoidCallback? onTap;

  const TicketCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.price,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Layout хэмжээсүүд
    const double cardWidth = 280;
    const double cardHeight = 120;
    const double splitRatio = 5 / 8; // Зураг 5 нэгж, Мэдээлэл 3 нэгж
    const double splitPosition = cardWidth * splitRatio;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cardWidth,
        height: cardHeight,
        margin: const EdgeInsets.only(right: 15, bottom: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E), // AppColors.ticketBackground оронд шууд код бичив
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // 1. Үндсэн Агуулга (Зураг + Мэдээлэл)
              Row(
                children: [
                  // Зүүн тал: Зураг (5 нэгж)
                  Expanded(
                    flex: 5,
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      height: double.infinity,
                    ),
                  ),

                  // Баруун тал: Мэдээлэл (3 нэгж)
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Гарчиг
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              height: 1.1,
                            ),
                          ),

                          // Үнэ
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Үнэ",
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 9,
                                ),
                              ),
                              Text(
                                price,
                                style: const TextStyle(
                                  color: Color(0xFFFFD700), // Алтлаг шар өнгө
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          // "АВАХ" ТОВЧ (Шинэчилсэн загвар)
                          SizedBox(
                            width: double.infinity,
                            height: 28,
                            child: ElevatedButton(
                              onPressed: onTap,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black, // Хар дэвсгэр
                                foregroundColor: Colors.white, // Цагаан текст
                                elevation: 0,
                                padding: EdgeInsets.zero,
                                // Цагаан хүрээ (1px өргөнтэй)
                                side: const BorderSide(color: Colors.white, width: 1.0),
                                shape: RoundedRectangleBorder(
                                  // Бага зэрэг дугуйрсан булан
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                "Авах",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // 2. Голын тасархай зураас
              Positioned(
                top: 10,
                bottom: 10,
                left: splitPosition - 1,
                child: CustomPaint(
                  size: const Size(2, double.infinity),
                  painter: DashedLinePainter(),
                ),
              ),

              // 3. Дээд талын сэтэрхий (Cutout)
              Positioned(
                top: -10,
                left: splitPosition - 10,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Colors.black, // Background өнгөтэй ижил байх ёстой (Main Background)
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              // 4. Доод талын сэтэрхий (Cutout)
              Positioned(
                bottom: -10,
                left: splitPosition - 10,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Colors.black, // Background өнгөтэй ижил байх ёстой
                    shape: BoxShape.circle,
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

// Тасархай зураас зурагч класс
class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double dashHeight = 4;
    double dashSpace = 3;
    double startY = 0;

    final paint = Paint()
      ..color = Colors.white24 // Бүдэг цагаан
      ..strokeWidth = 1;

    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}