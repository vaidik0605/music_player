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
  String? maxInt;
  String? maxBanner;
  String? maxNative;
  bool adsStatus;
  int? intCount;
  int? bannerCount;

  Data({
    this.maxInt,
    this.maxBanner,
    this.maxNative,
    this.adsStatus = false,
    this.intCount,
    this.bannerCount,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    maxInt: json["max_int"],
    maxBanner: json["max_banner"],
    maxNative: json["max_native"],
    adsStatus: json["ads_status"],
    intCount: json["int_count"],
    bannerCount: json["banner_count"],
  );

  Map<String, dynamic> toJson() => {
    "max_int": maxInt,
    "max_banner": maxBanner,
    "max_native": maxNative,
    "ads_status": adsStatus,
    "int_count": intCount,
    "banner_count": bannerCount,
  };
}
