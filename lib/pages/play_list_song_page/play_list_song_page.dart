import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/components/add_playlist.dart';
import 'package:music_player/components/app_text.dart';
import 'package:music_player/components/app_toast.dart';
import 'package:music_player/components/banner_ad_widget.dart';
import 'package:music_player/constants/color_constant.dart';
import 'package:music_player/constants/string_constant.dart';
import 'package:music_player/controller/home_controller.dart';
import 'package:music_player/controller/player_controller.dart';
import 'package:music_player/helper/audio_query_helper.dart';
import 'package:music_player/pages/home_page/home_page.dart';
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
  List<SongModel> songList = [];
  String tmpPath = '';

  @override
  void initState() {
    var arg = Get.arguments;
    title = arg['title'];
    playlistId = arg['playListId'];
    HomeController controller = Get.put(HomeController());
    tmpPath = controller.tmpPath!;
    super.initState();
    getData();
  }
  getData() async {

    songList = await offlineAudioQuery.getPlaylistSongs(playlistId!);
    logs("songList ---> ${songList.length}");
    setState(() {});
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
      body: ListView.separated(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 10),
        shrinkWrap: true,
        itemCount: songList.length,
        separatorBuilder: (context, index) {
          if(index % bannerAdDividerCount == 0){
            return const AppBannerAdView();
          }
          return const SizedBox();
        },
        itemBuilder: (context, index) {
          return ListTile(
            leading: OfflineAudioQuery.offlineArtworkWidget(
              id: songList[index].id,
              type: ArtworkType.AUDIO,
              tempPath: tmpPath,
              fileName: songList[index].displayNameWOExt,
            ),
            title: AppText(
              title: songList[index].title.trim() != ''
                  ? songList[index].title
                  : songList[index].displayNameWOExt,
              textOverflow: TextOverflow.ellipsis,
            ),
            subtitle: AppText(
              title:
                  '${songList[index].artist?.replaceAll('<unknown>', 'Unknown') ?? AppStringConstant.unknown} - ${songList[index].album?.replaceAll('<unknown>', 'Unknown') ?? 'Unknown'}',
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
                log("value ---> $value");
                if (value == 0) {
                   AddToPlayList().addToPlayList(
                    context,
                    songList[index].id,
                  );
                }
                if (value == 1) {
                  await offlineAudioQuery.removeFromPlaylist(
                    playlistId: playlistId!,
                    audioId: songList[index].id,
                  );
                  //getData();
                  // List songs =
                  //     await offlineAudioQuery.getPlaylistSongs(playlistId!);
                  // logs("songs ---> ${songs.length}");
                  //setState(() {});
                  '${AppStringConstant.removeFrom} $title'.showToast();
                }
                // if (value == 0) {
                // showDialog(
                // context: context,
                // builder: (BuildContext context) {
                // final String fileName = _cachedSongs[index].uri!;
                // final List temp = fileName.split('.');
                // temp.removeLast();
                //           final String songName = temp.join('.');
                //           final controller =
                //               TextEditingController(text: songName);
                //           return AlertDialog(
                //             content: Column(
                //               mainAxisSize: MainAxisSize.min,
                //               children: [
                //                 Row(
                //                   children: [
                //                     Text(
                //                       'Name',
                //                       style: TextStyle(
                //                           color: Theme.of(context).accentColor),
                //                     ),
                //                   ],
                //                 ),
                //                 const SizedBox(
                //                   height: 10,
                //                 ),
                //                 TextField(
                //                     autofocus: true,
                //                     controller: controller,
                //                     onSubmitted: (value) async {
                //                       try {
                //                         Navigator.pop(context);
                //                         String newName = _cachedSongs[index]
                //                                 ['id']
                //                             .toString()
                //                             .replaceFirst(songName, value);

                //                         while (await File(newName).exists()) {
                //                           newName = newName.replaceFirst(
                //                               value, '$value (1)');
                //                         }

                //                         File(_cachedSongs[index]['id']
                //                                 .toString())
                //                             .rename(newName);
                //                         _cachedSongs[index]['id'] = newName;
                //                         ShowSnackBar().showSnackBar(
                //                           context,
                //                           'Renamed to ${_cachedSongs[index]['id'].split('/').last}',
                //                         );
                //                       } catch (e) {
                //                         ShowSnackBar().showSnackBar(
                //                           context,
                //                           'Failed to Rename ${_cachedSongs[index]['id'].split('/').last}',
                //                         );
                //                       }
                //                       setState(() {});
                //                     }),
                //               ],
                //             ),
                //             actions: [
                //               TextButton(
                //                 style: TextButton.styleFrom(
                //                   primary: Theme.of(context).brightness ==
                //                           Brightness.dark
                //                       ? Colors.white
                //                       : Colors.grey[700],
                //                   //       backgroundColor: Theme.of(context).accentColor,
                //                 ),
                //                 onPressed: () {
                //                   Navigator.pop(context);
                //                 },
                //                 child: const Text(
                //                   'Cancel',
                //                 ),
                //               ),
                //               TextButton(
                //                 style: TextButton.styleFrom(
                //                   primary: Colors.white,
                //                   backgroundColor:
                //                       Theme.of(context).accentColor,
                //                 ),
                //                 onPressed: () async {
                //                   try {
                //                     Navigator.pop(context);
                //                     String newName = _cachedSongs[index]['id']
                //                         .toString()
                //                         .replaceFirst(
                //                             songName, controller.text);

                //                     while (await File(newName).exists()) {
                //                       newName = newName.replaceFirst(
                //                           controller.text,
                //                           '${controller.text} (1)');
                //                     }

                //                     File(_cachedSongs[index]['id'].toString())
                //                         .rename(newName);
                //                     _cachedSongs[index]['id'] = newName;
                //                     ShowSnackBar().showSnackBar(
                //                       context,
                //                       'Renamed to ${_cachedSongs[index]['id'].split('/').last}',
                //                     );
                //                   } catch (e) {
                //                     ShowSnackBar().showSnackBar(
                //                       context,
                //                       'Failed to Rename ${_cachedSongs[index]['id'].split('/').last}',
                //                     );
                //                   }
                //                   setState(() {});
                //                 },
                //                 child: const Text(
                //                   'Ok',
                //                   style: TextStyle(color: Colors.white),
                //                 ),
                //               ),
                //               const SizedBox(
                //                 width: 5,
                //               ),
                //             ],
                //           );
                //         },
                //       );
                //     }
                //     if (value == 1) {
                //       showDialog(
                //         context: context,
                //         builder: (BuildContext context) {
                //           Uint8List? _imageByte =
                //               _cachedSongs[index]['image'] as Uint8List?;
                //           String _imagePath = '';
                //           final _titlecontroller = TextEditingController(
                //               text: _cachedSongs[index]['title'].toString());
                //           final _albumcontroller = TextEditingController(
                //               text: _cachedSongs[index]['album'].toString());
                //           final _artistcontroller = TextEditingController(
                //               text: _cachedSongs[index]['artist'].toString());
                //           final _albumArtistController = TextEditingController(
                //               text: _cachedSongs[index]['albumArtist']
                //                   .toString());
                //           final _genrecontroller = TextEditingController(
                //               text: _cachedSongs[index]['genre'].toString());
                //           final _yearcontroller = TextEditingController(
                //               text: _cachedSongs[index]['year'].toString());
                //           final tagger = Audiotagger();
                //           return AlertDialog(
                //             content: SizedBox(
                //               height: 400,
                //               width: 300,
                //               child: SingleChildScrollView(
                //                 physics: const BouncingScrollPhysics(),
                //                 child: Column(
                //                   mainAxisSize: MainAxisSize.min,
                //                   children: [
                //                     GestureDetector(
                //                       onTap: () async {
                //                         final String filePath = await Picker()
                //                             .selectFile(
                //                                 context,
                //                                 ['png', 'jpg', 'jpeg'],
                //                                 'Pick Image');
                //                         if (filePath != '') {
                //                           _imagePath = filePath;
                //                           final Uri myUri = Uri.parse(filePath);
                //                           final Uint8List imageBytes =
                //                               await File.fromUri(myUri)
                //                                   .readAsBytes();
                //                           _imageByte = imageBytes;
                //                           final Tag tag = Tag(
                //                             artwork: _imagePath,
                //                           );
                //                           try {
                //                             await [
                //                               Permission.manageExternalStorage,
                //                             ].request();
                //                             await tagger.writeTags(
                //                               path: _cachedSongs[index]['id']
                //                                   .toString(),
                //                               tag: tag,
                //                             );
                //                           } catch (e) {
                //                             await tagger.writeTags(
                //                               path: _cachedSongs[index]['id']
                //                                   .toString(),
                //                               tag: tag,
                //                             );
                //                           }
                //                         }
                //                       },
                //                       child: Card(
                //                         elevation: 5,
                //                         shape: RoundedRectangleBorder(
                //                           borderRadius:
                //                               BorderRadius.circular(7.0),
                //                         ),
                //                         clipBehavior: Clip.antiAlias,
                //                         child: SizedBox(
                //                           height: MediaQuery.of(context)
                //                                   .size
                //                                   .width /
                //                               2,
                //                           width: MediaQuery.of(context)
                //                                   .size
                //                                   .width /
                //                               2,
                //                           child: _imageByte == null
                //                               ? const Image(
                //                                   fit: BoxFit.cover,
                //                                   image: AssetImage(
                //                                       'assets/cover.jpg'),
                //                                 )
                //                               : Image(
                //                                   fit: BoxFit.cover,
                //                                   image:
                //                                       MemoryImage(_imageByte!)),
                //                         ),
                //                       ),
                //                     ),
                //                     const SizedBox(height: 20.0),
                //                     Row(
                //                       children: [
                //                         Text(
                //                           'Title',
                //                           style: TextStyle(
                //                               color: Theme.of(context)
                //                                   .accentColor),
                //                         ),
                //                       ],
                //                     ),
                //                     TextField(
                //                         autofocus: true,
                //                         controller: _titlecontroller,
                //                         onSubmitted: (value) {}),
                //                     const SizedBox(
                //                       height: 30,
                //                     ),
                //                     Row(
                //                       children: [
                //                         Text(
                //                           'Artist',
                //                           style: TextStyle(
                //                               color: Theme.of(context)
                //                                   .accentColor),
                //                         ),
                //                       ],
                //                     ),
                //                     TextField(
                //                         autofocus: true,
                //                         controller: _artistcontroller,
                //                         onSubmitted: (value) {}),
                //                     const SizedBox(
                //                       height: 30,
                //                     ),
                //                     Row(
                //                       children: [
                //                         Text(
                //                           'Album Artist',
                //                           style: TextStyle(
                //                               color: Theme.of(context)
                //                                   .accentColor),
                //                         ),
                //                       ],
                //                     ),
                //                     TextField(
                //                         autofocus: true,
                //                         controller: _albumArtistController,
                //                         onSubmitted: (value) {}),
                //                     const SizedBox(
                //                       height: 30,
                //                     ),
                //                     Row(
                //                       children: [
                //                         Text(
                //                           'Album',
                //                           style: TextStyle(
                //                               color: Theme.of(context)
                //                                   .accentColor),
                //                         ),
                //                       ],
                //                     ),
                //                     TextField(
                //                         autofocus: true,
                //                         controller: _albumcontroller,
                //                         onSubmitted: (value) {}),
                //                     const SizedBox(
                //                       height: 30,
                //                     ),
                //                     Row(
                //                       children: [
                //                         Text(
                //                           'Genre',
                //                           style: TextStyle(
                //                               color: Theme.of(context)
                //                                   .accentColor),
                //                         ),
                //                       ],
                //                     ),
                //                     TextField(
                //                         autofocus: true,
                //                         controller: _genrecontroller,
                //                         onSubmitted: (value) {}),
                //                     const SizedBox(
                //                       height: 30,
                //                     ),
                //                     Row(
                //                       children: [
                //                         Text(
                //                           'Year',
                //                           style: TextStyle(
                //                               color: Theme.of(context)
                //                                   .accentColor),
                //                         ),
                //                       ],
                //                     ),
                //                     TextField(
                //                         autofocus: true,
                //                         controller: _yearcontroller,
                //                         onSubmitted: (value) {}),
                //                   ],
                //                 ),
                //               ),
                //             ),
                //             actions: [
                //               TextButton(
                //                 style: TextButton.styleFrom(
                //                   primary: Theme.of(context).brightness ==
                //                           Brightness.dark
                //                       ? Colors.white
                //                       : Colors.grey[700],
                //                 ),
                //                 onPressed: () {
                //                   Navigator.pop(context);
                //                 },
                //                 child: const Text('Cancel'),
                //               ),
                //               TextButton(
                //                 style: TextButton.styleFrom(
                //                   primary: Colors.white,
                //                   backgroundColor:
                //                       Theme.of(context).accentColor,
                //                 ),
                //                 onPressed: () async {
                //                   Navigator.pop(context);
                //                   _cachedSongs[index]['title'] =
                //                       _titlecontroller.text;
                //                   _cachedSongs[index]['album'] =
                //                       _albumcontroller.text;
                //                   _cachedSongs[index]['artist'] =
                //                       _artistcontroller.text;
                //                   _cachedSongs[index]['albumArtist'] =
                //                       _albumArtistController.text;
                //                   _cachedSongs[index]['genre'] =
                //                       _genrecontroller.text;
                //                   _cachedSongs[index]['year'] =
                //                       _yearcontroller.text;
                //                   final tag = Tag(
                //                     title: _titlecontroller.text,
                //                     artist: _artistcontroller.text,
                //                     album: _albumcontroller.text,
                //                     genre: _genrecontroller.text,
                //                     year: _yearcontroller.text,
                //                     albumArtist: _albumArtistController.text,
                //                   );
                //                   try {
                //                     try {
                //                       await [
                //                         Permission.manageExternalStorage,
                //                       ].request();
                //                       tagger.writeTags(
                //                         path: _cachedSongs[index]['id']
                //                             .toString(),
                //                         tag: tag,
                //                       );
                //                     } catch (e) {
                //                       await tagger.writeTags(
                //                         path: _cachedSongs[index]['id']
                //                             .toString(),
                //                         tag: tag,
                //                       );
                //                       ShowSnackBar().showSnackBar(
                //                         context,
                //                         'Successfully edited tags',
                //                       );
                //                     }
                //                   } catch (e) {
                //                     ShowSnackBar().showSnackBar(
                //                       context,
                //                       'Failed to edit tags',
                //                     );
                //                   }
                //                 },
                //                 child: const Text(
                //                   'Ok',
                //                   style: TextStyle(color: Colors.white),
                //                 ),
                //               ),
                //               const SizedBox(
                //                 width: 5,
                //               ),
                //             ],
                //           );
                //         },
                //       );
                //     }
                //     if (value == 2) {
                //       try {
                //         File(_cachedSongs[index]['id'].toString()).delete();
                //         ShowSnackBar().showSnackBar(
                //           context,
                //           'Deleted ${_cachedSongs[index]['id'].split('/').last}',
                //         );
                //         if (_cachedAlbums[_cachedSongs[index]['album']]
                //                 .length ==
                //             1) {
                //           sortedCachedAlbumKeysList
                //               .remove(_cachedSongs[index]['album']);
                //         }
                //         _cachedAlbums[_cachedSongs[index]['album']]
                //             .remove(_cachedSongs[index]);

                //         if (_cachedArtists[_cachedSongs[index]['artist']]
                //                 .length ==
                //             1) {
                //           sortedCachedArtistKeysList
                //               .remove(_cachedSongs[index]['artist']);
                //         }
                //         _cachedArtists[_cachedSongs[index]['artist']]
                //             .remove(_cachedSongs[index]);

                //         if (_cachedGenres[_cachedSongs[index]['genre']]
                //                 .length ==
                //             1) {
                //           sortedCachedGenreKeysList
                //               .remove(_cachedSongs[index]['genre']);
                //         }
                //         _cachedGenres[_cachedSongs[index]['genre']]
                //             .remove(_cachedSongs[index]);

                //         _cachedSongs.remove(_cachedSongs[index]);
                //       } catch (e) {
                //         ShowSnackBar().showSnackBar(
                //           context,
                //           'Failed to delete ${_cachedSongs[index]['id']}',
                //         );
                //       }
                //       setState(() {});
                // }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 0,
                  child: Row(
                    children: [
                      const Icon(Icons.playlist_add_rounded,
                          color: ColorConstant.white),
                      SizedBox(width: 10.0.px),
                      const AppText(title: AppStringConstant.addToPlaylist),
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
              final audioPlayerController = Get.put(AudioPlayerController());
              audioPlayerController.initializeValue(
                  tmpPath: tmpPath, songList: songList, index: index);
            },
          );
        },
      ),
    );
  }
}
