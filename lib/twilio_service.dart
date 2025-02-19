import 'package:http/http.dart' as http;
import 'dart:convert';

class TwilioService {
  final String accountSid = 'AC9b3541729753ddd43eaef3fd652f72f3';  // معرف الحساب الخاص بك في Twilio
  final String authToken = '66c29b31059fe876cec10e5a69eca667';   // رمز التوثيق الخاص بك
  final String fromPhone = '+12317427510'; // الرقم الذي حصلت عليه من Twilio لإرسال الرسائل النصية

  // وظيفة لإرسال رسالة SMS عبر API Twilio
  Future<void> sendSmsMessage(String customerName, String productName, double totalPrice) async {
    final String toPhone = '+962796137795'; // رقم العميل الذي يستلم الرسالة (تأكد من إضافة رمز البلد)

    final String message = 'تم إتمام الدفع بنجاح من العميل $customerName. المنتج: $productName. المبلغ الكلي هو: $totalPrice د.أ';

    final url = Uri.parse('https://api.twilio.com/2010-04-01/Accounts/$accountSid/Messages.json');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Basic ' + base64Encode(utf8.encode('$accountSid:$authToken')),
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'From': fromPhone,  // الرقم المرسل منه (رقم Twilio)
        'To': toPhone,  // رقم العميل الذي سيستلم الرسالة
        'Body': message,  // الرسالة النصية
      },
    );

    if (response.statusCode == 200) {
      print('Message sent: ${response.body}');
    } else {
      print('Error sending message: ${response.statusCode}');
    }
  }
}
