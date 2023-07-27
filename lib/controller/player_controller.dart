import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_player/helper/media_item_converter.dart';
import 'package:music_player/pages/home_page/home_page.dart';
import 'package:music_player/utils/all_logs.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

AudioPlayer audioPlayer = AudioPlayer();

class AudioPlayerController extends GetxController {
  RxBool showMiniPlayer = false.obs;
  GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();
  List<MediaItem> mediaItemList = [];
  PanelController panelController = PanelController();
  TextEditingController noOfSongController = TextEditingController();
  ConcatenatingAudioSource audioSource =ConcatenatingAudioSource(children: []);
  Duration pickSleepTime = const Duration(seconds: 0);
  Timer? durationTimer;
  Timer? countTimer;

  Future<void> initializeValue(
      {required int index,
      bool isShuffleEnable = false,
      required List<SongModel> songList,
      required String tmpPath}) async {
    if (songList.isNotEmpty) {
      mediaItemList.clear();
      for (var element in songList) {
        mediaItemList
            .add(MediaItemConverter.songModelToMediaItem(element, tmpPath));
      }
    }
     audioSource = ConcatenatingAudioSource(
      children: List.generate(
        mediaItemList.length,
        (index) => AudioSource.uri(
          Uri.file(mediaItemList[index].extras!['url']),
          tag: mediaItemList[index],
        ),
      ),
    );
    await audioPlayer.setAudioSource(audioSource, initialIndex: index);
    Future.delayed(
      const Duration(milliseconds: 150),
      () async {
        play();
        //audioPlayer.play();
        await audioPlayer.setShuffleModeEnabled(isShuffleEnable);
        showMiniPlayer.value = true;
      },
    );
    update();
  }

  void play() {
    audioPlayer.play();
  }

  void changePlaySequence(int oldIndex,int newIndex){
    MediaItem mediaItem = mediaItemList.removeAt(oldIndex);
    mediaItemList.insert(newIndex, mediaItem);
    audioSource.move(oldIndex, newIndex);
    update();
  }

  void pause() {
    audioPlayer.pause();
  }

  void playNext() {
    audioPlayer.seekToNext();
    adIntersTitiaCount++;
    showInterstitialAd();
  }

  void playPrevious() {
    audioPlayer.seekToPrevious();
    adIntersTitiaCount++;
    showInterstitialAd();
  }

  void setVolume(double volume) {
    audioPlayer.setVolume(volume);
  }

  void setSeek(Duration duration) {
    audioPlayer.seek(duration);
  }

  void setSleepTimer(Duration initialTimer) {
    if (durationTimer != null) {
      durationTimer!.cancel();
    }
    if (countTimer != null) {
      countTimer!.cancel();
    }
    const oneSec = Duration(seconds: 1);
    var startTime = initialTimer.inSeconds;
    durationTimer = Timer.periodic(oneSec, (timer) {
      logs("start time ---> $startTime");
      if (startTime == 0) {
        timer.cancel();
        if (audioPlayer.playerState.processingState !=
            ProcessingState.completed) {
          pause();
        }
      } else {
        startTime--;
      }
    });
  }

  void setSleepCount(int count) {
    int startInt = 0;
    if (countTimer != null) {
      countTimer!.cancel();
    }
    if (durationTimer != null) {
      durationTimer!.cancel();
    }
    countTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      Duration duration = audioPlayer.duration ?? Duration.zero;
      Duration position = audioPlayer.position;

      logs("position ${position.inSeconds} : Duration ${duration.inSeconds}");
      if (startInt == count) {
        timer.cancel();
        pause();
      } else if (duration.inSeconds == position.inSeconds) {
        startInt++;
      }
    });
    //int startCount = 0;
  }
}
