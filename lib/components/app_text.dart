import 'package:flutter/material.dart';

class AppText extends StatelessWidget {
  final String title;
  final String? fontFamily;
  final TextAlign? textAlign;
  final double? letterSpacing;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double?fontHeight;
  final FontStyle? fontStyle;
  final Color? fontColor;
  final TextOverflow? textOverflow;
  final TextDecoration? textDecoration;
  final int? maxLines;

  const AppText(
      {Key? key,
      required this.title,
      this.textOverflow,
      this.fontStyle,
      this.fontSize,
      this.fontColor,
      this.fontWeight,
      this.letterSpacing,
      this.textDecoration,
      this.textAlign,
      this.fontFamily,
      this.maxLines = 1,
      this.fontHeight})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      textAlign: textAlign,
      maxLines: maxLines,
      style: TextStyle(
        height: fontHeight,
        letterSpacing: letterSpacing,
        fontWeight: fontWeight,
        color: fontColor ?? Theme.of(context).primaryColor,
        fontSize: fontSize,
        fontStyle: fontStyle,
        overflow: textOverflow,
        decoration: textDecoration,
        fontFamily: fontFamily,
      ),
    );
  }
}
