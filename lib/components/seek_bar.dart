import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_player/components/app_text.dart';
import 'package:music_player/constants/color_constant.dart';
import 'package:music_player/constants/string_constant.dart';
import 'package:music_player/controller/player_controller.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class SeekBar extends StatefulWidget {
  final Duration duration;
  final Duration position;
  final Duration bufferedPosition;
  final ValueChanged<Duration>? onChanged;
  final ValueChanged<Duration>? onChangeEnd;

  const SeekBar(
      {super.key,
      required this.duration,
      required this.bufferedPosition,
      required this.position,
      this.onChanged,
      this.onChangeEnd});

  @override
  State<SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  double? _dragValue;
  bool _dragging = false;
  late SliderThemeData _sliderThemeData;

  Duration get _duration => widget.duration;

  Duration get _position => widget.position;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _sliderThemeData = SliderTheme.of(context).copyWith(
      trackHeight: 4.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final value = min(
      _dragValue ?? widget.position.inMilliseconds.toDouble(),
      widget.duration.inMilliseconds.toDouble(),
    );
    if (_dragValue != null && !_dragging) {
      _dragValue = null;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: EdgeInsets.only(right: 25.px),
          child: StreamBuilder<double>(
            stream: audioPlayer.speedStream,
            builder: (context, snapshot) {
              final String speedValue =
                  '${snapshot.data?.toStringAsFixed(1) ?? 1.0}x';
              return GestureDetector(
                child: AppText(
                  title: speedValue,
                  fontWeight: FontWeight.w500,
                  fontColor: speedValue == '1.0x'
                      ? Theme.of(context).disabledColor
                      : null,
                ),
                onTap: () {
                  showSliderDialog(
                    context: context,
                    title: AppStringConstant.adjustAudio,
                    divisions: 25,
                    min: 0.5,
                    max: 3.0,
                  );
                },
              );
            },
          ),
        ),
        SizedBox(
          height: 20.px,
          child: Stack(
            children: [
              SliderTheme(
                data: _sliderThemeData.copyWith(
                  thumbShape: HiddenThumbComponentShape(),
                  activeTrackColor:
                      Theme.of(context).iconTheme.color!.withOpacity(0.5),
                  inactiveTrackColor:
                      Theme.of(context).iconTheme.color!.withOpacity(0.3),
                  // trackShape: RoundedRectSliderTrackShape(),
                  trackShape: const RectangularSliderTrackShape(),
                ),
                child: ExcludeSemantics(
                  child: Slider(
                    max: widget.duration.inMilliseconds.toDouble(),
                    value: min(
                      widget.bufferedPosition.inMilliseconds.toDouble(),
                      widget.duration.inMilliseconds.toDouble(),
                    ),
                    onChanged: (value) {},
                  ),
                ),
              ),
              SliderTheme(
                data: _sliderThemeData.copyWith(
                  inactiveTrackColor: Colors.transparent,
                  activeTrackColor: Theme.of(context).iconTheme.color,
                  thumbColor: Theme.of(context).iconTheme.color,
                ),
                child: Slider(
                  max: widget.duration.inMilliseconds.toDouble(),
                  value: value,
                  onChanged: (value) {
                    if (!_dragging) {
                      _dragging = true;
                    }
                    setState(() {
                      _dragValue = value;
                    });
                    widget.onChanged
                        ?.call(Duration(milliseconds: value.round()));
                  },
                  onChangeEnd: (value) {
                    widget.onChangeEnd
                        ?.call(Duration(milliseconds: value.round()));
                    _dragging = false;
                  },
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.px),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                title: RegExp(r'((^0*[1-9]\d*:)?\d{2}:\d{2})\.\d+$')
                        .firstMatch('$_position')
                        ?.group(1) ??
                    '$_position',
              ),
              AppText(
                title: RegExp(r'((^0*[1-9]\d*:)?\d{2}:\d{2})\.\d+$')
                        .firstMatch('$_duration')
                        ?.group(1) ??
                    '$_duration',
                // style: Theme.of(context).textTheme.caption!.copyWith(
                //       color: Theme.of(context).iconTheme.color,
                //     ),
              ),
            ],
          ),
        )
      ],
    );
  }
}

void showSliderDialog({
  required BuildContext context,
  required String title,
  required int divisions,
  required double min,
  required double max,
  String valueSuffix = '',
}) {
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      title: AppText(title: title, textAlign: TextAlign.center),
      content: StreamBuilder<double>(
        stream: audioPlayer.speedStream,
        builder: (context, snapshot) {
          double value = snapshot.data ?? audioPlayer.speed;
          if (value > max) {
            value = max;
          }
          if (value < min) {
            value = min;
          }
          return SizedBox(
            height: 100.px,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(CupertinoIcons.minus),
                      color: ColorConstant.white,
                      onPressed: audioPlayer.speed > min
                          ? () {
                              audioPlayer.setSpeed(audioPlayer.speed - 0.1);
                            }
                          : null,
                    ),
                    AppText(
                      title: '${snapshot.data?.toStringAsFixed(1)}$valueSuffix',
                      fontWeight: FontWeight.bold,
                      fontSize: 24.px,
                    ),
                    IconButton(
                      color: ColorConstant.white,
                      icon: const Icon(CupertinoIcons.plus),
                      onPressed: audioPlayer.speed < max
                          ? () {
                              audioPlayer.setSpeed(audioPlayer.speed + 0.1);
                            }
                          : null,
                    ),
                  ],
                ),
                Slider(
                  inactiveColor:
                      Theme.of(context).iconTheme.color!.withOpacity(0.4),
                  activeColor: Theme.of(context).iconTheme.color,
                  divisions: divisions,
                  min: min,
                  max: max,
                  value: value,
                  onChanged: audioPlayer.setSpeed,
                ),
              ],
            ),
          );
        },
      ),
    ),
  );
}

class HiddenThumbComponentShape extends SliderComponentShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size.zero;

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {}
}
