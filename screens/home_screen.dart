import 'package:flutter/material.dart';
import '../widgets/banner_slider.dart';
import '../widgets/ticket_card.dart';
import 'lottery_detail_screen.dart';
import '../services/mock_wallet_service.dart'; // Service-ээ импорт хийх

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  
  // Service-ийг дуудна (Singleton тул нэг л instance ашиглагдана)
  final MockWalletService _walletService = MockWalletService();

  List<String> get _categories {
    // Service-ээс сугалааны жагсаалтыг авч гарчгуудыг нь гаргана
    List<String> titles = _walletService.lotterySections.map((s) => s['title'] as String).toList();
    return ["Бүгд", ...titles];
  }

  @override
  Widget build(BuildContext context) {
    // Service-ээс бүх датаг авна
    final allSections = _walletService.lotterySections;

    final topPadding = MediaQuery.of(context).padding.top + 110;
    final bottomPadding = MediaQuery.of(context).padding.bottom + 100;

    return Scaffold(
      backgroundColor: Colors.transparent, 
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(top: topPadding, bottom: bottomPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            // --- BANNER ---
            const SizedBox(height: 180, child: BannerSlider()),
            const SizedBox(height: 20),

            // --- CATEGORY FILTER ---
            SizedBox(
              height: 40, 
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final isSelected = _selectedIndex == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIndex = index),
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.black, 
                        borderRadius: BorderRadius.circular(10), 
                        border: Border.all(
                          color: isSelected ? Colors.black : Colors.white,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        _categories[index],
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 20),

            // --- SECTIONS RENDER LOGIC ---
            // Хэрэв 0 (Бүгд) бол бүгдийг харуулна
            if (_selectedIndex == 0)
              ...allSections.map((section) => _buildSection(
                context, 
                section['title'], 
                section['data'] // Энэ нь одоо List<LotteryModel> байгаа
              ))
            // Хэрэв тодорхой категори сонгосон бол зөвхөн түүнийг харуулна
            else 
              _buildSection(
                context, 
                allSections[_selectedIndex - 1]['title'], 
                allSections[_selectedIndex - 1]['data']
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // data нь одоо Map биш List<LotteryModel> болсон
  Widget _buildSection(BuildContext context, String title, List<LotteryModel> data) {
    if (data.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              InkWell(
                onTap: () => _openCategorySheet(context, title, data),
                borderRadius: BorderRadius.circular(20),
                child: const Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 140,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              return TicketCard(
                imagePath: item.image, // Model-оос авах
                title: item.title,
                price: item.price,
                onTap: () => _navigateToDetail(context, item),
              );
            },
          ),
        ),
      ],
    );
  }

  // Item нь LotteryModel төрөлтэй болсон
  void _navigateToDetail(BuildContext context, LotteryModel item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LotteryDetailScreen(
          lottery: item, // ШИНЭЧЛЭГДСЭН: Model-оо шууд дамжуулна
        ),
      ),
    );
  }

  // --- BOTTOM SHEET (ДЭЛГЭРЭНГҮЙ ЦОНХ) ---
  void _openCategorySheet(BuildContext context, String title, List<LotteryModel> data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Color(0xFF1E1E1E),
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: Column(
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    width: 50, height: 5,
                    decoration: BoxDecoration(color: Colors.grey[700], borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: GridView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(15),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, 
                      childAspectRatio: 2.2, 
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      return _buildMiniTicket(context, data[index]);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- ЖИЖИГ ТАСАЛБАР (MINI TICKET) ---
  Widget _buildMiniTicket(BuildContext context, LotteryModel item) {
    return GestureDetector(
      onTap: () => _navigateToDetail(context, item),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2C),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: [
            // Үндсэн контент
            Row(
              children: [
                // Зураг (Зүүн талд)
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(10)),
                  child: Image.asset(
                    item.image,
                    width: 60,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                // Тасархай шугам
                const SizedBox(width: 8),
                CustomPaint(
                  size: const Size(1, double.infinity),
                  painter: DashedLineVerticalPainter(),
                ),
                const SizedBox(width: 8),
                // Мэдээлэл
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white, 
                            fontSize: 11, 
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.price,
                          style: const TextStyle(
                            color: Color(0xFFFFD700), 
                            fontSize: 12, 
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // --- СЭТЭРХИЙ (NOTCHES) ---
            Positioned(
              top: -6,
              left: 64, 
              child: _buildNotch(),
            ),
            Positioned(
              bottom: -6,
              left: 64,
              child: _buildNotch(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotch() {
    return Container(
      width: 12,
      height: 12,
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E), 
        shape: BoxShape.circle,
      ),
    );
  }
}

// Босоо тасархай зураас зурагч
class DashedLineVerticalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double dashHeight = 3, dashSpace = 3, startY = 0;
    final paint = Paint()..color = Colors.white24..strokeWidth = 1;
    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}