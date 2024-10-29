// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:fe/src/presentation/common/speech_bubble.dart';
// import 'package:fe/src/presentation/common/user_profile_icon.dart';
// //import 'package:fe/src/presentation/controller/controller.dart';
// import 'package:fe/src/shared/theme/color_theme.dart';
//
// class UserActionBubble extends ConsumerWidget {
//   final bool isSelectedFirstState;
//   final String firstStateText;
//   final String secondStateText;
//   final bool firstState;
//   final bool secondState;
//   final VoidCallback? handleFirstState;
//   final VoidCallback? handleSecondState;
//
//   const UserActionBubble({
//     super.key,
//     required this.isSelectedFirstState,
//     this.firstStateText = '',
//     this.secondStateText = '',
//     this.firstState = false,
//     this.secondState = false,
//     this.handleFirstState,
//     this.handleSecondState,
//   });
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final account = ref.watch(authControllerProvider);
//     final textTheme = Theme.of(context).textTheme;
//
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 30.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//             child: SpeechBubble(
//               borderColor: ColorTheme.primaryColor[300],
//               backgroundColor: ColorTheme.primaryColor[50],
//               tailPosition: TailPosition.right,
//               textContent: Column(
//                 children: [
//                   if (!isSelectedFirstState)
//                     Container(
//                       margin: const EdgeInsets.only(bottom: 6.0),
//                       child: CustomSelectedButton(
//                         isDisabled: secondState,
//                         isSelected: firstState,
//                         onPressed: handleFirstState ?? () {},
//                         buttonContent: _buildButtonContent(
//                           firstStateText,
//                           secondState ? false : firstState,
//                           textTheme,
//                         ),
//                       ),
//                     ),
//                   CustomSelectedButton(
//                     isDisabled: firstState,
//                     isSelected: secondState,
//                     onPressed: handleSecondState ?? () {},
//                     buttonContent: _buildButtonContent(
//                       secondStateText,
//                       secondState,
//                       textTheme,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           if(account is Authenticated && account.user.profileImage != null)
//           UserProfileIcon(
//             profileImage: account.user.profileImage!,
//           )
//         ],
//       ),
//     );
//   }
//
//   Widget _buildButtonContent(
//       String text, bool isSelected, TextTheme textTheme) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         if (isSelected)
//           Container(
//             margin: const EdgeInsets.only(right: 3.0),
//             child: SvgPicture.asset(
//               'assets/images/svg/check.svg',
//               width: 14.0,
//               height: 14.0,
//             ),
//           ),
//         Text(
//           text,
//           style: textTheme.bodySmall!.copyWith(
//             color: isSelected ? ColorTheme.primaryColor : ColorTheme.slateColor,
//           ),
//         ),
//       ],
//     );
//   }
// }
