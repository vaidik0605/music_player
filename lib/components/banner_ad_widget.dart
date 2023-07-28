import 'package:applovin_max/applovin_max.dart';
import 'package:flutter/material.dart';
import 'package:music_player/pages/home_page/home_page.dart';

class AppBannerAdView extends StatelessWidget {
  const AppBannerAdView({super.key});

  @override
  Widget build(BuildContext context) {
    if(isShowAds && bannerUnitId.isNotEmpty){
      return MaxAdView(
          adUnitId: bannerUnitId,
          adFormat: AdFormat.banner,
          isAutoRefreshEnabled: true);
    }
    return SizedBox();

  }
}
