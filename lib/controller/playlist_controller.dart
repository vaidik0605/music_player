import 'package:get/get.dart';
import 'package:music_player/helper/audio_query_helper.dart';

class PlaylistController extends GetxController{
  OfflineAudioQuery offlineAudioQuery = OfflineAudioQuery();
  bool isLoading = false;
  bool isDrawer = false;
}