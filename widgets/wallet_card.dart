import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_colors.dart';
import '../services/mock_wallet_service.dart';

// ==========================================
// UTILS: CARD STYLES & GRADIENTS
// ==========================================

class CardStyle {
  static const List<LinearGradient> gradients = [
    LinearGradient(colors: [Color(0xFFF5F5F5), Color(0xFFBDBDBD)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA000)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    LinearGradient(colors: [Color(0xFFE0E0E0), Color(0xFF909090)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    LinearGradient(colors: [Color(0xFFE0F7FA), Color(0xFF00BCD4)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    LinearGradient(colors: [Color(0xFFF8BBD0), Color(0xFFE91E63)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    LinearGradient(colors: [Colors.red, Colors.orange, Colors.yellow, Colors.green, Colors.blue, Colors.purple], begin: Alignment.topLeft, end: Alignment.bottomRight),
    LinearGradient(colors: [Color(0xFF2196F3), Color(0xFF0D47A1)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    LinearGradient(colors: [Color(0xFF66BB6A), Color(0xFF1B5E20)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    LinearGradient(colors: [Color(0xFFAB47BC), Color(0xFF4A148C)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    LinearGradient(colors: [Color(0xFFEF5350), Color(0xFFB71C1C)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    LinearGradient(colors: [Color(0x66FFFFFF), Color(0x1AFFFFFF)], begin: Alignment.topLeft, end: Alignment.bottomRight),
  ];

  static Color getTextColor(int index) => (index == 0 || index == 2 || index == 3 || index == 10) ? Colors.black87 : Colors.white;
  static bool hasBorder(int index) => index == 10;
}

// ---------------------------------------------------------------------------
// FORMATTER: MN IBAN (MN 12345 1234567890)
// ---------------------------------------------------------------------------
class MnIbanInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text.toUpperCase();
    if (!text.startsWith("MN")) {
      text = "MN${text.replaceAll("MN", "")}"; 
    }
    String digits = text.substring(2).replaceAll(RegExp(r'\D'), '');
    if (digits.length > 15) digits = digits.substring(0, 15);

    StringBuffer buffer = StringBuffer();
    buffer.write("MN "); 

    for (int i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);
      if (i == 4 && digits.length > 5) {
        buffer.write(" "); 
      }
    }

    String formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// ---------------------------------------------------------------------------
// MAIN WIDGET: WALLET CARD
// ---------------------------------------------------------------------------

class WalletCard extends StatefulWidget {
  const WalletCard({super.key});
  @override
  State<WalletCard> createState() => _WalletCardState();
}

class _WalletCardState extends State<WalletCard> with TickerProviderStateMixin {
  bool _isDetailsVisible = true; 
  final MockWalletService _walletService = MockWalletService();
  
  List<CreditCardModel> _localCards = [];
  final Map<String, AnimationController> _cardControllers = {};

  @override
  void initState() {
    super.initState();
    _updateLocalCards();
    _walletService.savedCardsNotifier.addListener(_updateLocalCards);
  }

  @override
  void dispose() {
    _walletService.savedCardsNotifier.removeListener(_updateLocalCards);
    for (var controller in _cardControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateLocalCards() {
    setState(() {
      if (_localCards.length != _walletService.savedCards.length) {
         _localCards = List.from(_walletService.savedCards);
         for (var card in _localCards) {
           if (!_cardControllers.containsKey(card.id)) {
             final controller = AnimationController(
               vsync: this,
               duration: const Duration(milliseconds: 600), 
               value: 0.0, 
             );
             controller.addListener(() {
               setState(() {});
             });
             _cardControllers[card.id] = controller;
           }
         }
      }
    });
  }

  void _onCardTap(CreditCardModel tappedCard) {
    final controller = _cardControllers[tappedCard.id];
    if (controller == null) return;

    bool isCurrentlyOut = controller.value > 0.5;

    if (isCurrentlyOut) {
      controller.reverse().then((_) {
        setState(() {
          _localCards.remove(tappedCard);
          _localCards.add(tappedCard);
        });
      });
    } else {
      _cardControllers.forEach((id, ctrl) {
        if (id != tappedCard.id && ctrl.value > 0.1) {
          ctrl.reverse();
        }
      });
      controller.forward();
    }
  }

  double _calculateTopPosition(double value, int index, int totalCards) {
    int itemsInFront = totalCards - 1 - index;
    double insideTop = 90.0 - (itemsInFront * 25.0);
    if (insideTop < 20) insideTop = 20;

    const double apexTop = -80.0; 
    const double outsideTop = 160.0; 

    if (value <= 0.5) {
      double t = value / 0.5;
      t = Curves.easeOutCubic.transform(t); 
      return insideTop + (apexTop - insideTop) * t;
    } else {
      double t = (value - 0.5) / 0.5;
      t = Curves.bounceOut.transform(t); 
      return apexTop + (outsideTop - apexTop) * t;
    }
  }

  double _calculateScale(double value) {
    if (value <= 0.5) {
      return 0.9 + (0.2 * (value / 0.5)); 
    } else {
      return 1.1 - (0.1 * ((value - 0.5) / 0.5)); 
    }
  }

  double _calculateAngle(double value) {
    if (value < 0.5) {
       return (value * 0.2); 
    } 
    return (1.0 - value) * 0.1; 
  }

  String _formatMoney(int amount) => amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');

  @override
  Widget build(BuildContext context) {
    List<Widget> backLayerCards = [];
    List<Widget> frontLayerCards = [];

    for (int i = 0; i < _localCards.length; i++) {
      final card = _localCards[i];
      final controller = _cardControllers[card.id]!;
      
      final topPos = _calculateTopPosition(controller.value, i, _localCards.length);
      final scale = _calculateScale(controller.value);
      final angle = _calculateAngle(controller.value);

      Widget cardWidget = Positioned(
        top: topPos,
        left: 0, 
        right: 0,
        child: Center(
          child: Transform.rotate(
            angle: angle,
            child: Transform.scale(
              scale: scale,
              child: HomeCardItem(
                card: card,
                isFloating: controller.value > 0.8,
                onTap: () => _onCardTap(card),
              ),
            ),
          ),
        ),
      );

      if (controller.value < 0.5) {
        backLayerCards.add(cardWidget);
      } else {
        frontLayerCards.add(cardWidget);
      }
    }

    return Container(
      height: 420, 
      padding: const EdgeInsets.only(top: 40),
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none, 
        children: [
          // LAYER 1: BACK CARDS
          Stack(
            clipBehavior: Clip.none,
            children: backLayerCards,
          ),

          // LAYER 2: POCKET
          Container(
            height: 200, 
            width: double.infinity,
            margin: const EdgeInsets.only(top: 100), 
            padding: const EdgeInsets.only(left: 10, right: 10, top: 20, bottom: 25),
            decoration: BoxDecoration(
              color: const Color(0xFF222222), 
              borderRadius: const BorderRadius.vertical(top: Radius.elliptical(300, 40), bottom: Radius.circular(30)), 
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.8), blurRadius: 20, offset: const Offset(0, -5))
              ]
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // CENTERED BALANCE & POINTS ROW
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // LEFT: POINTS
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10, bottom: 2), // Align adjustment
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text("Таны оноо:", style: TextStyle(color: Colors.grey, fontSize: 10)),
                            InkWell(
                              onTap: () => _showPointExchangeDialog(context),
                              child: ValueListenableBuilder(
                                valueListenable: _walletService.pointsNotifier,
                                builder: (ctx, pts, _) => Row(
                                  children: [
                                    const Icon(Icons.star, color: Colors.amber, size: 16),
                                    const SizedBox(width: 4),
                                    Text(_isDetailsVisible ? "$pts" : "****", style: const TextStyle(color: Colors.amber, fontSize: 16, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // CENTER: BALANCE
                    Expanded(
                      flex: 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Text("Үлдэгдэл:", style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ValueListenableBuilder<int>(
                            valueListenable: _walletService.balanceNotifier,
                            builder: (context, balance, child) {
                              return Text(
                                _isDetailsVisible ? "${_formatMoney(balance)} ₮" : "****** ₮", 
                                style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              );
                            }
                          ),
                        ],
                      ),
                    ),

                    // RIGHT: EYE ICON (Aligned with Bottom/Points)
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10, bottom: 2), // Aligned with points row
                          child: IconButton(
                            icon: Icon(_isDetailsVisible ? Icons.visibility : Icons.visibility_off, color: Colors.white54, size: 22),
                            onPressed: () => setState(() => _isDetailsVisible = !_isDetailsVisible),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 25),
                
                // ACTION BUTTONS (Transactions & Top Up)
                Row(children: [
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.history, 
                      label: "Гүйлгээ", 
                      onTap: () => _showAmountSheet(context, isExpense: true),
                    )
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.add_circle_outline, 
                      label: "Цэнэглэх", 
                      onTap: () => _showAmountSheet(context, isExpense: false),
                    )
                  ),
                ]),
              ],
            ),
          ),

          // LAYER 3: FRONT CARDS
          IgnorePointer(
            ignoring: false, 
            child: Stack(
              clipBehavior: Clip.none,
              children: frontLayerCards,
            ),
          ),
        ],
      ),
    );
  }

  // Dark Grey Button with Light Grey Border and White Text
  Widget _buildActionButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap, 
      borderRadius: BorderRadius.circular(15), 
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12), 
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2C), // Dark Grey
          borderRadius: BorderRadius.circular(15), 
          border: Border.all(color: Colors.white24) // Light Grey Border
        ), 
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20), // White Icon
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)), // White Text
          ],
        )
      )
    );
  }

  void _showAmountSheet(BuildContext context, {required bool isExpense}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      builder: (context) => _AmountBottomSheet(isExpense: isExpense),
    );
  }

  void _showPointExchangeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _PointExchangeDialog(),
    );
  }
}

// ==========================================
// CARD ITEM
// ==========================================
class HomeCardItem extends StatefulWidget {
  final CreditCardModel card;
  final bool isFloating;
  final VoidCallback onTap;
  const HomeCardItem({super.key, required this.card, required this.isFloating, required this.onTap});
  @override
  State<HomeCardItem> createState() => _HomeCardItemState();
}
class _HomeCardItemState extends State<HomeCardItem> with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  Timer? _longPressTimer;
  bool _isFlipped = false;
  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _flipAnimation = CurvedAnimation(parent: _flipController, curve: Curves.easeInOutBack);
  }
  void _startFlipTimer() {
    if (!widget.isFloating) return;
    _longPressTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        if (_isFlipped) {
          _flipController.reverse();
        } else {
          _flipController.forward();
        }
        setState(() => _isFlipped = !_isFlipped);
        HapticFeedback.mediumImpact();
      }
    });
  }
  void _cancelTimer() => _longPressTimer?.cancel();
  @override
  void didUpdateWidget(HomeCardItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFloating && !widget.isFloating && _isFlipped) {
       _flipController.reverse(); _isFlipped = false;
    }
  }
  @override
  void dispose() { _flipController.dispose(); _longPressTimer?.cancel(); super.dispose(); }
  String _maskCardNumber(String num) => num.length != 16 ? num : "**** ${num.substring(4, 8)} **** **${num.substring(14)}";
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onLongPressDown: (_) => _startFlipTimer(),
      onLongPressUp: _cancelTimer,
      onLongPressCancel: _cancelTimer,
      child: AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, child) {
          final angle = _flipAnimation.value * pi;
          final transform = Matrix4.identity()..setEntry(3, 2, 0.001)..rotateY(angle);
          return Transform(transform: transform, alignment: Alignment.center, child: SizedBox(width: 300, height: 180, child: _flipAnimation.value < 0.5 ? _buildFront() : Transform(alignment: Alignment.center, transform: Matrix4.identity()..rotateY(pi), child: _buildBack())));
        },
      ),
    );
  }
  Widget _buildCardBase({required Widget child}) {
    Color txtColor = CardStyle.getTextColor(widget.card.colorIndex);
    return Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), gradient: CardStyle.gradients[widget.card.colorIndex], border: Border.all(color: CardStyle.hasBorder(widget.card.colorIndex) ? Colors.white30 : Colors.transparent, width: 1), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 5))]), child: DefaultTextStyle(style: TextStyle(color: txtColor, fontFamily: 'Courier'), child: child));
  }
  Widget _buildFront() {
    Color txtColor = CardStyle.getTextColor(widget.card.colorIndex);
    return _buildCardBase(child: Stack(children: [Positioned(top: 0, left: 0, child: Text("AndSoft LLC", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: txtColor))), Positioned(top: 0, right: 0, child: Icon(Icons.wifi, color: txtColor.withOpacity(0.7), size: 24)), Positioned(top: 35, left: 0, child: Container(width: 45, height: 35, decoration: BoxDecoration(color: const Color(0xFFD4AF37), borderRadius: BorderRadius.circular(6)))), Positioned(bottom: 45, left: 0, child: Text(_maskCardNumber(widget.card.cardNumber), style: TextStyle(fontSize: 20, letterSpacing: 3, color: txtColor, fontWeight: FontWeight.bold))), Positioned(bottom: 0, left: 0, child: Text(widget.card.holderName, style: TextStyle(fontSize: 14, letterSpacing: 1.5, fontWeight: FontWeight.w600, color: txtColor.withOpacity(0.8)))), Positioned(bottom: 0, right: 0, child: Text("VISA", style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, fontSize: 22, color: txtColor)))]));
  }
  Widget _buildBack() {
    Color txtColor = CardStyle.getTextColor(widget.card.colorIndex);
    return _buildCardBase(child: Stack(children: [Positioned(top: 10, left: 0, right: 0, child: Container(height: 40, color: Colors.black87)), Positioned(top: 60, right: 20, child: Row(children: [const Text("CVV ", style: TextStyle(fontSize: 10)), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2), color: Colors.white, child: const Text("***", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)))])), Positioned(bottom: 20, left: 20, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("VALID THRU", style: TextStyle(fontSize: 8)), Text(widget.card.expiryDate, style: const TextStyle(fontSize: 16))])), Positioned(bottom: 10, right: 10, child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text("Verified by", style: TextStyle(color: txtColor.withOpacity(0.7), fontSize: 8)), Text("VISA", style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, fontSize: 18, color: txtColor))]))]));
  }
}
class CardNumberInputFormatter extends TextInputFormatter {
  @override TextEditingValue formatEditUpdate(TextEditingValue o, TextEditingValue n) { var t=n.text.replaceAll(RegExp(r'\D'),''); if(t.length>16)t=t.substring(0,16); var b=StringBuffer(); for(int i=0;i<t.length;i++){b.write(t[i]); if((i+1)%4==0&&i+1!=t.length)b.write(' ');} var s=b.toString(); return n.copyWith(text:s,selection:TextSelection.collapsed(offset:s.length)); }
}
class CardNameInputFormatter extends TextInputFormatter {
  @override TextEditingValue formatEditUpdate(TextEditingValue o, TextEditingValue n) => n.copyWith(text:n.text.toUpperCase().replaceAll(RegExp(r'[^A-Z\-\.]'),''),selection:TextSelection.collapsed(offset:n.text.length));
}
class ExpiryDateInputFormatter extends TextInputFormatter {
  @override TextEditingValue formatEditUpdate(TextEditingValue o, TextEditingValue n) { if(n.text.contains(RegExp(r'[^0-9/]')))return o; var t=n.text.replaceAll('/',''); if(t.length>4)t=t.substring(0,4); if(n.selection.baseOffset<o.selection.baseOffset)return n; var b=StringBuffer(); for(int i=0;i<t.length;i++){ int d=int.parse(t[i]); if(i==0&&d>1){b.write('0$d/');continue;} else if(i==1&&int.parse(t.substring(0,2))>12)return o; if(i==2&&d>3){b.write('0$d');continue;} else if(i==3&&int.parse(t.substring(2,4))>31)return o; b.write(t[i]); if(i==1&&t.length>2) {
    b.write('/');
  } else if(i==1&&t.length==2&&!o.text.endsWith('/'))b.write('/'); } return n.copyWith(text:b.toString(),selection:TextSelection.collapsed(offset:b.length)); }
}
class StampableCardItem extends StatefulWidget {
  final CreditCardModel card; final bool isSelected; final VoidCallback onTap;
  const StampableCardItem({super.key, required this.card, required this.isSelected, required this.onTap});
  @override State<StampableCardItem> createState() => _StampableCardItemState();
}
class _StampableCardItemState extends State<StampableCardItem> with TickerProviderStateMixin {
  late AnimationController _c; late Animation<double> _s, _o;
  @override void initState() { super.initState(); _c=AnimationController(vsync:this,duration:const Duration(milliseconds:1000)); _s=TweenSequence([TweenSequenceItem(tween:Tween(begin:3.0,end:1.0).chain(CurveTween(curve:Curves.bounceOut)),weight:40),TweenSequenceItem(tween:ConstantTween(1.0),weight:20),TweenSequenceItem(tween:Tween(begin:1.0,end:1.5).chain(CurveTween(curve:Curves.easeIn)),weight:40)]).animate(_c); _o=TweenSequence([TweenSequenceItem(tween:ConstantTween(1.0),weight:80),TweenSequenceItem(tween:Tween(begin:1.0,end:0.0),weight:20)]).animate(_c); if(widget.isSelected)_c.value=1.0; }
  @override void didUpdateWidget(StampableCardItem o) { super.didUpdateWidget(o); if(widget.isSelected&&!o.isSelected)_c.forward(from:0); if(!widget.isSelected&&o.isSelected)_c.reset(); }
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => GestureDetector(onTap:widget.onTap, behavior:HitTestBehavior.opaque, child:Stack(alignment:Alignment.center, clipBehavior:Clip.none, children:[HomeCardItem(card:widget.card, isFloating:false, onTap:widget.onTap), AnimatedBuilder(animation:_c, builder:(c,_) => AnimatedOpacity(opacity:widget.isSelected&&(_c.value>0.4||_c.isCompleted)?1:0, duration:const Duration(milliseconds:200), child:Transform.rotate(angle:-0.2, child:Container(padding:const EdgeInsets.symmetric(horizontal:10, vertical:5), decoration:BoxDecoration(border:Border.all(color:Colors.greenAccent,width:3), borderRadius:BorderRadius.circular(8)), child:Row(mainAxisSize:MainAxisSize.min, children:[const Icon(Icons.verified, color:Colors.greenAccent, size:24), const SizedBox(width:5), Text("AndSoft LLC", style:TextStyle(color:Colors.greenAccent, fontWeight:FontWeight.w900, fontFamily:'Courier', fontSize:14, letterSpacing:1.2))]))))), AnimatedBuilder(animation:_c, builder:(c,_) => _c.isDismissed||_c.isCompleted ? const SizedBox.shrink() : Opacity(opacity:_o.value, child:Transform.scale(scale:_s.value, alignment:Alignment.center, child:Transform.rotate(angle:-0.2, child:Stack(alignment:Alignment.center, children:[Container(width:140, height:50, decoration:BoxDecoration(color:const Color(0xFF424242), borderRadius:BorderRadius.circular(10), boxShadow:[BoxShadow(color:Colors.black.withOpacity(0.6), blurRadius:15, offset:const Offset(0,10))])), Padding(padding:const EdgeInsets.only(bottom:60), child:Container(width:25, height:60, decoration:BoxDecoration(gradient:const LinearGradient(colors:[Color(0xFF8D6E63), Color(0xFF3E2723)]), borderRadius:BorderRadius.circular(5)))), Padding(padding:const EdgeInsets.only(bottom:120), child:Container(width:50, height:30, decoration:BoxDecoration(color:const Color(0xFF3E2723), borderRadius:BorderRadius.circular(15))))])))))]));
}

// ==========================================
// AMOUNT SHEET (Used for TopUp & Transactions)
// ==========================================

class _AmountBottomSheet extends StatefulWidget {
  final bool isExpense; // true = Гүйлгээ, false = Цэнэглэх
  const _AmountBottomSheet({required this.isExpense});
  @override
  State<_AmountBottomSheet> createState() => _AmountBottomSheetState();
}

class _AmountBottomSheetState extends State<_AmountBottomSheet> {
  String _amount = "0";
  void _onKeyTap(String value) => setState(() => _amount = _amount == "0" ? value : (_amount.length < 9 ? _amount + value : _amount));
  void _onBackspace() => setState(() => _amount = _amount.length > 1 ? _amount.substring(0, _amount.length - 1) : "0");
  
  void _proceed() {
    int value = int.tryParse(_amount) ?? 0;
    
    // Limits
    int min = 100;
    int max = widget.isExpense ? 10000000 : 10000000; // Updated limit
    
    if (value < min) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Хамгийн багадаа $min₮"), backgroundColor: Colors.red)); return; }
    if (value > max) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Хамгийн ихдээ ${max ~/ 1000000} сая ₮"), backgroundColor: Colors.red)); return; }
    
    if (value > 0) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => _PaymentMethodsScreen(amount: value, isExpense: widget.isExpense)));
    }
  }

  @override
  Widget build(BuildContext context) {
    String title = widget.isExpense ? "Гүйлгээ хийх" : "Данс цэнэглэх";
    String btnText = widget.isExpense ? "Гүйлгээ хийх" : "Цэнэглэх";

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(color: AppColors.darkBackground, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      child: Column(children: [
        Center(child: Container(width: 50, height: 5, margin: const EdgeInsets.symmetric(vertical: 15), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)))),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Align(alignment: Alignment.centerLeft, child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)))),
        const SizedBox(height: 20),
        Container(margin: const EdgeInsets.symmetric(horizontal: 20), padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: const Color(0xFF202025), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(widget.isExpense ? "Шилжүүлэх дүн" : "Цэнэглэх дүн", style: const TextStyle(color: Colors.grey, fontSize: 12)), const SizedBox(height: 10), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(_amount.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},'), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)), const Text("₮", style: TextStyle(color: Colors.grey, fontSize: 32))])])),
        const SizedBox(height: 20),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 20), 
          child: SizedBox(width: double.infinity, height: 55, 
            child: ElevatedButton(
              onPressed: int.parse(_amount) > 0 ? _proceed : null, 
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, // Тас хар өнгө
                foregroundColor: Colors.white, // Цагаан текст
                side: const BorderSide(color: Colors.white, width: 1.5), // Цагаан хүрээ
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
              ), 
              child: Text(btnText, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
            )
          )
        ),
        const Spacer(),
        Container(color: const Color(0xFF151515), padding: const EdgeInsets.only(bottom: 30, top: 10), child: Column(children: [_buildKeyRow(['1', '2', '3']), _buildKeyRow(['4', '5', '6']), _buildKeyRow(['7', '8', '9']), Row(children: [_buildKeyBtn('.', flex: 1), _buildKeyBtn('0', flex: 1), Expanded(child: InkWell(onTap: _onBackspace, child: const SizedBox(height: 60, child: Center(child: Icon(Icons.backspace_outlined, color: Colors.white)))))])])),
      ]),
    );
  }
  Widget _buildKeyRow(List<String> keys) => Row(children: keys.map((k) => _buildKeyBtn(k)).toList());
  Widget _buildKeyBtn(String val, {int flex = 1}) {
    if (val == '.') return Expanded(flex: flex, child: const SizedBox(height: 60));
    return Expanded(flex: flex, child: InkWell(onTap: () => _onKeyTap(val), child: SizedBox(height: 60, child: Center(child: Text(val, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w500))))));
  }
}

// ==========================================
// PAYMENT SCREEN
// ==========================================

class _PaymentMethodsScreen extends StatefulWidget {
  final int amount;
  final bool isExpense;
  const _PaymentMethodsScreen({required this.amount, required this.isExpense});
  @override
  State<_PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<_PaymentMethodsScreen> {
  final MockWalletService _walletService = MockWalletService();
  final ScrollController _scrollController = ScrollController();
  
  bool _showTitleInAppBar = false;
  int? _selectedCardIndex;
  String? _selectedAccountId; // Шинэ: Данс сонгох
  
  // Collapsible States
  bool _isCardsExpanded = false;
  bool _isBankAppsExpanded = false;
  bool _isAccountsExpanded = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset > 80 && !_showTitleInAppBar) {
        setState(() => _showTitleInAppBar = true);
      } else if (_scrollController.offset <= 80 && _showTitleInAppBar) {
        setState(() => _showTitleInAppBar = false);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _formatMoney(int amount) => amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');

  // isNumeric: true бол PIN (4 тоо), false бол Login Password (text)
  Future<bool> _showPasswordDialog(String title, bool Function(String) validator, {bool isNumeric = true}) async {
    String input = "";
    return await showDialog<bool>(context: context, barrierDismissible: false, builder: (ctx) => Dialog(
      backgroundColor: const Color(0xFF202025), 
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), 
      child: Padding(
        padding: const EdgeInsets.all(25.0), 
        child: Column(
          mainAxisSize: MainAxisSize.min, 
          children: [
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)), 
            const SizedBox(height: 30), 
            TextField(
              autofocus: true, 
              keyboardType: isNumeric ? TextInputType.number : TextInputType.text, 
              obscureText: true, 
              style: const TextStyle(color: Colors.white, letterSpacing: 8, fontSize: 24, fontWeight: FontWeight.bold), 
              textAlign: TextAlign.center, 
              decoration: InputDecoration(
                hintText: isNumeric ? "••••" : "******", 
                hintStyle: const TextStyle(color: Colors.white38, letterSpacing: 8), 
                enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white54, width: 2)), 
                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 2))
              ), 
              onChanged: (val) => input = val, 
              inputFormatters: isNumeric ? [LengthLimitingTextInputFormatter(4)] : [] // Хэрэв Login Password бол урт хязгаарлахгүй
            ), 
            const SizedBox(height: 40), 
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Болих", style: TextStyle(color: Colors.grey, fontSize: 16))), 
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, foregroundColor: Colors.white, 
                  side: const BorderSide(color: Colors.white, width: 1.5), 
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12), 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                ), 
                onPressed: () => validator(input) ? Navigator.pop(ctx, true) : ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Нууц үг буруу!"), backgroundColor: Colors.red)), 
                child: const Text("Баталгаажуулах", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
              )
            ])
          ]
        )
      )
    )) ?? false;
  }

  Future<bool> _showConfirmationDialog(String msg) async {
    return await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(backgroundColor: const Color(0xFF202025), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), title: const Row(children: [Icon(Icons.warning_amber_rounded, color: Colors.amber), SizedBox(width: 10), Text("Анхааруулга", style: TextStyle(color: Colors.white))]), content: Text(msg, style: const TextStyle(color: Colors.white70)), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Үгүй", style: TextStyle(color: Colors.grey))), ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red), onPressed: () => Navigator.pop(ctx, true), child: const Text("Тийм, устгах", style: TextStyle(color: Colors.white)))])) ?? false;
  }

  void _processTransaction() async {
    // Check function: Returns {success, message}
    Future<Map<String, dynamic>> checkTransaction() async {
      await Future.delayed(const Duration(seconds: 4)); // Mock network delay
      
      if (widget.isExpense) {
        // Гүйлгээ: Үлдэгдэл шалгах
        return _walletService.deductBalanceResult(widget.amount, itemName: "Гүйлгээ");
      } else {
        // Цэнэглэлт: Гадны системийг шалгах (Mock)
        return _walletService.addBalance(widget.amount);
      }
    }

    // Show Dialog with Check Logic
    showDialog(
      context: context, 
      barrierDismissible: false, 
      builder: (ctx) => _PaymentProcessingDialog(onCheck: checkTransaction)
    ).then((result) {
      if (result == true && mounted) {
        Navigator.of(context).pop(); 
        Navigator.of(context).pop(); 
      }
    });
  }

  void _handlePayment() async {
    if (_selectedCardIndex == null && _selectedAccountId == null) return;
    
    // Payment confirmation uses Transaction PIN (0000)
    if (await _showPasswordDialog("Гүйлгээний нууц үг", _walletService.validateTransactionPin, isNumeric: true)) {
      _processTransaction();
    }
  }

  // --- CARD FORM ---
  void _showCardFormDialog({CreditCardModel? existingCard}) {
    final numberController = TextEditingController(text: existingCard?.cardNumber ?? "");
    final nameController = TextEditingController(text: existingCard?.holderName ?? "");
    final expiryController = TextEditingController(text: existingCard?.expiryDate ?? "");
    final cvvController = TextEditingController(text: existingCard?.cvv ?? "");
    
    CreditCardModel currentPreview = existingCard ?? CreditCardModel(
      id: "preview", cardNumber: "0000000000000000", holderName: "CARD HOLDER", 
      expiryDate: "MM/DD", cvv: "***", type: "VISA", colorIndex: 0
    );
    int selectedColor = currentPreview.colorIndex;

    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (context, setState) {
      void updatePreview() {
        currentPreview = CreditCardModel(
          id: "preview", 
          cardNumber: numberController.text.isEmpty ? "0000000000000000" : numberController.text.replaceAll(' ', ''), 
          holderName: nameController.text.isEmpty ? "CARD HOLDER" : nameController.text, 
          expiryDate: expiryController.text.isEmpty ? "MM/DD" : expiryController.text, 
          cvv: cvvController.text.isEmpty ? "***" : cvvController.text, 
          type: (numberController.text.startsWith('4')) ? "VISA" : "Mastercard", 
          colorIndex: selectedColor
        );
      }

      return AlertDialog(
        backgroundColor: const Color(0xFF202025),
        insetPadding: const EdgeInsets.symmetric(horizontal: 10),
        contentPadding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(existingCard == null ? "Карт холбох" : "Карт засах", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: SizedBox(width: 280, child: HomeCardItem(card: currentPreview, isFloating: true, onTap: (){}))),
                const SizedBox(height: 20),
                _buildDialogInput(controller: numberController, label: "Картын дугаар*", hint: "---- ---- ---- ----", formatter: CardNumberInputFormatter(), inputType: TextInputType.number, length: 19, onChanged: (_) => setState(() => updatePreview())),
                const SizedBox(height: 15),
                _buildDialogInput(controller: nameController, label: "Карт эзэмшигчийн нэр*", hint: "Name on Card", formatter: CardNameInputFormatter(), onChanged: (_) => setState(() => updatePreview())),
                const SizedBox(height: 15),
                Row(children: [
                  Expanded(child: _buildDialogInput(controller: expiryController, label: "Хүчинтэй хугацаа*", hint: "MM/DD", formatter: ExpiryDateInputFormatter(), length: 5, onChanged: (_) => setState(() => updatePreview()))),
                  const SizedBox(width: 15),
                  Expanded(child: _buildDialogInput(controller: cvvController, label: "CVV код*", hint: "***", inputType: TextInputType.number, length: 3, isObscure: true, onChanged: (_) => setState(() => updatePreview()))),
                ]),
                const SizedBox(height: 20),
                const Text("Картын өнгө", style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 10),
                Wrap(spacing: 10, runSpacing: 10, children: List.generate(CardStyle.gradients.length, (index) => GestureDetector(onTap: () => setState(() { selectedColor = index; updatePreview(); }), child: Container(width: 35, height: 35, decoration: BoxDecoration(shape: BoxShape.circle, gradient: CardStyle.gradients[index], border: selectedColor == index ? Border.all(color: Colors.white, width: 2) : null, boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)]))))),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Болих", style: TextStyle(color: Colors.grey))),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)), onPressed: () async {
            if (numberController.text.replaceAll(' ', '').length != 16) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Картын дугаар 16 орон байх ёстой!"))); return; }
            if (cvvController.text.length != 3) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("CVV код 3 орон байх ёстой!"))); return; }
            if (nameController.text.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Нэрээ оруулна уу!"))); return; }
            if (existingCard != null) {
              _walletService.editCard(existingCard.id, numberController.text.replaceAll(' ', ''), nameController.text, expiryController.text, cvvController.text, selectedColor);
              Navigator.pop(ctx);
            } else {
              _walletService.addCard(numberController.text.replaceAll(' ', ''), nameController.text, expiryController.text, cvvController.text, selectedColor);
              Navigator.pop(ctx);
              setState(() {});
            }
          }, child: const Text("Хадгалах", style: TextStyle(color: Colors.black))),
        ],
      );
    }));
  }

  // --- BANK ACCOUNT FORM ---
  void _showBankAccountForm({BankAccountModel? existingAccount}) {
    final nameController = TextEditingController(text: existingAccount?.bankName ?? "");
    final ibanController = TextEditingController(text: existingAccount?.ibanNumber ?? "");
    String selectedLogo = existingAccount?.logoAsset ?? "khan_bank.png";
    Color selectedColor = existingAccount?.color ?? Colors.green;
    
    final List<Map<String, dynamic>> banks = [
      {"name": "Khan Bank", "logo": "khan_bank.png", "color": Colors.green},
      {"name": "TDB", "logo": "TDB.png", "color": Colors.blue},
      {"name": "Golomt", "logo": "golomt.png", "color": Colors.blueGrey},
      {"name": "State Bank", "logo": "state_bank.png", "color": Colors.red},
      {"name": "M Bank", "logo": "M_bank.png", "color": Colors.teal},
      {"name": "Xac Bank", "logo": "khas_bank.png", "color": Colors.yellow[700]},
    ];

    if (nameController.text.isEmpty) nameController.text = banks[0]['name'];

    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (context, setState) {
      return AlertDialog(
        backgroundColor: const Color(0xFF202025),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(existingAccount == null ? "Данс нэмэх" : "Данс засах", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Банк сонгох", style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: banks.map((bank) {
                  bool isSelected = selectedLogo == bank['logo'];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedLogo = bank['logo'];
                        selectedColor = bank['color'];
                        nameController.text = bank['name'];
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 15),
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
                        borderRadius: BorderRadius.circular(12)
                      ),
                      child: Column(
                        children: [
                          ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.asset("assets/bank_logos/${bank['logo']}", width: 40, height: 40, fit: BoxFit.cover)),
                          const SizedBox(height: 5),
                          Text(bank['name'], style: const TextStyle(color: Colors.white, fontSize: 10))
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            _buildDialogInput(
              controller: ibanController, 
              label: "Дансны дугаар*", 
              hint: "MN 12345 1234567890", 
              inputType: TextInputType.number, 
              formatter: MnIbanInputFormatter(),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Болих", style: TextStyle(color: Colors.grey))),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.white), onPressed: () {
            if (ibanController.text.length < 5) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Дансны дугаараа оруулна уу!"))); return; }
            
            if (existingAccount != null) {
              _walletService.editBankAccount(existingAccount.id, nameController.text, selectedLogo, ibanController.text, selectedColor);
            } else {
              _walletService.addBankAccount(nameController.text, selectedLogo, ibanController.text, selectedColor);
            }
            Navigator.pop(ctx);
          }, child: const Text("Хадгалах", style: TextStyle(color: Colors.black))),
        ],
      );
    }));
  }

  Widget _buildDialogInput({required TextEditingController controller, required String label, required String hint, TextInputFormatter? formatter, TextInputType inputType = TextInputType.text, int? length, bool isObscure = false, Function(String)? onChanged}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)), const SizedBox(height: 5), Container(padding: const EdgeInsets.symmetric(horizontal: 15), decoration: BoxDecoration(color: const Color(0xFF2C2C35), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white10)), child: TextField(controller: controller, obscureText: isObscure, keyboardType: inputType, inputFormatters: [if (formatter != null) formatter, if (length != null) LengthLimitingTextInputFormatter(length)], onChanged: onChanged, style: const TextStyle(color: Colors.white), decoration: InputDecoration(border: InputBorder.none, hintText: hint, hintStyle: const TextStyle(color: Colors.white24))))]);
  }

  void _deleteCard(CreditCardModel card) async {
    if (!await _showConfirmationDialog("Та энэ картыг устгахдаа итгэлтэй байна уу?")) return;
    // Устгахдаа Login Password ашиглана (isNumeric: false)
    if (await _showPasswordDialog("Нэвтрэх нууц үг", _walletService.validateLoginPassword, isNumeric: false)) {
      _walletService.deleteCard(card.id);
      setState(() => _selectedCardIndex = null);
    }
  }

  void _deleteBankAccount(BankAccountModel account) async {
    if (!await _showConfirmationDialog("Та энэ дансыг устгахдаа итгэлтэй байна уу?")) return;
    // Устгахдаа Login Password ашиглана (isNumeric: false)
    if (await _showPasswordDialog("Нэвтрэх нууц үг", _walletService.validateLoginPassword, isNumeric: false)) {
      _walletService.deleteBankAccount(account.id);
      setState(() => _selectedAccountId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground, 
        elevation: 0, 
        title: _showTitleInAppBar ? Text("${_formatMoney(widget.amount)}₮", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)) : null,
        centerTitle: false,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context))
      ),
      body: Column(children: [
        Expanded(child: ScrollConfiguration(behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false), 
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(), 
          child: Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          
          Text("${_formatMoney(widget.amount)}₮", style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)), 
          Text(widget.isExpense ? "Гүйлгээ хийх" : "Данс цэнэглэх", style: const TextStyle(color: Colors.grey)), 
          const SizedBox(height: 30),

          // 1. BANK CARDS SECTION
          GestureDetector(onTap: () => setState(() => _isCardsExpanded = !_isCardsExpanded), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Банкны карт", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)), Icon(_isCardsExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.white)])), const SizedBox(height: 15),
          
          ValueListenableBuilder<List<CreditCardModel>>(valueListenable: _walletService.savedCardsNotifier, builder: (context, cards, child) {
            if (!_isCardsExpanded) return _buildAddButton(label: "Карт нэмэх", onTap: () => _showCardFormDialog());
            return Column(children: [
              ...List.generate(cards.length, (index) {
                final card = cards[index];
                return Container(margin: const EdgeInsets.only(bottom: 25), child: Dismissible(key: Key(card.id), direction: DismissDirection.horizontal, confirmDismiss: (direction) async {
                  if (direction == DismissDirection.startToEnd) { _deleteCard(card); return false; }
                  else { 
                    if (await _showPasswordDialog("Нэвтрэх нууц үг", _walletService.validateLoginPassword, isNumeric: false)) _showCardFormDialog(existingCard: card); 
                    return false; 
                  }
                }, background: _buildDismissBackground(Alignment.centerLeft, Icons.delete, Colors.red), secondaryBackground: _buildDismissBackground(Alignment.centerRight, Icons.edit, Colors.blue),
                child: StampableCardItem(card: card, isSelected: _selectedCardIndex == index, onTap: () => setState(() {
                  _selectedCardIndex = index;
                  _selectedAccountId = null; // Unselect account
                }))));
              }), 
              const SizedBox(height: 10), 
              _buildAddButton(label: "Карт нэмэх", onTap: () => _showCardFormDialog())
            ]);
          }),
          
          const SizedBox(height: 30), 

          // 2. BANK APPS SECTION (Only if not expense)
          if (!widget.isExpense) ...[
            GestureDetector(onTap: () => setState(() => _isBankAppsExpanded = !_isBankAppsExpanded), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Банкны апп", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)), Icon(_isBankAppsExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.white)])), const SizedBox(height: 15),
            
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 4, mainAxisSpacing: 15, crossAxisSpacing: 15, children: [_buildBankAppIcon("khan_bank.png", "Khan Bank", Colors.green), _buildBankAppIcon("state_bank.png", "State Bank", Colors.red), _buildBankAppIcon("khas_bank.png", "Xac Bank", Colors.yellow[700]!), _buildBankAppIcon("TDB.png", "TDB", Colors.blue), _buildBankAppIcon("M_bank.png", "M Bank", Colors.teal), _buildBankAppIcon("socialpay.png", "SocialPay", Colors.lightBlue), _buildBankAppIcon("golomt.png", "Golomt", Colors.blueGrey), _buildBankAppIcon("monpay.jpg", "MonPay", Colors.orange)]),
              crossFadeState: _isBankAppsExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
            const SizedBox(height: 30),
          ],

          // 3. BANK ACCOUNTS SECTION
           GestureDetector(onTap: () => setState(() => _isAccountsExpanded = !_isAccountsExpanded), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Банкны данс", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)), Icon(_isAccountsExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.white)])), const SizedBox(height: 15),
          
          ValueListenableBuilder<List<BankAccountModel>>(
            valueListenable: _walletService.savedAccountsNotifier,
            builder: (context, accounts, child) {
              if (!_isAccountsExpanded) return _buildAddButton(label: "Банкны данс нэмэх", onTap: () => _showBankAccountForm());
              return Column(
                children: [
                  ...accounts.map((account) {
                    bool isSelected = _selectedAccountId == account.id;
                    return Dismissible(
                      key: Key(account.id),
                      background: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        color: Colors.transparent, 
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      secondaryBackground: Container(
                         margin: const EdgeInsets.only(bottom: 10),
                        color: Colors.transparent, 
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.edit, color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                         if (direction == DismissDirection.startToEnd) {
                           _deleteBankAccount(account);
                           return false; 
                         } else {
                           if (await _showPasswordDialog("Нэвтрэх нууц үг", _walletService.validateLoginPassword, isNumeric: false)) {
                             _showBankAccountForm(existingAccount: account);
                           }
                           return false; 
                         }
                      },
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedAccountId = account.id;
                            _selectedCardIndex = null; // Unselect card
                          });
                        },
                        borderRadius: BorderRadius.circular(15),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2C2C35),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: isSelected ? Colors.greenAccent : Colors.white10,
                              width: isSelected ? 2 : 1
                            ),
                            boxShadow: isSelected ? [BoxShadow(color: Colors.greenAccent.withOpacity(0.2), blurRadius: 8)] : []
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40, height: 40,
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                                child: ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.asset("assets/bank_logos/${account.logoAsset}", fit: BoxFit.cover)),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(account.bankName, style: TextStyle(color: Colors.white, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)), 
                                    Text(account.ibanNumber, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                  ],
                                ),
                              ),
                              if (isSelected) const Icon(Icons.check_circle, color: Colors.greenAccent)
                              else Icon(Icons.chevron_right, color: Colors.grey[600])
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 10),
                  _buildAddButton(label: "Банкны данс нэмэх", onTap: () => _showBankAccountForm())
                ],
              );
            }
          ),

          const SizedBox(height: 100)]))))),
        
        Container(
          padding: const EdgeInsets.all(20), 
          color: AppColors.darkBackground, 
          child: ValueListenableBuilder<List<CreditCardModel>>(
            valueListenable: _walletService.savedCardsNotifier, 
            builder: (context, cards, child) {
              // Идэвхтэй байх нөхцөл: Карт эсвэл Данс аль нэг нь сонгогдсон байх ёстой
              bool isDisabled = _selectedCardIndex == null && _selectedAccountId == null;
              
              return SizedBox(
                width: double.infinity, 
                height: 55, 
                child: ElevatedButton(
                  onPressed: isDisabled ? null : _handlePayment, 
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, 
                    foregroundColor: Colors.white, 
                    side: const BorderSide(color: Colors.white, width: 1.5), 
                    disabledBackgroundColor: Colors.grey.withOpacity(0.3), 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                  ), 
                  child: Text(widget.isExpense ? "Гүйлгээ хийх" : "Цэнэглэх", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
                )
              );
            }
          )
        )
      ]),
    );
  }

  Widget _buildDismissBackground(Alignment align, IconData icon, Color iconColor) {
    return Container(margin: const EdgeInsets.only(bottom: 15), child: AspectRatio(aspectRatio: 1.586, child: Container(padding: const EdgeInsets.symmetric(horizontal: 20), alignment: align, child: Icon(icon, color: iconColor, size: 30))));
  }
  
  Widget _buildAddButton({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap, 
      child: Container(
        width: double.infinity, 
        padding: const EdgeInsets.all(15), 
        decoration: BoxDecoration(color: const Color(0xFF202025), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.blueAccent.withOpacity(0.3))), 
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, color: Colors.blueAccent, size: 20),
            const SizedBox(width: 10),
            Text("+ $label", style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold))
          ],
        )
      )
    );
  }

  Widget _buildBankAppIcon(String assetName, String name, Color color) {
    return InkWell(onTap: _processTransaction, borderRadius: BorderRadius.circular(15), child: Column(children: [SizedBox(height: 50, width: 50, child: ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.asset("assets/bank_logos/$assetName", fit: BoxFit.cover))), const SizedBox(height: 5), Text(name, style: const TextStyle(color: Colors.white, fontSize: 10), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis)]));
  }
}

// ==========================================
// REDESIGNED POINTS DIALOG
// ==========================================

class _PointExchangeDialog extends StatefulWidget {
  const _PointExchangeDialog();
  @override
  State<_PointExchangeDialog> createState() => _PointExchangeDialogState();
}

class _PointExchangeDialogState extends State<_PointExchangeDialog> {
  final MockWalletService _walletService = MockWalletService();
  final TextEditingController _pointsController = TextEditingController();
  int _cashAmount = 0;

  @override
  void initState() {
    super.initState();
    _pointsController.addListener(() {
      int pts = int.tryParse(_pointsController.text) ?? 0;
      setState(() {
        _cashAmount = (pts / 10).floor();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF202025),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: Text("Оноо хөрвүүлэх", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
            const SizedBox(height: 25),
            ValueListenableBuilder(
              valueListenable: _walletService.pointsNotifier, 
              builder: (ctx, pts, _) => Text("Боломжит оноо: $pts", style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold))
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(color: const Color(0xFF2C2C35), borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _pointsController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Оноо бичих",
                        hintStyle: TextStyle(color: Colors.white24)
                      ),
                    ),
                  ),
                  const Text("P", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold))
                ],
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: Text("= $_cashAmount ₮", style: const TextStyle(color: Colors.greenAccent, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, 
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                ), 
                onPressed: () {
                   int pts = int.tryParse(_pointsController.text) ?? 0;
                   if (pts < 1000) {
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Хамгийн багадаа 1000 оноо хөрвүүлэх боломжтой."), backgroundColor: Colors.red));
                   } else {
                     var res = _walletService.convertPointsToCash(pts);
                     Navigator.pop(context);
                     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message']), backgroundColor: res['success'] ? Colors.green : Colors.red));
                   }
                }, 
                child: const Text("Хөрвүүлэх", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// PAYMENT PROCESSING DIALOG (SUCCESS / FAIL)
// ==========================================

class _PaymentProcessingDialog extends StatefulWidget {
  final Future<Map<String, dynamic>> Function() onCheck;
  const _PaymentProcessingDialog({required this.onCheck});
  @override
  State<_PaymentProcessingDialog> createState() => _PaymentProcessingDialogState();
}

class _PaymentProcessingDialogState extends State<_PaymentProcessingDialog> {
  bool? _isSuccess; // null = loading, true = success, false = fail
  String _message = "Уншиж байна...";

  @override
  void initState() { 
    super.initState(); 
    _startProcess(); 
  }

  void _startProcess() async {
    // Run the check function passed from parent
    final result = await widget.onCheck();
    
    if (mounted) {
      setState(() {
        _isSuccess = result['success'];
        _message = result['message'] ?? (_isSuccess! ? "Амжилттай!" : "Алдаа гарлаа.");
      });
      
      // If success, auto close after a moment. If fail, user must close manually or wait.
      if (_isSuccess == true) {
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) Navigator.of(context).pop(true);
      } else {
         // Optional: Auto close on fail too, or let user tap outside? 
         // Let's keep it open for 2 seconds then close with false
         await Future.delayed(const Duration(milliseconds: 2000));
         if (mounted) Navigator.of(context).pop(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF202025), 
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), 
      child: Padding(
        padding: const EdgeInsets.all(30.0), 
        child: Column(
          mainAxisSize: MainAxisSize.min, 
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500), 
              transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child), 
              child: _isSuccess == null 
                  ? const SizedBox(width: 60, height: 60, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                  : (_isSuccess == true 
                      ? const Icon(Icons.check_circle, color: Colors.greenAccent, size: 60, key: ValueKey('success')) 
                      : const Icon(Icons.cancel, color: Colors.redAccent, size: 60, key: ValueKey('fail')))
            ), 
            const SizedBox(height: 25), 
            Text(
              _message, 
              style: TextStyle(
                color: _isSuccess == false ? Colors.redAccent : Colors.white, 
                fontSize: 16, 
                fontWeight: FontWeight.w500
              ),
              textAlign: TextAlign.center,
            )
          ]
        )
      )
    );
  }
}