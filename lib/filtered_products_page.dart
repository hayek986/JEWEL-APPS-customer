import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'BackgroundWidget.dart';
import 'more_products_page.dart';  // تأكد من استيراد صفحة more_products_page

class FilteredProductsPage extends StatelessWidget {
  final String filterType;

  FilteredProductsPage({required this.filterType});

  // تدفق البيانات للحصول على المنتجات بناءً على الفلتر المختار
  Stream<List<Map<String, dynamic>>> _getFilteredProducts() {
    return FirebaseFirestore.instance
        .collection('products')
        .where('type', isEqualTo: filterType)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['name'],
          'price': doc['price'],
          'image': doc['image'],
          'type': doc['type'],
          'weight': doc['weight'],
        };
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'منتجات $filterType',
            style: TextStyle(color: Color(0xFF6A5096)), // تغيير لون النص إلى الأصفر
          ),
        ),
        backgroundColor: Colors.green, // تعيين اللون الأخضر في شريط العنوان
      ),
      body: GestureDetector(
        onHorizontalDragUpdate: (details) {
          // إذا كان السحب من اليسار إلى اليمين
          if (details.delta.dx > 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MoreProductsPage()), // الانتقال إلى صفحة more_products_page
            );
          }
        },
        child: BackgroundWidget(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: _getFilteredProducts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Text(
                    'لا توجد منتجات حالياً',
                    style: TextStyle(color: Colors.yellow[700]), // تغيير لون النص إلى الذهبي
                  ),
                );
              }

              final products = snapshot.data!;

              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // عرض بطاقتين في كل صف
                  childAspectRatio: 0.75, // تعديل نسبة العرض إلى الارتفاع لتناسب العرض
                  mainAxisSpacing: 10, // المسافة الرأسية بين البطاقات
                  crossAxisSpacing: 10, // المسافة الأفقية بين البطاقات
                ),
                padding: EdgeInsets.all(10), // تعديل الحواف حول الشبكة
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];

                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/productDetails', // اسم المسار المؤدي إلى صفحة التفاصيل
                        arguments: {
                          'name': product['name'],
                          'price': product['price'],
                          'image': product['image'],
                          'type': product['type'], // تأكد من إرسال النوع
                          'weight': product['weight'],
                        },
                      );
                    },
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                            child: Image.network(
                              product['image'],
                              height: 150, // تحديد ارتفاع مناسب للصورة
                              fit: BoxFit.cover, // جعل الصورة تملأ المساحة المخصصة لها
                            ),
                          ),
                          Expanded( // إضافة Expanded لحل مشكلة overflow
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                product['name'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14, // حجم النص مشابه للبطاقات السابقة
                                  color: Colors.green, // اللون الأخضر للنص
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
                                color: Colors.green, // تغيير اللون إلى الأخضر
                                fontWeight: FontWeight.w500,
                                fontSize: 12, // حجم النص مشابه
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
