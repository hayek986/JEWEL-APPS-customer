const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

admin.initializeApp();

exports.sendNewOrderNotification = onDocumentCreated(
  "orders/{orderId}",
  async (event) => {
    const newOrder = event.data.data();

    const payload = {
      notification: {
        title: "🛒 طلب جديد",
        body: `تم إضافة طلب جديد بقيمة ${newOrder.totalPrice} دينار`,
      },
      topic: "admin",
    };

    try {
      await admin.messaging().send(payload);
      console.log("تم إرسال الإشعار بنجاح");
    } catch (error) {
      console.error("فشل إرسال الإشعار:", error);
    }
  }
);