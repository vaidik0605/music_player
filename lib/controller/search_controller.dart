import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/utils/all_logs.dart';
import 'package:on_audio_query/on_audio_query.dart';

class SearchSongController extends GetxController {
  TextEditingController searchTextController = TextEditingController();
  List<SongModel> songs = [];
  List<SongModel> searchedSongs = [];
  List<String> albumKeyList = [];
  List<String> searchedAlbumKeyList = [];
  Map<String, List<SongModel>> albumList = {};
  List<String> artisKeyList = [];
  List<String> searchedArtistKeyList = [];
  Map<String, List<SongModel>> artistList = {};
  String tmpPath = '';
  bool isLoading = false;

  void onSearchSong(String value) {
    if(value.trim().isNotEmpty){
      isLoading = true;
      update();
      Future.delayed(
        const Duration(milliseconds: 500),
            () {
          searchedSongs = songs
              .where((element) => element.title
              .toLowerCase()
              .trim()
              .contains(value.toLowerCase().trim()))
              .toList();
          searchedArtistKeyList = artisKeyList
              .where((element) => element
              .toLowerCase()
              .trim()
              .contains(value.toLowerCase().trim()))
              .toList();
          searchedAlbumKeyList = albumKeyList
              .where((element) => element
              .toLowerCase()
              .trim()
              .contains(value.toLowerCase().trim()))
              .toList();

          isLoading = false;
          update();
        },
      );
    }else{
      clearSearch();
    }
    logs("searchedSong = ${searchedSongs.length}");
  }

  void clearSearch(){
    searchTextController.clear();
    searchedSongs.clear();
    searchedAlbumKeyList.clear();
    searchedArtistKeyList.clear();
    update();
  }
}
