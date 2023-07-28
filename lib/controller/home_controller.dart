import 'package:applovin_max/applovin_max.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/helper/audio_query_helper.dart';
import 'package:music_player/helper/media_item_converter.dart';
import 'package:music_player/main.dart';
import 'package:music_player/model/ad_model.dart';
import 'package:music_player/pages/home_page/home_page.dart';
import 'package:music_player/service/rest_service.dart';
import 'package:music_player/utils/all_logs.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:path_provider/path_provider.dart';

class HomeController extends GetxController{
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
  List<SongModel> songs = [];
  OfflineAudioQuery offlineAudioQuery = OfflineAudioQuery();
  String? tmpPath;
  final Map<String, List<SongModel>> albums = {};
  final List<String> albumsKeyList = [];
  List<MediaItem> shuffleList = [];
  final List<String> artisKeyList = [];
  final List<String> genresKeyList = [];
  final Map<String, List<SongModel>> artists = {};
  final Map<String, List<SongModel>> genres = {};
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
    await offlineAudioQuery.requestPermission();
    tmpPath ??= (await getTemporaryDirectory()).path;
    logs("tmpPath ---> $tmpPath");
    songs = (await offlineAudioQuery.getSongs(
      sortType: songSortTypes[1],
      orderType: songOrderTypes[1],
    )).toList();

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
      shuffleList.add(MediaItemConverter.songModelToMediaItem(element, tmpPath!));
    }
    logs("shuffleList ----> ${shuffleList.length}");
    isLoading = false;
    update();
  }

  Future<void> loadAds() async {
    isLoading = true;
    update();
    Map<String, dynamic>? map = await RestService.getRestMethod();
    if (map != null && map.isNotEmpty) {
      AdModel adModel = AdModel.fromJson(map);
      if (adModel.data != null) {
        logs("AdModel ---> ${adModel.toJson()}");
        showAdOnCount = adModel.data!.intCount ?? 0;
        bannerAdDividerCount = adModel.data!.bannerCount ?? 0;
        bannerUnitId = adModel.data!.maxBanner ?? '';
        interstitialUnitId = adModel.data!.maxInt ?? '';
        appOpenAdId = adModel.data!.appOpen ?? '';
        isShowAds = adModel.data!.adsStatus;
        Map? sdkConfiguration = await AppLovinMAX.initialize(sdkKey);
        if (sdkConfiguration != null && adModel.data!.adsStatus) {
          initializeBannerAds();
          initializeInterstitialAds();
          initializeAppOpenAds();
        }
      }
    }
    await getData();
    isLoading = false;
    update();
  }
}