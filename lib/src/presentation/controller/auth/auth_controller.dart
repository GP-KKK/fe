part of '../controller.dart';

@riverpod
class AuthController extends _$AuthController {
  @override
  AuthState build() {
    return const AuthInitial();
  }

  Future<void> init() async {
    final user = await getProfile();

    if (user == null) {
      print('auth_controller user to string');
      print(user.toString());
      state = const NotAuthenticated();
    }
  }
  Future<void> login({required String type}) async {
      final user = await getProfile();

      if (user == null) {
        state = const NotAuthenticated();
      }
  }
  Future<void> initProfile(String email) async {
    final user = await getProfileWithEmail(email);
    if (user != null) {
      //String? profileImage, FeelState feelState, EmotionDegree? emotionDegree
      String? profileImage = user.profileImage;
      FeelState feelState = user.feelState;
      double emotionDegree = user.emotionDegree;
      bool shouldUpdate = false;

      if (profileImage == null) {
        profileImage = 'cat';
        shouldUpdate = true;
      }

      if (feelState == null) {
        feelState = FeelState.UNKNOWN;
        shouldUpdate = true;
      }

      if (emotionDegree == null) {
        emotionDegree = 36.5;
        shouldUpdate = true;
      }


      if (shouldUpdate) {
        final updatedUser = user.copyWith(
          profileImage: profileImage,
          feelState: feelState,
          emotionDegree: emotionDegree,
        );

        setProfile(user: updatedUser, updatedUser: updatedUser);
      }
    }
  }

  Future<UserModel?> getProfile() async {
    final user = await ref
        .watch(authRepositoryProvider)
        .login(type: 'naver');

    if (user is UserModel) {
      state = Authenticated(user: user, updatedUser: user);

      return user;
    } else {
      return null;
    }
  }
  Future<UserModel?> getProfileWithEmail(String email) async {

    final Dio dio = Dio();
    Map<String, dynamic> json = {
      "email": email,
    };
    String ip = Constants.ip;
    final response = await dio.get(
      '$ip/getUser',
      data: json,
    );
    final Map<String, dynamic> responseData;
    if (response.data is String) {
      responseData = jsonDecode(response.data) as Map<String, dynamic>;
    } else if (response.data is Map) {
      responseData = response.data as Map<String, dynamic>;
    } else {
      throw Exception('Invalid response data format');
    }
    final user = UserModel.fromJson(responseData);
    if (user is UserModel) {
      state = Authenticated(user: user, updatedUser: user);

      return user;
    } else {
      return null;
    }
  }

  void setProfile({required UserModel user, UserModel? updatedUser}) {
    state = Authenticated(user: user, updatedUser: updatedUser);
  }

  Future<void> updateProfile({required UserModel user}) async {
    print('auth_controller updateProfile: ${user.toString()}');
    try {

      await ref.watch(authRepositoryProvider).updateUser(user: user);

      setProfile(user: user, updatedUser: user);
    } catch (error, stackTrace) {
      ref.read(errorControllerProvider.notifier).onError(error, stackTrace);
    }
  }
}