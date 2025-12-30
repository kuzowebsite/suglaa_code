import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/app_colors.dart';
import '../../services/mock_wallet_service.dart';

class InviteFriendScreen extends StatefulWidget {
  const InviteFriendScreen({super.key});

  @override
  State<InviteFriendScreen> createState() => _InviteFriendScreenState();
}

class _InviteFriendScreenState extends State<InviteFriendScreen> with SingleTickerProviderStateMixin {
  final MockWalletService _walletService = MockWalletService();
  
  // Animation controller for "Pending" icon
  late AnimationController _animationController;
  
  // Tab state: 0 = Accepted, 1 = Pending
  int _selectedTabIndex = 0; 

  late String _inviteLink;
  String _myPhone = "00000000";

  // Жишээ өгөгдөл (Mock Data)
  final List<Map<String, dynamic>> _allInvites = [
    {"phone": "9911****", "status": "accepted", "date": "2024.12.10"},
    {"phone": "8822****", "status": "pending",  "date": "2024.12.11"},
    {"phone": "9900****", "status": "accepted", "date": "2024.12.12"},
    {"phone": "9511****", "status": "pending",  "date": "2024.12.13"},
    {"phone": "8080****", "status": "pending",  "date": "2024.12.13"},
  ];

  @override
  void initState() {
    super.initState();
    
    // 1. Нэвтэрсэн хэрэглэгчийн утсыг авах
    // (MockWalletService дээр loggedInPhone гэж байх ёстой, байхгүй бол 99112233 гэж орлуулна)
    _myPhone = _walletService.loggedInPhone ?? "";

    // 2. Линк үүсгэх (User-ийн хүссэн формат)
    _inviteLink = "ads:AndSoft.LLC-ийн_найзын_урилага_танд_$_myPhone";

    // 3. Animation эхлүүлэх (Эргэлдэх эффект)
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(); // Тасралтгүй давтах
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Хуулах функц
  void _copyLink() {
    Clipboard.setData(ClipboardData(text: _inviteLink));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Холбоос хуулагдлаа!"),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Одоогийн сонгосон tab-аас хамаарч шүүх
    List<Map<String, dynamic>> displayedList = _allInvites.where((item) {
      if (_selectedTabIndex == 0) return item['status'] == 'accepted';
      return item['status'] == 'pending';
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Найзаа урих", style: TextStyle(color: Colors.white)),
        leading: const BackButton(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            // --- HEADER хэсэг ---
            const Icon(Icons.people_alt_outlined, size: 60, color: Colors.amber),
            const SizedBox(height: 15),
            const Text(
              "Найзаа уриад оноо цуглуул!",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text(
              "Таны найз бүртгүүлсний дараа танд +100 оноо, найзад тань +50 оноо орох болно.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),

            const SizedBox(height: 30),

            // --- LINK DISPLAY ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              decoration: BoxDecoration(
                color: const Color(0xFF25252A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _inviteLink,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _copyLink,
                    child: const Icon(Icons.copy, color: Colors.white70, size: 20),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // --- SHARE BUTTONS (Хар өнгөтэй, Цагаан хүрээтэй) ---
            const Text("Хуваалцах", style: TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildShareButton(Icons.copy, onTap: _copyLink), // Copy
                const SizedBox(width: 20),
                _buildShareButton(Icons.facebook, onTap: () {}), // FB (Dummy)
                const SizedBox(width: 20),
                _buildShareButton(Icons.send, onTap: () {}), // Telegram/Other (Dummy)
                const SizedBox(width: 20),
                _buildShareButton(Icons.qr_code, onTap: () {}), // QR (Dummy)
              ],
            ),

            const SizedBox(height: 40),

            // --- TABS (Нэг мөрөнд) ---
            Container(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.white10, width: 1)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTabItem("Урилга хүлээж авсан", 0),
                  ),
                  Expanded(
                    child: _buildTabItem("Урилга хүлээгдэж буй", 1),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- LIST ---
            if (displayedList.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 40),
                child: Text("Одоогоор мэдээлэл алга байна.", style: TextStyle(color: Colors.grey)),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: displayedList.length,
                itemBuilder: (context, index) {
                  final item = displayedList[index];
                  final isPending = item['status'] == 'pending';
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: const Color(0xFF202025),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        // Icon based on status
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isPending 
                                ? Colors.orange.withOpacity(0.1) 
                                : Colors.green.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: isPending
                              // Хүлээгдэж буй үед эргэлддэг icon
                              ? RotationTransition(
                                  turns: _animationController,
                                  child: const Icon(Icons.hourglass_empty, color: Colors.orange, size: 20),
                                )
                              : const Icon(Icons.check, color: Colors.green, size: 20),
                        ),
                        const SizedBox(width: 15),
                        
                        // Phone & Date
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['phone'], 
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item['date'], 
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        
                        // Status Text
                        Text(
                          isPending ? "Хүлээгдэж байна" : "Амжилттай",
                          style: TextStyle(
                            color: isPending ? Colors.orange : Colors.green,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  // CUSTOM SHARE BUTTON WIDGET
  Widget _buildShareButton(IconData icon, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.black, // Тас хар
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 1.5), // Цагаан хүрээ
        ),
        child: Icon(icon, color: Colors.white, size: 22), // Цагаан icon
      ),
    );
  }

  // CUSTOM TAB ITEM WIDGET
  Widget _buildTabItem(String title, int index) {
    bool isSelected = _selectedTabIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          border: isSelected 
              ? const Border(bottom: BorderSide(color: Colors.amber, width: 2)) // Сонгогдсон үед доогуураа зураастай
              : null,
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey, // Сонгогдсон үед цагаан, үгүй бол саарал
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}