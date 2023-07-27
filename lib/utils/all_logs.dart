import 'package:flutter/foundation.dart';

void logs(String message){
  if (kDebugMode) {
    print(message);
  }
}