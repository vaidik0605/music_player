import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/components/app_image_assets.dart';
import 'package:music_player/components/app_loader.dart';
import 'package:music_player/components/app_text.dart';
import 'package:music_player/components/app_toast.dart';
import 'package:music_player/components/banner_ad_widget.dart';
import 'package:music_player/constants/asset_constant.dart';
import 'package:music_player/constants/color_constant.dart';
import 'package:music_player/constants/string_constant.dart';
import 'package:music_player/controller/playlist_controller.dart';
import 'package:music_player/pages/home_page/home_page.dart';
import 'package:music_player/routes/route_constant.dart';
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
            controller.getPlayList();
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
                            controller.createPlayList(value);
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
      child: ListView.separated(
        separatorBuilder: (context, index) {
          if (index % bannerAdDividerCount == 0) {
            return const AppBannerAdView();
          }
          return const SizedBox();
        },
        itemCount: controller.playlistDetails.length,
        itemBuilder: (context, index) {
          return ListTile(
            onTap: () async {
              Get.toNamed(RouteConstant.playlistSongRoute, arguments: {
                'title': controller.playlistDetails[index].playlist,
                'playListId': controller.playlistDetails[index].id,
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
                id: controller.playlistDetails[index].id,
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
              title: controller.playlistDetails[index].playlist,
            ),
            subtitle: AppText(
              title: '${controller.playlistDetails[index].numOfSongs} Songs',
            ),
            trailing: PopupMenuButton(
              icon: const Icon(Icons.more_vert_rounded,
                  color: ColorConstant.white),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(15.px),
                ),
              ),
              onSelected: (value) {
                if (value == 0) {
                  controller.deletePlayList(index);
                  '${AppStringConstant.deleted} ${controller.playlistDetails[index].playlist}'
                      .showToast();
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
      ),
    );
  }
}
