import 'package:flutter/material.dart';
import 'dart:math';

// ==========================================
// 1. DATA MODELS (ӨГӨГДЛИЙН ЗАГВАРУУД)
// ==========================================

/// Сугалааны үндсэн мэдээлэл
class LotteryModel {
  final String id;
  final String title;
  final String price;    
  final int priceInt;    
  final String image;
  final String category; 
  final DateTime endDate;   
  final int totalCount;     
  int soldCount;            

  double get progress => totalCount == 0 ? 0 : soldCount / totalCount;

  LotteryModel({
    required this.id,
    required this.title,
    required this.price,
    required this.priceInt,
    required this.image,
    required this.category,
    required this.endDate,
    this.totalCount = 1000,
    this.soldCount = 0,
  });
}

/// Худалдаж авсан тасалбар
class PurchasedTicketModel {
  final String id;
  final String lotteryId;      
  final String lotteryTitle;
  final String ticketNumbers;  
  final int price;
  final DateTime purchaseDate; 
  final DateTime lotteryEndDate; 

  PurchasedTicketModel({
    required this.id,
    required this.lotteryId,
    required this.lotteryTitle,
    required this.ticketNumbers,
    required this.price,
    required this.purchaseDate,
    required this.lotteryEndDate,
  });
}

/// Картны мэдээлэл
class CreditCardModel {
  final String id;
  final String cardNumber;
  final String holderName;
  final String expiryDate;
  final String cvv;
  final String type;
  final int colorIndex;

  CreditCardModel({
    required this.id,
    required this.cardNumber,
    required this.holderName,
    required this.expiryDate,
    required this.cvv,
    required this.type,
    required this.colorIndex,
  });
}

/// Банкны данс
class BankAccountModel {
  final String id;
  final String bankName;
  final String logoAsset;
  final String ibanNumber;
  final Color color;

  BankAccountModel({
    required this.id,
    required this.bankName,
    required this.logoAsset,
    required this.ibanNumber,
    required this.color,
  });
}

/// Гүйлгээний түүх
class TransactionModel {
  final String id;
  final String title;
  final String? detail;
  final DateTime date;
  final int amount;
  final bool isExpense;
  final bool isPoints;

  TransactionModel({
    required this.id,
    required this.title,
    this.detail,
    required this.date,
    required this.amount,
    required this.isExpense,
    required this.isPoints,
  });
}

// ==========================================
// 2. MOCK AUTH SERVICE
// ==========================================

class MockAuthService {
  static final MockAuthService _instance = MockAuthService._internal();
  factory MockAuthService() => _instance;
  MockAuthService._internal();

  final Map<String, String> _users = {"99112233": "1234", "88112233": "1234"};

  bool isPhoneRegistered(String phone) => _users.containsKey(phone);

  void registerUser(String phone, String password) {
    _users[phone] = password;
    debugPrint("AUTH: New User -> $phone");
  }

  bool login(String phone, String password) {
    if (_users[phone] == password) {
      MockWalletService().setLoggedInUser(phone);
      return true;
    }
    return false;
  }
  
  bool verifyUserPassword(String phone, String inputPassword) {
    return _users[phone] == inputPassword;
  }

  void updateLoginPassword(String phone, String newPassword) {
    if (_users.containsKey(phone)) {
      _users[phone] = newPassword;
      debugPrint("AUTH: Password updated for $phone");
    }
  }

  bool verifyOTP(String inputOtp) => inputOtp == "1234";

  void changePassword(String phone, String newPassword) {
    if (_users.containsKey(phone)) _users[phone] = newPassword;
  }

  String sendOTP(String phone) => "1234";
}

// ==========================================
// 3. MOCK WALLET SERVICE (MAIN)
// ==========================================

class MockWalletService {
  static final MockWalletService _instance = MockWalletService._internal();
  factory MockWalletService() => _instance;

  MockWalletService._internal() {
    _initLotteries();
    _initTransactions();
    _initFriends(); // Найзуудын жагсаалт үүсгэх
  }

  // --- STATE (ValueNotifiers) ---
  final ValueNotifier<int> balanceNotifier = ValueNotifier<int>(50000); 
  final ValueNotifier<int> pointsNotifier = ValueNotifier<int>(1000);
  
  final ValueNotifier<List<CreditCardModel>> savedCardsNotifier = ValueNotifier<List<CreditCardModel>>([]);
  final ValueNotifier<List<BankAccountModel>> savedAccountsNotifier = ValueNotifier<List<BankAccountModel>>([]);
  final ValueNotifier<List<TransactionModel>> transactionsNotifier = ValueNotifier<List<TransactionModel>>([]);
  final ValueNotifier<List<PurchasedTicketModel>> myTicketsNotifier = ValueNotifier<List<PurchasedTicketModel>>([]);

  // --- REFERRAL STATE (ШИНЭ) ---
  final ValueNotifier<List<Map<String, dynamic>>> invitedFriendsNotifier = ValueNotifier([]);

  // --- INTERNAL VARIABLES ---
  DateTime? _lastLoginDate;
  int _loginStreak = 0;
  bool _isProfileCompleted = false;
  final Set<String> _likedAds = {};

  final List<Map<String, dynamic>> _lotterySections = [];
  final Map<String, LotteryModel> _allLotteriesMap = {};

  // --- SECURITY MOCK ---
  String? _transactionPin; // Null = ПИН үүсгээгүй
  String? _savedBiometricPhone;
  String? _loggedInPhone;
  String? _loggedInName;
  String? _profileUrl;
  bool _isBiometricEnabled = false;

  // --- GETTERS ---
  int get balance => balanceNotifier.value;
  int get points => pointsNotifier.value;
  List<CreditCardModel> get savedCards => savedCardsNotifier.value;
  List<BankAccountModel> get savedAccounts => savedAccountsNotifier.value; 
  List<TransactionModel> get transactions => transactionsNotifier.value; 
  List<Map<String, dynamic>> get lotterySections => _lotterySections; 
  
  bool get isBiometricEnabled => _isBiometricEnabled;
  bool get isProfileCompleted => _isProfileCompleted;

String? get loggedInPhone => _loggedInPhone;

  String get currentPhone => _loggedInPhone ?? "";
  String? get currentName => _loggedInName;
  String? get profileUrl => _profileUrl;

  LotteryModel? getLotteryById(String id) => _allLotteriesMap[id];

  // --- TRANSACTION PIN MANAGEMENT ---
  
  // ПИН үүсгэсэн эсэх
  bool get hasTransactionPin => _transactionPin != null && _transactionPin!.isNotEmpty;

  // ПИН шалгах
  bool validateTransactionPin(String input) {
    if (_transactionPin == null) return false;
    return input == _transactionPin;
  }

  // ПИН солих / Үүсгэх
  void setTransactionPin(String newPin) {
    _transactionPin = newPin;
    debugPrint("WALLET: Гүйлгээний ПИН-г шинэчилсэн $newPin");
  }

  // --- SECURITY CHECKS (LOGIN) ---
  bool validateLoginPassword(String input) {
    if (_loggedInPhone == null) return false;
    return MockAuthService().verifyUserPassword(_loggedInPhone!, input);
  }

  // --- USER MANAGEMENT ---
  void setLoggedInUser(String phone) {
    _loggedInPhone = phone;
  }

  void logout() {
    _loggedInPhone = null;
    _loggedInName = null;
    _profileUrl = null;
    debugPrint("User logged out.");
  }

  void updateProfile({String? name, String? photoUrl}) {
    if (name != null) _loggedInName = name;
    if (photoUrl != null) _profileUrl = photoUrl;
  }

  void setBiometricEnabled(bool value) {
    _isBiometricEnabled = value;
    if (value && _loggedInPhone != null) {
      _savedBiometricPhone = _loggedInPhone;
    } else if (!value) {
      _savedBiometricPhone = null;
    }
  }

  String? get savedBiometricPhone => _savedBiometricPhone;

  // ==========================================
  // REFERRAL LOGIC (ШИНЭ ХЭСЭГ)
  // ==========================================

  void _initFriends() {
    // Status: 1 = Accepted (Ногоон), 0 = Pending (Шар)
    invitedFriendsNotifier.value = [
      {"name": "Б. Бат-Эрдэнэ", "phone": "99****11", "status": 1, "date": "2023.11.10"}, 
      {"name": "Д. Болд", "phone": "88****22", "status": 0, "date": "2023.12.01"},       
      {"name": "Г. Сараа", "phone": "91****33", "status": 1, "date": "2023.12.05"},      
      {"name": "Т. Оюун", "phone": "90****44", "status": 0, "date": "2023.12.18"},       
    ];
  }

  /// Шинэ хэрэглэгч урилгын линкээр бүртгүүлэхэд дуудагдана
  void processReferralRegistration(String linkOrCode) {
    if (linkOrCode.isNotEmpty) {
      // 1. Шинэ хэрэглэгчид (Өөрт) 50 оноо өгөх
      _addPoints(50, "Урилгаар бүртгүүлсэн", "Welcome Bonus");
      
      // 2. Урьсан хүнд 100 оноо өгөх (Mock тул зүгээр л log хийе)
      debugPrint("Referrer received 100 points via link: $linkOrCode");
    }
  }

  // ==========================================
  // X. LOTTERY LOGIC
  // ==========================================

  void _initLotteries() {
    if (_lotterySections.isNotEmpty) return;

    DateTime daysFromNow(int days) => DateTime.now().add(Duration(days: days));

    // 1. Супер сугалаа
    _addSection("🔥 Супер сугалаа", [
      LotteryModel(id: "101", title: "Land Cruiser 300", price: "30,000₮", priceInt: 30000, image: "assets/images/2.jpg", category: "Super", endDate: daysFromNow(45), totalCount: 5000, soldCount: 1250),
      LotteryModel(id: "102", title: "Lexus LX600", price: "40,000₮", priceInt: 40000, image: "assets/images/2.jpg", category: "Super", endDate: daysFromNow(60), totalCount: 4000, soldCount: 300),
      LotteryModel(id: "103", title: "3 өрөө байр", price: "25,000₮", priceInt: 25000, image: "assets/images/4.jpg", category: "Super", endDate: daysFromNow(30), totalCount: 6000, soldCount: 5900),
    ]);

    // 2. Онцлох
    _addSection("⭐️ Онцлох сугалаа", [
      LotteryModel(id: "201", title: "iPhone 15 Pro Max", price: "5,000₮", priceInt: 5000, image: "assets/images/1.jpg", category: "Featured", endDate: daysFromNow(5), totalCount: 500, soldCount: 450), 
      LotteryModel(id: "202", title: "MacBook Pro M3", price: "10,000₮", priceInt: 10000, image: "assets/images/4.jpg", category: "Featured", endDate: daysFromNow(3), totalCount: 300, soldCount: 280),
    ]);

    // 3. Монгол сугалаа
    _addSection("🇲🇳 Монгол сугалаа", [
      LotteryModel(id: "301", title: "Бүрэн сийлбэртэй гэр", price: "15,000₮", priceInt: 15000, image: "assets/images/3.jpg", category: "Mongol", endDate: daysFromNow(20), totalCount: 200, soldCount: 50),
      LotteryModel(id: "302", title: "Хурдан удмын адуу", price: "20,000₮", priceInt: 20000, image: "assets/images/2.jpg", category: "Mongol", endDate: daysFromNow(90), totalCount: 100, soldCount: 15),
    ]);

    // 4. Цалинтай сугалаа
    _addSection("💰 Цалинтай сугалаа", [
      LotteryModel(id: "401", title: "Сар бүр 2 сая", price: "3,000₮", priceInt: 3000, image: "assets/images/4.jpg", category: "Salary", endDate: daysFromNow(10), totalCount: 2000, soldCount: 1500),
      LotteryModel(id: "402", title: "Сар бүр 5 сая", price: "5,000₮", priceInt: 5000, image: "assets/images/4.jpg", category: "Salary", endDate: daysFromNow(100), totalCount: 3000, soldCount: 200),
    ]);

    // 5. Бэлгийн карт
    _addSection("🎁 Бэлгийн карт", [
      LotteryModel(id: "501", title: "Amazon \$100", price: "1,000₮", priceInt: 1000, image: "assets/images/1.jpg", category: "Gift", endDate: daysFromNow(2), totalCount: 100, soldCount: 80),
      LotteryModel(id: "502", title: "Steam \$50", price: "500₮", priceInt: 500, image: "assets/images/3.jpg", category: "Gift", endDate: DateTime.now().subtract(const Duration(days: 1)), totalCount: 100, soldCount: 100),
    ]);

    // 6. Малчдын сугалаа
    _addSection("🐎 Малчдын сугалаа", [
      LotteryModel(id: "601", title: "Мотоцикл Mustang 5", price: "5,000₮", priceInt: 5000, image: "assets/images/2.jpg", category: "Herder", endDate: daysFromNow(40), totalCount: 500, soldCount: 120),
      LotteryModel(id: "602", title: "Нарны панель", price: "3,000₮", priceInt: 3000, image: "assets/images/3.jpg", category: "Herder", endDate: daysFromNow(15), totalCount: 300, soldCount: 10),
    ]);

    // 7. Өдөр тутмын
    _addSection("📅 Өдөр тутмын", [
      LotteryModel(id: "701", title: "Өдрийн азтан", price: "500₮", priceInt: 500, image: "assets/images/4.jpg", category: "Daily", endDate: daysFromNow(1), totalCount: 1000, soldCount: 500),
      LotteryModel(id: "702", title: "Шатахуун 50л", price: "1,000₮", priceInt: 1000, image: "assets/images/2.jpg", category: "Daily", endDate: daysFromNow(1), totalCount: 200, soldCount: 50),
    ]);

    // 8. Бараг үнэгүй
    _addSection("⚡️ Бараг үнэгүй", [
      LotteryModel(id: "801", title: "Airpods Case", price: "100₮", priceInt: 100, image: "assets/images/1.jpg", category: "Cheap", endDate: daysFromNow(5), totalCount: 500, soldCount: 400),
      LotteryModel(id: "802", title: "Утасны нэгж", price: "50₮", priceInt: 50, image: "assets/images/3.jpg", category: "Cheap", endDate: daysFromNow(2), totalCount: 1000, soldCount: 900),
    ]);

    // 9. Тоглоом сугалаа
    _addSection("🎮 Тоглоом сугалаа", [
      LotteryModel(id: "901", title: "PlayStation 5", price: "5,000₮", priceInt: 5000, image: "assets/images/3.jpg", category: "Game", endDate: daysFromNow(25), totalCount: 300, soldCount: 100),
      LotteryModel(id: "902", title: "Gaming PC Set", price: "8,000₮", priceInt: 8000, image: "assets/images/4.jpg", category: "Game", endDate: daysFromNow(30), totalCount: 100, soldCount: 20),
    ]);
  }

  void _addSection(String title, List<LotteryModel> items) {
    _lotterySections.add({"title": title, "data": items});
    for (var item in items) {
      _allLotteriesMap[item.id] = item;
    }
  }

  /// 2. СУГАЛАА ХУДАЛДАЖ АВАХ
  Map<String, dynamic> buyTicket({
    required String lotteryId, 
    required String ticketNumbers,
    required int totalPrice,
    required String pinCode,
  }) {
    // 1. Пин код шалгах
    if (!validateTransactionPin(pinCode)) {
      return {"success": false, "message": "Гүйлгээний нууц үг буруу байна!"};
    }

    // 2. Үлдэгдэл шалгах
    if (balanceNotifier.value < totalPrice) {
      return {"success": false, "message": "Үлдэгдэл хүрэлцэхгүй байна."};
    }

    // 3. Сугалааг олж, дүүргэлт нэмэх
    final lottery = _allLotteriesMap[lotteryId];
    if (lottery != null) {
      lottery.soldCount += 1;
      if (lottery.soldCount > lottery.totalCount) {
        lottery.soldCount = lottery.totalCount;
      }
    }

    // 4. Төлбөр хасах
    balanceNotifier.value -= totalPrice;

    // 5. "Миний сугалаа" руу нэмэх
    final newTicket = PurchasedTicketModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      lotteryId: lotteryId,
      lotteryTitle: lottery?.title ?? "Unknown",
      ticketNumbers: ticketNumbers,
      price: totalPrice,
      purchaseDate: DateTime.now(),
      lotteryEndDate: lottery?.endDate ?? DateTime.now(),
    );
    
    List<PurchasedTicketModel> currentTickets = List.from(myTicketsNotifier.value);
    currentTickets.insert(0, newTicket);
    myTicketsNotifier.value = currentTickets;

    // 6. Гүйлгээний түүх нэмэх
    _addTransaction(
      title: "Сугалаа худалдан авалт",
      detail: "${lottery?.title ?? 'Unknown'}",
      amount: totalPrice,
      isExpense: true,
      isPoints: false,
    );
    
    // 7. Урамшуулал: Худалдан авалт бүрт 5 оноо
    _addPoints(5, "Худалдан авалтын урамшуулал", "+5 оноо");

    return {"success": true, "message": "Амжилттай худалдан авлаа."};
  }

  // ==========================================
  // A. BALANCE ACTIONS
  // ==========================================

  void _addTransaction({
    required String title,
    String? detail,
    required int amount,
    required bool isExpense,
    required bool isPoints,
  }) {
    final newTx = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString() + Random().nextInt(999).toString(),
      title: title,
      detail: detail,
      date: DateTime.now(),
      amount: amount,
      isExpense: isExpense,
      isPoints: isPoints,
    );

    List<TransactionModel> current = List.from(transactionsNotifier.value);
    current.insert(0, newTx); 
    transactionsNotifier.value = current;
  }

  void _initTransactions() {
    _addTransaction(title: "Цэнэглэлт", detail: "Дансаар орсон", amount: 5000000, isExpense: false, isPoints: false);
  }

  Map<String, dynamic> addBalance(int amount, {String source = "Банкны апп"}) {
    if (amount > 10000000) {
      return {"success": false, "message": "Сонгосон дансны үлдэгдэл хүрэлцэхгүй байна."};
    }

    balanceNotifier.value += amount;
    
    _addTransaction(
      title: "Түрүүвч цэнэглэлт",
      detail: source,
      amount: amount,
      isExpense: false,
      isPoints: false,
    );
    return {"success": true, "message": "Амжилттай цэнэглэгдлээ."};
  }

  Map<String, dynamic> deductBalanceResult(int amount, {String itemName = "Худалдан авалт"}) {
    if (balanceNotifier.value >= amount) {
      balanceNotifier.value -= amount;

      _addTransaction(
        title: "Худалдан авалт",
        detail: itemName, 
        amount: amount,
        isExpense: true,
        isPoints: false,
      );

      processCashback(amount, itemName: itemName); 

      return {"success": true, "message": "Гүйлгээ амжилттай."};
    }
    
    return {"success": false, "message": "Дансны үлдэгдэл хүрэлцэхгүй байна."};
  }

  bool deductBalance(int amount, {String itemName = "Худалдан авалт"}) {
      var res = deductBalanceResult(amount, itemName: itemName);
      return res['success'];
  }

  void processCashback(int purchaseAmount, {String itemName = "Худалдан авалт"}) {
    int cashbackPoints = (purchaseAmount * 0.05).toInt(); // 5%
    if (cashbackPoints > 0) {
      _addPoints(
        cashbackPoints, 
        "Худалдан авалтын урамшуулал", 
        "5% буцаан олголт ($itemName)"
      );
    }
  }

  // ==========================================
  // B. CARD MANAGEMENT
  // ==========================================

  void addCard(String fullNumber, String holder, String expiry, String cvv, int colorIdx) {
    String cleanNumber = fullNumber.replaceAll(" ", "");
    String type = cleanNumber.startsWith("4") ? "VISA" : "Mastercard";
    String uniqueId = DateTime.now().millisecondsSinceEpoch.toString();
    
    final newCard = CreditCardModel(
      id: uniqueId,
      cardNumber: cleanNumber, 
      holderName: holder.toUpperCase(),
      expiryDate: expiry,
      cvv: cvv,
      type: type,
      colorIndex: colorIdx,
    );
    
    List<CreditCardModel> currentCards = List.from(savedCardsNotifier.value);
    currentCards.add(newCard);
    savedCardsNotifier.value = currentCards;
  }

  void editCard(String id, String newNumber, String newHolder, String newExpiry, String newCvv, int newColorIdx) {
    List<CreditCardModel> currentCards = List.from(savedCardsNotifier.value);
    final index = currentCards.indexWhere((c) => c.id == id);
    
    if (index != -1) {
      String cleanNumber = newNumber.replaceAll(" ", "");
      String type = cleanNumber.startsWith("4") ? "VISA" : "Mastercard";
      
      currentCards[index] = CreditCardModel(
        id: id,
        cardNumber: cleanNumber, 
        holderName: newHolder.toUpperCase(),
        expiryDate: newExpiry,
        cvv: newCvv,
        type: type,
        colorIndex: newColorIdx,
      );
      savedCardsNotifier.value = currentCards;
    }
  }

  void deleteCard(String id) {
    List<CreditCardModel> currentCards = List.from(savedCardsNotifier.value);
    currentCards.removeWhere((c) => c.id == id);
    savedCardsNotifier.value = currentCards;
  }

  // ==========================================
  // C. BANK ACCOUNT MANAGEMENT
  // ==========================================

  void addBankAccount(String bankName, String logoAsset, String ibanNumber, Color color) {
    final newAccount = BankAccountModel(
      id: DateTime.now().millisecondsSinceEpoch.toString() + Random().nextInt(999).toString(),
      bankName: bankName,
      logoAsset: logoAsset,
      ibanNumber: ibanNumber,
      color: color,
    );

    List<BankAccountModel> currentAccounts = List.from(savedAccountsNotifier.value);
    currentAccounts.add(newAccount);
    savedAccountsNotifier.value = currentAccounts;
  }

  void editBankAccount(String id, String bankName, String logoAsset, String ibanNumber, Color color) {
    List<BankAccountModel> currentAccounts = List.from(savedAccountsNotifier.value);
    final index = currentAccounts.indexWhere((acc) => acc.id == id);
    
    if (index != -1) {
      currentAccounts[index] = BankAccountModel(
        id: id,
        bankName: bankName,
        logoAsset: logoAsset,
        ibanNumber: ibanNumber,
        color: color,
      );
      savedAccountsNotifier.value = currentAccounts;
    }
  }

  void deleteBankAccount(String id) {
    List<BankAccountModel> currentAccounts = List.from(savedAccountsNotifier.value);
    currentAccounts.removeWhere((acc) => acc.id == id);
    savedAccountsNotifier.value = currentAccounts;
  }

  // ==========================================
  // D. LOYALTY SYSTEM
  // ==========================================

  void _addPoints(int amount, String title, String detail) {
    pointsNotifier.value += amount;
    _addTransaction(
      title: title,
      detail: detail,
      amount: amount,
      isExpense: false,
      isPoints: true,
    );
  }

  void giveConsolationPrize(int ticketPrice, String lotteryName) {
    int consolationPoints = (ticketPrice * 0.10).toInt(); 
    if (consolationPoints > 0) {
      _addPoints(
        consolationPoints, 
        "Азгүйтлийн урамшуулал", 
        "10% буцаан олголт ($lotteryName)"
      );
    }
  }

  String checkDailyLogin() {
    DateTime now = DateTime.now();
    if (_lastLoginDate != null && 
        _lastLoginDate!.year == now.year && 
        _lastLoginDate!.month == now.month && 
        _lastLoginDate!.day == now.day) {
      return "Өнөөдөр аль хэдийн авсан.";
    }

    bool isConsecutive = false;
    if (_lastLoginDate != null) {
      final diff = now.difference(_lastLoginDate!).inDays;
      if (diff == 1) isConsecutive = true;
    }

    _loginStreak = isConsecutive ? _loginStreak + 1 : 1;
    _lastLoginDate = now;
    
    bool isSunday = now.weekday == 7; 
    int pointsToGive = 1;

    if (isSunday && _loginStreak >= 7) {
      pointsToGive = 5;
      _loginStreak = 0; 
    } else {
      pointsToGive = 1;
    }

    _addPoints(
      pointsToGive, 
      "Өдөр тутмын идэвх", 
      isSunday ? "Ням гараг (Streak $_loginStreak)" : "Энгийн өдөр (Streak $_loginStreak)"
    );
    return "Өдөр тутмын урамшуулал: +$pointsToGive оноо";
  }

  void applyReferralCode(String code) {
    if (code.isNotEmpty) {
      final friends = ["Бат", "Дорж", "Сараа", "Туяа"];
      final friend = friends[Random().nextInt(friends.length)];
      
      _addPoints(100, "Найз урьсан", "$friend бүртгүүлсэн ($code)");
    }
  }

  void watchAdReward(String adTitle) {
    _addPoints(1, "Реклам үзэх", "$adTitle (30 сек)");
  }

  void completeProfile() {
    if (!_isProfileCompleted) {
      _addPoints(10, "Профайл бөглөх", "Анкетаа бүрэн бөглөсний шагнал");
      _isProfileCompleted = true;
    }
  }

  Map<String, dynamic> convertPointsToCash(int pointsToBurn) {
    if (pointsNotifier.value >= pointsToBurn) {
      int cashAmount = (pointsToBurn / 10).floor(); 
      if (cashAmount < 1) return {"success": false, "message": "Хөрвүүлэхэд хэт бага оноо."};

      pointsNotifier.value -= pointsToBurn;
      _addTransaction(
        title: "Оноо хөрвүүлэлт",
        detail: "$pointsToBurn P -> $cashAmount₮",
        amount: pointsToBurn,
        isExpense: true,
        isPoints: true,
      );

      balanceNotifier.value += cashAmount;
      _addTransaction(
        title: "Онооноос орсон",
        detail: "Онооноос хөрвүүлсэн",
        amount: cashAmount,
        isExpense: false,
        isPoints: false,
      );

      return {"success": true, "message": "Амжилттай хөрвүүллээ!"};
    }
    return {"success": false, "message": "Оноо хүрэлцэхгүй."};
  }

  bool isAdLiked(String? id) {
    if (id == null) return false;
    return _likedAds.contains(id);
  }

  void toggleAdLike(String? id) {
    if (id == null) return;
    if (_likedAds.contains(id)) {
      _likedAds.remove(id);
    } else {
      _likedAds.add(id);
    }
  }
}