import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'cart_model.dart';
import 'order.dart';
import 'BackgroundWidget.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class PaymentPage extends StatefulWidget {
  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String selectedPaymentMethod = 'cash';
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController visaNumberController = TextEditingController();
  final TextEditingController visaExpiryController = TextEditingController();
  final TextEditingController visaCVCController = TextEditingController();
  final TextEditingController customerNameController = TextEditingController();

  String? _deviceId;
  bool _loadingLocation = false;

  @override
  void initState() {
    super.initState();
    _loadDeviceId();
  }

  Future<void> _loadDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    _deviceId = prefs.getString('deviceId');
    if (_deviceId == null) {
      _deviceId = Uuid().v4();
      await prefs.setString('deviceId', _deviceId!);
    }
    setState(() {});
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _loadingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _loadingLocation = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('خدمة تحديد الموقع غير مفعلة')),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _loadingLocation = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم رفض إذن الموقع')),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => _loadingLocation = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('إذن الموقع مرفوض نهائياً')),
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String address =
            "${place.street ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}";
        setState(() {
          addressController.text = address;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل في تحديد الموقع')),
      );
    } finally {
      setState(() => _loadingLocation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String webImageUrl = 'assets/bk.png';

    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'خيارات الدفع',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: const Color(0xFF800080),
        elevation: 0,
      ),
      body: BackgroundWidget(
        imageUrl: webImageUrl,
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'معلومات العميل',
                    style: TextStyle(
                      fontSize: kIsWeb ? 20 : 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF800080),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildTextField(
                      controller: customerNameController,
                      labelText: 'اسم العميل',
                      icon: Icons.person),
                  const SizedBox(height: 16),
                  Text(
                    'طريقة الدفع',
                    style: TextStyle(
                      fontSize: kIsWeb ? 20 : 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF800080),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          value: 'cash',
                          groupValue: selectedPaymentMethod,
                          title: Text(
                            'الدفع عند الاستلام',
                            style: TextStyle(
                              fontSize: kIsWeb ? 16 : 14,
                              color: const Color(0xFF800080),
                            ),
                          ),
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
                          title: Text(
                            'الدفع بواسطة فيزا',
                            style: TextStyle(
                              fontSize: kIsWeb ? 16 : 14,
                              color: const Color(0xFF800080),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              selectedPaymentMethod = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: addressController,
                          labelText: 'العنوان',
                          icon: Icons.location_on,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: _loadingLocation
                            ? const CircularProgressIndicator()
                            : const Icon(Icons.my_location,
                                color: Color(0xFF800080)),
                        onPressed: _loadingLocation ? null : _getCurrentLocation,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                      controller: phoneController,
                      labelText: 'رقم الهاتف',
                      icon: Icons.phone),
                  if (selectedPaymentMethod == 'visa') ...[
                    const SizedBox(height: 16),
                    _buildTextField(
                        controller: visaNumberController,
                        labelText: 'رقم الفيزا',
                        icon: Icons.credit_card),
                    const SizedBox(height: 16),
                    _buildTextField(
                        controller: visaExpiryController,
                        labelText: 'تاريخ انتهاء الفيزا',
                        icon: Icons.date_range),
                    const SizedBox(height: 16),
                    _buildTextField(
                        controller: visaCVCController,
                        labelText: 'CVC',
                        icon: Icons.lock,
                        obscureText: true),
                  ],
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          if (customerNameController.text.isEmpty ||
                              addressController.text.isEmpty ||
                              phoneController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('يرجى ملء جميع الحقول المطلوبة')),
                            );
                            return;
                          }

                          final cartItems =
                              context.read<CartModel>().cartItems.map((item) {
                            return {
                              'name': item['name'] as String,
                              'price': item['price'].toString(),
                              'imageUrl': item['image'] as String,
                              'type': item['type'] as String,
                              'weight': item['weight'].toString(),
                            };
                          }).toList();

                          if (cartItems.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('لا يوجد منتجات في سلة التسوق')),
                            );
                            return;
                          }

                          if (_deviceId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('خطأ في جلب معرف الجهاز')),
                            );
                            return;
                          }

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
                            deviceId: _deviceId!,
                          );

                          await FirebaseFirestore.instance.collection('orders').add({
                            'deviceId': order.deviceId,
                            'paymentMethod': order.paymentMethod,
                            'address': order.address,
                            'phone': order.phone,
                            'visaNumber': order.visaNumber,
                            'visaExpiry': order.visaExpiry,
                            'visaCVC': order.visaCVC,
                            'cartItems': order.cartItems,
                            'totalPrice': order.totalPrice,
                            'customerName': order.customerName,
                            'timestamp': FieldValue.serverTimestamp(),
                          });

                          context.read<CartModel>().clearCart();
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('تمت معالجة الطلب بنجاح')),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('فشل في إرسال الطلب. يرجى المحاولة مرة أخرى.')),
                          );
                        }
                      },
                      icon: const Icon(Icons.send, color: Colors.white),
                      label: Text(
                        'إرسال الطلب',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: kIsWeb ? 18 : 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            vertical: kIsWeb ? 20 : 16,
                            horizontal: kIsWeb ? 40 : 32),
                        backgroundColor: const Color(0xFF800080),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon, color: const Color(0xFF800080)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        labelStyle: const TextStyle(color: Color(0xFF800080)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF800080)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF800080)),
        ),
      ),
      style: const TextStyle(color: Color(0xFF800080)),
    );
  }
}
