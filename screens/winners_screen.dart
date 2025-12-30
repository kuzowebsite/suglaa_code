import 'dart:async';
import 'dart:ui'; 
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../utils/app_colors.dart';

// ==========================================
// 1. MAIN SCREEN
// ==========================================
class WinnersScreen extends StatefulWidget {
  const WinnersScreen({super.key});

  @override
  State<WinnersScreen> createState() => _WinnersScreenState();
}

class _WinnersScreenState extends State<WinnersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  // Data Source
  final List<Map<String, String>> _allWinners = [
    // Big Winners
    {
      "type": "big",
      "title": "Land Cruiser 300 Азтан",
      "videoUrl": "https://www.facebook.com/plugins/video.php?height=476&href=https%3A%2F%2Fwww.facebook.com%2Freel%2F2281757538996869%2F&show_text=false&width=267&t=0",
      "views": "25.9k",
      "likes": "1.2k",
      "comments": "340",
      "winnerName": "Б.Батболд",
      "luckyNumber": "889012",
      "desc": "Монгол улсын хэмжээнд явагдсан том сугалааны супер азтан тодорлоо. Энэхүү сугалаанд нийт 100,000 хүн оролцсоноос Б.Батболд супер шагналын эзэн боллоо.",
    },
    {
      "type": "big",
      "title": "iPhone 15 Pro Max",
      "videoUrl": "https://www.facebook.com/plugins/video.php?height=476&href=https%3A%2F%2Fwww.facebook.com%2Freel%2F741548408978897%2F&show_text=false&width=267&t=0",
      "views": "12.5k",
      "likes": "890",
      "comments": "120",
      "winnerName": "Г.Саран",
      "luckyNumber": "145678",
      "desc": "Ухаалаг утасны эзэн болсон азтан. Тэрээр 5 дахь удаагаа оролцож байж ийнхүү азтан болжээ.",
    },
    // Normal Winners
    {
      "type": "normal",
      "title": "Сүпер азтан",
      "videoUrl": "https://www.facebook.com/plugins/video.php?height=476&href=https%3A%2F%2Fwww.facebook.com%2Freel%2F741548408978897%2F&show_text=false&width=267&t=0",
      "views": "5.2k",
      "likes": "500",
      "comments": "45",
      "winnerName": "Т.Наран",
      "luckyNumber": "550011",
      "desc": "Баярын өдрийн супер азтан.",
    },
    {
      "type": "normal",
      "title": "Бэлгийн эзэн",
      "videoUrl": "https://www.facebook.com/plugins/video.php?height=476&href=https%3A%2F%2Fwww.facebook.com%2Freel%2F2281757538996869%2F&show_text=false&width=267&t=0",
      "views": "3.1k",
      "likes": "210",
      "comments": "30",
      "winnerName": "О.Дорж",
      "luckyNumber": "991234",
      "desc": "Гарын бэлгийн азтан.",
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, String>> _filterList(List<Map<String, String>> list, String type) {
    return list.where((item) {
      if (item['type'] != type) return false;
      if (_searchQuery.isEmpty) return true;
      final title = item['title']!.toLowerCase();
      final name = item['winnerName']!.toLowerCase();
      final query = _searchQuery.toLowerCase();
      return title.contains(query) || name.contains(query);
    }).toList();
  }

  void _showWinnerDetail(BuildContext context, Map<String, String> data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WinnerDetailSheet(
        data: data,
        allWinners: _allWinners,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredBigWinners = _filterList(_allWinners, "big");
    final filteredNormalWinners = _filterList(_allWinners, "normal");
    
    double screenWidth = MediaQuery.of(context).size.width;
    double cardWidth = (screenWidth - 45) / 2;
    double cardHeight = cardWidth / 0.75;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 100, bottom: 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SEARCH
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: const InputDecoration(
                    hintText: "Азтангийн нэр, гарчигаар хайх...",
                    hintStyle: TextStyle(color: Colors.white38, fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: Colors.white54),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // BIG WINNERS
            if (filteredBigWinners.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text("Том сугалааны азтангууд", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              SizedBox(
                height: cardHeight,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  itemCount: filteredBigWinners.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 15),
                      child: GestureDetector(
                        onTap: () => _showWinnerDetail(context, filteredBigWinners[index]),
                        child: WinnerCard(data: filteredBigWinners[index], width: cardWidth),
                      ),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 20),
            
            // NORMAL WINNERS
            if (filteredNormalWinners.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text("Азтангууд", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: filteredNormalWinners.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, 
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => _showWinnerDetail(context, filteredNormalWinners[index]),
                      child: WinnerCard(data: filteredNormalWinners[index], width: double.infinity),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 2. WINNER DETAIL SHEET
// ==========================================
class WinnerDetailSheet extends StatefulWidget {
  final Map<String, String> data;
  final List<Map<String, String>> allWinners;

  const WinnerDetailSheet({super.key, required this.data, required this.allWinners});

  @override
  State<WinnerDetailSheet> createState() => _WinnerDetailSheetState();
}

class _WinnerDetailSheetState extends State<WinnerDetailSheet> with TickerProviderStateMixin {
  late Map<String, String> _currentData; 
  int _currentTabIndex = 0; 

  final List<Map<String, String>> partners = [
    {"name": "Samsung", "logo": "S", "info": "Samsung Electronics", "contact": "7777-1234"},
    {"name": "Unitel", "logo": "U", "info": "Unitel Group", "contact": "7777-8888"},
    {"name": "CocaCola", "logo": "C", "info": "MCS Coca Cola", "contact": "7711-0000"},
  ];
  String? _selectedPartnerInfo;

  @override
  void initState() {
    super.initState();
    _currentData = widget.data;
  }

  // --- NAVIGATE TO FULL FEED & UPDATE ON RETURN ---
  Future<void> _openFullFeed() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullScreenVideoFeed(
          initialWinner: _currentData, 
          allWinners: widget.allWinners
        )
      )
    );

    if (result != null && result is Map<String, String>) {
      setState(() {
        _currentData = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1E1E1E), 
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // HEADER
              _buildHeader(),
              
              // TOP CONTENT
              _buildTopSection(),

              // TABS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildTabItem("Сэтгэгдэл", 0),
                    _buildTabItem("Азтан", 1),
                    _buildTabItem("Хамтарсан", 2),
                  ],
                ),
              ),
              const Divider(color: Colors.white10, height: 1),

              // TAB CONTENT
              Expanded(
                child: _currentTabIndex == 0 
                  // Use the Reusable Comment Widget
                  ? SharedCommentsWidget(scrollController: scrollController)
                  : _currentTabIndex == 1 
                      ? _buildWinnerTab(scrollController)
                      : _buildPartnersTab(scrollController),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        children: [
          Container(
            width: 40, height: 4, margin: const EdgeInsets.only(bottom: 15),
            decoration: BoxDecoration(color: Colors.grey[600], borderRadius: BorderRadius.circular(2)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _currentData['winnerName'] ?? "Азтан",
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              // WATCH BUTTON
              GestureDetector(
                onTap: _openFullFeed,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  child: const Text(
                    "Үзэх",
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- TOP SECTION ---
  Widget _buildTopSection() {
    return SizedBox(
      height: 180,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // VIDEO
            Expanded(
              flex: 5,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AbsorbPointer(
                  child: WebViewWidget(
                    controller: WebViewController()
                      ..setJavaScriptMode(JavaScriptMode.unrestricted)
                      ..setBackgroundColor(Colors.black)
                      ..loadHtmlString(_getHtml(_currentData['videoUrl']!)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // INFO BOX
            Expanded(
              flex: 4,
              child: GestureDetector(
                onTap: _showExpandedInfoDialog,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentData['title'] ?? "",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _currentData['desc'] ?? "...",
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white70, fontSize: 10),
                      ),
                      const Spacer(),
                      const Align(
                         alignment: Alignment.bottomRight,
                         child: Icon(Icons.open_in_full_rounded, color: Colors.white38, size: 14),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExpandedInfoDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Close",
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, anim1, anim2) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: () {}, 
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                height: MediaQuery.of(context).size.height * 0.5,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2C),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20)],
                  border: Border.all(color: Colors.white24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentData['title']!,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    const Divider(color: Colors.white24),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          _currentData['desc'] ?? "",
                          style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabItem(String title, int index) {
    bool isActive = _currentTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentTabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          border: isActive ? const Border(bottom: BorderSide(color: Colors.orange, width: 2)) : null,
        ),
        child: Text(title, style: TextStyle(color: isActive ? Colors.white : Colors.grey, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
      ),
    );
  }

  // --- PARTNERS TAB ---
  Widget _buildPartnersTab(ScrollController controller) {
    return SingleChildScrollView(
      controller: controller,
      child: Column(
        children: [
          const SizedBox(height: 20),
          SizedBox(
            height: 120, 
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: partners.length,
              itemBuilder: (ctx, i) {
                final p = partners[i];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedPartnerInfo = "${p['name']}\n${p['info']}\nУтас: ${p['contact']}";
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 20),
                    child: Column(
                      children: [
                        Container(
                          width: 70, height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white10,
                            border: Border.all(color: Colors.white24),
                          ),
                          alignment: Alignment.center,
                          child: Text(p['logo']!, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 8),
                        Text(p['name']!, style: const TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          if (_selectedPartnerInfo != null)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange.withOpacity(0.5))
              ),
              child: Text(
                _selectedPartnerInfo!,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
  
  // --- WINNER TAB ---
  Widget _buildWinnerTab(ScrollController controller) {
     String luckyNum = _currentData['luckyNumber'] ?? "000000";
     if (luckyNum.length < 6) luckyNum = luckyNum.padRight(6, '0');
     List<String> digits = luckyNum.split('').take(6).toList();

     return SingleChildScrollView(
      controller: controller,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Азтаны сэтгэгдэл:", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text(
            "\"Маш их баярлалаа! Энэ сугалаанд оролцоод ийм том шагнал авна гэж зүүдлээчгүй явлаа. Та бүхэнд ажлын амжилт хүсье!\"",
            style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic, fontSize: 16),
          ),
          const SizedBox(height: 20),
          
          // 6 STAR BADGES
          const Text("Азын тоо: ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: digits.map((digit) {
              return Container(
                width: 45, height: 45,
                margin: const EdgeInsets.only(right: 8),
                alignment: Alignment.center,
                decoration: const ShapeDecoration(
                  color: Colors.black, // Тас хар
                  shape: StarBorder(
                    points: 5,
                    innerRadiusRatio: 0.4,
                    pointRounding: 0.2,
                    side: BorderSide(color: Colors.white, width: 1.5) // Цагаан хүрээ
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Text(
                    digit,
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          
          const Text("Зургийн цомог:", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          SizedBox(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (ctx, i) => Container(
                width: 200,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(10),
                  image: const DecorationImage(
                     image: NetworkImage("https://via.placeholder.com/200x150"),
                     fit: BoxFit.cover
                  )
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  String _getHtml(String iframeSrc) {
    return '''<!DOCTYPE html><html><body style="margin:0;background:black;overflow:hidden;"><iframe src="$iframeSrc" style="width:100%;height:100%;border:none;object-fit:cover;" scrolling="no"></iframe></body></html>''';
  }
}

// ==========================================
// 3. FULL SCREEN VIDEO FEED (TikTok Style)
// ==========================================
class FullScreenVideoFeed extends StatefulWidget {
  final Map<String, String> initialWinner;
  final List<Map<String, String>> allWinners;

  const FullScreenVideoFeed({super.key, required this.initialWinner, required this.allWinners});

  @override
  State<FullScreenVideoFeed> createState() => _FullScreenVideoFeedState();
}

class _FullScreenVideoFeedState extends State<FullScreenVideoFeed> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    int initialIndex = widget.allWinners.indexOf(widget.initialWinner);
    if (initialIndex == -1) initialIndex = 0;
    _currentIndex = initialIndex;
    _pageController = PageController(initialPage: initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onBack() {
    Navigator.pop(context, widget.allWinners[_currentIndex]);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _onBack();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // 1. VERTICAL VIDEO FEED
            PageView.builder(
              scrollDirection: Axis.vertical,
              controller: _pageController,
              itemCount: widget.allWinners.length,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },
              itemBuilder: (context, index) {
                return FullVideoPageItem(data: widget.allWinners[index]);
              },
            ),
            
            // 2. TRANSPARENT HEADER (Top with Name & Back)
            Positioned(
              top: 0, left: 0, right: 0,
              // SafeArea-г ашиглаж дээд талаасаа зай авна, гэхдээ layout эвдэхгүйн тулд
              // зөвхөн top padding-ийг тооцно.
              child: SafeArea(
                child: Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.transparent
                      ]
                    ),
                  ),
                  child: Row(
                    children: [
                      // LEFT: Winner Name
                      Text(
                        widget.allWinners[_currentIndex]['winnerName'] ?? "Азтан",
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      // RIGHT: Back Button
                      GestureDetector(
                        onTap: _onBack,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FullVideoPageItem extends StatefulWidget {
  final Map<String, String> data;
  const FullVideoPageItem({super.key, required this.data});

  @override
  State<FullVideoPageItem> createState() => _FullVideoPageItemState();
}

class _FullVideoPageItemState extends State<FullVideoPageItem> {
  late WebViewController _webViewController;
  bool _isMenuHidden = false;
  String? _currentReaction;
  final List<String> reactions = ["❤️", "😢", "😠", "😄", "🎉", "👏"];

  @override
  void initState() {
    super.initState();

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..loadHtmlString(_getHtml(widget.data['videoUrl']!));
  }

  @override
  void dispose() {
    super.dispose();
  }

  // HTML: Flexbox ашиглаж Iframe-ийг яг голлуулна
  String _getHtml(String iframeSrc) {
    return '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
        <style>
          body, html { 
            margin: 0; 
            padding: 0; 
            width: 100%; 
            height: 100%; 
            background-color: black;
            overflow: hidden;
            
            /* ЭНЭ ХЭСЭГ: Видеог яг голлуулна */
            display: flex;
            align-items: center;
            justify-content: center;
          }
          
          iframe { 
            width: 100%; 
            height: 100%; 
            border: none; 
          }
        </style>
      </head>
      <body>
        <iframe 
          src="$iframeSrc" 
          allow="autoplay; clipboard-write; encrypted-media; picture-in-picture; web-share"
          allowfullscreen>
        </iframe>
      </body>
      </html>
    ''';
  }

  // Reaction Popup
  void _showReactionPopup() {
    showDialog(
      context: context,
      barrierColor: Colors.transparent, 
      builder: (ctx) => Stack(
        children: [
          Positioned(
            right: 60,
            bottom: 300, 
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: reactions.map((emoji) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _currentReaction = emoji;
                        });
                        Navigator.pop(ctx);
                      },
                      child: Text(emoji, style: const TextStyle(fontSize: 24)),
                    ),
                  )).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Сэтгэгдэл харуулах
  void _showComments() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1E1E1E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))
          ),
          child: Column(
            children: [
              Container(
                width: 40, height: 4, margin: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(color: Colors.grey[600], borderRadius: BorderRadius.circular(2)),
              ),
              Expanded(child: SharedCommentsWidget(scrollController: scrollController)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Хар дэвсгэр
      resizeToAvoidBottomInset: false, 
      // !!! ЧУХАЛ: SafeArea ашиглаж видеог notch болон доод зурааснаас хамгаалж, голлуулна !!!
      body: SafeArea(
        child: Stack(
          children: [
            // 1. VIDEO LAYER (WebView)
            // Center болон Padding ашиглан тодорхой зай авч "доошлуулна"
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 60.0), // Дээд доод талаас 60px зай авна
              child: Center(
                child: WebViewWidget(controller: _webViewController),
              ),
            ),

            // 2. БАРУУН ТАЛЫН ЦЭС
            Positioned(
              right: 10,
              bottom: 80, 
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Хураах товч
                  GestureDetector(
                    onTap: () => setState(() => _isMenuHidden = !_isMenuHidden),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                      child: Icon(_isMenuHidden ? Icons.arrow_back_ios_new : Icons.arrow_forward_ios, color: Colors.white, size: 16),
                    ),
                  ),
                  
                  // Гулсдаг цэс
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: _isMenuHidden ? 0 : 50,
                    height: _isMenuHidden ? 0 : 250,
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: _isMenuHidden ? null : Column(
                        children: [
                          // LIKE / EMOJI
                          GestureDetector(
                            onLongPress: _showReactionPopup,
                            onTap: () { setState(() { if (_currentReaction != null) _currentReaction = null; }); },
                            child: _currentReaction != null
                                ? Column(children: [Text(_currentReaction!, style: const TextStyle(fontSize: 32)), const SizedBox(height: 4), Text(widget.data['likes'] ?? "0", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))])
                                : _buildRightIcon(Icons.favorite, widget.data['likes'] ?? "0", Colors.redAccent),
                          ),
                          const SizedBox(height: 20),
                          
                          // COMMENT
                          GestureDetector(
                            onTap: _showComments,
                            child: _buildRightIcon(Icons.comment, widget.data['comments'] ?? "0", Colors.white),
                          ),
                          const SizedBox(height: 20),
                          
                          // VIEWS
                          _buildRightIcon(Icons.remove_red_eye, widget.data['views'] ?? "0", Colors.white),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRightIcon(IconData icon, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 4, color: Colors.black)]),
        )
      ],
    );
  }
}

// ==========================================
// 4. SHARED COMMENT WIDGET (For Detail & Feed)
// ==========================================
class SharedCommentsWidget extends StatefulWidget {
  final ScrollController scrollController;
  const SharedCommentsWidget({super.key, required this.scrollController});

  @override
  State<SharedCommentsWidget> createState() => _SharedCommentsWidgetState();
}

class _SharedCommentsWidgetState extends State<SharedCommentsWidget> {
  final TextEditingController _commentController = TextEditingController();
  
  // Local state for comments demo
  List<Map<String, dynamic>> comments = [
    {"id": 1, "user": "Wade Warren", "text": "OP🔥🔥🔥 you got nice moves", "time": "2m", "reaction": null, "replyTo": null},
    {"id": 2, "user": "Albert Flores", "text": "sooooo good man👌👌", "time": "5m", "reaction": "❤️", "replyTo": null},
    {"id": 3, "user": "Me", "text": "Баярлалаа залуусаа!", "time": "Just now", "reaction": null, "replyTo": null},
  ];

  Map<String, dynamic>? _replyingToComment;
  bool _isAngry = false;
  bool _isFlying = false;
  final List<String> reactions = ["❤️", "😢", "😠", "😄", "🎉", "👏"];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: widget.scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: comments.length,
            itemBuilder: (context, index) {
              final com = comments[index];
              return _buildCommentItem(com, index);
            },
          ),
        ),
        _buildInputArea(),
      ],
    );
  }

  Widget _buildCommentItem(Map<String, dynamic> com, int index) {
    bool isMe = com['user'] == "Me";
    return GestureDetector(
      onLongPress: () => _showCommentOptions(context, com, index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        color: Colors.transparent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: isMe ? Colors.orange : Colors.grey,
              child: Icon(isMe ? Icons.person_pin : Icons.person, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(com['user'], style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Text(com['time'], style: const TextStyle(color: Colors.white24, fontSize: 11)),
                    ],
                  ),
                  if (com['replyTo'] != null)
                    Container(
                      margin: const EdgeInsets.only(top: 4, bottom: 4),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Row(
                        children: [
                          Container(width: 2, height: 20, color: Colors.orange),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("@${com['replyTo']['user']}", style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                                Text(com['replyTo']['text'], maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey, fontSize: 10)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(com['text'], style: const TextStyle(color: Colors.white)),
                ],
              ),
            ),
            Column(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      comments[index]['reaction'] = comments[index]['reaction'] == null ? "❤️" : null;
                    });
                  },
                  onLongPress: () => _showReactionPopup(index),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: com['reaction'] != null 
                      ? Text(com['reaction'], style: const TextStyle(fontSize: 18))
                      : const Icon(Icons.favorite_border, color: Colors.grey, size: 18),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _showReactionPopup(int index) {
    showDialog(
      context: context,
      barrierColor: Colors.black26, 
      builder: (ctx) => Stack(
        children: [
          Positioned(
            top: MediaQuery.of(context).size.height / 2 - 50,
            left: 20, right: 20,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: reactions.map((emoji) => GestureDetector(
                    onTap: () {
                      setState(() => comments[index]['reaction'] = emoji);
                      Navigator.pop(ctx);
                    },
                    child: Text(emoji, style: const TextStyle(fontSize: 28)),
                  )).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 10,
        left: 16, right: 16, top: 10
      ),
      color: const Color(0xFF2C2C2C),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_replyingToComment != null)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Хариулж байна: ${_replyingToComment!['user']}", style: const TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold)),
                      Text(_replyingToComment!['text'], style: const TextStyle(color: Colors.grey, fontSize: 11)),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _replyingToComment = null),
                    child: const Icon(Icons.close, color: Colors.grey, size: 16),
                  )
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(25)),
                  child: TextField(
                    controller: _commentController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "Сэтгэгдэл бичих...",
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _handleSend,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  transform: _isAngry ? Matrix4.translationValues(5, 0, 0) : Matrix4.identity(),
                  onEnd: () {
                     if (_isAngry) setState(() => _isAngry = false); 
                  },
                  child: AnimatedOpacity(
                    opacity: _isFlying ? 0.0 : 1.0, 
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      width: 45, height: 45,
                      decoration: BoxDecoration(
                        color: Colors.black, 
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5), 
                      ),
                      child: _isAngry 
                        ? const Icon(Icons.sentiment_very_dissatisfied, color: Colors.redAccent, size: 24)
                        : const Icon(Icons.send, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  void _handleSend() {
    if (_commentController.text.isEmpty) {
      setState(() => _isAngry = true);
      Timer(const Duration(milliseconds: 100), () => setState(() => _isAngry = false)); 
      Timer(const Duration(milliseconds: 100), () => setState(() => _isAngry = true)); 
      setState(() => _isAngry = true);
      Timer(const Duration(seconds: 3), () {
        if (mounted) setState(() => _isAngry = false);
      });
    } else {
      setState(() => _isFlying = true);
      Timer(const Duration(milliseconds: 400), () {
        if (!mounted) return;
        setState(() {
          String txt = _commentController.text;
          comments.add({
            "id": DateTime.now().millisecondsSinceEpoch,
            "user": "Me",
            "text": txt,
            "time": "Just now",
            "reaction": null,
            "replyTo": _replyingToComment 
          });
          _commentController.clear();
          _replyingToComment = null;
          _isFlying = false; 
        });
      });
    }
  }

  void _showCommentOptions(BuildContext context, Map<String, dynamic> com, int index) {
    bool isMe = com['user'] == "Me";
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: const Color(0xFF2C2C2C), borderRadius: BorderRadius.circular(15)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isMe) ...[
               ListTile(
                leading: const Icon(Icons.reply, color: Colors.white),
                title: const Text("Хариулах", style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() => _replyingToComment = com);
                },
              ),
              ListTile(
                leading: const Icon(Icons.copy, color: Colors.white),
                title: const Text("Хуулах", style: TextStyle(color: Colors.white)),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: com['text']));
                  Navigator.pop(ctx);
                },
              ),
            ] else ...[
               ListTile(
                leading: const Icon(Icons.edit, color: Colors.white),
                title: const Text("Засах", style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(ctx);
                  _commentController.text = com['text'];
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.redAccent),
                title: const Text("Устгах", style: TextStyle(color: Colors.redAccent)),
                onTap: () {
                  setState(() => comments.removeAt(index));
                  Navigator.pop(ctx);
                },
              ),
            ]
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 5. MAIN CARD WIDGET
// ==========================================
class WinnerCard extends StatefulWidget {
  final Map<String, String> data;
  final double width;

  const WinnerCard({super.key, required this.data, required this.width});

  @override
  State<WinnerCard> createState() => _WinnerCardState();
}

class _WinnerCardState extends State<WinnerCard> {
  late WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..loadHtmlString(_getHtml(widget.data['videoUrl']!));
  }

  // ШИНЭЧЛЭГДСЭН: Iframe-ийг дүүргэж, crop хийж харуулна (object-fit: cover)
  String _getHtml(String iframeSrc) {
    return '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
        <style>
          body, html { 
            margin: 0; 
            padding: 0; 
            width: 100%; 
            height: 100%; 
            background-color: black;
            overflow: hidden;
          }
          iframe { 
            position: absolute; 
            top: 0; 
            left: 0; 
            width: 100%; 
            height: 100%; 
            border: none; 
            object-fit: cover; 
          }
        </style>
      </head>
      <body>
        <iframe src="$iframeSrc" allowfullscreen></iframe>
      </body>
      </html>
    ''';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.black,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned.fill(child: AbsorbPointer(child: WebViewWidget(controller: _controller))),
            // ШИНЭЧЛЭГДСЭН: Доод талын хар уусалтыг багасгасан (0.9 -> 0.6)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, 
                    end: Alignment.bottomCenter, 
                    colors: [
                      Colors.black.withOpacity(0.3), 
                      Colors.transparent, 
                      Colors.black.withOpacity(0.6) // Багасгасан
                    ]
                  )
                )
              ),
            ),
            Positioned(
              top: 10, left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white24, width: 0.5)),
                child: Text(widget.data['winnerName'] ?? "Азтан", style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ),
            Positioned(
              top: 10, right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [const Icon(Icons.remove_red_eye, color: Colors.white70, size: 14), const SizedBox(width: 4), Text(widget.data['views']!, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))],
                ),
              ),
            ),
            Positioned(
              bottom: 15, left: 15, right: 15,
              child: Text(widget.data['title']!, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600, shadows: [Shadow(color: Colors.black, blurRadius: 4)])),
            ),
          ],
        ),
      ),
    );
  }
}