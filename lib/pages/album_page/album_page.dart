import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/components/app_text.dart';
import 'package:music_player/components/search_list_tile.dart';
import 'package:music_player/constants/color_constant.dart';
import 'package:music_player/constants/string_constant.dart';
import 'package:music_player/controller/home_controller.dart';
import 'package:music_player/model/my_song_model.dart';
import 'package:music_player/pages/home_page/home_page.dart';
import 'package:music_player/routes/route_constant.dart';
import 'package:music_player/service/ad_service.dart';
import 'package:music_player/utils/all_logs.dart';

class AlbumPage extends StatefulWidget {
  const AlbumPage({super.key});

  @override
  State<AlbumPage> createState() => _AlbumPageState();
}

class _AlbumPageState extends State<AlbumPage> {
  List<String> albumKeyList = [];
  Map<String, List<MySongModel>> albumList = {};
  String tmpPath = '';
  bool isDrawer = false;

  @override
  void initState() {
    HomeController homeController = Get.put(HomeController());
    albumKeyList = homeController.albumsKeyList;
    albumList = homeController.albums;
    tmpPath = homeController.tmpPath ?? '';
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
      body: (albumList.isEmpty && albumKeyList.isEmpty)
          ? const Center(
              child: AppText(title: AppStringConstant.noAlbumFound),
            )
          : ListView.separated(
              itemCount: albumList.length,
        separatorBuilder: (context, index) {
          if (adModel.data != null &&
              adModel.data!.bannerCount != 0 &&
              index % adModel.data!.bannerCount == 0 && adModel.data!.scrollAd) {
            return AdService.createGoogleBannerAd();
          }
          return const SizedBox();
        },
        itemBuilder: (context, index) {
          return SearchListTile(
            id: albumList[albumKeyList[index]]![0].id!,
            title: albumKeyList[index],
            fileName: albumList[albumKeyList[index]]![0].displayNameWOExt!,
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
