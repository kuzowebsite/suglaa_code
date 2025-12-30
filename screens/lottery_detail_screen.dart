import 'package:flutter/material.dart';
import '../utils/app_colors.dart'; // Өөрийн app_colors замыг шалгаарай
import '../services/mock_wallet_service.dart'; // Models import
import '../widgets/monochrome_prize_list.dart'; 
import '../widgets/cinematic_timer.dart';
import '../widgets/electric_progress_bar.dart';
import '../widgets/lottery_purchase_sheet.dart'; // Purchase Sheet import

class LotteryDetailScreen extends StatelessWidget {
  // Зөвхөн model авна (imagePath, title, price тус тусдаа биш)
  final LotteryModel lottery;

  const LotteryDetailScreen({super.key, required this.lottery});

  @override
  Widget build(BuildContext context) {
    // Дүүргэлтийн хувийг тооцоолох
    final progressPercent = lottery.progress; // 0.0 -> 1.0

    return Scaffold(
      backgroundColor: const Color(0xFF121212), // AppColors.darkBackground
      
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          lottery.title.toUpperCase(), 
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1)
        ),
        centerTitle: true,
      ),
      
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Image
            Container(
              height: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 15,
                    offset: const Offset(0, 10),
                  ),
                ],
                image: DecorationImage(
                  image: AssetImage(lottery.image), 
                  fit: BoxFit.cover
                ),
              ),
            ),
            const SizedBox(height: 25),

            const Text(
              "АЖИЛ ХИЙХГҮЙ 10 ЖИЛ ЦАЛИН АВАХ УУ?", 
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)
            ),
            const SizedBox(height: 10),
            Text(
              "Супер азтан болоорой! Ангилал: ${lottery.category}", 
              style: const TextStyle(color: Colors.grey, height: 1.5, fontSize: 13)
            ),
            
            const SizedBox(height: 30),

            // Шагналын жагсаалт
            const MonochromePrizeList(), 
            
            const SizedBox(height: 40),

            // Timer
            const Center(
              child: Text(
                "ДУУСАХ ХУГАЦАА", 
                style: TextStyle(color: Colors.white54, letterSpacing: 3, fontSize: 10, fontWeight: FontWeight.bold)
              )
            ),
            const SizedBox(height: 20),
            CinematicTimer(targetDate: lottery.endDate),

            const SizedBox(height: 40),

            // DYNAMIC PROGRESS BAR
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("ДҮҮРГЭЛТ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                Text("${(progressPercent * 100).toInt()}%", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 10),
            ElectricProgressBar(value: progressPercent), 

            const SizedBox(height: 30),

            // DYNAMIC INFO TILES
            // Боломжит: Зарагдсан / Нийт
            _buildInfoTile("БОЛОМЖИТ:", "${lottery.soldCount}/${lottery.totalCount}ш"),
            const SizedBox(height: 10),
            _buildInfoTile("НЭГЖ ҮНЭ:", lottery.price, isBold: true),
            
            const SizedBox(height: 80),
          ],
        ),
      ),

      // Bottom Navigation Bar - Buy Button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF121212),
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
        ),
        child: SizedBox(
          height: 55,
          child: ElevatedButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => LotteryPurchaseSheet(
                  priceString: lottery.price,
                  lotteryTitle: lottery.title,
                  lotteryId: lottery.id, // <--- ЭНИЙГ НЭМСЭН (Алдаа засагдсан)
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black, 
              foregroundColor: Colors.white, 
              side: const BorderSide(color: Colors.white, width: 1.5), 
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), 
              elevation: 10,
              shadowColor: Colors.white.withOpacity(0.1),
            ),
            child: const Text(
              "СУГАЛАА АВАХ", 
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, {bool isBold = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF252525), 
        borderRadius: BorderRadius.circular(10)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text(
            value, 
            style: TextStyle(color: Colors.white, fontWeight: isBold ? FontWeight.w900 : FontWeight.bold, fontSize: 16)
          ),
        ],
      ),
    );
  }
}