import 'dart:async';
import 'dart:typed_data';
import 'dart:io';

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
import 'package:ar_flutter_plugin/datatypes/hittest_result_types.dart';
import 'package:ar_flutter_plugin/models/ar_hittest_result.dart';
import 'package:ar_flutter_plugin/models/ar_anchor.dart';
import 'package:ar_flutter_plugin/datatypes/config_planedetection.dart';
import 'dart:developer';
import 'dart:ui';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

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
  ARAnchorManager? arAnchorManager;
  List<ARNode> nodes = [];
  List<ARAnchor> anchors = [];
  late ARNode? planeIndicator;

//String localObjectReference;
  ARNode? localObjectNode;

//String webObjectReference;
  ARNode? webObjectNode;
  bool isTest = false;
  bool isViewingDetail = false;
  dynamic modelAsset;
  dynamic modelAr;
  bool isLoading = false;
  bool hasTapped = false;
  double _sliderValue = 50.0;
  double _defaultScale = 1;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    arSessionManager!.dispose();
  }

  void onARViewCreated(
      ARSessionManager arSessionManager,
      ARObjectManager arObjectManager,
      ARAnchorManager arAnchorManager,
      ARLocationManager arLocationManager) {
    // 1
    this.arSessionManager = arSessionManager;
    this.arObjectManager = arObjectManager;
    this.arLocationManager = arLocationManager;
    this.arAnchorManager = arAnchorManager;
    // 2
    this.arSessionManager.onInitialize(
          showFeaturePoints: true,
          showPlanes: true,
          customPlaneTexturePath: "triangle.png",
          showWorldOrigin: false,
          handleTaps: true,
          handlePans: true,
          handleRotation: true,
        );
    // 3
    this.arObjectManager!.onInitialize();

    this.arSessionManager!.onPlaneOrPointTap = onPlaneOrPointTapped;
    this.arObjectManager!.onPanStart = onPanStarted;
    this.arObjectManager!.onPanChange = onPanChanged;
    this.arObjectManager!.onPanEnd = onPanEnded;
    this.arObjectManager!.onRotationStart = onRotationStarted;
    this.arObjectManager!.onRotationChange = onRotationChanged;
    this.arObjectManager!.onRotationEnd = onRotationEnded;
    // onWebObjectAtButtonPressed();
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

  Future<void> onPlaneOrPointTapped(
      List<ARHitTestResult> hitTestResults) async {
    if (nodes.isNotEmpty) {
      return;
    }
    modelAr = widget.artifact['modelAr'];
    modelAsset = modelAr['modelAsset'];

    if (modelAsset == null) {
      log('modelAsset is null');
      return;
    }
    setState(() {
      hasTapped = true;
      isLoading = true;
      _defaultScale = modelAr['scale']['x'].toDouble();
    });
    if(hitTestResults.isEmpty){
        ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(content: Text('Đặt mô hình lên mặt phẳng')));
       return;
    }
    var singleHitTestResult = hitTestResults.firstWhere(
        (hitTestResult) => hitTestResult.type == ARHitTestResultType.plane);
    if (singleHitTestResult != null) {
      var newAnchor =
          ARPlaneAnchor(transformation: singleHitTestResult.worldTransform);
      bool? didAddAnchor = await this.arAnchorManager!.addAnchor(newAnchor);
      if (didAddAnchor!) {
        this.anchors.add(newAnchor);
        // Add note to anchor
        var newNode = ARNode(
            type: NodeType.webGLB,
            uri: modelAsset['url'],
            scale: Vector3(_defaultScale, _defaultScale, _defaultScale),
            position: Vector3(0.0, 0.0, 0.0),
            rotation: Vector4(1.0, 0.0, 0.0, 0.0));
        bool? didAddNodeToAnchor = await this
            .arObjectManager!
            .addNode(newNode, planeAnchor: newAnchor);
        if (didAddNodeToAnchor!) {
          this.nodes.add(newNode);
        } else {
          this.arSessionManager!.onError("Adding Node to Anchor failed");
        }
      } else {
        this.arSessionManager!.onError("Adding Anchor failed");
      }
    }

    this.arSessionManager.onInitialize(
          showFeaturePoints: false,
          showPlanes: false,
          customPlaneTexturePath: "triangle.png",
          showWorldOrigin: false,
          handleTaps: true,
          handlePans: true,
          handleRotation: true,
        );
    setState(() {
      isLoading = false;
    });
    onEffectAR();
  }

  onPanStarted(String nodeName) {
    print("Started panning node " + nodeName);
  }

  onPanChanged(String nodeName) {
    print("Continued panning node " + nodeName);
  }

  onPanEnded(String nodeName, Matrix4 newTransform) {
    print("Ended panning node " + nodeName);
    final pannedNode =
        this.nodes.firstWhere((element) => element.name == nodeName);

    /*
    * Uncomment the following command if you want to keep the transformations of the Flutter representations of the nodes up to date
    * (e.g. if you intend to share the nodes through the cloud)
    */
    //pannedNode.transform = newTransform;
  }

  onRotationStarted(String nodeName) {
    print("Started rotating node " + nodeName);
  }

  onRotationChanged(String nodeName) {
    print("Continued rotating node " + nodeName);
  }

  onRotationEnded(String nodeName, Matrix4 newTransform) {
    print("Ended rotating node " + nodeName);
    final rotatedNode =
        this.nodes.firstWhere((element) => element.name == nodeName);

    /*
    * Uncomment the following command if you want to keep the transformations of the Flutter representations of the nodes up to date
    * (e.g. if you intend to share the nodes through the cloud)
    */
    //rotatedNode.transform = newTransform;
  }

  onChangeSliderValue(double newValue) {
    setState(() {
      _sliderValue = newValue;
      if (nodes.isNotEmpty) {
        var curNode = nodes[0];
        double newScale = 0;
        var zoomScale = (newValue >= 50) ?  (newValue - 50) / 50 * 4 + 1 : 1 - (50 - newValue) / 50 * 4 / 5;
        newScale = _defaultScale * (zoomScale);
        curNode.scale = Vector3(newScale, newScale, newScale);
      }
    });
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
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: const Icon(Icons.close),
                  ),
                ],
              ),
              content: FractionallySizedBox(
                  widthFactor: 1.0,
                  heightFactor: 1,
                  child: Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.height * 0.8,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: image, fit: BoxFit.fitWidth)))),
              actions: [
                IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: () async {
                    // assume "imgProvider" is the ImageProvider you want to save
                    final Completer<ImageInfo> completer = Completer();
                    image.resolve(const ImageConfiguration()).addListener(
                          ImageStreamListener((ImageInfo info, bool _) =>
                              completer.complete(info)),
                        );

                    final ImageInfo info = await completer.future;

                    final ByteData bytes =
                        await info.image.toByteData() ?? ByteData(0);
                    final Uint8List imageData = bytes.buffer.asUint8List();

                    final result = await ImageGallerySaver.saveImage(imageData);

                    if (result != null && result['isSuccess']) {
                      // image successfully saved to photo gallery
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đã lưu vào thư viện')));
                    } else {
                      // image save failed
                      ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(content: Text('Lỗi')));
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () async {
                    // _onShare method:
                    final box = context.findRenderObject() as RenderBox?;
                    final Completer<ImageInfo> completer = Completer();
                    image.resolve(const ImageConfiguration()).addListener(
                          ImageStreamListener((ImageInfo info, bool _) =>
                              completer.complete(info)),
                        );

                    log('done....');
                    final ImageInfo info = await completer.future;

                    final ByteData bytes =
                        await info.image.toByteData() ?? ByteData(0);
                    final Uint8List imageData = bytes.buffer.asUint8List();

                    Directory appDocDir =
                        await getApplicationDocumentsDirectory();
                    String appDocPath = appDocDir.path;

                    // Join the document directory path with the filename.
                    var filename = 'share_image.png';
                    String filePath = '$appDocPath/$filename';

                    final File file = File(filePath);

                    await file.writeAsBytes(imageData);

                    await Share.shareFiles(
                      [filePath],
                      text: 'Share!',
                      sharePositionOrigin:
                          box!.localToGlobal(Offset.zero) & box.size,
                    );
                  },
                )
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
                                      planeDetectionConfig: PlaneDetectionConfig
                                          .horizontal,
                                    ),
                                    Container(
                                      alignment: Alignment.center,
                                      child: !hasTapped
                                          ? Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.all(
                                                          8.0),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black45,
                                                    borderRadius:
                                                        BorderRadius
                                                            .circular(8.0),
                                                  ),
                                                  child: const Text(
                                                    'Chạm vào vị trí bạn muốn đặt mô hình!',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight
                                                                .bold),
                                                  ),
                                                ),
                                              ])
                                          : (isLoading
                                              ? Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                      Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 20,
                                                                  right: 20),
                                                          child:
                                                              LinearProgressIndicator(
                                                            backgroundColor:
                                                                Colors
                                                                    .grey[300],
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
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      const Text(
                                                        'Bạn nên hướng camera vào khu vực rộng để có trải nghiệm tốt nhất',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal),
                                                      ),
                                                    ])
                                              : Container()),
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
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.add,
                    color: Colors.black87,
                  ),
                  RotatedBox(
                      quarterTurns: -1,
                      child: SliderTheme(
                        data: SliderThemeData(
                          thumbColor: Colors.blue,
                          activeTrackColor: Colors.blue,
                          inactiveTrackColor: Colors.grey,
                          overlayColor: Colors.blue.withOpacity(0.3),
                          thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 10.0),
                          overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 20.0),
                          trackHeight: 2.0,
                          tickMarkShape: const RoundSliderTickMarkShape(),
                        ),
                        child: Slider(
                          value: _sliderValue,
                          min: 0,
                          max: 100,
                          onChanged: (newValue) {
                            onChangeSliderValue(newValue);
                          },
                        ),
                      )),
                  const Icon(
                    Icons.remove,
                    color: Colors.black87,
                  ),
                ],
              )
            ],
          ),
        )
      ]),
    );
  }
}
