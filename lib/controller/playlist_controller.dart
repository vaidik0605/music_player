import 'package:get/get.dart';
import 'package:music_player/helper/audio_query_helper.dart';
import 'package:music_player/helper/db_helper.dart';

class PlaylistController extends GetxController{
  OfflineAudioQuery offlineAudioQuery = OfflineAudioQuery();
  bool isLoading = false;
  bool isDrawer = false;
  DbHelper dbHelper = DbHelper.instance;
}