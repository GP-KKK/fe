import 'dart:io';

import 'package:fe/src/data/model/model.dart';
import 'package:fe/src/presentation/common/scale_custom_button.dart';
import 'package:fe/src/presentation/common/user_profile_icon.dart';
import 'package:fe/src/shared/theme/color_theme.dart';
import 'package:fe/src/shared/theme/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MenuButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final String imagePath;
  final Color backgroundColor; // 배경색 매개변수 추가

  MenuButton({
    required this.title,
    required this.onPressed,
    required this.imagePath,
    required this.backgroundColor, // 생성자에서 배경색을 받도록 수정
  });

  @override
  Widget build(BuildContext context) {
    String img = imagePath;
    return Container(
      padding: const EdgeInsets.all(10),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor, // 전달받은 배경색 사용
          minimumSize: Size(100, 170), // 버튼의 최소 크기 설정
          padding: EdgeInsets.symmetric(horizontal: 27.0, vertical: 16.0),
          textStyle: TextStyle(fontSize: 20), // 텍스트 스타일 설정
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15), // 모서리 둥글기 조정
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(right: 10),
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/$img.png'),
                ),
              ),
            ),
            Expanded(
              child: Text(
                title,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleSmall!.copyWith(
                  color: ColorTheme.slateColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
