import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import '../utils/app_colors.dart';
import '../services/mock_wallet_service.dart';
// import '../screens/change_password_screen.dart'; // Хэрэв ПИН үүсгэх рүү үсрэх бол uncomment хийнэ үү

// Сагсанд буй тасалбарын мэдээллийг хадгалах модель
class TicketItem {
  final String numbers;
  final GlobalKey key; // Screenshot авах түлхүүр
  bool isHiding; // Эффект явж байх үед нуух эсэх

  TicketItem({
    required this.numbers, 
    required this.key, 
    this.isHiding = false
  });
}

class LotteryPurchaseSheet extends StatefulWidget {
  final String priceString;
  final String lotteryTitle;
  final String lotteryId;

  const LotteryPurchaseSheet({
    super.key, 
    required this.priceString,
    required this.lotteryTitle,
    required this.lotteryId,
  });

  @override
  State<LotteryPurchaseSheet> createState() => _LotteryPurchaseSheetState();
}

class _LotteryPurchaseSheetState extends State<LotteryPurchaseSheet> with TickerProviderStateMixin {
  final List<TicketItem> _basketTickets = [];
  
  List<String> _inputValues = List.filled(6, "");
  int _focusedIndex = 0;
  int _unitPrice = 0;

  // Түрүүвчний service
  final MockWalletService _walletService = MockWalletService();

  final TextEditingController _autoCountController = TextEditingController(text: "1");

  // Animation Keys
  final GlobalKey _inputRowKey = GlobalKey(); 
  final GlobalKey _basketListKey = GlobalKey(); 
  
  final List<GlobalKey> _inputKeys = List.generate(6, (index) => GlobalKey());
  final Map<String, GlobalKey> _keypadKeys = {};

  @override
  void initState() {
    super.initState();
    String cleanPrice = widget.priceString.replaceAll(RegExp(r'[^0-9]'), '');
    _unitPrice = int.tryParse(cleanPrice) ?? 0;

    for (var i = 0; i <= 9; i++) {
      _keypadKeys[i.toString()] = GlobalKey();
    }
  }

  @override
  void dispose() {
    _autoCountController.dispose();
    super.dispose();
  }

  // --- HELPER: Screenshot авах ---
  Future<ui.Image?> _captureImage(GlobalKey key) async {
    try {
      final RenderObject? renderObject = key.currentContext?.findRenderObject();
      if (renderObject == null || renderObject is! RenderRepaintBoundary) return null;
      
      final RenderRepaintBoundary boundary = renderObject;
      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      return image;
    } catch (e) {
      debugPrint("Screenshot failed: $e");
      return null;
    }
  }

  String _formatMoney(int amount) {
    return amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }

  // --- DIALOGS ---

  // 1. ҮЛДЭГДЭЛ ХҮРЭЛЦЭХГҮЙ ДИАЛОГ
  void _showInsufficientBalanceDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black54, 
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                width: 320,
                padding: const EdgeInsets.fromLTRB(25, 50, 25, 25),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.white10, width: 1),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.5), offset: const Offset(5, 5), blurRadius: 15),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Үлдэгдэл хүрэлцэхгүй", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    const Text("Уучлаарай, таны түрүүвч дэх үлдэгдэл хүрэлцэхгүй байна.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.5)),
                    const SizedBox(height: 25),
                    Row(
                      children: [
                        Expanded(child: TextButton(onPressed: () => Navigator.pop(ctx), style: TextButton.styleFrom(foregroundColor: Colors.white54), child: const Text("Хаах"))),
                        const SizedBox(width: 15),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(ctx), 
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
                            child: const Text("Цэнэглэх", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Positioned(
                top: -30,
                child: Container(
                  width: 70, height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(colors: [Color(0xFFFF5252), Color(0xFFA70000)]),
                    border: Border.all(color: const Color(0xFF2C2C2C), width: 4),
                  ),
                  child: const Center(child: Icon(Icons.account_balance_wallet_outlined, color: Colors.white, size: 32)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 2. АМЖИЛТТАЙ БОЛСОН ДИАЛОГ (Сайжруулсан дизайн)
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white24, width: 1),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 10)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: Colors.greenAccent, size: 40),
              ),
              const SizedBox(height: 20),
              const Text("Амжилттай!", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text(
                "Таны сугалаа амжилттай баталгаажлаа.\nТа 'Миний сугалаа' хэсгээс хараарай.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white10),
                ),
                child: ValueListenableBuilder<int>(
                  valueListenable: _walletService.balanceNotifier,
                  builder: (context, balance, child) {
                    return Text("Үлдэгдэл: ${_formatMoney(balance)}₮", style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold));
                  },
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx); // Close dialog
                    Navigator.pop(context); // Close sheet
                  },
                  child: const Text("Ойлголоо", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 3. LOGIC: PIN ОРУУЛАХ ДИАЛОГ (Шинэчлэгдсэн)
  void _showPinDialog(int totalPrice) {
    String pin = "";
    bool hasPin = _walletService.hasTransactionPin; // ПИН код байгаа эсэх

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF252525),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          hasPin ? "Гүйлгээний ПИН" : "Анхааруулга", // Гарчиг
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasPin) ...[
              const Text("Гүйлгээ хийхийн тулд 4 оронтой ПИН кодоо оруулна уу.", style: TextStyle(color: Colors.grey, fontSize: 13), textAlign: TextAlign.center),
              const SizedBox(height: 20),
              TextField(
                autofocus: true,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  hintText: "••••",
                  hintStyle: TextStyle(color: Colors.white24),
                  counterText: "",
                  filled: true,
                  fillColor: Color(0xFF151515),
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide(color: Colors.white24)),
                ),
                onChanged: (val) => pin = val,
              ),
            ] else ...[
              // ПИН кодгүй хэрэглэгч
              const Icon(Icons.lock_person, size: 50, color: Colors.orangeAccent),
              const SizedBox(height: 15),
              const Text(
                "Та Гүйлгээний ПИН кодоо үүсгэн үү.",
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                "Аюулгүй байдлын үүднээс гүйлгээ хийхэд ПИН код шаардлагатай.",
                style: TextStyle(color: Colors.grey, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ]
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
                  child: const Text("Цуцлах", style: TextStyle(color: Colors.grey)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: hasPin
                    ? ElevatedButton(
                        // --- DESIGN: ТӨЛӨХ ТОВЧ ---
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black, // Тас хар дэвсгэр
                          foregroundColor: Colors.white, // Цагаан текст
                          elevation: 0,
                          side: const BorderSide(color: Colors.white, width: 1.0), // Цагаан хүрээ
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Жаахан дугуй
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _processPayment(totalPrice, pin);
                        },
                        child: const Text("Төлөх", style: TextStyle(fontWeight: FontWeight.bold)),
                      )
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber, 
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          // Энд тохиргоо руу үсрэх код байж болно.
                          // Одоогоор зүгээр хааж байна.
                        },
                        child: const Text("Ойлголоо", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- LOGIC: ТӨЛБӨР БОЛОВСРУУЛАХ (Service руу хандах) ---
  void _processPayment(int totalPrice, String pin) {
    String allNumbers = _basketTickets.map((t) => t.numbers).join(", ");

    final result = _walletService.buyTicket(
      lotteryId: widget.lotteryId,
      ticketNumbers: allNumbers,
      totalPrice: totalPrice,
      pinCode: pin,
    );

    if (result['success']) {
      // АМЖИЛТТАЙ
      setState(() {
        _basketTickets.clear();
      });
      _showSuccessDialog(); // Сайжруулсан амжилттай диалог
    } else {
      // АЛДАА ГАРСАН
      String errorMsg = result['message'];
      
      // Хэрэв үлдэгдэл хүрэлцэхгүй бол
      if (errorMsg.contains("Үлдэгдэл")) {
        _showInsufficientBalanceDialog();
      } 
      // Хэрэв ПИН буруу бол
      else if (errorMsg.contains("Гүйлгээний нууц үг")) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Гүйлгээний ПИН код буруу байна!"), // Текст өөрчилсөн
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _onPayment() {
    if (_basketTickets.isEmpty) return;
    int totalPrice = _basketTickets.length * _unitPrice;
    _showPinDialog(totalPrice);
  }

  void _updateInputValue(String value, int targetIndex) {
    setState(() {
      _inputValues[targetIndex] = value;

      if (!_inputValues.contains("")) {
        final ticket = _inputValues.join();
        
        final inputContext = _inputRowKey.currentContext;
        if (inputContext != null) {
          final RenderBox inputBox = inputContext.findRenderObject() as RenderBox;
          final startPos = inputBox.localToGlobal(Offset.zero);
          _animateFlyingTicket(ticket, startPos);
        } else {
           _addToBasket(ticket);
        }

        _inputValues = List.filled(6, "");
        _focusedIndex = 0;

      } else {
        if (_focusedIndex < 5) {
          _focusedIndex++;
        }
      }
    });
  }

  // --- ANIMATIONS ---
  void _animateFlyingNumber(String value, int targetIndex) {
    final keyContext = _keypadKeys[value]?.currentContext;
    final inputContext = _inputKeys[targetIndex].currentContext;

    if (keyContext == null || inputContext == null) return;

    final RenderBox keyBox = keyContext.findRenderObject() as RenderBox;
    final RenderBox inputBox = inputContext.findRenderObject() as RenderBox;

    final startOffset = keyBox.localToGlobal(Offset.zero);
    final endOffset = inputBox.localToGlobal(Offset.zero).translate(2, 2);

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) {
        return _FlyingNumberWidget(
          startOffset: startOffset,
          endOffset: endOffset,
          text: value,
          onComplete: () {
            entry.remove();
            _updateInputValue(value, targetIndex);
          },
        );
      },
    );
    Overlay.of(context).insert(entry);
  }

  void _animateFlyingTicket(String ticketNumbers, Offset startPos) {
    final basketContext = _basketListKey.currentContext;
    Offset endPos = Offset.zero;
    
    if (basketContext != null) {
      final RenderBox basketBox = basketContext.findRenderObject() as RenderBox;
      endPos = basketBox.localToGlobal(Offset.zero).translate(20, 0);
    } else {
      final size = MediaQuery.of(context).size;
      endPos = Offset(20, size.height * 0.6);
    }

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) {
        return _FlyingTicketWidget(
          startOffset: startPos,
          endOffset: endPos,
          ticketNumbers: ticketNumbers,
          onComplete: () {
            entry.remove();
            _addToBasket(ticketNumbers);
          },
        );
      },
    );
    Overlay.of(context).insert(entry);
  }

  void _animateRealShatter(int index) async {
    final item = _basketTickets[index];
    final context = item.key.currentContext;
    
    if (context == null) {
      _removeFromBasket(index);
      return;
    }

    final image = await _captureImage(item.key);
    
    if (image == null) {
      _removeFromBasket(index);
      return;
    }

    final RenderBox box = context.findRenderObject() as RenderBox;
    final size = box.size;
    final position = box.localToGlobal(Offset.zero);

    setState(() {
      item.isHiding = true;
    });

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) {
        return _ImageShatterWidget(
          position: position,
          size: size,
          image: image,
          onComplete: () {
            entry.remove();
            image.dispose();
            _removeFromBasket(index); 
          },
        );
      },
    );

    if (mounted) {
      Overlay.of(context).insert(entry);
    }
  }

  void _onKeyTap(String value) {
    _animateFlyingNumber(value, _focusedIndex);
  }

  void _onInputTap(int index) {
    setState(() {
      _focusedIndex = index;
    });
  }

  Future<void> _onAutoFill() async {
    int count = int.tryParse(_autoCountController.text) ?? 1;
    if (count <= 0) count = 1;
    
    final inputContext = _inputRowKey.currentContext;
    Offset startPos = Offset.zero;

    if (inputContext != null) {
       final RenderBox inputBox = inputContext.findRenderObject() as RenderBox;
       startPos = inputBox.localToGlobal(Offset.zero);
    }

    var rng = Random();

    for (int k = 0; k < count; k++) {
      String randomTicket = "";
      for (var i = 0; i < 6; i++) {
        randomTicket += rng.nextInt(10).toString();
      }
      _animateFlyingTicket(randomTicket, startPos);
      await Future.delayed(const Duration(milliseconds: 200));
    }
  }

  void _addToBasket(String ticket) {
    setState(() {
      _basketTickets.insert(0, TicketItem(numbers: ticket, key: GlobalKey())); 
    });
  }

  void _removeFromBasket(int index) {
    if (index >= 0 && index < _basketTickets.length) {
      setState(() {
        _basketTickets.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalPrice = _basketTickets.length * _unitPrice;
    String formattedTotal = _formatMoney(totalPrice);

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: AppColors.darkBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 50,
              height: 5,
              margin: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Header
          Text(
            widget.lotteryTitle,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: ValueListenableBuilder<int>(
              valueListenable: _walletService.balanceNotifier,
              builder: (context, balance, child) {
                return Text("Үлдэгдэл: ${_formatMoney(balance)}₮", 
                  style: const TextStyle(color: Colors.greenAccent, fontSize: 12)
                );
              },
            ),
          ),

          const SizedBox(height: 10),
          const Text(
            "Таны азын тоо",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 20),

          // INPUT FIELDS
          Row(
            key: _inputRowKey, 
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(6, (index) {
              bool isFocused = index == _focusedIndex;
              bool isFilled = _inputValues[index].isNotEmpty;

              BoxDecoration containerDecoration;
              if (isFilled) {
                if (isFocused) {
                  containerDecoration = BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.redAccent, width: 2),
                    boxShadow: [BoxShadow(color: Colors.redAccent.withOpacity(0.5), blurRadius: 10)],
                  );
                } else {
                  containerDecoration = const BoxDecoration();
                }
              } else {
                containerDecoration = BoxDecoration(
                  color: const Color(0xFF151515),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isFocused ? Colors.white : Colors.white10,
                    width: isFocused ? 2 : 1,
                  ),
                  boxShadow: isFocused ? [BoxShadow(color: Colors.white.withOpacity(0.3), blurRadius: 8)] : [],
                );
              }

              return GestureDetector(
                onTap: () => _onInputTap(index),
                child: Container(
                  key: _inputKeys[index],
                  width: 54,
                  height: 54,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: containerDecoration,
                  child: Center(
                    child: isFilled
                        ? StarNumberWidget(text: _inputValues[index], size: 46)
                        : null,
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 20),

          // CONTROLS ROW
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 45),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: ElevatedButton.icon(
                    onPressed: _onAutoFill,
                    icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
                    label: const Text("Автомат бөглөх", style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white, width: 1),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 15),

                Expanded(
                  flex: 1,
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF25252A),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white),
                    ),
                    child: TextField(
                      controller: _autoCountController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(bottom: 2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          // KEYPAD
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _buildKeypadRow(["1", "2", "3", "4", "5"]),
                const SizedBox(height: 15),
                _buildKeypadRow(["6", "7", "8", "9", "0"]),
              ],
            ),
          ),

          const Divider(color: Colors.white10, height: 30),

          // BASKET LIST
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Сагс (${_basketTickets.length})", style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                if (_basketTickets.isNotEmpty)
                  GestureDetector(
                    onTap: () => setState(() => _basketTickets.clear()),
                    child: const Text("Бүгдийг устгах", style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                  ),
              ],
            ),
          ),

          Expanded(
            key: _basketListKey,
            child: _basketTickets.isEmpty
                ? const Center(child: Text("Тасалбар сонгоогүй байна", style: TextStyle(color: Colors.white24)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    itemCount: _basketTickets.length,
                    itemBuilder: (context, index) {
                      final item = _basketTickets[index];
                      
                      return Opacity(
                        opacity: item.isHiding ? 0.0 : 1.0,
                        child: RepaintBoundary(
                          key: item.key,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                            decoration: BoxDecoration(
                              color: const Color(0xFF202025),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: item.numbers.split('').map((char) => Padding(
                                    padding: const EdgeInsets.only(right: 5),
                                    child: StarNumberWidget(text: char, size: 38),
                                  )).toList(),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
                                  onPressed: () {
                                    if (!item.isHiding) {
                                      _animateRealShatter(index);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.fromLTRB(20, 15, 20, 30),
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A1A),
              border: Border(top: BorderSide(color: Colors.white10)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Нийт төлөх дүн", style: TextStyle(color: Colors.white70)),
                    Text("$formattedTotal₮", style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _basketTickets.isEmpty ? null : _onPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 0,
                    ),
                    child: const Text("ТӨЛБӨР ТӨЛӨХ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeypadRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: keys.map((key) => _buildSingleKey(key)).toList(),
    );
  }

  Widget _buildSingleKey(String key) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: InkWell(
        onTap: () => _onKeyTap(key),
        borderRadius: BorderRadius.circular(35),
        child: Container(
          key: _keypadKeys[key],
          width: 55,
          height: 55,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF3A3A40), Color(0xFF15151A)],
            ),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.6), offset: const Offset(2, 3), blurRadius: 4),
              BoxShadow(color: Colors.white.withOpacity(0.1), offset: const Offset(-1, -1), blurRadius: 2),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            key,
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, shadows: [Shadow(color: Colors.black, offset: Offset(1, 1), blurRadius: 2)]),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ВИДЖЕТ: Таван хошуу хэлбэртэй тоо (Дотоод)
// ---------------------------------------------------------------------------
class StarNumberWidget extends StatelessWidget {
  final String text;
  final double size;

  const StarNumberWidget({super.key, required this.text, required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: StarPainter(),
        child: Center(
          child: Text(text, style: TextStyle(color: Colors.white, fontSize: size * 0.4, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

class StarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint fillPaint = Paint()..color = Colors.black..style = PaintingStyle.fill;
    final Paint borderPaint = Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 1.5;

    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double outerRadius = size.width / 2 - 2;
    final double innerRadius = outerRadius / 2.0;

    final Path path = Path();
    double angle = -pi / 2;
    final double step = pi / 5;

    for (int i = 0; i < 10; i++) {
      double r = (i % 2 == 0) ? outerRadius : innerRadius;
      double x = cx + cos(angle) * r;
      double y = cy + sin(angle) * r;
      if (i == 0) path.moveTo(x, y); else path.lineTo(x, y);
      angle += step;
    }
    path.close();
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, borderPaint);
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// АНИМАЦИ (Flying Number, Ticket, Shatter) - Өмнөхтэй ижил
// ---------------------------------------------------------------------------
class _FlyingNumberWidget extends StatefulWidget {
  final Offset startOffset;
  final Offset endOffset;
  final String text;
  final VoidCallback onComplete;

  const _FlyingNumberWidget({required this.startOffset, required this.endOffset, required this.text, required this.onComplete});

  @override
  State<_FlyingNumberWidget> createState() => _FlyingNumberWidgetState();
}

class _FlyingNumberWidgetState extends State<_FlyingNumberWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _animation = Tween<Offset>(begin: widget.startOffset, end: widget.endOffset).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic));
    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Positioned(left: _animation.value.dx, top: _animation.value.dy, child: Material(color: Colors.transparent, child: StarNumberWidget(text: widget.text, size: 48)));
      },
    );
  }
}

class _FlyingTicketWidget extends StatefulWidget {
  final Offset startOffset;
  final Offset endOffset;
  final String ticketNumbers;
  final VoidCallback onComplete;

  const _FlyingTicketWidget({required this.startOffset, required this.endOffset, required this.ticketNumbers, required this.onComplete});

  @override
  State<_FlyingTicketWidget> createState() => _FlyingTicketWidgetState();
}

class _FlyingTicketWidgetState extends State<_FlyingTicketWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _posAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _posAnimation = Tween<Offset>(begin: widget.startOffset, end: widget.endOffset).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: _posAnimation.value.dx,
          top: _posAnimation.value.dy,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                decoration: BoxDecoration(color: const Color(0xFF202025), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white), boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.2), blurRadius: 10)]),
                child: Row(mainAxisSize: MainAxisSize.min, children: widget.ticketNumbers.split('').map((char) => Padding(padding: const EdgeInsets.only(right: 5), child: StarNumberWidget(text: char, size: 38))).toList()),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ImageShatterWidget extends StatefulWidget {
  final Offset position;
  final Size size;
  final ui.Image image;
  final VoidCallback onComplete;

  const _ImageShatterWidget({required this.position, required this.size, required this.image, required this.onComplete});

  @override
  State<_ImageShatterWidget> createState() => _ImageShatterWidgetState();
}

class _ImageShatterWidgetState extends State<_ImageShatterWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_ImageShard> _shards = [];
  final Random _rnd = Random();

  @override
  void initState() {
    super.initState();
    const int cols = 8; const int rows = 2;
    final double partW = widget.size.width / cols;
    final double partH = widget.size.height / rows;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final double startX = c * partW;
        final double startY = r * partH;
        final Rect srcRect = Rect.fromLTWH(startX * 2.0, startY * 2.0, partW * 2.0, partH * 2.0);
        _shards.add(_ImageShard(x: startX, y: startY, vx: (_rnd.nextDouble() - 0.5) * 8, vy: (_rnd.nextDouble() - 1) * 8, angle: 0, vAngle: (_rnd.nextDouble() - 0.5) * 0.4, srcRect: srcRect, width: partW, height: partH));
      }
    }
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _controller.addListener(() {
      setState(() {
        for (var s in _shards) { s.x += s.vx; s.y += s.vy; s.vy += 0.8; s.angle += s.vAngle; }
      });
    });
    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Positioned(left: widget.position.dx, top: widget.position.dy, width: widget.size.width, height: widget.size.height + 500, child: Stack(clipBehavior: Clip.none, children: [CustomPaint(painter: _ShardPainter(image: widget.image, shards: _shards), size: Size(widget.size.width, widget.size.height + 500))]));
  }
}

class _ImageShard {
  double x, y, vx, vy, angle, vAngle; final Rect srcRect; final double width, height;
  _ImageShard({required this.x, required this.y, required this.vx, required this.vy, required this.angle, required this.vAngle, required this.srcRect, required this.width, required this.height});
}

class _ShardPainter extends CustomPainter {
  final ui.Image image; final List<_ImageShard> shards;
  _ShardPainter({required this.image, required this.shards});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();
    for (var shard in shards) {
      canvas.save();
      final double centerX = shard.x + shard.width / 2;
      final double centerY = shard.y + shard.height / 2;
      canvas.translate(centerX, centerY); canvas.rotate(shard.angle); canvas.translate(-centerX, -centerY);
      final Rect dstRect = Rect.fromLTWH(shard.x, shard.y, shard.width, shard.height);
      canvas.drawImageRect(image, shard.srcRect, dstRect, paint);
      canvas.restore();
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}