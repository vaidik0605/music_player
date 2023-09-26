import 'dart:convert';
import 'dart:io';
import 'package:music_player/model/my_play_list_model.dart';
import 'package:music_player/model/my_song_model.dart';
import 'package:music_player/utils/all_logs.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DbHelper {
  DbHelper._privateConstructor();

  static final DbHelper instance = DbHelper._privateConstructor();
  static Database? _db;
  static const String _dbName = 'playlist.db';
  static const String _tableName = 'playlist';

  static const String _id = 'id';
  static const String _playListName = 'playlistName';
  static const String _tmpPath = 'tmpPath';
  static const String _playListId = 'playlistId';
  static const String _songs = 'songs';

  Future<Database?> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();
    return _db;
  }

  initDb() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _dbName);
    // await deleteDatabase(path);
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  _onCreate(Database db, int version) async {
    logs("onCreate ->");
    await db.execute(
        "CREATE TABLE $_tableName ($_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, $_playListName TEXT, $_playListId TEXT, $_songs TEXT,$_tmpPath TEXT)");
  }

  createPlayList({required MyPlaylistModel playlistModel}) async {
    var dbClient = await db;
    await dbClient!.insert(_tableName, playlistModel.toJson());
  }

  Future<List<MyPlaylistModel>> getPlayList() async {
    var dbClient = await db;
    List<Map<String, dynamic>> result = await dbClient!.query(_tableName);
    List<MyPlaylistModel> myPlaylistModel = [];
    for (var element in result) {
      logs('playList --> $element');
      List l = jsonDecode(element[_songs]);
      List<MySongModel> tmpSongList =
          List<MySongModel>.from(l.map((x) => MySongModel.fromJson(x)));
      myPlaylistModel.add(
        MyPlaylistModel(
          playlistName: element[_playListName],
          playlistId: element[_playListId],
          songs: tmpSongList,
          tmpPath: element[_tmpPath]
        ),
      );
    }
    return myPlaylistModel;
  }

  Future<MyPlaylistModel> getPlayListSongs({required String playListId}) async {
    var dbClient = await db;
    List<Map<String, dynamic>> result = await dbClient!
        .query(_tableName, where: '$_playListId = ?', whereArgs: [playListId]);
    Map<String, dynamic> element = result.first;
    List l = jsonDecode(element[_songs]);
    List<MySongModel> tmpSongList =
        List<MySongModel>.from(l.map((x) => MySongModel.fromJson(x)));
    MyPlaylistModel myPlaylistModel = MyPlaylistModel(
      playlistName: element[_playListName],
      playlistId: element[_playListId],
      songs: tmpSongList,
    );
    return myPlaylistModel;
  }

  addSongs({required MySongModel songs, required String playListId,required String tmpPath}) async {
    var dbClient = await db;
    MyPlaylistModel result = await getPlayListSongs(playListId: playListId);
    List<Map<dynamic, dynamic>> songList = [];
    for (var element in result.songs) {
      songList.add(element.toJson());
    }
    songList.add(songs.toJson());
    Map<String, dynamic> map = {
      _songs: jsonEncode(songList),
      _playListId: result.playlistId!,
      _playListName: result.playlistName,
      _tmpPath: tmpPath
    };
    await dbClient!.update(_tableName, map,
        where: '$_playListId = ?', whereArgs: [result.playlistId!]);
  }

  deletePlayList({required String playListId}) async {
    var dbClient = await db;
    await dbClient!
        .delete(_tableName, where: '$_playListId = ?', whereArgs: [playListId]);
  }

  removeSongFromPlayList(
      {required MyPlaylistModel playlistModel, required int songId}) async {
    var dbClient = await db;
    playlistModel.songs.removeWhere((element) => element.id == songId);
    List<Map<dynamic, dynamic>> songList = [];
    for (var element in playlistModel.songs) {
      songList.add(element.toJson());
    }
    Map<String, dynamic> map = {
      _songs: jsonEncode(songList),
      _playListId: playlistModel.playlistId!,
      _playListName: playlistModel.playlistName,
      _tmpPath: playlistModel.tmpPath
    };
    await dbClient!.update(_tableName, map,
        where: '$_playListId = ?', whereArgs: [playlistModel.playlistId!]);
  }
}
