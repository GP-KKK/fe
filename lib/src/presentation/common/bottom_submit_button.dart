import 'package:flutter/material.dart';
import 'package:fe/src/presentation/common/custom_button.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class BottomSubmitButton extends ConsumerWidget {
  final String? buttonTitle;
  final VoidCallback? onPressed;

  const BottomSubmitButton(
      {super.key, required this.onPressed, this.buttonTitle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: 108,
      child: Column(
        children: [
          Container(
            height: 20,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: const Alignment(0.00, -1.00),
                end: const Alignment(0, 1),
                colors: [Colors.white.withOpacity(0), Colors.white],
              ),
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 40),
            child: CustomButton(
              onPressed: onPressed,
              buttonSize: ButtonSize.xl,
              buttonContent: Text(
                '저장하기',
                style: textTheme.labelMedium!.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
