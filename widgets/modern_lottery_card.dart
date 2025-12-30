import 'package:flutter/material.dart';

class ModernLotteryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String price;
  final LinearGradient gradient;
  final IconData icon; // Бодит зураг ("assets/...") ашиглахыг зөвлөж байна

  const ModernLotteryCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.gradient,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220, // Картны өргөнийг томсгосон
      margin: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: gradient,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            // Баруун дээд талын чимэглэл (Бүдэг дүрс)
            Positioned(
              right: -30, top: -30,
              child: Icon(icon, size: 150, color: Colors.white.withOpacity(0.15)),
            ),
            
            Padding(
              padding: const EdgeInsets.all(22.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Зураг/Icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 30, color: Colors.white),
                  ),
                  const Spacer(),
                  
                  // Гарчиг & Дэд гарчиг
                  Text(title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                  Text(subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8)),
                  ),
                  const SizedBox(height: 20),
                  
                  // Үнэ болон "Play" товч
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(price, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Text("Play", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                            SizedBox(width: 5),
                            Icon(Icons.play_arrow_rounded, color: Colors.black87, size: 18)
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}