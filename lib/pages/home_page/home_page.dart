import 'dart:math';
import 'package:applovin_max/applovin_max.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/components/app_image_assets.dart';
import 'package:music_player/components/app_loader.dart';
import 'package:music_player/components/app_text.dart';
import 'package:music_player/components/audio_player.dart';
import 'package:music_player/constants/asset_constant.dart';
import 'package:music_player/constants/color_constant.dart';
import 'package:music_player/constants/string_constant.dart';
import 'package:music_player/controller/home_controller.dart';
import 'package:music_player/controller/music_page_controller.dart';
import 'package:music_player/controller/player_controller.dart';
import 'package:music_player/pages/artist_page/artist_page.dart';
import 'package:music_player/pages/music_page/music_page.dart';
import 'package:music_player/pages/album_page/album_page.dart';
import 'package:music_player/pages/playlist_page/playlist_page.dart';
import 'package:music_player/routes/route_constant.dart';
import 'package:music_player/utils/all_logs.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

String bannerUnitId = '';
String interstitialUnitId = '';
String appOpenAdId = '';
int adIntersTitiaCount = 0;
int showAdOnCount = 0;
int interstitialRetryAttempt = 0;
int bannerAdDividerCount = 0;
bool isAppOpenAdInitialized = false;
bool isShowAds = false;

void initializeInterstitialAds() {
  AppLovinMAX.setInterstitialListener(InterstitialListener(
    onAdLoadedCallback: (ad) {
      logs('Interstitial ad loaded from ${ad.networkName}');
      interstitialRetryAttempt = 0;
    },
    onAdLoadFailedCallback: (adUnitId, error) {
      interstitialRetryAttempt = interstitialRetryAttempt + 1;
      int retryDelay = pow(2, min(6, interstitialRetryAttempt)).toInt();

      logs(
          'Interstitial ad failed to load with code ${error.code} - retrying in ${retryDelay}s');

      Future.delayed(Duration(milliseconds: retryDelay * 1000), () {
        AppLovinMAX.loadInterstitial(interstitialUnitId);
      });
    },
    onAdDisplayedCallback: (ad) {
      logs("onAdDisplayedCallback --->");
    },
    onAdDisplayFailedCallback: (ad, error) {
      logs('onAdDisplayFailedCallback ---> ${error.message}');
    },
    onAdClickedCallback: (ad) {
      logs("onAdClickedCallback --->");
    },
    onAdHiddenCallback: (ad) {
      logs("onAdHiddenCallback --->");
      adIntersTitiaCount = 0;
      initializeInterstitialAds();
      audioPlayer.seekToNext();
      audioPlayer.play();
    },
  ));

  // Load the first interstitial
  AppLovinMAX.loadInterstitial(interstitialUnitId);
}

void initializeBannerAds() {
  if (bannerUnitId.isNotEmpty && isShowAds) {
    AppLovinMAX.createBanner(bannerUnitId, AdViewPosition.bottomCenter);
  }
}

void initializeAppOpenAds() {
  if (appOpenAdId.isNotEmpty && isShowAds) {
    AppLovinMAX.setAppOpenAdListener(AppOpenAdListener(
      onAdLoadedCallback: (ad) {},
      onAdLoadFailedCallback: (adUnitId, error) {},
      onAdDisplayedCallback: (ad) {},
      onAdDisplayFailedCallback: (ad, error) {
        AppLovinMAX.loadAppOpenAd(appOpenAdId);
      },
      onAdClickedCallback: (ad) {},
      onAdHiddenCallback: (ad) {
        logs("On hide ----> ");
        AppLovinMAX.loadAppOpenAd(appOpenAdId);
      },
      onAdRevenuePaidCallback: (ad) {},
    ));
    logs("APPOPEN --->");
    AppLovinMAX.loadAppOpenAd(appOpenAdId);
  }
}

Future<void> showInterstitialAd() async {
  if (isShowAds &&
      interstitialUnitId.isNotEmpty &&
      showAdOnCount != 0 &&
      adIntersTitiaCount == showAdOnCount) {
    audioPlayer.stop();
    bool isReady = (await AppLovinMAX.isInterstitialReady(interstitialUnitId))!;
    if (isReady) {
      AppLovinMAX.showInterstitial(interstitialUnitId);
    }
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    logs("state ---> $state");
    switch (state) {
      case AppLifecycleState.resumed:
        await showAdIfReady();
        break;

      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        break;
    }
  }

  Future<void> showAdIfReady() async {
    if (isShowAds && appOpenAdId.isNotEmpty) {
      if (isAppOpenAdInitialized) {
        return;
      }

      bool isReady = (await AppLovinMAX.isAppOpenAdReady(appOpenAdId))!;
      logs("isReady --> $isReady");
      if (isReady) {
        AppLovinMAX.showAppOpenAd(appOpenAdId);
        audioPlayer.stop();
      } else {
        AppLovinMAX.loadAppOpenAd(appOpenAdId);
        audioPlayer.play();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      init: HomeController(),
      initState: (state) async {
        WidgetsBinding.instance.addObserver(this);
        audioPlayer.positionStream.listen((event) async {
          if (event == audioPlayer.duration) {
            adIntersTitiaCount++;
            showInterstitialAd();
          }
        });
        Future.delayed(
          const Duration(milliseconds: 150),
          () {
            HomeController homeController = Get.find<HomeController>();
            homeController.loadAds();
          },
        );
      },
      builder: (HomeController controller) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          drawer: appDrawer(context, controller),
          body: SafeArea(
            child: Stack(
              children: [
                PageView(
                  physics: const CustomPhysics(),
                  onPageChanged: (index) {
                    controller.selectedIndex.value = index;
                  },
                  controller: controller.pageController,
                  children: [
                    Stack(
                      children: [
                        NestedScrollView(
                          physics: const BouncingScrollPhysics(),
                          controller: controller.scrollController,
                          headerSliverBuilder: (
                            BuildContext context,
                            bool innerBoxScrolled,
                          ) {
                            return <Widget>[
                              SliverAppBar(
                                expandedHeight: 135.px,
                                backgroundColor: Colors.transparent,
                                elevation: 0,
                                toolbarHeight: 65.px,
                                automaticallyImplyLeading: false,
                                flexibleSpace: LayoutBuilder(
                                  builder: (context, constraints) {
                                    return FlexibleSpaceBar(
                                      collapseMode: CollapseMode.parallax,
                                      background: GestureDetector(
                                        onTap: () async {
                                          await showTextInputDialog(
                                            context: context,
                                            title: AppStringConstant.name,
                                            initialText: controller.name.value,
                                            keyboardType: TextInputType.name,
                                            onSubmitted: (value) {
                                              controller.name.value =
                                                  value.trim();
                                              Get.back();
                                            },
                                          );
                                        },
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            SizedBox(height: 45.px),
                                            Row(
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 15.px),
                                                  child: AppText(
                                                    title: AppStringConstant
                                                        .hiThere,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 30.px,
                                                    fontColor: Theme.of(context)
                                                        .colorScheme
                                                        .secondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                left: 15.0.px,
                                              ),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Obx(() => AppText(
                                                      title:
                                                          controller.name.value,
                                                      fontSize: 20.px,
                                                      fontWeight:
                                                          FontWeight.w500))
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              SliverAppBar(
                                automaticallyImplyLeading: false,
                                pinned: true,
                                backgroundColor: Colors.transparent,
                                elevation: 0,
                                stretch: true,
                                toolbarHeight: 65.px,
                                bottom: PreferredSize(
                                    preferredSize: Size.fromHeight(40.px),
                                    child: shuffleView(controller)),
                                title: Align(
                                  alignment: Alignment.centerRight,
                                  child: AnimatedBuilder(
                                    animation: controller.scrollController,
                                    builder: (context, child) {
                                      return Column(
                                        children: [
                                          GestureDetector(
                                            child: AnimatedContainer(
                                              width: (!controller
                                                          .scrollController
                                                          .hasClients ||
                                                      controller
                                                              .scrollController
                                                              // ignore: invalid_use_of_protected_member
                                                              .positions
                                                              .length >
                                                          1)
                                                  ? MediaQuery.of(context)
                                                      .size
                                                      .width
                                                  : max(
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width -
                                                          controller
                                                              .scrollController
                                                              .offset
                                                              .roundToDouble(),
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width -
                                                          75.px,
                                                    ),
                                              height: 50.px,
                                              duration: const Duration(
                                                milliseconds: 150,
                                              ),
                                              padding: EdgeInsets.all(2.0.px),
                                              // margin: EdgeInsets.zero,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  10.0.px,
                                                ),
                                                color: ColorConstant.grey900,
                                                boxShadow: const [
                                                  BoxShadow(
                                                    color:
                                                        ColorConstant.black26,
                                                    blurRadius: 5.0,
                                                    offset: Offset(1.5, 1.5),
                                                    // shadow direction: bottom right
                                                  )
                                                ],
                                              ),
                                              child: Row(
                                                children: [
                                                  SizedBox(
                                                    width: 10.0.px,
                                                  ),
                                                  Icon(
                                                    CupertinoIcons.search,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .secondary,
                                                  ),
                                                  SizedBox(
                                                    width: 10.0.px,
                                                  ),
                                                  AppText(
                                                      title: AppStringConstant
                                                          .songsAlbumsArtis,
                                                      fontSize: 16.px,
                                                      fontWeight:
                                                          FontWeight.normal),
                                                ],
                                              ),
                                            ),
                                            onTap: () => Get.toNamed(
                                                RouteConstant.searchRoute),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ];
                          },
                          body: (controller.isLoading)
                              ? const AppLoader()
                              : (controller.songs.isEmpty)
                                  ? const Center(
                                      child: AppText(
                                          title: AppStringConstant.noSong),
                                    )
                                  : const MusicPage(),
                        ),
                        Builder(
                          builder: (context) => Padding(
                            padding: const EdgeInsets.only(
                              top: 8.0,
                              left: 4.0,
                            ),
                            child: Transform.rotate(
                              angle: 22 / 7 * 2,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.horizontal_split_rounded,
                                ),
                                color: Theme.of(context).iconTheme.color,
                                onPressed: () =>
                                    Scaffold.of(context).openDrawer(),
                                tooltip: MaterialLocalizations.of(context)
                                    .openAppDrawerTooltip,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const AlbumPage(),
                    const ArtistPage(),
                    const PlaylistPage(),
                  ],
                ),
                const Positioned(
                    bottom: -1, left: 0, right: 0, child: MiniPlayer()),
              ],
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: ValueListenableBuilder(
              valueListenable: controller.selectedIndex,
              builder: (BuildContext context, int indexValue, Widget? child) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  height: 60.px,
                  child: SalomonBottomBar(
                    currentIndex: indexValue,
                    onTap: (index) => controller.onItemTapped(index),
                    items: [
                      SalomonBottomBarItem(
                        icon: const Icon(Icons.music_note),
                        title: AppText(
                            title: AppStringConstant.songs,
                            fontColor: Theme.of(context).colorScheme.secondary),
                        selectedColor: Theme.of(context).colorScheme.secondary,
                      ),
                      SalomonBottomBarItem(
                        icon: const Icon(Icons.album),
                        title: AppText(
                            title: AppStringConstant.album,
                            fontColor: Theme.of(context).colorScheme.secondary),
                        selectedColor: Theme.of(context).colorScheme.secondary,
                      ),
                      SalomonBottomBarItem(
                        icon: AppImageAsset(
                          image: AssetConstant.icArtist,
                          fit: BoxFit.cover,
                          height: 20.px,
                          width: 20.px,
                          color: (indexValue == 2)
                              ? Theme.of(context).colorScheme.secondary
                              : ColorConstant.white,
                        ),
                        title: AppText(
                            title: AppStringConstant.artist,
                            fontColor: Theme.of(context).colorScheme.secondary),
                        selectedColor: Theme.of(context).colorScheme.secondary,
                      ),
                      SalomonBottomBarItem(
                        icon: const Icon(Icons.my_library_music_rounded),
                        title: AppText(
                            title: AppStringConstant.playlist,
                            fontColor: Theme.of(context).colorScheme.secondary),
                        selectedColor: Theme.of(context).colorScheme.secondary,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void loadAds() {
    AppLovinMAX.setBannerListener(AdViewAdListener(
      onAdLoadedCallback: (ad) {
        logs('Banner ad loaded from ${ad.networkName}');
      },
      onAdLoadFailedCallback: (adUnitId, error) {
        logs(
            'Banner ad failed to load with error code ${error.code} and message: ${error.message}');
      },
      onAdClickedCallback: (ad) {
        logs('Banner ad clicked');
      },
      onAdExpandedCallback: (ad) {
        logs('Banner ad expanded');
      },
      onAdCollapsedCallback: (ad) {
        logs('Banner ad collapsed');
      },
      onAdRevenuePaidCallback: (ad) {
        logs('Banner ad revenue paid: ${ad.revenue}');
      },
    ));
    initializeInterstitialAds();
  }

  void loadBannerAds() {}

  Widget shuffleView(HomeController homeController) {
    return Container(
      height: 50.px,
      color: ColorConstant.black,
      alignment: Alignment.center,
      padding: EdgeInsets.only(left: 20.0.px, right: 10.0.px),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(
              title:
                  '${homeController.songs.length} ${AppStringConstant.songs}',
              fontWeight: FontWeight.w600),
          const Spacer(),
          TextButton.icon(
            onPressed: () {
              AudioPlayerController controller =
                  Get.put(AudioPlayerController());
              controller.initializeValue(
                  tmpPath: homeController.tmpPath!,
                  songList: homeController.songs,
                  index: 0,
                  isShuffleEnable: true);
            },
            icon: const Icon(Icons.shuffle_rounded),
            label: const AppText(
                title: AppStringConstant.shuffle, fontWeight: FontWeight.w600),
          ),
          IconButton(
            onPressed: () {
              AudioPlayerController controller =
                  Get.put(AudioPlayerController());
              MusicPageController musicPlayerController =
                  Get.put(MusicPageController());

              controller.initializeValue(
                  tmpPath: homeController.tmpPath!,
                  songList: musicPlayerController.songList,
                  index: 0,
                  isShuffleEnable: false);
            },
            tooltip: AppStringConstant.play,
            icon: const Icon(Icons.play_arrow_rounded,
                color: ColorConstant.white),
            iconSize: 30.0.px,
          ),
          PopupMenuButton(
              itemBuilder: (context) {
                final List<String> sortTypes = [
                  AppStringConstant.displayName,
                  AppStringConstant.dateAdded,
                  AppStringConstant.album,
                  AppStringConstant.artist,
                  AppStringConstant.duration,
                  AppStringConstant.size,
                ];
                final List<String> orderTypes = [
                  AppStringConstant.increasing,
                  AppStringConstant.decreasing,
                ];
                final menuList = <PopupMenuEntry<int>>[];
                menuList.addAll(
                  sortTypes
                      .map(
                        (e) => PopupMenuItem(
                          value: sortTypes.indexOf(e),
                          child: Row(
                            children: [
                              if (homeController.selectedSortValue ==
                                  sortTypes.indexOf(e))
                                Icon(
                                  Icons.check_rounded,
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? ColorConstant.white
                                      : ColorConstant.grey700,
                                )
                              else
                                const SizedBox(),
                              SizedBox(width: 10.px),
                              AppText(title: e),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                );
                menuList.add(
                  PopupMenuDivider(
                    height: 10.px,
                  ),
                );
                menuList.addAll(
                  orderTypes
                      .map(
                        (e) => PopupMenuItem(
                          value: sortTypes.length + orderTypes.indexOf(e),
                          child: Row(
                            children: [
                              if (homeController.selectedOrderTypeValue ==
                                  orderTypes.indexOf(e))
                                Icon(
                                  Icons.check_rounded,
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? ColorConstant.white
                                      : ColorConstant.grey700,
                                )
                              else
                                const SizedBox(),
                              SizedBox(width: 10.px),
                              AppText(
                                title: e,
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                );
                return menuList;
              },
              onSelected: (value) async {
                if (value < 6) {
                  homeController.selectedSortValue = value;
                } else {
                  homeController.selectedOrderTypeValue = value - 6;
                  logs(
                      "homeController.selectedOrderTypeValue ---------> ${homeController.selectedOrderTypeValue}");
                }
                MusicPageController musicPageController =
                    Get.put(MusicPageController());
                await musicPageController.sortSongs(
                    homeController.selectedSortValue,
                    homeController.selectedOrderTypeValue);
              },
              icon: const Icon(Icons.sort_rounded),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15.px)),
              ))
        ],
      ),
    );
  }

  Widget appDrawer(BuildContext context, HomeController controller) {
    return Drawer(
      backgroundColor: ColorConstant.black,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: false,
            elevation: 0,
            stretch: true,
            expandedHeight: MediaQuery.of(context).size.height * 0.2,
            flexibleSpace: FlexibleSpaceBar(
              title: const AppText(title: 'Music player'),
              titlePadding: const EdgeInsets.only(bottom: 40.0),
              centerTitle: true,
              background: ShaderMask(
                shaderCallback: (rect) {
                  return LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.black.withOpacity(0.1),
                    ],
                  ).createShader(
                    Rect.fromLTRB(0, 0, rect.width, rect.height),
                  );
                },
                blendMode: BlendMode.dstIn,
                child: Image(
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  image: AssetImage(
                    Theme.of(context).brightness == Brightness.dark
                        ? AssetConstant.drawerImageDark
                        : AssetConstant.drawerImageLight,
                  ),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                ListTile(
                  title: AppText(
                    title: AppStringConstant.home,
                    fontColor: Theme.of(context).colorScheme.secondary,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
                  leading: Icon(
                    Icons.home_rounded,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  selected: true,
                  onTap: () => Get.back(),
                ),
                ListTile(
                  title: const AppText(
                    title: AppStringConstant.album,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
                  leading: const Icon(
                    Icons.album,
                  ),
                  selected: true,
                  onTap: () {
                    Get.back();
                    Get.toNamed(RouteConstant.albumRoute,
                        arguments: {'isDrawer': true});
                  },
                ),
                ListTile(
                  title: const AppText(
                    title: AppStringConstant.artist,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
                  leading: AppImageAsset(
                    image: AssetConstant.icArtist,
                    fit: BoxFit.cover,
                    height: 20.px,
                    width: 20.px,
                    color: ColorConstant.white,
                  ),
                  selected: true,
                  onTap: () {
                    Get.back();
                    Get.toNamed(RouteConstant.artistRoute,
                        arguments: {'isDrawer': true});
                  },
                ),
                ListTile(
                  title: const AppText(
                    title: AppStringConstant.playlist,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
                  leading: const Icon(Icons.my_library_music_rounded),
                  selected: true,
                  onTap: () {
                    Get.back();
                    Get.toNamed(RouteConstant.playListRoute,
                        arguments: {'isDrawer': true});
                  },
                ),
                ListTile(
                  title: const AppText(
                    title: AppStringConstant.about,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
                  leading: const Icon(
                    Icons.info,
                  ),
                  selected: true,
                  onTap: () {
                    Get.back();
                    Get.toNamed(RouteConstant.aboutRoute);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CustomPhysics extends ScrollPhysics {
  const CustomPhysics({super.parent});

  @override
  CustomPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomPhysics(parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 150,
        stiffness: 100,
        damping: 1,
      );
}

Future<void> showTextInputDialog({
  required BuildContext context,
  required String title,
  String? initialText,
  required TextInputType keyboardType,
  required Function(String) onSubmitted,
}) async {
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      final controller = TextEditingController(text: initialText);
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
            TextField(
              autofocus: true,
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
              controller: controller,
              keyboardType: keyboardType,
              textAlignVertical: TextAlignVertical.bottom,
              onSubmitted: (value) {
                onSubmitted(value);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: ColorConstant.white,
            ),
            onPressed: () => Get.back(),
            child: const AppText(title: AppStringConstant.cancel),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: ColorConstant.white,
              backgroundColor: Theme.of(context).colorScheme.secondary,
            ),
            onPressed: () {
              onSubmitted(controller.text.trim());
            },
            child: const Text(
              AppStringConstant.ok,
            ),
          ),
          SizedBox(
            width: 5.px,
          ),
        ],
      );
    },
  );
}
