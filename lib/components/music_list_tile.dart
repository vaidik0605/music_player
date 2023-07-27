import 'package:flutter/material.dart';
import 'package:music_player/components/app_text.dart';
import 'package:music_player/constants/color_constant.dart';
import 'package:music_player/helper/audio_query_helper.dart';
import 'package:on_audio_query/on_audio_query.dart';

class AlbumTile extends StatelessWidget {
  final String title;
  final String subTitle;
  final int id;
  final ArtworkType artworkType;
  final String tempPath;
  final String fileName;
  final Function() onTap;
  const AlbumTile(
      {super.key,
      required this.id,
      required this.title,
      required this.fileName,
      required this.subTitle,
      required this.tempPath,
        required this.onTap,
      this.artworkType = ArtworkType.ALBUM});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: OfflineAudioQuery.offlineArtworkWidget(
        id: id,
        type: artworkType,
        tempPath: tempPath,
        fileName:fileName,
      ),          title: AppText(title:title,fontColor: ColorConstant.white,textOverflow: TextOverflow.ellipsis,),
      subtitle: AppText(title: subTitle),
    );
  }
}
