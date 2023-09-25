import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/components/app_image_assets.dart';
import 'package:music_player/components/app_text.dart';
import 'package:music_player/components/app_toast.dart';
import 'package:music_player/constants/asset_constant.dart';
import 'package:music_player/constants/color_constant.dart';
import 'package:music_player/constants/string_constant.dart';
import 'package:music_player/helper/audio_query_helper.dart';
import 'package:music_player/pages/home_page/home_page.dart';
import 'package:music_player/utils/all_logs.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class AddToPlayList{
  OfflineAudioQuery offlineAudioQuery = OfflineAudioQuery();
  Future<void> addToPlayList(BuildContext context,int audioId, SongModel songModel) async{
    List<PlaylistModel> playlistDetails = await offlineAudioQuery.getPlaylists();
    logs("playListDetails ----> $playlistDetails");
    // ignore: use_build_context_synchronously
    showModalBottomSheet(backgroundColor: Colors.transparent,context: context, builder: (context) {
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
                title: const AppText(title:AppStringConstant.createPlaylist),
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
                      await offlineAudioQuery.createPlaylist(name: value);
                      playlistDetails =
                      await offlineAudioQuery.getPlaylists();
                      Get.back();
                    },
                  );
                },
              ),
              if(playlistDetails.isNotEmpty)
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: playlistDetails.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Card(
                        elevation: 5,
                        color: ColorConstant.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7.0.px),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: QueryArtworkWidget(
                          id: playlistDetails[index].id,
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
                        title:playlistDetails[index].playlist,
                      ),
                      subtitle: AppText(
                        title:'${playlistDetails[index].numOfSongs} Songs',
                      ),
                      onTap: ()  {
                         offlineAudioQuery.addToPlaylist(
                          playlistId: playlistDetails[index].id,
                          audioId: audioId,
                        );
                        Get.back();
                        '${AppStringConstant.addedTo} ${playlistDetails[index].playlist}'.showToast();
                      },
                    );
                  },
                ),
            ],
          ),
        ),
      );
    },);
  }
}