import 'dart:ffi';

import 'package:arcore_example/views/DiscoveryScreen.dart';
import 'package:arcore_example/views/localAndWebObjectsView.dart';
import 'package:flutter/material.dart';
import 'package:arcore_example/qr_code.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';

class MyHomePage extends StatefulWidget {
  final String title;
  const MyHomePage({required this.title, Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MyHomePage();
}

class _MyHomePage extends State<MyHomePage> {
  int currentTab = 2;
  Widget _currentScreen = QRScanScene();
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
          _currentScreen = const DiscoveryScreen();
        });
        break;
      case 1:
        break;
      case 2:
        setState(() {
          _currentScreen = const QRScanScene();
        });
        break;

      case 3:
        setState(() {
          {
            _currentScreen = const LocalAndWebObjectsView();
          }
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            '${widget.title}',
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
      initialActiveIndex: 2,
      items: const [
        TabItem(icon: Icons.home, title: 'Home'),
        TabItem(icon: Icons.map, title: 'Discovery'),
        TabItem(icon: Icons.qr_code_scanner_rounded, title: 'Scan'),
        TabItem(icon: Icons.message, title: 'Message'),
        TabItem(icon: Icons.people, title: 'Profile'),
      ],
      onTap: (int i) => {onChangeTab(i, context)},
    ));
  }
}

// Center(
//           child: ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) => const LocalAndWebObjectsView()));
//               },
//               child: const Text("Local / Web Objects")),
//         )