import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'BackgroundWidget.dart';  // استيراد الملف الجديد

class AddProductPage extends StatefulWidget {
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  File? _image;
  final _formKey = GlobalKey<FormState>();
  String _selectedType = 'خواتم';  // القيمة الافتراضية من الخيارات

  // قائمة الأنواع
  final List<String> _types = [
    'خواتم',
    'ذبل',
    'سحبات',
    'أساور',
    'عقد',
    'حلق',
    'بيبي',
    'تعاليق',
    'تشكيلة'
  ];

  // اختيار صورة من المعرض
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // رفع الصورة إلى Firebase Storage
  Future<String?> _uploadImage() async {
    if (_image == null) return null;

    final storageRef = FirebaseStorage.instance.ref().child('product_images/${DateTime.now().millisecondsSinceEpoch}');
    final uploadTask = storageRef.putFile(_image!);
    final snapshot = await uploadTask;
    final downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  // إضافة المنتج إلى Firestore
  Future<void> _addProduct() async {
    if (_formKey.currentState!.validate()) {
      String name = _nameController.text;
      double price = double.parse(_priceController.text);

      // رفع الصورة والحصول على رابطها
      String? imageUrl = await _uploadImage();

      await FirebaseFirestore.instance.collection('products').add({
        'name': name,
        'price': price,
        'image': imageUrl,
        'type': _selectedType,  // إضافة النوع المحدد
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم إضافة المنتج بنجاح')));
      Navigator.pop(context); // العودة بعد إضافة المنتج
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إضافة منتج'),
        centerTitle: true,  // جعل العنوان في منتصف شريط التطبيق
      ),
      body: GestureDetector(
        onHorizontalDragUpdate: (details) {
          if (details.primaryDelta! > 0) {
            Navigator.pop(context); // العودة إذا تم السحب من اليسار إلى اليمين
          }
        },
        child: BackgroundWidget(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: _image == null
                        ? Container(height: 200, color: Colors.grey[300], child: Center(child: Text('اضغط لاختيار صورة')))
                        : Image.file(_image!, height: 200, width: double.infinity, fit: BoxFit.cover),
                  ),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'اسم المنتج'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال اسم المنتج';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'السعر'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال السعر';
                      }
                      return null;
                    },
                  ),
                  // Dropdown لانتقاء النوع
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: InputDecoration(labelText: 'نوع المنتج'),
                    items: _types.map((type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value!;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى اختيار نوع المنتج';
                      }
                      return null;
                    },
                  ),
                  ElevatedButton(
                    onPressed: _addProduct,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4CAF50), // خلفية زر أخضر
                      foregroundColor: Color(0xFFFFD700), // الكتابة باللون الذهبي
                    ),
                    child: Text('إضافة المنتج'),
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
