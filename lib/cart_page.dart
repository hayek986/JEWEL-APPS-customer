import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'cart_model.dart';
import 'BackgroundWidget.dart';

class CartPage extends StatelessWidget {
  final String backgroundImageUrl = 'assets/bk.png';

  @override
  Widget build(BuildContext context) {
    final cartModel = context.watch<CartModel>();

    final String webImageUrl =
        kIsWeb ? 'http://yourdomain.com/path/to/bk.png' : backgroundImageUrl;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'السلة',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF800080), // بنفسجي
        centerTitle: true,
        elevation: 0,
      ),
      body: BackgroundWidget(
        imageUrl: webImageUrl,
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: cartModel.cartItems.isEmpty
                ? Center(
                    child: Text(
                      'السلة فارغة',
                      style: TextStyle(
                        fontSize: kIsWeb ? 28 : 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: cartModel.cartItems.length,
                          itemBuilder: (context, index) {
                            final cartItem = cartModel.cartItems[index];
                            return Card(
                              margin: EdgeInsets.symmetric(
                                  vertical: 8, horizontal: kIsWeb ? 32 : 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 3,
                              child: ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: cartItem['image'] != null &&
                                          cartItem['image']!.isNotEmpty
                                      ? Image.network(
                                          cartItem['image'],
                                          width: kIsWeb ? 80 : 50,
                                          height: kIsWeb ? 80 : 50,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.asset(
                                          'assets/default_image.png',
                                          width: kIsWeb ? 80 : 50,
                                          height: kIsWeb ? 80 : 50,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                                title: Text(
                                  cartItem['name'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF800080), // بنفسجي
                                    fontSize: kIsWeb ? 20 : 16,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'السعر: ${cartItem['price']} د.أ',
                                      style: TextStyle(
                                        color: const Color(0xFF800080), // بنفسجي
                                        fontSize: kIsWeb ? 18 : 14,
                                      ),
                                    ),
                                    if (cartItem.containsKey('weight') &&
                                        cartItem['weight'] != null)
                                      Text(
                                        'الوزن: ${cartItem['weight']}',
                                        style: TextStyle(
                                          color: const Color(0xFF800080), // بنفسجي
                                          fontSize: kIsWeb ? 18 : 14,
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete,
                                      color: Colors.redAccent,
                                      size: kIsWeb ? 30 : 24),
                                  onPressed: () {
                                    context.read<CartModel>().removeItem(index);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('تم حذف المنتج من السلة')),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.all(kIsWeb ? 32.0 : 16.0),
                        child: Column(
                          children: [
                            Text(
                              'السعر الإجمالي: ${cartModel.getTotalPrice()} د.أ',
                              style: TextStyle(
                                fontSize: kIsWeb ? 26 : 22,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF800080), // بنفسجي
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(context, '/payment');
                              },
                              icon: const Icon(
                                Icons.payment,
                                color: Color(0xFF800080), // بنفسجي
                                size: 30,
                              ),
                              label: Text(
                                'الذهاب إلى الدفع',
                                style: TextStyle(
                                  color: Colors.white, // أبيض
                                  fontSize: kIsWeb ? 20 : 16,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    vertical: kIsWeb ? 20 : 14,
                                    horizontal: kIsWeb ? 40 : 32),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                backgroundColor:
                                    const Color(0xFF800080), // بنفسجي
                                foregroundColor: const Color(0xFF800080),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
      floatingActionButton: kIsWeb
          ? null
          : FloatingActionButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Icon(Icons.arrow_back, color: Color(0xFF800080)),
              backgroundColor: const Color(0xFF800080),
            ),
    );
  }
}
