import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/components/app_loader.dart';
import 'package:music_player/components/app_text.dart';
import 'package:music_player/components/app_toast.dart';
import 'package:music_player/constants/color_constant.dart';
import 'package:music_player/constants/string_constant.dart';
import 'package:music_player/controller/playlist_controller.dart';
import 'package:music_player/helper/audio_query_helper.dart';
import 'package:music_player/model/my_play_list_model.dart';
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
            controller.update();
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
                            MyPlaylistModel playlistModel = MyPlaylistModel(
                                playlistName: value,
                                playlistId:
                                    '$value-${DateTime.now().microsecondsSinceEpoch}');
                            await controller.dbHelper
                                .createPlayList(playlistModel: playlistModel);
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
      child: FutureBuilder<List<MyPlaylistModel>>(
        future: controller.dbHelper.getPlayList(),
        builder: (context, AsyncSnapshot<List<MyPlaylistModel>> snapshot) {
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
                        'title': snapshot.data![index].playlistName!,
                        'playListId': snapshot.data![index].playlistId!,
                      });
                    },
                    leading: OfflineAudioQuery.offlineArtworkWidget(
                        id: snapshot.data![index].songs.isNotEmpty
                            ? snapshot.data![index].songs.first.id!
                            : 0,
                        type: ArtworkType.AUDIO,
                        tempPath: (snapshot.data![index].tmpPath.isNotEmpty) ? snapshot.data![index].tmpPath :'',
                        fileName: snapshot.data![index].songs.isNotEmpty
                            ? snapshot.data!.first.songs.first.displayNameWOExt!
                            : ''),
                    title: AppText(
                      title: snapshot.data![index].playlistName!,
                    ),
                    subtitle: AppText(
                      title: '${snapshot.data![index].songs.length} Songs',
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
                          await controller.dbHelper.deletePlayList(
                              playListId: snapshot.data![index].playlistId!);

                          '${AppStringConstant.deleted} ${snapshot.data![index].playlistName}'
                              .showToast();
                          controller.update();
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
