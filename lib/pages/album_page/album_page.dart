import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/components/app_text.dart';
import 'package:music_player/components/banner_ad_widget.dart';
import 'package:music_player/components/music_list_tile.dart';
import 'package:music_player/constants/color_constant.dart';
import 'package:music_player/constants/string_constant.dart';
import 'package:music_player/controller/home_controller.dart';
import 'package:music_player/pages/home_page/home_page.dart';
import 'package:music_player/routes/route_constant.dart';
import 'package:music_player/utils/all_logs.dart';
import 'package:on_audio_query/on_audio_query.dart';

class AlbumPage extends StatefulWidget {
  const AlbumPage({super.key});

  @override
  State<AlbumPage> createState() => _AlbumPageState();
}

class _AlbumPageState extends State<AlbumPage> {
  List<String> albumKeyList = [];
  Map<String, List<SongModel>> albumList = {};
  String tmpPath = '';
  bool isDrawer = false;

  @override
  void initState() {
    HomeController homeController = Get.put(HomeController());
    albumKeyList = homeController.albumsKeyList;
    albumList = homeController.albums;
    tmpPath = homeController.tmpPath!;
    var args = Get.arguments;
    if (args != null) {
      isDrawer = args['isDrawer'];
    }
    logs('isDrawer ----> $isDrawer');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: isDrawer
            ? BackButton(
                onPressed: () => Get.back(), color: ColorConstant.white)
            : const SizedBox(),
        title: const AppText(
          title: AppStringConstant.album,
          fontColor: ColorConstant.white,
        ),
      ),
      body: ListView.separated(
        itemCount: albumList.length,
        separatorBuilder: (context, index) {
          if (bannerAdDividerCount != 0 && index % bannerAdDividerCount == 0) {
            return const AppBannerAdView();
          }
          return const SizedBox();
        },
        itemBuilder: (context, index) {
          return AlbumTile(
            id: albumList[albumKeyList[index]]![0].id,
            title: albumKeyList[index],
            fileName: albumList[albumKeyList[index]]![0].displayNameWOExt,
            subTitle:
                '${albumList[albumKeyList[index]]!.length} ${AppStringConstant.songs}',
            tempPath: tmpPath,
            onTap: () => Get.toNamed(RouteConstant.musicRoute, arguments: {
              'songList': albumList[albumKeyList[index]],
              'title': albumKeyList[index]
            }),
          );
        },
      ),
    );
  }
}
