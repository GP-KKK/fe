import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:fe/src/shared/constants/constants.dart';
import 'package:http/http.dart' as http;

import 'package:fe/src/data/model/model.dart';
import 'package:fe/src/shared/theme/color_theme.dart';
import 'package:fe/src/shared/theme/text_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

final ValueNotifier<List<BaseMessage>> globalMessage =
    ValueNotifier<List<BaseMessage>>([]);

class MessageGroupChannelHandler extends GroupChannelHandler {
  @override
  void onMessageReceived(BaseChannel channel, BaseMessage message) {
    // You can customize how to display different types of messages with the result object in the message parameter.
    if (message is UserMessage) {
      // ...
      globalMessage.value = List.from(globalMessage.value)..add(message);
      print('receive user message');
    } else if (message is FileMessage) {
      // ...
      print('receive file message');
    } else if (message is AdminMessage) {
      // ...
      globalMessage.value = List.from(globalMessage.value)..add(message);
      print('receive admin message');
    }
  }

  @override
  void onMessageUpdated(BaseChannel channel, BaseMessage message) {
    // TODO: implement onMessageUpdated
    super.onMessageUpdated(channel, message);
    print('message updated');
  }

  @override
  void onMessageDeleted(BaseChannel channel, int messageId) {
    // TODO: implement onMessageDeleted
    super.onMessageDeleted(channel, messageId);
    print('message deleted');
  }
}

class ChatScreen extends StatefulWidget {
  GroupChannel groupChannel;
  UserModel? otherUser;

  String? email;
  ChatScreen({super.key, required this.groupChannel, this.otherUser, this.email});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showAdditionalOptions = false;
  bool _showMannerTemperature = false;

  void _toggleAdditionalOptions() {
    setState(() {
      _showAdditionalOptions = !_showAdditionalOptions;
    });
  }

  void _toggleMannerTemperature() {
    setState(() {
      _showMannerTemperature = true;
    });
  }


  Future<void> checkOnTap(UserModel usermodel) async {
    //초기화
    var email= usermodel.email;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('evaluation_$email');

  }

  // 이전 메세지 가져오기
  Future<void> makeMessageList() async {
    try {
      final query = PreviousMessageListQuery(
        channelType: widget.groupChannel.channelType,
        channelUrl: widget.groupChannel.channelUrl,
      )
        ..messageTypeFilter = MessageTypeFilter.all
        ..limit = 50; // default = 20

      globalMessage.value = await query.next();
    } catch (e) {
      // Handle error.
      print(
          'Error messages | chat_list_screen.dart | FloatingActionButton | message : $e');
    }
    setState(() {});
  }

  // 메세지 보내기 함수
  Future<void> _sendMessage() async {
    String text = _textController.text;
    if (text.trim().isNotEmpty) {
      try {
        final params = UserMessageCreateParams(message: text)
          ..pushNotificationDeliveryOption =
              PushNotificationDeliveryOption.normal;
        final message =
            widget.groupChannel.sendUserMessage(params, handler: (message, e) {
          if (e != null) {
            // Handle error.
            print(
                'Error messages | create_channel_screen.dart | handler() : $e');
          } else {
            // A text message with detailed configuration is successfully sent to the channel.
            print('Success to send Message');
          }
        });
      } catch (e) {
        // Handle error.
        print(
            'Error messages | create_channel_screen.dart | _sendMassage() : $e');
      }
      _textController.clear();
      await makeMessageList();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SendbirdChat.addChannelHandler(
        'group chatting message handler', MessageGroupChannelHandler());
    if (widget.otherUser != null) {
      // If UserModel is already provided, use it
    } else if (widget.email != null) {
      // If only email is provided, fetch the user information
      print('widget.email: ${widget.email.toString()}');
      fetchUserFromEmail(widget.email!);
    }

    makeMessageList();
  }

  //이메일로 유저 가져오기
  Future<void> fetchUserFromEmail(String email) async {
    try {
      UserModel? user = await getUser(email);
      if (user != null) {
        setState(() {
          widget.otherUser = user; // Set the user data if found
        });
      }
    } catch (e) {
      print('Error fetching user: $e');
    }
  }

  //getuser 서버 연동
  Future<UserModel?> getUser(String email) async {
    String ip = Constants.ip;
    Map<String, dynamic> json = {
      "email": email,
    };
    final Dio dio = Dio();

    print('create_channel email: $email');
    try {
      final response = await dio.get(
        '$ip/getUser',
        data: json,
      );

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch user');
      }
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    SendbirdChat.removeChannelHandler('group chatting message handler');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '채팅창',
          style: textTheme.titleSmall!.copyWith(
            color: ColorTheme.slateColor,
          ),
        ),
        centerTitle: true,
        foregroundColor: Colors.blueGrey,
        backgroundColor: Colors.white,
        leading: BackButton(
          onPressed: () {
            setState(() {
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/home_screen',
                (route) => false,
              );
            });
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: ColorTheme.primaryGradient),
        child: Column(
          children: <Widget>[
            // 추가 기능 목록 중 체크 아이콘 버튼을 눌렀을 때
            // 매너 온도 평가 목록
            if (_showMannerTemperature)
              Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(8.0),
                //color: Colors.grey[200],
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 30,
                  ),
                  child: ElevatedButton(
                    onPressed: () {},
                    child: Text(
                      "매너 온도 평가하러 가기",
                      style: textTheme.bodyMedium,
                    ),
                  ),
                ),
              ),
            // 수정
            // Padding(
            //   padding: const EdgeInsets.only(top: 15.0),
            //   child: AnimatedVisibility(
            //     isVisible: true,
            //     child: Container(
            //       margin: const EdgeInsets.only(bottom: 30.0),
            //       padding:
            //           const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            //       decoration: ShapeDecoration(
            //         color: ColorTheme.slateColor[400]!,
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(18),
            //         ),
            //       ),
            //       child: Text(
            //         '대화가 시작되었습니다.',
            //         style: textTheme.bodySmall!.copyWith(color: Colors.white),
            //       ),
            //     ),
            //   ),
            // ),
            // 채팅 화면
            Expanded(
              child: ValueListenableBuilder(
                  valueListenable: globalMessage,
                  builder: (BuildContext context, List<BaseMessage> value,
                      Widget? child) {
                    // 위젯이 빌드된 후에 스크롤 위치를 설정합니다.
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      // 스크롤의 최대 위치로 이동합니다.
                      _scrollController
                          .jumpTo(_scrollController.position.maxScrollExtent);
                    });
                    return ListView.builder(
                      controller: _scrollController,
                      itemCount: value.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Align(
                                alignment: (value[index].sender?.userId !=
                                        SendbirdChat.currentUser?.userId)
                                    ? Alignment.centerLeft
                                    : Alignment.centerRight,
                                // alignment: Alignment.centerRight,

                                child: Container(
                                    constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width *
                                              2 /
                                              3,
                                    ),
                                    padding: EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 16.0),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    child: Column(
                                      children: [
                                        Align(
                                          alignment: Alignment.topLeft,
                                          child: Text(
                                            value[index].message,
                                            style:
                                                textTheme.labelMedium!.copyWith(
                                              color: ColorTheme.slateColor,
                                            ),
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.bottomRight,
                                          child: Text(
                                            '${DateFormat('yyyy-MM-dd    kk:mm').format(DateTime.fromMillisecondsSinceEpoch(value[index].createdAt))}',
                                            style:
                                                textTheme.labelMedium!.copyWith(
                                              color: ColorTheme.slateColor,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }),
            ),
            // 추가 기능 목록
            //  더하기 아이콘 버튼을 눌렀을 때
            if (_showAdditionalOptions)
              Container(
                padding: EdgeInsets.all(8.0),
                color: Colors.grey[200],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // _buildCircleButton(Icons.phone, Colors.green, callOnTap),
                    // _buildCircleButton(
                    //     Icons.camera, Colors.purple, cameraOnTap),
                    _buildCircleButton(  Icons.check,
                      Colors.blue,
                          () async {
                        await checkOnTap(widget.otherUser!);
                      },
                    ),
                    _buildEvaluationButton(context,widget.otherUser!),
                    _buildTogetherButton(context,widget.otherUser! )
                  ],
                ),
              ),

            // 텍스트 필드 & 더하기 아이콘 버튼
            Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Stack(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        IconButton(
                          icon: Icon(
                            Icons.add,
                            color: Colors.grey,
                          ),
                          onPressed: _toggleAdditionalOptions,
                        ),
                        Expanded(
                          child: TextField(
                            controller: _textController,
                            decoration: InputDecoration(
                              hintText: '메세지를 입력하세요',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: const BorderSide(
                                    color: Colors
                                        .grey), // Set border color to gray
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10.0,
                                  horizontal:
                                      10), // Adjusted padding inside the TextField
                              hintStyle: TextStyle(
                                  fontSize: 15.0), // Decreased font size
                            ),
                          ),
                        ),
                      ],
                    ),

                    // 전송 아이콘 버튼
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: IconButton(
                        icon: const Icon(
                          Icons.send,
                          color: Colors.grey,
                        ),
                        onPressed: _sendMessage,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildCircleButton(
    IconData icon, Color iconColor, VoidCallback onPressed) {
  return Container(
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: Colors.black, width: 2), // 검정색 테두리
      color: iconColor,
    ),
    child: IconButton(
      icon: Icon(icon, color: Colors.white),
      onPressed: onPressed,
    ),
  );
}

Widget _buildTogetherButton(BuildContext context, UserModel userModel) {
  return ElevatedButton(
    onPressed: () async {
      //bool alreadyEvaluated = await _isEvaluationCompleted(userModel.email);
      // if (alreadyEvaluated) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(content: Text('이미 이 사용자를 평가하셨습니다.',style: TextStyle(color: Colors.black87))),
      //   );
      // } else {
      _showCompanionConfirmDialog(context, userModel.email);
      //}
    },
    child: const Text('동행 확인하기'),
  );
}
void _showCompanionConfirmDialog(BuildContext context, String email) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('동행 확인'),
        content: const Text('함께 동행했음을 확인하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // "아니요" 선택 시 다이얼로그 닫기
            child: const Text('아니요'),
          ),
          ElevatedButton(
            onPressed: () {
              _sendEvaluation(context, email, 1, 4); // 네 선택 시 4점 평가
              Navigator.pop(context); // 다이얼로그 닫기
            },
            child: const Text('네'),
          ),
        ],
      );
    },
  );
}

Widget _buildEvaluationButton(BuildContext context, UserModel userModel) {
  return ElevatedButton(
    onPressed: () async {
      _showEvaluationDialog(context, userModel.email);

      // bool alreadyEvaluated = await _isEvaluationCompleted(userModel.email);
      // if (alreadyEvaluated) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(content: Text('이미 이 사용자를 평가하셨습니다.',style: TextStyle(color: Colors.black87))),
      //   );
      // } else {
      // }
    },
    child: const Text('매너 온도 평가하기'),
  );
}

void _showEvaluationDialog(BuildContext context, String name) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('매너 온도 평가'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildEvaluationOption(context, '매우 불친절해요', 1, name, 1),
            _buildEvaluationOption(context, '불친절해요', 2, name, 1),
            _buildEvaluationOption(context, '보통이에요', 3, name, 1),
            _buildEvaluationOption(context, '친절해요', 4, name, 1),
            _buildEvaluationOption(context, '매우 친절해요', 5, name, 1),
          ],
        ),
      );
    },
  );
}
// 평가 완료 여부 저장
Future<void> _setEvaluationCompleted(String email) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('evaluated_$email', true); // email로 구분하여 저장
}

// 평가 완료 여부 확인
Future<bool> _isEvaluationCompleted(String email) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('evaluated_$email') ?? false; // 없을 경우 false 반환
}

Widget _buildEvaluationOption(BuildContext context, String text, int score, String email, int id) {
  return ListTile(
    title: Text(text,style: TextStyle(color: Colors.black87) ,),
    onTap: () {
      _sendEvaluation(context, email, id, score);
    },
  );
}

Future<void> _sendEvaluation(BuildContext context, String email, int id, int score) async {
  String ip = Constants.ip;

  final Uri url = Uri.parse('$ip/evaluate'); // 서버 URL
  final Map<String, dynamic> requestData = {
    'id': id,
    'email': email,
    'score': score,
  };

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestData),
    );

    if (response.statusCode == 200) {
      await _setEvaluationCompleted(email); // 평가 완료 상태 저장
      Navigator.of(context).pop(); // 팝업 닫기
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('평가가 성공적으로 완료되었습니다.', style: TextStyle(color: Colors.black87),)),
      );
    } else {
      throw Exception('평가 실패');
    }
  } catch (e) {
    Navigator.of(context).pop(); // 팝업 닫기
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('평가에 실패했습니다. 다시 시도해주세요.',style: TextStyle(color: Colors.black87))),
    );
  }
}

