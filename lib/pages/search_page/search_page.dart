import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/components/app_loader.dart';
import 'package:music_player/components/app_text.dart';
import 'package:music_player/components/music_list_tile.dart';
import 'package:music_player/constants/color_constant.dart';
import 'package:music_player/constants/string_constant.dart';
import 'package:music_player/controller/home_controller.dart';
import 'package:music_player/controller/search_controller.dart';
import 'package:music_player/routes/route_constant.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SearchSongController>(
      init: SearchSongController(),
      initState: (state) {
        Future.delayed(
          const Duration(milliseconds: 150),
          () {
            HomeController homeController = Get.find<HomeController>();
            SearchSongController searchSongController =
                Get.find<SearchSongController>();
            searchSongController.songs = homeController.songs;
            searchSongController.albumList = homeController.albums;
            searchSongController.albumKeyList = homeController.albumsKeyList;
            searchSongController.artistList = homeController.artists;
            searchSongController.artisKeyList = homeController.artisKeyList;
            searchSongController.tmpPath = homeController.tmpPath!;
          },
        );
      },
      builder: (controller) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.px, vertical: 10.px),
                      child: SizedBox(
                        height: 52.px,
                        child: TextField(
                          cursorColor: ColorConstant.tealAccent,
                          controller: controller.searchTextController,
                          onChanged: (value) => controller.onSearchSong(value),
                          style: const TextStyle(color: ColorConstant.white),
                          decoration: InputDecoration(
                            prefixIcon: IconButton(
                                onPressed: () => Get.back(),
                                icon: const Icon(Icons.arrow_back),
                                color: ColorConstant.white),
                            suffixIcon: IconButton(
                                onPressed: () => controller.clearSearch(),
                                icon: const Icon(Icons.close,
                                    color: ColorConstant.white)),
                            fillColor: ColorConstant.grey900,
                            filled: true,
                            hintText: AppStringConstant.songsAlbumsArtis,
                            hintStyle: TextStyle(color: ColorConstant.grey300),
                            contentPadding:
                                EdgeInsets.only(bottom: 5.px, left: 5.px),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.px),
                                borderSide: BorderSide.none),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.px),
                                borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                    ),
                    if (!controller.isLoading)
                      Expanded(
                          child: (controller.searchedSongs.isEmpty &&
                                  controller.searchedArtistKeyList.isEmpty &&
                                  controller.searchedAlbumKeyList.isEmpty)
                              ? const Center(
                                  child: AppText(
                                      title: AppStringConstant.noSongFound),
                                )
                              : ListView(
                                  children: [
                                    if (controller.searchedSongs.isNotEmpty)
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 15.px),
                                            child: AppText(
                                              title: AppStringConstant.songs,
                                              fontColor:
                                                  ColorConstant.tealAccent,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 22.px,
                                            ),
                                          ),
                                          Column(
                                            children: controller.searchedSongs
                                                .map<Widget>((song) {
                                              return AlbumTile(
                                                id: song.id,
                                                title: song.title,
                                                fileName: song.displayNameWOExt,
                                                subTitle:
                                                    song.artist ?? 'unKnown',
                                                tempPath: controller.tmpPath,
                                                onTap: () => Get.toNamed(
                                                    RouteConstant.musicRoute,
                                                    arguments: {
                                                      'songList': [song],
                                                      'title': song.displayName
                                                    }),
                                              );
                                            }).toList(),
                                          ),
                                          SizedBox(height: 10.px),
                                        ],
                                      ),
                                    if (controller
                                        .searchedArtistKeyList.isNotEmpty)
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 15.px),
                                            child: AppText(
                                              title: AppStringConstant.artists,
                                              fontColor:
                                                  ColorConstant.tealAccent,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 22.px,
                                            ),
                                          ),
                                          Column(
                                            children: List.generate(
                                                controller.searchedArtistKeyList
                                                    .length,
                                                (index) => AlbumTile(
                                                      id: controller
                                                          .artistList[controller
                                                                  .searchedArtistKeyList[
                                                              index]]![0]
                                                          .id,
                                                      title: controller
                                                              .searchedArtistKeyList[
                                                          index],
                                                      fileName: controller
                                                          .artistList[controller
                                                                  .searchedArtistKeyList[
                                                              index]]![0]
                                                          .displayNameWOExt,
                                                      subTitle:
                                                          '${controller.artistList[controller.searchedArtistKeyList[index]]!.length} ${AppStringConstant.songs}',
                                                      tempPath:
                                                          controller.tmpPath,
                                                      onTap: () => Get.toNamed(
                                                          RouteConstant
                                                              .musicRoute,
                                                          arguments: {
                                                            'songList': controller
                                                                    .artistList[
                                                                controller
                                                                        .searchedArtistKeyList[
                                                                    index]],
                                                            'title': controller
                                                                    .searchedArtistKeyList[
                                                                index]
                                                          }),
                                                    )),
                                          ),
                                        ],
                                      ),
                                    if (controller
                                        .searchedAlbumKeyList.isNotEmpty)
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 15.px),
                                            child: AppText(
                                              title: AppStringConstant.albums,
                                              fontColor:
                                                  ColorConstant.tealAccent,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 22.px,
                                            ),
                                          ),
                                          Column(
                                            children: List.generate(
                                                controller.searchedAlbumKeyList
                                                    .length,
                                                (index) => AlbumTile(
                                                      id: controller
                                                          .albumList[controller
                                                                  .searchedAlbumKeyList[
                                                              index]]![0]
                                                          .id,
                                                      title: controller
                                                              .searchedAlbumKeyList[
                                                          index],
                                                      fileName: controller
                                                          .albumList[controller
                                                                  .searchedAlbumKeyList[
                                                              index]]![0]
                                                          .displayNameWOExt,
                                                      subTitle:
                                                          '${controller.albumList[controller.searchedAlbumKeyList[index]]!.length} ${AppStringConstant.songs}',
                                                      tempPath:
                                                          controller.tmpPath,
                                                      onTap: () => Get.toNamed(
                                                          RouteConstant
                                                              .musicRoute,
                                                          arguments: {
                                                            'songList': controller
                                                                    .albumList[
                                                                controller
                                                                        .searchedAlbumKeyList[
                                                                    index]],
                                                            'title': controller
                                                                    .searchedAlbumKeyList[
                                                                index]
                                                          }),
                                                    )),
                                          ),
                                        ],
                                      )
                                  ],
                                )),
                  ],
                ),
                if (controller.isLoading) const AppLoader(),
              ],
            ),
          ),
        );
      },
    );
  }
}
