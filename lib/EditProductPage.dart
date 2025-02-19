import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'BackgroundWidget.dart'; // تأكد من استيراد BackgroundWidget هنا

class EditProductPage extends StatefulWidget {
  @override
  _EditProductPageState createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  late String productId;
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _weightController = TextEditingController(); // إضافة متحكم لـ weight
  String? _imageUrl;
  bool _isLoading = true;
  final ImagePicker _picker = ImagePicker();
  File? _newImage;

  String? _selectedType; // تغيير من قائمة إلى نوع واحد فقط
  final List<String> _availableTypes = [
    'خواتم', 'ذبل', 'سحبات', 'أساور', 'عقد', 'حلق', 'بيبي', 'تعاليق', 'تشكيلة'
  ]; // الأنواع المتاحة

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      productId = args['productId'];
      _loadProductData();
    });
  }

  Future<void> _loadProductData() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('products').doc(productId).get();

    setState(() {
      _nameController.text = doc['name'];
      _priceController.text = doc['price'].toString();
      _weightController.text = doc['weight'].toString();
      _imageUrl = doc['image'];

      // تأكد من أن "type" هو نص، ثم نحوله إلى نوع واحد فقط
      _selectedType = doc['type'];

      _isLoading = false;
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _newImage = File(pickedFile.path);
      });
    }
  }

  Future<String> _uploadImage() async {
    if (_newImage == null) {
      return _imageUrl ?? '';
    }

    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference storageRef = FirebaseStorage.instance.ref().child('product_images/$fileName');

    UploadTask uploadTask = storageRef.putFile(_newImage!);
    TaskSnapshot taskSnapshot = await uploadTask;

    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> _updateProduct() async {
    String name = _nameController.text;
    double price = double.parse(_priceController.text);
    String type = _selectedType ?? ''; // تأكيد أن النوع ليس فارغًا
    double weight = double.parse(_weightController.text);

    String imageUrl = await _uploadImage();

    await FirebaseFirestore.instance.collection('products').doc(productId).update({
      'name': name,
      'price': price,
      'type': type, // تحديث النوع كقيمة واحدة
      'weight': weight,
      'image': imageUrl,
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم تحديث المنتج بنجاح')));
    Navigator.pop(context);
  }

  Future<void> _deleteProduct() async {
    if (_imageUrl != null) {
      try {
        Reference storageRef = FirebaseStorage.instance.refFromURL(_imageUrl!);
        await storageRef.delete();
      } catch (e) {
        print("Error deleting image from storage: $e");
      }
    }

    await FirebaseFirestore.instance.collection('products').doc(productId).delete();

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم حذف المنتج بنجاح')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(appBar: AppBar(title: Text('تحرير المنتج')), body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'تحرير المنتج',
          style: TextStyle(color: Color(0xFF6A5096)), // لون الكتابة بالذهب
        ),
        backgroundColor: Colors.green, // اللون الأخضر في شريط العنوان
        centerTitle: true,  // محاذاة النص في المنتصف

        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: Color(0xFF6A5096)), // أيقونة الحذف باللون الذهبي
            onPressed: _deleteProduct,
          ),
        ],
      ),
      body: GestureDetector(
        onHorizontalDragUpdate: (details) {
          if (details.primaryDelta! > 0) {
            Navigator.pop(context); // الرجوع للصفحة السابقة عند السحب من اليسار لليمين
          }
        },
        child: BackgroundWidget(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'اسم المنتج',
                    labelStyle: TextStyle(color:Color(0xFF6A5096)), // الكتابة بالذهب
                  ),
                ),
                TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'السعر',
                    labelStyle: TextStyle(color: Color(0xFF6A5096)), // الكتابة بالذهب
                  ),
                ),
                TextField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'الوزن',
                    labelStyle: TextStyle(color: Color(0xFF6A5096)), // الكتابة بالذهب
                  ),
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedType = newValue;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'نوع المنتج',
                    labelStyle: TextStyle(color:Color(0xFF6A5096)), // الكتابة بالذهب
                  ),
                  items: _availableTypes.map<DropdownMenuItem<String>>((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                ),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: _pickImage,
                  child: _newImage == null
                      ? _imageUrl != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(15), // جعل الحواف دائرية
                    child: Image.network(
                      _imageUrl!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover, // ضبط الصورة لتناسب الحاوية تلقائيًا وبشكل جميل
                    ),
                  )
                      : Container(height: 200, color: Colors.grey[200])
                      : ClipRRect(
                    borderRadius: BorderRadius.circular(15), // جعل الحواف دائرية
                    child: Image.file(
                      _newImage!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover, // ضبط الصورة لتناسب الحاوية تلقائيًا وبشكل جميل
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Center(
                  child: ElevatedButton(
                    onPressed: _updateProduct,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // خلفية زر خضراء
                    ),
                    child: Text(
                      'تحديث المنتج',
                      style: TextStyle(color: Color(0xFF6A5096)), // الكتابة بالذهب
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
