import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:local_auth/local_auth.dart';
import 'package:image_picker/image_picker.dart';

import '../utils/app_colors.dart';
import '../services/mock_wallet_service.dart';
import '../screens/auth_screen.dart';
import '../screens/bank_account_screen.dart';
import '../screens/reward_points_screen.dart';
import '../screens/my_lottery_screen.dart';
import '../screens/change_password_screen.dart';
import '../screens/invite_friend_screen.dart';
import '../screens/profile/terms_conditions_screen.dart';
import '../screens/profile/privacy_policy_screen.dart';
import '../screens/profile/contact_us_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final MockWalletService _walletService = MockWalletService();
  final LocalAuthentication auth = LocalAuthentication();
  final ImagePicker _picker = ImagePicker();

  String _realNameFromDAN = "М.Бат-Ирээдүй"; 
  late TextEditingController _appVisibleNameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  
  File? _tempSelectedImage;

  bool _isBiometricEnabled = false;
  bool _isNotificationEnabled = true;
  bool _isRealNameVerified = false; 
  bool _isEmailVerified = false;

  @override
  void initState() {
    super.initState();
    _appVisibleNameController = TextEditingController(text: _walletService.currentName ?? "");
    _phoneController = TextEditingController(text: _walletService.currentPhone);
    _emailController = TextEditingController(text: "m.batireedui@andsoft.com");
    _isBiometricEnabled = _walletService.isBiometricEnabled;
  }

  @override
  void dispose() {
    _appVisibleNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // --- LOGIC ---

  Future<bool> _simulateDANRequest(BuildContext context, String title) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue[900]!, width: 2),
                  borderRadius: BorderRadius.circular(8)
                ),
                child: Text("ДАН", style: TextStyle(color: Colors.blue[900], fontWeight: FontWeight.bold, fontSize: 24)),
              ),
              const SizedBox(height: 20),
              const CircularProgressIndicator(color: Color(0xFF005EB8)),
              const SizedBox(height: 20),
              Text("$title...", style: const TextStyle(color: Colors.black87)),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 2));
    if (context.mounted) Navigator.pop(context);
    return true; 
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _tempSelectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  void _saveProfile() {
    String? finalPhotoPath;
    if (_tempSelectedImage != null) {
      finalPhotoPath = _tempSelectedImage!.path;
    } else {
      finalPhotoPath = _walletService.profileUrl;
    }

    _walletService.updateProfile(
      name: _appVisibleNameController.text.trim(),
      photoUrl: finalPhotoPath,
    );
    
    setState(() {
      _tempSelectedImage = null;
    });

    Navigator.pop(context); 
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Мэдээлэл амжилттай хадгалагдлаа!"),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  ImageProvider _getImageProvider(String? path) {
    if (path == null || path.isEmpty) {
      return const AssetImage("assets/images/placeholder.png"); 
    }
    if (path.startsWith('http')) {
      return NetworkImage(path);
    } else {
      return FileImage(File(path));
    }
  }

  // --- ЗАСВАР ОРУУЛСАН ХЭСЭГ: BottomSheet ---
  void _showEditBottomSheet() {
    _tempSelectedImage = null; 
    _appVisibleNameController.text = _walletService.currentName ?? "";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder( 
        builder: (context, setSheetState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.85, 
            decoration: const BoxDecoration(
              color: Color(0xFF1E1E24),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
            ),
            // Padding-ийг дотор нь өгөхгүй, Column дотор өгнө
            child: Column(
              children: [
                
                // 1. ТОЛГОЙ ХЭСЭГ (FIXED - Хөдлөхгүй)
                Padding(
                  padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
                  child: Column(
                    children: [
                      Center(
                        child: Container(
                          width: 40, height: 4,
                          decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text("Мэдээлэл засах", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),

                // 2. ДУНД ХЭСЭГ (SCROLLABLE - Гүйдэг)
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        
                        // IMAGE PICKER
                        Center(
                          child: Stack(
                            children: [
                              Container(
                                width: 100, height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white10,
                                  border: Border.all(color: Colors.white24, width: 1),
                                  image: (_tempSelectedImage != null)
                                      ? DecorationImage(image: FileImage(_tempSelectedImage!), fit: BoxFit.cover)
                                      : (_walletService.profileUrl != null && _walletService.profileUrl!.isNotEmpty)
                                          ? DecorationImage(
                                              image: _getImageProvider(_walletService.profileUrl), 
                                              fit: BoxFit.cover
                                            )
                                          : null,
                                ),
                                child: (_tempSelectedImage == null && (_walletService.profileUrl == null || _walletService.profileUrl!.isEmpty))
                                    ? const Icon(Icons.person, size: 50, color: Colors.white30)
                                    : null,
                              ),
                              Positioned(
                                bottom: 0, right: 0,
                                child: GestureDetector(
                                  onTap: () async {
                                    await _pickImage();
                                    setSheetState(() {}); 
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                      color: Colors.blueAccent,
                                      shape: BoxShape.circle,
                                      boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 4)],
                                    ),
                                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // ДАН ХЭСЭГ
                        const Text("Хэрэглэгчийн нэр", style: TextStyle(color: Colors.white70, fontSize: 13)),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () async {
                            bool success = await _simulateDANRequest(context, "Улсын бүртгэлээс мэдээлэл татаж байна");
                            if (success) {
                              setSheetState(() {
                                _isRealNameVerified = true;
                                _realNameFromDAN = "Б.Болд-Эрдэнэ"; 
                              });
                            }
                          },
                          borderRadius: BorderRadius.circular(15),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: _isRealNameVerified ? Colors.green.withOpacity(0.5) : Colors.transparent),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _isRealNameVerified ? Icons.check_circle : Icons.fingerprint, 
                                  color: _isRealNameVerified ? Colors.green : Colors.blueAccent
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Text(
                                    _isRealNameVerified ? _realNameFromDAN : "ДАН-аар нэвтэрч нэр татах",
                                    style: TextStyle(
                                      color: _isRealNameVerified ? Colors.white : Colors.blueAccent,
                                      fontWeight: _isRealNameVerified ? FontWeight.bold : FontWeight.normal
                                    ),
                                  ),
                                ),
                                if (!_isRealNameVerified) const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 14),
                              ],
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 10, top: 5),
                          child: Text("Энэ нь таны Улсын бүртгэл дээрх албан ёсны нэр юм.", style: TextStyle(color: Colors.white30, fontSize: 11)),
                        ),
                        
                        const SizedBox(height: 20),

                        _buildLabel("Апп-д харагдах нэр"),
                        TextField(
                          controller: _appVisibleNameController,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration("Таны нэр (Nickname)", Icons.edit_outlined),
                        ),
                        const SizedBox(height: 20),
                        _buildLabel("Утас"),
                        TextField(
                          controller: _phoneController,
                          readOnly: true,
                          style: const TextStyle(color: Colors.grey), 
                          decoration: _inputDecoration("Утасны дугаар", Icons.phone_iphone, isReadOnly: true),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // И-мэйл хэсэг
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("И-мэйл хаяг", style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: _isEmailVerified ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _isEmailVerified ? "Баталгаажсан" : "Баталгаажаагүй",
                                style: TextStyle(color: _isEmailVerified ? Colors.green : Colors.orange, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _emailController,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration("name@example.com", Icons.email_outlined),
                        ),
                        
                        if (!_isEmailVerified)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: SizedBox(
                              width: double.infinity,
                              height: 45,
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  bool success = await _simulateDANRequest(context, "И-мэйл хаягийг баталгаажуулж байна");
                                  if (success) {
                                    setSheetState(() => _isEmailVerified = true);
                                  }
                                },
                                icon: const Icon(Icons.fingerprint, color: Colors.blueAccent, size: 18),
                                label: const Text("ДАН-аар баталгаажуулах", style: TextStyle(color: Colors.blueAccent)),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.blueAccent.withOpacity(0.5)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                          ),

                        const SizedBox(height: 30), // Товч доор орохгүйн тулд зай авна
                      ],
                    ),
                  ),
                ),

                // 3. ХАДГАЛАХ ТОВЧ (FIXED - Хөдлөхгүй)
                Padding(
                  // Keyboard гарч ирэхэд товчийг дээшлүүлнэ
                  padding: EdgeInsets.only(
                    left: 20, 
                    right: 20, 
                    top: 10, 
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black, 
                        foregroundColor: Colors.white, 
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        side: const BorderSide(color: Colors.white, width: 1.5),
                      ),
                      child: const Text("Хадгалах", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon, {bool isReadOnly = false}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white30),
      filled: true,
      fillColor: isReadOnly ? Colors.transparent : Colors.white.withOpacity(0.05),
      prefixIcon: Icon(icon, color: isReadOnly ? Colors.grey : Colors.white54),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: isReadOnly ? const BorderSide(color: Colors.white10) : BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: isReadOnly ? const BorderSide(color: Colors.white10) : BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: isReadOnly ? const BorderSide(color: Colors.white10) : const BorderSide(color: Colors.blueAccent)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final phone = _walletService.currentPhone;
    final displayName = _walletService.currentName ?? "Нэр оруулаагүй";
    final photoPath = _walletService.profileUrl;
    final balance = _walletService.balance;
    final points = _walletService.points;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Хувийн мэдээлэл", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PROFILE HEADER
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24, width: 2),
                          image: (photoPath != null && photoPath.isNotEmpty)
                              ? DecorationImage(image: _getImageProvider(photoPath), fit: BoxFit.cover)
                              : null,
                          color: Colors.white10,
                        ),
                        child: (photoPath == null || photoPath.isEmpty)
                            ? const Icon(Icons.person, size: 40, color: Colors.white54)
                            : null,
                      ),
                      Positioned(
                        bottom: 0, right: 0,
                        child: GestureDetector(
                          onTap: _showEditBottomSheet,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
                            child: const Icon(Icons.edit, color: Colors.white, size: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(displayName, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        if (_isRealNameVerified)
                           Padding(
                             padding: const EdgeInsets.only(bottom: 5),
                             child: Row(
                               children: [
                                 const Icon(Icons.verified, color: Colors.green, size: 12),
                                 const SizedBox(width: 4),
                                 Text(_realNameFromDAN, style: const TextStyle(color: Colors.green, fontSize: 12)),
                               ],
                             ),
                           ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(20)),
                          child: Text(phone, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // STATS CARD
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF202025), Color(0xFF25252A)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem("Үлдэгдэл", "$balance₮"),
                  Container(width: 1, height: 40, color: Colors.white10),
                  _buildStatItem("Оноо", "$points P"),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // MENU ITEMS
            _buildSectionTitle("Үндсэн"),
            _buildMenuItem(
              Icons.account_balance_wallet_outlined, 
              "Банкны данс",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BankAccountScreen()),
                );
              },
            ),
            _buildMenuItem(
  Icons.stars_outlined, 
  "Урамшууллын оноо", 
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RewardPointsScreen()),
    );
  }
),

_buildMenuItem(
  Icons.confirmation_number_outlined, 
  "Миний сугалаа", 
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MyLotteryScreen()),
    );
  }
),

_buildMenuItem(
  Icons.person_add_alt_1_outlined, 
  "Найзаа урих", 
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const InviteFriendScreen()),
    );
  }
),

            const SizedBox(height: 20),

            _buildSectionTitle("Тохиргоо"),
            _buildMenuItem(
              Icons.fingerprint, 
              "Биометрик нэвтрэлт", 
              isToggle: true,
              switchValue: _isBiometricEnabled,
              onToggle: (val) async {
                  if (val) {
                    try {
                      final bool didAuth = await auth.authenticate(
                        localizedReason: 'Баталгаажуулах',
                        options: const AuthenticationOptions(stickyAuth: true, biometricOnly: true),
                      );
                      if (didAuth) {
                        setState(() => _isBiometricEnabled = true);
                        _walletService.setBiometricEnabled(true);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Биометрик идэвхэжлээ")));
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Алдаа гарлаа")));
                    }
                  } else {
                    setState(() => _isBiometricEnabled = false);
                    _walletService.setBiometricEnabled(false);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Биометрик идэвхгүй боллоо")));
                  }
              },
            ),
             _buildMenuItem(
              Icons.notifications_outlined, 
              "Мэдэгдэл хүлээн авах", 
              isToggle: true,
              switchValue: _isNotificationEnabled,
              onToggle: (val) => setState(() => _isNotificationEnabled = val),
            ),
            _buildMenuItem(
  Icons.lock_outline, 
  "Нууц үг солих", 
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
    );
  }
),

            const SizedBox(height: 20),

            _buildSectionTitle("Бусад"),

            _buildMenuItem(
  Icons.description_outlined, 
  "Үйлчилгээний нөхцөл", 
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TermsConditionsScreen()),
    );
  }
),

 _buildMenuItem(
  Icons.privacy_tip_outlined, 
  "Нууцлалын бодлого", 
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
    );
  }
),

 _buildMenuItem(
  Icons.headset_mic_outlined, 
  "Холбоо барих", 
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ContactUsScreen()),
    );
  }
),
            
            const SizedBox(height: 30),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                   showDialog(
                     context: context,
                     builder: (ctx) => AlertDialog(
                       backgroundColor: const Color(0xFF25252A),
                       title: const Text("Гарах", style: TextStyle(color: Colors.white)),
                       content: const Text("Гарахдаа итгэлтэй байна уу?", style: TextStyle(color: Colors.white70)),
                       actions: [
                         TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Үгүй", style: TextStyle(color: Colors.grey))),
                         ElevatedButton(
                           onPressed: () {
                             Navigator.pop(ctx);
                             _walletService.logout();
                             Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const AuthScreen()), (_) => false);
                           },
                           style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                           child: const Text("Тийм", style: TextStyle(color: Colors.white)),
                         ),
                       ],
                     ),
                   );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C1E1E), 
                  foregroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 0,
                  side: BorderSide(color: Colors.redAccent.withOpacity(0.2)),
                ),
                child: const Text("Гарах", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 10),
      child: Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildMenuItem(
    IconData icon, 
    String title, 
    {
      VoidCallback? onTap, 
      bool isToggle = false, 
      bool switchValue = false,
      Function(bool)? onToggle
    }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF202025),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.03)),
      ),
      child: ListTile(
        onTap: isToggle ? null : onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 2),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white70, size: 20),
        ),
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 15)),
        trailing: isToggle 
          ? Switch(
              value: switchValue, 
              onChanged: onToggle, 
              activeThumbColor: Colors.blueAccent,
              activeTrackColor: Colors.blueAccent.withOpacity(0.3),
              inactiveThumbColor: Colors.grey,
              inactiveTrackColor: Colors.white10,
            )
          : const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 14),
      ),
    );
  }
}