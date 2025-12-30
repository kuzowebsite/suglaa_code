import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:webview_flutter/webview_flutter.dart';
import '../utils/app_colors.dart'; 

class LiveStreamScreen extends StatefulWidget {
  const LiveStreamScreen({super.key});

  @override
  State<LiveStreamScreen> createState() => _LiveStreamScreenState();
}

class _LiveStreamScreenState extends State<LiveStreamScreen> {
  late WebViewController _webViewController;
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode(); 

  // --- ТОХИРГОО ---
  final int maxDigits = 6; 
  
  // MOCK DATA: My Tickets
  List<Map<String, dynamic>> myTickets = [
    {
      "name": "Land Cruiser 300",
      "number": "984512", 
      "image": "https://images.unsplash.com/photo-1533473359331-0135ef1bcfb0?auto=format&fit=crop&w=500&q=80"
    }, 
    {
      "name": "iPhone 15 Pro Max",
      "number": "125678", 
      "image": "https://images.unsplash.com/photo-1494976388531-d1058494cdd8?auto=format&fit=crop&w=500&q=80"
    }, 
    {
      "name": "Samsung S24 Ultra",
      "number": "334519", 
      "image": "https://images.unsplash.com/photo-1503376763036-066120622c74?auto=format&fit=crop&w=500&q=80"
    }, 
  ];

  // LIVE STATE
  String currentDrawnNumbers = ""; 

  // COMMENTS DATA
  // "isMe": true гэвэл өөрийн бичсэн сэтгэгдэл гэж үзнэ
  List<Map<String, dynamic>> comments = [
    {"id": "1", "user": "Батболд", "text": "Амжилт хүсье бүгдэд нь!", "time": "2 min", "reaction": null, "isMe": false},
    {"id": "2", "user": "Саран", "text": "Минийх таараасай 🙏", "time": "1 min", "reaction": "❤️", "isMe": false},
    {"id": "3", "user": "Би", "text": "Энэ машин гоё юм байна даа", "time": "Now", "reaction": null, "isMe": true},
  ];

  // Хариулж буй сэтгэгдэл (Reply state)
  Map<String, dynamic>? _replyingTo;

  // Reaction Emojis
  final List<String> _reactionEmojis = ["👍", "❤️", "😂", "😠", "👏", "😢"];

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000)) 
      ..loadHtmlString(_getFacebookIframeHtml());
  }

  String _getFacebookIframeHtml() {
    return '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
          body { margin: 0; padding: 0; background-color: black; display: flex; justify-content: center; align-items: center; height: 100vh; }
          iframe { width: 100%; height: 100%; border: none; }
        </style>
      </head>
      <body>
        <iframe src="https://www.facebook.com/plugins/video.php?height=314&href=https%3A%2F%2Fwww.facebook.com%2Freel%2F1639064687473455%2F&show_text=false&width=560&t=0" 
          width="100%" height="100%" 
          style="border:none;overflow:hidden" 
          scrolling="no" frameborder="0" 
          allowfullscreen="true" 
          allow="autoplay; clipboard-write; encrypted-media; picture-in-picture; web-share">
        </iframe>
      </body>
      </html>
    ''';
  }

  List<Map<String, dynamic>> getSortedTickets() {
    List<Map<String, dynamic>> sortedList = List.from(myTickets);
    sortedList.sort((a, b) {
      int scoreA = _calculateMatchScore(a['number']);
      int scoreB = _calculateMatchScore(b['number']);
      return scoreB.compareTo(scoreA); 
    });
    return sortedList;
  }

  int _calculateMatchScore(String ticket) {
    if (currentDrawnNumbers.isEmpty) return 0;
    int matches = 0;
    for (int i = 0; i < currentDrawnNumbers.length; i++) {
      if (i < ticket.length && ticket[i] == currentDrawnNumbers[i]) {
        matches++;
      } else {
        break;
      }
    }
    return matches;
  }

  // --- FUNCTION: Fullscreen Video ---
  void _openFullScreenVideo() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: WebViewWidget(controller: _webViewController),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white24,
        child: const Icon(Icons.close, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    )));
  }

  // --- REACTION LOGIC ---
  void _showReactionPicker(Map<String, dynamic> comment) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (ctx) {
        return Stack(
          children: [
            Positioned(
              // Байрлалыг нарийн тооцох боломжтой, энд төвд харууллаа
              bottom: MediaQuery.of(context).viewInsets.bottom + 100,
              left: 20,
              right: 20,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [const BoxShadow(color: Colors.black26, blurRadius: 10)],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: _reactionEmojis.map((emoji) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            comment['reaction'] = emoji;
                          });
                          Navigator.pop(ctx);
                        },
                        child: Text(emoji, style: const TextStyle(fontSize: 28)),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // --- COMMENT MENU LOGIC (Long Press) ---
  void _onCommentLongPress(Map<String, dynamic> comment) {
    bool isMe = comment['isMe'] == true;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2C2C2C),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. ХАРИУЛАХ (Бүгдэд харагдана)
              ListTile(
                leading: const Icon(Icons.reply, color: Colors.white),
                title: const Text("Хариулах", style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _replyingTo = comment;
                  });
                  _commentFocusNode.requestFocus();
                },
              ),
              // 2. ХУУЛАХ (Бүгдэд харагдана)
              ListTile(
                leading: const Icon(Icons.copy, color: Colors.white),
                title: const Text("Хуулах", style: TextStyle(color: Colors.white)),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: comment['text']!));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Сэтгэгдэл хуулагдлаа"), duration: Duration(seconds: 1)),
                  );
                },
              ),
              // 3. ЗАСАХ (Зөвхөн өөрт)
              if (isMe)
                ListTile(
                  leading: const Icon(Icons.edit, color: Colors.white),
                  title: const Text("Засах", style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    _commentController.text = comment['text'];
                    _commentFocusNode.requestFocus();
                    // Засах логикийг энд нэмж болно (ID-аар нь хайж шинэчлэх)
                  },
                ),
              // 4. УСТГАХ (Зөвхөн өөрт)
              if (isMe)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.redAccent),
                  title: const Text("Устгах", style: TextStyle(color: Colors.redAccent)),
                  onTap: () {
                    setState(() {
                      comments.removeWhere((c) => c['id'] == comment['id']);
                    });
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _sendComment() {
    if (_commentController.text.isNotEmpty) {
      setState(() {
        String text = _commentController.text;
        // Хэрэв хариулж байгаа бол prefix нэмэх эсвэл тусад нь хадгалах
        // Энд зүгээр л текст хэлбэрээр нэмлээ
        comments.add({
          "id": DateTime.now().millisecondsSinceEpoch.toString(),
          "user": "Би",
          "text": text,
          "time": "Now",
          "reaction": null,
          "isMe": true,
          "replyTo": _replyingTo != null ? _replyingTo!['user'] : null
        });
        _commentController.clear();
        _replyingTo = null; // Reset reply
      });
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> sortedTickets = getSortedTickets();

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      // AppBar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Шууд дамжуулалт", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        // Admin товчийг УСТГАСАН
      ),
      
      // Үндсэн бүтэц: Column (Дээш доош гүйхгүй)
      body: Column(
        children: [
          // ==========================================
          // 1. VIDEO SECTION (FIXED)
          // ==========================================
          SizedBox(
            height: 240, 
            width: double.infinity,
            child: Stack(
              children: [
                WebViewWidget(controller: _webViewController),
                // Fullscreen Button
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: _openFullScreenVideo,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8)
                      ),
                      child: const Icon(Icons.fullscreen, color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
          ),

          // ==========================================
          // 2. LUCKY NUMBERS & TICKETS (FIXED HEIGHT)
          // ==========================================
          // Энэ хэсэгт бага зэрэг зай хэрэгтэй тул Container ашиглана
          Container(
            padding: const EdgeInsets.only(bottom: 10),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white12, width: 1))
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 // --- АЗЫН ДУГААР (КАРТАНД) ---
                 Center(
                   child: Container(
                     margin: const EdgeInsets.only(top: 15, bottom: 10),
                     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                     decoration: BoxDecoration(
                       color: Colors.black, // Тас хар дэвсгэр
                       borderRadius: BorderRadius.circular(16),
                       border: Border.all(color: Colors.white, width: 1.5), // Цагаан хүрээ
                       boxShadow: [const BoxShadow(color: Colors.white10, blurRadius: 10)]
                     ),
                     child: Column(
                       children: [
                         const Text("АЗЫН ДУГААР", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 12)),
                         const SizedBox(height: 10),
                         Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(maxDigits, (index) {
                              String digit = "";
                              if (index < currentDrawnNumbers.length) {
                                digit = currentDrawnNumbers[index];
                              }
                              return _buildBlackStar(digit, size: 40, fontSize: 16);
                            }),
                          ),
                       ],
                     ),
                   ),
                 ),

                 // --- МИНИЙ СУГАЛАА ---
                 const Padding(
                    padding: EdgeInsets.only(left: 16.0, bottom: 8),
                    child: Text("Миний сугалаанууд", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(
                    height: 140, // Өндрийг тохируулав
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal, 
                      itemCount: sortedTickets.length,
                      itemBuilder: (context, index) {
                        return _buildTicketCard(sortedTickets[index]);
                      },
                    ),
                  ),
              ],
            ),
          ),

          // ==========================================
          // 3. COMMENTS LIST (SCROLLABLE - EXPANDED)
          // ==========================================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text("Сэтгэгдэл", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment = comments[index];
                      return _buildCommentItem(comment);
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // ==========================================
          // 4. INPUT AREA
          // ==========================================
          _buildInputArea(),
        ],
      ),
    );
  }

  // --- WIDGET: Input Area with Reply Preview ---
  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.only(
        left: 12, right: 12, top: 10,
        bottom: MediaQuery.of(context).viewInsets.bottom + 10 // Keyboard safe
      ),
      color: const Color(0xFF121212),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // REPLY PREVIEW
          if (_replyingTo != null)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white24)
              ),
              child: Row(
                children: [
                  const Icon(Icons.reply, color: Colors.white54, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Хариулж байна: ${_replyingTo!['user']}", style: const TextStyle(color: Colors.blueAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                        Text(_replyingTo!['text'], maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _replyingTo = null),
                    child: const Icon(Icons.close, color: Colors.white54, size: 16),
                  )
                ],
              ),
            ),
          
          // INPUT ROW
          Row(
            children: [
              IconButton(onPressed: (){}, icon: const Icon(Icons.emoji_emotions_outlined, color: Colors.white54)),
              Expanded(
                child: TextField(
                  controller: _commentController,
                  focusNode: _commentFocusNode,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Сэтгэгдэл бичих...",
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: Colors.white10,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _sendComment,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
                  child: const Icon(Icons.send, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- WIDGET: Comment Item ---
  Widget _buildCommentItem(Map<String, dynamic> comment) {
    return GestureDetector(
      onLongPress: () => _onCommentLongPress(comment),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        color: Colors.transparent, // Touch area
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AVATAR
            CircleAvatar(
              radius: 16,
              backgroundColor: comment['isMe'] ? Colors.orange : Colors.white12,
              child: Text(comment['user'][0], style: const TextStyle(color: Colors.white, fontSize: 12)),
            ),
            const SizedBox(width: 10),
            
            // TEXT CONTENT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(comment['user'], style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Text(comment['time'], style: const TextStyle(color: Colors.white30, fontSize: 10)),
                    ],
                  ),
                  // Reply indicator inside comment
                  if (comment['replyTo'] != null)
                     Padding(
                       padding: const EdgeInsets.only(top: 2),
                       child: Text("@${comment['replyTo']}", style: const TextStyle(color: Colors.blueAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                     ),
                  const SizedBox(height: 2),
                  Text(comment['text'], style: const TextStyle(color: Colors.white, fontSize: 14)),
                ],
              ),
            ),

            // REACTION HEART
            GestureDetector(
              onLongPress: () => _showReactionPicker(comment),
              onTap: () {
                // Энгийн даралт (Жишээ нь зүгээр like)
                setState(() {
                  if (comment['reaction'] != null) {
                    comment['reaction'] = null;
                  } else {
                    comment['reaction'] = "❤️";
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.only(left: 8, bottom: 8, top: 8),
                child: comment['reaction'] != null
                    ? Text(comment['reaction'], style: const TextStyle(fontSize: 18))
                    : const Icon(Icons.favorite_border, color: Colors.white30, size: 18),
              ),
            )
          ],
        ),
      ),
    );
  }

  // --- WIDGET: Custom Star (Хар өнгөтэй, Цагаан хүрээтэй) ---
  Widget _buildBlackStar(String digit, {double size = 50, double fontSize = 20}) {
    bool hasValue = digit.isNotEmpty;
    
    return Container(
      width: size,
      height: size,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.star_rounded, size: size, color: Colors.white), // Хүрээ
          Icon(Icons.star_rounded, size: size - 3, color: Colors.black), // Доторх
          if (hasValue)
            Text(
              digit,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: fontSize),
            )
          else if (size > 30)
             Text("?", style: TextStyle(color: Colors.white24, fontSize: fontSize, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // --- WIDGET: Ticket Card (Ticket Shape) ---
  Widget _buildTicketCard(Map<String, dynamic> ticketData) {
    String ticketNumber = ticketData['number'];
    String ticketName = ticketData['name'];

    int matchCount = _calculateMatchScore(ticketNumber);
    bool isLeading = matchCount > 0 && matchCount == currentDrawnNumbers.length;

    return ClipPath(
      clipper: TicketClipper(), // Тасалбар хэлбэр оруулагч
      child: Container(
        width: 300, 
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          // Тасалбарын хүрээг ClipPath дотор зурах хэцүү тул энд Border ашиглахгүй
          // Харин сонгогдсон үед дотор нь өнгөөр ялгая
        ),
        child: Stack(
          children: [
            // Background Highlight if Winning
            if (isLeading)
              Positioned.fill(child: Container(color: Colors.amber.withOpacity(0.1))),

            Row(
              children: [
                // 60% IMAGE
                Expanded(
                  flex: 6,
                  child: Image.network(
                    ticketData['image'],
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                // DASHED LINE SEPARATOR
                Container(
                  width: 1,
                  height: double.infinity,
                  color: Colors.white12,
                  child: Column(
                    children: List.generate(20, (i) => Expanded(child: Container(color: i%2==0 ? Colors.transparent : Colors.grey, width: 1))),
                  ),
                ),
                // 40% INFO
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Сугалаа", style: TextStyle(color: Colors.white54, fontSize: 10)),
                        const SizedBox(height: 4),
                        Text(
                          ticketName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isLeading ? Colors.amber : Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                          child: const Text("Тодруулж байна...", style: TextStyle(color: Colors.greenAccent, fontSize: 8)),
                        ),
                        const SizedBox(height: 25),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            // STARS AT BOTTOM
            Positioned(
              bottom: 8,
              left: 10, 
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: List.generate(maxDigits, (index) {
                     String digit = "";
                     if(index < ticketNumber.length) digit = ticketNumber[index];
                     bool isMatch = index < currentDrawnNumbers.length && digit == currentDrawnNumbers[index];
                     
                     return Container(
                       margin: const EdgeInsets.only(right: 2),
                       child: Stack(
                         alignment: Alignment.center,
                         children: [
                           Icon(Icons.star_rounded, size: 24, color: Colors.white),
                           Icon(Icons.star_rounded, size: 20, color: isMatch ? Colors.amber : Colors.black),
                           Text(
                             digit, 
                             style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)
                           ),
                         ],
                       ),
                     );
                  }),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// --- CUSTOM CLIPPER: TICKET SHAPE ---
class TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0.0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0.0);
    path.addOval(Rect.fromCircle(center: Offset(0.0, size.height / 2), radius: 10.0));
    path.addOval(Rect.fromCircle(center: Offset(size.width, size.height / 2), radius: 10.0));
    path.fillType = PathFillType.evenOdd;
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}