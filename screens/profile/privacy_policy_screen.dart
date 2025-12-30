import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
        title: const Text("Нууцлалын бодлого", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER ---
            Center(
              child: Column(
                children: [
                  const Icon(Icons.security, color: Colors.amber, size: 50),
                  const SizedBox(height: 15),
                  const Text(
                    '"AndSoft LLC"\nХЭРЭГЛЭГЧИЙН МЭДЭЭЛЛИЙН\nНУУЦЛАЛЫН БОДЛОГО',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Сүүлд шинэчилсэн: 2025.12.14",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            
            // --- CONTENT ---
            _buildSectionTitle("1. НИЙТЛЭГ ҮНДЭСЛЭЛ"),
            _buildParagraph(
              "1.1. Энэхүү баримт бичиг нь 'AndSoft LLC' (цаашид 'Компани') нь хэрэглэгчийн хувийн мэдээллийг хэрхэн цуглуулах, ашиглах, хамгаалахтай холбоотой харилцааг зохицуулна."
            ),
            _buildParagraph(
              "1.2. Бид хэрэглэгчийн хувийн мэдээллийг Монгол Улсын 'Хувь хүний мэдээлэл хамгаалах тухай хууль'-ийн дагуу чандлан нууцална."
            ),

            _buildSectionTitle("2. ЦУГЛУУЛАХ МЭДЭЭЛЭЛ"),
            _buildParagraph(
              "2.1. Бүртгэл үүсгэхэд: Овог нэр, утасны дугаар, цахим шуудангийн хаяг."
            ),
            _buildParagraph(
              "2.2. Баталгаажуулалт: Шагнал олгох үед иргэний үнэмлэхийн хуулбар эсвэл регистрийн дугаар (Зөвхөн хуулийн дагуу татвар суутгах зорилгоор)."
            ),
            _buildParagraph(
              "2.3. Төхөөрөмжийн мэдээлэл: IP хаяг, үйлдлийн систем, төхөөрөмжийн загвар (Аппликейшны аюулгүй байдлыг хангах зорилгоор)."
            ),

            _buildSectionTitle("3. МЭДЭЭЛЛИЙГ АШИГЛАХ ЗОРИЛГО"),
            _buildParagraph(
              "3.1. Хэрэглэгчийг таньж баталгаажуулах, сугалааны тохирлын үнэн зөв байдлыг хангах."
            ),
            _buildParagraph(
              "3.2. Хэрэглэгчид шинэ бүтээгдэхүүн, урамшуулал, үйлчилгээний нөхцөлийн өөрчлөлтийн талаар мэдээлэл хүргэх."
            ),
            _buildParagraph(
              "3.3. Санхүүгийн гэмт хэрэг, залилангаас урьдчилан сэргийлэх."
            ),

            _buildSectionTitle("4. МЭДЭЭЛЛИЙН АЮУЛГҮЙ БАЙДАЛ"),
            _buildParagraph(
              "4.1. Бид хэрэглэгчийн мэдээллийг хамгаалахын тулд орчин үеийн шифрлэлтийн технологи (SSL/TLS) болон серверийн хамгаалалтыг ашигладаг."
            ),
            _buildParagraph(
              "4.2. Таны нууц үг системд шифрлэгдсэн хэлбэрээр хадгалагдах бөгөөд Компанийн ажилтнууд харах боломжгүй."
            ),

            _buildSectionTitle("5. МЭДЭЭЛЭЛ ДАМЖУУЛАХ"),
            _buildParagraph(
              "5.1. Бид хэрэглэгчийн хувийн мэдээллийг гуравдагч этгээдэд худалдахгүй, түрээслэхгүй."
            ),
            _buildParagraph(
              "5.2. Зөвхөн хууль хяналтын байгууллагын албан ёсны шаардлагаар эсвэл шүүхийн шийдвэрийн дагуу мэдээллийг гаргаж өгнө."
            ),

            _buildSectionTitle("6. ХЭРЭГЛЭГЧИЙН ЭРХ"),
            _buildParagraph(
              "6.1. Хэрэглэгч өөрийн бүртгэлтэй мэдээллээ харах, шинэчлэх эрхтэй."
            ),
            _buildParagraph(
              "6.2. Хэрэглэгч хүссэн үедээ бүртгэлээ устгуулах хүсэлт гаргаж болно. (Бүртгэл устсанаар цуглуулсан оноо болон эрхүүд устахыг анхаарна уу)."
            ),

            const SizedBox(height: 40),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("ОЙЛГОЛОО", style: TextStyle(fontWeight: FontWeight.bold)),
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
      padding: const EdgeInsets.only(top: 25, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.amber,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        textAlign: TextAlign.justify,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 14,
          height: 1.6,
        ),
      ),
    );
  }
}