import 'package:fe/src/presentation/screen/chat/chat_list_screen.dart';
import 'package:fe/src/presentation/screen/edit/edit_screen.dart';
import 'package:fe/src/presentation/screen/login/login_screen.dart';
import 'package:fe/src/presentation/screen/map/map_screen.dart';
import 'package:fe/src/presentation/screen/map/newmap_screen.dart';
import 'package:fe/src/presentation/screen/map/together_screen.dart';
import 'package:fe/src/presentation/screen/news/news_article.dart';
import 'package:fe/src/presentation/screen/news/news_screen.dart';
import 'package:fe/src/presentation/screen/qr/loading_screen.dart';
import 'package:fe/src/presentation/screen/qr/qr_code_screen.dart';
import 'package:fe/src/presentation/screen/setting/setting_screen.dart';
import 'package:fe/src/shared/theme/main_theme.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'presentation/screen/home/home_screen.dart';

class App extends HookConsumerWidget{
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    // TODO: implement build
    return MaterialApp(
        debugShowCheckedModeBanner: false,

        theme: mainThemeByLocale(const Locale('ko')),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        //'/auth': (context) => Auth(),
        '/home_screen': (context) => const HomeScreen(),
        '/news_list': (context) => NewsScreen(),
        '/news_article': (context) => const NewsArticle(url: ''),
        '/edit': (context) => EditScreen(),
        '/map':(context)=>TogetherScreen(),
        '/setting': (context) => SettingScreen(),
        '/qr_code': (context) => QrCodeScreen(), // qr code 찍는 화면
        '/chat_list': (context) => ChatListScreen(),
        '/loading': (context) => LoadingScreen(),

      },
      //home: LoginScreen(),
    );
  }
  
}