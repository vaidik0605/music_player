import 'dart:developer';
import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_player/components/animated_text.dart';
import 'package:music_player/components/app_image_assets.dart';
import 'package:music_player/components/app_text.dart';
import 'package:music_player/components/app_toast.dart';
import 'package:music_player/components/popup_dialog.dart';
import 'package:music_player/components/seek_bar.dart';
import 'package:music_player/constants/asset_constant.dart';
import 'package:music_player/constants/color_constant.dart';
import 'package:music_player/constants/string_constant.dart';
import 'package:music_player/controller/player_controller.dart';
import 'package:music_player/helper/media_item_converter.dart';
import 'package:music_player/routes/route_constant.dart';
import 'package:music_player/utils/all_logs.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:rxdart/rxdart.dart' as rx_dart;
import 'dart:ui' as ui;

import 'package:sliding_up_panel/sliding_up_panel.dart';

class AudioPlayerPage extends StatelessWidget {
  const AudioPlayerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: AudioPlayerController(),
      builder: (AudioPlayerController controller) {
        return Dismissible(
          key: const Key('PlayerScreen'),
          direction: DismissDirection.down,
          onDismissed: (direction) {
            Get.back();
          },
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              centerTitle: true,
              leading: IconButton(
                color: ColorConstant.white,
                icon: const Icon(Icons.expand_more_rounded),
                tooltip: AppStringConstant.back,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              actions: [
                IconButton(
                  color: ColorConstant.white,
                  icon: const Icon(Icons.lyrics_rounded),
                  tooltip: AppStringConstant.lyrics,
                  onPressed: () =>
                      controller.cardKey.currentState!.toggleCard(),
                ),
                StreamBuilder<int?>(
                    stream: audioPlayer.currentIndexStream,
                    builder: (context, snapshot) {
                      int currentIndex = snapshot.data ?? 0;
                      return PopupMenuButton(
                          icon: const Icon(
                            Icons.more_vert_rounded,
                            color: ColorConstant.white,
                          ),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(15.0),
                            ),
                          ),
                          onSelected: (int? value) {
                            if (value == 1) {
                              sleepTimerDialog(context, controller);
                            }
                            if (value == 2) {
                              final mediaItem =
                                  controller.mediaItemList[currentIndex];
                              final details =
                                  MediaItemConverter.mediaItemToMap(mediaItem);
                              details['duration'] =
                                  '${int.parse(details["duration"].toString()) ~/ 60}:${int.parse(details["duration"].toString()) % 60}';
                              if (mediaItem.extras?['size'] != null) {
                                details.addEntries([
                                  MapEntry(
                                    'date_modified',
                                    DateTime.fromMillisecondsSinceEpoch(
                                      int.parse(
                                            mediaItem.extras!['date_modified']
                                                .toString(),
                                          ) *
                                          1000,
                                    ).toString().split('.').first,
                                  ),
                                  MapEntry(
                                    'size',
                                    '${((mediaItem.extras!['size'] as int) / (1024 * 1024)).toStringAsFixed(2)} MB',
                                  ),
                                ]);
                              }
                              PopupDialog.showPopup(
                                  context: context,
                                  closeButtonColor: ColorConstant.grey900,
                                  child: Container(
                                    color: ColorConstant.grey900,
                                    child: SingleChildScrollView(
                                      padding: EdgeInsets.all(10.px),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: details.keys
                                            .map((e) => SelectableText.rich(
                                                  TextSpan(
                                                    children: <TextSpan>[
                                                      TextSpan(
                                                        text: format(
                                                          e.toString(),
                                                        ),
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: ColorConstant
                                                              .white,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text: details[e]
                                                            .toString(),
                                                        style: const TextStyle(
                                                          color: ColorConstant
                                                              .white,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  showCursor: true,
                                                  cursorColor:
                                                      ColorConstant.white,
                                                  cursorRadius:
                                                      const Radius.circular(5),
                                                ))
                                            .toList(),
                                      ),
                                    ),
                                  ));
                            }
                          },
                          itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 1,
                                  child: Row(
                                    children: [
                                      Icon(
                                        CupertinoIcons.timer,
                                        color:
                                            Theme.of(context).iconTheme.color,
                                      ),
                                      SizedBox(width: 10.0.px),
                                      const AppText(
                                        title: AppStringConstant.sleepTimer,
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 2,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.info_rounded,
                                        color:
                                            Theme.of(context).iconTheme.color,
                                      ),
                                      SizedBox(width: 10.0.px),
                                      const AppText(
                                          title: AppStringConstant.songInfo),
                                    ],
                                  ),
                                ),
                              ]);
                    })
              ],
            ),
            body: Stack(
              children: [
                Column(
                  children: [
                    const ArtWorkWidget(),
                    NameAndControlButtons(playerController: controller),
                  ],
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: SlidingUpPanel(
                    minHeight: 60.px,
                    maxHeight: 350.px,
                    slideDirection: SlideDirection.UP,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15.0),
                      topRight: Radius.circular(15.0),
                    ),
                    margin: EdgeInsets.zero,
                    padding: EdgeInsets.zero,
                    boxShadow: const [],
                    color: const Color.fromRGBO(0, 0, 0, 0.05),
                    controller: controller.panelController,
                    panelBuilder: (ScrollController scrollController) {
                      return ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15.px),
                          topRight: Radius.circular(15.px),
                        ),
                        child: BackdropFilter(
                          filter:
                              ui.ImageFilter.blur(sigmaX: 8.px, sigmaY: 8.px),
                          child: ShaderMask(
                            shaderCallback: (bounds) {
                              return const LinearGradient(
                                end: Alignment.topCenter,
                                begin: Alignment.center,
                                colors: [
                                  ColorConstant.black,
                                  ColorConstant.black,
                                  ColorConstant.black,
                                  Colors.transparent,
                                  Colors.transparent,
                                ],
                              ).createShader(Rect.fromLTRB(
                                  0, 0, bounds.width, bounds.height));
                            },
                            blendMode: BlendMode.dstIn,
                            child: AudioList(
                                panelController: controller.panelController,
                                scrollController: scrollController),
                          ),
                        ),
                      );
                    },
                    header: GestureDetector(
                      onTap: () {
                        if (controller.panelController.isPanelOpen) {
                          controller.panelController.close();
                        } else {
                          if (controller.panelController.panelPosition > 0.9) {
                            controller.panelController.close();
                          } else {
                            controller.panelController.open();
                          }
                        }
                      },
                      onVerticalDragUpdate: (DragUpdateDetails details) {
                        if (details.delta.dy > 0.0) {
                          controller.panelController
                              .animatePanelToPosition(0.0);
                        }
                      },
                      child: SizedBox(
                        height: 70.px,
                        width: Device.width,
                        child: Align(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 5.px,
                              ),
                              Center(
                                child: Container(
                                  width: 30.px,
                                  height: 5.px,
                                  decoration: BoxDecoration(
                                    color: ColorConstant.grey300,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  alignment: Alignment.center,
                                  color: Colors.transparent,
                                  child: AppText(
                                    title: AppStringConstant.upNext,
                                    textAlign: TextAlign.center,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18.px,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ArtWorkWidget extends StatefulWidget {
  const ArtWorkWidget({super.key});

  @override
  State<ArtWorkWidget> createState() => _ArtWorkWidgetState();
}

class _ArtWorkWidgetState extends State<ArtWorkWidget> {
  final ValueNotifier<bool> dragging = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AudioPlayerController>(
      init: AudioPlayerController(),
      builder: (controller) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: SizedBox(
            height: Device.width * 0.85.px,
            width: Device.width * 0.85.px,
            child: FlipCard(
              flipOnTouch: false,
              key: controller.cardKey,
              front: GestureDetector(
                onHorizontalDragEnd: (details) {
                  if ((details.primaryVelocity ?? 0) > 100) {
                    controller.playPrevious();
                  }
                  if ((details.primaryVelocity ?? 0) < -100) {
                    controller.playNext();
                  }
                },
                onVerticalDragStart: (details) {
                  dragging.value = true;
                },
                onVerticalDragEnd: (details) {
                  dragging.value = false;
                },
                onVerticalDragUpdate: (details) {
                  if (details.delta.dy != 0.0) {
                    double volume = audioPlayer.volume;
                    volume -= details.delta.dy / 150;
                    if (volume < 0) {
                      volume = 0;
                    }
                    if (volume > 1.0) {
                      volume = 1.0;
                    }
                    controller.setVolume(volume);
                  }
                },
                onDoubleTap: () =>
                    controller.cardKey.currentState!.toggleCard(),
                child: Stack(
                  children: [
                    StreamBuilder<int?>(
                        stream: audioPlayer.currentIndexStream,
                        builder: (context, snapshot) {
                          int currentIndex = snapshot.data ?? 0;
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(15.0),
                            child: Hero(
                              tag: 'artWork',
                              child: Image(
                                fit: BoxFit.contain,
                                width: Device.width * 0.85,
                                gaplessPlayback: true,
                                errorBuilder: (
                                  BuildContext context,
                                  Object exception,
                                  StackTrace? stackTrace,
                                ) {
                                  return const Image(
                                    fit: BoxFit.cover,
                                    image: AssetImage(AssetConstant.coverImage),
                                  );
                                },
                                image: FileImage(
                                  File(
                                    controller
                                        .mediaItemList[currentIndex].artUri!
                                        .toFilePath(),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                    ValueListenableBuilder(
                      valueListenable: dragging,
                      child: StreamBuilder<double>(
                        stream: audioPlayer.volumeStream,
                        builder: (context, snapshot) {
                          final double volumeValue = snapshot.data ?? 1.0;
                          return Center(
                            child: SizedBox(
                              width: 60.0,
                              height: Device.width * 0.7,
                              child: Card(
                                color: ColorConstant.black87,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Expanded(
                                      child: FittedBox(
                                        fit: BoxFit.fitHeight,
                                        child: RotatedBox(
                                          quarterTurns: -1,
                                          child: SliderTheme(
                                            data: SliderTheme.of(context)
                                                .copyWith(
                                              thumbShape:
                                                  HiddenThumbComponentShape(),
                                              activeTrackColor:
                                                  Theme.of(context)
                                                      .colorScheme
                                                      .secondary,
                                              inactiveTrackColor:
                                                  Theme.of(context)
                                                      .colorScheme
                                                      .secondary
                                                      .withOpacity(0.4),
                                              trackShape:
                                                  const RoundedRectSliderTrackShape(),
                                            ),
                                            child: ExcludeSemantics(
                                              child: Slider(
                                                value: audioPlayer.volume,
                                                onChanged: (_) {},
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 20.0,
                                      ),
                                      child: Icon(
                                        volumeValue == 0
                                            ? Icons.volume_off_rounded
                                            : volumeValue > 0.6
                                                ? Icons.volume_up_rounded
                                                : Icons.volume_down_rounded,
                                        color: ColorConstant.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      builder: (
                        BuildContext context,
                        bool value,
                        Widget? child,
                      ) {
                        return Visibility(
                          visible: value,
                          child: child!,
                        );
                      },
                    ),
                  ],
                ),
              ),
              back: GestureDetector(
                  onTap: () => controller.cardKey.currentState!.toggleCard(),
                  child:
                      const Center(child: AppText(title: 'Flip background'))),
            ),
          ),
        );
      },
    );
  }
}

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});
  @override
  Widget build(BuildContext context) {
    return GetBuilder<AudioPlayerController>(
      init: AudioPlayerController(),
      builder: (controller) {
        return Obx(() => (controller.showMiniPlayer.value)
            ? Dismissible(
                key: const Key('miniPlayer'),
                direction: DismissDirection.down,
                confirmDismiss: (direction) async {
                  audioPlayer.stop();
                  controller.showMiniPlayer.value = false;
                  return true;
                },
                child: StreamBuilder<int?>(
                    stream: audioPlayer.currentIndexStream,
                    builder: (context, snapshot) {
                      int currentIndex = snapshot.data ?? 0;
                      return Dismissible(
                        key: Key(controller.mediaItemList[currentIndex].id),
                        confirmDismiss: (direction) {
                          if (direction == DismissDirection.startToEnd) {
                            controller.playPrevious();
                          } else {
                            controller.playNext();
                          }
                          return Future.value(false);
                        },
                        child: GestureDetector(
                          onTap: () =>
                              Get.toNamed(RouteConstant.audioPlayerRoute),
                          child: Card(
                            color: ColorConstant.grey900,
                            margin: EdgeInsets.symmetric(
                              horizontal: 2.0.px,
                              vertical: 1.0.px,
                            ),
                            child: SizedBox(
                              height: 76.px,
                              child: Column(
                                children: [
                                  ListTile(
                                    leading: Hero(
                                        tag: 'artWork',
                                        child: Card(
                                          elevation: 8,
                                          color: ColorConstant.black,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(7.0),
                                          ),
                                          clipBehavior: Clip.antiAlias,
                                          child: SizedBox.square(
                                            dimension: 50.px,
                                            child: Image(
                                              fit: BoxFit.cover,
                                              errorBuilder: (
                                                BuildContext context,
                                                Object exception,
                                                StackTrace? stackTrace,
                                              ) {
                                                return const Image(
                                                  fit: BoxFit.cover,
                                                  image: AssetImage(
                                                      AssetConstant.coverImage),
                                                );
                                              },
                                              image: FileImage(
                                                File(
                                                  controller
                                                      .mediaItemList[audioPlayer
                                                              .currentIndex ??
                                                          0]
                                                      .artUri!
                                                      .toFilePath(),
                                                ),
                                              ),
                                            ),
                                          ),
                                        )),
                                    title: AppText(
                                      title: controller
                                          .mediaItemList[
                                              audioPlayer.currentIndex ?? 0]
                                          .title,
                                      maxLines: 1,
                                      textOverflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: AppText(
                                      title: controller
                                              .mediaItemList[
                                                  audioPlayer.currentIndex ?? 0]
                                              .artist ??
                                          '',
                                      maxLines: 1,
                                      textOverflow: TextOverflow.ellipsis,
                                    ),
                                    trailing:
                                        const ControlButtons(miniPlayer: true),
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 5.px),
                                    child: StreamBuilder<Duration?>(
                                      stream: audioPlayer.durationStream,
                                      builder: (context, snapshot) {
                                        final duration = snapshot.data;
                                        return StreamBuilder<Duration>(
                                          stream: audioPlayer.positionStream,
                                          builder: (context, snapshot) {
                                            final position = snapshot.data;
                                            return position == null ||
                                                    duration == null
                                                ? const SizedBox()
                                                : (position.inSeconds
                                                                .toDouble() <
                                                            0.0 ||
                                                        (position.inSeconds
                                                                .toDouble() >
                                                            duration.inSeconds
                                                                .toDouble()))
                                                    ? const SizedBox()
                                                    : SliderTheme(
                                                        data: SliderTheme.of(
                                                                context)
                                                            .copyWith(
                                                          activeTrackColor:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .secondary,
                                                          inactiveTrackColor:
                                                              Colors
                                                                  .transparent,
                                                          trackHeight: 0.5,
                                                          thumbColor:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .secondary,
                                                          thumbShape:
                                                              const RoundSliderThumbShape(
                                                            enabledThumbRadius:
                                                                1.0,
                                                          ),
                                                          overlayColor: Colors
                                                              .transparent,
                                                          overlayShape:
                                                              const RoundSliderOverlayShape(
                                                            overlayRadius: 2.0,
                                                          ),
                                                        ),
                                                        child: Center(
                                                          child: Slider(
                                                            inactiveColor: Colors
                                                                .transparent,
                                                            value: position
                                                                .inSeconds
                                                                .toDouble(),
                                                            max: duration
                                                                .inSeconds
                                                                .toDouble(),
                                                            onChanged:
                                                                (newPosition) {
                                                              controller
                                                                  .setSeek(
                                                                Duration(
                                                                  seconds:
                                                                      newPosition
                                                                          .round(),
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      );
                                          },
                                        );
                                      },
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }))
            : const SizedBox());
      },
    );
  }
}

class NameAndControlButtons extends StatelessWidget {
  final AudioPlayerController playerController;

  const NameAndControlButtons({super.key, required this.playerController});

  Stream<Duration?> get _bufferPositionStream =>
      audioPlayer.bufferedPositionStream.distinct();

  Stream<Duration?> get _durationStream =>
      audioPlayer.durationStream.distinct();

  Stream<PositionData> get positionDataStream =>
      rx_dart.Rx.combineLatest3<Duration, Duration?, Duration?, PositionData>(
        audioPlayer.positionStream,
        _bufferPositionStream,
        _durationStream,
        (position, bufferedPosition, duration) => PositionData(position,
            bufferedPosition ?? Duration.zero, duration ?? Duration.zero),
      );

  @override
  Widget build(BuildContext context) {
    final double width = Device.width;
    return SizedBox(
      width: width,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              StreamBuilder<int?>(
                  stream: audioPlayer.currentIndexStream,
                  builder: (context, snapshot) {
                    int currentIndex = snapshot.data ?? 0;
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.px),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(height: 40.px),
                            SizedBox(
                              height: 90.px,
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  AnimatedText(
                                    text: playerController
                                        .mediaItemList[currentIndex].title
                                        .split(' (')[0]
                                        .split('|')[0]
                                        .trim(),
                                    pauseAfterRound: const Duration(seconds: 3),
                                    showFadingOnlyWhenScrolling: false,
                                    fadingEdgeEndFraction: 0.1,
                                    fadingEdgeStartFraction: 0.1,
                                    startAfter: const Duration(seconds: 2),
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  AnimatedText(
                                    text:
                                        '${playerController.mediaItemList[currentIndex].artist ?? "Unknown"} • ${playerController.mediaItemList[currentIndex].album ?? "Unknown"}',
                                    pauseAfterRound: const Duration(seconds: 3),
                                    showFadingOnlyWhenScrolling: false,
                                    fadingEdgeEndFraction: 0.1,
                                    fadingEdgeStartFraction: 0.1,
                                    startAfter: const Duration(seconds: 2),
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20.px),
                          ],
                        ),
                      ),
                    );
                  }),
              StreamBuilder<int?>(
                  stream: audioPlayer.currentIndexStream,
                  builder: (context, snapshot) {
                    int currentIndex = snapshot.data ?? 0;
                    return SizedBox(
                      width: width * 0.95.px,
                      child: StreamBuilder<PositionData>(
                        stream: positionDataStream,
                        builder: (context, snapshot) {
                          final positionData = snapshot.data ??
                              PositionData(
                                  Duration.zero,
                                  Duration.zero,
                                  playerController.mediaItemList[currentIndex]
                                          .duration ??
                                      Duration.zero);
                          return SeekBar(
                            duration: positionData.duration,
                            bufferedPosition: positionData.bufferedPosition,
                            position: positionData.position,
                            onChangeEnd: (value) =>
                                playerController.setSeek(value),
                          );
                        },
                      ),
                    );
                  }),
              const ControlButtons(),
            ],
          ),
        ],
      ),
    );
  }
}

class AudioList extends StatelessWidget {
  final PanelController? panelController;
  final ScrollController? scrollController;

  const AudioList({super.key, this.panelController, this.scrollController});

  void _updateScrollController(
    ScrollController? scrollController,
    int itemIndex,
    int queuePosition,
    int queueLength,
  ) {
    if (panelController != null && !panelController!.isPanelOpen) {
      if (queuePosition > 3) {
        scrollController?.animateTo(
          itemIndex * 72 + 12,
          curve: Curves.linear,
          duration: const Duration(
            milliseconds: 350,
          ),
        );
      } else if (queuePosition < 4 && queueLength > 4) {
        scrollController?.animateTo(
          (queueLength - 4) * 72 + 12,
          curve: Curves.linear,
          duration: const Duration(
            milliseconds: 350,
          ),
        );
      }
    }
    return;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AudioPlayerController>(
      init: AudioPlayerController(),
      builder: (controller) {
        return StreamBuilder<SequenceState?>(
          stream: audioPlayer.sequenceStateStream,
          builder: (context, snapshot) {
            if(!snapshot.hasData || snapshot.data == null){
              return const SizedBox();
            }
            final sequenceState = snapshot.data!;
            final int currentIndex = sequenceState.currentIndex;
            final num questionPosition = sequenceState.sequence.length - currentIndex;
            List<MediaItem> mediaItemList = [];
            for (var element in sequenceState.sequence) {
              mediaItemList.add(element.tag);
            }
            WidgetsBinding.instance.addPostFrameCallback(
                  (_) => _updateScrollController(
                scrollController,
                sequenceState.currentIndex,
                questionPosition.toInt(),
                mediaItemList.length,
              ),
            );
            return ReorderableListView.builder(
              scrollController: scrollController,
              shrinkWrap: true,
              itemCount: mediaItemList.length,
              header: SizedBox(height: 60.px),
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(bottom: 10.px),
              onReorder: (oldIndex, newIndex) {
                if (oldIndex < newIndex) {
                  newIndex--;
                }
                controller.changePlaySequence(oldIndex, newIndex);
              },
              itemBuilder: (context, index) {
                return Dismissible(
                  onDismissed: (direction) {
                    controller.mediaItemList.removeAt(index);
                    controller.audioSource.removeAt(index);
                    controller.update();
                  },
                  key: Key(mediaItemList[index].id),
                  direction: (index == sequenceState.currentIndex)
                      ? DismissDirection.none
                      : DismissDirection.horizontal,
                  child: ListTileTheme(
                    selectedColor: ColorConstant.black,
                    child: ListTile(
                      selected: index == sequenceState.currentIndex,
                      onTap: () {
                        audioPlayer.seek(Duration.zero,index: index);
                        _updateScrollController( scrollController,
                          sequenceState.currentIndex,
                          questionPosition.toInt(),
                          mediaItemList.length);
                      },
                      contentPadding:
                      EdgeInsets.only(left: 16.px, right: 10.px),
                      leading: Card(
                        elevation: 5,
                        color: ColorConstant.black,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7.px)),
                        clipBehavior: Clip.antiAlias,
                        child: (mediaItemList[index].artUri == null)
                            ? SizedBox.square(
                          dimension: 50.px,
                          child: const AppImageAsset(
                              image: AssetConstant.coverImage),
                        )
                            : SizedBox.square(
                          dimension: 50.px,
                          child: Image(
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              logs("error ---> $error");
                              return const AppImageAsset(
                                fit: BoxFit.cover,
                                image: AssetConstant.coverImage,
                              );
                            },
                            image: FileImage(
                              File(mediaItemList[index].artUri!.toFilePath()),
                            ),
                          ),
                        ),
                      ),
                      title: AppText(
                          title: mediaItemList[index].title,
                          textOverflow: TextOverflow.ellipsis,
                          fontColor: (sequenceState.currentIndex == index)
                              ? Theme.of(context).colorScheme.secondary
                              : ColorConstant.white,
                          fontWeight: (sequenceState.currentIndex == index)
                              ? FontWeight.w600
                              : FontWeight.normal),
                      subtitle: AppText(
                        title: '${mediaItemList[index].artist}',
                        fontColor: (sequenceState.currentIndex == index)
                            ? Theme.of(context).colorScheme.secondary
                            : ColorConstant.white,
                      ),
                      trailing: (index == sequenceState.currentIndex)
                          ? IconButton(
                        icon: Icon(
                          Icons.bar_chart_rounded,
                          color:
                          Theme.of(context).colorScheme.secondary,
                        ),
                        tooltip: AppStringConstant.playing,
                        onPressed: () {},
                      )
                          : ReorderableDragStartListener(
                        key: Key(mediaItemList[index].id),
                        index: index,
                        enabled: index != sequenceState.currentIndex,
                        child: const Icon(
                          Icons.drag_handle_rounded,
                          color: ColorConstant.white,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }
        );
      },
    );
  }
}

class ControlButtons extends StatelessWidget {
  final bool shuffle;
  final bool miniPlayer;

  const ControlButtons({
    super.key,
    this.shuffle = true,
    this.miniPlayer = false,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AudioPlayerController>(
      init: AudioPlayerController(),
      builder: (controller) {
        return StreamBuilder<int?>(
            stream: audioPlayer.currentIndexStream,
            builder: (context, snapshot) {
              int currentIndex = snapshot.data ?? 0;
              return StreamBuilder<LoopMode?>(
                  stream: audioPlayer.loopModeStream,
                  builder: (context, snapshot) {
                    final loopMode = snapshot.data ?? LoopMode.off;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!miniPlayer)
                          StreamBuilder<bool>(
                              stream: audioPlayer.shuffleModeEnabledStream,
                              builder: (context, snapshot) {
                                final bool isShuffleEnable =
                                    snapshot.data ?? false;
                                return IconButton(
                                    tooltip: 'Shuffle',
                                    onPressed: () async {
                                      final enable = !isShuffleEnable;
                                      await audioPlayer
                                          .setShuffleModeEnabled(enable);
                                    },
                                    icon: Icon(
                                      Icons.shuffle_rounded,
                                      color: (isShuffleEnable)
                                          ? ColorConstant.white
                                          : ColorConstant.disableColor,
                                    ));
                              }),
                        if (!miniPlayer)
                          StreamBuilder<bool?>(
                              stream: audioPlayer.shuffleModeEnabledStream,
                              builder: (context, snapshot) {
                                final isShuffleEnable = snapshot.data ?? false;
                                return IgnorePointer(
                                  ignoring: (currentIndex == 0 &&
                                              loopMode == LoopMode.off ||
                                          isShuffleEnable)
                                      ? true
                                      : false,
                                  child: IconButton(
                                    icon:
                                        const Icon(Icons.skip_previous_rounded),
                                    iconSize: (miniPlayer) ? 24.0.px : 45.px,
                                    tooltip: AppStringConstant.skipPrevious,
                                    color: (currentIndex == 0 &&
                                                loopMode == LoopMode.off ||
                                            isShuffleEnable)
                                        ? ColorConstant.disableColor
                                        : Theme.of(context).primaryColor,
                                    onPressed: () => controller.playPrevious(),
                                  ),
                                );
                              }),
                        StreamBuilder<PlayerState>(
                          stream: audioPlayer.playerStateStream,
                          builder: (context, snapshot) {
                            final playerSate = snapshot.data;
                            final processingState = playerSate?.processingState;
                            bool? isPlaying = playerSate?.playing;
                            log("isPlaying ---> $isPlaying");
                            log("processingState ---> $processingState");
                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                if (processingState ==
                                        ProcessingState.loading ||
                                    processingState ==
                                        ProcessingState.buffering)
                                  if (processingState ==
                                      ProcessingState.completed)
                                    Center(
                                      child: SizedBox(
                                        height: miniPlayer ? 40.0 : 65.0,
                                        width: miniPlayer ? 40.0 : 65.0,
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            Theme.of(context).iconTheme.color!,
                                          ),
                                        ),
                                      ),
                                    ),
                                if (miniPlayer)
                                  Center(
                                    child: isPlaying != null &&
                                            isPlaying &&
                                            processingState !=
                                                ProcessingState.completed
                                        ? IconButton(
                                            tooltip: AppStringConstant.pause,
                                            onPressed: () => controller.pause(),
                                            icon: const Icon(
                                              Icons.pause_rounded,
                                            ),
                                            color: Theme.of(context)
                                                .iconTheme
                                                .color,
                                          )
                                        : IconButton(
                                            tooltip: AppStringConstant.play,
                                            onPressed: () => controller.play(),
                                            icon: const Icon(
                                              Icons.play_arrow_rounded,
                                            ),
                                            color: Theme.of(context)
                                                .iconTheme
                                                .color,
                                          ),
                                  )
                                else
                                  Center(
                                    child: SizedBox(
                                      height: 59.px,
                                      width: 59.px,
                                      child: Center(
                                        child: isPlaying != null &&
                                                isPlaying &&
                                                processingState !=
                                                    ProcessingState.completed
                                            ? FloatingActionButton(
                                                shape: const CircleBorder(),
                                                elevation: 10,
                                                tooltip: AppStringConstant.pause,
                                                backgroundColor:
                                                    ColorConstant.white,
                                                onPressed: () =>
                                                    controller.pause(),
                                                child: Icon(
                                                  Icons.pause_rounded,
                                                  size: 40.0.px,
                                                  color: ColorConstant.black,
                                                ),
                                              )
                                            : FloatingActionButton(
                                                shape: const CircleBorder(),
                                                elevation: 10,
                                                tooltip: AppStringConstant.play,
                                                backgroundColor:
                                                    ColorConstant.white,
                                                onPressed: () =>
                                                    controller.play(),
                                                child: Icon(
                                                  Icons.play_arrow_rounded,
                                                  size: 40.0.px,
                                                  color: ColorConstant.black,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                        IgnorePointer(
                          ignoring: (currentIndex ==
                                      controller.mediaItemList.length - 1 &&
                                  loopMode == LoopMode.off)
                              ? true
                              : false,
                          child: IconButton(
                            icon: const Icon(Icons.skip_next_rounded),
                            iconSize: (miniPlayer) ? 24.0.px : 45.px,
                            tooltip: AppStringConstant.skipNext,
                            color: (currentIndex ==
                                        controller.mediaItemList.length - 1 &&
                                    loopMode == LoopMode.off)
                                ? ColorConstant.white.withOpacity(0.5)
                                : Theme.of(context).primaryColor,
                            onPressed: () => controller.playNext(),
                          ),
                        ),
                        if (!miniPlayer)
                          StreamBuilder(
                              stream: audioPlayer.loopModeStream,
                              builder: (context, snapshot) {
                                LoopMode loopMode =
                                    snapshot.data ?? LoopMode.off;
                                const texts = ['Off', 'All', 'One'];
                                final icons = [
                                  Icon(
                                    Icons.repeat_rounded,
                                    color: ColorConstant.disableColor,
                                  ),
                                  const Icon(
                                    Icons.repeat_rounded,
                                    color: ColorConstant.white,
                                  ),
                                  const Icon(
                                    Icons.repeat_one_rounded,
                                    color: ColorConstant.white,
                                  ),
                                ];
                                const cycleModes = [
                                  LoopMode.off,
                                  LoopMode.all,
                                  LoopMode.one,
                                ];
                                final index = cycleModes.indexOf(loopMode);
                                return IconButton(
                                    tooltip: 'Repeat${texts[index]}',
                                    onPressed: () async {
                                      if (loopMode == LoopMode.off) {
                                        await audioPlayer
                                            .setLoopMode(LoopMode.one);
                                      } else if (loopMode == LoopMode.one) {
                                        await audioPlayer
                                            .setLoopMode(LoopMode.all);
                                      } else {
                                        await audioPlayer
                                            .setLoopMode(LoopMode.off);
                                      }
                                    },
                                    icon: icons[index]);
                              }),
                      ],
                    );
                  });
            });
      },
    );
  }
}

class PositionData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;

  PositionData(this.position, this.bufferedPosition, this.duration);
}

String format(String msg) {
  return '${msg[0].toUpperCase()}${msg.substring(1)}: '.replaceAll('_', ' ');
}

Future sleepTimerDialog(BuildContext context, AudioPlayerController controller) {
  return showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: Text(
            AppStringConstant.sleepTimer,
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          contentPadding: const EdgeInsets.all(10.0),
          children: [
            ListTile(
              title: const AppText(
                title: AppStringConstant.sleepDurationTitle,
                maxLines: 2,
              ),
              subtitle: const AppText(
                title: AppStringConstant.sleepDurationSubTitle,
                fontColor: ColorConstant.grey,
              ),
              dense: true,
              onTap: () {
                Get.back();
                setSleepDurationTimer(
                  context,
                  controller,
                );
              },
            ),
            ListTile(
              title: const AppText(
                title: AppStringConstant.sleepAfterTitle,
              ),
              subtitle: const AppText(
                title: AppStringConstant.sleepAfterSubTitle,
                maxLines: 2,
                fontColor: ColorConstant.grey,
              ),
              dense: true,
              isThreeLine: true,
              onTap: () {
                Get.back();
                setSleepCounterTimer(context, controller);
              },
            ),
          ],
        );
      });
}

Future setSleepCounterTimer(BuildContext context, AudioPlayerController controller) {
  return showDialog(
    context: context,
    builder: (context) {
      return SimpleDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.px)),
        contentPadding:
            EdgeInsets.symmetric(horizontal: 10.px, vertical: 10.px),
        title: AppText(
          title: AppStringConstant.enterNoOfSongs,
          fontColor: Theme.of(context).colorScheme.secondary,
          fontSize: 16.px,
        ),
        children: [
          TextField(
            keyboardType: TextInputType.number,
            controller: controller.noOfSongController,
            style: const TextStyle(color: ColorConstant.white),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textAlignVertical: TextAlignVertical.bottom,
          ),
          SizedBox(height: 5.px),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.secondary,
                ),
                onPressed: () => Get.back(),
                child: const AppText(title: AppStringConstant.cancel),
              ),
              SizedBox(width: 10.px),
              TextButton(
                style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Theme.of(context).colorScheme.secondary ==
                            ColorConstant.white
                        ? ColorConstant.black
                        : ColorConstant.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.px))),
                onPressed: () {
                  if (controller.noOfSongController.text.trim().isNotEmpty) {
                    controller.setSleepCount(
                        int.parse(controller.noOfSongController.text));
                    '${AppStringConstant.sleepTimerSetFor} ${controller.noOfSongController.text} ${AppStringConstant.songs}'
                        .showToast();
                    Get.back();
                  }
                },
                child: const AppText(title: AppStringConstant.ok),
              ),
            ],
          ),
        ],
      );
    },
  );
}

Future setSleepDurationTimer(
    BuildContext context, AudioPlayerController controller) {
  return showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.px)),
          title: Center(
            child: AppText(
              title: AppStringConstant.selectDuration,
              fontWeight: FontWeight.w600,
              fontColor: Theme.of(context).colorScheme.secondary,
            ),
          ),
          children: [
            Center(
              child: SizedBox(
                height: 200.px,
                width: 200.px,
                child: CupertinoTheme(
                    data: CupertinoThemeData(
                        primaryColor: Theme.of(context).colorScheme.secondary,
                        textTheme: CupertinoTextThemeData(
                            dateTimePickerTextStyle: TextStyle(
                                fontSize: 16.px,
                                color:
                                    Theme.of(context).colorScheme.secondary))),
                    child: CupertinoTimerPicker(
                      mode: CupertinoTimerPickerMode.hm,
                      onTimerDurationChanged: (value) {
                        controller.pickSleepTime = value;
                      },
                    )),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                  onPressed: () => Get.back(),
                  child: const AppText(title: AppStringConstant.cancel),
                ),
                SizedBox(width: 10.px),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Theme.of(context).colorScheme.secondary ==
                            ColorConstant.white
                        ? ColorConstant.black
                        : ColorConstant.white,
                  ),
                  onPressed: () {
                    controller.setSleepTimer(controller.pickSleepTime);
                    '${AppStringConstant.sleepTimerSetFor} ${controller.pickSleepTime.inMinutes} ${AppStringConstant.minutes}'
                        .showToast();
                    Get.back();
                  },
                  child: const AppText(title: AppStringConstant.ok),
                ),
              ],
            ),
          ],
        );
      });
}
