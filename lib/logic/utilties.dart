

import 'dart:math';

class Utilities {
  static String subStr(String s, int length){
    if(s.length > length){
      return s.substring(0, length) + "...";
    }
    return s;
  }
}