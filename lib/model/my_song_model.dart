// To parse this JSON data, do
//
//     final mySongModel = mySongModelFromJson(jsonString);

import 'dart:convert';

MySongModel mySongModelFromJson(String str) => MySongModel.fromJson(json.decode(str));

String mySongModelToJson(MySongModel data) => json.encode(data.toJson());

class MySongModel {
  String? uri;
  String? artist;
  dynamic year;
  bool isMusic;
  String? title;
  String? genreId;
  int? size;
  int? duration;
  bool isAlarm;
  String? displayNameWOExt;
  dynamic albumArtist;
  dynamic genre;
  bool isNotification;
  int? track;
  String? data;
  String? displayName;
  String? album;
  dynamic composer;
  bool isRingtone;
  num? artistId;
  bool isPodcast;
  int? bookmark;
  int? dateAdded;
  bool isAudiobook;
  int? dateModified;
  num? albumId;
  String? fileExtension;
  int? id;

  MySongModel({
    this.uri,
    this.artist,
    this.year,
    this.isMusic = false,
    this.title,
    this.genreId,
    this.size,
    this.duration,
    this.isAlarm = false,
    this.displayNameWOExt,
    this.albumArtist,
    this.genre,
    this.isNotification = false,
    this.track,
    this.data,
    this.displayName,
    this.album,
    this.composer,
    this.isRingtone = false,
    this.artistId,
    this.isPodcast = false,
    this.bookmark,
    this.dateAdded,
    this.isAudiobook = false,
    this.dateModified,
    this.albumId,
    this.fileExtension,
    this.id,
  });

  factory MySongModel.fromJson(Map<dynamic, dynamic> json) => MySongModel(
    uri: json["_uri"],
    artist: json["artist"],
    year: json["year"],
    isMusic: json["is_music"],
    title: json["title"],
    genreId: json["genre_id"],
    size: json["_size"],
    duration: json["duration"],
    isAlarm: json["is_alarm"],
    displayNameWOExt: json["_display_name_wo_ext"],
    albumArtist: json["album_artist"],
    genre: json["genre"],
    isNotification: json["is_notification"],
    track: json["track"],
    data: json["_data"],
    displayName: json["_display_name"],
    album: json["album"],
    composer: json["composer"],
    isRingtone: json["is_ringtone"],
    artistId: json["artist_id"].toDouble(),
    isPodcast: json["is_podcast"],
    bookmark: json["bookmark"],
    dateAdded: json["date_added"],
    isAudiobook: json["is_audiobook"],
    dateModified: json["date_modified"],
    albumId: json["album_id"].toDouble(),
    fileExtension: json["file_extension"],
    id: json["_id"],
  );

  Map<String, dynamic> toJson() => {
    "_uri": uri,
    "artist": artist,
    "year": year,
    "is_music": isMusic,
    "title": title,
    "genre_id": genreId,
    "_size": size,
    "duration": duration,
    "is_alarm": isAlarm,
    "_display_name_wo_ext": displayNameWOExt,
    "album_artist": albumArtist,
    "genre": genre,
    "is_notification": isNotification,
    "track": track,
    "_data": data,
    "_display_name": displayName,
    "album": album,
    "composer": composer,
    "is_ringtone": isRingtone,
    "artist_id": artistId,
    "is_podcast": isPodcast,
    "bookmark": bookmark,
    "date_added": dateAdded,
    "is_audiobook": isAudiobook,
    "date_modified": dateModified,
    "album_id": albumId,
    "file_extension": fileExtension,
    "_id": id,
  };
}
