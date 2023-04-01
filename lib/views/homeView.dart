import 'package:arcore_example/views/localAndWebObjectsView.dart';
import 'package:flutter/material.dart';
import 'package:arcore_example/qr_code.dart';

class MyHomePage extends StatelessWidget {
  final String title;

  const MyHomePage({required this.title, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: Center(
          child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LocalAndWebObjectsView()));
              },
              child: const Text("Local / Web Objects")),
        ),
        bottomNavigationBar: createBottomAppBar(context));
  }

  BottomAppBar createBottomAppBar(BuildContext context) {
    return BottomAppBar(
        color: Colors.white,
        shape: CircularNotchedRectangle(),
        clipBehavior: Clip.antiAlias,
        notchMargin: 5.0,
        child: Container(
            height: 70,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                // left tab bar icons
                children: <Widget>[
                  Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        // Study Icon
                        MaterialButton(
                          color: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50.0),
                            ),
                            minWidth: 50,
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const QRViewExample(),
            ));
                            })
                      ])
                ])));
  }
}
