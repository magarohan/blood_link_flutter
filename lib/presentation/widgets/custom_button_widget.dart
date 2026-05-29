import 'package:flutter/material.dart';

import '../../themes/colors.dart';

class CustomButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final bool isFilled;
  final double? height;
  final double? width;
  const CustomButton(
      {super.key,
      required this.title,
      required this.onTap,
      required this.isFilled,
      this.height,
      this.width});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: width ?? MediaQuery.of(context).size.width * 0.90,
        height: height ?? MediaQuery.of(context).size.width * 0.15,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isFilled ? MyColors.primaryColor : MyColors.backgroundColor,
            border: Border.all(color: MyColors.primaryColor)),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
                color: isFilled ? Colors.white : MyColors.primaryColor,
                fontSize: 16,
                fontWeight: FontWeight(600)),
          ),
        ),
      ),
    );
  }
}
