import 'dart:ffi';

import 'package:arcore_example/views/DiscoveryScreen.dart';
import 'package:arcore_example/views/localAndWebObjectsView.dart';
import 'package:arcore_example/views/museum_scene.dart';
import 'package:flutter/material.dart';
import 'package:arcore_example/qr_code.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'favorite_scene.dart';
import 'video_app.dart';
import 'temp.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MyHomePage();
}

class _MyHomePage extends State<MyHomePage> {
  String title = "AR";
  int currentTab = 2;
  Widget _currentScreen = const QRScanScene();
  final PageStorageBucket _bucket = PageStorageBucket();

  @override
  initState() {
    super.initState();
  }

  void onChangeTab(int tab, BuildContext context) {
    // ignore: avoid_print
    print('tab: ' + tab.toString());
    currentTab = tab;

    switch (currentTab) {
      case 0:
        setState(() {
          _currentScreen = const MuseumScene();
          title = "Bảo tàng";
        });
        break;
      case 1:
        setState(() {
          _currentScreen = const QRScanScene();
          title = "Quét mã";
        });
        break;
      case 2:
        setState(() {
          _currentScreen =  const FavoriteScene();
          title = "Yêu thích";
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            title,
          ),
        ),
        body: Container(
          child: PageStorage(
            child: _currentScreen,
            bucket: _bucket,
          ),
        ),
        bottomNavigationBar: createBottomAppBar(context));
  }

  BottomAppBar createBottomAppBar(BuildContext context) {
    return BottomAppBar(
        child: ConvexAppBar(
      initialActiveIndex: 1,
      items: const [
        TabItem(icon: Icons.museum, title: 'Museum'),
        TabItem(icon: Icons.qr_code_scanner_rounded, title: 'Scan'),
        TabItem(icon: Icons.favorite, title: 'Favorite'),
      ],
      onTap: (int i) => {onChangeTab(i, context)},
    ));
  }
}
