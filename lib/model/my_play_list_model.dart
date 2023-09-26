// To parse this JSON data, do
//
//     final playlistModel = playlistModelFromJson(jsonString);

import 'dart:convert';
import 'package:music_player/model/my_song_model.dart';

MyPlaylistModel myPlaylistModelFromJson(String str) => MyPlaylistModel.fromJson(json.decode(str));

String myPlaylistModelToJson(MyPlaylistModel data) => json.encode(data.toJson());

class MyPlaylistModel {
  String? playlistName;
  String? playlistId;
  String tmpPath;
  List<MySongModel> songs;

  MyPlaylistModel({
    this.playlistName,
    this.playlistId,
    this.songs = const <MySongModel>[],
    this.tmpPath = '',
  });

  factory MyPlaylistModel.fromJson(Map<String, dynamic> json) => MyPlaylistModel(
    playlistName: json["playlistName"],
    playlistId: json["playlistId"],
    songs: List<MySongModel>.from(json["songs"].map((x) => MySongModel.fromJson(x))),
    tmpPath: json["tmpPath"],
  );

  Map<String, dynamic> toJson() => {
    "playlistName": playlistName,
    "playlistId": playlistId,
    "songs": List<dynamic>.from(songs.map((x) => x.toJson())).toString(),
    "tmpPath": tmpPath,
  };
}
