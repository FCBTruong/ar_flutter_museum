import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:developer';

class ArtifactDetailScene extends StatefulWidget {
  const ArtifactDetailScene({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ArtifactDetailScene();
}

class _ArtifactDetailScene extends State<ArtifactDetailScene> {
  String description =
      "Tyrannosaurus is a genus of large theropod dinosaur. The species Tyrannosaurus rex, often called T. rex or colloquially T-Rex, is one of the best represented theropods. It lived throughout what is now western North America, on what was then an island continent known as Laramidia.";

  Map<String, dynamic> data = jsonDecode(dttest);
  @override
  initState() {
    super.initState();
  }

  Widget createWidgetByBlock(Map<String, dynamic> block) {
    Widget wg = Container();
    Map<String, dynamic> blData = block['data'];

    switch (block['type']) {
      case 'header':
      int level = blData['level'];
      
   
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
          wg = Text(
            blData['text'],
            textAlign: TextAlign.justify,
            style: const TextStyle(
              color: Colors.black,
            ),
          );
          break;
        }
      case 'image':
        {
          wg = Padding(
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
            child: Image.asset('assets/images/tyranosaurus.jpeg'),
          );
          break;
        }
    }
    return Expanded(child: wg);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Brachiosaurus"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Container(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            color: Colors.white12,
            child: ListView(
                // This next line does the trick.
                scrollDirection: Axis.vertical,
                children: data['blocks']
                    .map<Widget>((block) => createWidgetByBlock(block))
                    .toList())));
  }
}

var dttest =
    "{\"time\":1680984904023,\"blocks\":[{\"id\":\"f8pdSDYhte\",\"type\":\"header\",\"data\":{\"text\":\"Tyranosaurus\",\"level\":3}},{\"id\":\"JU6jV9vIdX\",\"type\":\"paragraph\",\"data\":{\"text\":\"<i><b><a href=\\\"http://en.wikipedia.org/wiki/Tyrannosaurus\\\">Tyrannosaurus</a></b></i>&nbsp;(meaning \\\"tyrant lizard\\\") is an extinct genus of large theropod dinosaur. The species&nbsp;<i><b>Tyrannosaurus rex</b></i>&nbsp;(<i>rex</i>&nbsp;meaning \\\"king\\\" in Latin), often called&nbsp;<i><b>T. rex</b></i>&nbsp;or colloquially&nbsp;<i><b>T-Rex</b></i>, is one of the best represented members of the genus as well as all theropods.&nbsp;<i>Tyrannosaurus</i>&nbsp;lived throughout what is now western North America, on what was then an island continent known as Laramidia.&nbsp;<i>Tyrannosaurus</i>&nbsp;had a much wider range than other tyrannosaurids. Fossils are found in a variety of rock formations dating to the Maastrichtian age of the Upper Cretaceous period, 68-66 million years ago. It was the largest and the last known member of the tyrannosaurids and among the last non-avian dinosaurs to exist before the Cretaceous–Paleogene extinction event.\"}},{\"id\":\"MaqksRPE1G\",\"type\":\"image\",\"data\":{\"file\":{\"url\":\"https://localhost:5001/api/files/2facc1e4-b211-4621-863b-9f46b12fcb42/da5471c6-d709-4eaa-bdd6-d4437e06fbf3.jpeg\"},\"caption\":\"\",\"withBorder\":false,\"stretched\":false,\"withBackground\":false}},{\"id\":\"Artkhj9fuh\",\"type\":\"paragraph\",\"data\":{\"text\":\"Like other tyrannosaurids,&nbsp;<i>Tyrannosaurus</i>&nbsp;was a bipedal carnivore with a massive skull balanced by a long, heavy tail. Relative to its large and powerful hind limbs, the forelimbs of&nbsp;<i>Tyrannosaurus</i>&nbsp;were short but unusually powerful for their size, and they had 2 clawed digits. The most complete specimen measures up to 12.3-12.4 meters (40.4-40.7 feet) in length and stands 3.66 meters (12 feet) tall, though&nbsp;<i>T. rex</i>&nbsp;could grow to lengths of around 13.2 meters (43.30 feet), up to 3.96 meters (13 feet) tall at the hips, and according to most modern estimates 8.4 metric tons (9.3 short tons) to 14 metric tons (15.4 short tons) in weight. Although other theropods rivaled or exceeded&nbsp;<i>Tyrannosaurus rex</i>&nbsp;in size, it is still among the largest known land predators and is estimated to have exerted the strongest bite force among all terrestrial animals. By far the largest carnivore in its environment and the infamous \\\"<i>king of the dinosaurs</i>\\\",&nbsp;<i>Tyrannosaurus rex</i>&nbsp;was most likely an apex predator, preying upon hadrosaurs, juvenile armored herbivores like ceratopsians and ankylosaurs, and possibly sauropods. Some experts have suggested the dinosaur was primarily a scavenger. The question of whether&nbsp;<i>Tyrannosaurus</i>&nbsp;was an apex predator or a pure scavenger was among the longest debates in paleontology. Most paleontologists today accept that&nbsp;<i>Tyrannosaurus</i>&nbsp;was both an active predator and a scavenger. B\"}},{\"id\":\"h7Hk3mkGsj\",\"type\":\"image\",\"data\":{\"file\":{\"url\":\"https://localhost:5001/api/files/2facc1e4-b211-4621-863b-9f46b12fcb42/7bf131eb-80da-4889-9c4d-6777c513f11f.jpeg\"},\"caption\":\"\",\"withBorder\":false,\"stretched\":false,\"withBackground\":false}}],\"version\":\"2.26.5\"}";
