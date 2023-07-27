import 'package:get/get.dart';
import 'package:music_player/controller/home_controller.dart';
import 'package:on_audio_query/on_audio_query.dart';

class MusicPageController extends GetxController {
  List<SongModel> songList = [];
  String tmpPath = '';
  Map<String, dynamic>? getArg;

  Future<void> sortSongs(
    int sortVal,
    int order,
  ) async {
    switch (sortVal) {
      case 0:
        songList.sort(
          (a, b) => a.displayName.compareTo(b.displayName),
        );
        break;
      case 1:
        songList.sort(
          (a, b) => a.dateAdded.toString().compareTo(b.dateAdded.toString()),
        );
        break;
      case 2:
        songList.sort(
          (a, b) => a.album.toString().compareTo(b.album.toString()),
        );
        break;
      case 3:
        songList.sort(
          (a, b) => a.artist.toString().compareTo(b.artist.toString()),
        );
        break;
      case 4:
        songList.sort(
          (a, b) => a.duration.toString().compareTo(b.duration.toString()),
        );
        break;
      case 5:
        songList.sort(
          (a, b) => a.size.toString().compareTo(b.size.toString()),
        );
        break;
      default:
        songList.sort(
          (a, b) => a.dateAdded.toString().compareTo(b.dateAdded.toString()),
        );
        break;
    }
    if (order == 1) {
      songList = songList.reversed.toList();
    }
    Future.delayed(
      const Duration(milliseconds: 400),
      () {
        update();
      },
    );
  }

  @override
  void onInit() {
    getArg = Get.arguments;
    HomeController homeController = Get.put(HomeController());
    if (getArg != null && getArg!.isNotEmpty) {
      songList = getArg!['songList'];
    } else {
      songList = homeController.songs;
    }

    sortSongs(homeController.selectedSortValue,
        homeController.selectedOrderTypeValue);
    tmpPath = homeController.tmpPath!;
    update();
    super.onInit();
  }
}
