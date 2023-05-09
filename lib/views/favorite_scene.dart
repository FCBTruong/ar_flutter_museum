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
  List<String> selectedMuseums = [];
  List<dynamic> filteredArtifacts = [];
  List<String> initMuseums = [];
 PopupMenuButton<dynamic>? _popupMenuButton;

  @override
  initState() {
    super.initState();
    filteredArtifacts = ArtifactFavoriteMgr.listArtifacts;

    List<dynamic> artifactPackages = [
      ...ArtifactFavoriteMgr.listArtifacts
    ]; // Replace with your actual list of artifacts
    Set<String> museumNames = artifactPackages
        .map((artifactPkg) => artifactPkg['museumName'].toString())
        .toSet();
    selectedMuseums = museumNames.toList();
    initMuseums = museumNames.toList();

    filteredArtifacts = filterArtifactsByMuseums(selectedMuseums);
  }

  void openArtifact(Map<String, dynamic> artifactPackage) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ArtifactDetailScene(
                url: "", artifactPackage: artifactPackage)));
  }

  void _onMuseumSelected(String museumName, bool isChecked) {
    setState(() {
      if (isChecked == true) {
        selectedMuseums.add(museumName);
      } else {
        selectedMuseums.remove(museumName);
      }
      filteredArtifacts = filterArtifactsByMuseums(selectedMuseums);
    });
  }

  List<dynamic> filterArtifactsByMuseums(List<String> selectedMuseums) {
    List<dynamic> artifactPkgList = [
      ...ArtifactFavoriteMgr.listArtifacts
    ]; // Replace with your actual list of artifacts

    return artifactPkgList
        .where((artifactPkg) =>
            selectedMuseums.contains(artifactPkg['museumName']))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    _popupMenuButton = PopupMenuButton(
                itemBuilder: (context) => initMuseums
                    .map<PopupMenuItem>(
                      (museumName) => PopupMenuItem(
                        child: CheckboxListTile(
                          title: Text(museumName),
                          value: selectedMuseums.contains(museumName),
                          onChanged: (value) {
                            _onMuseumSelected(
                              museumName,
                              value!,
                            );
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      ),
                    )
                    .toList(),
                child: const Icon(Icons.filter_list),
              );

    return Scaffold(
        appBar: AppBar(title: const Text("Yêu thích"), actions: <Widget>[
          Padding(
              padding: const EdgeInsets.only(right: 10),
              child: _popupMenuButton)
        ]),
        body: Container(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          color: Colors.white12,
          child: ArtifactFavoriteMgr.listArtifacts.isNotEmpty
              ? ListView(
                  children: filteredArtifacts
                      .map<Widget>((artifactPackage) => Card(
                            clipBehavior: Clip.hardEdge,
                            color: Color.fromARGB(255, 245, 245, 245),
                            child: InkWell(
                              splashColor: Color.fromARGB(255, 153, 153, 153)
                                  .withAlpha(30),
                              onTap: () {
                                openArtifact(artifactPackage);
                              },
                              child: SizedBox(
                                  height: 200,
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 5, 0, 0),
                                    child: Column(children: [
                                      Center(
                                          child: Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: Text(
                                                artifactPackage['artifact']
                                                        ['name']
                                                    .toString(),
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color: Colors.black),
                                              ))),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Row(children: [
                                        Expanded(
                                          flex: 3,
                                          child: Image(
                                              image: NetworkImage(artifactPackage[
                                                              'artifact']
                                                          ['image'] !=
                                                      ""
                                                  ? artifactPackage['artifact']
                                                      ['image']
                                                  : "https://www.generationsforpeace.org/wp-content/uploads/2018/03/empty.jpg")),
                                        ),
                                        Expanded(
                                            flex: 7,
                                            child: SizedBox(
                                                child: Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: Text(
                                                Utilities.subStr(
                                                    artifactPackage['artifact']
                                                            ['description']
                                                        .toString(),
                                                    100),
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 15,
                                                    color: Colors.black),
                                                overflow: TextOverflow.fade,
                                              ),
                                            )))
                                      ]),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Row(children: [
                                        const Icon(Icons.museum_outlined,
                                            color: Colors.black),
                                        Text(
                                          Utilities.subStr(
                                              artifactPackage
                                                      .containsKey('museumName')
                                                  ? artifactPackage[
                                                          'museumName']
                                                      .toString()
                                                  : "",
                                              100),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: Colors.black),
                                          overflow: TextOverflow.fade,
                                        ),
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
