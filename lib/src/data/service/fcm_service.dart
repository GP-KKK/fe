import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class FCMService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  void init() async {
    // FCM 토큰 요청
    String? token = await _messaging.getToken();
    print("FCM 토큰: $token");

    // 포그라운드 알림 처리
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('푸시 알림 수신: ${message.notification?.title}');
    });

    // 백그라운드 알림 처리
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print('백그라운드 푸시 알림 수신: ${message.notification?.title}');
  }
}
