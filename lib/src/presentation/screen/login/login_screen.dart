import 'package:fe/src/presentation/controller/controller.dart';
import 'package:fe/src/presentation/layout/static_layout.dart';
import 'package:fe/src/presentation/screen/home/home_screen.dart';
import 'package:fe/src/presentation/screen/login/widget/social_login_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerWidget {
  final String? path;

  const LoginScreen({
    super.key,
    this.path,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AuthState>(authControllerProvider, (_, state) {
      switch (state) {
        case Authenticated():
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
          //Navigator.of(context).pushNamed('/home_screen');
      }
    });

    return StaticLayout(
      key: const Key('login_screen'),
      innerTopPadding: 100,
      isAppBarVisible: false,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: 180,
          height: 180,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/car.png'),
            ),
          ),
        ),
        const SocialLoginButtonSet()
      ],
    );
  }
}
