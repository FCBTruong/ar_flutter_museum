import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:arcore_example/logic/api.dart';
import 'dart:developer';

class MuseumScene extends StatefulWidget {
  const MuseumScene({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MuseumScene();
}

class _MuseumScene extends State<MuseumScene> {
  @override
  initState() {
    super.initState();
    fetchData();
  }

  bool _isLoading = false;
  dynamic museums;

  void onViewMorePressed() {}
  void onContactPressed() {}
  void fetchData() async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.get(Uri.parse(publicMuseumsUrl));
    if (response.statusCode == 200) {
      log("museums: .. " + response.toString());
      var museumsInformation = json.decode(response.body);

      setState(() {
        museums = museumsInformation['museums'];
        _isLoading = false;
      });
    } else {
      log('error with fetching: ' + publicMuseumsUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: (_isLoading)
            ? const Center(child: CircularProgressIndicator())
            : Container(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                color: Colors.white24,
                child: ListView(
                    children: museums
                        .map<Widget>((museum) => MuseumCard(
                            title: museum['name'] ?? "Chưa cập nhật",
                            image: museum['imageUrl'] ??
                                "https://www.abc.net.au/news/image/117200-3x2-940x627.jpg",
                            address: museum['address'] ?? "Chưa cập nhật",
                            openingTime:
                                museum['openingTime'] ?? "Chưa cập nhật",
                            onViewMorePressed: onViewMorePressed,
                            onContactPressed: onContactPressed))
                        .toList()),
              ));
  }
}

class MuseumCard extends StatelessWidget {
  final String title;
  final String image;
  final String address;
  final String openingTime;
  final VoidCallback onViewMorePressed;
  final VoidCallback onContactPressed;

  MuseumCard({
    required this.title,
    required this.image,
    required this.address,
    required this.openingTime,
    required this.onViewMorePressed,
    required this.onContactPressed,
  });

  void openDirection() {
    MapsLauncher.launchQuery(address);

    // MapsLauncher.launchCoordinates(37.4220041, -122.0862462);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(title,
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center),
                ),
                const SizedBox(height: 8),
                image != ""
                    ? Image.network(image,
                        loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        }
                        return Center(
                          child: DecoratedBox(
                              decoration:
                                  BoxDecoration(color: Colors.grey[200]),
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
                      })
                    : Container(),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on),
                    Expanded(
                        child: Text(
                      address,
                    )),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time_filled_rounded),
                    Expanded(
                        child: Text(
                      openingTime,
                    )),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: onContactPressed,
                      label: const Text('Tham quan'),
                      icon: const Icon(Icons.airplane_ticket_rounded),
                    ),
                    ElevatedButton.icon(
                      onPressed: openDirection,
                      label: const Text('Chỉ đường'),
                      icon: const Icon(Icons.directions),
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
