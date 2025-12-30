import 'package:flutter/material.dart';
import 'dart:async';
import '../services/mock_wallet_service.dart';
import '../widgets/star_number_widget.dart'; // Таван хошуу виджет
import 'lottery_detail_screen.dart'; // Дэлгэрэнгүй рүү үсрэхэд

class MyLotteryScreen extends StatefulWidget {
  const MyLotteryScreen({super.key});

  @override
  State<MyLotteryScreen> createState() => _MyLotteryScreenState();
}

class _MyLotteryScreenState extends State<MyLotteryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MockWalletService _service = MockWalletService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Огноог ангилах логик
  List<PurchasedTicketModel> _filterTickets(List<PurchasedTicketModel> all, int type) {
    final now = DateTime.now();
    if (type == 0) {
      // Идэвхтэй: 7-оос дээш хоног үлдсэн
      return all.where((t) => t.lotteryEndDate.difference(now).inDays > 7).toList();
    } else if (type == 1) {
      // Хугацаа дөхсөн: 0-7 хоног үлдсэн
      return all.where((t) {
        final diff = t.lotteryEndDate.difference(now).inDays;
        return diff >= 0 && diff <= 7;
      }).toList();
    } else {
      // Дууссан: Хугацаа нь өнгөрсөн
      return all.where((t) => t.lotteryEndDate.isBefore(now)).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Notch-той ижил өнгө
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("МИНИЙ СУГАЛАА", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.amber,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          tabs: const [
            Tab(text: "Идэвхтэй"),
            Tab(text: "Хугацаа дөхсөн"),
            Tab(text: "Дууссан"),
          ],
        ),
      ),
      body: ValueListenableBuilder<List<PurchasedTicketModel>>(
        valueListenable: _service.myTicketsNotifier,
        builder: (context, allTickets, child) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildList(_filterTickets(allTickets, 0), false, false), // Active
              _buildList(_filterTickets(allTickets, 1), true, false),  // Expiring
              _buildList(_filterTickets(allTickets, 2), false, true),  // Expired
            ],
          );
        },
      ),
    );
  }

  Widget _buildList(List<PurchasedTicketModel> tickets, bool isExpiring, bool isExpired) {
    if (tickets.isEmpty) {
      return const Center(child: Text("Сугалаа алга", style: TextStyle(color: Colors.white24)));
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 20, bottom: 30),
      physics: const BouncingScrollPhysics(),
      itemCount: tickets.length,
      itemBuilder: (context, index) {
        return _MyTicketCard(
          ticket: tickets[index],
          isExpiring: isExpiring,
          isExpired: isExpired,
        );
      },
    );
  }
}

class _MyTicketCard extends StatelessWidget {
  final PurchasedTicketModel ticket;
  final bool isExpiring; 
  final bool isExpired;  

  const _MyTicketCard({
    required this.ticket,
    this.isExpiring = false,
    this.isExpired = false,
  });

  @override
  Widget build(BuildContext context) {
    final service = MockWalletService();
    final lotteryModel = service.getLotteryById(ticket.lotteryId);
    final imagePath = lotteryModel?.image ?? "assets/images/2.jpg"; 

    return GestureDetector(
      onTap: () {
        if (lotteryModel != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LotteryDetailScreen(lottery: lotteryModel),
            ),
          );
        }
      },
      child: Opacity(
        opacity: isExpired ? 0.5 : 1.0, 
        child: Container(
          height: 140, 
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // 60% дээр байрлах цэгийг тооцоолох
              final double splitPosition = constraints.maxWidth * 0.6;
              const double notchSize = 16.0; // Notch хэмжээ

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // ҮНДСЭН КАРТНЫ ДЭВСГЭР
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF252525),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.6),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // --- 1. ЗҮҮН ТАЛ (60%) ---
                        Expanded(
                          flex: 6,
                          child: Container(
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.horizontal(left: Radius.circular(16)),
                            ),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                // Зураг
                                ClipRRect(
                                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                                  child: Image.asset(imagePath, fit: BoxFit.cover),
                                ),
                                // Хар сүүдэр (Gradient)
                                Positioned(
                                  bottom: 0, left: 0, right: 0,
                                  child: Container(
                                    height: 80, // Сүүдрийг бага зэрэг өндөр болгов
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(16)),
                                      gradient: LinearGradient(
                                        begin: Alignment.bottomCenter, end: Alignment.topCenter,
                                        colors: [Colors.black.withOpacity(0.95), Colors.transparent],
                                      ),
                                    ),
                                  ),
                                ),
                                // ТАВАН ХОШУУТАЙ ТОО
                                Positioned(
                                  bottom: 12, left: 12,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text("ТАНЫ ДУГААР:", style: TextStyle(color: Colors.white70, fontSize: 9, letterSpacing: 1, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: ticket.ticketNumbers.split('').where((c) => RegExp(r'[0-9]').hasMatch(c)).take(6).map((char) {
                                          return Padding(
                                            padding: const EdgeInsets.only(right: 3),
                                            // ЗАЛРУУЛГА: Хэмжээг томруулсан (size: 32)
                                            child: StarNumberWidget(text: char, size: 32), 
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // --- 2. ТАСАРХАЙ ШУГАМ (Босоо) ---
                        CustomPaint(
                          size: const Size(1, double.infinity),
                          painter: _DashedLineVerticalPainter(),
                        ),

                        // --- 3. БАРУУН ТАЛ (40%) ---
                        Expanded(
                          flex: 4,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Нэр, Үнэ, Цаг
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      ticket.lotteryTitle.toUpperCase(),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      "${ticket.price}₮",
                                      style: const TextStyle(color: Colors.amber, fontSize: 13, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 10),
                                    
                                    // --- LIVE COUNTDOWN TIMER ---
                                    _MiniTimer(
                                      endDate: ticket.lotteryEndDate,
                                      isExpiring: isExpiring,
                                      isExpired: isExpired,
                                    ),
                                  ],
                                ),

                                // Огноо
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("АВСАН ОГНОО", style: TextStyle(color: Colors.white38, fontSize: 8, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 2),
                                    Text(
                                      "${ticket.purchaseDate.month}-р сарын ${ticket.purchaseDate.day}",
                                      style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      "${ticket.purchaseDate.hour.toString().padLeft(2,'0')}:${ticket.purchaseDate.minute.toString().padLeft(2,'0')}",
                                      style: const TextStyle(color: Colors.white54, fontSize: 9),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // --- 4. ДЭЭД NOTCH (Хагас дугуй хар) ---
                  Positioned(
                    top: -notchSize / 2, // Тал нь харагдана
                    left: splitPosition - (notchSize / 2), // Яг шугам дээр төвлөрнө
                    child: Container(
                      width: notchSize,
                      height: notchSize,
                      decoration: const BoxDecoration(
                        color: Color(0xFF121212), // Scaffold background color
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),

                  // --- 5. ДООД NOTCH (Хагас дугуй хар) ---
                  Positioned(
                    bottom: -notchSize / 2, // Тал нь харагдана
                    left: splitPosition - (notchSize / 2), // Яг шугам дээр төвлөрнө
                    child: Container(
                      width: notchSize,
                      height: notchSize,
                      decoration: const BoxDecoration(
                        color: Color(0xFF121212), // Scaffold background color
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// --- MINI TIMER WIDGET (Секундтэй болгосон) ---
class _MiniTimer extends StatefulWidget {
  final DateTime endDate;
  final bool isExpiring;
  final bool isExpired;

  const _MiniTimer({required this.endDate, required this.isExpiring, required this.isExpired});

  @override
  State<_MiniTimer> createState() => _MiniTimerState();
}

class _MiniTimerState extends State<_MiniTimer> {
  late Timer _timer;
  Duration _timeLeft = Duration.zero;

  @override
  void initState() {
    super.initState();
    _calculateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) => _calculateTime());
  }

  void _calculateTime() {
    final now = DateTime.now();
    if (widget.endDate.isAfter(now)) {
      if (mounted) {
        setState(() => _timeLeft = widget.endDate.difference(now));
      }
    } else {
      if (mounted) {
        setState(() => _timeLeft = Duration.zero);
      }
      _timer.cancel();
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isExpired) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Text("ДУУССАН", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
      );
    }

    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final days = _timeLeft.inDays;
    final hours = twoDigits(_timeLeft.inHours.remainder(24));
    final minutes = twoDigits(_timeLeft.inMinutes.remainder(60));
    final seconds = twoDigits(_timeLeft.inSeconds.remainder(60)); // СЕКУНД НЭМСЭН

    // Өдөр байгаа бол өдрийг харуулна, байхгүй бол зөвхөн цаг минут секунд
    String timeString = days > 0 
        ? "$daysө $hours:$minutes:$seconds" 
        : "$hours:$minutes:$seconds";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          // Хугацаа дөхсөн бол улаан, үгүй бол бүдэг саарал
          color: widget.isExpiring ? Colors.redAccent.withOpacity(0.5) : Colors.white12, 
          width: 1
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.access_time_filled, color: widget.isExpiring ? Colors.redAccent : Colors.white54, size: 12),
          const SizedBox(width: 5),
          Text(
            timeString,
            style: TextStyle(
              color: widget.isExpiring ? Colors.redAccent : Colors.white, 
              fontSize: 11, 
              fontWeight: FontWeight.bold,
              fontFamily: "monospace" // Тоонууд үсрэхгүй байхын тулд
            ),
          ),
        ],
      ),
    );
  }
}

// Босоо тасархай зураас зурагч
class _DashedLineVerticalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double dashHeight = 3, dashSpace = 3, startY = 4; // Захын notch-оос холдуулахын тулд startY-г 4 болгов
    final paint = Paint()..color = Colors.white12..strokeWidth = 1;
    
    // Доод зах хүртэл зурах (Notch-ийн хэмжээг тооцож бага зэрэг зай үлдээнэ)
    while (startY < size.height - 4) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}