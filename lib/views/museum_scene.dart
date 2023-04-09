import 'package:flutter/material.dart';
import 'dart:convert';

class MuseumScene extends StatefulWidget {
  const MuseumScene({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MuseumScene();
}

class _MuseumScene extends State<MuseumScene> {
  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          color: Colors.white24,
        ));
  }
}
