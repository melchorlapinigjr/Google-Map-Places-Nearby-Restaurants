import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:traveler/api_key.dart';

class MapView extends StatefulWidget {
  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  @override
  void initState() {
    super.initState();

    /// Add origin marker
    _addMarker(LatLng(_originLatitude, _originLongitude), "origin",
        BitmapDescriptor.defaultMarker);

    /// Add destination marker
    _addMarker(LatLng(_destLatitude, _destLongitude), "destination",
        BitmapDescriptor.defaultMarkerWithHue(90));
  }

  GoogleMapController mapController;

  // this will hold the generated polylines
  Set<Polyline> _polylines = {};
  // this will hold each polyline coordinate as Lat and Lng pairs
  List<LatLng> polylineCoordinates = [];
  // this is the key object - the PolylinePoints
  // which generates every polyline between start and finish
  PolylinePoints polylinePoints = PolylinePoints();

  double _originLatitude = 56.94801, _originLongitude = 24.10507;
  double _destLatitude = 59.637251887193415,
      _destLongitude = 24.720301818049453;
// this set will hold my markers
  final List<Marker> markers = [];

  showFBlikes(id) {
    print('tap marker $id');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Stack(
            children: [
              GoogleMap(
                onTap: (cordinate) {
                  _animateCamera(cordinate);
                },
                mapType: MapType.normal,
                initialCameraPosition: CameraPosition(
                  target: LatLng(_originLatitude, _originLongitude),
                  zoom: 8.4746,
                ),
                onMapCreated: _onMapCreated,
                polylines: _polylines,
                markers: markers.toSet(),
                compassEnabled: true,
                tiltGesturesEnabled: false,
              ),
              Positioned(
                left: 20,
                top: 10,
                right: 20,
                child: RaisedButton(
                  onPressed: () {
                    _moveCameraToCenter();

                    /// Get and draw polyline
                    _createPolylines();
                  },
                  child: Row(
                    children: [
                      Icon(Icons.place, color: Colors.redAccent),
                      SizedBox(
                        width: 10,
                      ),
                      Text("Show Nearby Restaurants"),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    print("\n\nMap ready.\n\n");
  }

  Future<void> _animateCamera(coordinate) async {
    final GoogleMapController controller = mapController;
    controller.animateCamera(CameraUpdate.newLatLng(coordinate));
  }

  _addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
    MarkerId markerId = MarkerId(id);
    Marker marker =
        Marker(markerId: markerId, icon: descriptor, position: position);
    markers.add(marker);
    print("Markers created!");
  }

  // Create the polylines for showing the route between two places
  _createPolylines() async {
    polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints
        .getRouteBetweenCoordinates(
      Secrets.API_KEY, // Google Maps API Key
      PointLatLng(_originLatitude, _originLongitude),
      PointLatLng(_destLatitude, _destLongitude),
      travelMode: TravelMode.transit,
    )
        .catchError((onError) {
      print("\n\nAn error occured possibly due to network issues\n\n");
    });

    print(result.toString());
    if (result != null) {
      print("\n\nResults not null.\n\n");

      if (result.points.isNotEmpty) {
        result.points.forEach((PointLatLng point) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        });
      }

      print(polylineCoordinates.toString());

      setState(() {
        PolylineId id = PolylineId('poly');
        Polyline polyline = Polyline(
          polylineId: id,
          color: Colors.red,
          points: polylineCoordinates,
          width: 3,
        );
        _polylines.add(polyline);
        print('\n\nPolyline made.\n\n');

        // add the constructed polyline as a set of points
        // to the polyline set, which will eventually
        // end up showing up on the map
      });
    } else {
      print("\n\nNo coordinates found between routes.\n\n");
    }
  }

  _moveCameraToCenter() async {
    final GoogleMapController controller = mapController;
    double _centerLatitude = 58.21996037527976;
    double _centerLongitude = 24.50057526961153;

    controller.animateCamera(
      CameraUpdate.newLatLngZoom(
          LatLng(_centerLatitude, _centerLongitude), 6.0),
    );
  }
}
