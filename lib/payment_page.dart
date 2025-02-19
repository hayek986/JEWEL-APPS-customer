import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'twilio_service.dart';
import 'cart_model.dart';
import 'order.dart'; // تم تغيير اسم الكلاس إلى CustomOrder
import 'package:provider/provider.dart';
import 'BackgroundWidget.dart'; // تأكد من استيراد BackgroundWidget هنا

class PaymentPage extends StatefulWidget {
  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String selectedPaymentMethod = 'cash'; // Default payment method

  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController visaNumberController = TextEditingController();
  final TextEditingController visaExpiryController = TextEditingController();
  final TextEditingController visaCVCController = TextEditingController();
  final TextEditingController customerNameController = TextEditingController(); // Customer name controller

  double dragStartX = 0.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: (details) {
        dragStartX = details.localPosition.dx;
      },
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! > 0) {
          // إذا كان السحب من اليسار لليمين
          Navigator.pop(context); // العودة للصفحة السابقة عند السحب
        }
      },
      child: WillPopScope(
        onWillPop: () async {
          Navigator.pop(context); // العودة للصفحة السابقة عند الضغط على زر الرجوع
          return false; // لا نقوم بإغلاق الصفحة مباشرةً
        },
        child: Scaffold(
          appBar: AppBar(
            title: Center(  // توسيط النص في AppBar
              child: Text(
                'خيارات الدفع',
                style: TextStyle(
                  color:Color(0xFF6A5096), // تغيير لون النص إلى الأصفر
                ),
              ),
            ),
            backgroundColor: Colors.green, // تغيير لون AppBar إلى الأخضر
            elevation: 0,
          ),
          body: BackgroundWidget(  // إضافة BackgroundWidget هنا
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // عنوان القسم
                  Text(
                    'معلومات العميل',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green, // تغيير اللون إلى الأخضر
                    ),
                  ),
                  SizedBox(height: 8),
                  // اسم العميل
                  TextField(
                    controller: customerNameController,
                    decoration: InputDecoration(
                      labelText: 'اسم العميل',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  // طريقة الدفع
                  Text(
                    'طريقة الدفع',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green, // تغيير اللون إلى الأخضر
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          value: 'cash',
                          groupValue: selectedPaymentMethod,
                          title: Text('الدفع عند الاستلام'),
                          onChanged: (value) {
                            setState(() {
                              selectedPaymentMethod = value!;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          value: 'visa',
                          groupValue: selectedPaymentMethod,
                          title: Text('الدفع بواسطة فيزا'),
                          onChanged: (value) {
                            setState(() {
                              selectedPaymentMethod = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  // العنوان ورقم الهاتف
                  TextField(
                    controller: addressController,
                    decoration: InputDecoration(
                      labelText: 'العنوان',
                      prefixIcon: Icon(Icons.location_on),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      labelText: 'رقم الهاتف',
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  // فيزا المدفوعات
                  if (selectedPaymentMethod == 'visa') ...[
                    SizedBox(height: 16),
                    TextField(
                      controller: visaNumberController,
                      decoration: InputDecoration(
                        labelText: 'رقم الفيزا',
                        prefixIcon: Icon(Icons.credit_card),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: visaExpiryController,
                      decoration: InputDecoration(
                        labelText: 'تاريخ انتهاء الفيزا',
                        prefixIcon: Icon(Icons.date_range),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: visaCVCController,
                      decoration: InputDecoration(
                        labelText: 'CVC',
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      obscureText: true,
                    ),
                  ],
                  SizedBox(height: 24),
                  // زر إرسال الطلب
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final cartItems = context.read<CartModel>().cartItems.map((item) {
                          return {
                            'name': item['name'] as String,
                            'price': item['price'] as String,
                          };
                        }).toList();

                        final order = CustomOrder(
                          paymentMethod: selectedPaymentMethod,
                          address: addressController.text,
                          phone: phoneController.text,
                          visaNumber: visaNumberController.text,
                          visaExpiry: visaExpiryController.text,
                          visaCVC: visaCVCController.text,
                          cartItems: cartItems,
                          totalPrice: context.read<CartModel>().getTotalPrice(),
                          customerName: customerNameController.text.trim(),
                        );

                        if (order.customerName.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('يرجى إدخال اسم العميل')),
                          );
                          return;
                        }

                        // حفظ الطلب في Firestore
                        FirebaseFirestore.instance.collection('orders').doc(order.customerName).set({
                          'paymentMethod': order.paymentMethod,
                          'address': order.address,
                          'phone': order.phone,
                          'visaNumber': order.visaNumber,
                          'visaExpiry': order.visaExpiry,
                          'visaCVC': order.visaCVC,
                          'cartItems': order.cartItems,
                          'totalPrice': order.totalPrice,
                          'timestamp': FieldValue.serverTimestamp(),
                        });

                        // إرسال رسالة SMS
                        TwilioService twilioService = TwilioService();
                        try {
                          String productNames = order.cartItems.map((item) => item['name']).join(', ');
                          await twilioService.sendSmsMessage(order.customerName, productNames, order.totalPrice);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('تم إرسال رسالة بنجاح')),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('فشل في إرسال رسالة: $e')),
                          );
                        }

                        // مسح السلة
                        context.read<CartModel>().clearCart();

                        // رسالة تأكيد
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('تمت معالجة الطلب بنجاح')),
                        );
                      },
                      icon: Icon(Icons.send, color: Colors.white),
                      label: Text(
                        'إرسال الطلب',
                        style: TextStyle(color: Color(0xFF6A5096)),  // تغيير لون النص إلى اللون المطلوب
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                        backgroundColor: Colors.green, // تعيين اللون الأخضر
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
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
    );
  }
}
