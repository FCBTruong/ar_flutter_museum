import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ArtifactFavoriteMgr {
  static List<Map<String, dynamic>> listArtifacts = [];
  static void init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> listJson = prefs.getStringList('favorite_artifacts') ?? [];
    listArtifacts = listJson
        .map<Map<String, dynamic>>((String json) => jsonDecode(json))
        .toList();
  }

  static void processRawText(String raw) {}

  static void saveFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> listJson = listArtifacts
        .map((Map<String, dynamic> obj) => jsonEncode(obj))
        .toList();
    prefs.setStringList('favorite_artifacts', listJson);
  }

  static bool add(Map<String, dynamic> artifact){
    // TODO

    return true;
  }
   static bool remove(String artifactId){
    // TODO

    return true;
  }
}
