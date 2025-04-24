import 'package:flutter/material.dart';

// ignore: must_be_immutable
class TopBarLogo extends StatelessWidget {
  Color backGroundColor = Colors.red;
  Color borderColor = Colors.red;
  String imagePath = "";

  TopBarLogo({
    super.key,
    required this.imagePath,
    required this.backGroundColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: backGroundColor,
        border: Border(
          top: BorderSide(color: borderColor, width: 2),
          left: BorderSide(color: borderColor, width: 2),
        ),
      ),
      child: Center(child: Image.asset(imagePath, width: 250, height: 150)),
    );
  }
}
