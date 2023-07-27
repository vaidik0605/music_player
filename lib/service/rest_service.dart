import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:music_player/components/app_toast.dart';
import 'package:music_player/constants/string_constant.dart';
import 'package:music_player/service/rest_constant.dart';
import 'package:music_player/utils/all_logs.dart';

class RestService{
  static Future<Map<String, dynamic>?>getRestMethod() async {
    try {
      final url = Uri.parse(RestConstant.adIdsEndPoint);
      logs("url ---> $url");
      final response = await http.get(url,headers: RestConstant.headers);
      logs("response ---> ${response.body}");
      Map<String,dynamic> responseMap = {};
      switch(response.statusCode){
        case 200:
        case 201:
        responseMap = jsonDecode(response.body);
          break;
        case 500:
          AppStringConstant.severError.showToast();
        default:
          logs('getRestMethod response : ${response.body} : ${response.statusCode}');
      }
      return responseMap;
    } on SocketException catch (e) {
      logs("Catch exception in getRestMethod ---> $e");
    }
    return null;
  }
}