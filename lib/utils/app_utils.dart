import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class Utils {
  static printLog(String message) {
    if (kDebugMode) {
      print(message);
    }
  }

  static showToast({required String content}) {
    toast(content);
  }

  // static void shareMessageWithFiles(
  //     {required String message, required List<XFile> files}) {
  //   if(files.isEmpty) {
  //     Share.share(message);
  //   } else {
  //     Share.shareXFiles(files, text: message);
  //   }
  // }

  static Locale getLocalFromSharedPrefs() {
    final locale = sharedPreferences.getString('locale');
    if (locale != null) {
      return Locale(locale);
    }
    printLog("getLocalFromSharedPrefs: $locale");
    return const Locale('en');
  }
}
