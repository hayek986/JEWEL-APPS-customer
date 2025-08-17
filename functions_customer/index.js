// The Cloud Functions for Firebase SDK to create Cloud Functions and set up triggers.
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { getFirestore } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");
const { initializeApp } = require("firebase-admin/app");

initializeApp();

// يستمع هذا الكود لأي طلب جديد تتم إضافته إلى مجموعة 'orders' في Firestore
exports.sendNewOrderNotification = onDocumentCreated(
  {
    document: "orders/{orderId}",
    // يمكنك تغيير المنطقة (region) إذا لزم الأمر
    region: "us-central1",
  },
  async (event) => {
    // الحصول على بيانات الطلب الجديد
    const orderData = event.data.data();
    const customerName = orderData.customerName;
    const totalPrice = orderData.totalPrice;
    const productNames = orderData.cartItems.map((item) => item.name).join(", ");

    // معرف صاحب التطبيق الذي سيتم إرسال الإشعار إليه.
    // يجب أن يتطابق هذا المعرف مع المعرف المستخدم في ملف firebase_notifications_service.dart
    const appOwnerUserId = "app_owner_123";

    // الحصول على رمز الجهاز (token) الخاص بصاحب التطبيق من Firestore
    const tokenSnapshot = await getFirestore()
      .collection("deviceTokens")
      .doc(appOwnerUserId)
      .get();

    // التحقق من وجود الرمز قبل الإرسال
    if (!tokenSnapshot.exists || !tokenSnapshot.data().token) {
      console.log("Device token not found for app owner. Aborting notification.");
      return null;
    }
    
    const deviceToken = tokenSnapshot.data().token;

    // إنشاء رسالة الإشعار
    const payload = {
      notification: {
        title: "طلب جديد!",
        body: `لديك طلب جديد من ${customerName}. الإجمالي: ${totalPrice} د.أ. المنتجات: ${productNames}`,
      },
    };

    // إرسال الإشعار إلى الجهاز
    try {
      const response = await getMessaging().sendToDevice(deviceToken, payload);
      console.log("Successfully sent message:", response);
    } catch (error) {
      console.log("Error sending message:", error);
    }
    return null; // يجب أن تعيد الدالة قيمة
  },
);
