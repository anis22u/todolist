import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class taskdetailscreen extends StatefulWidget {
  final String title;
  final String description;
  final GeoPoint location;
  final String image;
  taskdetailscreen(
      {required this.title,
      required this.description,
      required this.location,
      required this.image});

  @override
  State<taskdetailscreen> createState() => _taskdetailscreenState();
}

class _taskdetailscreenState extends State<taskdetailscreen> {
  LatLng getGooglePlex() {
    if (widget.location.latitude != null && widget.location.longitude != null) {
      return LatLng(widget.location.latitude, widget.location.longitude);
    } else {
      throw 'Location not set yet!';
    }
  }

  GoogleMap gethemap() {
    return GoogleMap(
      initialCameraPosition: CameraPosition(target: getGooglePlex(), zoom: 13),
      markers: {
        Marker(
            markerId: MarkerId('_currentlocation'),
            icon: BitmapDescriptor.defaultMarker,
            position: getGooglePlex())
      },
    );
  }

  bool _showFullImage = false;
  bool _showMap = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0A0E21),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xffB0C4DE),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          //crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  left: 15, right: 15, top: 1, bottom: 10),
              child: Container(
                width: 400,
                color: Color(0xffB0C4DE),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Color(0xff2a2c57)),
                      children: [
                        const TextSpan(
                          text: 'Title: ',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        TextSpan(
                            text: '${widget.title}\n',
                            style: const TextStyle(
                              fontSize: 18,
                              fontFamily: 'NovaRound',
                            )),
                        const TextSpan(
                          text: 'Description:\n ',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        TextSpan(
                            text: '${widget.description},',
                            style: const TextStyle(
                              fontSize: 18,
                              fontFamily: 'NovaRound',
                            )),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // image
            GestureDetector(
              onTap: () {
                setState(() {
                  _showFullImage = !_showFullImage;
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 15, right: 15, top: 1, bottom: 10),
                child: Container(
                  child: Row(
                    children: [
                      const Text(
                        'image',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      _showFullImage
                          ? CachedNetworkImage(
                              imageUrl: widget.image,
                              placeholder: (context, url) =>
                                  CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                            )
                          : CachedNetworkImage(
                              imageUrl: widget.image,
                              placeholder: (context, url) =>
                                  CircularProgressIndicator(), // Show loading indicator
                              errorWidget: (context, url, error) => Icon(Icons
                                  .error), // Show error if image fails to load
                              width: 25, // Thumbnail width
                              height: 40, // Thumbnail height
                              //fit: BoxFit.cover, // Thumbnail fit
                            ),
                    ],
                  ),
                ),
              ),
            ),
            // Map Button
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _showMap = !_showMap;
                });
              },
              icon: const Icon(
                Icons.location_pin,
                color: Color(0xffB0C4DE),
                size: 35,
              ),
              label: const Text(
                'Open Map',
                style: TextStyle(color: Color(0xffB0C4DE)),
              ),
            ),
            SizedBox(height: 20),
            Container(
              height: 450,
              width: 360,
              child: _showMap ? gethemap() : Container(),
            )
          ],
        ),
      ),
    );
  }
}
