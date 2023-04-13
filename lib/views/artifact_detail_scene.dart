import 'package:arcore_example/views/localAndWebObjectsView.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:developer';
import 'package:arcore_example/logic/text_handler.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:arcore_example/logic/artifact_favorite_mgr.dart';

class ArtifactDetailScene extends StatefulWidget {
  const ArtifactDetailScene({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ArtifactDetailScene();
}

class _ArtifactDetailScene extends State<ArtifactDetailScene> {
  bool _isLoading = true;
  String _appBarTitle = 'Đang tải';
  Map<String, dynamic> data = jsonDecode(dttest);
  bool _isFavorite = false;
  @override
  initState() {
    super.initState();
    _isLoading = true;
    _isFavorite = false;
    fetchData();
  }

  Future fetchData() async {
    // fetch data and update app bar title when done
    final response = await http.get(Uri.parse(
        'https://ar-dashboard.azurewebsites.net/api/guests/9ad8d313-2bd2-4263-9a24-c2b495ca70f9/2b798788-3eff-4bdf-ae1a-fd3c2637368f/38744d66-0978-4aae-a192-929321f92a2a'));
    if (response.statusCode == 200) {
      log("hiiii");
      log(response.toString());
      final Map<String, dynamic> jsonData = json.decode(response.body);
      log(jsonData.toString());
      var artifact = jsonData["artifact"];
      var information = artifact["information"];
      log("infor" + information);

      setState(() {
        _appBarTitle = 'Fetched Data';
        _isLoading = false;
        data = jsonDecode(information);
      });
    } else {
      setState(() {
        _appBarTitle = 'Error';
        _isLoading = false;
      });
    }
  }

  void openARView() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const LocalAndWebObjectsView()));
  }

  Widget createWidgetByBlock(Map<String, dynamic> block) {
    Widget wg = Container();
    Map<String, dynamic> blData = block['data'];
    log('create widget by block');

    switch (block['type']) {
      case 'header':
        wg = Text(
          blData['text'],
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        );
        break;
      case 'paragraph':
        {
          wg = Html(data: blData['text']);

          break;
        }
      case 'image':
        {
          wg = Padding(
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
            child: Image.network(blData['file']['url']),
          );
          break;
        }
    }
    return Expanded(child: wg);
  }

  void onClickFavorite() {
    if (_isFavorite) {
      // remove from favorite lists
      ArtifactFavoriteMgr.remove("id");
    } else {
      // add to favorite list
      ArtifactFavoriteMgr.remove("artifact");
    }
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(_appBarTitle),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon((_isFavorite)
                  ? Icons.favorite
                  : Icons.favorite_border_outlined),
              tooltip: 'Thêm vào danh sách yêu thích',
              onPressed: () {
                onClickFavorite();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text((_isFavorite)
                        ? 'Đã thêm vào danh sách yêu thích'
                        : "Đã xóa khỏi danh sách yêu thích")));
              },
            ),
          ]),
      body: (_isLoading)
          ? const Center(child: CircularProgressIndicator())
          : Container(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              color: Colors.white12,
              child: ListView(
                  // This next line does the trick.
                  scrollDirection: Axis.vertical,
                  children: data['blocks']
                      .map<Widget>((block) => createWidgetByBlock(block))
                      .toList())),
      floatingActionButton: Visibility(
          visible: !_isLoading,
          child: FloatingActionButton(
            onPressed: () {
              openARView();
            },
            backgroundColor: Colors.green,
            child: const Icon(Icons.view_in_ar),
          )),
    );
  }
}

var dttest =
    "{\"time\":1680984904023,\"blocks\":[{\"id\":\"f8pdSDYhte\",\"type\":\"header\",\"data\":{\"text\":\"Tyranosaurus\",\"level\":3}},{\"id\":\"JU6jV9vIdX\",\"type\":\"paragraph\",\"data\":{\"text\":\"<i><b><a href=\\\"http://en.wikipedia.org/wiki/Tyrannosaurus\\\">Tyrannosaurus</a></b></i>&nbsp;(meaning \\\"tyrant lizard\\\") is an extinct genus of large theropod dinosaur. The species&nbsp;<i><b>Tyrannosaurus rex</b></i>&nbsp;(<i>rex</i>&nbsp;meaning \\\"king\\\" in Latin), often called&nbsp;<i><b>T. rex</b></i>&nbsp;or colloquially&nbsp;<i><b>T-Rex</b></i>, is one of the best represented members of the genus as well as all theropods.&nbsp;<i>Tyrannosaurus</i>&nbsp;lived throughout what is now western North America, on what was then an island continent known as Laramidia.&nbsp;<i>Tyrannosaurus</i>&nbsp;had a much wider range than other tyrannosaurids. Fossils are found in a variety of rock formations dating to the Maastrichtian age of the Upper Cretaceous period, 68-66 million years ago. It was the largest and the last known member of the tyrannosaurids and among the last non-avian dinosaurs to exist before the Cretaceous–Paleogene extinction event.\"}},{\"id\":\"MaqksRPE1G\",\"type\":\"image\",\"data\":{\"file\":{\"url\":\"https://www.dropbox.com/s/fwspy174pube78s/museum_bg_0.jpeg?dl=1\"},\"caption\":\"\",\"withBorder\":false,\"stretched\":false,\"withBackground\":false}},{\"id\":\"Artkhj9fuh\",\"type\":\"paragraph\",\"data\":{\"text\":\"Like other tyrannosaurids,&nbsp;<i>Tyrannosaurus</i>&nbsp;was a bipedal carnivore with a massive skull balanced by a long, heavy tail. Relative to its large and powerful hind limbs, the forelimbs of&nbsp;<i>Tyrannosaurus</i>&nbsp;were short but unusually powerful for their size, and they had 2 clawed digits. The most complete specimen measures up to 12.3-12.4 meters (40.4-40.7 feet) in length and stands 3.66 meters (12 feet) tall, though&nbsp;<i>T. rex</i>&nbsp;could grow to lengths of around 13.2 meters (43.30 feet), up to 3.96 meters (13 feet) tall at the hips, and according to most modern estimates 8.4 metric tons (9.3 short tons) to 14 metric tons (15.4 short tons) in weight. Although other theropods rivaled or exceeded&nbsp;<i>Tyrannosaurus rex</i>&nbsp;in size, it is still among the largest known land predators and is estimated to have exerted the strongest bite force among all terrestrial animals. By far the largest carnivore in its environment and the infamous \\\"<i>king of the dinosaurs</i>\\\",&nbsp;<i>Tyrannosaurus rex</i>&nbsp;was most likely an apex predator, preying upon hadrosaurs, juvenile armored herbivores like ceratopsians and ankylosaurs, and possibly sauropods. Some experts have suggested the dinosaur was primarily a scavenger. The question of whether&nbsp;<i>Tyrannosaurus</i>&nbsp;was an apex predator or a pure scavenger was among the longest debates in paleontology. Most paleontologists today accept that&nbsp;<i>Tyrannosaurus</i>&nbsp;was both an active predator and a scavenger. B\"}},{\"id\":\"h7Hk3mkGsj\",\"type\":\"image\",\"data\":{\"file\":{\"url\":\"https://www.dropbox.com/s/pw1fn956w0tveye/museum_bg_1.jpeg?dl=1\"},\"caption\":\"\",\"withBorder\":false,\"stretched\":false,\"withBackground\":false}}],\"version\":\"2.26.5\"}";
