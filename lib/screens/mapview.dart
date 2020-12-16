import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart' as places;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:traveler/utils/api_key.dart';
import 'package:traveler/utils/coordinates.dart';

class MapView extends StatefulWidget {
  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  GoogleMapController mapController;

  // this will hold the generated polylines
  Map<PolylineId, Polyline> polylines = {};
  // this will hold each polyline coordinate as Lat and Lng pairs
  List<LatLng> polylineCoordinates = [];
  // this is the key object - the PolylinePoints
  // which generates every polyline between start and finish
  PolylinePoints polylinePoints = PolylinePoints();

  // this will hold my markers
  Map<MarkerId, Marker> markers = {};
  @override
  void initState() {
    super.initState();

    /// Add origin marker
    _addMarker(LatLng(originLatitude, originLongitude), "origin",
        BitmapDescriptor.defaultMarker, '', '', '', false);

    /// Add destination marker
    _addMarker(LatLng(destLatitude, destLongitude), "destination",
        BitmapDescriptor.defaultMarkerWithHue(90), '', '', '', false);

    /// Get and draw polyline
    _createPolylines();
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
                  target: LatLng(originLatitude, originLongitude),
                  zoom: 8.4746,
                ),
                onMapCreated: _onMapCreated,
                markers: Set<Marker>.of(markers.values),
                polylines: Set<Polyline>.of(polylines.values),
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
                    _showNearbyRestaurants();
                  },
                  child: Row(
                    children: [
                      SizedBox(
                        width: 10,
                      ),
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

  _addMarker(
      LatLng position,
      String nameId,
      BitmapDescriptor descriptor,
      String infoTitle,
      String infoVicinity,
      String infoRating,
      bool isRestaurant) {
    MarkerId markerId = MarkerId(nameId);
    Marker marker = Marker(
        markerId: markerId,
        icon: descriptor,
        position: position,
        draggable: false,
        infoWindow: isRestaurant
            ? InfoWindow(
                title: infoTitle,
                snippet: "Rating: $infoRating",
                onTap: () {
                  return AlertDialog(
                    title: Text(infoTitle),
                    content: Text(infoVicinity),
                  );
                })
            : InfoWindow());
    markers[markerId] = marker;
    print("Marker created!");
  }

  // Create the polylines for showing the route between two places
  _createPolylines() async {
    polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints
        .getRouteBetweenCoordinates(
      Secrets.GOOGLE_API_KEY, // Google Maps API Key
      PointLatLng(originLatitude, originLongitude),
      PointLatLng(destLatitude, destLongitude),
      travelMode: TravelMode.driving,
    )
        .catchError((onError) {
      print("\n\nAn error occured possibly due to network issues\n\n");
    });

    if (result != null) {
      print("\n\nResults not null.\n\n");
      print('Points length : ' + result.points.length.toString());

      if (result.points.isNotEmpty) {
        result.points.forEach((PointLatLng point) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        });
      } else {
        print("No coordinate points available.");
      }

      setState(() {
        PolylineId id = PolylineId('poly');
        Polyline polyline = Polyline(
          polylineId: id,
          color: Colors.red,
          points: polylineCoordinates,
          width: 3,
        );
        polylines[id] = polyline;
        setState(() {
          print('\n\nPolyline made.\n\n');
        });

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

    controller.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(centerLatitude, centerLongitude), 8.0),
    );
  }

  _showNearbyRestaurants() async {
    places.GoogleMapsPlaces _places =
        places.GoogleMapsPlaces(apiKey: Secrets.GOOGLE_API_KEY);

    final centerLocation = places.Location(centerLatitude, centerLongitude);
    final result = await _places.searchNearbyWithRadius(centerLocation, 200000,
        type: "resturant");

    if (result.status == "OK") {
      print(result.results.toString());
      print("\nNearby request successful!\n");
      setState(() {
        result.results.forEach((data) {
          _addMarker(
              LatLng(data.geometry.location.lat, data.geometry.location.lng),
              data.name,
              BitmapDescriptor.defaultMarkerWithHue(25),
              data.name,
              data.reference,
              data.rating.toString(),
              true);
        });
      });
    }
  }
}
