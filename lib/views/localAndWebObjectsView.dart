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
import 'dart:developer';

class LocalAndWebObjectsView extends StatefulWidget {
  const LocalAndWebObjectsView({Key? key}) : super(key: key);

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
  bool isTest = true;
  bool isViewingDetail = false;

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

    onLocalObjectButtonPressed();
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
          uri: "assets/Chicken_01/Velociraptor.glb",
          scale: Vector3(2, 2, 2),
          position: Vector3(0, -0.5, -0.5),
          rotation: Vector4(1.0, 0.0, 0.0, 0.0));
      // 3
      bool? didAddLocalNode = await arObjectManager.addNode(newNode);
      localObjectNode = (didAddLocalNode!) ? newNode : null;
    }
  }

  Future<void> onWebObjectAtButtonPressed() async {
    if (webObjectNode != null) {
      arObjectManager.removeNode(webObjectNode!);
      webObjectNode = null;
    } else {
      var newNode = ARNode(
          type: NodeType.webGLB,
          uri:
              "https://github.com/KhronosGroup/glTF-Sample-Models/raw/master/2.0/Duck/glTF-Binary/Duck.glb",
          scale: Vector3(0.2, 0.2, 0.2));
      bool? didAddWebNode = await arObjectManager.addNode(newNode);
      webObjectNode = (didAddWebNode!) ? newNode : null;
    }
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
      body: Padding(
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
                              : ARView(
                                  onARViewCreated: onARViewCreated,
                                )),
                    ),
            )),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ArtifactDetailScene()));
                });
              },
              child: const Text('read more', style: TextStyle(fontSize: 20)),
            )
          ],
        ),
      ),
    );
  }
}
