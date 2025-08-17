import 'package:flutter/material.dart';
import 'filtered_products_page.dart';
import 'BackgroundWidget.dart';
import 'home_page.dart';
import 'cart_page.dart';

class MoreProductsPage extends StatelessWidget {
  void _openFilteredProductsPage(BuildContext context, String filterType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FilteredProductsPage(filterType: filterType),
      ),
    );
  }

  void _goToHomePage(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
      (Route<dynamic> route) => false,
    );
  }

  void _goToCartPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CartPage()),
    );
  }

  Widget _buildFilterButton(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: 140, // حجم موحد
        height: 55,  // حجم موحد
        child: ElevatedButton(
          onPressed: () => _openFilteredProductsPage(context, label),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF800080),
            foregroundColor: Colors.white,
            padding: EdgeInsets.zero, // إزالة البادينج الداخلي
            textStyle: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), // بيضاوي
          ),
          child: Text(label, style: const TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'اختر نوع المنتجات',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
        backgroundColor: const Color(0xFF800080),
        centerTitle: true,
        elevation: 0,
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! > 0) {
            _goToHomePage(context);
          }
        },
        child: BackgroundWidget(
          imageUrl: 'assets/bk.png',
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
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
                  const SizedBox(height: 30.0),
                  _buildButton(context, 'الذهاب إلى السلة', Icons.shopping_cart, () => _goToCartPage(context)),
                  const SizedBox(height: 20.0),
                  _buildButton(context, ' الصفحة الرئيسية', Icons.home, () => _goToHomePage(context)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String label, IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: 220,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 25, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF800080),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
      ),
    );
  }
}
