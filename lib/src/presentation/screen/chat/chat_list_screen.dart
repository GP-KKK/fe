import 'package:dio/dio.dart';
import 'package:fe/src/data/model/model.dart';
import 'package:fe/src/presentation/screen/chat/create_channel_screen.dart';
import 'package:fe/src/shared/theme/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';

import '../../../shared/theme/color_theme.dart';

class ChatListScreen extends StatefulWidget {
  @override
  State<ChatListScreen> createState() => _ChatListState();
}

class _ChatListState extends State<ChatListScreen> {
  late List<GroupChannel> _channels = [];
  final ScrollController _scrollController = ScrollController();

  // make channel list
  Future<void> makeChannelList() async {
    // Retrieve all users.
    final query = GroupChannelListQuery()
      ..userIdsIncludeFilter = [SendbirdChat.currentUser!.userId];

    try {
      _channels = await query.next();
      setState(() {});
    } catch (e) {
      // Handle error.
      print('Error messages | chat_list_screen.dart | MyInit() : $e');
    }
  }

  @override
  void initState() {
    super.initState();
    SendbirdChat.addChannelHandler(
        'group chatting message handler', MessageGroupChannelHandler());
    makeChannelList();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    SendbirdChat.removeChannelHandler('group chatting message handler');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    makeChannelList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '채팅 목록',
          style: textTheme.titleSmall!.copyWith(
            color: ColorTheme.slateColor,
          ),
        ),
        centerTitle: true,
        foregroundColor: Colors.blueGrey,
        backgroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: ColorTheme.primaryGradient),
        child: ValueListenableBuilder(
            valueListenable: globalMessage,
            builder:
                (BuildContext context, List<BaseMessage> value, Widget? child) {
              return ListView.builder(
                controller: _scrollController,
                itemCount: _channels.length,
                itemBuilder: (context, index) {
                  GroupChannel channel = _channels[index];


                  return Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: GestureDetector(
                      onTap: () async {
                        await Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                ChatScreen(groupChannel: channel, email: channel.data,)));
                        makeChannelList();
                      },
                      child: Stack(
                        children: [
                          Container(
                            constraints: const BoxConstraints(minHeight: 94),
                            padding: const EdgeInsets.only(
                              top: 20,
                              left: 10,
                              right: 14,
                              bottom: 20,
                            ),
                            decoration: ShapeDecoration(
                              color: Colors.white.withOpacity(0.7),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              // shadows: [
                              //   if (currentQuest.currentScreen != null)
                              //     const BoxShadow(
                              //       color: ColorTheme.shadow,
                              //       blurRadius: 2,
                              //       offset: Offset(0, 1),
                              //     )
                              // ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(right: 10),
                                  width: 52,
                                  height: 52,
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image:
                                          AssetImage('assets/images/talk.png'),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${channel.name}와의 대화',
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                          style: textTheme.bodyLarge!.copyWith(
                                            color: ColorTheme.slateColor,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        // if (currentQuest.currentScreen == null)
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              channel.lastMessage?.message ??
                                                  '아직 대화가 없습니다',
                                              style: textTheme.labelSmall!
                                                  .copyWith(
                                                color: ColorTheme.primaryColor,
                                              ),
                                            ),
                                            (channel.lastMessage != null)
                                                ? Text(
                                                    '${DateFormat('yyyy-MM-dd    kk:mm').format(DateTime.fromMillisecondsSinceEpoch(_channels[index].lastMessage!.createdAt))}',
                                                    style: textTheme.labelSmall!
                                                        .copyWith(
                                                      color: ColorTheme
                                                          .primaryColor,
                                                    ),
                                                  )
                                                : Text(''),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
      ),
      // floatingActionButton: FloatingActionButton(//여기있는 걸 QR 찍었었을때 바로 되게해서 바로 채팅창으로 넘어가게끔
      //   onPressed: () async {
      //     try {
      //       final channel_params = GroupChannelCreateParams()
      //         // 김성민
      //         // 1234235는 한 current user와 대화할 새로운 사람의 uid
      //         // 임시로 chat_list_screen의 floatingButton에 새로운 대화 시작 기능을 구현해놓음
      //         ..userIds = [SendbirdChat.currentUser!.userId, '이거 뭐로 할래?']//여기다가 상대방 아이디 587503
      //         ..isDistinct = true
      //         ..name = 'chat with ???'; // 채팅방 이름 623747 '김성민'
      //
      //       final channel = await GroupChannel.createChannel(channel_params);
      //       await Navigator.of(context).push(MaterialPageRoute(
      //           builder: (context) => ChatScreen(groupChannel: channel)));
      //       makeChannelList();
      //     } catch (e) {
      //       // Handle error.
      //       print(
      //           'Error messages | chat_list_screen.dart | FloatingActionButton | channel : $e');
      //     }
      //     setState(() {});
      //   },
      //   child: Icon(Icons.add),
      // ),
    );
  }
}
