import 'package:fe/src/data/model/model.dart';
import 'package:fe/src/data/repository/auth/social_login_repository.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';

class NaverService implements SocialLoginRepository {
  @override
  Future<UserModel?> login() async {
    try {
      final NaverLoginResult result = await FlutterNaverLogin.logIn();
      if (result.status == NaverLoginStatus.loggedIn) {
        print('로그인 성공: ${result.account?.email}');
        return _toUser(result.account);
      }else {
        print('로그인 실패 또는 취소됨');
      }

    } catch (e) {
      print('네이버 로그인 중 오류 발생: $e');
    }
    return null;
  }

  UserModel _toUser(NaverAccountResult naverUser) => UserModel(
    email: naverUser.email,
    name: naverUser.name,
    profileImage:
    naverUser.profileImage.isNotEmpty ? naverUser.profileImage : null,
    source: 'naver',
  );

  @override
  Future<void> logout() async {
    try {
      await FlutterNaverLogin.logOut();
    } catch (e) {
      print(e);
    }
  }
}
