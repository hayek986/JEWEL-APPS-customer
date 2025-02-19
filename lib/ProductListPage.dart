import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_product_page.dart'; // تأكد من استيراد صفحة إضافة المنتج
import 'BackgroundWidget.dart'; // استيراد الـ BackgroundWidget

class ProductListPage extends StatelessWidget {
  // تدفق البيانات للحصول على المنتجات من Firestore
  Stream<List<Map<String, dynamic>>> _getProducts() {
    return FirebaseFirestore.instance.collection('products').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['name'],
          'price': doc['price'],
          'image': doc['image'],
        };
      }).toList();
    });
  }

  // الانتقال إلى صفحة تحرير المنتج مع معرف المنتج
  void _editProduct(BuildContext context, String productId) {
    Navigator.pushNamed(
      context,
      '/editProduct', // تعديل المسار بناءً على ما تم تحديده
      arguments: {'productId': productId},
    );
  }

  // الانتقال إلى صفحة إضافة منتج جديد
  void _addProduct(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddProductPage(), // التأكد من استخدام الكلاس الصحيح هنا
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        if (details.primaryDelta! > 0) {
          Navigator.pop(context); // This will handle the swipe to go back
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'قائمة المنتجات',
            style: TextStyle(color: Color(0xFF6A5096)),  // تعيين لون النص إلى اللون المحدد
          ),
          backgroundColor: Colors.green,  // تعيين اللون الأخضر في شريط العنوان
          centerTitle: true,  // محاذاة النص في المنتصف
          actions: [
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () => _addProduct(context), // زر إضافة منتج جديد
            ),
          ],
        ),
        body: BackgroundWidget(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: _getProducts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('لا توجد منتجات'));
              }

              final products = snapshot.data!;

              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // عرض 2 منتجات في كل صف
                  childAspectRatio: 0.75, // تعديل نسبة العرض إلى الارتفاع لتناسب العرض
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                padding: EdgeInsets.all(10),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];

                  return GestureDetector(
                    onTap: () => _editProduct(context, product['id']), // عند النقر على المنتج
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15), // حواف دائرية
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                            child: Image.network(
                              product['image'],
                              height: 150, // ارتفاع مناسب للصورة
                              fit: BoxFit.cover, // ضبط ملاءمة الصورة
                            ),
                          ),
                          Expanded( // إضافة Expanded لحل مشكلة overflow
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                product['name'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14, // تقليل حجم النص
                                  color: Colors.green, // اللون الذهبي
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              'السعر: ${product['price']} د.أ',
                              style: TextStyle(
                                color: Colors.green, // الأخضر
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
