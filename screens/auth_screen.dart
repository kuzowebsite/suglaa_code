import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart'; // Biometric package
import '../utils/app_colors.dart';
import '../services/mock_wallet_service.dart'; // Энд Auth болон Wallet service хоёулаа байгаа
import '../layout/main_layout.dart';

// Дэлгэцийн төлөвүүд
enum AuthState {
  login,
  registerPhone,
  registerOTP,
  registerPassword,
  forgotPhone,
  forgotOTP,
  forgotPassword,
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // Service-үүдийг дуудах
  final MockAuthService _authService = MockAuthService();
  final MockWalletService _walletService = MockWalletService();
  final LocalAuthentication auth = LocalAuthentication(); // Биометрик объект

  AuthState _currentState = AuthState.login;

  // Controller-ууд
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPassController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  // ШИНЭ: Referral Controller
  final TextEditingController _referralController = TextEditingController();

  String _tempPhone = ""; // Бүртгүүлэх явцад дугаарыг түр хадгалах

  // ШИНЭ: Checkbox state & Paste state
  bool _useReferral = false;
  bool _isPasteSuccess = false;

  void _switchState(AuthState newState) {
    setState(() {
      _currentState = newState;
      _phoneController.clear();
      _passwordController.clear();
      _otpController.clear();
      _newPassController.clear();
      _confirmPassController.clear();
      _referralController.clear();
      _useReferral = false; // Reset referral
    });
  }

  // --- PASTE LOGIC ---
  void _pasteReferralCode() async {
    ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null && data.text != null) {
      setState(() {
        _referralController.text = data.text!;
        _isPasteSuccess = true;
      });

      // 3 секундын дараа icon буцаах
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _isPasteSuccess = false;
          });
        }
      });
    }
  }

  // ==========================================
  // 1. БИОМЕТРЭЭР НЭВТРЭХ ЛОГИК
  // ==========================================
  void _loginWithBiometrics() async {
    bool authenticated = false;
    try {
      authenticated = await auth.authenticate(
        localizedReason: 'Нэвтрэхийн тулд хурууны хээгээ уншуулна уу',
        // ШИНЭ ХУВИЛБАРТ ИНГЭЖ БИЧНЭ:
        options: const AuthenticationOptions(
          biometricOnly: true,
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      debugPrint("Bio Error: $e");
      // FaceID/TouchID тохируулаагүй үед алдаа гарч болно
      _showError("Биометрик алдаа: Тохиргоо хийгдээгүй эсвэл цуцлагдлаа.");
      return;
    }

    if (authenticated) {
      String? savedPhone = _walletService.savedBiometricPhone;

      if (savedPhone != null && savedPhone.isNotEmpty) {
        _walletService.setLoggedInUser(savedPhone);

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainLayout()),
          );
        }
      } else {
        _showError("Биометрээр нэвтрэх мэдээлэл олдсонгүй. Кодоор нэвтэрнэ үү.");
      }
    }
  }

  // ==========================================
  // 2. ЭНГИЙН НЭВТРЭХ ЛОГИК (ЗАСВАР ОРУУЛСАН)
  // ==========================================
  void _handleLogin() async {
    final phone = _phoneController.text.trim();
    final pass = _passwordController.text.trim();

    if (phone.isEmpty || pass.isEmpty) {
      _showError("Утасны дугаар болон нууц үгээ оруулна уу");
      return;
    }

    bool success = _authService.login(phone, pass);

    if (success) {
      _walletService.setLoggedInUser(phone);

      // --- БИОМЕТР САНАЛ БОЛГОХ ---
      if (!_walletService.isBiometricEnabled) {
        bool? enableBio = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF25252A),
            title: const Text("Биометрик нэвтрэлт", style: TextStyle(color: Colors.white)),
            content: const Text(
              "Та дараагийн удаа биометрээр (FaceID/Хурууны хээ) нэвтрэх үү?",
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text("Үгүй", style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                child: const Text("Тийм", style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        );

        if (enableBio == true) {
          bool didAuth = false;
          try {
            // ЭНД БАС AuthenticationOptions АШИГЛАНА
            didAuth = await auth.authenticate(
              localizedReason: 'Идэвхжүүлэхийн тулд баталгаажуулна уу',
              options: const AuthenticationOptions(
                biometricOnly: true,
                useErrorDialogs: true,
                stickyAuth: true,
              ),
            );
          } catch (e) {
            debugPrint("Bio enable error: $e");
          }

          if (didAuth) {
            _walletService.setBiometricEnabled(true);
            _showSuccess("Биометрик амжилттай идэвхжлээ!");
          }
        }
      }
      // ----------------------------

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainLayout()),
        );
      }
    } else {
      if (mounted) {
        _showError("Утасны дугаар эсвэл нууц үг буруу байна");
      }
    }
  }

  // Бүртгэлийг дуусгах
  void _handleRegistrationComplete() {
    if (_newPassController.text.isNotEmpty && _newPassController.text == _confirmPassController.text) {

      // Auth Service-д шинэ хэрэглэгчийг бүртгэх
      _authService.registerUser(_tempPhone, _newPassController.text);

      // ШИНЭ: Найзын урилга ашигласан эсэхийг шалгах
      if (_useReferral && _referralController.text.isNotEmpty) {
        _walletService.processReferralRegistration(_referralController.text);
        // Зурвас харуулах
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Амжилттай! Танд +50 оноо, Урьсан хүнд +100 оноо орлоо."),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        _showSuccess("Амжилттай бүртгэгдлээ. Нэвтэрнэ үү.");
      }

      _switchState(AuthState.login);
    } else {
      _showError("Нууц үг таарахгүй байна");
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.red,
      behavior: SnackBarBehavior.floating,
    ));
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.green,
      behavior: SnackBarBehavior.floating,
    ));
  }

  // --- WIDGET BUILDERS ---

  Widget _buildTextField(TextEditingController controller, String label, IconData icon,
      {bool isObscure = false, bool isNumber = false, bool isCenter = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: const Color(0xFF202025),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
      ),
      child: TextField(
        controller: controller,
        obscureText: isObscure,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(8)] : null,
        textAlign: isCenter ? TextAlign.center : TextAlign.start,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          icon: isCenter ? null : Padding(padding: const EdgeInsets.only(left: 15), child: Icon(icon, color: Colors.grey, size: 20)),
          border: InputBorder.none,
          hintText: label,
          hintStyle: const TextStyle(color: Colors.grey),
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    switch (_currentState) {

      // 1. НЭВТРЭХ
      case AuthState.login:
        content = Column(
          children: [
            const Text("Нэвтрэх", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            _buildTextField(_phoneController, "Утасны дугаар", Icons.phone, isNumber: true),
            _buildTextField(_passwordController, "Нууц үг", Icons.lock, isObscure: true),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _switchState(AuthState.forgotPhone),
                child: const Text("Нууц үгээ мартсан?", style: TextStyle(color: Colors.grey)),
              ),
            ),
            const SizedBox(height: 20),
            _buildButton("Нэвтрэх", _handleLogin),

            // --- БИОМЕТРИК ТОВЧ (ХЭРЭВ ИДЭВХЖСЭН БОЛ) ---
            if (_walletService.isBiometricEnabled) ...[
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _loginWithBiometrics,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueAccent.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.blueAccent.withOpacity(0.1),
                  ),
                  child: const Icon(Icons.fingerprint, size: 40, color: Colors.blueAccent),
                ),
              ),
            ],
            // ---------------------------------------------

            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Хаяг байхгүй юу?", style: TextStyle(color: Colors.grey)),
                TextButton(
                  onPressed: () => _switchState(AuthState.registerPhone),
                  child: const Text("Бүртгүүлэх", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        );
        break;

      // 2. БҮРТГҮҮЛЭХ - УТАС
      case AuthState.registerPhone:
        content = Column(
          children: [
            const Text("Бүртгүүлэх", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            _buildTextField(_phoneController, "Утасны дугаар", Icons.phone, isNumber: true),
            const SizedBox(height: 20),
            _buildButton("Үргэлжлүүлэх", () {
              if (_phoneController.text.length == 8) {
                _tempPhone = _phoneController.text;
                _switchState(AuthState.registerOTP);
              } else {
                _showError("Утасны дугаараа зөв оруулна уу");
              }
            }),
            TextButton(
              onPressed: () => _switchState(AuthState.login),
              child: const Text("Буцах", style: TextStyle(color: Colors.grey)),
            ),
          ],
        );
        break;

      // 3. БҮРТГҮҮЛЭХ - OTP
      case AuthState.registerOTP:
        content = Column(
          children: [
            const Text("Баталгаажуулах", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("Таны $_tempPhone дугаарт ирсэн кодыг оруулна уу", style: const TextStyle(color: Colors.grey), textAlign: TextAlign.center),
            const SizedBox(height: 30),
            _buildTextField(_otpController, "0000", Icons.message, isNumber: true, isCenter: true),
            const SizedBox(height: 20),
            _buildButton("Баталгаажуулах", () {
              if (_otpController.text.length == 4) {
                _switchState(AuthState.registerPassword);
              } else {
                _showError("Код буруу байна");
              }
            }),
            TextButton(
              onPressed: () => _switchState(AuthState.registerPhone),
              child: const Text("Буцах", style: TextStyle(color: Colors.grey)),
            ),
          ],
        );
        break;

      // 4. БҮРТГҮҮЛЭХ - НУУЦ ҮГ (ШИНЭЧЛЭГДСЭН)
      case AuthState.registerPassword:
        content = Column(
          children: [
            const Text("Нууц үг зохиох", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            _buildTextField(_newPassController, "Шинэ нууц үг", Icons.lock, isObscure: true),
            _buildTextField(_confirmPassController, "Дахин оруулах", Icons.lock, isObscure: true),

            const SizedBox(height: 10),
            // --- REFERRAL CHECKBOX ---
            Row(
              children: [
                Checkbox(
                  value: _useReferral,
                  activeColor: Colors.amber,
                  checkColor: Colors.black,
                  onChanged: (val) {
                    setState(() {
                      _useReferral = val ?? false;
                    });
                  },
                ),
                const Text("Найзын урилга", style: TextStyle(color: Colors.white)),
              ],
            ),

            // --- REFERRAL INPUT FIELD ---
            if (_useReferral)
              Container(
                margin: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(color: const Color(0xFF202025), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.amber.withOpacity(0.5))),
                child: TextField(
                  controller: _referralController,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: InputDecoration(
                    icon: const Padding(padding: EdgeInsets.only(left: 15), child: Icon(Icons.link, color: Colors.amber, size: 20)),
                    border: InputBorder.none,
                    hintText: "Линк оруулах",
                    hintStyle: const TextStyle(color: Colors.grey),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    // PASTE ICON
                    suffixIcon: IconButton(
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _isPasteSuccess
                            ? const Icon(Icons.check_circle, color: Colors.greenAccent, key: ValueKey(1))
                            : const Icon(Icons.content_paste, color: Colors.white54, key: ValueKey(2)),
                      ),
                      onPressed: _pasteReferralCode,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 20),
            _buildButton("Дуусгах", _handleRegistrationComplete),
          ],
        );
        break;

      // 5. БУСАД (Password Reset - Forgot logic)
      default:
        content = Column(
          children: [
            const Text("Нууц үг сэргээх", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            const Text("Энэ хэсэгт нууц үг сэргээх форм байна (OTP, New Password г.м)", style: TextStyle(color: Colors.grey), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => _switchState(AuthState.login),
              child: const Text("Буцах", style: TextStyle(color: Colors.grey)),
            ),
          ],
        );
    }

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: content,
        ),
      ),
    );
  }
}