import 'dart:ui'; 
import 'package:flutter/material.dart';
import '../utils/app_colors.dart'; 
import '../services/mock_wallet_service.dart'; 
import '../screens/profile_screen.dart'; 
import '../screens/live_stream_screen.dart'; 

class CustomAppBar extends StatefulWidget {
  const CustomAppBar({super.key});

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  final MockWalletService _walletService = MockWalletService();
  
  // Mэдэгдлийн цэсний байршлыг олоход хэрэгтэй
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isDropdownOpen = false;

  // MOCK DATA: Мэдэгдлүүд
  final List<Map<String, dynamic>> _notifications = [
    {
      "title": "Амжилттай цэнэглэлт",
      "body": "Таны данс 50,000₮-өөр цэнэглэгдлээ.",
      "time": "2 минутын өмнө",
      "isRead": false,
      "icon": Icons.account_balance_wallet,
      "color": Colors.green
    },
    {
      "title": "Шууд дамжуулалт эхэллээ",
      "body": "iPhone 15 Pro Max-ын азтан тодруулах live эхэллээ!",
      "time": "10 минутын өмнө",
      "isRead": false,
      "icon": Icons.live_tv,
      "color": Colors.redAccent
    },
    {
      "title": "Танд шинэ хүсэлт ирлээ",
      "body": "Батболд таныг найзаар нэмэх хүсэлт илгээлээ.",
      "time": "1 цагийн өмнө",
      "isRead": true,
      "icon": Icons.person_add,
      "color": Colors.blue
    },
    {
      "title": "Системийн шинэчлэл",
      "body": "Аппликейшн шинэчлэгдлээ. Шинэ боломжуудыг туршаад үзээрэй.",
      "time": "Өчигдөр",
      "isRead": true,
      "icon": Icons.system_update,
      "color": Colors.orange
    },
    {
      "title": "Сугалааны дүн",
      "body": "Өчигдрийн сугалааны азтанууд тодорлоо. Дэлгэрэнгүйг харна уу.",
      "time": "2 өдрийн өмнө",
      "isRead": true,
      "icon": Icons.emoji_events,
      "color": Colors.purple
    },
  ];

  @override
  void dispose() {
    // Хэрэв дэлгэцээс гарах үед цэс нээлттэй байвал хаана
    _removeOverlay();
    super.dispose();
  }

  // --- DROPDOWN (Overlay) FUNCTION ---
  void _toggleOverlay() {
    if (_isDropdownOpen) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {
      _isDropdownOpen = false;
    });
  }

  void _showOverlay() {
    // Дэлгэцийн хаана дарсныг мэдэх OverlayEntry үүсгэх
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isDropdownOpen = true;
    });
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          // 1. Дэлгэцийн бусад хэсэгт дарвал хаах
          GestureDetector(
            onTap: _removeOverlay,
            behavior: HitTestBehavior.translucent,
            child: Container(color: Colors.transparent),
          ),
          
          // 2. Унждаг цэс (Dropdown)
          Positioned(
            width: 320, // Цэсний өргөн
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              // Icon-оос зүүн тийш шилжүүлж байрлуулна (Баруун талд тулгахын тулд)
              offset: const Offset(-280, 50), 
              child: Material(
                elevation: 10,
                color: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white12),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 5))
                    ]
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Мэдэгдэл", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                            Text("${_notifications.where((n) => !n['isRead']).length} шинэ", style: const TextStyle(color: Colors.blueAccent, fontSize: 12)),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: Colors.white10),
                      
                      // List (Зөвхөн эхний 3-ыг харуулна)
                      ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _notifications.length > 3 ? 3 : _notifications.length,
                        itemBuilder: (context, index) {
                          return _buildNotificationItem(_notifications[index], compact: true);
                        },
                      ),
                      
                      // Footer (See All)
                      GestureDetector(
                        onTap: () {
                          _removeOverlay(); // Dropdown-г хаагаад
                          _openAllNotifications(); // BottomSheet нээнэ
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: const BoxDecoration(
                            border: Border(top: BorderSide(color: Colors.white10)),
                          ),
                          child: const Center(
                            child: Text("Бүгдийг харах", style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- BOTTOM SHEET FUNCTION ---
  void _openAllNotifications() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Бүтэн дэлгэцээр татах боломжтой
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7, // Эхлээд дэлгэцийн 70%-д гарна
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFF121212),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle Bar
              Center(
                child: Container(
                  width: 40, height: 5,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(10)),
                ),
              ),
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Бүх мэдэгдэл", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    TextButton(
                      onPressed: () {}, // Бүгдийг уншсанаар тэмдэглэх функц
                      child: const Text("Бүгдийг уншсан", style: TextStyle(color: Colors.blueAccent)),
                    )
                  ],
                ),
              ),
              const Divider(color: Colors.white10),
              
              // Full List
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    return _buildNotificationItem(_notifications[index], compact: false);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Notification Item Widget
  Widget _buildNotificationItem(Map<String, dynamic> data, {required bool compact}) {
    return Container(
      color: data['isRead'] ? Colors.transparent : Colors.white.withOpacity(0.02),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (data['color'] as Color).withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(data['icon'], color: data['color'], size: 20),
        ),
        title: Text(
          data['title'],
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white, 
            fontSize: 14, 
            fontWeight: data['isRead'] ? FontWeight.normal : FontWeight.bold
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!compact) ...[
               const SizedBox(height: 4),
               Text(data['body'], style: const TextStyle(color: Colors.white70, fontSize: 13)),
            ],
            const SizedBox(height: 4),
            Text(data['time'], style: const TextStyle(color: Colors.grey, fontSize: 11)),
          ],
        ),
        trailing: !data['isRead'] 
          ? Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle))
          : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    
    String phone = _walletService.currentPhone; 
    String? name = _walletService.currentName;
    String? photoUrl = _walletService.profileUrl;
    
    String displayName = (name != null && name.trim().isNotEmpty) ? name : phone;

    // --- ЗУРАГ ХАРУУЛАХ WIDGET ---
    Widget profileAvatar;
    if (photoUrl != null && photoUrl.isNotEmpty) {
      profileAvatar = Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24, width: 1.5),
          image: DecorationImage(
            image: NetworkImage(photoUrl),
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      profileAvatar = Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: Colors.white10, 
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24, width: 1.5),
        ),
        child: const Icon(Icons.person, color: Colors.white70, size: 28),
      );
    }

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: EdgeInsets.only(
            top: statusBarHeight + 10,
            bottom: 15,
            left: 20,
            right: 20,
          ),
          decoration: BoxDecoration(
            color: AppColors.darkBackground.withOpacity(0.7),
            border: const Border(
              bottom: BorderSide(color: Colors.white10, width: 0.5),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ЗҮҮН ТАЛ: Profile + Name
              GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileScreen()),
                  );
                  setState(() {});
                },
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    profileAvatar, 
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Сайн байна уу,",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white60,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          displayName, 
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // БАРУУН ТАЛ: Live Button & Notification Icon
              Row(
                children: [
                  // 1. LIVE BUTTON
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LiveStreamScreen()),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.circle, color: Colors.redAccent, size: 10),
                          SizedBox(width: 6),
                          Text(
                            "LIVE", 
                            style: TextStyle(
                              color: Colors.white, 
                              fontWeight: FontWeight.bold, 
                              fontSize: 12
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 2. NOTIFICATION BUTTON (CompositedTransformTarget ашиглана)
                  CompositedTransformTarget(
                    link: _layerLink, // Энэ холбоосоор Overlay байршлаа олно
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: _isDropdownOpen ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.05), 
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white10),
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 24),
                            onPressed: _toggleOverlay, // Dropdown нээх/хаах
                          ),
                        ),
                        
                        // Улаан цэг (Шинэ мэдэгдэл байгаа үед)
                        if (_notifications.any((n) => !n['isRead']))
                          Positioned(
                            right: 10,
                            top: 10,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF5252), 
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.darkBackground, width: 1.5),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}