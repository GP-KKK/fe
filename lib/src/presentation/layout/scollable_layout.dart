import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fe/src/shared/theme/color_theme.dart';

class ScrollableLayout extends StatefulWidget {
  final List<Widget> children;
  final bool isAppBarVisible;
  final Widget? appBarTitle;
  final double innerTopPadding;
  final double sidePadding;
  final Color? backgroundColor;
  final Gradient? gradientColor;
  final ScrollController? scrollController;
  final PreferredSizeWidget? customAppBar;
  final SliverAppBar? sliverAppBar;
  final Widget? bottomTabBar;
  final Widget? actionIcon;
  final Widget? leadingIcon;
  final ScrollPhysics? scrollPhysics;
  final Function? onBackButtonPressed;

  const ScrollableLayout({
    super.key,
    required this.children,
    this.isAppBarVisible = false,
    this.appBarTitle,
    this.innerTopPadding = 100.0,
    this.sidePadding = 20.0,
    this.backgroundColor,
    this.gradientColor,
    this.scrollController,
    this.customAppBar,
    this.sliverAppBar,
    this.bottomTabBar,
    this.actionIcon,
    this.leadingIcon,
    this.scrollPhysics,
    this.onBackButtonPressed,
  });

  @override
  State<ScrollableLayout> createState() => _ScrollableLayoutState();
}

class _ScrollableLayoutState extends State<ScrollableLayout> {
  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

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
      child: SafeArea(
        top: false,
        bottom: Platform.isAndroid ? true : false,
        child: Scaffold(
          appBar: widget.isAppBarVisible ? _buildAppBar() : null,
          backgroundColor: widget.backgroundColor ?? Colors.white,
          body: Stack(
            children: [
              Container(
                decoration: BoxDecoration(gradient: widget.gradientColor),
                child: _buildCustomScrollView(),
              ),
              if (widget.bottomTabBar != null)
                Positioned(
                  bottom: keyboardHeight > 0 ? -108 : 0,
                  left: 0,
                  right: 0,
                  child: widget.bottomTabBar!,
                ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return widget.customAppBar ??
        AppBar(
          title: widget.appBarTitle,
          centerTitle: true,
          leading: widget.leadingIcon ?? _buildLeadingIcon(),
          leadingWidth: 42,
          actions: widget.actionIcon != null ? [widget.actionIcon!] : null,
          backgroundColor: widget.backgroundColor ?? Colors.white,
          scrolledUnderElevation: 0.0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(0.0),
            child: _buildBottomBorder(),
          ),
        );
  }

  Widget _buildLeadingIcon() {
    return GestureDetector(
      // onTap: () => Navigator.of(context).canPop()
      //     ? Navigator.of(context).pop()
      //     : context.go(Routes.home),
      child: SvgPicture.asset('assets/images/svg/chevron_left.svg',
          width: 20, height: 20),
    );
  }

  Container _buildBottomBorder() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
            bottom: BorderSide(color: ColorTheme.slateColor[200]!, width: 1.0)),
      ),
    );
  }

  CustomScrollView _buildCustomScrollView() {
    final viewTopPadding = MediaQuery.of(context).padding.top;
    final viewBottomPadding = MediaQuery.of(context).padding.bottom;

    return CustomScrollView(
      controller: widget.scrollController,
      physics: widget.scrollPhysics,
      slivers: <Widget>[
        if (widget.sliverAppBar != null) widget.sliverAppBar!,
        SliverPadding(
          padding: EdgeInsets.only(
            top: widget.customAppBar != null ||
                    widget.isAppBarVisible ||
                    widget.sliverAppBar != null
                ? widget.innerTopPadding
                : viewTopPadding + widget.innerTopPadding,
            left: widget.sidePadding,
            right: widget.sidePadding,
            bottom: viewBottomPadding,
          ),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) => widget.children[index],
              childCount: widget.children.length,
            ),
          ),
        ),
      ],
    );
  }
}
