import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';

class NotificationSend {
  CollectionReference seller =
      FirebaseFirestore.instance.collection('Users/AppUsers/Sellers');

  Future<String> gettoken({String uid}) async {
    String token;
    var docu = seller.doc(uid).get();
    return await docu.then((doc) {
      token = doc.data()['token'];
      return token;
    });
  }

  var postUrl = "https://fcm.googleapis.com/fcm/send";

  Future<void> sendNotification(
      {String sellerid, String body, String title}) async {
    var token = await gettoken(uid: sellerid);

    print('token : $token');

    final data = {
      "notification": {"body": body, "title": title},
      "priority": "high",
      /* "data": {
            "click_action": "FLUTTER_NOTIFICATION_CLICK",
            "id": "1",
            "status": "done"
          },*/
      "to": "$token"
    };

    final headers = {
      'content-type': 'application/json',
      'Authorization':
          'key=<Your API key>'
    };

    BaseOptions options = new BaseOptions(
      connectTimeout: 5000,
      receiveTimeout: 3000,
      headers: headers,
    );

    try {
      final response = await Dio(options).post(postUrl, data: data);

      if (response.statusCode == 200) {
        print('Request Sent To Driver');
      } else {
        print('notification sending failed');
        // on failure do sth
      }
    } catch (e) {
      print('exception $e');
    }
  }
}
