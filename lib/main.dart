import 'dart:async';

import 'package:fe/src/app.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    print('Firebase 초기화 성공');
    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
    String? token = await _firebaseMessaging.getToken();
    print('FCM 토큰: $token');

  } catch (e) {
    print('Firebase 초기화 실패: $e');
  }

  await initializeApp();
  runApplication();
}

void runApplication() {
  final ftoast = FToast();
  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}

Future<void> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  // kakao login
  KakaoSdk.init(nativeAppKey: '5023f50da56c724b08f5d91b6ee9ba61');

  // location permission
  await _checkLocationPermission();

  // sendBird chat api
  await SendbirdChat.init(
    appId: 'BC23D9CA-D861-4819-9C1B-FF94FBC9E234',
    options: SendbirdChatOptions(useCollectionCaching: true),
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
      statusBarColor: Colors.transparent,
    ),
  );
}
Future<void> _checkLocationPermission() async {
  var status = await Permission.location.status;
  if (status.isDenied) {
    await Permission.location.request();
  }
}
