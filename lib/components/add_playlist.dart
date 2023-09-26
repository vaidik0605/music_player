import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/components/app_text.dart';
import 'package:music_player/components/app_toast.dart';
import 'package:music_player/constants/color_constant.dart';
import 'package:music_player/constants/string_constant.dart';
import 'package:music_player/helper/audio_query_helper.dart';
import 'package:music_player/helper/db_helper.dart';
import 'package:music_player/model/my_play_list_model.dart';
import 'package:music_player/model/my_song_model.dart';
import 'package:music_player/pages/home_page/home_page.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class AddToPlayList {
  OfflineAudioQuery offlineAudioQuery = OfflineAudioQuery();
  DbHelper dbHelper = DbHelper.instance;

  Future<void> addToPlayList(
      BuildContext context, MySongModel songModel, String tmpPath) async {
    List<MyPlaylistModel> playlistDetails = await dbHelper.getPlayList();
    // ignore: use_build_context_synchronously
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.fromLTRB(10.px, 15.px, 10.px, 15.px),
          margin: EdgeInsets.fromLTRB(25.px, 0, 25.px, 25.px),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.px),
            color: ColorConstant.grey900,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const AppText(title: AppStringConstant.createPlaylist),
                  leading: Card(
                    elevation: 0,
                    color: Colors.transparent,
                    child: SizedBox.square(
                      dimension: 50.px,
                      child: Center(
                        child: Icon(
                          Icons.add_rounded,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? ColorConstant.white
                              : ColorConstant.grey700,
                        ),
                      ),
                    ),
                  ),
                  onTap: () {
                    showTextInputDialog(
                      context: context,
                      keyboardType: TextInputType.text,
                      title: AppStringConstant.createNewPlaylist,
                      onSubmitted: (String value) async {
                        MyPlaylistModel playlistModel = MyPlaylistModel(
                            playlistName: value,
                            playlistId:
                                '$value-${DateTime.now().microsecondsSinceEpoch}');
                        await dbHelper.createPlayList(
                            playlistModel: playlistModel);
                        playlistDetails = await dbHelper.getPlayList();
                        Get.back();
                      },
                    );
                  },
                ),
                if (playlistDetails.isNotEmpty)
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: playlistDetails.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: OfflineAudioQuery.offlineArtworkWidget(
                            id: playlistDetails[index].songs.isNotEmpty
                                ? playlistDetails[index].songs.first.id!
                                : 0,
                            type: ArtworkType.AUDIO,
                            tempPath:
                                (playlistDetails[index].tmpPath.isNotEmpty)
                                    ? playlistDetails[index].tmpPath
                                    : '',
                            fileName: playlistDetails[index].songs.isNotEmpty
                                ? playlistDetails
                                    .first.songs.first.displayNameWOExt!
                                : ''),
                        title: AppText(
                          title: playlistDetails[index].playlistName!,
                        ),
                        subtitle: AppText(
                          title: '${playlistDetails[index].songs.length} Songs',
                        ),
                        onTap: () async {
                          DbHelper dbHelper = DbHelper.instance;
                          await dbHelper.addSongs(
                              tmpPath: tmpPath,
                              songs: songModel,
                              playListId: playlistDetails[index].playlistId!);
                          Get.back();
                          '${AppStringConstant.addedTo} ${playlistDetails[index].playlistName}'
                              .showToast();
                        },
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
