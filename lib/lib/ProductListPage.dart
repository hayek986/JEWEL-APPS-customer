import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_product_page.dart';
import 'BackgroundWidget.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ProductListPage extends StatelessWidget {
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

  void _editProduct(BuildContext context, String productId) {
    Navigator.pushNamed(
      context,
      '/editProduct',
      arguments: {'productId': productId},
    );
  }

  void _addProduct(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddProductPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // تحديد صورة الخلفية للويب والجوال
    final String webImageUrl =
        kIsWeb ? 'http://yourdomain.com/path/to/bk.png' : 'assets/bk.png';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'قائمة المنتجات',
          style: TextStyle(color: Color(0xFF6A5096)),
        ),
        backgroundColor: Colors.green,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: () => _addProduct(context),
          ),
        ],
      ),
      body: BackgroundWidget(
        imageUrl: webImageUrl,
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: _getProducts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('لا توجد منتجات', style: TextStyle(color: Colors.white)));
            }

            final products = snapshot.data!;

            // تحديد عدد الأعمدة بناءً على المنصة
            int crossAxisCount = kIsWeb ? 4 : 2;

            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 0.75,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              padding: EdgeInsets.all(10),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return _buildProductCard(context, product);
              },
            );
          },
        ),
      ),
    );
  }

  // دالة مساعدة لبناء بطاقة المنتج
  Widget _buildProductCard(BuildContext context, Map<String, dynamic> product) {
    return GestureDetector(
      onTap: () => _editProduct(context, product['id']),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.white.withOpacity(0.1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                child: Image.network(
                  product['image'],
                  height: kIsWeb ? 200 : 150,
                  fit: BoxFit.cover,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        product['name'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: kIsWeb ? 16 : 14,
                          color: Colors.green,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'السعر: ${product['price']} د.أ',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                          fontSize: kIsWeb ? 14 : 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}