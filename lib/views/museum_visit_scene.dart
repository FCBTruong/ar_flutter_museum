import 'package:flutter/material.dart';

class MuseumVisitScene extends StatefulWidget {
  final dynamic museum;
  const MuseumVisitScene({Key? key, this.museum}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MuseumVisitScene();
}

class _MuseumVisitScene extends State<MuseumVisitScene> {
  List<dynamic> publicArtifacts = [];
  @override
  initState() {
    publicArtifacts = widget.museum['artifacts'];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.museum['name'].toString(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Column(
          children: [
            Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  widget.museum['introduction'].toString(),
                  style: const TextStyle(fontSize: 16),
                )),
            const SizedBox(
              height: 25,
            ),
            const Text(
              'Danh sách hiện vật',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
                child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: GridView.builder(
                      itemCount: publicArtifacts.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        return
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: AspectRatio(
                            aspectRatio: 1.0,
                            child: publicArtifacts[index]['image'] != ""
                                ? Image.network(publicArtifacts[index]['image'],
                                fit: BoxFit.cover,)
                                : Container()));
                      },
                    )))
          ],
        ));
  }
}
