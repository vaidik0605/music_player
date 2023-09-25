// To parse this JSON data, do
//
//     final adModel = adModelFromJson(jsonString);

import 'dart:convert';

AdModel adModelFromJson(String str) => AdModel.fromJson(json.decode(str));

String adModelToJson(AdModel data) => json.encode(data.toJson());

class AdModel {
  bool success;
  String? message;
  Data? data;

  AdModel({
    this.success = false,
    this.message,
    this.data,
  });

  factory AdModel.fromJson(Map<String, dynamic> json) => AdModel(
    success: json["success"],
    message: json["message"],
    data: Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data!.toJson(),
  };
}

class Data {
  String? gAppOpen;
  String? gBanner;
  String? gInt;
  String? gNative;
  String? maxInt;
  String? maxBanner;
  String? maxNative;
  String? appOpen;
  bool adsStatus;
  bool isGoogle;
  bool scrollAd;
  int intCount;
  int bannerCount;

  Data({
    this.gAppOpen,
    this.gBanner,
    this.gInt,
    this.gNative,
    this.maxInt,
    this.maxBanner,
    this.maxNative,
    this.appOpen,
    this.adsStatus = false,
    this.scrollAd = false,
    this.isGoogle = false,
    this.intCount = 0,
    this.bannerCount = 0,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    gAppOpen: json["g_app_open"],
    gBanner: json["g_banner"],
    gInt: json["g_int"],
    gNative: json["g_native"],
    maxInt: json["max_int"],
    maxBanner: json["max_banner"],
    maxNative: json["max_native"],
    appOpen: json["app_open"],
    adsStatus: json["ads_status"],
    isGoogle: json["is_google"],
    intCount: json["int_count"],
    bannerCount: json["banner_count"],
    scrollAd: json["scroll_ad"],
  );

  Map<String, dynamic> toJson() => {
    "g_app_open": gAppOpen,
    "g_banner": gBanner,
    "g_int": gInt,
    "g_native": gNative,
    "max_int": maxInt,
    "max_banner": maxBanner,
    "max_native": maxNative,
    "app_open": appOpen,
    "ads_status": adsStatus,
    "is_google": isGoogle,
    "int_count": intCount,
    "banner_count": bannerCount,
    "scroll_ad": scrollAd,
  };
}
