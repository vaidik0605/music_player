import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/components/app_image_assets.dart';
import 'package:music_player/components/app_loader.dart';
import 'package:music_player/components/app_text.dart';
import 'package:music_player/components/app_toast.dart';
import 'package:music_player/constants/asset_constant.dart';
import 'package:music_player/constants/color_constant.dart';
import 'package:music_player/constants/string_constant.dart';
import 'package:music_player/controller/playlist_controller.dart';
import 'package:music_player/pages/home_page/home_page.dart';
import 'package:music_player/routes/route_constant.dart';
import 'package:music_player/service/ad_service.dart';
import 'package:on_audio_query/on_audio_query.dart';

import 'package:responsive_sizer/responsive_sizer.dart';

class PlaylistPage extends StatelessWidget {
  const PlaylistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PlaylistController>(
      init: PlaylistController(),
      initState: (state) {
        Future.delayed(
          const Duration(milliseconds: 150),
          () {
            PlaylistController controller = Get.find<PlaylistController>();
            var args = Get.arguments;
            if (args != null) {
              controller.isDrawer = args['isDrawer'];
            }
          },
        );
      },
      builder: (PlaylistController controller) {
        return Scaffold(
          appBar: AppBar(
            leading: controller.isDrawer
                ? BackButton(
                    onPressed: () => Get.back(), color: ColorConstant.white)
                : const SizedBox(),
            backgroundColor: Colors.transparent,
            centerTitle: true,
            title: const AppText(
              title: AppStringConstant.playlist,
              fontColor: ColorConstant.white,
            ),
          ),
          body: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title:
                        const AppText(title: AppStringConstant.createPlaylist),
                    leading: Card(
                      elevation: 0,
                      color: Colors.transparent,
                      child: SizedBox.square(
                        dimension: 50.px,
                        child: Center(
                          child: Icon(
                            Icons.add_rounded,
                            color: Theme.of(context).iconTheme.color,
                          ),
                        ),
                      ),
                    ),
                    onTap: () async {
                      await showTextInputDialog(
                        context: context,
                        title: AppStringConstant.createNewPlaylist,
                        initialText: '',
                        keyboardType: TextInputType.name,
                        onSubmitted: (String value) async {
                          if (value.trim() != '') {
                            Get.back();
                            await controller.offlineAudioQuery
                                .createPlaylist(name: value);
                            controller.update();
                          }
                        },
                      );
                    },
                  ),
                  playlistView(controller),
                ],
              ),
              if (controller.isLoading) const AppLoader(),
            ],
          ),
        );
      },
    );
  }

  Widget playlistView(PlaylistController controller) {
    return Expanded(
      child: FutureBuilder<List<PlaylistModel>>(
        future: controller.offlineAudioQuery.getPlaylists(),
        builder: (context, AsyncSnapshot<List<PlaylistModel>> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData &&
                snapshot.data != null &&
                snapshot.data!.isNotEmpty) {
              return ListView.separated(
                separatorBuilder: (context, index) {
                  if (adModel.data != null &&
                      adModel.data!.bannerCount != 0 &&
                      index % adModel.data!.bannerCount == 0 &&
                      adModel.data!.scrollAd) {
                    return AdService.createGoogleBannerAd();
                  }
                  return const SizedBox();
                },
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: () async {
                      Get.toNamed(RouteConstant.playlistSongRoute, arguments: {
                        'title': snapshot.data![index].playlist,
                        'playListId': snapshot.data![index].id,
                      });
                    },
                    leading: Card(
                      elevation: 5,
                      color: ColorConstant.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7.0.px),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: QueryArtworkWidget(
                        id: snapshot.data![index].id,
                        type: ArtworkType.PLAYLIST,
                        keepOldArtwork: true,
                        artworkBorder: BorderRadius.circular(7.0.px),
                        nullArtworkWidget: ClipRRect(
                          borderRadius: BorderRadius.circular(7.0.px),
                          child: AppImageAsset(
                            fit: BoxFit.cover,
                            height: 50.0.px,
                            width: 50.0.px,
                            image: AssetConstant.coverImage,
                          ),
                        ),
                      ),
                    ),
                    title: AppText(
                      title: snapshot.data![index].playlist,
                    ),
                    subtitle: AppText(
                      title: '${snapshot.data![index].numOfSongs} Songs',
                    ),
                    trailing: PopupMenuButton(
                      icon: const Icon(Icons.more_vert_rounded,
                          color: ColorConstant.white),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(15.px),
                        ),
                      ),
                      onSelected: (value) async {
                        if (value == 0) {
                          bool isSuccess = await controller.offlineAudioQuery.removePlaylist(
                              playlistId: snapshot.data![index].id);
                          if (isSuccess) {
                            '${AppStringConstant.deleted} ${snapshot.data![index].playlist}'
                                .showToast();
                            controller.update();
                          }
                        }
                      },
                      itemBuilder: (context) {
                        return [
                          PopupMenuItem(
                            value: 0,
                            child: Row(
                              children: [
                                const Icon(Icons.delete_rounded,
                                    color: ColorConstant.white),
                                SizedBox(width: 10.0.px),
                                const AppText(
                                  title: AppStringConstant.delete,
                                ),
                              ],
                            ),
                          ),
                        ];
                      },
                    ),
                  );
                },
              );
            }
            return const Center(
                child: AppText(title: AppStringConstant.noPlaylistFound));
          }
          return const AppLoader();
        },
      ),
    );
  }
}
