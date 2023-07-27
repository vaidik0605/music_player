import 'package:flutter/material.dart';
import 'package:music_player/components/app_text.dart';
import 'package:music_player/constants/string_constant.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: AppText(title: '${AppStringConstant.about} page'),
      ),
    );
  }
}
