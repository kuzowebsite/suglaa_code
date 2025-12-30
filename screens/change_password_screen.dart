import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/mock_wallet_service.dart';
import '../utils/app_colors.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Нууц үг солих", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.amber,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: "Нэвтрэх нууц үг"),
            Tab(text: "Гүйлгээний ПИН"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _LoginPasswordTab(),
          _TransactionPinTab(),
        ],
      ),
    );
  }
}

// ==========================================
// TAB 1: НЭВТРЭХ НУУЦ ҮГ СОЛИХ
// ==========================================
class _LoginPasswordTab extends StatefulWidget {
  const _LoginPasswordTab();

  @override
  State<_LoginPasswordTab> createState() => _LoginPasswordTabState();
}

class _LoginPasswordTabState extends State<_LoginPasswordTab> {
  final MockAuthService _authService = MockAuthService();
  final MockWalletService _walletService = MockWalletService();

  bool _isForgotMode = false; // Мартсан горим
  bool _otpSent = false; // OTP илгээсэн эсэх

  // Controllers
  final _oldPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _phoneController.text = _walletService.currentPhone; // Автоматаар бөглөх
  }

  void _resetFields() {
    _oldPassController.clear();
    _newPassController.clear();
    _confirmPassController.clear();
    _otpController.clear();
    setState(() {
      _otpSent = false;
    });
  }

  // 1. Энгийн солих
  void _changePassword() {
    String phone = _walletService.currentPhone;
    if (_newPassController.text != _confirmPassController.text) {
      _showError("Шинэ нууц үг таарахгүй байна.");
      return;
    }
    if (_newPassController.text.length < 4) {
      _showError("Нууц үг хамгийн багадаа 4 оронтой байна.");
      return;
    }

    if (_authService.verifyUserPassword(phone, _oldPassController.text)) {
      _authService.updateLoginPassword(phone, _newPassController.text);
      _showSuccess("Нэвтрэх нууц үг амжилттай солигдлоо.");
      _resetFields();
    } else {
      _showError("Хуучин нууц үг буруу байна.");
    }
  }

  // 2. Мартсан үед (OTP илгээх)
  void _sendOTP() {
    // Mock OTP logic
    setState(() {
      _otpSent = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("OTP код илгээлээ: 1234")));
  }

  // 3. Мартсан үед (OTP шалгаж солих)
  void _resetPasswordWithOTP() {
    if (_newPassController.text != _confirmPassController.text) {
      _showError("Шинэ нууц үг таарахгүй байна.");
      return;
    }
    if (_authService.verifyOTP(_otpController.text)) {
      _authService.updateLoginPassword(_walletService.currentPhone, _newPassController.text);
      _showSuccess("Нууц үг амжилттай сэргээгдлээ.");
      setState(() {
        _isForgotMode = false;
        _otpSent = false;
      });
      _resetFields();
    } else {
      _showError("OTP код буруу байна.");
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.green));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!_isForgotMode) ...[
            // --- STANDARD CHANGE MODE ---
            const Text("Нууц үг солих", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildTextField("Хуучин нууц үг", _oldPassController, obscure: true),
            const SizedBox(height: 15),
            _buildTextField("Шинэ нууц үг", _newPassController, obscure: true),
            const SizedBox(height: 15),
            _buildTextField("Шинэ нууц үг давтах", _confirmPassController, obscure: true),
            
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => setState(() => _isForgotMode = true),
                child: const Text("Нууц үгээ мартсан?", style: TextStyle(color: Colors.amber)),
              ),
            ),
            const SizedBox(height: 20),
            _buildButton("Солих", _changePassword),

          ] else ...[
            // --- FORGOT MODE ---
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white), 
                  onPressed: () => setState(() => _isForgotMode = false),
                ),
                const Text("Нууц үг сэргээх", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 20),
            
            _buildTextField("Утасны дугаар", _phoneController, readOnly: true),
            const SizedBox(height: 15),
            
            if (!_otpSent)
              _buildButton("OTP илгээх", _sendOTP)
            else ...[
              _buildTextField("OTP код (1234)", _otpController, isNumber: true),
              const SizedBox(height: 15),
              _buildTextField("Шинэ нууц үг", _newPassController, obscure: true),
              const SizedBox(height: 15),
              _buildTextField("Шинэ нууц үг давтах", _confirmPassController, obscure: true),
              const SizedBox(height: 20),
              _buildButton("Сэргээх", _resetPasswordWithOTP),
            ],
          ]
        ],
      ),
    );
  }
}

// ==========================================
// TAB 2: ГҮЙЛГЭЭНИЙ ПИН СОЛИХ / ҮҮСГЭХ
// ==========================================
class _TransactionPinTab extends StatefulWidget {
  const _TransactionPinTab();

  @override
  State<_TransactionPinTab> createState() => _TransactionPinTabState();
}

class _TransactionPinTabState extends State<_TransactionPinTab> {
  final MockWalletService _walletService = MockWalletService();
  final MockAuthService _authService = MockAuthService();

  // Modes: 
  // 0 = Change (Хуучин ПИН асууна)
  // 1 = Forgot (Мартсан, OTP асууна)
  // 2 = Create (Шинэ хэрэглэгч, OTP асууна)
  int _mode = 0; 
  bool _otpSent = false;

  final _oldPinController = TextEditingController();
  final _newPinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _phoneController.text = _walletService.currentPhone;
    
    // --- ШАЛГАЛТ ---
    // Service-ээс hasTransactionPin-ийг шалгана.
    // Одоо анхдагчаар ПИН байхгүй тул энэ нь false буцааж, _mode = 2 болно.
    if (!_walletService.hasTransactionPin) {
      _mode = 2; // Create mode
    } else {
      _mode = 0; // Change mode
    }
  }

  void _resetFields() {
    _oldPinController.clear();
    _newPinController.clear();
    _confirmPinController.clear();
    _otpController.clear();
    setState(() {
      _otpSent = false;
    });
  }

  // 1. Энгийн солих (Change Mode)
  void _changePin() {
    if (_newPinController.text != _confirmPinController.text) {
      _showError("Шинэ ПИН таарахгүй байна."); return;
    }
    if (_newPinController.text.length != 4) {
      _showError("ПИН код 4 оронтой байх ёстой."); return;
    }

    if (_walletService.validateTransactionPin(_oldPinController.text)) {
      _walletService.setTransactionPin(_newPinController.text);
      _showSuccess("Гүйлгээний нууц үг солигдлоо.");
      _resetFields();
    } else {
      _showError("Хуучин ПИН буруу байна.");
    }
  }

  // 2. OTP илгээх (Forgot болон Create үед адилхан)
  void _sendOTP() {
    setState(() {
      _otpSent = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("OTP код илгээлээ: 1234")));
  }

  // 3. ПИН шинээр үүсгэх / Сэргээх
  void _savePinWithOTP() {
    if (_newPinController.text != _confirmPinController.text) {
      _showError("Шинэ ПИН таарахгүй байна."); return;
    }
    if (_newPinController.text.length != 4) {
      _showError("ПИН код 4 оронтой байх ёстой."); return;
    }

    if (_authService.verifyOTP(_otpController.text)) {
      _walletService.setTransactionPin(_newPinController.text);
      
      String msg = _mode == 2 ? "Гүйлгээний ПИН амжилттай үүслээ." : "Гүйлгээний ПИН сэргээгдлээ.";
      _showSuccess(msg);
      
      // Амжилттай үүсгэсний дараа "Солих" горим руу шилжүүлнэ
      setState(() {
        _mode = 0; 
        _otpSent = false;
      });
      _resetFields();
    } else {
      _showError("OTP код буруу байна.");
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.green));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          // --- CASE 0: CHANGE PIN (Хуучин ПИН асууна) ---
          if (_mode == 0) ...[
            const Text("Гүйлгээний ПИН солих", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildTextField("Хуучин ПИН (4 орон)", _oldPinController, isNumber: true, isPin: true, obscure: true),
            const SizedBox(height: 15),
            _buildTextField("Шинэ ПИН (4 орон)", _newPinController, isNumber: true, isPin: true, obscure: true),
            const SizedBox(height: 15),
            _buildTextField("Шинэ ПИН давтах", _confirmPinController, isNumber: true, isPin: true, obscure: true),
            
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => setState(() => _mode = 1), // Forgot mode руу шилжих
                child: const Text("ПИН кодоо мартсан?", style: TextStyle(color: Colors.amber)),
              ),
            ),
            const SizedBox(height: 20),
            _buildButton("Солих", _changePin),

          ] 
          // --- CASE 1 (FORGOT) & CASE 2 (CREATE) ---
          else if (_mode == 1 || _mode == 2) ...[
            Row(
              children: [
                // Create Mode (2) дээр буцах товч харагдахгүй (Учир нь буцах газар байхгүй)
                if (_mode == 1) 
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white), 
                    onPressed: () => setState(() => _mode = 0), // Буцаад Change mode руу
                  ),
                
                Text(
                  _mode == 2 ? "Гүйлгээний ПИН үүсгэх" : "ПИН код сэргээх", 
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
                ),
              ],
            ),
            const SizedBox(height: 10),
            
            if (_mode == 2) 
              const Padding(
                padding: EdgeInsets.only(bottom: 15),
                child: Text("Та шинэ хэрэглэгч тул гүйлгээний ПИН үүсгэх шаардлагатай.", style: TextStyle(color: Colors.grey, fontSize: 13)),
              ),

            _buildTextField("Утасны дугаар", _phoneController, readOnly: true),
            const SizedBox(height: 15),

            if (!_otpSent)
              _buildButton("OTP илгээх", _sendOTP)
            else ...[
              _buildTextField("OTP код (1234)", _otpController, isNumber: true),
              const SizedBox(height: 15),
              _buildTextField("Шинэ ПИН (4 орон)", _newPinController, isNumber: true, isPin: true, obscure: true),
              const SizedBox(height: 15),
              _buildTextField("Шинэ ПИН давтах", _confirmPinController, isNumber: true, isPin: true, obscure: true),
              const SizedBox(height: 20),
              _buildButton(_mode == 2 ? "Үүсгэх" : "Сэргээх", _savePinWithOTP),
            ],
          ]
        ],
      ),
    );
  }
}

// --- COMMON WIDGETS ---

Widget _buildTextField(String label, TextEditingController controller, {bool obscure = false, bool isNumber = false, bool isPin = false, bool readOnly = false}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12),
        ),
        child: TextField(
          controller: controller,
          obscureText: obscure,
          readOnly: readOnly,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          maxLength: isPin ? 4 : null,
          inputFormatters: isPin ? [FilteringTextInputFormatter.digitsOnly] : [],
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            counterText: "", // Hide character counter
          ),
        ),
      ),
    ],
  );
}

Widget _buildButton(String text, VoidCallback onPressed) {
  return SizedBox(
    width: double.infinity,
    height: 50,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    ),
  );
}