import 'package:flutter/material.dart';
import 'dart:async';
import '../screens/lottery_detail_screen.dart';
import '../services/mock_wallet_service.dart'; // LotteryModel-ийг ашиглахын тулд заавал import хийнэ

class BannerSlider extends StatefulWidget {
  const BannerSlider({super.key});

  @override
  State<BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider> {
  late final PageController _pageController;
  Timer? _timer;
  double _pageValue = 0.0;
  
  // Service-ийг дуудаж жинхэнэ сугалааны мэдээллийг авах боломжтой
  final MockWalletService _walletService = MockWalletService();

  // --- DATA SECTION ---
  // ID-г нь MockWalletService дээрх ID-нуудтай ижил болговол илүү сайн ("101", "103" гэх мэт)
  final List<Map<String, dynamic>> _bannerData = [
    {
      "id": "ad_unitel_01",
      "likes": 1250,
      "type": "ad",
      "image": "assets/images/1.jpg",
      "title": "Unitel Group",
      "description": "🎉 Unitel-ийн шинэ хэрэглэгч болоод 50GB дата бэлгэнд аваарай!",
      "date": "2023.10.25",
      "website": "https://unitel.mn",
      "socials": ["fb", "ig", "tg"]
    },
    {
      "id": "101", // Service дээрх Land Cruiser-ийн ID-тай тааруулав
      "likes": 500,
      "type": "lottery",
      "image": "assets/images/2.jpg",
      "title": "Land Cruiser 300",
      "price": "30,000₮",
    },
    {
      "id": "ad_shoppy_01",
      "likes": 890,
      "type": "ad",
      "image": "assets/images/3.jpg",
      "title": "Shoppy.mn",
      "description": "🔥 BLACK FRIDAY эхэллээ! Бүх бараа 70% хүртэл хямдарлаа.",
      "date": "2023.11.01",
      "website": "https://shoppy.mn",
      "socials": ["fb", "ig"]
    },
    {
      "id": "103", // Service дээрх Байрны ID-тай тааруулав
      "likes": 300,
      "type": "lottery",
      "image": "assets/images/4.jpg",
      "title": "3 өрөө байр",
      "price": "25,000₮",
    },
  ];

  @override
  void initState() {
    super.initState();
    int initialPage = 1000;
    _pageController = PageController(viewportFraction: 0.85, initialPage: initialPage);

    _pageController.addListener(() {
      setState(() {
        _pageValue = _pageController.page!;
      });
    });

    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: PageView.builder(
        controller: _pageController,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final realIndex = index % _bannerData.length;
          return _buildBannerItem(index, data: _bannerData[realIndex]);
        },
      ),
    );
  }

  Widget _buildBannerItem(int index, {required Map<String, dynamic> data}) {
    double diff = index - _pageValue;
    double scale = (1 - (diff.abs() * 0.1)).clamp(0.9, 1.0);
    final Matrix4 matrix = Matrix4.identity()..setEntry(3, 2, 0.001)..scale(scale);
    bool isLottery = data["type"] == "lottery";

    return Transform(
      transform: matrix,
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: () {
          if (isLottery) {
            // АЛДАА ЗАССАН ХЭСЭГ:
            // Banner дээрх өгөгдлийг ашиглан LotteryModel үүсгэх эсвэл Service-ээс хайх
            
            // 1. Service-ээс ID-аар нь хайж үзнэ (Илүү найдвартай)
            LotteryModel? lottery = _walletService.getLotteryById(data["id"]);

            // 2. Хэрэв Service-д байхгүй бол (ID зөрүүтэй үед) Banner-ийн датагаар түр үүсгэнэ
            lottery ??= LotteryModel(
                id: data["id"],
                title: data["title"],
                price: data["price"],
                priceInt: int.tryParse(data["price"].replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
                image: data["image"],
                category: "Banner Special",
                endDate: DateTime.now().add(const Duration(days: 30)), // Dummy data
                totalCount: 1000,
                soldCount: 0,
            );

            // 3. Шинэчлэгдсэн Detail Screen рүү model-оо дамжуулна
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LotteryDetailScreen(
                  lottery: lottery!, // Named parameter 'lottery' ашиглана
                ),
              ),
            );
          } else {
            // Show Ad Detail Sheet
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => AdDetailSheet(data: data),
            );
          }
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 5)),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 1. Only the Image is shown
                Image.asset(data["image"], fit: BoxFit.cover),

                // 2. Ad Tag
                if (!isLottery)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        "Ad",
                        style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// AD DETAIL SHEET (Өмнөхтэй ижил)
// ==========================================
class AdDetailSheet extends StatefulWidget {
  final Map<String, dynamic> data;
  const AdDetailSheet({super.key, required this.data});

  @override
  State<AdDetailSheet> createState() => _AdDetailSheetState();
}

class _AdDetailSheetState extends State<AdDetailSheet> {
  final _walletService = MockWalletService();
  late bool isLiked;
  late String? adId;
  late int likeCount;

  @override
  void initState() {
    super.initState();
    adId = widget.data['id'];
    likeCount = widget.data['likes'] ?? 0;
    isLiked = _walletService.isAdLiked(adId);
  }

  void _toggleLike() {
    setState(() {
      _walletService.toggleAdLike(adId);
      isLiked = _walletService.isAdLiked(adId);
    });
  }

  @override
  Widget build(BuildContext context) {
    int displayCount = isLiked ? likeCount + 1 : likeCount;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1E1E1E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 20),
                  width: 50, height: 5,
                  decoration: BoxDecoration(color: Colors.grey[700], borderRadius: BorderRadius.circular(10)),
                ),
              ),

              // HEADER
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.data["title"],
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.data["date"] ?? "Огноо тодорхойгүй",
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // IMAGE
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  widget.data["image"],
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(height: 15),

              // ACTION BAR
              Row(
                children: [
                  GestureDetector(
                    onTap: _toggleLike,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                            color: isLiked ? Colors.blue : Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "$displayCount",
                            style: TextStyle(
                              color: isLiked ? Colors.blue : Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // DESCRIPTION
              Text(
                widget.data["description"] ?? "",
                style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.6),
              ),
              
              const SizedBox(height: 30),

              // WEBSITE BUTTON
              if (widget.data["website"] != null)
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: () {}, 
                    icon: const Icon(Icons.language, color: Colors.white),
                    label: const Text("Вэб сайт руу зочлох"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      side: const BorderSide(color: Colors.white, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                ),

              const SizedBox(height: 25),

              const Text("Холбоо барих", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildContactIcon(Icons.phone, Colors.green, () {}),
                  _buildContactIcon(Icons.email, Colors.orange, () {}),
                  if ((widget.data["socials"] ?? []).contains("fb")) 
                    _buildContactIcon(Icons.facebook, const Color(0xFF1877F2), () {}),
                  if ((widget.data["socials"] ?? []).contains("ig")) 
                    _buildContactIcon(Icons.camera_alt, const Color(0xFFE4405F), () {}),
                  if ((widget.data["socials"] ?? []).contains("tg")) 
                    _buildContactIcon(Icons.send, const Color(0xFF0088CC), () {}),
                ],
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContactIcon(IconData icon, Color iconColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 55, height: 55,
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2C),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white, width: 1),
        ),
        child: Icon(icon, color: iconColor, size: 26),
      ),
    );
  }
}