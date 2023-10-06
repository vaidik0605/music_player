import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:music_player/components/app_image_assets.dart';
import 'package:music_player/components/app_text.dart';
import 'package:music_player/components/audio_player.dart';
import 'package:music_player/constants/asset_constant.dart';
import 'package:music_player/constants/color_constant.dart';
import 'package:music_player/constants/string_constant.dart';
import 'package:music_player/utils/all_logs.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String version = '';

  @override
  void initState() {
    getDeviceInfo();
    super.initState();
  }

  getDeviceInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    logs('version --> ${packageInfo.version}');
    version = packageInfo.version;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppText(title: AppStringConstant.about, fontSize: 16.px),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(
              Icons.arrow_back,
              color: ColorConstant.white,
            )),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: Device.height * 0.01.h),
              AppImageAsset(
                  image: AssetConstant.appLogo,
                  height: 130.px,
                  width: 130.px,
                  fit: BoxFit.cover),
              SizedBox(height: Device.height * 0.04.h),
              AppText(
                  title: version,
                  fontSize: 12.px,
                  fontColor: ColorConstant.white.withOpacity(0.6)),
              SizedBox(height: 10.px),
              AppText(title: 'Music', fontSize: 16.px, letterSpacing: 0.5),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const MiniPlayer(),
    );
  }
}
