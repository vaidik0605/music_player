import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:music_player/constants/color_constant.dart';
import 'package:music_player/localization/localization.dart';
import 'package:music_player/pages/home_page/home_page.dart';
import 'package:music_player/routes/route_constant.dart';
import 'package:music_player/routes/route_helper.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

const String sdkKey =
    "CKT_K98xIftRqJI8pphaJHTgCwbaHyvlfDPtriUJoWBeSWn42R8DZcvQ1D2fsIExu9XGXh5rIwow2Q97eEB1QB";


Future<void> main() async {
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Music Player',
    androidNotificationOngoing: true,
    androidShowNotificationBadge: true,
    notificationColor: ColorConstant.grey900,
  );
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (BuildContext context, Orientation orientation, screenType) {
        return AnnotatedRegion(
            value: const SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: ColorConstant.black38,
                statusBarIconBrightness: Brightness.light,
                systemNavigationBarIconBrightness: Brightness.light),
            child: GestureDetector(
              onTap: () => FocusManager.instance.primaryFocus!.unfocus(),
              child: GetMaterialApp(
                builder: BotToastInit(),
                debugShowCheckedModeBanner: false,
                locale: Get.deviceLocale,
                translations: Languages(),
                localizationsDelegates: const [
                  GlobalCupertinoLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                ],
                navigatorKey: Get.key,
                scrollBehavior: MyBehavior(),
                home: const HomePage(),
                getPages: RouteHelper.routes,
                initialRoute: RouteConstant.initialRoute,
                theme: ThemeData(
                    scaffoldBackgroundColor: ColorConstant.black,
                    useMaterial3: true,
                    popupMenuTheme:
                        PopupMenuThemeData(color: ColorConstant.grey900),
                    fontFamily: 'popins',
                    dialogTheme:
                        DialogTheme(backgroundColor: ColorConstant.grey900),
                    colorScheme: Theme.of(context).colorScheme.copyWith(
                          primary: ColorConstant.white,
                          secondary: ColorConstant.tealAccent,
                          brightness: Brightness.dark,
                        ),
                    inputDecorationTheme: InputDecorationTheme(
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            width: 1.5.px, color: ColorConstant.tealAccent),
                      ),
                    ),
                    dialogBackgroundColor: ColorConstant.black,
                    appBarTheme: const AppBarTheme(
                        systemOverlayStyle: SystemUiOverlayStyle.light)),
              ),
            ));
      },
    );
  }
}

class MyBehavior extends ScrollBehavior {
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }

  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
