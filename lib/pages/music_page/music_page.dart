import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/components/add_playlist.dart';
import 'package:music_player/components/app_text.dart';
import 'package:music_player/constants/color_constant.dart';
import 'package:music_player/constants/string_constant.dart';
import 'package:music_player/controller/music_page_controller.dart';
import 'package:music_player/controller/player_controller.dart';
import 'package:music_player/helper/audio_query_helper.dart';
import 'package:music_player/pages/home_page/home_page.dart';
import 'package:music_player/service/ad_service.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class MusicPage extends StatelessWidget {
  const MusicPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MusicPageController>(
      init: MusicPageController(),
      builder: (controller) {
        return Scaffold(
            appBar: (controller.getArg != null && controller.getArg!.isNotEmpty)
                ? AppBar(
                    centerTitle: true,
                    leading: const BackButton(color: ColorConstant.white),
                    backgroundColor: Colors.transparent,
                    title: AppText(title: '${controller.getArg!['title']}'),
                  )
                : const PreferredSize(
                    preferredSize: Size.zero, child: SizedBox()),
            body: (controller.songList.isNotEmpty)
                ? ListView.separated(
                    separatorBuilder: (context, index) {
                      if (adModel.data != null &&
                          adModel.data!.bannerCount != 0 &&
                          index % adModel.data!.bannerCount == 0 &&
                          adModel.data!.scrollAd) {
                        return AdService.createGoogleBannerAd();
                      }
                      return const SizedBox();
                    },
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 10),
                    shrinkWrap: true,
                    itemCount: controller.songList.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: OfflineAudioQuery.offlineArtworkWidget(
                          id: controller.songList[index].id!,
                          type: ArtworkType.AUDIO,
                          tempPath: controller.tmpPath,
                          fileName:
                              controller.songList[index].displayNameWOExt!,
                        ),
                        title: AppText(
                          title: controller.songList[index].title!.trim() != ''
                              ? controller.songList[index].title!
                              : controller.songList[index].displayNameWOExt!,
                          textOverflow: TextOverflow.ellipsis,
                        ),
                        subtitle: AppText(
                          title:
                              '${controller.songList[index].artist?.replaceAll('<unknown>', 'Unknown') ?? AppStringConstant.unknown} - ${controller.songList[index].album?.replaceAll('<unknown>', 'Unknown') ?? 'Unknown'}',
                          textOverflow: TextOverflow.ellipsis,
                        ),
                        trailing: PopupMenuButton(
                          icon: const Icon(
                            Icons.more_vert_rounded,
                            color: ColorConstant.white,
                          ),
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(15.0)),
                          ),
                          onSelected: (int? value) async {
                            if (value == 0) {
                              AddToPlayList().addToPlayList(
                                  context, controller.songList[index],controller.tmpPath);
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 0,
                              child: Row(
                                children: [
                                  const Icon(Icons.playlist_add_rounded,
                                      color: ColorConstant.white),
                                  SizedBox(width: 10.0.px),
                                  const AppText(
                                      title: AppStringConstant.addToPlaylist),
                                ],
                              ),
                            ),
                          ],
                        ),
                        onTap: () async {
                          AdService.counterHandler();
                          final audioPlayerController =
                              Get.put(AudioPlayerController());
                          audioPlayerController.initializeValue(
                              tmpPath: controller.tmpPath,
                              mySongList: controller.songList,
                              index: index);
                        },
                      );
                    },
                  )
                : const Center(
                    child: AppText(title: AppStringConstant.noSongFound),
                  ));
      },
    );
  }
}
