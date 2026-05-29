import 'package:blood_link/core/constants/images.dart';
import 'package:flutter/material.dart';

class CustomBackgroundWidget extends StatelessWidget {
  final Widget body;
  const CustomBackgroundWidget({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Stack(
      children: [
        Positioned.fill(child: Image.asset(kBackgroundImage)),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: body,
        )
      ],
    ));
  }
}
