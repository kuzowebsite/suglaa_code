import 'package:flutter/material.dart';
import 'dart:math' as math; // For rotation animation
import '../services/mock_wallet_service.dart';
import '../utils/app_colors.dart';

// ==========================================
// 1. ANIMATED SMILE EMOJI (Happy)
// ==========================================
class AnimatedSmileEmoji extends StatefulWidget {
  const AnimatedSmileEmoji({super.key});

  @override
  State<AnimatedSmileEmoji> createState() => _AnimatedSmileEmojiState();
}

class _AnimatedSmileEmojiState extends State<AnimatedSmileEmoji> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800), // Хурдан хөдөлгөөн
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Дээш доош үсрэх + Том жижиг болох
        return Transform.scale(
          scale: 1.0 + (_controller.value * 0.2), // 1.0 -> 1.2
          child: Transform.translate(
            offset: Offset(0, -2 * _controller.value), // Үсрэх
            child: const Text(
              "😄", // Инээж буй emoji
              style: TextStyle(fontSize: 22),
            ),
          ),
        );
      },
    );
  }
}

// ==========================================
// 2. ANIMATED SAD EMOJI (Sad/Missed)
// ==========================================
class AnimatedSadEmoji extends StatefulWidget {
  const AnimatedSadEmoji({super.key});

  @override
  State<AnimatedSadEmoji> createState() => _AnimatedSadEmojiState();
}

class _AnimatedSadEmojiState extends State<AnimatedSadEmoji> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500), // Удаан хөдөлгөөн
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Толгойгоо зөөлөн сэгсрэх (Rotation)
        double angle = 0.1 * math.sin(_controller.value * 2 * math.pi);
        return Transform.rotate(
          angle: angle, 
          child: Opacity(
            opacity: 0.7, // Бүдэг
            child: const Text(
              "😢", // Гунигтай emoji
              style: TextStyle(fontSize: 20),
            ),
          ),
        );
      },
    );
  }
}

// ==========================================
// 3. ЦЭНХЭР ЦАХИЛГААН АНИМАЦИ (ELECTRIC EFFECT)
// ==========================================
class ElectricIcon extends StatefulWidget {
  final bool isPowerful; // Хүчтэй цахилах төлөв
  const ElectricIcon({super.key, this.isPowerful = false});

  @override
  State<ElectricIcon> createState() => _ElectricIconState();
}

class _ElectricIconState extends State<ElectricIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.isPowerful ? 50 : 500),
    )..repeat(reverse: true);
  }

  @override
  void didUpdateWidget(ElectricIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.duration = Duration(milliseconds: widget.isPowerful ? 50 : 500);
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: 0.6 + (_controller.value * 0.4),
          child: Icon(
            Icons.flash_on_rounded,
            color: widget.isPowerful ? Colors.yellowAccent : Colors.blueAccent,
            size: widget.isPowerful ? 30 : 24,
            shadows: [
              Shadow(
                color: (widget.isPowerful ? Colors.yellow : Colors.blueAccent)
                    .withOpacity(0.8 * _controller.value),
                blurRadius: widget.isPowerful ? 20 : 12 * _controller.value,
              ),
            ],
          ),
        );
      },
    );
  }
}

// ==========================================
// 4. УРАМШУУЛЛЫН ОНОО ХУУДАС (MAIN SCREEN)
// ==========================================
class RewardPointsScreen extends StatefulWidget {
  const RewardPointsScreen({super.key});

  @override
  State<RewardPointsScreen> createState() => _RewardPointsScreenState();
}

class _RewardPointsScreenState extends State<RewardPointsScreen> {
  final MockWalletService _walletService = MockWalletService();
  
  final List<String> _daysOfWeek = ['Да', 'Мя', 'Лх', 'Пү', 'Ба', 'Бя', 'Ня'];

  bool _isElectroPower = false; 
  bool _hasClaimedToday = false; 

  void _claimDailyPoints() async {
    if (_hasClaimedToday || _isElectroPower) return;

    setState(() {
      _isElectroPower = true; 
    });

    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      setState(() {
        _isElectroPower = false; 
        _hasClaimedToday = true; 
      });

      int pointsToAdd = DateTime.now().weekday == 7 ? 5 : 1;
      _walletService.pointsNotifier.value += pointsToAdd;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("+$pointsToAdd оноо амжилттай нэмэгдлээ!"),
          backgroundColor: Colors.blueAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  bool _checkActiveLottery(List<PurchasedTicketModel> tickets) {
    final now = DateTime.now();
    return tickets.any((ticket) => ticket.lotteryEndDate.isAfter(now));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Урамшууллын оноо", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTotalPointsCard(),
            const SizedBox(height: 30),

            const Text("Өдөр тутмын идэвх", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            
            // Миний сугалааг сонсох
            ValueListenableBuilder<List<PurchasedTicketModel>>(
              valueListenable: _walletService.myTicketsNotifier,
              builder: (context, tickets, child) {
                bool hasActiveLottery = _checkActiveLottery(tickets);
                return _buildDailyStreakRow(hasActiveLottery);
              },
            ),
            
            const SizedBox(height: 30),

            const Text("Оноо цуглуулах нөхцөл", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            _buildConditionItem(
              icon: Icons.shopping_bag_outlined,
              title: "1. Худалдан авалтын урамшуулал",
              description: "Хэрэглэгч мөнгөөр сугалаа худалдаж авах бүрд төлсөн дүнгийн 5%-тай тэнцэх оноо нэмэгдэнэ.",
            ),
            _buildConditionItem(
              icon: Icons.sentiment_very_dissatisfied,
              title: "2. Азгүйтлийн урамшуулал",
              description: "Сугалаа хожоогүй (азгүй) болсон тохиолдолд сугалааны үнийн дүнгийн 10%-ийг оноо болгон буцааж өгнө.",
            ),
            _buildConditionItem(
              icon: Icons.flash_on,
              title: "3. Өдөр тутмын идэвх",
              description: 
                  "Зөвхөн идэвхтэй сугалаа эзэмшигчдэд зориулсан тусгай урамшуулал. "
                  "Та өдөр бүр апп-даа зочилж, тухайн өдрийн 'цахилгаан' дээр дарж оноогоо цуглуулаарай.\n\n"
                  "⚠️ Анхааруулга: Энэхүү цэс нь зөвхөн таныг идэвхтэй (хугацаа нь дуусаагүй) сугалаатай байх үед нээлттэй байна.",
            ),

            _buildOneTimeBonus(),
            const SizedBox(height: 30),
            _buildExchangeRateInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalPointsCard() {
    return ValueListenableBuilder<int>(
      valueListenable: _walletService.pointsNotifier,
      builder: (context, points, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 25),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white, width: 1.5),
            boxShadow: [
              BoxShadow(color: Colors.white.withOpacity(0.05), blurRadius: 15, spreadRadius: 2)
            ],
          ),
          child: Column(
            children: [
              const Text("Таны цуглуулсан оноо", style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star_rounded, color: Colors.orangeAccent, size: 30),
                  const SizedBox(width: 10),
                  Text("$points", style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ӨДӨР ТУТМЫН ИДЭВХИЙН МӨР (EMOJI НЭМСЭН)
  Widget _buildDailyStreakRow(bool hasActiveLottery) {
    int todayWeekday = DateTime.now().weekday; // 1 (Да) - 7 (Ня)

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!hasActiveLottery)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: const [
                Icon(Icons.lock_outline, color: Colors.redAccent, size: 14),
                SizedBox(width: 5),
                Expanded(
                  child: Text(
                    "Сугалаа худалдаж авсны дараа идэвхэжнэ.",
                    style: TextStyle(color: Colors.redAccent, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (index) {
            int currentDayNumber = index + 1;
            bool isToday = currentDayNumber == todayWeekday;
            bool isPassed = currentDayNumber < todayWeekday;

            return GestureDetector(
              onTap: () {
                if (isToday) {
                  if (hasActiveLottery) {
                    _claimDailyPoints();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Та идэвхтэй сугалаагүй байна!"),
                        backgroundColor: Colors.redAccent,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                }
              },
              child: Column(
                children: [
                  Text(
                    _daysOfWeek[index], 
                    style: TextStyle(color: isToday ? Colors.white : Colors.grey, fontSize: 12)
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 42,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isToday ? Colors.black : const Color(0xFF202025),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isToday 
                            ? (hasActiveLottery 
                                ? (_isElectroPower ? Colors.blueAccent : Colors.white) 
                                : Colors.grey) 
                            : Colors.white10, 
                        width: isToday ? 1.5 : 1.0
                      ),
                    ),
                    child: Center(
                      // --- EMOJI LOGIC HERE ---
                      child: isToday 
                        ? (hasActiveLottery 
                            ? (_hasClaimedToday 
                                ? const AnimatedSmileEmoji() // АВСАН БОЛ SMILE
                                : ElectricIcon(isPowerful: _isElectroPower)) 
                            : const AnimatedSadEmoji()) // ИДЭВХГҮЙ БОЛ SAD
                        : (isPassed 
                            ? const AnimatedSadEmoji() // ӨНГӨРСӨН БОЛ SAD (Аваагүй гэж тооцов)
                            : Text(currentDayNumber == 7 ? "5" : "1", style: const TextStyle(color: Colors.white24, fontSize: 12))),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildConditionItem({required IconData icon, required String title, required String description}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: const Color(0xFF202025), borderRadius: BorderRadius.circular(15)),
      child: ExpansionTile(
        leading: Icon(icon, color: Colors.orangeAccent, size: 22),
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
        childrenPadding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
        children: [Text(description, style: const TextStyle(color: Colors.white60, fontSize: 13))],
      ),
    );
  }

  Widget _buildOneTimeBonus() {
    bool isCompleted = _walletService.isProfileCompleted;
    return Opacity(
      opacity: isCompleted ? 0.5 : 1.0,
      child: Container(
        decoration: BoxDecoration(color: const Color(0xFF202025), borderRadius: BorderRadius.circular(15)),
        child: ListTile(
          leading: Icon(isCompleted ? Icons.check_circle : Icons.person_add_outlined, color: isCompleted ? Colors.greenAccent : Colors.orangeAccent),
          title: const Text("4. Профайл бөглөх", style: TextStyle(color: Colors.white, fontSize: 14)),
          trailing: isCompleted ? const Text("Дууссан", style: TextStyle(color: Colors.grey, fontSize: 12)) : const Icon(Icons.chevron_right, color: Colors.white24),
        ),
      ),
    );
  }

  Widget _buildExchangeRateInfo() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.2)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blueAccent, size: 20),
          SizedBox(width: 15),
          Expanded(child: Text("Онооны ханш: 1,000 оноо = 100₮", style: TextStyle(color: Colors.white70, fontSize: 12))),
        ],
      ),
    );
  }
}