import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cart_model.dart';
import 'BackgroundWidget.dart'; // استيراد الويدجت الخاص بالخلفية
import 'filtered_products_page.dart' ;


class ProductDetailsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final productDetails = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final productName = productDetails['name']!;
    final productPrice = double.tryParse(productDetails['price'].toString()) ?? 0.0;
    final productImage = productDetails['image']!;
    final productType = productDetails['type']!;
    final productWeight = productDetails['weight']!;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'تفاصيل المنتج',
          style: TextStyle(
            color: Color(0xFF6A5096),  // تغيير لون النص إلى اللون الأصفر
          ),
        ),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (DragEndDetails details) {
          if (details.primaryVelocity != null && details.primaryVelocity! > 0) {
            // إذا كانت السحبة من اليسار إلى اليمين
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FilteredProductsPage(filterType: productType),
              ),
            );
          }
        },
        child: BackgroundWidget(
          child: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FullScreenImagePage(imageUrl: productImage),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
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
                          child: Image.network(
                            productImage,
                            width: 250,
                            height: 250,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      productName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 9),
                    Text(
                      'السعر: د.أ ${productPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      'النوع: $productType',
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      'الوزن: $productWeight',
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        context.read<CartModel>().addToCart(productName, productPrice, productImage);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تمت الإضافة إلى السلة')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'إضافة إلى السلة',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/products');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'العودة إلى صفحة المنتجات',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/cart');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'الذهاب إلى السلة',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
class FullScreenImagePage extends StatelessWidget {
  final String imageUrl;

  FullScreenImagePage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('صورة المنتج',
          style: TextStyle(color: Color(0xFF6A5096)),
        ),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (DragEndDetails details) {
          if (details.primaryVelocity != null && details.primaryVelocity! > 0) {
            // إذا كانت السحبة من اليسار إلى اليمين
            Navigator.pop(context);
          }
        },
        child: Center(
          child: InteractiveViewer(
            child: Image.network(imageUrl),
          ),
        ),
      ),
    );
  }
}
