import 'package:flutter/material.dart';
import 'package:portfolio_plus/utils/colors.dart';
import 'package:portfolio_plus/utils/ts.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isCenterTitle;
  final bool isBackButton;
  final double height;

  const CustomAppBar({
    super.key,
    required this.title,
    this.isCenterTitle = true,
    this.isBackButton = true,
    this.height = 48.0,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: Ts.semiBold18(AppColors.black),
      ),
      centerTitle: isCenterTitle,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: isBackButton
          ? IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          : null,
    );
  }
}
