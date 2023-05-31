

import 'dart:math';

class Utilities {
  static String subStr(String s, int length){
    if(s.length > length){
      return s.substring(0, length) + "...";
    }
    return s;
  }

  static String getFontSizeName(double fontSize){
    if(fontSize == FONT_SMALL){
      return "Nhỏ";
    }
    if(fontSize == FONT_MEDIUM){
      return "Vừa";
    }
    if(fontSize == FONT_LARGE){
      return "Lớn";
    }
    if(fontSize == FONT_VERY_LARGE){
      return "Rất lớn";
    }
    return "Vừa";
  }

  static const double FONT_SMALL = 14;
  static const double FONT_MEDIUM = 16;
  static const double FONT_LARGE = 18;
  static const double FONT_VERY_LARGE = 20;
}