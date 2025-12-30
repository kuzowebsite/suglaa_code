import 'package:flutter/material.dart';

// ШИНЭЭР ҮҮСГЭСЭН 3 ТОГЛООМЫН ФАЙЛЫГ ИМПОРТЛОХ
import '../widgets/lucky_wheel_game.dart';
import '../widgets/scratch_card_game.dart';
import '../widgets/dice_game.dart';

// HEADER-ийг импортлох
import '../widgets/custom_app_bar.dart'; 

class OthersScreen extends StatelessWidget {
  const OthersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      
      body: Stack(
        children: [
          // -------------------------------
          // 1. CONTENT LAYER (Тоглоомуудын цэс)
          // -------------------------------
          GridView.count(
            // Header-ийн доогуур орохгүйн тулд дээд талаас зай авна
            padding: const EdgeInsets.only(top: 110, left: 20, right: 20, bottom: 20),
            crossAxisCount: 2, 
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            children: [
              _buildGameCard(
                context,
                "Азын хүрд",
                Icons.donut_large_rounded,
                Colors.purpleAccent,
                // Шинэ файл руу үсэрнэ
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LuckyWheelGame())),
              ),
              _buildGameCard(
                context,
                "Хусах сугалаа",
                Icons.style_rounded,
                Colors.orangeAccent,
                // Шинэ файл руу үсэрнэ
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScratchCardGame())),
              ),
              _buildGameCard(
                context,
                "Азын шоо",
                Icons.casino_rounded,
                Colors.redAccent,
                // Шинэ файл руу үсэрнэ
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DiceGame())),
              ),
               _buildGameCard(
                context,
                "Слот машин",
                Icons.view_carousel_rounded,
                Colors.blueAccent,
                () {
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Тун удахгүй...")));
                },
              ),
            ],
          ),

          // -------------------------------
          // 2. HEADER LAYER (CustomAppBar)
          // -------------------------------
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CustomAppBar(), 
          ),
        ],
      ),
    );
  }

  Widget _buildGameCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.2), blurRadius: 10, spreadRadius: 1),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: color),
            ),
            const SizedBox(height: 15),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}