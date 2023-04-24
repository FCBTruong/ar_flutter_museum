import 'package:arcore_example/views/artifact_detail_scene.dart';
import 'package:flutter/material.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'dart:developer';

class LocalAndWebObjectsView extends StatefulWidget {
  final dynamic artifact;
  const LocalAndWebObjectsView({Key? key, required this.artifact})
      : super(key: key);

  @override
  State<LocalAndWebObjectsView> createState() => _LocalAndWebObjectsViewState();
}

class _LocalAndWebObjectsViewState extends State<LocalAndWebObjectsView> {
  late ARSessionManager arSessionManager;
  late ARObjectManager arObjectManager;
  late ARLocationManager arLocationManager;

//String localObjectReference;
  ARNode? localObjectNode;

//String webObjectReference;
  ARNode? webObjectNode;
  bool isTest = false;
  bool isViewingDetail = false;
  dynamic modelAsset;
  dynamic modelAr;
  bool isLoading = false;

  void onARViewCreated(
      ARSessionManager arSessionManager,
      ARObjectManager arObjectManager,
      ARAnchorManager arAnchorManager,
      ARLocationManager arLocationManager) {
    // 1
    this.arSessionManager = arSessionManager;
    this.arObjectManager = arObjectManager;
    this.arLocationManager = arLocationManager;
    // 2
    this.arSessionManager.onInitialize(
          showFeaturePoints: false,
          showPlanes: true,
          customPlaneTexturePath: "triangle.png",
          showWorldOrigin: true,
          handleTaps: false,
        );
    // 3
    this.arObjectManager.onInitialize();

    onWebObjectAtButtonPressed();
  }

  Future<void> onLocalObjectButtonPressed() async {
    // 1
    if (localObjectNode != null) {
      arObjectManager.removeNode(localObjectNode!);
      localObjectNode = null;
    } else {
      // 2
      //  log(' ${arLocationManager.currentLocation.latitude.toString()}');
      var newNode = ARNode(
          type: NodeType.localGLTF2,
          uri: "assets/Chicken_01/phoenix_bird.glb",
          scale: Vector3(2, 2, 2),
          position: Vector3(0, -0.5, -0.5),
          rotation: Vector4(1.0, 0.0, 0.0, 0.0));
      // 3
      bool? didAddLocalNode = await arObjectManager.addNode(newNode);
      localObjectNode = (didAddLocalNode!) ? newNode : null;
    }
  }

  Future<void> onWebObjectAtButtonPressed() async {
    log('artifaceModelAr' + widget.artifact['modelAr'].toString());

    modelAr = widget.artifact['modelAr'];
    modelAsset = modelAr['modelAsset'];

    if (modelAsset == null) {
      log('modelAsset is null');
      return;
    }
    setState(() {
      isLoading = true;
    });

    if (webObjectNode != null) {
      arObjectManager.removeNode(webObjectNode!);
      webObjectNode = null;
    } else {
      var newNode = ARNode(
          type: NodeType.webGLB,
          uri: modelAsset['url'],
          position: Vector3(0, 0, -0.5),
          scale: Vector3(modelAr['scale']['x'], modelAr['scale']['y'],
              modelAr['scale']['z']));
      bool? didAddWebNode = await arObjectManager.addNode(newNode);
      webObjectNode = (didAddWebNode!) ? newNode : null;
      setState(() {
        isLoading = false;
      });
      onEffectAR();
    }
  }

  void onEffectAR() {
    // sounds
  }

  Future<void> onTakeScreenshot() async {
    var image = await arSessionManager!.snapshot();
    await showDialog(
        context: context,
        builder: (_) => AlertDialog(
              insetPadding: const EdgeInsets.all(0),
              content: FractionallySizedBox(
                widthFactor: 1.0,
                heightFactor: 1.0,
                child: Container(
                    decoration: BoxDecoration(
                        image:
                            DecorationImage(image: image, fit: BoxFit.cover))),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    // TODO: Add save logic here
                  },
                  child: const Text('Lưu'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Đóng'),
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.artifact['name']),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                  child: SizedBox(
                child: isViewingDetail
                    ? Container(
                        padding: const EdgeInsets.fromLTRB(10, 40, 10, 0),
                        color: Colors.white12,
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(0),
                        child: Container(
                            color: Colors.black,
                            child: isTest
                                ? Container()
                                : Stack(children: <Widget>[
                                    ARView(
                                      onARViewCreated: onARViewCreated,
                                    ),
                                    Container(
                                      alignment: Alignment.center,
                                      child: isLoading
                                          ? Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                  Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 20,
                                                              right: 20),
                                                      child:
                                                          LinearProgressIndicator(
                                                        backgroundColor:
                                                            Colors.grey[300],
                                                      )),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  const Text(
                                                    'Đang tải mô hình 3D...',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  const Text(
                                                    'Bạn nên hướng camera vào khu vực rộng để có trải nghiệm tốt nhất',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.normal),
                                                  ),
                                                  ModelViewer(
                                                    src:
                                                        'https://modelviewer.dev/shared-assets/models/Astronaut.glb',
                                                    alt:
                                                        "A 3D model of an astronaut",
                                                    ar: true,
                                                    autoRotate: true,
                                                    cameraControls: true,
                                                  ),
                                                ])
                                          : Container(),
                                    ),
                                  ])),
                      ),
              )),
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: () {
                    onTakeScreenshot();
                  },
                ),
              )),
        ),
      ]),
    );
  }
}
