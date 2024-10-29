import 'dart:async';
import 'dart:io';

import 'package:fe/src/data/model/model.dart';
import 'package:fe/src/data/service/firebase_service.dart';
import 'package:fe/src/presentation/common/scale_custom_button.dart';
import 'package:fe/src/presentation/common/user_profile_icon.dart';
import 'package:fe/src/presentation/controller/controller.dart';
import 'package:fe/src/shared/theme/color_theme.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';

import 'widget/menu_button_screen.dart';

UserModel dummy_user = const UserModel(
    email: '123kim003@gmail.com',
    name: '빵빵이',
    feel: "옥지얌. 운전할 때 말 걸지마",
    profileImage: 'pig');

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final account = ref.watch(authControllerProvider);
    account is Authenticated ? account.user : null;
    // USER_ID below should be unique to your Sendbird application.
    // TODO: implement build
    if(account is Authenticated){
    //  saveUserLocation(account.user.email, account.user.name);
    }

    return _buildHomeScreen();
  }


  Widget _buildHomeScreen() {
    final account = ref.watch(authControllerProvider);
    account is Authenticated ? account.user : null;

    account is Authenticated ? buildForChat(account.user) : null;

    if(account is Authenticated){
      print('_buildHomeScreen account user');
      print(account.user.toString());
    }
    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(color: Colors.white),

          child: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                systemOverlayStyle: const SystemUiOverlayStyle(
                  statusBarBrightness: Brightness.light,
                  statusBarIconBrightness: Brightness.dark,
                  statusBarColor: Colors.white,
                ),
                leading: Container(),
                backgroundColor: Colors.white,
                elevation: 0.0,
                scrolledUnderElevation: 0.0,
                toolbarHeight: 0,
                titleSpacing: 0,
                floating: true,
                pinned: true,
                flexibleSpace: flexibleSpace,
                bottom: account is Authenticated ? bottom( account.user, context) :bottom( dummy_user, context)
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    MenuButton(
                      title: 'QR 찍기',
                      onPressed: () {
                        setState(() {
                          Navigator.of(context).pushNamed('/qr_code');
                        });

                        // QR 찍기 페이지로 이동
                      }, imagePath: 'qr',
                      backgroundColor: const Color(0xFFE1EBFC), // 원하는 색상 전달

                    ),
                    MenuButton(
                      title: '채팅',
                      onPressed: () {
                        setState(() {
                          Navigator.of(context).pushNamed('/chat_list');
                        });

                        // QR 찍기 페이지로 이동
                      }, imagePath: 'talk',
                      backgroundColor: const Color(0xFFF8D7E0), // 원하는 색상 전달

                    ),
                    MenuButton(
                      title: '동행자 찾기',
                      onPressed: () {
                        // 지도 페이지로 이동
                        setState(() {
                          Navigator.of(context).pushNamed('/map');
                        });
                      }, imagePath: 'map_marker',
                      backgroundColor: const Color(0xFF8E94F7), // 원하는 색상 전달

                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

FlexibleSpaceBar get flexibleSpace {
  return FlexibleSpaceBar(
    background: Container(
      // decoration: const BoxDecoration(
      //   gradient: LinearGradient(
      //     begin: Alignment(-0.00, -1.00),
      //     end: Alignment(0, 1),
      //     colors: [Color(0xFFF1E9FF), Color(0x00F1E9FF)],
      //   ),
      // ),
      height: 0,
    ),
  );
}
void buildForChat(UserModel user){
  String username = user.email.split('@')[0];
  runZonedGuarded(() async {
    // user는 어플 사용자의 id, 김성민
    final user = await SendbirdChat.connect(username); // user id 내 아이디. '0123kkm'
    if (user.nickname == '') {
      print('새로 생성한 계정의 경우 약간의 딜레이로 인해서 닉네임이 안바뀐 상태로 출력됨');
      SendbirdChat.updateCurrentUserInfo(nickname: 'testUser'); // user nickname
    }
    // The user is connected to the Sendbird server.
    print(
        'SendBird Message | Main.dart | InitializeApp() : Success to Connect');
  }, (e, s) {
    // Handle error.
    print('Error Message | main.dart | initializeApp() : $e');
    print('Error Message | main.dart | initializeApp() : $s');
  });

}

PreferredSizeWidget bottom(UserModel user, BuildContext context) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(90.0),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: Platform.isIOS
          ? null
          : const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-0.00, -1.00),
                end: Alignment(0, 1),
                colors: [Color(0xFFFFFFFF), Color(0xFFFFFF)],
              ),
            ),
      child: Column(
        children: [
          const SizedBox(height: 10,),
          Row(

            children: [
              Expanded(
                child: _ProfileButton(user: user),
              ),
              const SizedBox(
                width: 10,
              ),
              Container(
                width: 60,
                height: 60,
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(80),
                  ),
                  shadows: const [
                    BoxShadow(
                      color: Color(0x1EBC87E5),
                      blurRadius: 3,
                      offset: Offset(0, 3),
                      spreadRadius: 0,
                    )
                  ],
                ),
                child: IconButton(
                  iconSize: 40,
                  color: const Color(0xFFCBB1F2),
                  onPressed: () {
                    _showFeedbackDialog(context, user); // 다이얼로그 호출
                  },
                  icon: const Icon(
                    Icons.settings,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
void _showFeedbackDialog(BuildContext context, UserModel user) {
  TextEditingController feedbackController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('불편 사항을 적어주세요'),
        content: TextField(
          controller: feedbackController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: '불편한 점을 적어주세요...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // 다이얼로그 닫기
            },
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _sendFeedbackEmail(feedbackController.text, user);
              Navigator.of(context).pop(); // 다이얼로그 닫기
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('이메일이 전송되었습니다.')),
              );
            },
            child: const Text('확인'),
          ),
        ],
      );
    },
  );
}

Future<void> _sendFeedbackEmail(String feedback,UserModel user) async {
  const String username = '123kim003@gmail.com'; // 발신자 이메일
  const String password = 'zrxc wqfg kraf zmfp'; // 앱 비밀번호

  final smtpServer = gmail(username, password);

  final message = Message()
    ..from = Address(username, '사용자 피드백 : ')
    ..recipients.add('123kim003@gmail.com') // 수신자 이메일
    ..subject = '사용자 피드백 ${DateTime.now()} from ${user.email}'
    ..text = feedback;

  try {
    await send(message, smtpServer);
    print('이메일이 성공적으로 전송되었습니다.');
  } catch (e) {
    print('이메일 전송 실패: $e');
  }
}

class _ProfileButton extends ConsumerStatefulWidget {
  final UserModel user;

  const _ProfileButton({required this.user});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProfileButtonState();

}

class _ProfileButtonState extends ConsumerState<_ProfileButton>{

  @override
  Widget build(BuildContext context) {
    //Sentry에 전달될 사용자 정보

    final textTheme = Theme.of(context).textTheme;
    return ScaleCustomButton(
      onTap: () async {
        await ref
            .read(authControllerProvider.notifier)
            .initProfile(widget.user.email);
        Navigator.pushNamed(context, '/edit');
      },
      child: Container(
        constraints: const BoxConstraints(minHeight: 72),
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 5,
        ),
        decoration: ShapeDecoration(
          color: const Color(0xFFF4F0FF),
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: Colors.white),
            borderRadius: BorderRadius.circular(80),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x1EBC87E5),
              blurRadius: 3,
              offset: Offset(0, 3),
              spreadRadius: 0,
            )
          ],
        ),
        child: Row(
          children: [
            if (widget.user.profileImage != null)
              UserProfileIcon(
                size: 56,
                profileImage: widget.user.profileImage!,
              ),
            const SizedBox(
              width: 12,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '내 매너 온도 : ${widget.user.emotionDegree.toString()}',
                    style: textTheme.labelSmall!.copyWith(
                      color: ColorTheme.slateColor[600],
                    ),
                  ),
                  Text(widget.user.name, style: textTheme.displaySmall),
                ],
              ),
            )
          ],
        ),
      ),
    );

  }


}


