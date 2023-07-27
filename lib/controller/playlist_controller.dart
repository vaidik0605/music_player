import 'package:get/get.dart';
import 'package:music_player/helper/audio_query_helper.dart';
import 'package:on_audio_query/on_audio_query.dart';

class PlaylistController extends GetxController{
  OfflineAudioQuery offlineAudioQuery = OfflineAudioQuery();
  bool isLoading = false;
  bool isDrawer = false;
  List<PlaylistModel> playlistDetails = [];
  Future<void> getPlayList() async {
    setLoading(true);
    playlistDetails = await offlineAudioQuery.getPlaylists();
    setLoading(false);
  }

  void setLoading(bool loading){
    isLoading = loading;
    update();
  }
  Future<void> deletePlayList(int index) async {
    await offlineAudioQuery.removePlaylist(playlistId: playlistDetails[index].id);
    playlistDetails.removeAt(index);
    update();
  }
  Future<void> createPlayList(String name) async{
    await offlineAudioQuery.createPlaylist(name: name);
    await getPlayList();
    update();
  }
}