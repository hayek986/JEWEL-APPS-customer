import 'package:flutter/material.dart';
import 'BackgroundWidget.dart';  // استيراد الويدجت الخاص بالخلفية

class ProductCard extends StatelessWidget {
  final String productName;
  final String productPrice;
  final String productImage;
  final String productWeight;  // إضافة الوزن
  final String productType;    // إضافة النوع
  final VoidCallback onTap;

  const ProductCard({
    required this.productName,
    required this.productPrice,
    required this.productImage,
    required this.productWeight,  // تمرير الوزن
    required this.productType,    // تمرير النوع
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: BackgroundWidget(
        child: Card(
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          color: Colors.grey[850],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,  // تمديد العرض
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                child: Image.network(
                  productImage,
                  width: double.infinity,
                  height: 240,  // زيادة ارتفاع الصورة
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,  // المعلومات على الحافة اليسرى
                  children: [
                    Text(
                      productName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.yellow[700], // الذهبي
                        shadows: [
                          Shadow(
                            blurRadius: 3.0,
                            color: Colors.grey.withOpacity(0.5),
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'السعر: $productPrice د.أ',
                      style: TextStyle(
                        color: Colors.yellow[700], // الذهبي
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        shadows: [
                          Shadow(
                            blurRadius: 3.0,
                            color: Colors.grey.withOpacity(0.5),
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(  // عرض الوزن
                      'الوزن: $productWeight غرام',
                      style: TextStyle(
                        color: Colors.yellow[700], // الذهبي
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(  // عرض النوع
                      'النوع: $productType',
                      style: TextStyle(
                        color: Colors.yellow[700], // الذهبي
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: ElevatedButton(
                        onPressed: onTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green, // الأخضر للأزرار
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                          shadowColor: Colors.green.withOpacity(0.6),
                          elevation: 12,
                        ),
                        child: const Text(
                          'عرض التفاصيل',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white, // نص الزر أبيض
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
