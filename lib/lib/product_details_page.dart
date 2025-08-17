import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cart_model.dart';
import 'BackgroundWidget.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ProductDetailsPage extends StatelessWidget {
  const ProductDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final productDetails =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final productName = productDetails['name']!;
    final productPrice =
        double.tryParse(productDetails['price'].toString()) ?? 0.0;
    final productImage = productDetails['image']!;
    final productType = productDetails['type']!;
    final productWeight = productDetails['weight']!;

    final String webImageUrl =
        kIsWeb ? 'http://yourdomain.com/path/to/bk.png' : 'assets/bk.png';

    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'تفاصيل المنتج',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF800080),
        centerTitle: true,
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! > 0) {
            Navigator.pop(context);
          }
        },
        child: BackgroundWidget(
          imageUrl: webImageUrl,
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    textDirection: TextDirection.rtl,
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: IntrinsicWidth(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildLabelValueRow('الأسم:', productName, '', isSmallScreen: isSmallScreen),
                                  const SizedBox(height: 6),
                                  _buildLabelValueRow('الوزن:', '$productWeight', 'غم', isSmallScreen: isSmallScreen),
                                  const SizedBox(height: 6),
                                  _buildLabelValueRow('السعر:', '$productPrice', 'دينار', isBoldValue: true, isSmallScreen: isSmallScreen),
                                  const SizedBox(height: 6),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Container(
                        width: screenWidth * 0.4 > 240 ? 240 : screenWidth * 0.4,
                        height: screenWidth * 0.4 > 240 ? 240 : screenWidth * 0.4,
                        decoration: BoxDecoration(
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              offset: Offset(0, 4),
                              blurRadius: 8,
                            ),
                          ],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: GestureDetector(
                            onTap: () {
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) =>
                              //         FullScreenImagePage(imageUrl: productImage),
                              //   ),
                              // );
                            },
                            child: Image.network(
                              productImage,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: _buildElevatedButton(
                onPressed: () {
                  context.read<CartModel>().addToCart(
                        productName,
                        productPrice,
                        productImage,
                        productType,
                        productWeight,
                      );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تمت الإضافة إلى السلة')),
                  );
                },
                label: 'إضافة للسلة',
                isSmallScreen: isSmallScreen,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                label: 'المنتجات',
                isSmallScreen: isSmallScreen,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/cart');
                },
                label: ' السلة',
                isSmallScreen: isSmallScreen,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabelValueRow(
      String label,
      String value,
      String unit, {
        double fontSize = 20,
        bool isBoldValue = false,
        required bool isSmallScreen, // إضافة متغير الشاشة الصغيرة
      }) {
    return RichText(
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.right,
      text: TextSpan(
        style: TextStyle(
          // التعديل هنا ليكون حجم الخط متكيفًا
          fontSize: isSmallScreen ? 16 : 20,
          color: const Color(0xFF800080),
        ),
        children: <TextSpan>[
          TextSpan(
            text: '$label ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: value,
            style: TextStyle(fontWeight: isBoldValue ? FontWeight.w600 : FontWeight.normal),
          ),
          if (unit.isNotEmpty)
            TextSpan(
              text: ' $unit',
              style: TextStyle(fontWeight: isBoldValue ? FontWeight.w600 : FontWeight.normal),
            ),
        ],
      ),
    );
  }

  Widget _buildElevatedButton({
    required VoidCallback onPressed,
    required String label,
    required bool isSmallScreen,
  }) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF800080),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: isSmallScreen ? 13 : 18,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class FullScreenImagePage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImagePage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'صورة المنتج',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF800080),
        centerTitle: true,
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(imageUrl),
        ),
      ),
    );
  }
}
