import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cart_model.dart'; // تأكد من استيراد CartModel هنا
import 'BackgroundWidget.dart'; // تأكد من استيراد BackgroundWidget هنا

class CartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cartModel = context.watch<CartModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'السلة',
          style: TextStyle(color: Color(0xFF6A5096)), // تغيير لون النص إلى الأصفر
        ),
        backgroundColor: Colors.green, // تغيير الخلفية إلى الأخضر
        centerTitle: true, // محاذاة النص في المنتصف
        elevation: 0,
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (DragEndDetails details) {
          if (details.primaryVelocity != null && details.primaryVelocity! > 0) {
            // إذا كانت السحبة من اليسار إلى اليمين
            Navigator.pop(context);
          }
        },
        child: BackgroundWidget( // إضافة BackgroundWidget هنا
          child: cartModel.cartItems.isEmpty
              ? Center(
            child: Text(
              'السلة فارغة',
              style: TextStyle(
                fontSize: 22,
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
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 3,
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: cartItem['image'] != null && cartItem['image']!.isNotEmpty
                              ? Image.network(
                            cartItem['image'], // عرض صورة المنتج من Firebase Storage
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                              : Image.asset(
                            'assets/default_image.png', // صورة افتراضية
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(
                          cartItem['name'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green, // النص باللون الأخضر
                          ),
                        ),
                        subtitle: Text(
                          'السعر: ${cartItem['price']} د.أ',
                          style: TextStyle(color: Colors.green), // تغيير اللون إلى الأخضر
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () {
                            context.read<CartModel>().removeItem(index);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('تم حذف المنتج من السلة')),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'السعر الإجمالي: ${cartModel.getTotalPrice()} د.أ',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.green, // تغيير اللون إلى الأخضر
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/payment');
                      },
                      icon: Icon(Icons.payment, color: Color(0xFF6A5096)), // تغيير لون الأيقونة إلى الأصفر
                      label: Text(
                        'الذهاب إلى الدفع',
                        style: TextStyle(color: Color(0xFF6A5096)), // تغيير لون النص إلى الأصفر
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        backgroundColor: Colors.green, // تغيير اللون الخلفية إلى الأخضر
                        foregroundColor: Color(0xFF6A5096), // تغيير لون النص إلى الأصفر
                      ),

                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/');
        },
        child: Icon(Icons.home, color: Color(0xFF6A5096)), // تغيير لون الأيقونة إلى الأصفر
        backgroundColor: Colors.green, // تغيير خلفية الأيقونة إلى الأخضر
      ),
    );
  }
}
