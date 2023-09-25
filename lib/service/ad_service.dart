import 'dart:math';

import 'package:applovin_max/applovin_max.dart' as applovin;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:music_player/constants/color_constant.dart';
import 'package:music_player/controller/player_controller.dart';
import 'package:music_player/pages/home_page/home_page.dart';
import 'package:music_player/utils/all_logs.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class AdService {
  static InterstitialAd? googleInterstitialAd;
  static int numInterstitialLoadAttempts = 0;

  static SizedBox createGoogleBannerAd() {
    BannerAd bannerAd = BannerAd(
        size: AdSize.banner,
        adUnitId: adModel.data!.gBanner ?? '',
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) {},
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            ad.dispose();
            logs('Google banner ad failed to load with error ---> $error');
            createApplovinBannerAds();
          },
          onAdOpened: (Ad ad) {},
          onAdClosed: (Ad ad) {},
        ),
        request: const AdRequest());
    bannerAd.load();
     return SizedBox(
      height: bannerAd.size.height.toDouble(),
      width: bannerAd.size.width.toDouble(),
      child: AdWidget(ad: bannerAd),
    );
  }

 static Widget loadNativeAd()  {
    if (adModel.data != null && adModel.data!.gNative != null && adModel.data!.gNative!.isNotEmpty) {
      NativeAd nativeAd = NativeAd(
          adUnitId: adModel.data!.gNative ?? '',
          listener: NativeAdListener(
            onAdLoaded: (ad) {
             logs('Native ad loaded ---> ');
            },
            onAdFailedToLoad: (ad, error) {
              // Dispose the ad here to free resources.
              logs('$NativeAd failedToLoad: $error');
              ad.dispose();
            },
            // Called when a click is recorded for a NativeAd.
            onAdClicked: (ad) {},
            // Called when an impression occurs on the ad.
            onAdImpression: (ad) {},
            // Called when an ad removes an overlay that covers the screen.
            onAdClosed: (ad) {},
            // Called when an ad opens an overlay that covers the screen.
            onAdOpened: (ad) {},
            // For iOS only. Called before dismissing a full screen view
            onAdWillDismissScreen: (ad) {},
            // Called when an ad receives revenue value.
            onPaidEvent: (ad, valueMicros, precision, currencyCode) {},
          ),
          request: const AdRequest(),
          // Styling
          nativeTemplateStyle: NativeTemplateStyle(
              templateType: TemplateType.small,
              mainBackgroundColor: ColorConstant.black87,
              cornerRadius: 20.px,
              callToActionTextStyle: NativeTemplateTextStyle(
                  textColor: ColorConstant.white,
                  backgroundColor:Colors.orange,
                  style: NativeTemplateFontStyle.bold,
                  size: 15.px),
              primaryTextStyle: NativeTemplateTextStyle(
                  textColor: ColorConstant.white,
                  backgroundColor: ColorConstant.black87,
                  style: NativeTemplateFontStyle.monospace,
                  size: 16.px),
              secondaryTextStyle: NativeTemplateTextStyle(
                  textColor: ColorConstant.white,
                  backgroundColor: ColorConstant.black87,
                  style: NativeTemplateFontStyle.bold,
                  size: 16.px),
              tertiaryTextStyle: NativeTemplateTextStyle(
                  textColor: ColorConstant.white,
                  backgroundColor: ColorConstant.black87,
                  style: NativeTemplateFontStyle.normal,
                  size: 16.px)));
      nativeAd.load();
      return  ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: 320, // minimum recommended width
            minHeight: 60, // minimum recommended height
            maxWidth: double.infinity,
            maxHeight: 80,
          ),
          child: AdWidget(ad: nativeAd));
    }
    return const SizedBox();
  }

    static void createGoogleInterstitialAd() {
    InterstitialAd.load(
      adUnitId: adModel.data!.gInt ?? '',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          googleInterstitialAd = ad;
          numInterstitialLoadAttempts = 0;
          audioPlayer.play();
          googleInterstitialAd!.setImmersiveMode(true);
        },
        onAdFailedToLoad: (LoadAdError error) {
          logs(
              'Google interstitial ad failed to load with error ---> ${error.message}');
          numInterstitialLoadAttempts = 0;
          googleInterstitialAd = null;
          createApplovinInterstitialAds();
        },
      ),
    ).catchError((error) {
      logs(
          'Google interstitial ad failed to load with error ---> ${error.message}');
      createApplovinInterstitialAds();
    });
  }

  static counterHandler() {
    numInterstitialLoadAttempts++;
    logs(
        "counterHandle ---> $numInterstitialLoadAttempts : ${adModel.data!.intCount}");
    if (adModel.data!.intCount != 0 &&
        numInterstitialLoadAttempts == adModel.data!.intCount) {
      audioPlayer.stop();
      logs("load ad-->");
      showGoogleInterstitialAd();
    }
  }

  static void showGoogleInterstitialAd({Function? dismissFunction}) {
    if (googleInterstitialAd == null) {
      showApplovinInterstitialAd();
    } else {
      googleInterstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (InterstitialAd ad) {},
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          ad.dispose();
          createGoogleInterstitialAd();
          if (dismissFunction != null) {
            dismissFunction();
          }
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          logs('Google ad failed to show fullscreen content ---> $error');
          ad.dispose();
          showApplovinInterstitialAd();
          // createInterstitialAd();
          if (dismissFunction != null) {
            dismissFunction();
          }
        },
      );
      googleInterstitialAd!.show();
      numInterstitialLoadAttempts = 0;
      googleInterstitialAd = null;
    }
  }

  static listenApplovinBannerAds() {
    return applovin.AppLovinMAX.setBannerListener(applovin.AdViewAdListener(
      onAdLoadedCallback: (ad) {
        logs('Applovin Banner ad loaded from ---> ${ad.networkName}');
      },
      onAdLoadFailedCallback: (adUnitId, error) {
        logs(
            'Applovin Banner ad failed to load with error ---> ${error.message}');
      },
      onAdClickedCallback: (ad) {
        logs('Applovin Banner ad clicked');
      },
      onAdExpandedCallback: (ad) {
        logs('Applovin Banner ad expanded');
      },
      onAdCollapsedCallback: (ad) {
        logs('Applovin Banner ad collapsed');
      },
      onAdRevenuePaidCallback: (ad) {
        logs('Applovin Banner ad revenue paid: ${ad.revenue}');
      },
    ));
  }

  static Widget createApplovinBannerAds() {
    if (adModel.data!.maxBanner != null &&
        adModel.data!.maxBanner!.isNotEmpty &&
        adModel.data!.adsStatus) {
      logs('Create applovin banner ads');
      applovin.AppLovinMAX.createBanner(adModel.data!.maxBanner!, applovin.AdViewPosition.bottomCenter);
      return applovin.MaxAdView(
          adUnitId: adModel.data!.maxBanner ?? '',
          adFormat: applovin.AdFormat.banner,
          listener: applovin.AdViewAdListener(
            onAdLoadedCallback: (ad) {
              logs('Applovin Banner ad loaded from ---> ${ad.networkName}');
            },
            onAdLoadFailedCallback: (adUnitId, error) {
              logs(
                  'Applovin Banner ad failed to load with error ---> ${error.message}');
            },
            onAdClickedCallback: (ad) {
              logs('Applovin Banner ad clicked');
            },
            onAdExpandedCallback: (ad) {
              logs('Applovin Banner ad expanded');
            },
            onAdCollapsedCallback: (ad) {
              logs('Applovin Banner ad collapsed');
            },
            onAdRevenuePaidCallback: (ad) {
              logs('Applovin Banner ad revenue paid: ${ad.revenue}');
            },),
          isAutoRefreshEnabled: false);
    }
    return const SizedBox();
  }

  static void createApplovinInterstitialAds() {
    applovin.AppLovinMAX.setInterstitialListener(applovin.InterstitialListener(
      onAdLoadedCallback: (ad) {
        logs('Interstitial ad loaded from ${ad.networkName}');
        numInterstitialLoadAttempts = 0;
      },
      onAdLoadFailedCallback: (adUnitId, error) {
        numInterstitialLoadAttempts = numInterstitialLoadAttempts + 1;
        int retryDelay = pow(2, min(6, numInterstitialLoadAttempts)).toInt();

        logs(
            'Applovin Interstitial ad failed to load with code ${error.code} - retrying in ${retryDelay}s');

        Future.delayed(Duration(milliseconds: retryDelay * 1000), () {
          applovin.AppLovinMAX.loadInterstitial(adModel.data!.maxInt ?? '');
        });
      },
      onAdDisplayedCallback: (ad) {
        logs("onAdDisplayedCallback --->");
      },
      onAdDisplayFailedCallback: (ad, error) {
        numInterstitialLoadAttempts = 0;
        logs('onAdDisplayFailedCallback ---> ${error.message}');
        audioPlayer.play();
      },
      onAdClickedCallback: (ad) {
        logs("onAdClickedCallback --->");
      },
      onAdHiddenCallback: (ad) {
        logs("onAdHiddenCallback --->");
        numInterstitialLoadAttempts = 0;
        createApplovinInterstitialAds();
        audioPlayer.play();
      },
    ));

    // Load the first interstitial
    applovin.AppLovinMAX.loadInterstitial(adModel.data!.maxInt ?? '');
  }

  static Future<void> showApplovinInterstitialAd() async {
    audioPlayer.stop();
    logs('adModel.data!.maxInt ---> ${adModel.data!.maxInt}');
    bool isReady =
        (await applovin.AppLovinMAX.isInterstitialReady(adModel.data!.maxInt ?? ''))!;
    logs('isReady --> $isReady');
    if (isReady) {
      applovin.AppLovinMAX.showInterstitial(adModel.data!.maxInt!);
    } else {
      numInterstitialLoadAttempts = 0;
      audioPlayer.play();
    }
  }
}

class AppOpenAdManager {
  AppOpenAd? _appOpenAd;
  bool _isShowingAd = false;

  /// Load an AppOpenAd.
  void loadAd() {
    AppOpenAd.load(
      adUnitId: adModel.data!.gAppOpen ?? '',
      orientation: AppOpenAd.orientationPortrait,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          showAdIfAvailable();
        },
        onAdFailedToLoad: (error) {
          logs('Google AppOpen ad failed to load with error ---> $error');
          showApplovinAppOpenAd();
        },
      ),
    );
  }

  bool get isAdAvailable {
    return _appOpenAd != null;
  }

  void showAdIfAvailable() {
    if (_appOpenAd == null) {
      loadAd();
      return;
    }
    if (_isShowingAd) {
      return;
    }

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        audioPlayer.stop();
        _isShowingAd = true;
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isShowingAd = false;
        audioPlayer.play();
        ad.dispose();
        logs('Google AppOpen ad failed to show fullscreen content ---> $error');
        _appOpenAd = null;
        showApplovinAppOpenAd();
      },
      onAdDismissedFullScreenContent: (ad) {
        Get.back();
        audioPlayer.play();
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
      },
    );
    _appOpenAd!.show();
  }

  void initializeApplovinAppOpenAds() {
    if (adModel.data!.appOpen != null &&
        adModel.data!.appOpen!.isNotEmpty &&
        adModel.data!.adsStatus) {
      applovin.AppLovinMAX.setAppOpenAdListener(applovin.AppOpenAdListener(
        onAdLoadedCallback: (ad) {},
        onAdLoadFailedCallback: (adUnitId, error) {},
        onAdDisplayedCallback: (ad) {},
        onAdDisplayFailedCallback: (ad, error) {
          logs('Applovin AppOpen ad failed to display ---> $error');
          applovin.AppLovinMAX.loadAppOpenAd(adModel.data!.appOpen ?? '');
        },
        onAdClickedCallback: (ad) {},
        onAdHiddenCallback: (ad) {
          logs("On hide ----> ");
          applovin.AppLovinMAX.loadAppOpenAd(adModel.data!.appOpen ?? '');
        },
        onAdRevenuePaidCallback: (ad) {},
      ));
      logs("APPOPEN --->");
      applovin.AppLovinMAX.loadAppOpenAd(adModel.data!.appOpen ?? '');
    }
  }

  Future<void> showApplovinAppOpenAd() async {
    bool isReady =
        (await applovin.AppLovinMAX.isAppOpenAdReady(adModel.data!.appOpen!))!;
    logs("isReady --> $isReady");
    if (isReady) {
      applovin.AppLovinMAX.showAppOpenAd(adModel.data!.appOpen!);
      audioPlayer.stop();
    } else {
      applovin.AppLovinMAX.loadAppOpenAd(adModel.data!.appOpen!);
      audioPlayer.play();
    }
  }
}
