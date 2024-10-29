import 'package:dio/dio.dart';
import 'package:fe/src/shared/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';

import '../../../data/model/model.dart';
import '../chat/create_channel_screen.dart';

class TogetherScreen extends StatefulWidget {
  @override
  _TogetherScreenState createState() => _TogetherScreenState();
}

class _TogetherScreenState extends State<TogetherScreen> {
  List<Map<String, dynamic>> nearbyUsers = [];
  UserModel? user; // 사용자 정보 저장

  @override
  void initState() {
    super.initState();
    fetchNearbyUsers();
  }

  Future<void> fetchNearbyUsers() async {
    final DatabaseReference ref = FirebaseDatabase.instance.ref('users');
    final DataSnapshot snapshot = await ref.get();

    Position currentPosition = await Geolocator.getCurrentPosition();

    List<Map<String, dynamic>> users = [];

    for (var user in snapshot.children) {
      double latitude = (user.child('latitude').value ?? 0.0) as double;
      double longitude = (user.child('longitude').value ?? 0.0) as double;
      String name = user.child('name').value as String;
      String email = user.key as String;

      double distance = Geolocator.distanceBetween(
        currentPosition.latitude,
        currentPosition.longitude,
        latitude,
        longitude,
      );

      users.add({
        'name': name,
        'email': email,
        'distance': distance,
      });
    }

    users.sort((a, b) => a['distance'].compareTo(b['distance']));
    print('users.toString(): ${users.toString()}');
    setState(() {
      nearbyUsers = users;
      print('nearbyUsers: $nearbyUsers');

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('근처 유저 목록',style: TextStyle(color: Colors.black87))),
      body: SafeArea(
        child: nearbyUsers.isEmpty
            ? const Center(child: Text('근처에 있는 유저를 불러오고 있어요.'))
            : ListView.builder(
          itemCount: nearbyUsers.length-1,
          itemBuilder: (context, index) {
            final user = nearbyUsers[index+1];
            return Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10.0, vertical: 5.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFFDF98FC), // 연한 하늘색 배경
                  borderRadius: BorderRadius.circular(15.0), // 모서리 둥글게
                  border: Border.all(
                    color: Color(0xFFDF98FC), // 테두리 색
                    width: 1.5, // 테두리 두께
                  ),
                ),

                child: ListTile(
                  title: Text('유저 이름 : ${user['name']}', style: TextStyle(color: Colors.white),),
                  subtitle: Text('거리: ${user['distance'].toStringAsFixed(2)} m', style: TextStyle(color: Colors.white)),
                  onTap: () => showMessageInputDialog(user['email'],user['name']),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void showMessageInputDialog(String email, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('동행 요청'),
        content: Text('$name님께 동행을 요청하기 위해 채팅을 시작하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // "아니요" 선택 시 닫기
            child: const Text('아니요'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // 다이얼로그 닫기
              goToChat(email); // "예" 선택 시 채팅 화면으로 이동
            },
            child: const Text('예'),
          ),
        ],
      ),
    );
  }
  bool isLoading = false; // 로딩 상태

  Future<void> _fetchUserInfo(String email) async {
    setState(() {
      isLoading = true;
    });

    email='$email@naver.com';
    try {
      final dio = Dio();
      print('email: ${email}');
      Map<String, dynamic> json = {
        "email": email,
      };
      String ip = Constants.ip;
      final response = await dio.get(
        '$ip/getUser',
        data: json,
      );

      if (response.statusCode == 200) {
        setState(() {
          user = UserModel.fromJson(response.data);
        });
      } else {
        print('사용자 정보를 불러오지 못했습니다.');
      }
    } catch (e) {
      print('Error fetching user info: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void goToChat(String email) async {
    _fetchUserInfo(email);
    String username=email;
    try {
      final channelParams = GroupChannelCreateParams()
        ..userIds = [SendbirdChat.currentUser!.userId, username]
        ..isDistinct = true
        ..name = user!.name
        ..data=user!.email;

      final channel = await GroupChannel.createChannel(channelParams);

      final params = GroupChannelUpdateParams()
        ..name = user!.name
        ..data=user!.email;
      await channel.updateChannel(params);

      await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ChatScreen(groupChannel: channel, otherUser: user),
      ));
    } catch (e) {
      print(
        'Error messages | chat_list_screen.dart | goToChat() : $e',
      );
    }
  }


  void showResultDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}
