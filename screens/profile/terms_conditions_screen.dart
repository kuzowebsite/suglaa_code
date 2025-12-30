import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground, // Хар дэвсгэр
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Үйлчилгээний нөхцөл", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                  const Icon(Icons.gavel, color: Colors.amber, size: 50),
                  const SizedBox(height: 15),
                  const Text(
                    '"AndSoft LLC"\nХОНЖВОРТ СУГАЛААНЫ\nҮЙЛЧИЛГЭЭНИЙ НӨХЦӨЛ',
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
                      "Нийтлэсэн огноо: 2025 оны 12-р сарын 14-ний өдөр",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            
            // --- CONTENT ---
            _buildSectionTitle("1. ЕРӨНХИЙ НӨХЦӨЛ"),
            _buildParagraph(
              "1.1. Энэхүү үйлчилгээний нөхцөл (цаашид 'Нөхцөл' гэх) нь 'AndSoft LLC' (цаашид 'Компани' гэх) болон түүний хөгжүүлсэн хонжворт сугалааны аппликейшн (цаашид 'Үйлчилгээ' гэх)-ийг ашиглаж буй иргэн, хуулийн этгээд (цаашид 'Хэрэглэгч' гэх) хоорондын харилцааг зохицуулна."
            ),
            _buildParagraph(
              "1.2. Хэрэглэгч нь энэхүү Аппликейшнд бүртгүүлснээр энэхүү Нөхцөлийг бүрэн эхээр нь хүлээн зөвшөөрсөнд тооцогдоно."
            ),
            _buildParagraph(
              "1.3. Компани нь энэхүү Нөхцөлд нэмэлт, өөрчлөлт оруулах эрхтэй бөгөөд өөрчлөлт орсон тухай бүрд Аппликейшнаар дамжуулан Хэрэглэгчдэд мэдэгдэнэ."
            ),

            _buildSectionTitle("2. БҮРТГЭЛ БА АЮУЛГҮЙ БАЙДАЛ"),
            _buildParagraph(
              "2.1. Үйлчилгээг ашиглахын тулд Хэрэглэгч өөрийн гар утасны дугаараар бүртгүүлэх шаардлагатай."
            ),
            _buildParagraph(
              "2.2. Хэрэглэгч нь өөрийн нэвтрэх нэр, нууц үг, гүйлгээний ПИН код зэрэг мэдээллийн нууцлалыг хадгалах үүрэгтэй."
            ),
            _buildParagraph(
              "2.3. Буруутай үйлдлийн улмаас өөрийн бүртгэлийг гуравдагч этгээдэд алдсан тохиолдолд Компани хариуцлага хүлээхгүй."
            ),
            _buildParagraph(
              "2.4. Хэрэглэгч нь зөвхөн нэг удаа, өөрийн нэр дээр бүртгэл үүсгэх эрхтэй. Давхардсан бүртгэл илэрвэл Компани тухайн бүртгэлийг түдгэлзүүлэх эрхтэй."
            ),

            _buildSectionTitle("3. ТӨЛБӨР ТООЦОО БА ЦЭНЭГЛЭЛТ"),
            _buildParagraph(
              "3.1. Сугалааны тасалбар худалдан авах төлбөрийг 'AndSoft Wallet' буюу цахим түрүүвчээр дамжуулан хийнэ."
            ),
            _buildParagraph(
              "3.2. Цахим түрүүвчийг банкны карт, дотоодын банкны шилжүүлэг болон QPay үйлчилгээгээр цэнэглэх боломжтой."
            ),
            _buildParagraph(
              "3.3. Буруу данс руу шилжүүлэг хийсэн, гүйлгээний утга буруу бичсэн тохиолдолд үүсэх хохирлыг Компани хариуцахгүй."
            ),
            _buildParagraph(
              "3.4. Төлбөр төлөгдсөн тасалбарыг буцаах, цуцлах боломжгүй."
            ),

            _buildSectionTitle("4. СУГАЛАА БА ШАГНАЛ"),
            _buildParagraph(
              "4.1. Сугалааны тохирол нь санамсаргүй тоо үүсгэх (RNG) технологи болон шууд дамжуулалтаар ил тод явагдана."
            ),
            _buildParagraph(
              "4.2. Хэрэглэгч хожсон тохиолдолд шагналаа авахдаа өөрийн биеийн байцаалтыг (Иргэний үнэмлэх) авч ирэх үүрэгтэй."
            ),
            _buildParagraph(
              "4.3. Шагнал авах хугацаа нь тохирол явагдсанаас хойш хуанлийн 30 хоног байна. Энэ хугацаанд шагналаа аваагүй тохиолдолд хүчингүйд тооцно."
            ),
            _buildParagraph(
              "4.4. 18 нас хүрээгүй хүн сугалаанд оролцох, шагнал авах эрхгүй."
            ),

            _buildSectionTitle("5. ОНОО ЦУГЛУУЛАХ БА УРАМШУУЛАЛ"),
            _buildParagraph(
              "5.1. Хэрэглэгч нь сугалаа худалдан авалт, өдөр тутмын идэвх болон найзаа урих замаар оноо цуглуулах боломжтой."
            ),
            _buildParagraph(
              "5.2. Цуглуулсан оноог бэлэн мөнгө болгон хувиргах эсвэл сугалааны тасалбар худалдан авахад ашиглаж болно. (Ханш: 1,000 оноо = 100₮)"
            ),
            _buildParagraph(
              "5.3. Компани нь урьдчилан мэдэгдэхгүйгээр онооны журамд өөрчлөлт оруулах эрхтэй."
            ),

            _buildSectionTitle("6. ХУВИЙН МЭДЭЭЛЛИЙН НУУЦЛАЛ"),
            _buildParagraph(
              "6.1. Компани нь Хэрэглэгчийн хувийн мэдээллийг Монгол Улсын 'Хувь хүний мэдээлэл хамгаалах тухай хууль'-ийн дагуу нууцлан хадгална."
            ),
            _buildParagraph(
              "6.2. Хэрэглэгчийн зөвшөөрөлгүйгээр хувийн мэдээллийг гуравдагч этгээдэд дамжуулахгүй (Хуулийн байгууллагын шаардлагаас бусад тохиолдолд)."
            ),

            _buildSectionTitle("7. ХОРИГЛОХ ЗҮЙЛС"),
            _buildParagraph(
              "7.1. Аппликейшны үйл ажиллагаанд санаатайгаар саад учруулах, хакердах оролдлого хийх."
            ),
            _buildParagraph(
              "7.2. Бусдын нэр, хувийн мэдээллийг ашиглан бүртгэл үүсгэх."
            ),
            _buildParagraph(
              "7.3. Мөнгө угаах болон бусад хууль бус үйл ажиллагаанд ашиглах."
            ),

            _buildSectionTitle("8. ХАРИУЦЛАГА"),
            _buildParagraph(
              "8.1. Интернэтийн тасалдал, банкны системийн саатал зэрэг Компаниас үл хамаарах шалтгаанаар үүссэн хохирлыг Компани хариуцахгүй."
            ),
            _buildParagraph(
              "8.2. Хэрэглэгч энэхүү Нөхцөлийг зөрчсөний улмаас үүсэх аливаа хохирол, хуулийн хариуцлагыг өөрөө бүрэн хариуцна."
            ),

            _buildSectionTitle("9. БУСАД"),
            _buildParagraph(
              "9.1. Энэхүү Нөхцөлтэй холбоотой маргааныг талууд харилцан зөвшилцөх замаар шийдвэрлэнэ."
            ),
            _buildParagraph(
              "9.2. Зөвшилцөлд хүрч чадаагүй тохиолдолд Монгол Улсын шүүхээр шийдвэрлүүлнэ."
            ),
            _buildParagraph(
              "9.2.1. Үйлчилгээний нөхцөл хүчин төгөлдөр болох хугацаа: 2025.12.14."
            ),
            _buildParagraph(
              "9.2.2. Холбоо барих: Info@andsoft.mn, Утас: 7700-XXXX."
            ),

            const SizedBox(height: 40),
            
            // --- FOOTER BUTTON ---
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
                child: const Text("ОЙЛГОЛОО, ХҮЛЭЭН ЗӨВШӨӨРЧ БАЙНА", style: TextStyle(fontWeight: FontWeight.bold)),
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
          height: 1.6, // Мөр хоорондын зай
        ),
      ),
    );
  }
}