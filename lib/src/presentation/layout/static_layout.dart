import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fe/src/shared/theme/color_theme.dart';

class StaticLayout extends StatefulWidget {
  final List<Widget> children;
  final bool isAppBarVisible;
  final Widget? appBarTitle;
  final double innerTopPadding;
  final Color? backgroundColor;
  final Gradient? gradientColor;
  final MainAxisAlignment? mainAxisAlignment;
  final CrossAxisAlignment? crossAxisAlignment;
  final Function? onBackButtonPressed;

  const StaticLayout({
    super.key,
    required this.children,
    this.isAppBarVisible = false,
    this.appBarTitle,
    this.innerTopPadding = 50.0,
    this.backgroundColor,
    this.gradientColor,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    this.onBackButtonPressed,
  });

  @override
  State<StaticLayout> createState() => _StaticLayoutState();
}

class _StaticLayoutState extends State<StaticLayout> {
  @override
  Widget build(BuildContext context) {
    final viewTopPadding = MediaQuery.of(context).padding.top;
    final viewBottomPadding = MediaQuery.of(context).padding.bottom;

    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (!didPop) {
          if (widget.onBackButtonPressed != null) {
            widget.onBackButtonPressed!();
          } else {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          }

          return;
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: widget.isAppBarVisible ? _buildAppBar() : null,
        backgroundColor: widget.backgroundColor ?? Colors.white,
        body: Container(
          decoration: BoxDecoration(gradient: widget.gradientColor),
          padding: EdgeInsets.only(
            top: widget.isAppBarVisible
                ? 0
                : widget.innerTopPadding + viewTopPadding,
            bottom: viewBottomPadding,
            left: 20.0,
            right: 20.0,
          ),
          child: Column(
            mainAxisAlignment:
            widget.mainAxisAlignment ?? MainAxisAlignment.spaceBetween,
            crossAxisAlignment:
            widget.crossAxisAlignment ?? CrossAxisAlignment.stretch,
            children: widget.children,
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: widget.appBarTitle,
      centerTitle: true,
      //leading: _buildLeadingIcon(),
      leadingWidth: 42,
      backgroundColor: widget.backgroundColor ?? Colors.white,
      scrolledUnderElevation: 0.0,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
        systemStatusBarContrastEnforced: false,
        statusBarColor: Colors.transparent,
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.0),
        child: _buildBottomBorder(),
      ),
    );
  }

  // GestureDetector _buildLeadingIcon() {
  //   return GestureDetector(
  //     onTap: () => Navigator.of(context).canPop()
  //         ? Navigator.of(context).pop()
  //         : context.go(Routes.home),
  //     child: SvgPicture.asset('assets/images/svg/chevron_left.svg',
  //         width: 20, height: 20),
  //   );
  // }

  Container _buildBottomBorder() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
            bottom: BorderSide(color: ColorTheme.slateColor[200]!, width: 1.0)),
      ),
    );
  }
}
