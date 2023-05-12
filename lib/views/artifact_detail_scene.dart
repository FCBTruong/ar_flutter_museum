import 'package:arcore_example/qr_code.dart';
import 'package:arcore_example/views/audio_player.dart';
import 'package:arcore_example/views/homeView.dart';
import 'package:arcore_example/views/localAndWebObjectsView.dart';
import 'package:arcore_example/views/video_app.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:arcore_example/logic/artifact_favorite_mgr.dart';
import 'package:appinio_video_player/appinio_video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class ArtifactDetailScene extends StatefulWidget {
  final String url;
  final dynamic artifactPackage;
  const ArtifactDetailScene({Key? key, required this.url, this.artifactPackage})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _ArtifactDetailScene();
}

class _ArtifactDetailScene extends State<ArtifactDetailScene> {
  bool _isLoading = true;
  bool _isHasAR = false;
  String _appBarTitle = 'Đang tải';
  Map<String, dynamic> information = {};
  bool _isFavorite = false;
  late VideoPlayerController videoPlayerController;
  dynamic artifact;
  dynamic artifactPackage;
  bool _isCachedData = false;

  @override
  initState() {
    super.initState();
    _isLoading = true;
    _isFavorite = false;
    _isHasAR = false;
    _isCachedData = widget.artifactPackage != null;
    fetchData();
  }

  Future fetchData() async {
    // fetch data and update app bar title when done
    if (widget.url != "") {
      final response = await http.get(Uri.parse(widget.url));
      if (response.statusCode == 200) {
        log(response.toString());
        artifactPackage = json.decode(response.body);
        log("artifactPkg " + artifactPackage.toString());
        artifact = artifactPackage["artifact"];

        onDoneData();
      } else {
        setState(() {
          _appBarTitle = 'Error';
          _isLoading = false;
        });
      }
    } else {
      artifactPackage = widget.artifactPackage;
      artifact = artifactPackage["artifact"];
      onDoneData();
    }
  }

  void onDoneData() {
    var info = artifact["information"];

    _isFavorite = ArtifactFavoriteMgr.isFavorite(artifactPackage['id']);
    _isHasAR = artifact['modelAr'] != null &&
        artifact['modelAr'] != "" &&
        artifact['modelAr']['modelAsset'] != null;

    if (_isFavorite && !_isCachedData) {
      ArtifactFavoriteMgr.update(artifactPackage);
    }

    setState(() {
      _appBarTitle = '';
      _isLoading = false;
      information = jsonDecode(info);
    });
  }

  void openARView() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => LocalAndWebObjectsView(artifact: artifact)));
  }

  Widget createWidgetByBlock(Map<String, dynamic> block) {
    Widget wg = Container();

    log('create widget by block');
    Map<String, dynamic> blData = block['data'];
    switch (block['type']) {
      case 'header':
        wg = Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: Text(
              blData['text'],
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 28,
              ),
            ));
        break;
      case 'paragraph':
        {
          wg = Html(data: blData['text']);

          break;
        }
      case 'image':
        {
          wg = Padding(
            padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
            child: Image.network(blData['file']['url'],
                loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                return Column(
                    children: ([
                  child,
                  Visibility(
                      visible:
                          blData['caption'] != '' && blData['caption'] != null,
                      child: Text(
                        blData['caption'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ))
                ]));
              }
              return Center(
                child: DecoratedBox(
                    decoration: BoxDecoration(color: Colors.grey[200]),
                    child: const SizedBox(
                        width: double.infinity,
                        height: 200,
                        child: Center(
                            child: SizedBox(
                          height: 30.0,
                          width: 30.0,
                          child: CircularProgressIndicator(
                              // value: loadingProgress.expectedTotalBytes != null
                              //     ? loadingProgress.cumulativeBytesLoaded /
                              //         loadingProgress.expectedTotalBytes!
                              //     : null,
                              ),
                        )))),
              );
            }),
          );
          break;
        }

      case 'video':
        {
          String url = blData['file']['url'];

          wg = VideoApp(url: url);
          break;
        }
      case 'audio':
        {
          String url = blData['url'];
          wg = AudioPlayerBlock(audioUrl: url);
          break;
        }
      case 'embed':
        {
          var service = blData['service'];

          if (service == 'youtube') {
            var videoId = YoutubePlayer.convertUrlToId(blData['source']);
            YoutubePlayerController _controller = YoutubePlayerController(
              initialVideoId: videoId!,
              flags: const YoutubePlayerFlags(
                autoPlay: true,
                mute: true,
              ),
            );

            wg = Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                child: YoutubePlayer(
                  controller: _controller,
                  showVideoProgressIndicator: true,
                ));
          }
          break;
        }
      case 'list':
        {
          var items = blData['items'];
          var style = blData['style'];

          int count = 1;
          if (items != null) {
            wg = Padding(
                padding: const EdgeInsets.fromLTRB(10, 5, 0, 5),
                child: Column(
                    children: items
                        .map<Widget>((block) => Row(
                              children: [
                                Text(style == "unordered"
                                    ? '• '
                                    : (count++).toString() + '. '),
                                Text(block.toString())
                              ],
                            ))
                        .toList()));
          }
          break;
        }
    }
    return wg;
  }

  void onClickFavorite() {
    if (_isFavorite) {
      // remove from favorite lists
      ArtifactFavoriteMgr.remove(artifactPackage['id']);
    } else {
      // add to favorite list
      ArtifactFavoriteMgr.add(artifactPackage);
    }
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          !_isCachedData
              ? Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const MyHomePage()))
              : Navigator.of(context).pop();
          return false;
        },
        child: Scaffold(
          appBar: AppBar(
              title: Text(_appBarTitle),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => !_isCachedData
                    ? Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const MyHomePage()))
                    : Navigator.of(context).pop(),
              ),
              actions: <Widget>[
                Visibility(
                    visible: !_isLoading && _isHasAR,
                    child: Row(children: [
                      const Text(
                        'Trải nghiệm AR',
                        style: TextStyle(color: Colors.black),
                      ),
                      IconButton(
                        onPressed: () {
                          openARView();
                        },
                        icon: const Icon(Icons.view_in_ar),
                      )
                    ])),
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
                  padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                  color: Colors.white12,
                  child: ListView(
                      // This next line does the trick.
                      scrollDirection: Axis.vertical,
                      children: information['blocks'] != null
                          ? information['blocks']
                              .map<Widget>(
                                  (block) => createWidgetByBlock(block))
                              .toList()
                          : [])),
          // floatingActionButton: Visibility(
          //     visible: !_isLoading && _isHasAR,
          //     child: FloatingActionButton(
          //       onPressed: () {
          //         openARView();
          //       },
          //       backgroundColor: Colors.green,
          //       child: const Icon(Icons.view_in_ar),
          //     )),
        ));
  }
}
