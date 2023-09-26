import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/components/add_playlist.dart';
import 'package:music_player/components/app_loader.dart';
import 'package:music_player/components/app_text.dart';
import 'package:music_player/components/app_toast.dart';
import 'package:music_player/constants/color_constant.dart';
import 'package:music_player/constants/string_constant.dart';
import 'package:music_player/controller/home_controller.dart';
import 'package:music_player/controller/player_controller.dart';
import 'package:music_player/helper/audio_query_helper.dart';
import 'package:music_player/helper/db_helper.dart';
import 'package:music_player/model/my_play_list_model.dart';
import 'package:music_player/model/my_song_model.dart';
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
  DbHelper dbHelper = DbHelper.instance;
  String title = '';
  String? playlistId;
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
      body: FutureBuilder<MyPlaylistModel>(
        future: dbHelper.getPlayListSongs(playListId: playlistId!),
        builder: (context, AsyncSnapshot<MyPlaylistModel> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data != null && snapshot.data!.songs.isNotEmpty) {
              return ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 10),
                shrinkWrap: true,
                itemCount: snapshot.data!.songs.length,
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
                  MySongModel songModel = snapshot.data!.songs[index];
                  return ListTile(
                    leading: OfflineAudioQuery.offlineArtworkWidget(
                      id: songModel.id!,
                      type: ArtworkType.AUDIO,
                      tempPath: tmpPath,
                      fileName: songModel.displayNameWOExt!,
                    ),
                    title: AppText(
                      title: songModel.title != null &&
                              songModel.title!.trim() != ''
                          ? songModel.title!
                          : songModel.displayNameWOExt!,
                      textOverflow: TextOverflow.ellipsis,
                    ),
                    subtitle: AppText(
                      title:
                          '${songModel.artist?.replaceAll('<unknown>', 'Unknown') ?? AppStringConstant.unknown} - ${songModel.album?.replaceAll('<unknown>', 'Unknown') ?? 'Unknown'}',
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
                          AddToPlayList().addToPlayList(context, songModel,tmpPath);
                        }
                        if (value == 1) {
                          logs('audioId ---> ${songModel.id}');
                          await dbHelper.removeSongFromPlayList(playlistModel: snapshot.data!, songId: songModel.id!);
                          '${AppStringConstant.removeFrom} $title'.showToast();
                          setState(() {});
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
                          mySongList: snapshot.data!.songs,
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
