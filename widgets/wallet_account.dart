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
// MAIN WIDGET: WALLET ACCOUNT
// ---------------------------------------------------------------------------

class WalletAccount extends StatefulWidget {
  const WalletAccount({super.key});

  @override
  State<WalletAccount> createState() => _WalletAccountState();
}

class _WalletAccountState extends State<WalletAccount> {
  final MockWalletService _walletService = MockWalletService();
  
  // Toggles
  bool _isCardsExpanded = true; 
  bool _isAccountsExpanded = true;

  // Available Banks Data
  final List<Map<String, dynamic>> _availableBanks = [
    {'name': 'Khan Bank', 'logo': 'khan_bank.png', 'color': Colors.green},
    {'name': 'Golomt Bank', 'logo': 'golomt.png', 'color': Colors.blueGrey},
    {'name': 'TDB', 'logo': 'TDB.png', 'color': Colors.blue},
    {'name': 'State Bank', 'logo': 'state_bank.png', 'color': Colors.red},
    {'name': 'Xac Bank', 'logo': 'khas_bank.png', 'color': Colors.yellow[700]},
    {'name': 'M Bank', 'logo': 'M_bank.png', 'color': Colors.teal},
    {'name': 'SocialPay', 'logo': 'socialpay.png', 'color': Colors.lightBlue},
    {'name': 'MonPay', 'logo': 'monpay.jpg', 'color': Colors.orange},
  ];

  // --- PASSWORD & CONFIRMATION DIALOGS ---

  Future<bool> _showPasswordDialog(String title, bool Function(String) validator) async {
    String input = "";
    return await showDialog<bool>(context: context, barrierDismissible: false, builder: (ctx) => Dialog(backgroundColor: const Color(0xFF202025), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), child: Padding(padding: const EdgeInsets.all(25.0), child: Column(mainAxisSize: MainAxisSize.min, children: [Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 30), TextField(autofocus: true, keyboardType: TextInputType.number, obscureText: true, style: const TextStyle(color: Colors.white, letterSpacing: 8, fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center, decoration: const InputDecoration(hintText: "••••", hintStyle: TextStyle(color: Colors.white38, letterSpacing: 8), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white54, width: 2)), focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 2))), onChanged: (val) => input = val, inputFormatters: [LengthLimitingTextInputFormatter(4)]), const SizedBox(height: 40), Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Болих", style: TextStyle(color: Colors.grey, fontSize: 16))), ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, side: const BorderSide(color: Colors.white, width: 1.5), padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), onPressed: () => validator(input) ? Navigator.pop(ctx, true) : ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Нууц үг буруу!"), backgroundColor: Colors.red)), child: const Text("Баталгаажуулах", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)))])])))) ?? false;
  }

  Future<bool> _showConfirmationDialog({String msg = "Та үүнийг устгахдаа итгэлтэй байна уу?"}) async {
    return await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(backgroundColor: const Color(0xFF202025), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), title: const Row(children: [Icon(Icons.warning_amber_rounded, color: Colors.amber), SizedBox(width: 10), Text("Анхааруулга", style: TextStyle(color: Colors.white))]), content: Text(msg, style: const TextStyle(color: Colors.white70)), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Үгүй", style: TextStyle(color: Colors.grey))), ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red), onPressed: () => Navigator.pop(ctx, true), child: const Text("Тийм, устгах", style: TextStyle(color: Colors.white)))])) ?? false;
  }

  // --- CARD FORM DIALOG (Add/Edit) ---

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
                Center(child: SizedBox(width: 280, child: HomeCardItem(card: currentPreview, isInteractive: true))),
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

  // --- BANK ACCOUNT DIALOG (Add/Edit) ---

  void _showAddBankAccountDialog({BankAccountModel? existingAccount}) {
    Map<String, dynamic>? selectedBank;
    final ibanController = TextEditingController(text: existingAccount?.ibanNumber ?? "");

    if (existingAccount != null) {
      try {
        selectedBank = _availableBanks.firstWhere((b) => b['name'] == existingAccount.bankName);
      } catch (e) { selectedBank = null; }
    }

    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (context, setState) {
      return AlertDialog(
        backgroundColor: const Color(0xFF202025),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(existingAccount == null ? "Банкны данс холбох" : "Данс засах", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Банк сонгох*", style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(color: const Color(0xFF2C2C35), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white10)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Map<String, dynamic>>(
                    value: selectedBank,
                    hint: const Text("Банкаа сонгоно уу", style: TextStyle(color: Colors.white38)),
                    dropdownColor: const Color(0xFF2C2C35),
                    icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
                    isExpanded: true,
                    style: const TextStyle(color: Colors.white),
                    items: _availableBanks.map((bank) {
                      return DropdownMenuItem<Map<String, dynamic>>(
                        value: bank,
                        child: Row(
                          children: [
                            ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.asset("assets/bank_logos/${bank['logo']}", width: 24, height: 24, fit: BoxFit.cover)),
                            const SizedBox(width: 10),
                            Text(bank['name']),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => selectedBank = val),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text("Дансны дугаар (IBAN)*", style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(color: const Color(0xFF2C2C35), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white10)),
                child: Row(
                  children: [
                    const Text("MN ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)), 
                    Expanded(
                      child: TextField(
                        controller: ibanController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 1.2),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly, 
                          LengthLimitingTextInputFormatter(15), 
                          MongolianIBANFormatter(), 
                        ],
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "XXXXX XXXXXXXXXX",
                          hintStyle: TextStyle(color: Colors.white24),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              const Text("Зөвхөн тоон утга оруулна (Нийт 15 орон)", style: TextStyle(color: Colors.white30, fontSize: 10)),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Болих", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)), 
            onPressed: () {
              if (selectedBank == null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Банкаа сонгоно уу!"))); return; }
              String rawNumbers = ibanController.text.replaceAll(' ', '');
              if (rawNumbers.length != 15) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Дансны дугаар 15 оронтой байх ёстой!"))); return; }

              if (existingAccount != null) {
                // EDIT
                _walletService.editBankAccount(existingAccount.id, selectedBank!['name'], selectedBank!['logo'], rawNumbers, selectedBank!['color']);
              } else {
                // ADD
                _walletService.addBankAccount(selectedBank!['name'], selectedBank!['logo'], rawNumbers, selectedBank!['color']);
              }
              Navigator.pop(ctx);
            }, 
            child: const Text("Хадгалах", style: TextStyle(color: Colors.black))
          ),
        ],
      );
    }));
  }

  Widget _buildDialogInput({required TextEditingController controller, required String label, required String hint, TextInputFormatter? formatter, TextInputType inputType = TextInputType.text, int? length, bool isObscure = false, Function(String)? onChanged}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)), const SizedBox(height: 5), Container(padding: const EdgeInsets.symmetric(horizontal: 15), decoration: BoxDecoration(color: const Color(0xFF2C2C35), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white10)), child: TextField(controller: controller, obscureText: isObscure, keyboardType: inputType, inputFormatters: [if (formatter != null) formatter, if (length != null) LengthLimitingTextInputFormatter(length)], onChanged: onChanged, style: const TextStyle(color: Colors.white), decoration: InputDecoration(border: InputBorder.none, hintText: hint, hintStyle: const TextStyle(color: Colors.white24))))]);
  }

  void _deleteCard(CreditCardModel card) async {
    if (!await _showConfirmationDialog(msg: "Та энэ картыг устгахдаа итгэлтэй байна уу?")) return;
    if (await _showPasswordDialog("Нэвтрэх нууц үг (1234)", _walletService.validateLoginPassword)) {
      _walletService.deleteCard(card.id);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent, 
        elevation: 0, 
        title: const Text("Түрийвч", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false), 
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(), 
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20), 
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: [
                const SizedBox(height: 20),
                
                // --- БАНКНЫ КАРТУУД ---
                GestureDetector(
                  onTap: () => setState(() => _isCardsExpanded = !_isCardsExpanded), 
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                    children: [
                      const Text("Банкны карт", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)), 
                      Icon(_isCardsExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.white)
                    ]
                  )
                ), 
                const SizedBox(height: 15),
                
                ValueListenableBuilder<List<CreditCardModel>>(
                  valueListenable: _walletService.savedCardsNotifier, 
                  builder: (context, cards, child) {
                    return Column(
                      children: [
                        if (_isCardsExpanded)
                          ...List.generate(cards.length, (index) {
                            final card = cards[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 25), 
                              child: Dismissible(
                                key: Key(card.id), 
                                direction: DismissDirection.horizontal, 
                                confirmDismiss: (direction) async {
                                  if (direction == DismissDirection.startToEnd) { 
                                    // Swipe Right -> Delete
                                    _deleteCard(card); 
                                    return false; 
                                  } else { 
                                    // Swipe Left -> Edit
                                    if (await _showPasswordDialog("Нэвтрэх нууц үг (1234)", _walletService.validateLoginPassword)) {
                                      _showCardFormDialog(existingCard: card); 
                                    }
                                    return false; 
                                  }
                                }, 
                                background: _buildDismissBackground(Alignment.centerLeft, Icons.delete, Colors.red), 
                                secondaryBackground: _buildDismissBackground(Alignment.centerRight, Icons.edit, Colors.blueAccent),
                                child: HomeCardItem(card: card, isInteractive: true)
                              )
                            );
                          }), 
                        
                        const SizedBox(height: 10), 
                        _buildAddButton(label: "Карт холбох", onTap: () => _showCardFormDialog())
                      ]
                    );
                  }
                ),

                const SizedBox(height: 30), 

                // --- БАНКНЫ ДАНС ---
                GestureDetector(
                  onTap: () => setState(() => _isAccountsExpanded = !_isAccountsExpanded), 
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                    children: [
                      const Text("Банкны данс", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)), 
                      Icon(_isAccountsExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.white)
                    ]
                  )
                ),
                const SizedBox(height: 15),

                ValueListenableBuilder<List<BankAccountModel>>(
                  valueListenable: _walletService.savedAccountsNotifier,
                  builder: (context, accounts, child) {
                    return Column(
                      children: [
                        if (_isAccountsExpanded)
                          ...accounts.map((account) {
                             return Container(
                               margin: const EdgeInsets.only(bottom: 15),
                               child: Dismissible(
                                 key: Key(account.id),
                                 direction: DismissDirection.horizontal,
                                 
                                 // ЗӨВХӨН ICON ХАРАГДАНА (Арын дэвсгэр өнгөгүй)
                                 background: _buildDismissBackground(Alignment.centerLeft, Icons.delete, Colors.red),
                                 secondaryBackground: _buildDismissBackground(Alignment.centerRight, Icons.edit, Colors.blueAccent),

                                 confirmDismiss: (direction) async {
                                    if (direction == DismissDirection.startToEnd) {
                                      // --- БАРУУН (DELETE) ---
                                      bool confirm = await _showConfirmationDialog(msg: "Та энэ дансыг устгахдаа итгэлтэй байна уу?");
                                      if (!confirm) return false;
                                      
                                      bool passwordCorrect = await _showPasswordDialog("Нэвтрэх нууц үг (1234)", _walletService.validateLoginPassword);
                                      if (passwordCorrect) {
                                        _walletService.deleteBankAccount(account.id);
                                        return false; 
                                      }
                                      return false;
                                    } else {
                                      // --- ЗҮҮН (EDIT) ---
                                      _showAddBankAccountDialog(existingAccount: account);
                                      return false;
                                    }
                                 },
                                 child: Container(
                                   padding: const EdgeInsets.all(16),
                                   decoration: BoxDecoration(
                                     color: const Color(0xFF2C2C35),
                                     borderRadius: BorderRadius.circular(15),
                                     border: Border.all(color: Colors.white10),
                                   ),
                                   child: Row(
                                     children: [
                                       Container(
                                         width: 50, height: 50,
                                         decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                                         padding: const EdgeInsets.all(5),
                                         child: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.asset("assets/bank_logos/${account.logoAsset}", fit: BoxFit.contain))
                                       ),
                                       const SizedBox(width: 15),
                                       Expanded(
                                         child: Column(
                                           crossAxisAlignment: CrossAxisAlignment.start,
                                           children: [
                                             Text(account.bankName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                             const SizedBox(height: 5),
                                             Text("MN ${account.ibanNumber.substring(0, 5)} ${account.ibanNumber.substring(5)}", 
                                               style: const TextStyle(color: Colors.white70, fontSize: 14, letterSpacing: 1),
                                             ),
                                           ],
                                         ),
                                       ),
                                       Container(width: 10, height: 10, decoration: BoxDecoration(color: account.color, shape: BoxShape.circle))
                                     ],
                                   ),
                                 ),
                               ),
                             );
                          }),
                          
                        const SizedBox(height: 10),
                        _buildAddButton(label: "Банкны данс нэмэх", onTap: () => _showAddBankAccountDialog()),
                      ],
                    );
                  }
                ),

                const SizedBox(height: 50)
              ]
            )
          )
        )
      ),
    );
  }

  // --- ШИНЭЧЛЭГДСЭН: Background нь Transparent, зөвхөн Icon нь өнгөтэй ---
  Widget _buildDismissBackground(Alignment align, IconData icon, Color iconColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: align,
        decoration: BoxDecoration(
          color: Colors.transparent, // Арын дэвсгэр өнгөгүй
          borderRadius: BorderRadius.circular(15)
        ),
        child: Icon(icon, color: iconColor, size: 30) // Icon нь өнгөтэй
      ),
    );
  }
  
  Widget _buildAddButton({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap, 
      child: Container(
        width: double.infinity, 
        padding: const EdgeInsets.all(20), 
        decoration: BoxDecoration(color: const Color(0xFF202025), borderRadius: BorderRadius.circular(15)), 
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_circle_outline, color: Colors.blueAccent),
            const SizedBox(width: 10),
            Text("+ $label", style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold))
          ],
        )
      )
    );
  }
}

// ==========================================
// HOME CARD ITEM (Handles Visuals & Flip)
// ==========================================

class HomeCardItem extends StatefulWidget {
  final CreditCardModel card;
  final bool isInteractive;

  const HomeCardItem({super.key, required this.card, this.isInteractive = false});

  @override
  State<HomeCardItem> createState() => _HomeCardItemState();
}

class _HomeCardItemState extends State<HomeCardItem> with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  bool _isFlipped = false;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _flipAnimation = CurvedAnimation(parent: _flipController, curve: Curves.easeInOutBack);
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _toggleFlip() {
    if (!widget.isInteractive) return;
    if (_isFlipped) { _flipController.reverse(); } else { _flipController.forward(); }
    setState(() => _isFlipped = !_isFlipped);
    HapticFeedback.lightImpact();
  }

  String _maskCardNumber(String num) {
    if (num.length != 16) return num;
    return "**** ${num.substring(4, 8)} **** **${num.substring(14)}";
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleFlip, 
      child: AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, child) {
          final angle = _flipAnimation.value * pi;
          final transform = Matrix4.identity()..setEntry(3, 2, 0.001)..rotateY(angle);
          final isShowingFront = _flipAnimation.value < 0.5;

          return Transform(
            transform: transform,
            alignment: Alignment.center,
            child: SizedBox(
              width: double.infinity,
              height: 200, 
              child: isShowingFront ? _buildFront() : Transform(alignment: Alignment.center, transform: Matrix4.identity()..rotateY(pi), child: _buildBack()),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardBase({required Widget child}) {
    Color txtColor = CardStyle.getTextColor(widget.card.colorIndex);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: CardStyle.gradients[widget.card.colorIndex],
        border: Border.all(color: CardStyle.hasBorder(widget.card.colorIndex) ? Colors.white30 : Colors.transparent, width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: DefaultTextStyle(style: TextStyle(color: txtColor, fontFamily: 'Courier'), child: child),
    );
  }

  Widget _buildFront() {
    Color txtColor = CardStyle.getTextColor(widget.card.colorIndex);
    return _buildCardBase(child: Stack(
      children: [
        Positioned(top: 0, left: 0, child: Text("AndSoft LLC", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: txtColor))),
        Positioned(top: 0, right: 0, child: Icon(Icons.wifi, color: txtColor.withOpacity(0.7), size: 24)),
        Positioned(top: 35, left: 0, child: Container(width: 45, height: 35, decoration: BoxDecoration(color: const Color(0xFFD4AF37), borderRadius: BorderRadius.circular(6)))),
        Positioned(bottom: 45, left: 0, child: Text(_maskCardNumber(widget.card.cardNumber), style: TextStyle(fontSize: 20, letterSpacing: 3, color: txtColor, fontWeight: FontWeight.bold))),
        Positioned(bottom: 0, left: 0, child: Text(widget.card.holderName, style: TextStyle(fontSize: 14, letterSpacing: 1.5, fontWeight: FontWeight.w600, color: txtColor.withOpacity(0.8)))),
        Positioned(bottom: 0, right: 0, child: Text("VISA", style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, fontSize: 22, color: txtColor))),
      ],
    ));
  }

  Widget _buildBack() {
    Color txtColor = CardStyle.getTextColor(widget.card.colorIndex);
    return _buildCardBase(child: Stack(
      children: [
        Positioned(top: 10, left: 0, right: 0, child: Container(height: 40, color: Colors.black87)),
        Positioned(top: 60, right: 20, child: Row(children: [const Text("CVV ", style: TextStyle(fontSize: 10)), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2), color: Colors.white, child: const Text("***", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)))])),
        Positioned(bottom: 20, left: 20, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("VALID THRU", style: TextStyle(fontSize: 8)), Text(widget.card.expiryDate, style: const TextStyle(fontSize: 16))])),
        Positioned(bottom: 10, right: 10, child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text("Verified by", style: TextStyle(color: txtColor.withOpacity(0.7), fontSize: 8)), Text("VISA", style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, fontSize: 18, color: txtColor))])),
      ],
    ));
  }
}

// ---------------------------------------------------------------------------
// FORMATTERS
// ---------------------------------------------------------------------------

class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (text.length > 16) text = text.substring(0, 16);
    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) buffer.write(' ');
    }
    var string = buffer.toString();
    return newValue.copyWith(text: string, selection: TextSelection.collapsed(offset: string.length));
  }
}

class CardNameInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text.toUpperCase().replaceAll(RegExp(r'[^A-Z\-\.]'), '');
    return newValue.copyWith(text: newText, selection: TextSelection.collapsed(offset: newText.length));
  }
}

class ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.contains(RegExp(r'[^0-9/]'))) return oldValue;
    var newText = newValue.text.replaceAll('/', '');
    if (newText.length > 4) newText = newText.substring(0, 4);
    if (newValue.selection.baseOffset < oldValue.selection.baseOffset) return newValue;
    var buffer = StringBuffer();
    for (int i = 0; i < newText.length; i++) {
      int digit = int.parse(newText[i]);
      if (i == 0) { if (digit > 1) { buffer.write('0$digit/'); continue; } }
      else if (i == 1) { int month = int.parse(newText.substring(0, 2)); if (month < 1 || month > 12) return oldValue; }
      if (i == 2) { if (digit > 3) { buffer.write('0$digit'); continue; } }
      else if (i == 3) { int day = int.parse(newText.substring(2, 4)); if (day < 1 || day > 31) return oldValue; }
      buffer.write(newText[i]);
      if (i == 1 && newText.length > 2) {
        buffer.write('/');
      } else if (i == 1 && newText.length == 2 && !oldValue.text.endsWith('/')) buffer.write('/');
    }
    return newValue.copyWith(text: buffer.toString(), selection: TextSelection.collapsed(offset: buffer.length));
  }
}

class MongolianIBANFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text.replaceAll(RegExp(r'\D'), ''); 
    if (text.length > 15) text = text.substring(0, 15); 
    
    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if (i == 4 && text.length > 5) {
        buffer.write(' ');
      }
    }
    var string = buffer.toString();
    return newValue.copyWith(text: string, selection: TextSelection.collapsed(offset: string.length));
  }
}