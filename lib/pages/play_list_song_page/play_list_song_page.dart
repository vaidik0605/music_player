import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/components/add_playlist.dart';
import 'package:music_player/components/app_loader.dart';
import 'package:music_player/components/app_text.dart';
import 'package:music_player/constants/color_constant.dart';
import 'package:music_player/constants/string_constant.dart';
import 'package:music_player/controller/home_controller.dart';
import 'package:music_player/controller/player_controller.dart';
import 'package:music_player/helper/audio_query_helper.dart';
import 'package:music_player/pages/home_page/home_page.dart';
import 'package:music_player/service/ad_service.dart';
import 'package:music_player/utils/all_logs.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class PlaylistSongPage extends StatefulWidget {
  const PlaylistSongPage({super.key});

  @override
  State<PlaylistSongPage> createState() => _PlaylistSongPageState();
}

class _PlaylistSongPageState extends State<PlaylistSongPage> {
  OfflineAudioQuery offlineAudioQuery = OfflineAudioQuery();
  String title = '';
  int? playlistId;
  String tmpPath = '';

  @override
  void initState() {
    var arg = Get.arguments;
    title = arg['title'];
    playlistId = arg['playListId'];
    HomeController controller = Get.put(HomeController());
    tmpPath = controller.tmpPath!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: const BackButton(color: ColorConstant.white),
        backgroundColor: Colors.transparent,
        title: AppText(title: title),
      ),
      body: FutureBuilder<List<SongModel>>(
        future: offlineAudioQuery.getPlaylistSongs(playlistId!),
        builder: (context, AsyncSnapshot<List<SongModel>> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data != null && snapshot.data!.isNotEmpty) {
              return ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 10),
                shrinkWrap: true,
                itemCount: snapshot.data!.length,
                separatorBuilder: (context, index) {
                  if (adModel.data != null &&
                      adModel.data!.bannerCount != 0 &&
                      index % adModel.data!.bannerCount == 0 &&
                      adModel.data!.scrollAd) {
                    return AdService.createGoogleBannerAd();
                  }
                  return const SizedBox();
                },
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: OfflineAudioQuery.offlineArtworkWidget(
                      id: snapshot.data![index].id,
                      type: ArtworkType.AUDIO,
                      tempPath: tmpPath,
                      fileName: snapshot.data![index].displayNameWOExt,
                    ),
                    title: AppText(
                      title: snapshot.data![index].title.trim() != ''
                          ? snapshot.data![index].title
                          : snapshot.data![index].displayNameWOExt,
                      textOverflow: TextOverflow.ellipsis,
                    ),
                    subtitle: AppText(
                      title:
                          '${snapshot.data![index].artist?.replaceAll('<unknown>', 'Unknown') ?? AppStringConstant.unknown} - ${snapshot.data![index].album?.replaceAll('<unknown>', 'Unknown') ?? 'Unknown'}',
                      textOverflow: TextOverflow.ellipsis,
                    ),
                    trailing: PopupMenuButton(
                      icon: const Icon(
                        Icons.more_vert_rounded,
                        color: ColorConstant.white,
                      ),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15.0)),
                      ),
                      onSelected: (int? value) async {
                        if (value == 0) {
                          AddToPlayList().addToPlayList(context,
                              snapshot.data![index].id, snapshot.data![index]);
                        }
                        if (value == 1) {
                          logs('audioId ---> ${snapshot.data![index].id}');
                          bool isSuccess =
                              await offlineAudioQuery.removeFromPlaylist(
                                  playlistId: playlistId!,
                                  audioId: snapshot.data![index].id);
                          logs('isSuccess --> $isSuccess');
                         setState(() {});
                          // '${AppStringConstant.removeFrom} $title'.showToast();
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
                        PopupMenuItem(
                          value: 1,
                          child: Row(
                            children: [
                              const Icon(Icons.delete_rounded,
                                  color: ColorConstant.white),
                              SizedBox(width: 10.0.px),
                              const AppText(title: AppStringConstant.remove),
                            ],
                          ),
                        ),
                      ],
                    ),
                    onTap: () async {
                      final audioPlayerController =
                          Get.put(AudioPlayerController());
                      audioPlayerController.initializeValue(
                          tmpPath: tmpPath,
                          songList: snapshot.data!,
                          index: index);
                    },
                  );
                },
              );
            }
            return const Center(
              child: AppText(title: AppStringConstant.noSongFound),
            );
          }
          return const AppLoader();
        },
      ),
    );
  }
}
