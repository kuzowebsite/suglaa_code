import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart'; // WebView багц
import '../../utils/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  late final WebViewController _controller;

  // ТАНЫ ХҮССЭН IFRAME LINK (src доторх хэсэг)
  // Жишээ нь: Улаанбаатар хотын төв цэгийг заасан Embed Link.
  // Та Google Maps дээр Share -> Embed a map гэж байгаад src="..." хэсгийг нь хуулж энд тавиарай.
  final String _googleMapEmbedUrl = "https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d2674.1217542164927!2d106.9245480755631!3d47.914681566653684!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x5d96930005f33a7f%3A0xa9573ad5473e1d8a!2z0KLTqdCyINGI0YPRg9C00LDQvQ!5e0!3m2!1sen!2smn!4v1766116363099!5m2!1sen!2smn";

  @override
  void initState() {
    super.initState();

    // WebView Controller тохиргоо
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000)) // Тунгалаг дэвсгэр
      ..loadHtmlString(_buildHtmlContent(_googleMapEmbedUrl));
  }

  // Iframe-ийг HTML хуудас болгож бэлтгэх функц
  String _buildHtmlContent(String embedUrl) {
    return '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
          body, html { margin: 0; padding: 0; height: 100%; width: 100%; background-color: #202025; }
          iframe { border: 0; width: 100%; height: 100%; }
        </style>
      </head>
      <body>
        <iframe 
          src="$embedUrl" 
          allowfullscreen="" 
          loading="lazy" 
          referrerpolicy="no-referrer-when-downgrade">
        </iframe>
      </body>
      </html>
    ''';
  }

  void _callPhone() => launchUrl(Uri.parse("tel:+97680901860"));
  void _sendEmail() => launchUrl(Uri.parse("mailto:hello@andsoft.com"));
  void _openFacebook() => launchUrl(Uri.parse("https://facebook.com/AndSoftLLC"));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Холбоо барих", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // --- HEADER ---
            const Icon(Icons.support_agent, color: Colors.amber, size: 60),
            const SizedBox(height: 15),
            const Text(
              "Танд тусламж хэрэгтэй юу?",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text(
              "Бидэнтэй дараах сувгуудаар холбогдоорой",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 30),

            // --- CONTACT LIST ---
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF202025),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  _buildContactItem(Icons.phone, "(+976) 80901860", _callPhone, Colors.green),
                  const Divider(color: Colors.white10, indent: 60, endIndent: 20),
                  _buildContactItem(Icons.email, "hello@andsoft.com", _sendEmail, Colors.redAccent),
                  const Divider(color: Colors.white10, indent: 60, endIndent: 20),
                  _buildContactItem(Icons.facebook, "Facebook хуудас", _openFacebook, Colors.blue),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // --- ADDRESS ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on, color: Colors.amber, size: 28),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Хаяг байршил",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Улаанбаатар хот, Сүхбаатар дүүрэг, 1-р хороо Embassy One бизнес оффис, 10 давхар",
                          style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- GOOGLE MAP (WEBVIEW IFRAME) ---
            Container(
              height: 300,
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24, width: 1),
                color: const Color(0xFF202025), // Map ачаалж байх үеийн өнгө
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: WebViewWidget(controller: _controller),
              ),
            ),
            
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text, VoidCallback onTap, Color color) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}