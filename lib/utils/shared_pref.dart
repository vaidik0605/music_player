import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';


const musicId = '';

const keyThemeStatus = "ThemeStatus";
const tmpPath = "tmpPath";

Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

checkPrefKey(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.containsKey(key);
}

setDarkTheme(bool value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool(keyThemeStatus, value);
}


Future<bool> getTheme() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool(keyThemeStatus) ?? false;
}

getPrefIntValue(String key) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt(key);
}

getPrefBoolValue(String key) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(key) ?? false;
}

getPrefStringValue(String key) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(key) ?? "";
}

setPrefStringValue(String key, value) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString(key, value);
}

getPrefStringUserValue(String key) async {
  SharedPreferences prefs = await _prefs;
  return prefs.getString(key) ?? "";
}

setPrefStringUserValue(String key, value1) async {
  SharedPreferences prefs = await _prefs;
  return prefs.setString(key, value1);
}

setPrefIntValue(String key, value) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setInt(key, value);
}

setPrefBoolValue(String key, value) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setBool(key, value);
}

removePrefValue(String key) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.remove(key);
}
