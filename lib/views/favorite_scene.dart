import 'package:flutter/material.dart';
import 'dart:convert';
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

  void openArtifact() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const ArtifactDetailScene()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          color: Colors.white12,
          child: ListView(
            children: [
              Card(
                clipBehavior: Clip.hardEdge,
                color: Colors.blueGrey,
                child: InkWell(
                  splashColor: Colors.blue.withAlpha(30),
                  onTap: () {
                    openArtifact();
                  },
                  child: const SizedBox(
                    width: 300,
                    height: 100,
                    child: Text('A card that can be tapped'),
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
