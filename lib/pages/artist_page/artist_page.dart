import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:music_player/components/app_text.dart';
import 'package:music_player/components/search_list_tile.dart';
import 'package:music_player/constants/color_constant.dart';
import 'package:music_player/constants/string_constant.dart';
import 'package:music_player/controller/home_controller.dart';
import 'package:music_player/model/my_song_model.dart';
import 'package:music_player/pages/home_page/home_page.dart';
import 'package:music_player/routes/route_constant.dart';
import 'package:music_player/service/ad_service.dart';

class ArtistPage extends StatefulWidget {
  const ArtistPage({super.key});

  @override
  State<ArtistPage> createState() => _ArtistPageState();
}

class _ArtistPageState extends State<ArtistPage> {
  List<String> artistKeyList = [];
  Map<String, List<MySongModel>> artistList = {};
  String tmpPath = '';
  bool isDrawer = false;

  @override
  void initState() {
    HomeController homeController = Get.put(HomeController());
    artistKeyList = homeController.artisKeyList;
    artistList = homeController.artists;
    tmpPath = homeController.tmpPath ?? '';
    var args = Get.arguments;
    if (args != null) {
      isDrawer = args['isDrawer'];
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: isDrawer
            ? BackButton(
                onPressed: () => Get.back(), color: ColorConstant.white)
            : const SizedBox(),
        centerTitle: true,
        title: const AppText(
          title: AppStringConstant.artist,
          fontColor: ColorConstant.white,
        ),
      ),
      body: (artistKeyList.isEmpty && artistList.isEmpty)
          ? const Center(child: AppText(title: AppStringConstant.noArtistFound))
          : ListView.separated(
              separatorBuilder: (context, index) {
                if (adModel.data != null &&
                    adModel.data!.bannerCount != 0 &&
                    index % adModel.data!.bannerCount == 0 &&
                    adModel.data!.scrollAd) {
                  return AdService.createGoogleBannerAd();
                }
                return const SizedBox();
              },
              itemCount: artistList.length,
              itemBuilder: (context, index) {
                return SearchListTile(
                  id: artistList[artistKeyList[index]]![0].id!,
                  title: artistKeyList[index],
                  fileName:
                      artistList[artistKeyList[index]]![0].displayNameWOExt!,
                  subTitle:
                      '${artistList[artistKeyList[index]]!.length} ${AppStringConstant.songs}',
                  tempPath: tmpPath,
                  onTap: () => Get.toNamed(RouteConstant.musicRoute,
                      arguments: {
                        'songList': artistList[artistKeyList[index]],
                        'title': artistKeyList[index]
                      }),
                );
              },
            ),
    );
  }
}
