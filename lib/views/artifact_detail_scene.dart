import 'package:arcore_example/views/audio_player.dart';
import 'package:arcore_example/views/localAndWebObjectsView.dart';
import 'package:arcore_example/views/video_app.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:developer';
import 'package:arcore_example/logic/text_handler.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:arcore_example/logic/artifact_favorite_mgr.dart';
import 'package:appinio_video_player/appinio_video_player.dart';

class ArtifactDetailScene extends StatefulWidget {
  final String url;
  const ArtifactDetailScene({Key? key, required this.url}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ArtifactDetailScene();
}

class _ArtifactDetailScene extends State<ArtifactDetailScene> {
  bool _isLoading = true;
  String _appBarTitle = 'Đang tải';
  Map<String, dynamic> data = {};
  bool _isFavorite = false;
  List<CustomVideoPlayerController> _videoControllers = [];
  int _videoIdx = 0;
  late CustomVideoPlayerController _customVideoPlayerController;
  late VideoPlayerController videoPlayerController;

  @override
  initState() {
    super.initState();
    _isLoading = true;
    _isFavorite = false;
    fetchData();
    _videoControllers = [];
    _videoIdx = 0;
  }

  Future fetchData() async {
    // fetch data and update app bar title when done
    final response = await http.get(Uri.parse(
        widget.url));
    if (response.statusCode == 200) {
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
            child: Image.network(blData['file']['url'],
                loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                return child;
              }
              return const Center(
                child: SizedBox(
                    width: 150,
                    height: 150,
                    child: SizedBox(
                      child: CircularProgressIndicator(
                        // value: loadingProgress.expectedTotalBytes != null
                        //     ? loadingProgress.cumulativeBytesLoaded /
                        //         loadingProgress.expectedTotalBytes!
                        //     : null,
                      ),
                      height: 20.0,
                      width: 20.0,
                    )),
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
