import 'dart:developer';
import 'dart:io';
import 'package:fe/src/data/model/model.dart';
import 'package:fe/src/shared/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:fe/src/shared/theme/color_theme.dart';
import 'package:fe/src/shared/theme/text_theme.dart';
import 'package:dio/dio.dart';
import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';

import '../chat/create_channel_screen.dart'; // API 호출을 위한 dio 패키지

class QrCodeScreen extends StatefulWidget {
  @override
  State<QrCodeScreen> createState() => _QrCodeScreenState();
}

class _QrCodeScreenState extends State<QrCodeScreen> {
  UserModel? user; // 사용자 정보 저장
  bool isLoading = false; // 로딩 상태
  String? scannedEmail;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'QR Code Scanner',
          style: textTheme.titleSmall!.copyWith(
            color: ColorTheme.slateColor,
          ),
        ),
        centerTitle: true,
        foregroundColor: Colors.blueGrey,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
              ),
              child: QRViewExample(onScanComplete: _fetchUserInfo),
            ),
          ),
          if (isLoading) const CircularProgressIndicator(),
          if (user != null) _buildUserInfo(context),
        ],
      ),
    );
  }

  Future<void> _fetchUserInfo(String email) async {
    setState(() {
      isLoading = true;
    });

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

  Widget _buildUserInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            '사용자 정보',
            style: textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          Text(
            '이름: ${user?.name}',
            style: textTheme.bodyLarge,
          ),
          Text(
            '상태 메세지: ${user?.feel?.isNotEmpty == true ? user!.feel : '(없음)'}',
            style: textTheme.bodyLarge,
          ),

// 상태 텍스트 위젯
          Text(
            '상태: ${feelNames[user?.feelState ?? '알 수 없음']}',
            style: textTheme.bodyLarge,
          ),
          Text(
            '매너 온도: ${user?.emotionDegree.toStringAsFixed(1)}',
            style: textTheme.bodyLarge,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (user != null) {
                goToChat(user!.email);
              }
            },
            child: const Text('채팅하기'),
          ),
        ],
      ),
    );
  }
  final Map<FeelState, String> feelNames = {
    FeelState.DRIVING: '운전 중',
    FeelState.PARKING: '주차 중',
    FeelState.COMMING_SOON: '곧 돌아옵니다.',
    FeelState.BUSY: '바쁨',
    FeelState.UNKNOWN: '알 수 없음',
  };

  void goToChat(String email) async {
    String username = email.split('@')[0];
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

      await Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => ChatScreen(groupChannel: channel, otherUser: user),
      ));
    } catch (e) {
      print(
        'Error messages | chat_list_screen.dart | goToChat() : $e',
      );
    }
  }
}

class QRViewExample extends StatefulWidget {
  final Function(String) onScanComplete;

  const QRViewExample({Key? key, required this.onScanComplete}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool isScanning = false;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
        MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;

    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: Colors.red,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: scanArea,
      ),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });

    controller.scannedDataStream.listen((scanData) {
      if (!isScanning) {
        setState(() {
          isScanning = true;
          result = scanData;
        });

        if (result != null && result!.code != null) {
          String input = result!.code!;
          String email = input.split(':')[1].trim(); // 이메일 추출
          widget.onScanComplete(email);
        }
      }
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
