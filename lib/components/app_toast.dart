import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:music_player/components/app_text.dart';
import 'package:music_player/constants/color_constant.dart';
import 'package:responsive_sizer/responsive_sizer.dart';


extension AppToast on String{
  showToast({double? fontSize}) {
    BotToast.showCustomNotification(toastBuilder: (cancelFunc) {
      return Padding(
        padding:EdgeInsets.all(12.px),
        child: Card(
          elevation: 15,
          color: ColorConstant.grey900,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            contentPadding:
             EdgeInsets.symmetric(horizontal: 12.px, vertical: 5.px),
            title: Container(
              margin: const EdgeInsets.only(top: 5),
              child: AppText(
                title: this,
                textOverflow: TextOverflow.ellipsis,
                maxLines: 3,
                fontSize: fontSize ?? 13,
                fontColor: ColorConstant.white,
              ),
            ),
          ),
        ),
      );
    },);
  }
}
