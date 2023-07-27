import 'package:get/get.dart';
import 'package:music_player/components/audio_player.dart';
import 'package:music_player/pages/about_page/about_page.dart';
import 'package:music_player/pages/album_page/album_page.dart';
import 'package:music_player/pages/artist_page/artist_page.dart';
import 'package:music_player/pages/home_page/home_page.dart';
import 'package:music_player/pages/music_page/music_page.dart';
import 'package:music_player/pages/play_list_song_page/play_list_song_page.dart';
import 'package:music_player/pages/playlist_page/playlist_page.dart';
import 'package:music_player/pages/search_page/search_page.dart';
import 'package:music_player/routes/route_constant.dart';

class RouteHelper {
  static String homePageRoute() => RouteConstant.homeRoute;
  static String musicPlayerRoute() => RouteConstant.audioPlayerRoute;
  static String searchRoute() => RouteConstant.searchRoute;
  static String musicRoute() => RouteConstant.musicRoute;
  static String playListSongRoute() => RouteConstant.playlistSongRoute;
  static String albumRoute() => RouteConstant.albumRoute;
  static String artistRoute() => RouteConstant.artistRoute;
  static String playListRoute() => RouteConstant.playListRoute;
  static String aboutRoute() => RouteConstant.aboutRoute;

  static List<GetPage> routes = [
    GetPage(
      name: RouteConstant.homeRoute,
      page: () => const HomePage(),
    ),
    GetPage(
      name: RouteConstant.audioPlayerRoute,
      page: () => const AudioPlayerPage(),
    ),
    GetPage(
      name: RouteConstant.searchRoute,
      page: () => const SearchPage(),
    ),
    GetPage(
      name: RouteConstant.musicRoute,
      page: () => const MusicPage(),
    ),
    GetPage(
      name: RouteConstant.playlistSongRoute,
      page: () => const PlaylistSongPage(),
    ), GetPage(
      name: RouteConstant.albumRoute,
      page: () => const AlbumPage(),
    ), GetPage(
      name: RouteConstant.artistRoute,
      page: () => const ArtistPage(),
    ), GetPage(
      name: RouteConstant.playListRoute,
      page: () => const PlaylistPage(),
    ), GetPage(
      name: RouteConstant.aboutRoute,
      page: () => const AboutPage(),
    ),
  ];
}
