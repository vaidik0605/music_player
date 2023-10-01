import 'package:applovin_max/applovin_max.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/helper/audio_query_helper.dart';
import 'package:music_player/helper/media_item_converter.dart';
import 'package:music_player/main.dart';
import 'package:music_player/model/ad_model.dart';
import 'package:music_player/model/my_song_model.dart';
import 'package:music_player/pages/home_page/home_page.dart';
import 'package:music_player/service/ad_service.dart';
import 'package:music_player/service/rest_service.dart';
import 'package:music_player/utils/all_logs.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:path_provider/path_provider.dart';

class HomeController extends GetxController {
  final ValueNotifier<int> selectedIndex = ValueNotifier<int>(0);
  final PageController pageController = PageController();
  final ScrollController scrollController = ScrollController();

  RxString name = 'Guest'.obs;
  int selectedSortValue = 1;
  int selectedOrderTypeValue = 1;

  void onItemTapped(int index) {
    selectedIndex.value = index;
    pageController.jumpToPage(
      index,
    );
  }

  List<MySongModel> songs = [];
  OfflineAudioQuery offlineAudioQuery = OfflineAudioQuery();
  String? tmpPath;
  final Map<String, List<MySongModel>> albums = {};
  final List<String> albumsKeyList = [];
  List<MediaItem> shuffleList = [];
  final List<String> artisKeyList = [];
  final List<String> genresKeyList = [];
  final Map<String, List<MySongModel>> artists = {};
  final Map<String, List<MySongModel>> genres = {};
  bool isLoading = false;
  final Map<int, SongSortType> songSortTypes = {
    0: SongSortType.DISPLAY_NAME,
    1: SongSortType.DATE_ADDED,
    2: SongSortType.ALBUM,
    3: SongSortType.ARTIST,
    4: SongSortType.DURATION,
    5: SongSortType.SIZE,
  };
  final Map<int, OrderType> songOrderTypes = {
    0: OrderType.ASC_OR_SMALLER,
    1: OrderType.DESC_OR_GREATER,
  };

  Future<void> getData() async {
    isLoading = true;
    update();
    bool status = await offlineAudioQuery.requestPermission();
    if (status) {
      tmpPath ??= (await getTemporaryDirectory()).path;
      logs("tmpPath ---> $tmpPath");
      List<SongModel> tmpSong = (await offlineAudioQuery.getSongs(
        sortType: songSortTypes[1],
        orderType: songOrderTypes[1],
      ))
          .toList();
      for (var element in tmpSong) {
        MySongModel songModel = MySongModel.fromJson(element.getMap);
        songs.add(songModel);
      }

      for (int i = 0; i < songs.length; i++) {
        try {
          if (albums.containsKey(songs[i].album ?? 'Unknown')) {
            albums[songs[i].album ?? 'Unknown']!.add(songs[i]);
          } else {
            albums[songs[i].album ?? 'Unknown'] = [songs[i]];
            albumsKeyList.add(songs[i].album ?? 'Unknown');
          }

          if (artists.containsKey(songs[i].artist ?? 'Unknown')) {
            artists[songs[i].artist ?? 'Unknown']!.add(songs[i]);
          } else {
            artists[songs[i].artist ?? 'Unknown'] = [songs[i]];
            artisKeyList.add(songs[i].artist ?? 'Unknown');
          }

          if (genres.containsKey(songs[i].genre ?? 'Unknown')) {
            genres[songs[i].genre ?? 'Unknown']!.add(songs[i]);
          } else {
            genres[songs[i].genre ?? 'Unknown'] = [songs[i]];
            genresKeyList.add(songs[i].genre ?? 'Unknown');
          }
        } catch (e) {
          logs('Catch exception in --> ${e.toString()}');
        }
      }
      logs("albums --> ${albums.length}");
      logs("artists --> ${artists.length}");
      logs("genres --> ${genres.length}");
      for (var element in songs) {
        shuffleList
            .add(MediaItemConverter.songModelToMediaItem(element, tmpPath!));
      }
    }
    logs("shuffleList ----> ${shuffleList.length}");
    isLoading = false;
    update();
  }

  Future<void> loadAds() async {
    isLoading = true;
    update();
    await getData();
    Map<String, dynamic>? map = await RestService.getRestMethod();
    if (map != null && map.isNotEmpty) {
      adModel = AdModel(data: null, success: false, message: null);
      adModel = AdModel.fromJson(map);
      if (adModel.data != null && adModel.data!.adsStatus) {
        // AdService.createInterstitialAd();
        AdService.createGoogleInterstitialAd();
        Map<dynamic, dynamic>? sdkConfiguration =
            await AppLovinMAX.initialize(sdkKey);
        if (sdkConfiguration != null) {}
      }
    }
    isLoading = false;
    update();
  }
}
