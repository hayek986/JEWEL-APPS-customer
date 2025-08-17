/**
 * هذا الكود يحل مشكلة الـ "timeout" التي واجهتها.
 * السبب كان أن ملف الدوال (functions) لم يحتوي على أي دالة جاهزة للعمل.
 *
 * هذا الكود يقوم بتهيئة Firebase Admin SDK مرة واحدة فقط،
 * ويحتوي على دالة اختبار بسيطة.
 */

// استيراد المكتبات اللازمة
const functions = require("firebase-functions");
const admin = require("firebase-admin");

// ✅ أهم خطوة: تهيئة Firebase Admin SDK
// يجب أن يتم استدعاء هذا مرة واحدة فقط في بداية الملف.
admin.initializeApp();

// مثال على دالة بسيطة تستجيب لطلب HTTP
// هذه الدالة ستمنع خطأ الـ "timeout" عند النشر.
exports.helloWorld = functions.https.onRequest((request, response) => {
  // استخدام logger لتسجيل الرسائل في سجلات Firebase
  functions.logger.info("Hello from the customer app functions!", {structuredData: true});
  response.send("Hello from Firebase Functions!");
});
