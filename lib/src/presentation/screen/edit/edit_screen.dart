import 'dart:convert';

import 'package:fe/src/data/model/model.dart';
import 'package:fe/src/presentation/common/adaptive_bottom_sheet.dart';
import 'package:fe/src/presentation/common/bottom_submit_button.dart';
import 'package:fe/src/presentation/common/custom_popup_button.dart';
import 'package:fe/src/presentation/common/custom_text_field.dart';
import 'package:fe/src/presentation/controller/controller.dart';
import 'package:fe/src/presentation/layout/scollable_layout.dart';
import 'package:fe/src/presentation/screen/edit/widget/feel_state_bottom_sheet.dart';
import 'package:fe/src/presentation/screen/edit/widget/profile_image_bottom_sheet.dart';
import 'package:fe/src/presentation/screen/edit/widget/profile_image_modify_button.dart';
import 'package:fe/src/presentation/utils/form_validate_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditScreen extends ConsumerStatefulWidget {
  const EditScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditScreenState();
}

class _EditScreenState extends ConsumerState<EditScreen> {
  final GlobalKey<FormState> formKey = GlobalKey();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _feelFocus = FocusNode();

  bool isProfileInfoChanged = false;


  void onSubmitted(UserModel user) async {
    print("onSubmitted");
    FocusScope.of(context).unfocus();

    if (formKey.currentState == null) {
      return;
    }

    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      await ref.read(authControllerProvider.notifier).updateProfile(user: user);
      formKey.currentState!.reset();
      goToBeforeScreen();
    } else {
      print('invalid form');
    }
  }

  void goToBeforeScreen() {
    Navigator.of(context).pop();
  }
  Widget _buildTextField({
    String? labelText,
    required String hintText,
    required String initialValue,
    required ValueChanged<String> onChanged,
    int? maxLength,
    String? Function(String?)? validator,
    TextInputAction textInputAction = TextInputAction.next,
    FocusNode? focusNode,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return CustomTextField(
      onChanged: onChanged,
      initialValue: initialValue,
      focusNode: focusNode,
      maxLength: maxLength,
      labelText: labelText,
      hintText: hintText,
      validator: validator,
      textInputAction: textInputAction,
      keyboardType: keyboardType,
    );
  }

  Widget _buildPopupButton({
    String? labelText,
    String? hintText,
    required String? textValue,
    required VoidCallback onTap,
  }) {
    return CustomPopupButton(
      labelText: labelText,
      hintText: hintText,
      textValue: textValue,
      onTap: onTap,
    );
  }
  final Map<FeelState, String> feelNames = {
    FeelState.DRIVING: ('운전 중'),
    FeelState.PARKING: ('주차 중'),
    FeelState.COMMING_SOON: ('곧 돌아옵니다.'),
    FeelState.BUSY: ('바쁨'),
    FeelState.UNKNOWN : ('알 수 없음'),
  };

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final account = ref.watch(authControllerProvider) as Authenticated;
    UserModel currentUser = account.user;

    print('account.user: ${account.user}');
    print('account.updatedUser: ${account.updatedUser}');
    UserModel updatedUser = account.updatedUser!;
    ref.listen<AuthState>(authControllerProvider, (_, state) {
      if (state is Authenticated) {
        final UserModel updatedUser = state.updatedUser!;

        // UserModel의 모든 필드를 비교
        bool hasChanged = currentUser.name != updatedUser.name ||
            currentUser.email != updatedUser.email ||
            currentUser.profileImage != updatedUser.profileImage ||
            currentUser.source != updatedUser.source ||
            currentUser.feelState != updatedUser.feelState ||
            currentUser.feel != updatedUser.feel ||
            currentUser.emotionDegree != updatedUser.emotionDegree;

        // 상태 변경 감지 시 UI 업데이트
        if (hasChanged) {
          setState(() {
            isProfileInfoChanged = true;
          });
        }
      }
    });
    String name= updatedUser.name;
    String feel= updatedUser.feel;
    FeelState feelstate= updatedUser.feelState;
    if (account.updatedUser != null) {
      return GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: ScrollableLayout(
          isAppBarVisible: true,
          appBarTitle:
          Text(('editProfile'), style: textTheme.labelMedium),
          backgroundColor: Colors.white,
          innerTopPadding: 0,
          bottomTabBar: BottomSubmitButton(
            onPressed: (){
              if(name!=currentUser.name || feel!=currentUser.feel||feelstate!=currentUser.feelState){
                isProfileInfoChanged=true;
              }
              if(isProfileInfoChanged){
                onSubmitted(updatedUser);
              }
            }
          ),
          children: [
            Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 20),
                    child: ProfileImageModifyButton(
                        onTap: () => _showProfileImageBottomSheet()),
                  ),
                  Wrap(
                    runSpacing: 25,
                    spacing: 25,
                    children: [
                      _buildTextField(
                        labelText: ('닉네임'),
                        hintText: ('닉네임을 입력하세요.'),
                        maxLength: 20,
                        initialValue: updatedUser.name,
                        onChanged: (value) {
                          name=value;
                          print(name);
                        },

                        focusNode: _nameFocus,
                        validator: (value) => FormValidateUtils()
                            .validateName(_nameFocus, value!),
                      ),

                      _buildTextField(
                        labelText: ('내 상태 메세지를 입력하세요'),
                        hintText: ('내 상태 메세지를 입력하세요'),
                        maxLength: 20,
                        initialValue: updatedUser.feel,
                        onChanged: (value) {
                          feel=value;
                        },
                        focusNode: _feelFocus,
                        validator: (value) => FormValidateUtils()
                            .validateName(_feelFocus, value!),
                      ),
                      _buildPopupButton(
                        labelText: '내 상태',
                        textValue: feelNames[updatedUser.feelState],
                        onTap: () => _showFeelStateBottomSheet(),
                      ),

                      SizedBox(
                          width: 200, // 원하는 너비
                          height: 200, // 원하는 높이


                        child: Image.memory(base64Decode(updatedUser.qrcode!))
                      )


                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        //context.go(Routes.myPage);
      });
      return const SizedBox.shrink();
    }
  }

  void updateField(UserModel currentUser, UserModel updateUser, String field,
      dynamic value) {
    switch (field) {
      case 'name':
        ref.watch(authControllerProvider.notifier).setProfile(
            user: currentUser, updatedUser: updateUser.copyWith(name: value));
        break;

    }
  }
  void _showFeelStateBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return const AdaptiveBottomSheet(childWidget: FeelStateBottomSheet());
      },
    );
  }

  void _showProfileImageBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return const AdaptiveBottomSheet(
            childWidget: ProfileImageBottomSheet());
      },
    );
  }

}

