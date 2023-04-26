import 'package:arcore_example/logic/artifact_favorite_mgr.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import '../logic/utilties.dart';
import 'artifact_detail_scene.dart';

class FavoriteScene extends StatefulWidget {
  const FavoriteScene({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _FavoriteScene();
}

class _FavoriteScene extends State<FavoriteScene> {
  @override
  initState() {
    super.initState();
  }

  void openArtifact(Map<String, dynamic> artifactPackage) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ArtifactDetailScene(
                url: "", artifactPackage: artifactPackage)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      color: Colors.white12,
      child: ArtifactFavoriteMgr.listArtifacts.isNotEmpty
          ? ListView(
              children: ArtifactFavoriteMgr.listArtifacts
                  .map<Widget>((artifactPackage) => Card(
                        clipBehavior: Clip.hardEdge,
                        color: Color.fromARGB(255, 245, 245, 245),
                        child: InkWell(
                          splashColor:
                              Color.fromARGB(255, 153, 153, 153).withAlpha(30),
                          onTap: () {
                            openArtifact(artifactPackage);
                          },
                          child: SizedBox(
                              height: 200,
                              child: Padding(
                                padding: const EdgeInsets.all(5),
                                child: Column(children: [
                                  Center(
                                      child: Text(
                                    artifactPackage['artifact']['name']
                                        .toString(),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.black),
                                  )),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    Utilities.subStr(
                                        artifactPackage['artifact']
                                                ['description']
                                            .toString(),
                                        100),
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.black),
                                    overflow: TextOverflow.fade,
                                  ),
                                  Text(
                                    Utilities.subStr(
                                        artifactPackage
                                                .containsKey('museumName')
                                            ? artifactPackage['museumName']
                                                .toString()
                                            : "",
                                        100),
                                    style: const TextStyle(
                                        fontSize: 15, color: Colors.black),
                                    overflow: TextOverflow.fade,
                                  ),
                                  Row(children: const [
                                    Icon(Icons.museum_outlined,
                                        color: Colors.black),
                                    Text(
                                      'British Museum',
                                      style: TextStyle(
                                          fontSize: 15, color: Colors.black),
                                    )
                                  ])
                                ]),
                              )),
                        ),
                      ))
                  .toList())
          : const Center(child: Text('Chưa có mục yêu thích nào')),
    ));
  }
}
