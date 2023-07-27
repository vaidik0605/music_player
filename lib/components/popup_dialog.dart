import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/constants/color_constant.dart';

class PopupDialog {
  static void showPopup({
    required BuildContext context,
    required Widget child,
    double radius = 20.0,
    Color? backColor,
    Color? closeButtonColor,
    Color? closeIconColor,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          backgroundColor: Colors.transparent,
          content: Stack(
            children: [
              GestureDetector(onTap: () => Get.back()),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Card(
                  elevation: 0.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(radius),
                  ),
                  clipBehavior: Clip.antiAlias,
                  color: backColor,
                  child: child,
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Card(
                  elevation: 15.0,
                  color: closeButtonColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close_rounded),
                    color: closeIconColor ?? ColorConstant.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
