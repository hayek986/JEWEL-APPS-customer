import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_model.dart';
import 'product_card.dart';
import 'product_model.dart'; // Import the Product model

class ProductGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // ***************************************************************
    // تحديد عدد الأعمدة بناءً على عرض الشاشة
    final double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount;
    double childAspectRatio;

    if (screenWidth > 900) { // شاشات كبيرة (كمبيوتر مكتبي)
      crossAxisCount = 4;
      childAspectRatio = 0.75; // يمكن تعديلها حسب الحاجة
    } else if (screenWidth > 600) { // شاشات متوسطة (تابلت)
      crossAxisCount = 3;
      childAspectRatio = 0.7; // يمكن تعديلها حسب الحاجة
    } else { // شاشات صغيرة (موبايل)
      crossAxisCount = 2; // عرض عمودين على الموبايل
      childAspectRatio = 0.6; // نسبة العرض إلى الارتفاع للموبايل (يمكن تعديلها)
    }
    // ***************************************************************

    return Scaffold(
      appBar: AppBar(
        title: Text('جميع المنتجات'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('products').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No products found.'));
          }

          final products = snapshot.data!.docs.map((doc) {
            return Product.fromFirestore(doc);
          }).toList();

          return GridView.builder(
            padding: const EdgeInsets.all(10.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount, // استخدام العدد الديناميكي هنا
              childAspectRatio: childAspectRatio, // استخدام نسبة العرض إلى الارتفاع الديناميكية
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              return ProductCard(product: products[index]);
            },
          );
        },
      ),
    );
  }
}
