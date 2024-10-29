import 'dart:convert';
import 'dart:io';

import 'package:device_region/device_region.dart';
import 'package:fe/src/presentation/controller/controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:http/http.dart' as http;

enum LoginPlatform {
  facebook,
  google,
  kakao,
  naver,
  apple,
  none, // logout
}

class SocialLoginButtonSet extends StatefulHookConsumerWidget {
  const SocialLoginButtonSet({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SocialLoginButtonSetState();
}

class _SocialLoginButtonSetState extends ConsumerState<SocialLoginButtonSet> {
  String region = 'KR';
  LoginPlatform _loginPlatform = LoginPlatform.none;

  @override
  void initState() {
    super.initState();
    getRegion();
  }

  // get region
  Future<void> getRegion() async {
    final region = await DeviceRegion.getSIMCountryCode();

    if (region != null) {
      setState(() {
        this.region = region;
      });
    }
  }

  // sign in with google
  void signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    if (googleUser != null) {
      print('name = ${googleUser.displayName}');
      print('email = ${googleUser.email}');
      print('id = ${googleUser.id}');

      setState(() {
        _loginPlatform = LoginPlatform.google;
        Navigator.of(context).pushNamed('/home_screen');
      });
    }
  }

  // sign in with naver
  void signInWithNaver() async {
    final NaverLoginResult result = await FlutterNaverLogin.logIn();
    if (result.status == NaverLoginStatus.loggedIn) {
      print('accessToken = ${result.accessToken}');
      print('id = ${result.account.id}');
      print('email = ${result.account.email}');
      print('name = ${result.account.name}');
    }else{
      print("개똥망");
    }
    setState(() {
      _loginPlatform = LoginPlatform.naver;
      Navigator.of(context).pushNamed('/home_screen');
    });
  }

  // sing in with apple
  void signInWithApples() async {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );
    print(credential);
    // Now send the credential (especially `credential.authorizationCode`) to your server to create a session
    // after they have been validated with Apple (see `Integration` section for more information on how to do this)
    setState(() {
      _loginPlatform = LoginPlatform.apple;
      Navigator.of(context).pushNamed('/home_screen');
    });
  }

  // sign in with kakao
  void signInWithKakao() async {
    try {
      bool isInstalled = await isKakaoTalkInstalled();

      OAuthToken token = isInstalled
          ? await UserApi.instance.loginWithKakaoTalk()
          : await UserApi.instance.loginWithKakaoAccount();

      final url = Uri.https('kapi.kakao.com', '/v2/user/me');

      final response = await http.get(
        url,
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer ${token.accessToken}'
        },
      );

      final profileInfo = json.decode(response.body);
      print(profileInfo.toString());

      setState(() {
        _loginPlatform = LoginPlatform.kakao;
        Navigator.of(context).pushNamed('/home_screen');
      });
    } catch (error) {
      print('카카오톡으로 로그인 실패 $error');
    }
  }

  // log out -> LogIn Platform
  void signOut() async {
    switch (_loginPlatform) {
      case LoginPlatform.facebook:
        // await FacebookAuth.instance.logOut();
        break;
      case LoginPlatform.google:
        await GoogleSignIn().signOut();
        break;
      case LoginPlatform.kakao:
        await UserApi.instance.logout();
        break;
      case LoginPlatform.naver:
        await FlutterNaverLogin.logOut();
        break;
      case LoginPlatform.apple:
        // 애플 로그인은 다른 소셜 로그인 처럼 로그아웃 처리가 없고 사용자가 직접 앱과 계정의 연결을 끊어야 합니다.
        break;
      case LoginPlatform.none:
        break;
    }

    setState(() {
      _loginPlatform = LoginPlatform.none;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final authController = ref.read(authControllerProvider.notifier);

    return Padding(
      padding: const EdgeInsets.only(bottom: 100.0),
      child: Column(
        children: [
          Text(
            '로그인을 진행할 sns를 선택해주세요',
            style: textTheme.bodyMedium!.copyWith(),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  // google log in (완료)
                  GestureDetector(
                    key: const Key('google_login_button'),
                    onTap: () async {
                      signInWithGoogle();
                      //await authController.login(type: LoginType.google);
                    },
                    child: SvgPicture.asset(
                      'assets/images/svg/btn_login_google.svg',
                      semanticsLabel: 'Google Login Button',
                    ),
                  ),

                  // apple log in
                  if (Platform.isIOS)
                    GestureDetector(
                      onTap: () async {
                        signInWithApples();
                        //await authController.login(type: LoginType.apple);
                      },
                      child: SvgPicture.asset(
                        'assets/images/svg/btn_login_apple.svg',
                        semanticsLabel: 'Apple Login Button',
                      ),
                    ),

                  // kakao log in
                  if (region == 'KR' || region == 'kr')
                    GestureDetector(
                      onTap: () async {
                        signInWithKakao();
                        //await authController.login(type: LoginType.kakao);
                      },
                      child: SvgPicture.asset(
                        'assets/images/svg/btn_login_kakao.svg',
                        semanticsLabel: 'Kakao Login Button',
                      ),
                    ),

                  // naver login (완료)
                  if (region == 'KR' || region == 'kr')
                    GestureDetector(
                      onTap: () async {

                        //signInWithNaver();
                        await authController.login(type: 'naver');
                        Navigator.of(context).pushNamed('/home_screen');

                      },
                      child: SvgPicture.asset(
                        'assets/images/svg/btn_login_naver.svg',
                        semanticsLabel: 'Naver Login Button',
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
