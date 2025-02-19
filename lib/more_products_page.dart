import 'package:flutter/material.dart';
import 'filtered_products_page.dart';  // تأكد من استيراد الصفحة الثانية
import 'BackgroundWidget.dart';  // تأكد من استيراد الـ BackgroundWidget
import 'home_page.dart';  // استيراد الصفحة الرئيسية
import 'cart_page.dart';  // تأكد من استيراد صفحة السلة

class MoreProductsPage extends StatelessWidget {
  // دالة للانتقال إلى صفحة المنتجات المفلترة بناءً على النوع المختار
  void _openFilteredProductsPage(BuildContext context, String filterType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FilteredProductsPage(filterType: filterType),
      ),
    );
  }

  // دالة للانتقال إلى الصفحة الرئيسية
  void _goToHomePage(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),  // الصفحة الرئيسية
          (Route<dynamic> route) => false,  // إزالة جميع الصفحات السابقة
    );
  }

  // دالة للانتقال إلى صفحة السلة
  void _goToCartPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CartPage()),  // انتقل إلى صفحة السلة
    );
  }

  // دالة لعرض الأزرار
  Widget _buildFilterButton(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),  // زيادة المسافة بين الأزرار
      child: ElevatedButton(
        onPressed: () => _openFilteredProductsPage(context, label),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,  // الإبقاء على اللون الأخضر للخلفية
          foregroundColor: Color(0xFF6A5096),  // تغيير لون النص إلى اللون المطلوب
          padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0), // زيادة حجم الزر
          textStyle: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold), // تغيير حجم الخط
        ),
        child: Text(label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'اختر نوع المنتجات',
          style: TextStyle(color: Color(0xFF6A5096)),  // تعيين لون النص إلى الذهبي
        ),
        backgroundColor: Colors.green,
        centerTitle: true,  // محاذاة النص في المنتصف
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          // إذا كانت الحركة من اليسار إلى اليمين (drag من اليسار)
          if (details.primaryVelocity! > 0) {
            _goToHomePage(context);
          }
        },
        child: BackgroundWidget(  // إضافة BackgroundWidget كخلفية
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // عرض الأزرار في منتصف الصفحة
                Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    _buildFilterButton(context, 'خواتم'),
                    _buildFilterButton(context, 'ذبل'),
                    _buildFilterButton(context, 'سحبات'),
                    _buildFilterButton(context, 'أساور'),
                    _buildFilterButton(context, 'عقد'),
                    _buildFilterButton(context, 'حلق'),
                    _buildFilterButton(context, 'بيبي'),
                    _buildFilterButton(context, 'تعاليق'),
                    _buildFilterButton(context, 'تشكيلة'),
                  ],
                ),
                SizedBox(height: 20.0),  // إضافة مساحة فارغة قبل الزر
                ElevatedButton(
                  onPressed: () => _goToCartPage(context),  // الذهاب إلى صفحة السلة
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,  // لون الزر الأخضر للسلة
                    padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
                    textStyle: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  child: const Text(
                    'الذهاب إلى السلة',
                    style: TextStyle(color: Color(0xFF6A5096)),
                  ),
                ),
                SizedBox(height: 20.0),  // إضافة مساحة فارغة بعد الزر
                ElevatedButton(
                  onPressed: () => _goToHomePage(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,  // لون الزر الأخضر للعودة للصفحة الرئيسية
                    padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
                    textStyle: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  child: const Text(
                    'العودة إلى الصفحة الرئيسية',
                    style: TextStyle(color: Color(0xFF6A5096)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
